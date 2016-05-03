import std.typecons : Flag, Yes, No;
import clwrap;

string clType(T)()
{
    static if (is(T == CLBuff!(X[]), X) | is(T == CLImage!(X[]), X))
        return X.stringof;
    else
        return T.stringof;
}

enum CLType(T) = clType!T;

auto clCall(Args ...)(Args args)
if (is(Args[0] == CLKernelDef!X, X...) || is(Args[0] == CLKernel!X, X...))
{
    clBegin!(Yes.Blocking)(args);
}

struct Named(string name_, T)
{
    enum name = name_;
    alias Type = T;
    T val;
}

auto named(string name, T)(T val)
{
    return Named!name(val);
}

enum isNamed(T) = isInstanceOf!(Named, T);

template GetName(T)
if (isNamed!T)
{
    enum GetName = T.name;
}

enum GetName(alias a) = __traits(identifier, a);

template GetType(T)
if (isNamed!T)
{
    alias GetType = T.Type;
}

alias GetType(alias a) = typeof(a);

//pass aliases
template clBegin(Params ...)
{
    // could support things other than Named with some default naming scheme
    auto clBegin(Flag!"Blocking" blocking = No.Blocking, Args ...)(const(char)[] source, Args args)
    if (allSatisfy!(isNamed, Args))
    {
        alias names = staticMap!(GetName, AliasSeq!(Params, Args));
        alias types = staticMap!(GetType, AliasSeq!(Params, Args));


        CLKernelDef!(2, Args)(source).clBegin!blocking;
    }
}

auto clBegin(Flag!"Blocking" blocking = No.Blocking, KernelDefT, Args ...)(KernelDefT kernelDef, Args args)
if (is(KernelDefT : CLKernelDef!X, X...))
{
    cld.context.createProgram(kernelDef)
    .buildProgram
    .createKernel!(KernelDefT.name)
    .clBegin!blocking(args);
}

auto clBegin(Flag!"Blocking" blocking = No.Blocking, KernelT, Args ...)(KernelT kernel, Args args)
if (is(KernelT : CLKernel!X, X...) && is(Args[0] : size_t[]))
{
    kernel.setArgs(args[1 .. $]);
    cld.queue.enqueueCLKernel(kernel, args[0]);
    static if (blocking)
        cl.finish();
}

struct CLSetup
{
    cl.platform_id platform;
    cl.device_id[] devices;
    cl.context context;
    cl.command_queue queue;
}

CLSetup defaultSetup;
alias cld = defaultSetup;

static this()
{
    defaultSetup.platform  = getChosenPlatform();
    defaultSetup.devices = defaultSetup.platform.getDevices(cl.DEVICE_TYPE_GPU);
    defaultSetup.context = defaultSetup.devices.createContext();
    defaultSetup.queue = defaultSetup.context.
        createCommandQueue(defaultSetup.devices[0]);
}

auto clWith(Foo)(CLSetup setup, Foo foo)
if (isCallable!Foo)
{
    auto setupBack = defaultSetup;
    defaultSetup = setup;
    scope(exit) defaultSetup = setupBack;
    return foo();
}

private enum isSetupMember(T) = is(T : cl.platform) || is(T : cl.device[])
    || is(T : cl.context) || is(T : cl.command_queue);

//TODO: how useful is this really? Does it actually make sense to
//change these independently
auto clWith(Args ...)(Args args)
if (Args.length > 1 && isCallable!(Args[$-1])
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


/+
buffers are created with regard to a context, available for everyone in that context

kernels combine to make a program, program must be created for specfic context, built for specific devices. kernel is extracted from program, has arguments set, and then placed on a queue to be executed.

Really you just want to make calls to a given kernel on a queue. Barely ever want to set args seperately from queuing. Lazy chaining of kernels isn't such a big win, because you'll be writing to memory and re-reading every time.

Chaining needs to be done by creating one kernel containing all the steps (or using pipes and/or spawning kernels in kernels, when we have opencl 2)

ideal non-functional workflow:
clCall!kernel([1000, 300], param0, param1.createBuffer(), param2);

ideal functional workflow:
data.clMap!someKernel(otherArgs); //returns OpenCL buffer

given an ndslice, you can extract the pointer, the lengths and the strides. Can copy the whole thing and only map over part, or can copy data to contiguous memory first. Could also map to multiple buffers and paper over the cracks in OpenCL-C??

data.sliced(1000, 300).clMap!someKernel;

could have set the other arguments first? A bit like partial?

or could call the alias argument if it's callable:
data.clMap!(arg => kernel.setArgs(3.4, 42, arg));

chained;
data.clMap!someFunction.clMap!someOtherFunction;

I think I have to have some task-based setup:

auto ev = data.createBuffer.clMap!kernel
    .padForLocalSize(64, 32)
    .call(otherArgs);
+/
private enum bool isSlice(T) = is(T : Slice!(N, Range), size_t N, Range);

auto clMap(alias kernel, Flag!"Blocking" = No.Blocking, Slice)(Slice s, )
if (is(typeof(kernel) : CLKernel!X, X...) && isSlice(Slice) && hasMember!(Slice, "ptr"))
{
    auto structure = s.structure;
    auto shape = s.shape;
    auto strides = s.strides;
    auto p = zip(shape[], strides[]).maxPos!"a[1] < b[1]"[0];
    auto length = p[0] * p[1];

    kernel.setArgs(args[1 .. $]);

}
