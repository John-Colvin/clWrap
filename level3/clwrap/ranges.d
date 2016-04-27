
import std.typecons : Flag;
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
if (is(Args[0] == CLKernelDef!X, X) || is(Args[0] == CLKernel!X, X))
{
    clBegin!Yes.Blocking(args);
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
{
    context.createProgram(kernelDef)
    .buildProgram
    .createKernel!(KernelDefT.name)
    .clBegin!blocking;
}

auto clBegin(Flag!"Blocking" blocking = No.Blocking, KernelT, Args ...)(KernelT kernel, Args args)
{
    kernel.setArgs(args);
    queue.enqueueCLKernel(kernel);
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
