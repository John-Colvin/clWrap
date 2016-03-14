import clWrap;
import clWrap.task;

import std.typecons : tuple;
import std.range;
import std.algorithm;
import std.conv;
import std.stdio;

auto kernelDefA = CLKernelDef!("kernelA", 2,
        CLBuffer!float, "input", float, "b")
(q{
    size_t idx = get_global_id(0) * get_global_size(1) + get_global_id(1);

    input[idx] += exp(cos(b));
});

auto kernelDefB = CLKernelDef!("kernelB", 2,
        CLBuffer!float, "input", uint, "a")
(q{
    size_t idx = get_global_id(0) * get_global_size(1) + get_global_id(1);

    input[idx] += sqrt(input[idx] + a);
});

void main()
{
    auto platform = getChosenPlatform();

    auto devices = platform.getDevices(cl.DEVICE_TYPE_GPU);
    devices.map!(getInfo!(cl.DEVICE_NAME)).writeln;

    auto context = devices.createContext();

    auto queue = createCommandQueue(context, devices[0]);/*,
            OUT_OF_ORDER_EXEC);*/

    auto kernels = context.createProgram(kernelDefA, kernelDefB)
        .buildProgram.createKernel!("kernelA", "kernelB");
    auto kernelA = kernels[0];
    auto kernelB = kernels[1];

    auto input = iota(1_024 * 10_240).map!(to!float).array;
    auto devBuff = context.newBuffer(cl.MEM_COPY_HOST_PTR, input);

    auto task1 = task(kernelA);
    auto task2 = task(kernelB);

    task1.globalRange[queue] = [[0, 1024], [0, 10_240]];
    task1.localSize[queue] = [8, 64];

    task1.defaultArgs[0] = devBuff;

    task2.globalRange[queue] = [[0, 1024], [0, 10_240]];
    task2.localSize[queue] = [8, 64];

    task2.defaultArgs = tuple(devBuff, 4);

    cl.event t2Ev;
    foreach(i; 0 .. 10)
    {
        cl.event t1Ev;
        if(i == 0)
            t1Ev = task1.instance(queue)(devBuff, i);
        else
            t1Ev = task1.instance(queue).dependsOn(t2Ev)(devBuff, i);

        auto task2i = task2.instance(queue);

        if(i & 1) task2i.args[1] = 3;

        task2i.dependsOn(t1Ev);

        t2Ev = task2i.enqueue();
    }

    queue.read(devBuff, input, Yes.Blocking, 0, [t2Ev]);
}
