string clType(T)()
{
    static if (is(T == CLBuff!(X[]), X) | is(T == CLImage!(X[]), X))
        return X.stringof;
    else
        return T.stringof;
}

enum CLType(T) = clType!T;

auto clCall(Args ...)(Args args)
if (is(Args[0] == CLKernelDef!X, X) || is(Args[0] == CLKernel!X, X))
{
    clBegin!Yes.Blocking(args);
}

auto clBegin(Flag!"Blocking" blocking = No.Blocking, Args ...)(const(char)[] source, Args args)
{
    CLKernelDef!(2, Args)(
            `__kernel void(` ~ [staticMap!(CLType, Args)].joiner(",")
          ~ ")\n{\n" ~ source ~ "\n}"
    ).clBegin!blocking;
}

auto clBegin(Flag!"Blocking" blocking = No.Blocking, KernelDefT, Args ...)(KernelDefT kernelDef, Args args)
{
    context.createProgram(kernelDef)
         .buildProgram
         .clBegin!blocking;
}

auto clBegin(Flag!"Blocking" blocking = No.Blocking, KernelT, Args ...)(KernelT kernel, Args args)
{
    kernel.setArgs(args);
    queue.enqueueCLKernel(kernel);
}

struct CLSetup
{
    cl.platform platform;
    cl.device[] devices;
    cl.context context;
    cl.command_queue queue;
}

CLSetup defaultSetup;

static this()
{
    defaultSetup.platform  = getChosenPlatform();
    defaultSetup.devices = platform.getDevices(cl.DEVICE_TYPE_GPU);
    defaultSetup.context = devices.createContext();
    defaultSetup.queue = context.createCommandQueue(devices[0]);
}

auto clWith(Foo)(CLSetup setup, Foo foo)
if (isCallable!Foo)
{
    auto setupBack = defaultSetup;
    defaultSetup = setup;
    scope(exit) defaultSetup = setupBack;
    return foo();
}

private alias isSetupMember(T) = is(T : cl.platform) || is(T : cl.device[])
    || is(T : cl.context) || is(T : cl.command_queue);

//TODO: how useful is this really? Does it actually make sense to
//change these independently
auto clWith(Args ...)(Args args)
static if (Args.length > 1 && isCallable!(Args[$-1])
    && allSatisfy!(isSetupMember, Args[0 .. $-1]))
{
    CLSetup setup = defaultSetup;
    foreach(arg; args[0 .. $-1])
    {
        static if (is(T : cl.platform))
            setup.platform = arg;
        else static if (is(T : cl.device[]))
            setup.devices = arg;
        else static if (is(T : cl.context))
            setup.context = arg;
        else static if (is(T : cl.command_queue))
            setup.queue = arg;
        else static assert(false);
    }
}


/+
/*
   Different bases:

   Array

   Generator
 */

struct CLMap(alias newFragment, Fragment, Backing)
{
    Backing b;
    frag;


}

unittest
{
    iota(100).buffer.CLMap!"a + 1".read.enqueue;
    iota(100).array.CLMap!"a + 1".read.enqueue;
    int[100] buff;
    iota(100).array.CLMap!"a + 1".read(buff[]).enqueue;


}
+/
