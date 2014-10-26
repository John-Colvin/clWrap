module clWrap.wrap;

public import derelict.opencl.cl;
import derelict.opengl3.gl3;
import std.exception, std.range, std.conv, std.traits, std.string;
debug import std.stdio;
import clWrap.errors, clWrap.info, clWrap.util;

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

void clSetKernelArgs(TL ...)(cl_kernel kernel, TL args)
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
            clSetKernelArg(kernel, i, arg.s, null)
                .clEnforce();
        }
        else static if(is(typeof(arg) : clBuffer!X, X))
        {
            clSetKernelArg(kernel, i, cl_mem.sizeof, &(arg.buffer))
                .clEnforce();
        }
        else
        {
            clSetKernelArg(kernel, i, typeof(arg).sizeof, &arg)
                .clEnforce();
        }
    }
}

void clWrite(T)(cl_command_queue queue, cl_mem buffer, T[] data,
        bool blocking = false, size_t offset = 0, const cl_event[] waitList = null,
        cl_event* event = null)
{
    clEnqueueWriteBuffer(queue, buffer, blocking, offset, data.memSize, data.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

void clEnqueueCLKernel(T0, T1 : size_t[], T2 : size_t[])(cl_command_queue queue,
        cl_kernel kernel, const T0 globalWorkSize,
        const T1 globalWorkOffset = null, const T2 localWorkSize = null,
        const cl_event[] waitList = null, cl_event* event = null)
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
    clEnqueueNDRangeKernel(queue, kernel, globalWorkSize.length.to!uint,
            globalWorkOffset.ptr, globalWorkSize.ptr, localWorkSize.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

void clRead(T)(cl_command_queue queue, cl_mem buffer, T[] data,
        bool blocking = false, size_t offset = 0, const cl_event[] waitList = null,
        cl_event* event = null)
{    
    clEnqueueReadBuffer(queue, buffer, blocking, offset, data.memSize, data.ptr,
            cast(uint)waitList.length, waitList.ptr, event)
        .clEnforce();
}

/// This should not be stateful. All of this info can be queried from clGetMemObjectInfo
struct clBuffer(T)
{
    cl_buffer_region region;
    cl_mem buffer;
    cl_mem parentBuffer;    
    cl_mem_flags subFlags; //doesn't seem to be any way of specifying no flags
    alias buffer this;

    this(AT)(cl_context context, cl_mem_flags flags, AT data)
        if(isArray!AT)
    {
        debug writeln("new buffer, type: ", T.stringof,
                " data.length: ", data.length, " data.memSize: ", data.memSize);

        cl_int status;
        buffer = clCreateBuffer(context, flags, data.memSize, data.ptr, &status);
        status.clEnforce();

        parentBuffer = buffer;
        subFlags = flags & ~(CL_MEM_USE_HOST_PTR
                | CL_MEM_ALLOC_HOST_PTR | CL_MEM_COPY_HOST_PTR);

        region = cl_buffer_region(0, data.memSize);
    }

    this()(cl_context context, cl_mem_flags flags, size_t length)
    {
        debug writeln("new buffer, type: ", T.stringof,
                " length: ", length, " memSize: ", length * T.sizeof);

        cl_int status;
        buffer = clCreateBuffer(context, flags, length * T.sizeof, null, &status);
        status.clEnforce();

        parentBuffer = buffer;
        subFlags = flags & ~(CL_MEM_USE_HOST_PTR
                | CL_MEM_ALLOC_HOST_PTR | CL_MEM_COPY_HOST_PTR);
        
        region = cl_buffer_region(0, length * T.sizeof);
    }

    auto slice(size_t i0, size_t i1, cl_mem_flags flags = 0)
    in
    {
        assert(i1 > i0);
        assert(i0 * T.sizeof < region.size);
        assert(i1 * T.sizeof <= region.size);
    }
    body
    {
        clBuffer tmp;
        tmp.region = cl_buffer_region(region.origin + i0 * T.sizeof, (i1 - i0) * T.sizeof);

        auto tmpFlags = flags ? flags : subFlags;
        auto regionPtr = &(tmp.region);
        import std.stdio;
        debug writeln(parentBuffer, " ", region, " ", tmp.region, " ",
                subFlags, " ", flags, " ", tmpFlags, " ",regionPtr);

        cl_int status;
        tmp.buffer = clCreateSubBuffer(parentBuffer, tmpFlags,
                CL_BUFFER_CREATE_TYPE_REGION, regionPtr, &status);
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
    cl_platform_id id;
    alias id this;

    this(cl_platform_id id)
    {
        this.id = id;
    }

    @property CLVersion version_()
    {
        size_t platformInfoSize;
        clGetPlatformInfo(id, CL_PLATFORM_VERSION, 0, null, &platformInfoSize)
            .clEnforce();
        auto platformVersionStr = new char[platformInfoSize];
        clGetPlatformInfo(id, CL_PLATFORM_VERSION, platformInfoSize,
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

    auto getInfo(cl_platform_info flag)()
    {
        return .getInfo!(clGetPlatformInfo, flag, platformInfoEnums)(id);
    }
}

auto getPlatforms()
{
    cl_uint numPlatforms;
    clGetPlatformIDs(0, null, &numPlatforms).clEnforce();
    
    auto platformIDs = new cl_platform_id[numPlatforms];

    clGetPlatformIDs(numPlatforms, platformIDs.ptr, 
            null).clEnforce();

    return platformIDs.map!((id) => CLPlatform(id)).array;
}

struct CLDevice
{
    CLDevice[] contexts;
    cl_device_id id;
    alias id this;

    this(cl_device_id id)
    {
        this.id = id;
    }

    auto getInfo(cl_device_info flag)()
    {
        return .getInfo!(clGetDeviceInfo, flag, deviceInfoEnums)(id);
    }
}

auto getDevices(cl_platform_id platformID,
        cl_device_type device_type = CL_DEVICE_TYPE_ALL)
{
    cl_uint numDevices;
    clGetDeviceIDs(
        platformID, 
        device_type, 
        0, 
        null,
        &numDevices).clEnforce();

    auto deviceIDs = new cl_device_id[numDevices]; 

    clGetDeviceIDs(
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
    cl_context id;
    alias id this;

    this(cl_context id)
    {
        this.id = id;
    }

    auto getInfo(cl_context_info flag)()
    {
        return .getInfo!(clGetContextInfo, flag, contextInfoEnums)(id);
    }
}

auto createContext(CLDevice[] devices)
{
    return .createContext(devices.map!"a.id".array);
}

auto createContext(cl_device_id[] devices)
in
{
    assert(devices.length != 0);
    cl_platform_id platform = CLDevice(devices[0]).getInfo!CL_DEVICE_PLATFORM;
    foreach(device; devices[1 .. $])
        assert(CLDevice(device).getInfo!CL_DEVICE_PLATFORM == platform);
}
body
{
    cl_platform_id platform = CLDevice(devices[0]).getInfo!CL_DEVICE_PLATFORM;
    cl_context_properties[3] props = [
        cast(cl_context_properties)CL_CONTEXT_PLATFORM,
        cast(cl_context_properties)platform,
        cast(cl_context_properties)0];
    
    scope(exit) status.clEnforce();
    return CLContext(
            clCreateContext(props.ptr,
                cast(cl_uint)(devices.length), devices.ptr,
                null, null, &status)
            );
}

struct CLQueue
{
    cl_command_queue id;
    alias id this;
    
    this(cl_command_queue id)
    {
        this.id = id;
    }

    auto getInfo(cl_command_queue_info flag)()
    {
        return .getInfo!(clGetCommandQueueInfo, flag, queueInfoEnums)(id);
    }
}

auto createCommandQueue(cl_context context, cl_device_id device, cl_command_queue_properties properties = 0)
{
    scope(exit) status.clEnforce();
    return CLQueue(
            clCreateCommandQueue(context, device, properties, &status)
            );
}

enum OUT_OF_ORDER_EXEC = CL_QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE;

struct CLProgram
{
    cl_program id;
    alias id this;
    
    this(cl_program id)
    {
        this.id = id;
    }

    auto getInfo(cl_program_info flag)()
    {
        return .getInfo!(clGetProgramInfo, flag, programInfoEnums)(id);
    }
/+
    auto getBuildInfo(cl_program_build_info flag)(cl_device_id device)
    {
        auto buildInfo(Args ...)(Args args)
        {
            return clGetProgramBuildInfo(args[0], device, args[1..$]);
        }
        return .getInfo!(buildInfo, flag, programBuildInfoEnums)(id);
    }
+/
}


cl_program createProgramFromSource(cl_context context, const(char)[] source)
{
    auto ptr = source.ptr;
    auto length = source.length;

    scope(exit) status.clEnforce();
    return clCreateProgramWithSource(context, 1, &ptr, &length, &status);
}

cl_program createProgramFromSource(cl_context context, const(char)[][] sources)
{
    const(char)*[] sourcePtrs = sources.map!"a.ptr".array;
    size_t[] lengths = sources.map!"a.length".array;

    scope(exit) status.clEnforce();
    return clCreateProgramWithSource(context,
            sourcePtrs.length.to!uint, sourcePtrs.ptr, lengths.ptr, &status);
}

cl_program buildProgram(cl_program program, cl_device_id[] devices = null, const(char)[] options = null)
{
    clBuildProgram(program,
            devices.length.to!uint, devices.ptr, options.toStringz(), null, null)
        .clEnforce({
                if(devices.empty)
                {
                    size_t nDevices = CLProgram(program).getInfo!CL_PROGRAM_NUM_DEVICES;
                    devices = new cl_device_id[nDevices];
                    clGetProgramInfo(program, CL_PROGRAM_DEVICES, devices.memSize, devices.ptr, null);
                }
                auto buildLogs = new ubyte[][devices.length];
                foreach(i, dev; devices)
                {
                    size_t len;
                    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, 0, null, &len);
                    buildLogs[i] = new ubyte[len];
                    clGetProgramBuildInfo(program, dev, CL_PROGRAM_BUILD_LOG, buildLogs[i].memSize, buildLogs[i].ptr, null);
                }
                return (cast(char[][])buildLogs).join("\n\n");
            }());
    return program;
}

struct Kernel(uint nDims, ArgTypes_ ...)
{
    cl_kernel id;
    alias id this;
 
    alias ArgTypes = ArgTypes_;

    enum nParallelDims = nDims;

    this(cl_kernel id)
    {
        this.id = id;
    }

    auto getInfo(cl_kernel_info flag)()
    {
        return .getInfo!(clGetKernelInfo, flag, KernelInfoEnums)(id);
    }
}


/**
 * Thread-local status flag. Just for convenience to not have to declare a new one in
 * every function that needs one.
 */
cl_int status;


