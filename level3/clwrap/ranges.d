import std.typecons : Flag, Yes, No, Nullable;
import clwrap;
import std.traits : hasMember, isInstanceOf;
import std.range : iota;

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
    auto clBegin(Flag!"Blocking" blocking = Yes.Blocking, Args ...)(const(char)[] source, Args args)
    if (allSatisfy!(isNamed, Args))
    {
        alias names = staticMap!(GetName, AliasSeq!(Params, Args));
        alias types = staticMap!(GetType, AliasSeq!(Params, Args));


        CLKernelDef!(2, Args)(source).clBegin!blocking;
    }
}

auto clBegin(Flag!"Blocking" blocking = Yes.Blocking, KernelDefT, Args ...)(KernelDefT kernelDef, Args args)
if (is(KernelDefT : CLKernelDef!X, X...))
{
    cld.context.createProgram(kernelDef)
    .buildProgram
    .createKernel!(KernelDefT.name)
    .clBegin!blocking(args);
}

auto clBegin(Flag!"Blocking" blocking = Yes.Blocking, KernelT, Args ...)(KernelT kernel, Args args)
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

import mir.ndslice;

// What if there's some offset? All handled in strides in slice
private auto getFlatSlice(SliceT)(SliceT s)
if (isInstanceOf!(Slice, SliceT) && is(typeof(SliceT.ptr()) : Q*, Q))
{
    //surely if it's a pointer underneath I can just get the address
    //of the last element as well as the first?
    import std.range : zip;
    import std.algorithm : minPos;
    auto structure = s.structure;
    auto shape = s.shape;
    auto strides = structure.strides;
    auto p = zip(shape[], strides[]).minPos!"a[1] > b[1]".front;
    auto length = p[0] * p[1];

    return s.ptr[0 .. length];
}

auto clMap(alias kernel, BufferSliceT, Flag!"Blocking" blocking = Yes.Blocking, size_t buffIdx = 0, Args ...)
    (BufferSliceT buffer, Args args)
if (is(typeof(kernel) : CLKernel!X0, X0...) && is(BufferSliceT : CLBufferSlice!X1, X1...))
in
{
    assert(buffer.strides[$-1] == 1);
    static if (buffer.strides.length > 1)
        assert(buffer.strides[$-2] == buffer.shape[$-1]);
    static if (buffer.strides.length > 2)
        assert(buffer.strides[$-3] == buffer.shape[$-1] * buffer.shape[$-2]);
}
body
{
    kernel.setArgs(args[0 .. buffIdx], buffer.toCLBuffer, args[buffIdx .. $]);

    struct Res
    {
        cl.kernel id;
        Nullable!(size_t[BufferSliceT.nDims]) localSizes;

        Res setLocalSizes(typeof(localSizes) newSizes)
        {
            localSizes = newSizes;
            return this;
        }
        auto enqueue()
        {
            return cld.queue.enqueueCLKernel(kernel, buffer.shape[], buffer.offsets[],
                localSizes.isNull ? null : localSizes.get[]);
        }
    }

    return Res(kernel);
}

auto toBuffer(SliceT)(SliceT slice, cl.mem_flags flags)
if (isInstanceOf!(Slice, SliceT) && hasMember!(SliceT, "ptr") && slice.shape.length <= 3)
in
{
    import std.algorithm : all;
    assert(slice.structure.strides[].all!"a > 0",
        "toBuffer does not support slices with negative strides");
}
body
{
    alias ElemT = typeof(slice.byElement.front);
    enum ND = SliceT.init.shape.length;
    auto flatSlice = slice.getFlatSlice;
    auto shape = slice.shape;
    auto strides = slice.structure.strides;
    return CLBufferSlice!(ElemT, ND)(
        cld.context.newBuffer(flags, slice.getFlatSlice),
        Slice!(ND, typeof(iota(size_t.init)))(
            /*slice.*/shape,
            /*slice.structure.*/strides,
            iota(flatSlice.length)
        )
    );
}
/+
auto toBuffer(T)(T[] data, cl.mem_flags flags)
{
    return CLBufferSlice!(T, 1)(
        cld.context.newBuffer(flags, data),
        [data.length],
        [0],
        [1]
    );
}+/

struct CLBufferSlice(T, size_t nDims_ = 1)
if (nDims_ != 0 && nDims_ <= 3)
{
    cl.mem buffer;
    alias buffer this;

    enum nDims = nDims_;
    Slice!(nDims, typeof(iota(size_t.init))) dummySlice;

    this(cl.mem buffer, size_t[nDims] shape)
    {
        import std.algorithm : fold;
        this.buffer = buffer;
        this.dummySlice = iota(shape[].fold!"a*b"(size_t(1))).sliced(shape);
    }

    void assignToDummySlice(T)(T s)
    {
        dummySlice = s;
    }

    this(cl.mem buffer, typeof(dummySlice) index)
    {
        this.buffer = buffer;
        this.dummySlice = index;
    }

    /++
    + These offsets don't mean a whole lot...
    +/
    size_t[nDims] offsets() @property
    {
        import std.algorithm : makeIndex;
        //import std.stdio;
        size_t[nDims] ret;
        size_t[nDims] inStrideOrderIdx;
        auto strides = dummySlice.structure.strides;
        makeIndex(dummySlice.structure.strides[], inStrideOrderIdx[]);
        size_t remainder = dummySlice.byElement[0];
        //writeln("linearIdx ", remainder);
        foreach_reverse(idx; inStrideOrderIdx)
        {
            ret[idx] = remainder / strides[idx];
            remainder %= strides[idx];
        }
        assert(remainder == 0);
        //writeln(dummySlice.structure, " ", ret);
        return ret;
    }

    size_t[nDims] shape() @property
    {
        return dummySlice.shape;
    }

    long[nDims] strides() @property
    {
        return dummySlice.structure.strides;
    }

    template opDispatch(string s)
    if (s != "clRead" && s != "clMap" && s != "clWrite")
    {
        template opDispatch(TArgs ...)
        {
            auto opDispatch(Args ...)(auto ref Args args)
            {
                return typeof(this)(buffer, mixin(`dummySlice.` ~ s ~
                        (TArgs.length ? `!TArgs` : ``) ~ `(args)`));
            }
        }
    }

    auto toCLBuffer()
    {
        return CLBuffer!T(buffer);
    }

    auto opIndex(Args ...)(Args args)
    {
        return typeof(this)(buffer, dummySlice.opIndex(args));
    }

    auto opSlice(uint dim, Args ...)(Args args)
    {
        return dummySlice.opSlice!dim(args);
    }

    auto opDollar(uint dim)()
    {
        return dummySlice.opDollar!dim;
    }
}

