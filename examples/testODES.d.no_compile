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

static immutable string integrateCode = 
`
__kernel
void integrate(__global float* states,
               __global float* statesNew,
               float deltaT,
               float gamma,
               float beta,
               size_t s,
               size_t baseIdx,
               size_t rowLen,
               float sumRatio
               )
{
    size_t i = get_global_id(0);
    float state_s_i = states[i + baseIdx];
    float state_s_ip1 = states[i + baseIdx + 1];
    float state_sp1_im1 = states[rowLen * (i + 1) - (i*i + i)/2 + j - 1];

    
    float d = - gamma * i * state_s_i
              + gamma * (i+1) * state_s_ip1
              + beta * i * state_s_i
              + sumRatio * (-s * state_s_i + (s + 1) * state_sp1_im1);

    statesNew[i + baseIdx] = state_s_i + d * deltaT;
}
`;

alias IntegrateKernelT = Kernel!(
        cl_mem, "states",
        cl_mem, "statesNew",
        float,  "deltaT",
        float,  "gamma",
        float,  "beta",
        size_t, "s",
        size_t, "baseIdx",
        size_t, "rowLen",
        float,  "sumRatio");

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

    auto program = createProgramFromSource(context, integrateCode)
        .buildProgram();

    auto integrate = IntegrateKernelT(
            clCreateKernel(program, "someKernel", &status)
            );
    status.clEnforce();

    alias FPType = float;

    float deltaT = 0.01;
    float gamma = 0.1;
    float beta = 0.2;
    ulong M = 300;
    auto states = StateSpace!FPType(300);

    //initialise states


    auto statesBuff = clBuffer!FPType(context,
            CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR,
            states.density
            );
    
    auto statesNewBuff = clBuffer!FPType(context,
            CL_MEM_READ_WRITE, states.density.length);

    auto integrationStep = task(integration);

    integrationStep.defaultArgs.deltaT = deltaT;
    integrationStep.defaultArgs.gamma = gamma;
    integrationStep.defaultArgs.beta = beta;

    foreach(t; 0 .. 10)
    {
        foreach(s_; states.width)
        {
            with(integrationStep.args)
            {
                states = statesBuff;
                statesNew = statesNewBuff;
                s = s_;
                baseIdx = 
            } 
        }
        cl_event t1Ev;
        if(i == 0)
            t1Ev = task1.instance(queue)(devBuff, i);
        else
            t1Ev = task1.instance(queue).dependsOn(t1Ev)(devBuff, i);
    }

    auto someMemory = new float[110];
    queue.clRead(devBuff, someMemory, true, 0, [t2Ev]);

    writeln(someMemory);
}

struct StateSpace(FPType)
{
    size_t width;
    FPType[] density;

    this(size_t maxIorS)
    {
        width = maxIorS + 1;
        density = new ulong[((width + 1) * width) / 2];
    }

    size_t si2n(size_t s, size_t i)
    {
        return width * s - (s*s - s) / 2;
    }

    Tuple!(size_t, "s", size_t, "i") n2si(size_t n)
    {
        auto wph = width + 0.5;
        auto s = size_t(wph - sqrt(wph*wph - 2*n));
        return tuple(s, n + (s*s)/2 - wph*i);
    }

    auto opIndex(size_t n)
    {
        return density[n];
    }

    auto opIndex(size_t s, size_t i)
    {
        return density[si2n(s, i)];
    }
}


