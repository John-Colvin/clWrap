import std.typecons : Flag, Yes, No, Nullable;
import clwrap;
import std.traits : hasMember, isInstanceOf;

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


// DIMENSIONS ARE PART OF THE BUFFER TYPE!!!!!!!!!!!!!!!
// OR MAYBE A BUFFER SLICE OBJECT??

import mir.ndslice;

/+
auto clMap(alias kernel, Flag!"Blocking" = Yes.Blocking, SliceT, size_t buffIdx = 0, Args ...)
    (SliceT s, Args args)
if (is(typeof(kernel) : CLKernel!X, X...) && isSlice!(SliceT) && hasMember!(SliceT, "ptr"))
in
{
    assert(s.structure.strides[].all!"a > 0",
        "clMap does not support slices with negative strides");
}
body
{
    auto structure = s.structure;
    auto shape = s.shape;
    auto strides = s.strides;
    auto p = zip(shape[], strides[]).maxPos!"a[1] < b[1]"[0];
    auto length = p[0] * p[1];

    auto flatData = s.ptr[0 .. length];

    kernel.setArgs(args[0 .. buffIdx],
            cld.context.newBuffer(cl.MEM_COPY_HOST_PTR, flatData),
            args[buffIdx .. $]);

    static struct Res
    {
        cl.kernel id;
        Nullable!(size_t[kernel.nParallelDims]) localSizes;

        Res setLocalSizes(typeof(localSizes) newSizes)
        {
            localSizes = newSizes;
        }
        auto enqueue()
        {
            return cld.queue.enqueueCLKernel(kernel, shape,
                localSizes.isNull ? null, localSizes.get);
        }
    }

    return Res(kernel);
}
+/

// What if there's some offset? All handled in strides in slice
private auto getFlatSlice(SliceT)(SliceT s)
if (isInstanceOf!(Slice, SliceT) && hasMember!(SliceT, "ptr"))
{
    import std.range : zip;
    import std.algorithm : minPos;
    auto structure = s.structure;
    auto shape = s.shape;
    auto strides = structure.strides;
    auto p = zip(shape[], strides[]).minPos!"a[1] > b[1]".front;
    auto length = p[0] * p[1];
    import std.stdio;
    writeln(length);

    return s.ptr[0 .. length];
}

/*auto clMap(alias kernel, BufferT, Flag!"Blocking" blocking = Yes.Blocking, size_t buffIdx = 0, Args ...)
    (BufferT buffer, Args args)
if (is(typeof(kernel) : CLKernel!X, X...) && is(BufferT : CLBuffer!X, X))
{
    kernel.setArgs(args[0 .. buffIdx], buffer, args[buffIdx .. $]);

    static struct Res
    {
        cl.kernel id;
        Nullable!(size_t[kernel.nParallelDims]) localSizes;

        Res setLocalSizes(typeof(localSizes) newSizes)
        {
            localSizes = newSizes;
            return this;
        }
        auto enqueue()
        {
            return cld.queue.enqueueCLKernel(kernel, buffer.shape, null,
                localSizes.isNull ? null : localSizes.get);
        }
    }

    return Res(kernel);
}*/

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
    return CLBufferSlice!(ElemT, ND)(
        cld.context.newBuffer(flags, slice.getFlatSlice),
        slice.shape,
        size_t[ND].init,
        cast(size_t[ND])slice.structure.strides
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
    size_t[nDims] shape; //comes *after* offsets, is shape of live data
    size_t[nDims] offsets;
    size_t[nDims] strides;

    auto toCLBuffer()
    {
        return CLBuffer!T(buffer);
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
    size_t[3] bufferOffsets;
    bufferOffsets[0 .. N] = buffer.offsets;
    size_t[3] hostOffsets;
    size_t[3] shape;
    shape[0 .. N] = buffer.shape.ptr;
    auto sliceStrides = slice.structure.strides;
    cl.enqueueWriteBufferRect(cld.queue,
        buffer,
        blocking,
        bufferOffsets.ptr,
        hostOffsets.ptr,
        shape.ptr,
        buffer.strides[1],
        buffer.strides[0],
        sliceStrides[1],
        sliceStrides[0],
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
    auto sliceStrides = slice.structure.strides;
    cl.enqueueReadBufferRect(cld.queue,
        buffer,
        blocking,
        buffer.offsets.ptr, //needs length 3
        size_t[N].init.ptr, //needs length 3
        buffer.shape.ptr, //needs length 3
        buffer.strides[1],
        buffer.strides[0],
        sliceStrides[1],
        sliceStrides[0],
        slice.ptr,
        0, null, null);
    return buffer;
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