auto clWrite(T, size_t N)(CLBufferSlice!(T, N) buffer, Slice!(N, T*) slice, Flag!"Blocking" blocking = Yes.Blocking)
in
{
    assert(buffer.shape == slice.shape);
    assert(slice.structure.strides[$-1] == 1);
    assert(buffer.strides[$-1] == 1);
}
body
{
    size_t[3] bufferOffsets = 0;
    size_t[3] hostOffsets = 0; //always all zeros
    size_t[3] shape = 1;
    size_t[2] sliceStrides = 0;
    size_t[2] bufferStrides = 0;

    bufferOffsets[0] = buffer.offsets[N-1] * T.sizeof;
    shape[0] = buffer.shape[N-1] * T.sizeof;
    static if(N > 1)
    {
        bufferOffsets[1] = buffer.offsets[N-2];
        shape[1] = buffer.shape[N-2];
        sliceStrides[0] = slice.structure.strides[N-2] * T.sizeof;
        bufferStrides[0] = buffer.strides[N-2] * T.sizeof;
    }
    static if(N > 2)
    {
        bufferOffsets[2] = buffer.offsets[N-3];
        shape[2] = buffer.shape[N-3];
        sliceStrides[1] = slice.structure.strides[N-3] * T.sizeof;
        bufferStrides[1] = buffer.strides[N-3] * T.sizeof;
    }

    cl.enqueueWriteBufferRect(cld.queue,
        buffer,
        blocking,
        bufferOffsets.ptr,
        hostOffsets.ptr,
        shape.ptr,
        bufferStrides[0],
        bufferStrides[1],
        sliceStrides[0],
        sliceStrides[1],
        slice.ptr,
        0, null, null);

    return buffer;
}

auto clWrite(T)(CLBufferSlice!(T, 1) buffer, T[] data, Flag!"Blocking" blocking = Yes.Blocking)
in
{
    assert(buffer.shape[0] == data.length);
}
body
{
    cld.queue.write(buffer, data, blocking, buffer.offset[0]);
    return buffer;
}

auto clRead(T, size_t N)(CLBufferSlice!(T, N) buffer, Slice!(N, T*) slice, Flag!"Blocking" blocking = Yes.Blocking)
in
{
    assert(buffer.shape == slice.shape);
    assert(slice.structure.strides[$-1] == 1);
    assert(buffer.strides[$-1] == 1);
}
body
{
    size_t[3] bufferOffsets = 0;
    size_t[3] hostOffsets = 0; //always all zeros
    size_t[3] shape = 1;
    size_t[2] sliceStrides = 0;
    size_t[2] bufferStrides = 0;

    bufferOffsets[0] = buffer.offsets[N-1] * T.sizeof;
    shape[0] = buffer.shape[N-1] * T.sizeof;
    static if(N > 1)
    {
        bufferOffsets[1] = buffer.offsets[N-2];
        shape[1] = buffer.shape[N-2];
        sliceStrides[0] = slice.structure.strides[N-2] * T.sizeof;
        bufferStrides[0] = buffer.strides[N-2] * T.sizeof;
    }
    static if(N > 2)
    {
        bufferOffsets[2] = buffer.offsets[N-3];
        shape[2] = buffer.shape[N-3];
        sliceStrides[1] = slice.structure.strides[N-3] * T.sizeof;
        bufferStrides[1] = buffer.strides[N-3] * T.sizeof;
    }

    cl.enqueueReadBufferRect(cld.queue,
        buffer,
        blocking,
        bufferOffsets.ptr,
        hostOffsets.ptr,
        shape.ptr,
        bufferStrides[0],
        bufferStrides[1],
        sliceStrides[0],
        sliceStrides[1],
        slice.ptr,
        0, null, null);
    return slice;
}

auto clRead(T)(CLBufferSlice!(T, 1) buffer, T[] data, Flag!"Blocking" blocking = Yes.Blocking)
in
{
    assert(buffer.shape[0] == data.length);
}
body
{
    cld.queue.read(buffer, data, blocking, buffer.offset[0]);
    return buffer;
}

auto clBuildKernel(KernelDefT)(KernelDefT kernelDef)
{
    pragma(msg, KernelDefT.name);
    return cld.context.createProgram(kernelDef)
    .buildProgram
    .createKernel!(KernelDefT.name);
}

