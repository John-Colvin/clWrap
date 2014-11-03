import clWrap.wrap;
import clWrap.task;
import clWrap.clSelect;
import clWrap.errors;

import derelict.opencl.cl;

import std.typecons : tuple;
import std.range;
import std.algorithm;
import std.conv;
import std.stdio;

static immutable string kernelA = 
`
__kernel
void someKernel(__global float* input, float b)
{
    size_t i = get_global_id(0);
    size_t j = get_global_id(1);

    input[i + j] = exp(cos(b));
}
`;

static immutable string kernelB = 
`
__kernel
void someOtherKernel(__global float* input, uint a)
{
    size_t i = get_global_id(0);
    size_t j = get_global_id(1);

    input[i + j] = sqrt(input[i + j] + a);
}
`;

void main()
{
    DerelictCL.load();
    auto platform = getChosenPlatform();
    DerelictCL.reload(platform.version_);
    auto devices = getDevices(platform);
    auto context = createContext(devices);
    devices.map!(d => d.getInfo!CL_DEVICE_NAME).writeln;
    auto queue = createCommandQueue(context, devices[0],
            OUT_OF_ORDER_EXEC);

    auto program = createProgramFromSource(context, [kernelA, kernelB])
        .buildProgram();

    auto someKernel = Kernel!(2, cl_mem, float)(
            clCreateKernel(program, "someKernel", &status)
            );
    status.clEnforce();
    auto someOtherKernel = Kernel!(2, cl_mem, uint)(
            clCreateKernel(program, "someOtherKernel", &status)
            );
    status.clEnforce();

    auto devBuff = clBuffer!float(context,
            CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
            iota(110).array.to!(float[])
            );

    auto task1 = task(someKernel);
    auto task2 = task(someOtherKernel);

    task1.globalRange[queue] = [[0, 100], [0, 10]];
    task1.localSize[queue] = [20, 1];

    task1.defaultArgs[0] = devBuff;

    task2.globalRange[queue] = [[0, 100], [0, 10]];
    task2.localSize[queue] = [20, 1];

    task2.defaultArgs = tuple(devBuff, 4);

    cl_event t2Ev;
    foreach(i; 0 .. 10)
    {
        cl_event t1Ev;
        if(i == 0)
            t1Ev = task1.instance(queue)(devBuff, i);
        else
            t1Ev = task1.instance(queue).dependsOn(t2Ev)(devBuff, i);

        auto task2i = task2.instance(queue);
        
        if(i & 1) task2i.args[1] = 3;

        task2i.dependsOn(t1Ev);
        
        t2Ev = task2i.enqueue();
    }

    auto someMemory = new float[110];
    queue.clRead(devBuff, someMemory, true, 0, [t2Ev]);

    writeln(someMemory);
}
