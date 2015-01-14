module clWrap.l2.wrap;

public static import cl = clWrap.cl;

public import derelict.opencl.cl : CLVersion;

import derelict.opengl3.gl3;
import std.exception, std.range, std.conv, std.traits, std.string, std.typecons;
debug import std.stdio;
import clWrap.l2.errors, clWrap.l2.info, clWrap.l2.util;

struct LocalBuffSize
{
    size_t s;
}
auto localBuffSize(size_t s)
{
    return LocalBuffSize(s);
}

struct NoChange{}
@property auto noChange(){ return NoChange(); }

void setKernelArgs(TL ...)(cl.kernel kernel, TL args)
{
    foreach(i, arg; args)
    {
        //debug writeln(i, " ", typeof(arg).stringof, " ", arg);
        static if(is(typeof(arg) : NoChange))
        {
            continue;
        }
        else static if(is(typeof(arg) : LocalBuffSize))
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

void write(T)(cl.command_queue queue, cl.mem buffer, T[] data,
        bool blocking = false, size_t offset = 0, const cl.event[] waitList = null,
        cl.event* event = null)
{
    cl.enqueueWriteBuffer(queue, buffer, blocking, offset, data.memSize, data.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

void enqueueCLKernel(T0, T1 : size_t[], T2 : size_t[])(cl.command_queue queue,
        cl.kernel kernel, const T0 globalWorkSize,
        const T1 globalWorkOffset = null, const T2 localWorkSize = null,
        const cl.event[] waitList = null, cl.event* event = null)
    if(isArray!T0 && is(ElementType!T0 : size_t) &&
       isArray!T1 && is(ElementType!T1 : size_t) &&
       isArray!T2 && is(ElementType!T1 : size_t)) 
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

void read(T)(cl.command_queue queue, cl.mem buffer, T[] data,
        bool blocking = false, size_t offset = 0, const cl.event[] waitList = null,
        cl.event* event = null)
{    
    cl.enqueueReadBuffer(queue, buffer, blocking, offset, data.memSize, data.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

/// This should not be stateful. All of this info can be queried from clGetMemObjectInfo
struct CLBuffer(T)
{
    cl.buffer_region region;
    cl.mem buffer;
    cl.mem parentBuffer;    
    cl.mem_flags subFlags; //doesn't seem to be any way of specifying no flags
    alias buffer this;

    this(AT)(cl.context context, cl.mem_flags flags, AT data)
        if(isArray!AT)
    {
        debug writeln("new buffer, type: ", T.stringof,
                " data.length: ", data.length, " data.memSize: ", data.memSize);

        cl.int_ status;
        buffer = cl.createBuffer(context, flags, data.memSize, data.ptr, &status);
        status.clEnforce();

        parentBuffer = buffer;
        subFlags = flags & ~(cl.MEM_USE_HOST_PTR
                | cl.MEM_ALLOC_HOST_PTR | cl.MEM_COPY_HOST_PTR);

        region = cl.buffer_region(0, data.memSize);
    }

    this()(cl.context context, cl.mem_flags flags, size_t length)
    {
        debug writeln("new buffer, type: ", T.stringof,
                " length: ", length, " memSize: ", length * T.sizeof);

        cl.int_ status;
        buffer = cl.createBuffer(context, flags, length * T.sizeof, null, &status);
        status.clEnforce();

        parentBuffer = buffer;
        subFlags = flags & ~(cl.MEM_USE_HOST_PTR
                | cl.MEM_ALLOC_HOST_PTR | cl.MEM_COPY_HOST_PTR);
        
        region = cl.buffer_region(0, length * T.sizeof);
    }

    auto slice(size_t i0, size_t i1, cl.mem_flags flags = 0)
    in
    {
        assert(i1 > i0);
        assert(i0 * T.sizeof < region.size);
        assert(i1 * T.sizeof <= region.size);
    }
    body
    {
        CLBuffer tmp;
        tmp.region = cl.buffer_region(region.origin + i0 * T.sizeof, (i1 - i0) * T.sizeof);

        auto tmpFlags = flags ? flags : subFlags;
        auto regionPtr = &(tmp.region);
        import std.stdio;
        debug writeln(parentBuffer, " ", region, " ", tmp.region, " ",
                subFlags, " ", flags, " ", tmpFlags, " ",regionPtr);

        cl.int_ status;
        tmp.buffer = cl.createSubBuffer(parentBuffer, tmpFlags,
                cl.BUFFER_CREATE_TYPE_REGION, regionPtr, &status);
        status.clEnforce();

        debug writeln("Created subBuffer");
        tmp.parentBuffer = parentBuffer;
        return tmp;
    }

    //seems to be ignored in favour of alias this in some compilers
    //alias opSlice = slice;
    auto opSlice(size_t i0, size_t i1)
    {
        return slice(i0, i1);
    }

    auto opDollar()
    {
        return length;
    }

    @property size_t length()
    {
        return region.size / T.sizeof;
    }

    invariant()
    {
        assert(region.size % T.sizeof == 0,
                "region size: " ~ region.size.to!string
                ~ " % T.sizeof: " ~ T.sizeof.to!string
                ~ " == " ~ (region.size % T.sizeof).to!string);
    }
}




struct CLPlatform
{
    CLDevice[] devices;
    cl.platform_id id;
    alias id this;

    this(cl.platform_id id)
    {
        this.id = id;
    }

    @property CLVersion version_()
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
}

auto getPlatforms()
{
    cl.uint_ numPlatforms;
    cl.getPlatformIDs(0, null, &numPlatforms).clEnforce();
    
    auto platformIDs = new cl.platform_id[numPlatforms];

    cl.getPlatformIDs(numPlatforms, platformIDs.ptr, 
            null).clEnforce();

    return platformIDs.map!((id) => CLPlatform(id)).array;
}

struct CLDevice
{
    CLDevice[] contexts;
    cl.device_id id;
    alias id this;

    this(cl.device_id id)
    {
        this.id = id;
    }
}

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

    return deviceIDs.map!((id) => CLDevice(id)).array;
}

struct CLContext
{
    CLQueue[] queues;
    cl.context id;
    alias id this;

    this(cl.context id)
    {
        this.id = id;
    }
}

auto createContext(CLDevice[] devices)
{
    return .createContext(devices.map!"a.id".array);
}

auto createContext(cl.device_id[] devices)
in
{
    assert(devices.length != 0);
    cl.platform_id platform = CLDevice(devices[0]).getInfo!(cl.DEVICE_PLATFORM);
    foreach(device; devices[1 .. $])
        assert(CLDevice(device).getInfo!(cl.DEVICE_PLATFORM) == platform);
}
body
{
    cl.platform_id platform = CLDevice(devices[0]).getInfo!(cl.DEVICE_PLATFORM);
    cl.context_properties[3] props = contextPropertyList( 
        cl.CONTEXT_PLATFORM,
        platform
        );
    scope(exit) status.clEnforce();
    return CLContext(
            cl.createContext(cast(cl.context_properties*)(props.ptr),
                cast(cl.uint_)(devices.length), devices.ptr,
                null, null, &status)
            );
}

auto contextPropertyList(Args...)(Args args)
{
    cl.context_properties[Args.length + 1] props;
    foreach(i, arg; args)
        props[i] = *cast(cl.context_properties*)(&arg);
    return props;
}

struct CLQueue
{
    cl.command_queue id;
    alias id this;
    
    this(cl.command_queue id)
    {
        this.id = id;
    }
}

auto createCommandQueue(cl.context context, cl.device_id device, cl.command_queue_properties properties = 0)
{
    scope(exit) status.clEnforce(
            "call: 'cl.createCommandQueue(" ~ text(context) ~ ", " ~ text(device) ~ ", " ~ text(properties) ~ '\'');
    return CLQueue(
            cl.createCommandQueue(context, device, properties, &status)
            );
}

enum OUT_OF_ORDER_EXEC = cl.QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE;

struct CLProgram
{
    cl.program id;
    alias id this;
    
    this(cl.program id)
    {
        this.id = id;
    }
/+
    auto getBuildInfo(cl.program_build_info flag)(cl.device_id device)
    {
        auto buildInfo(Args ...)(Args args)
        {
            return clGetProgramBuildInfo(args[0], device, args[1..$]);
        }
        return .getInfo!(buildInfo, flag, programBuildInfoEnums)(id);
    }
+/
}


cl.program createProgramFromSource(cl.context context, const(char)[] source)
{
    auto ptr = source.ptr;
    auto length = source.length;

    scope(exit) status.clEnforce();
    return cl.createProgramWithSource(context, 1, &ptr, &length, &status);
}

cl.program createProgramFromSource(cl.context context, const(char)[][] sources)
{
    const(char)*[] sourcePtrs = sources.map!"a.ptr".array;
    size_t[] lengths = sources.map!"a.length".array;

    scope(exit) status.clEnforce();
    return cl.createProgramWithSource(context,
            sourcePtrs.length.to!uint, sourcePtrs.ptr, lengths.ptr, &status);
}

cl.program buildProgram(cl.program program, cl.device_id[] devices = null, const(char)[] options = null)
{
    cl.buildProgram(program,
            devices.length.to!uint, devices.ptr, options.toStringz(), null, null)
        .clEnforce({
                if(devices.empty)
                {
                    size_t nDevices = CLProgram(program).getInfo!(cl.PROGRAM_NUM_DEVICES);
                    devices = new cl.device_id[nDevices];
                    cl.getProgramInfo(program, cl.PROGRAM_DEVICES, devices.memSize, devices.ptr, null);
                }
                auto buildLogs = new ubyte[][devices.length];
                foreach(i, dev; devices)
                {
                    size_t len;
                    cl.getProgramBuildInfo(program, dev, cl.PROGRAM_BUILD_LOG, 0, null, &len);
                    buildLogs[i] = new ubyte[len];
                    cl.getProgramBuildInfo(program, dev, cl.PROGRAM_BUILD_LOG, buildLogs[i].memSize, buildLogs[i].ptr, null);
                }
                return (cast(char[][])buildLogs).join("\n\n");
            }());
    return program;
}

struct CLKernel(uint nDims, ArgDesc ...)
{
    cl.kernel id;
    alias id this;
 
    alias ArgTypes = ArgDesc;

    enum nParallelDims = nDims;

    this(cl.kernel id)
    {
        this.id = id;
    }
}


/**
 * Thread-local status flag. Just for convenience to not have to declare a new one in
 * every function that needs one.
 */
cl.int_ status;
