module clWrap.l2.wrap;

public static import cl = clWrap.cl;

public import derelict.opencl.cl : CLVersion;

import derelict.opengl3.gl3;
import std.exception, std.range, std.conv,
       std.algorithm, std.traits, std.string, std.typecons;
debug import std.stdio;
import clWrap.l2.errors, clWrap.l2.info, clWrap.l2.util;

/**
 * enqueue a write command on a given command queue. See enqueueWriteBuffer
 */
void write(T)(cl.command_queue queue, cl.mem buffer, T[] data,
        Flag!"Blocking" blocking = No.Blocking, size_t offset = 0, const cl.event[] waitList = null,
        cl.event* event = null)
{
    cl.enqueueWriteBuffer(queue, buffer, blocking, offset, data.memSize, data.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

/**
 * enqueue a read command on a given command queue. See enqueueReadBuffer
 */
void read(T)(cl.command_queue queue, cl.mem buffer, T[] data,
        Flag!"Blocking" blocking = No.Blocking, size_t offset = 0, const cl.event[] waitList = null,
        cl.event* event = null)
{
    cl.enqueueReadBuffer(queue, buffer, blocking, offset, data.memSize, data.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

/**
 * Mark a parameter to setArgs as a local buffer size
 */
struct LocalBuffer
{
    size_t s;
}

/**
 * Use as a positional argument to setKernelArgs to denote that you
 * don't want to change that argument
 */
struct NoChange{}
@property auto noChange(){ return NoChange(); }

/**
 * Set the arguments for a kernel.
 * Pass the args you want to set, in order. See NoChange and LocalBuffSize
 * for special argument types.
 */
void setArgs(TL ...)(cl.kernel kernel, TL args)
{
    foreach(i, arg; args)
    {
        //debug writeln(i, " ", typeof(arg).stringof, " ", arg);
        static if(is(typeof(arg) : NoChange)) {}
        else static if(is(typeof(arg) : LocalBuffer))
        {
            cl.setKernelArg(kernel, i, arg.s, null)
                .clEnforce();
        }
        else static if(is(typeof(arg) : CLBuffer!X, X))
        {
            cl.setKernelArg(kernel, i, cl.mem.sizeof, &(arg.buffer))
                .clEnforce();
        }
        else
        {
            cl.setKernelArg(kernel, i, typeof(arg).sizeof, &arg)
                .clEnforce();
        }
    }
}

/**
 * Checks that you are passing the right argument types to the
 * kernel before setting them
 */
void setArgs(Kernel, TL ...)(Kernel kernel, TL args)
if (isInstanceOf!(CLKernel, Kernel))
{
    static assert(Kernel.ArgTypes.length >= TL.length,
        "Can't set more arguments than the kernel supports");
    foreach(i, T; TL)
        static assert(is(T == NoChange)
            || is(T == LocalBuffer)
            || is(T == Kernel.ArgTypes[i]),
            T.stringof ~ "  " ~ Kernel.ArgTypes[i].stringof);

    kernel.id.setArgs(args);
}

/**
 * Enqueue a given kernel on to a given command queue. See enqueueNDRangeKernel
 */
void enqueueCLKernel(cl.command_queue queue,
    cl.kernel kernel, const size_t[] globalWorkSize,
    const size_t[] globalWorkOffset = null, const size_t[] localWorkSize = null,
    const cl.event[] waitList = null, cl.event* event = null)
in
{
    if(globalWorkOffset)
        assert(globalWorkSize.length == globalWorkOffset.length);
    if(localWorkSize)
        assert(globalWorkSize.length == localWorkSize.length);
}
body
{
    cl.enqueueNDRangeKernel(queue, kernel, globalWorkSize.length.to!uint,
            globalWorkOffset.ptr, globalWorkSize.ptr, localWorkSize.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

/**
 * Use this instead of raw cl.mem buffers for stricter typing and better
 * introspection opportunities.
 */
struct CLBuffer(T)
{
    cl.mem buffer;
    alias buffer this;
}

/**
 * create a new buffer from given data, see clCreateBuffer
 */
CLBuffer!T newBuffer(T)(cl.context context, cl.mem_flags flags, T[] data)
{
    //debug writeln("new buffer, type: ", AT.stringof,
    //        " data.length: ", data.length, " data.memSize: ", data.memSize);

    auto buffer = cl.createBuffer(context, flags, data.memSize, data.ptr, &status);
    status.clEnforce();

    return CLBuffer!T(buffer);
}

/**
 * create a new buffer of a particular size. See clCreateBuffer
 */
CLBuffer!T newBuffer(T)(cl.context context, cl.mem_flags flags, size_t length)
{
    //debug writeln("new buffer, type: ", T.stringof,
    //        " length: ", length, " memSize: ", length * T.sizeof);

    cl.int_ status;
    auto buffer = cl.createBuffer(context, flags, length * T.sizeof, null, &status);
    status.clEnforce();

    return CLBuffer!T(buffer);
}

/**
 * Use this instead of raw cl.mem imagesfor stricter typing and better
 * introspection opportunities.
 * `AT` should be an array type
 */
struct CLImage(T)
{
    cl.mem image;
    alias image this;
}

/**
 * For a given platform, get version information
 */
CLVersion getVersion(cl.platform_id id)
{
    size_t platformInfoSize;
    cl.getPlatformInfo(id, cl.PLATFORM_VERSION, 0, null, &platformInfoSize)
        .clEnforce();
    auto platformVersionStr = new char[platformInfoSize];
    cl.getPlatformInfo(id, cl.PLATFORM_VERSION, platformInfoSize,
            platformVersionStr.ptr, null);
    import std.format;
    uint major, minor;
    formattedRead(platformVersionStr, "OpenCL %d.%d ", &major, &minor);

    enforce(major == 1, "Only OpenCL 1.x is supported");
    switch(minor)
    {
        case 0:
            return CLVersion.CL10;
        case 1:
            return CLVersion.CL11;
        case 2:
            return CLVersion.CL12;
        default:
           throw new Exception("invalid OpenCL version number: " ~ major.to!string ~ "." ~ minor.to!string);
    }
}

/**
 * Get a list of all platforms available
 */
auto getPlatforms()
{
    cl.uint_ numPlatforms;
    cl.getPlatformIDs(0, null, &numPlatforms).clEnforce();

    auto platformIDs = new cl.platform_id[numPlatforms];

    cl.getPlatformIDs(numPlatforms, platformIDs.ptr,
            null).clEnforce();

    return platformIDs;
}

/**
 * Get a list of all devices on a given platform. Use the optional parameter
 * to filter on device types
 */
auto getDevices(cl.platform_id platformID,
        cl.device_type device_type = cl.DEVICE_TYPE_ALL)
{
    cl.uint_ numDevices;
    cl.getDeviceIDs(
        platformID,
        device_type,
        0,
        null,
        &numDevices).clEnforce();

    auto deviceIDs = new cl.device_id[numDevices];

    cl.getDeviceIDs(
        platformID,
        device_type,
        numDevices,
        deviceIDs.ptr,
        null).clEnforce();

    return deviceIDs;
}

/**
 * Given an array of devices, create a context that spans that array
 */
auto createContext(cl.device_id[] devices ...)
in
{
    assert(devices.length != 0);
    cl.platform_id platform = devices[0].getInfo!(cl.DEVICE_PLATFORM);
    foreach(device; devices[1 .. $])
        assert(device.getInfo!(cl.DEVICE_PLATFORM) == platform);
}
body
{
    cl.platform_id platform = devices[0].getInfo!(cl.DEVICE_PLATFORM);
    cl.context_properties[3] props = contextPropertyList(
        cl.CONTEXT_PLATFORM,
        platform
        );
    scope(exit) status.clEnforce();
    return cl.createContext(cast(cl.context_properties*)(props.ptr),
                cast(cl.uint_)(devices.length), devices.ptr,
                null, null, &status);
}

/**
 * Helper function to create a valid array of context_properties for use
 * in clCreateContext. Not generally needed in user code, used internally
 * in createContext. Useful if you need to create your own context using
 * the l1 api.
 */
cl.context_properties[Args.length + 1] contextPropertyList(Args...)(Args args)
{
    cl.context_properties[Args.length + 1] props;
    foreach(i, arg; args)
        props[i] = *cast(cl.context_properties*)(&arg);
    return props;
}

/**
 * Create a command queue for a given device on a given context
 */
auto createCommandQueue(cl.context context, cl.device_id device, cl.command_queue_properties properties = 0)
{
    scope(exit) status.clEnforce(
            "call: 'cl.createCommandQueue(" ~ text(context) ~ ", " ~ text(device) ~ ", " ~ text(properties) ~ '\'');
    return cl.createCommandQueue(context, device, properties, &status);
}

/// Convenience enum to save some typing
enum OUT_OF_ORDER_EXEC = cl.QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE;

cl.program createProgram(cl.context context, const(char)[] source)
{
    auto ptr = source.ptr;
    auto length = source.length;

    scope(exit) status.clEnforce();
    return cl.createProgramWithSource(context, 1, &ptr, &length, &status);
}

//TODO: support arrays of strings
cl.program createProgram(cl.context context, const(char)[][] sources)
{
    const(char)*[] sourcePtrs = sources.map!"a.ptr".array;
    size_t[] lengths = sources.map!"a.length".array;

    scope(exit) status.clEnforce();
    return cl.createProgramWithSource(context,
            sourcePtrs.length.to!uint, sourcePtrs.ptr, lengths.ptr, &status);
}

auto createProgram(KernelDefs ...)(cl.context context, KernelDefs kernelDefs)
{
    return CLProgram!KernelDefs(.createProgram(context, [kernelDefs].map!"a.source".array));
}

/**
 * Given a program, build it. Reports any build logs in the thrown exception message if building
 * fails
 */
cl.program buildProgramImpl(cl.program program, cl.device_id[] devices = null, const(char)[] options = null)
{
    cl.buildProgram(program,
            devices.length.to!uint, devices.ptr, options.toStringz(), null, null)
        .clEnforce({
                if(devices is null)
                {
                    size_t nDevices = program.getInfo!(cl.PROGRAM_NUM_DEVICES);
                    devices = new cl.device_id[nDevices];
                    cl.getProgramInfo(program, cl.PROGRAM_DEVICES, devices.memSize, devices.ptr, null);
                }
                auto buildLogs = new char[][devices.length];
                foreach(i, dev; devices)
                {
                    size_t len;
                    cl.getProgramBuildInfo(program, dev, cl.PROGRAM_BUILD_LOG, 0, null, &len);
                    buildLogs[i] = new char[len];
                    cl.getProgramBuildInfo(program, dev, cl.PROGRAM_BUILD_LOG, buildLogs[i].memSize, buildLogs[i].ptr, null);
                }
                return buildLogs.join("\n\n");
            }());
    return program;
}

auto buildProgram(Program)(Program program, cl.device_id[] devices = null, const(char)[] options = null)
if (isInstanceOf!(CLProgram, Program))
{
    .buildProgramImpl(program, devices, options);
    return program;
}

/**
 *
 */
// TODO: use getKernelArgInfo to validate name & ArgTypes
struct CLKernelDef(string kernelName, uint nDims, ArgDesc ...)
{
    const(char)[] source;

    enum name = kernelName;

    import std.typecons : Tuple;
    private alias TupleT = Tuple!ArgDesc;
    alias ArgTypes = TupleT.Types;
    alias ArgNames = TupleT.fieldNames;

    enum nParallelDims = nDims;

    this(R)(R r)
    if (is(ElementType!R : dchar))
    {
        import std.utf, std.string, std.meta;
        enum argStr = roundRobin([staticMap!(clCName, ArgTypes)], repeat(" "),
                    [ArgNames]).chunks(2).joiner([", "]).join();
        r = r.stripLeft;
        if (r.startsWith("__kernel"))
            source = r.to!string;
        else
            source = `__kernel void ` ~ name ~ `(` ~ argStr ~ `){` ~
                r.to!string ~ `}`;
    }
}

private template clCName(T)
{
    static if (is(T == CLBuffer!Q, Q))
        enum clCName = Q.stringof ~ `*`;
    else
        enum clCName = T.stringof;
}

alias isKernelDef(T) = isInstanceOf!(CLKernelDef, T);

/**
 * A wrapper for CLKernel that contains more static information
 * about the kernel
 */
struct CLKernel(KernelDef)
if (isInstanceOf!(CLKernelDef, KernelDef))
{
    cl.kernel id;
    alias id this;

    alias ArgTypes = KernelDef.ArgTypes;

    enum nParallelDims = KernelDef.nParallelDims;

    enum name = KernelDef.name;

    this(cl.kernel id)
    {
        this.id = id;
    }
}

struct CLProgram(KernelDefs ...)
if (allSatisfy!(isKernelDef, KernelDefs))
{
    cl.program id;
    alias id this;

    import std.meta : staticMap;

    alias KernelDefTypes = KernelDefs;
    alias KernelTypes = staticMap!(CLKernel, KernelDefs);

    this(cl.program id)
    {
        this.id = id;
    }
}

auto createKernel(string name, Program)(Program program)
if (isInstanceOf!(CLProgram, Program))
{
    enum hasName(T) = T.name == name;
    import std.meta : Filter;
    alias KernelsWithName = Filter!(hasName, Program.KernelTypes);
    static assert(KernelsWithName.length == 1, "Found multiple kernels with name \"" ~ name ~ "\"");
    alias Kernel = KernelsWithName[0];
    //TODO: are template argument strings guaranteed to be 0-terminated?
    scope(exit) status.clEnforce();
    return Kernel(cl.createKernel(program, name.toStringz, &status));
}

auto createAllKernels(Program)(Program program)
if (isInstanceOf!(CLProgram, Program))
{
    cl_uint numKernels;
    clCreateKernelsInProgram(program, 0, null, &numKernels)
        .clEnforce();
    auto kernels = Program.KernelTypes[](numKernels);
    clCreateKernelsInProgram(program, kernels.length, kernels.ptr, null)
        .clEnforce();
    return kernels;
}

// ((source(s) + context -> program) + devices -> built program) + names -> kernels
// ((KernelDef(s) + context -> program) + devices -> built program) + name -> kernel

/**
 * Thread-local status flag. Just for convenience to not have to declare a new one in
 * every function that needs one.
 */
cl.int_ status;
