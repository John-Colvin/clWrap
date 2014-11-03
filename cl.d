module clWrap.cl;

import derelict.opencl.cl;

import std.typecons : Typedef;

alias char_   = cl_char;
alias uchar  = cl_uchar;
alias short_  = cl_short;
alias ushort_ = cl_ushort;
alias int_    = cl_int;
alias uint_   = cl_uint;
alias long_   = cl_long;
alias ulong_  = cl_ulong;

alias half   = cl_half;
alias float_  = cl_float;
alias double_ = cl_double;

alias GLuint = cl_GLuint;
alias GLint  = cl_GLint;
alias GLenum = cl_GLenum;


struct   platform_id {   cl_platform_id raw; } 
struct     device_id {     cl_device_id raw; } 
struct       context {       cl_context raw; } 
struct command_queue { cl_command_queue raw; } 
struct           mem {           cl_mem raw; } 
struct       program {       cl_program raw; } 
struct        kernel {        cl_kernel raw; } 
struct         event {         cl_event raw; } 
struct       sampler {       cl_sampler raw; } 



alias device_type                  = Typedef!(cl_device_type, cl_device_type.init, "device_type");
alias platform_info                = Typedef!(cl_platform_info, cl_platform_info.init, "platform_info");
alias device_info                  = Typedef!(cl_device_info, cl_device_info.init, "device_info");
alias device_fp_config             = Typedef!(cl_device_fp_config, cl_device_fp_config.init, "device_fp_config");
alias device_mem_cache_type        = Typedef!(cl_device_mem_cache_type, cl_device_mem_cache_type.init, "device_mem_cache_type");
alias device_local_mem_type        = Typedef!(cl_device_local_mem_type, cl_device_local_mem_type.init, "device_local_mem_type");
alias device_exec_capabilities     = Typedef!(cl_device_exec_capabilities, cl_device_exec_capabilities.init, "device_exec_capabilities");
alias command_queue_properties     = Typedef!(cl_command_queue_properties, cl_command_queue_properties.init, "command_queue_properties");
alias device_partition_property    = Typedef!(cl_device_partition_property, cl_device_partition_property.init, "device_partition_property");
alias device_affinity_domain       = Typedef!(cl_device_affinity_domain, cl_device_affinity_domain.init, "device_affinity_domain");

alias context_properties           = Typedef!(cl_context_properties, cl_context_properties.init, "context_properties");
alias context_info                 = Typedef!(cl_context_info, cl_context_info.init, "context_info");
alias command_queue_info           = Typedef!(cl_command_queue_info, cl_command_queue_info.init, "command_queue_info");
alias channel_order                = Typedef!(cl_channel_order, cl_channel_order.init, "channel_order");
alias channel_type                 = Typedef!(cl_channel_type, cl_channel_type.init, "channel_type");
alias mem_flags                    = Typedef!(cl_mem_flags, cl_mem_flags.init, "mem_flags");
alias mem_object_type              = Typedef!(cl_mem_object_type, cl_mem_object_type.init, "mem_object_type");
alias mem_info                     = Typedef!(cl_mem_info, cl_mem_info.init, "mem_info");
alias mem_migration_flags          = Typedef!(cl_mem_migration_flags, cl_mem_migration_flags.init, "mem_migration_flags");
alias image_info                   = Typedef!(cl_image_info, cl_image_info.init, "image_info");
alias buffer_create_type           = Typedef!(cl_buffer_create_type, cl_buffer_create_type.init, "buffer_create_type");
alias addressing_mode              = Typedef!(cl_addressing_mode, cl_addressing_mode.init, "addressing_mode");
alias filter_mode                  = Typedef!(cl_filter_mode, cl_filter_mode.init, "filter_mode");
alias sampler_info                 = Typedef!(cl_sampler_info, cl_sampler_info.init, "sampler_info");
alias map_flags                    = Typedef!(cl_map_flags, cl_map_flags.init, "map_flags");
alias program_info                 = Typedef!(cl_program_info, cl_program_info.init, "program_info");
alias program_build_info           = Typedef!(cl_program_build_info, cl_program_build_info.init, "program_build_info");
alias program_binary_type          = Typedef!(cl_program_binary_type, cl_program_binary_type.init, "program_binary_type");
alias build_status                 = Typedef!(cl_build_status, cl_build_status.init, "build_status");
alias kernel_info                  = Typedef!(cl_kernel_info, cl_kernel_info.init, "kernel_info");
alias kernel_arg_info              = Typedef!(cl_kernel_arg_info, cl_kernel_arg_info.init, "kernel_arg_info");
alias kernel_arg_address_qualifier = Typedef!(cl_kernel_arg_address_qualifier, cl_kernel_arg_address_qualifier.init, "kernel_arg_address_qualifier");
alias kernel_arg_access_qualifier  = Typedef!(cl_kernel_arg_access_qualifier, cl_kernel_arg_access_qualifier.init, "kernel_arg_access_qualifier");
alias kernel_arg_type_qualifier    = Typedef!(cl_kernel_arg_type_qualifier, cl_kernel_arg_type_qualifier.init, "kernel_arg_type_qualifier");
alias kernel_work_group_info       = Typedef!(cl_kernel_work_group_info, cl_kernel_work_group_info.init, "kernel_work_group_info");
alias event_info                   = Typedef!(cl_event_info, cl_event_info.init, "event_info");
alias command_type                 = Typedef!(cl_command_type, cl_command_type.init, "command_type");
alias profiling_info               = Typedef!(cl_profiling_info, cl_profiling_info.init, "profiling_info");

alias image_format  = cl_image_format;
alias image_desc    = cl_image_desc;
alias buffer_region = cl_buffer_region;

alias device_partition_property_ext = Typedef!(cl_device_partition_property_ext, cl_device_partition_property_ext.init, "device_partition_property_ext");

public import derelict.opencl.cl : CLeglImageKHR, CLeglDisplayKHR;
alias egl_image_properties_khr = Typedef!(cl_egl_image_properties_khr, cl_egl_image_properties_khr.init, "egl_image_properties_khr");

alias gl_object_type = Typedef!(cl_gl_object_type, cl_gl_object_type.init, "gl_object_type");
alias gl_texture_info = Typedef!(cl_gl_texture_info, cl_gl_texture_info.init, "gl_texture_info");
alias gl_platform_info = Typedef!(cl_gl_platform_info, cl_gl_platform_info.init, "gl_platform_info");

alias GLsync = cl_GLsync;

alias gl_context_info = Typedef!(cl_gl_context_info, cl_gl_context_info.init, "gl_context_info");

public import derelict.opencl.cl : ID3D10Buffer, ID3D10Texture2D, ID3D10Texture3D;

alias d3d10_device_source_khr = Typedef!(cl_d3d10_device_source_khr, cl_d3d10_device_source_khr.init, "d3d10_device_source_khr");
alias d3d10_device_set_khr = Typedef!(cl_d3d10_device_set_khr, cl_d3d10_device_set_khr.init, "d3d10_device_set_khr");

public import derelict.opencl.cl : ID3D11Buffer, ID3D11Texture2D, ID3D11Texture3D;

alias d3d11_device_source_khr = Typedef!(cl_d3d11_device_source_khr, cl_d3d11_device_source_khr.init, "d3d11_device_source_khr");
alias d3d11_device_set_khr = Typedef!(cl_d3d11_device_set_khr, cl_d3d11_device_set_khr.init, "d3d11_device_set_khr");

alias dx9_media_adapter_type_khr = Typedef!(cl_dx9_media_adapter_type_khr, cl_dx9_media_adapter_type_khr.init, "dx9_media_adapter_type_khr");
alias dx9_media_adapter_set_khr = Typedef!(cl_dx9_media_adapter_set_khr, cl_dx9_media_adapter_set_khr.init, "dx9_media_adapter_set_khr");

version(Windows)
{
    public import derelict.opencl.cl : IDirect3DSurface9, HANDLE;

    alias dx9_surface_info_khr = cl_dx9_surface_info_khr;
}



int_ getPlatformIDs(uint_ a, platform_id* b, uint_* c) 
{
    assert(clGetPlatformIDs);
    return clGetPlatformIDs(a, b, c);
}
    
int_ getPlatformInfo(platform_id a, platform_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetPlatformInfo);
    return clGetPlatformInfo(a, b, c, d, e);
}
    
int_ getDeviceIDs(platform_id a, device_type b, uint_ c, device_id* d, uint_* e) 
{
    assert(clGetDeviceIDs);
    return clGetDeviceIDs(a, b, c, d, e);
}
    
int_ getDeviceInfo(device_id a, device_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetDeviceInfo);
    return clGetDeviceInfo(a, b, c, d, e);
}
    
context createContext(const(context_properties*) a, uint_ b, const(device_id*) c, void* function(const(char*), const(void*), size_t, void*) d, void* e, int_* f) 
{
    assert(clCreateContext);
    return clCreateContext(a, b, c, d, e, f);
}
    
context createContextFromType(const(context_properties*) a, device_type b, void* function(const(char*), const(void*), size_t, void*) c, void* d, int_* e) 
{
    assert(clCreateContextFromType);
    return clCreateContextFromType(a, b, c, d, e);
}
    
int_ retainContext(context a) 
{
    assert(clRetainContext);
    return clRetainContext(a);
}
    
int_ releaseContext(context a) 
{
    assert(clReleaseContext);
    return clReleaseContext(a);
}
    
int_ getContextInfo(context a, context_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetContextInfo);
    return clGetContextInfo(a, b, c, d, e);
}
    
command_queue createCommandQueue(context a, device_id b, command_queue_properties c, int_* d) 
{
    assert(clCreateCommandQueue);
    return clCreateCommandQueue(a, b, c, d);
}
    
int_ retainCommandQueue(command_queue a) 
{
    assert(clRetainCommandQueue);
    return clRetainCommandQueue(a);
}
    
int_ releaseCommandQueue(command_queue a) 
{
    assert(clReleaseCommandQueue);
    return clReleaseCommandQueue(a);
}
    
int_ getCommandQueueInfo(command_queue a, command_queue_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetCommandQueueInfo);
    return clGetCommandQueueInfo(a, b, c, d, e);
}
    
mem createBuffer(context a, mem_flags b, size_t c, void* d, int_* e) 
{
    assert(clCreateBuffer);
    return clCreateBuffer(a, b, c, d, e);
}
    
int_ retainMemObject(mem a) 
{
    assert(clRetainMemObject);
    return clRetainMemObject(a);
}
    
int_ releaseMemObject(mem a) 
{
    assert(clReleaseMemObject);
    return clReleaseMemObject(a);
}
    
int_ getSupportedImageFormats(context a, mem_flags b, mem_object_type c, uint_ d, image_format* e, uint_* f) 
{
    assert(clGetSupportedImageFormats);
    return clGetSupportedImageFormats(a, b, c, d, e, f);
}
    
int_ getMemObjectInfo(mem a, mem_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetMemObjectInfo);
    return clGetMemObjectInfo(a, b, c, d, e);
}
    
int_ getImageInfo(mem a, image_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetImageInfo);
    return clGetImageInfo(a, b, c, d, e);
}
    
sampler createSampler(context a, bool b, addressing_mode c, filter_mode d, int_* e) 
{
    assert(clCreateSampler);
    return clCreateSampler(a, b, c, d, e);
}
    
int_ retainSampler(sampler a) 
{
    assert(clRetainSampler);
    return clRetainSampler(a);
}
    
int_ releaseSampler(sampler a) 
{
    assert(clReleaseSampler);
    return clReleaseSampler(a);
}
    
int_ getSamplerInfo(sampler a, sampler_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetSamplerInfo);
    return clGetSamplerInfo(a, b, c, d, e);
}
    
program createProgramWithSource(context a, uint_ b, const(char*)* c, const(size_t*) d, int_* e) 
{
    assert(clCreateProgramWithSource);
    return clCreateProgramWithSource(a, b, c, d, e);
}
    
program createProgramWithBinary(context a, uint_ b, const(device_id*) c, const(size_t*) d, const(ubyte*)* e, int_* f, int_* g) 
{
    assert(clCreateProgramWithBinary);
    return clCreateProgramWithBinary(a, b, c, d, e, f, g);
}
    
program createProgramWithBuiltInKernels(context a, uint_ b, const(device_id*) c, const(char*) d, int_* e) 
{
    assert(clCreateProgramWithBuiltInKernels);
    return clCreateProgramWithBuiltInKernels(a, b, c, d, e);
}
    
int_ retainProgram(program a) 
{
    assert(clRetainProgram);
    return clRetainProgram(a);
}
    
int_ releaseProgram(program a) 
{
    assert(clReleaseProgram);
    return clReleaseProgram(a);
}
    
int_ buildProgram(program a, uint_ b, const(device_id) c, const(char*) d, void* function(program, void*) e, void* f) 
{
    assert(clBuildProgram);
    return clBuildProgram(a, b, c, d, e, f);
}
    
int_ getProgramInfo(program a, program_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetProgramInfo);
    return clGetProgramInfo(a, b, c, d, e);
}
    
int_ getProgramBuildInfo(program a, device_id b, program_build_info c, size_t d, void* e, size_t* f) 
{
    assert(clGetProgramBuildInfo);
    return clGetProgramBuildInfo(a, b, c, d, e, f);
}
    
kernel createKernel(program a, const(char*) b, int_* c) 
{
    assert(clCreateKernel);
    return clCreateKernel(a, b, c);
}
    
int_ createKernelsInProgram(program a, uint_ b, kernel* c, uint_* d) 
{
    assert(clCreateKernelsInProgram);
    return clCreateKernelsInProgram(a, b, c, d);
}
    
int_ retainKernel(kernel a) 
{
    assert(clRetainKernel);
    return clRetainKernel(a);
}
    
int_ releaseKernel(kernel a) 
{
    assert(clReleaseKernel);
    return clReleaseKernel(a);
}
    
int_ setKernelArg(kernel a, uint_ b, size_t c, const(void*) d) 
{
    assert(clSetKernelArg);
    return clSetKernelArg(a, b, c, d);
}
    
int_ getKernelInfo(kernel a, kernel_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetKernelInfo);
    return clGetKernelInfo(a, b, c, d, e);
}
    
int_ getKernelArgInfo(kernel a, uint_ b, kernel_arg_info c, size_t d, void* e, size_t* f) 
{
    assert(clGetKernelArgInfo);
    return clGetKernelArgInfo(a, b, c, d, e, f);
}
    
int_ getKernelWorkGroupInfo(kernel a, device_id b, kernel_work_group_info c, size_t d, void* e, size_t* f) 
{
    assert(clGetKernelWorkGroupInfo);
    return clGetKernelWorkGroupInfo(a, b, c, d, e, f);
}
    
int_ waitForEvents(uint_ a, const(event*) b) 
{
    assert(clWaitForEvents);
    return clWaitForEvents(a, b);
}
    
int_ getEventInfo(event a, event_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetEventInfo);
    return clGetEventInfo(a, b, c, d, e);
}
    
int_ retainEvent(event a) 
{
    assert(clRetainEvent);
    return clRetainEvent(a);
}
    
int_ releaseEvent(event a) 
{
    assert(clReleaseEvent);
    return clReleaseEvent(a);
}
    
int_ getEventProfilingInfo(event a, profiling_info b, size_t c, void* d, size_t* e) 
{
    assert(clGetEventProfilingInfo);
    return clGetEventProfilingInfo(a, b, c, d, e);
}
    
int_ flush(command_queue a) 
{
    assert(clFlush);
    return clFlush(a);
}
    
int_ finish(command_queue a) 
{
    assert(clFinish);
    return clFinish(a);
}
    
int_ enqueueReadBuffer(command_queue a, mem b, bool c, size_t d, size_t e, void* f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueReadBuffer);
    return clEnqueueReadBuffer(a, b, c, d, e, f, g, h, i);
}
    
int_ enqueueWriteBuffer(command_queue a, mem b, bool c, size_t d, size_t e, const(void*) f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueWriteBuffer);
    return clEnqueueWriteBuffer(a, b, c, d, e, f, g, h, i);
}
    
int_ enqueueCopyBuffer(command_queue a, mem b, mem c, size_t d, size_t e, size_t f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueCopyBuffer);
    return clEnqueueCopyBuffer(a, b, c, d, e, f, g, h, i);
}
    
int_ enqueueReadImage(command_queue a, mem b, bool c, const(size_t*) d, const(size_t*) e, size_t f, size_t g, void* h, uint_ i, const(event*) j, event* k) 
{
    assert(clEnqueueReadImage);
    return clEnqueueReadImage(a, b, c, d, e, f, g, h, i, j, k);
}
    
int_ enqueueWriteImage(command_queue a, mem b, bool c, const(size_t*) d, const(size_t*) e, size_t f, size_t g, const(void*) h, uint_ i, const(event*) j, event* k) 
{
    assert(clEnqueueWriteImage);
    return clEnqueueWriteImage(a, b, c, d, e, f, g, h, i, j, k);
}
    
int_ enqueueCopyImage(command_queue a, mem b, mem c, const(size_t*) d, const(size_t*) e, const(size_t*) f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueCopyImage);
    return clEnqueueCopyImage(a, b, c, d, e, f, g, h, i);
}
    
int_ enqueueCopyImageToBuffer(command_queue a, mem b, mem c, const(size_t*) d, const(size_t*) e, size_t f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueCopyImageToBuffer);
    return clEnqueueCopyImageToBuffer(a, b, c, d, e, f, g, h, i);
}
    
int_ enqueueCopyBufferToImage(command_queue a, mem b, mem c, size_t d, const(size_t*) e, const(size_t*) f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueCopyBufferToImage);
    return clEnqueueCopyBufferToImage(a, b, c, d, e, f, g, h, i);
}
    
void* enqueueMapBuffer(command_queue a, mem b, bool c, map_flags d, size_t e, size_t f, uint_ g, const(event*) h, event* i, int_* j) 
{
    assert(clEnqueueMapBuffer);
    return clEnqueueMapBuffer(a, b, c, d, e, f, g, h, i, j);
}
    
void* enqueueMapImage(command_queue a, mem b, bool c, map_flags d, const(size_t*) e, const(size_t*) f, size_t* g, size_t* h, uint_ i, const(event*) j, event* k, int_* l) 
{
    assert(clEnqueueMapImage);
    return clEnqueueMapImage(a, b, c, d, e, f, g, h, i, j, k, l);
}
    
int_ enqueueUnmapMemObject(command_queue a, mem b, void* c, uint_ d, const(event*) e, event* f) 
{
    assert(clEnqueueUnmapMemObject);
    return clEnqueueUnmapMemObject(a, b, c, d, e, f);
}
    
int_ enqueueNDRangeKernel(command_queue a, kernel b, uint_ c, const(size_t*) d, const(size_t*) e, const(size_t*) f, uint_ h, const(event*) i, event* j) 
{
    assert(clEnqueueNDRangeKernel);
    return clEnqueueNDRangeKernel(a, b, c, d, e, f, g, h, i, j);
}
    
int_ enqueueTask(command_queue a, kernel b, uint_ c, const(event*) d, event* e) 
{
    assert(clEnqueueTask);
    return clEnqueueTask(a, b, c, d, e);
}
    
int_ enqueueNativeKernel(command_queue a, void* function(void*) b, void* c, size_t d, uint_ e, const(mem*) f, const(void*)* g, uint_ h, const(event*) i, event* j) 
{
    assert(clEnqueueNativeKernel);
    return clEnqueueNativeKernel(a, b, c, d, e, f, g, h, i, j);
}
    
int_ setCommandQueueProperty(command_queue a, command_queue_properties b, bool c, command_queue_properties* d) 
{
    assert(clSetCommandQueueProperty);
    return clSetCommandQueueProperty(a, b, c, d);
}
    
mem createSubBuffer(mem a, mem_flags b, buffer_create_type c, const(void*) d, int_* e)
{
    assert(clCreateSubBuffer);
    return clCreateSubBuffer(a, b, c, d, e);
}
    
int_ setMemObjectDestructorCallback(mem a, void* function(mem, void*) b, void* c) 
{
    assert(clSetMemObjectDestructorCallback);
    return clSetMemObjectDestructorCallback(a, b, c);
}
    
event createUserEvent(context a, int_* b) 
{
    assert(clCreateUserEvent);
    return clCreateUserEvent(a, b);
}
    
int_ setUserEventStatus(event a, int_ b) 
{
    assert(clSetUserEventStatus);
    return clSetUserEventStatus(a, b);
}
    
int_ setEventCallback( event a, int_ b, void* function(event, int_, void*) c, void* d) 
{
    assert(clSetEventCallback);
    return clSetEventCallback(a, b, c, d);
}
    
int_ enqueueReadBufferRect(command_queue a, mem b, bool c, const(size_t*) d, const(size_t*) e, const(size_t*) f, size_t g, size_t h, size_t i, size_t j, void* k, uint_ l, const(event*) m, event* n) 
{
    assert(clEnqueueReadBufferRect);
    return clEnqueueReadBufferRect(a, b, c, d, e, f, g, h, i, j, k, l, m, n);
}
    
int_ enqueueWriteBufferRect(command_queue a, mem b, bool c, const(size_t*) d, const(size_t*) e, const(size_t*) f, size_t g, size_t h, size_t i, size_t j, const(void*) k, uint_ l, const(event* r) m, event* n) 
{
    assert(clEnqueueWriteBufferRect);
    return clEnqueueWriteBufferRect(a, b, c, d, e, f, g, h, i, j, k, l, m, n);
}
    
int_ enqueueCopyBufferRect(command_queue a, mem b, mem c, const(size_t*) d, const(size_t*) e, const(size_t*) f, size_t g, size_t h, size_t i, size_t j, uint_ k, const(event*) l, event* m) 
{
    assert(clEnqueueCopyBufferRect);
    return clEnqueueCopyBufferRect(a, b, c, d, e, f, g, h, i, j, k, l, m);
}
    
mem createImage2D(context a, mem_flags b, const(image_format*) c, size_t d, size_t e, size_t f, void* g, int_* h) 
{
    assert(clCreateImage2D);
    return clCreateImage2D(a, b, c, d, e, f, g, h);
}
    
mem createImage3D(context a, mem_flags b, const(image_format*) c, size_t d, size_t e, size_t f, size_t g, size_t h, void* i, int_* j) 
{
    assert(clCreateImage3D);
    return clCreateImage3D(a, b, c, d, e, f, g, h, i, j);
}
    
int_ enqueueMarker(command_queue a, event* b) 
{
    assert(clEnqueueMarker);
    return clEnqueueMarker(a, b);
}
    
int_ enqueueWaitForEvents(command_queue a, uint_ b, const(event*) c) 
{
    assert(clEnqueueWaitForEvents);
    return clEnqueueWaitForEvents(a, b, c);
}
    
int_ enqueueBarrier(command_queue a) 
{
    assert(clEnqueueBarrier);
    return clEnqueueBarrier(a);
}
    
int_ unloadCompiler() 
{
    assert(clUnloadCompiler);
    return clUnloadCompiler();
}
    
void* getExtensionFunctionAddress(const(char*) a)
{
    assert(clGetExtensionFunctionAddress);
    clGetExtensionFunctionAddress(a);
}
    
int_ createSubDevices(device_id a, const(device_partition_property) b, uint_ c, device_id* d, uint_* e) 
{
    assert(clCreateSubDevices);
    return clCreateSubDevices(a, b, c, d, e);
}
    
int_ retainDevice(device_id a) 
{
    assert(clRetainDevice);
    return clRetainDevice(a);
}
    
int_ releaseDevice(device_id a) 
{
    assert(clReleaseDevice);
    return clReleaseDevice(a);
}
    
mem createImage(context a, mem_flags b, const(image_format*) c, const(image_desc*) d, void* e, int_* f) 
{
    assert(clCreateImage);
    return clCreateImage(a, b, c, d, e, f);
}
    
int_ compileProgram(program a, uint_ b, const(device_id*) c, const(char*) d, uint_ e, const(program*) f, const(char*)* g, void* function(program, void*) h, void* i) 
{
    assert(clCompileProgram);
    return clCompileProgram(a, b, c, d, e, f, g, h, i);
}
    
program linkProgram(context a, uint_ b, const(device_id*) c, const(char*) d, uint_ e, const(program*) f, void* function(program, void*) g, void* h, int_* i) 
{
    assert(clLinkProgram);
    return clLinkProgram(a, b, c, d, e, f, g, h, i);
}
    
int_ unloadPlatformCompiler(platform_id a) 
{
    assert(clUnloadPlatformCompiler);
    return clUnloadPlatformCompiler(a);
}
    
int_ enqueueFillBuffer(command_queue a, mem b, const(void*) c, size_t d, size_t e, size_t f, uint_ g, const(event*) h, event* i) 
{
    assert(clEnqueueFillBuffer);
    return clEnqueueFillBuffer(a, b, c, d, e, f, g, h, i);
}
    
int_ enqueueFillImage(command_queue a, mem b, const(void*) c, const(size_t*) d, const(size_t*) e, uint_ f, const(event*) g, event* h) 
{
    assert(clEnqueueFillImage);
    return clEnqueueFillImage(a, b, c, d, e, f, g, h);
}
    
int_ enqueueMigrateMemObjects(command_queue a, uint_ b, const(mem*) c, mem_migration_flags d, uint_ e, const(event*) f, event* g) 
{
    assert(clEnqueueMigrateMemObjects);
    return clEnqueueMigrateMemObjects(a, b, c, d, e, f, g);
}
    
int_ enqueueMarkerWithWaitList(command_queue a, uint_ b, const(event*) c, event* d) 
{
    assert(clEnqueueMarkerWithWaitList);
    return clEnqueueMarkerWithWaitList(a, b, c, d);
}
    
int_ enqueueBarrierWithWaitList(command_queue a, uint_ b, const(event*) c, event* d) 
{
    assert(clEnqueueBarrierWithWaitList);
    return clEnqueueBarrierWithWaitList(a, b, c, d);
}
    
void* getExtensionFunctionAddressForPlatform(platform_id a, const(char*) b) 
{
    assert(clGetExtensionFunctionAddressForPlatform);
    clGetExtensionFunctionAddressForPlatform(a, b);
}


enum : int_
{
    SUCCESS                                  = 0,
    DEVICE_NOT_FOUND                         = -1,
    DEVICE_NOT_AVAILABLE                     = -2,
    COMPILER_NOT_AVAILABLE                   = -3,
    MEM_OBJECT_ALLOCATION_FAILURE            = -4,
    OUT_OF_RESOURCES                         = -5,
    OUT_OF_HOST_MEMORY                       = -6,
    PROFILING_INFO_NOT_AVAILABLE             = -7,
    MEM_COPY_OVERLAP                         = -8,
    IMAGE_FORMAT_MISMATCH                    = -9,
    IMAGE_FORMAT_NOT_SUPPORTED               = -10,
    BUILD_PROGRAM_FAILURE                    = -11,
    MAP_FAILURE                              = -12,
    MISALIGNED_SUB_BUFFER_OFFSET             = -13,
    EXEC_STATUS_ERROR_FOR_EVENTS_IN_WAIT_LIST= -14,
    COMPILE_PROGRAM_FAILURE                  = -15,
    LINKER_NOT_AVAILABLE                     = -16,
    LINK_PROGRAM_FAILURE                     = -17,
    DEVICE_PARTITION_FAILED                  = -18,
    KERNEL_ARG_INFO_NOT_AVAILABLE            = -19,

    INVALID_VALUE                            = -30,
    INVALID_DEVICE_TYPE                      = -31,
    INVALID_PLATFORM                         = -32,
    INVALID_DEVICE                           = -33,
    INVALID_CONTEXT                          = -34,
    INVALID_QUEUE_PROPERTIES                 = -35,
    INVALID_COMMAND_QUEUE                    = -36,
    INVALID_HOST_PTR                         = -37,
    INVALID_MEM_OBJECT                       = -38,
    INVALID_IMAGE_FORMAT_DESCRIPTOR          = -39,
    INVALID_IMAGE_SIZE                       = -40,
    INVALID_SAMPLER                          = -41,
    INVALID_BINARY                           = -42,
    INVALID_BUILD_OPTIONS                    = -43,
    INVALID_PROGRAM                          = -44,
    INVALID_PROGRAM_EXECUTABLE               = -45,
    INVALID_KERNEL_NAME                      = -46,
    INVALID_KERNEL_DEFINITION                = -47,
    INVALID_KERNEL                           = -48,
    INVALID_ARG_INDEX                        = -49,
    INVALID_ARG_VALUE                        = -50,
    INVALID_ARG_SIZE                         = -51,
    INVALID_KERNEL_ARGS                      = -52,
    INVALID_WORK_DIMENSION                   = -53,
    INVALID_WORK_GROUP_SIZE                  = -54,
    INVALID_WORK_ITEM_SIZE                   = -55,
    INVALID_GLOBAL_OFFSET                    = -56,
    INVALID_EVENT_WAIT_LIST                  = -57,
    INVALID_EVENT                            = -58,
    INVALID_OPERATION                        = -59,
    INVALID_GL_OBJECT                        = -60,
    INVALID_BUFFER_SIZE                      = -61,
    INVALID_MIP_LEVEL                        = -62,
    INVALID_GLOBAL_WORK_SIZE                 = -63,
    INVALID_PROPERTY                         = -64,
    INVALID_IMAGE_DESCRIPTOR                 = -65,
    INVALID_COMPILER_OPTIONS                 = -66,
    INVALID_LINKER_OPTIONS                   = -67,
    INVALID_DEVICE_PARTITION_COUNT           = -68,
}

enum : bool_
{
    FALSE                                    = 0,
    TRUE                                     = 1,
    BLOCKING                                 = TRUE,
    NON_BLOCKING                             = FALSE
}

enum : platform_info
{
    PLATFORM_PROFILE                         = 0x0900,
    PLATFORM_VERSION                         = 0x0901,
    PLATFORM_NAME                            = 0x0902,
    PLATFORM_VENDOR                          = 0x0903,
    PLATFORM_EXTENSIONS                      = 0x0904,
}

enum : device_info
{
    DEVICE_TYPE_DEFAULT                      = (1 << 0),
    DEVICE_TYPE_CPU                          = (1 << 1),
    DEVICE_TYPE_GPU                          = (1 << 2),
    DEVICE_TYPE_ACCELERATOR                  = (1 << 3),
    DEVICE_TYPE_CUSTOM                       = (1 << 4),
    DEVICE_TYPE_ALL                          = 0xFFFFFFFF,
}

enum : device_info
{
    DEVICE_TYPE                              = 0x1000,
    DEVICE_VENDOR_ID                         = 0x1001,
    DEVICE_MAX_COMPUTE_UNITS                 = 0x1002,
    DEVICE_MAX_WORK_ITEM_DIMENSIONS          = 0x1003,
    DEVICE_MAX_WORK_GROUP_SIZE               = 0x1004,
    DEVICE_MAX_WORK_ITEM_SIZES               = 0x1005,
    DEVICE_PREFERRED_VECTOR_WIDTH_CHAR       = 0x1006,
    DEVICE_PREFERRED_VECTOR_WIDTH_SHORT      = 0x1007,
    DEVICE_PREFERRED_VECTOR_WIDTH_INT        = 0x1008,
    DEVICE_PREFERRED_VECTOR_WIDTH_LONG       = 0x1009,
    DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT      = 0x100A,
    DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE     = 0x100B,
    DEVICE_MAX_CLOCK_FREQUENCY               = 0x100C,
    DEVICE_ADDRESS_BITS                      = 0x100D,
    DEVICE_MAX_READ_IMAGE_ARGS               = 0x100E,
    DEVICE_MAX_WRITE_IMAGE_ARGS              = 0x100F,
    DEVICE_MAX_MEM_ALLOC_SIZE                = 0x1010,
    DEVICE_IMAGE2D_MAX_WIDTH                 = 0x1011,
    DEVICE_IMAGE2D_MAX_HEIGHT                = 0x1012,
    DEVICE_IMAGE3D_MAX_WIDTH                 = 0x1013,
    DEVICE_IMAGE3D_MAX_HEIGHT                = 0x1014,
    DEVICE_IMAGE3D_MAX_DEPTH                 = 0x1015,
    DEVICE_IMAGE_SUPPORT                     = 0x1016,
    DEVICE_MAX_PARAMETER_SIZE                = 0x1017,
    DEVICE_MAX_SAMPLERS                      = 0x1018,
    DEVICE_MEM_BASE_ADDR_ALIGN               = 0x1019,
    DEVICE_MIN_DATA_TYPE_ALIGN_SIZE          = 0x101A, // Deprecated in OpenCl 1.2
    DEVICE_SINGLE_FP_CONFIG                  = 0x101B,
    DEVICE_GLOBAL_MEM_CACHE_TYPE             = 0x101C,
    DEVICE_GLOBAL_MEM_CACHELINE_SIZE         = 0x101D,
    DEVICE_GLOBAL_MEM_CACHE_SIZE             = 0x101E,
    DEVICE_GLOBAL_MEM_SIZE                   = 0x101F,
    DEVICE_MAX_CONSTANT_BUFFER_SIZE          = 0x1020,
    DEVICE_MAX_CONSTANT_ARGS                 = 0x1021,
    DEVICE_LOCAL_MEM_TYPE                    = 0x1022,
    DEVICE_LOCAL_MEM_SIZE                    = 0x1023,
    DEVICE_ERROR_CORRECTION_SUPPORT          = 0x1024,
    DEVICE_PROFILING_TIMER_RESOLUTION        = 0x1025,
    DEVICE_ENDIAN_LITTLE                     = 0x1026,
    DEVICE_AVAILABLE                         = 0x1027,
    DEVICE_COMPILER_AVAILABLE                = 0x1028,
    DEVICE_EXECUTION_CAPABILITIES            = 0x1029,
    DEVICE_QUEUE_PROPERTIES                  = 0x102A,
    DEVICE_NAME                              = 0x102B,
    DEVICE_VENDOR                            = 0x102C,
    DRIVER_VERSION                           = 0x102D,
    DEVICE_PROFILE                           = 0x102E,
    DEVICE_VERSION                           = 0x102F,
    DEVICE_EXTENSIONS                        = 0x1030,
    DEVICE_PLATFORM                          = 0x1031,
    DEVICE_DOUBLE_FP_CONFIG                  = 0x1032,
    // 0x1033 reserved for CL_DEVICE_HALF_FP_CONFIG
    DEVICE_PREFERRED_VECTOR_WIDTH_HALF       = 0x1034,
    DEVICE_HOST_UNIFIED_MEMORY               = 0x1035,
    DEVICE_NATIVE_VECTOR_WIDTH_CHAR          = 0x1036,
    DEVICE_NATIVE_VECTOR_WIDTH_SHORT         = 0x1037,
    DEVICE_NATIVE_VECTOR_WIDTH_INT           = 0x1038,
    DEVICE_NATIVE_VECTOR_WIDTH_LONG          = 0x1039,
    DEVICE_NATIVE_VECTOR_WIDTH_FLOAT         = 0x103A,
    DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE        = 0x103B,
    DEVICE_NATIVE_VECTOR_WIDTH_HALF          = 0x103C,
    DEVICE_OPENCL_C_VERSION                  = 0x103D,
    DEVICE_LINKER_AVAILABLE                  = 0x103E,
    DEVICE_BUILT_IN_KERNELS                  = 0x103F,
    DEVICE_IMAGE_MAX_BUFFER_SIZE             = 0x1040,
    DEVICE_IMAGE_MAX_ARRAY_SIZE              = 0x1041,
    DEVICE_PARENT_DEVICE                     = 0x1042,
    DEVICE_PARTITION_MAX_SUB_DEVICES         = 0x1043,
    DEVICE_PARTITION_PROPERTIES              = 0x1044,
    DEVICE_PARTITION_AFFINITY_DOMAIN         = 0x1045,
    DEVICE_PARTITION_TYPE                    = 0x1046,
    DEVICE_REFERENCE_COUNT                   = 0x1047,
    DEVICE_PREFERRED_INTEROP_USER_SYNC       = 0x1048,
    DEVICE_PRINTF_BUFFER_SIZE                = 0x1049,
}

enum : device_fp_config
{
    FP_DENORM                                = (1 << 0),
    FP_INF_NAN                               = (1 << 1),
    FP_ROUND_TO_NEAREST                      = (1 << 2),
    FP_ROUND_TO_ZERO                         = (1 << 3),
    FP_ROUND_TO_INF                          = (1 << 4),
    FP_FMA                                   = (1 << 5),
    FP_SOFT_FLOAT                            = (1 << 6),
    FP_CORRECTLY_ROUNDED_DIVIDE_SQRT         = (1 << 7),
}

enum : device_mem_cache_type
{
    NONE                                     = 0x0,
    READ_ONLY_CACHE                          = 0x1,
    READ_WRITE_CACHE                         = 0x2,
}

enum : device_local_mem_type
{
    LOCAL                                    = 0x1,
    GLOBAL                                   = 0x2,
}

enum : device_exec_capabilities
{
    EXEC_KERNEL                              = (1 << 0),
    EXEC_NATIVE_KERNEL                       = (1 << 1),
}

enum : command_queue_properties
{
    QUEUE_OUT_OF_ORDER_EXEC_MODE_ENABLE      = (1 << 0),
    QUEUE_PROFILING_ENABLE                   = (1 << 1),
}

enum : context_info
{
    CONTEXT_REFERENCE_COUNT                  = 0x1080,
    CONTEXT_DEVICES                          = 0x1081,
    CONTEXT_PROPERTIES                       = 0x1082,
    CONTEXT_NUM_DEVICES                      = 0x1083,
}

enum : context_properties
{
    CONTEXT_PLATFORM                         = 0x1084,
    CONTEXT_INTEROP_USER_SYNC                = 0x1085,
}

enum : device_partition_property
{
    DEVICE_PARTITION_EQUALLY                 = 0x1086,
    DEVICE_PARTITION_BY_COUNTS               = 0x1087,
    DEVICE_PARTITION_BY_COUNTS_LIST_END      = 0x0,
    DEVICE_PARTITION_BY_AFFINITY_DOMAIN      = 0x1088,
}

enum : device_affinity_domain
{
    DEVICE_AFFINITY_DOMAIN_NUMA               = (1 << 0),
    DEVICE_AFFINITY_DOMAIN_L4_CACHE           = (1 << 1),
    DEVICE_AFFINITY_DOMAIN_L3_CACHE           = (1 << 2),
    DEVICE_AFFINITY_DOMAIN_L2_CACHE           = (1 << 3),
    DEVICE_AFFINITY_DOMAIN_L1_CACHE           = (1 << 4),
    DEVICE_AFFINITY_DOMAIN_NEXT_PARTITIONABLE = (1 << 5),
}

enum : command_queue_info
{
    QUEUE_CONTEXT                            = 0x1090,
    QUEUE_DEVICE                             = 0x1091,
    QUEUE_REFERENCE_COUNT                    = 0x1092,
    QUEUE_PROPERTIES                         = 0x1093,
}

enum : mem_flags
{
    MEM_READ_WRITE                           = (1 << 0),
    MEM_WRITE_ONLY                           = (1 << 1),
    MEM_READ_ONLY                            = (1 << 2),
    MEM_USE_HOST_PTR                         = (1 << 3),
    MEM_ALLOC_HOST_PTR                       = (1 << 4),
    MEM_COPY_HOST_PTR                        = (1 << 5),
// reserved                                     = (1 << 6),
    MEM_HOST_WRITE_ONLY                      = (1 << 7),
    MEM_HOST_READ_ONLY                       = (1 << 8),
    MEM_HOST_NO_ACCESS                       = (1 << 9),
}

enum : mem_migration_flags
{
    MIGRATE_MEM_OBJECT_HOST                  = (1 << 0),
    MIGRATE_MEM_OBJECT_CONTENT_UNDEFINED     = (1 << 1),
}

enum : channel_order
{
    R                                        = 0x10B0,
    A                                        = 0x10B1,
    RG                                       = 0x10B2,
    RA                                       = 0x10B3,
    RGB                                      = 0x10B4,
    RGBA                                     = 0x10B5,
    BGRA                                     = 0x10B6,
    ARGB                                     = 0x10B7,
    INTENSITY                                = 0x10B8,
    LUMINANCE                                = 0x10B9,
    Rx                                       = 0x10BA,
    RGx                                      = 0x10BB,
    RGBx                                     = 0x10BC,
    DEPTH                                    = 0x10BD,
    DEPTH_STENCIL                            = 0x10BE,
}

enum : channel_type
{
    SNORM_INT8                               = 0x10D0,
    SNORM_INT16                              = 0x10D1,
    UNORM_INT8                               = 0x10D2,
    UNORM_INT16                              = 0x10D3,
    UNORM_SHORT_565                          = 0x10D4,
    UNORM_SHORT_555                          = 0x10D5,
    UNORM_INT_101010                         = 0x10D6,
    SIGNED_INT8                              = 0x10D7,
    SIGNED_INT16                             = 0x10D8,
    SIGNED_INT32                             = 0x10D9,
    UNSIGNED_INT8                            = 0x10DA,
    UNSIGNED_INT16                           = 0x10DB,
    UNSIGNED_INT32                           = 0x10DC,
    HALF_FLOAT                               = 0x10DD,
    FLOAT                                    = 0x10DE,
    UNORM_INT24                              = 0x10DF,
}

enum : mem_object_type
{
    MEM_OBJECT_BUFFER                        = 0x10F0,
    MEM_OBJECT_IMAGE2D                       = 0x10F1,
    MEM_OBJECT_IMAGE3D                       = 0x10F2,
    MEM_OBJECT_IMAGE2D_ARRAY                 = 0x10F3,
    MEM_OBJECT_IMAGE1D                       = 0x10F4,
    MEM_OBJECT_IMAGE1D_ARRAY                 = 0x10F5,
    MEM_OBJECT_IMAGE1D_BUFFER                = 0x10F6,
}

enum : mem_info
{
    MEM_TYPE                                 = 0x1100,
    MEM_FLAGS                                = 0x1101,
    MEM_SIZE                                 = 0x1102,
    MEM_HOST_PTR                             = 0x1103,
    MEM_MAP_COUNT                            = 0x1104,
    MEM_REFERENCE_COUNT                      = 0x1105,
    MEM_CONTEXT                              = 0x1106,
    MEM_ASSOCIATED_MEMOBJECT                 = 0x1107,
    MEM_OFFSET                               = 0x1108,
}

enum : image_info
{
    IMAGE_FORMAT                             = 0x1110,
    IMAGE_ELEMENT_SIZE                       = 0x1111,
    IMAGE_ROW_PITCH                          = 0x1112,
    IMAGE_SLICE_PITCH                        = 0x1113,
    IMAGE_WIDTH                              = 0x1114,
    IMAGE_HEIGHT                             = 0x1115,
    IMAGE_DEPTH                              = 0x1116,
    IMAGE_ARRAY_SIZE                         = 0x1117,
    IMAGE_BUFFER                             = 0x1118,
    IMAGE_NUM_MIP_LEVELS                     = 0x1119,
    IMAGE_NUM_SAMPLES                        = 0x111A,
}

enum : addressing_mode
{
    ADDRESS_NONE                             = 0x1130,
    ADDRESS_CLAMP_TO_EDGE                    = 0x1131,
    ADDRESS_CLAMP                            = 0x1132,
    ADDRESS_REPEAT                           = 0x1133,
    ADDRESS_MIRRORED_REPEAT                  = 0x1134,
}

enum : filter_mode
{
    FILTER_NEAREST                           = 0x1140,
    FILTER_LINEAR                            = 0x1141,
}

enum : sampler_info
{
    SAMPLER_REFERENCE_COUNT                  = 0x1150,
    SAMPLER_CONTEXT                          = 0x1151,
    SAMPLER_NORMALIZED_COORDS                = 0x1152,
    SAMPLER_ADDRESSING_MODE                  = 0x1153,
    SAMPLER_FILTER_MODE                      = 0x1154,
}

enum : map_flags
{
    MAP_READ                                 = (1 << 0),
    MAP_WRITE                                = (1 << 1),
    MAP_WRITE_INVALIDATE_REGION              = (1 << 2),
}

enum : program_info
{
    PROGRAM_REFERENCE_COUNT                  = 0x1160,
    PROGRAM_CONTEXT                          = 0x1161,
    PROGRAM_NUM_DEVICES                      = 0x1162,
    PROGRAM_DEVICES                          = 0x1163,
    PROGRAM_SOURCE                           = 0x1164,
    PROGRAM_BINARY_SIZES                     = 0x1165,
    PROGRAM_BINARIES                         = 0x1166,
    PROGRAM_NUM_KERNELS                      = 0x1167,
    PROGRAM_KERNEL_NAMES                     = 0x1168,
}

enum : program_build_info
{
    PROGRAM_BUILD_STATUS                     = 0x1181,
    PROGRAM_BUILD_OPTIONS                    = 0x1182,
    PROGRAM_BUILD_LOG                        = 0x1183,
    PROGRAM_BINARY_TYPE                      = 0x1184,
}

enum : program_binary_type
{
    PROGRAM_BINARY_TYPE_NONE                 = 0x0,
    PROGRAM_BINARY_TYPE_COMPILED_OBJECT      = 0x1,
    PROGRAM_BINARY_TYPE_LIBRARY              = 0x2,
    PROGRAM_BINARY_TYPE_EXECUTABLE           = 0x4,
}

enum : build_status
{
    BUILD_SUCCESS                            =  0,
    BUILD_NONE                               = -1,
    BUILD_ERROR                              = -2,
    BUILD_IN_PROGRESS                        = -3,
}

enum : kernel_info
{
    KERNEL_FUNCTION_NAME                     = 0x1190,
    KERNEL_NUM_ARGS                          = 0x1191,
    KERNEL_REFERENCE_COUNT                   = 0x1192,
    KERNEL_CONTEXT                           = 0x1193,
    KERNEL_PROGRAM                           = 0x1194,
    KERNEL_ATTRIBUTES                        = 0x1195,
}

enum : kernel_arg_info
{
    KERNEL_ARG_ADDRESS_QUALIFIER             = 0x1196,
    KERNEL_ARG_ACCESS_QUALIFIER              = 0x1197,
    KERNEL_ARG_TYPE_NAME                     = 0x1198,
    KERNEL_ARG_TYPE_QUALIFIER                = 0x1199,
    KERNEL_ARG_NAME                          = 0x119A,
}

enum : kernel_arg_address_qualifier
{
    KERNEL_ARG_ADDRESS_GLOBAL                = 0x119B,
    KERNEL_ARG_ADDRESS_LOCAL                 = 0x119C,
    KERNEL_ARG_ADDRESS_CONSTANT              = 0x119D,
    KERNEL_ARG_ADDRESS_PRIVATE               = 0x119E,
}

enum : kernel_arg_access_qualifier
{
    KERNEL_ARG_ACCESS_READ_ONLY              = 0x11A0,
    KERNEL_ARG_ACCESS_WRITE_ONLY             = 0x11A1,
    KERNEL_ARG_ACCESS_READ_WRITE             = 0x11A2,
    KERNEL_ARG_ACCESS_NONE                   = 0x11A3,
}

enum : kernel_arg_type_qualifer
{
    KERNEL_ARG_TYPE_NONE                     = 0,
    KERNEL_ARG_TYPE_CONST                    = (1 << 0),
    KERNEL_ARG_TYPE_RESTRICT                 = (1 << 1),
    KERNEL_ARG_TYPE_VOLATILE                 = (1 << 2),
}

enum : kernel_work_group_info
{
    KERNEL_WORK_GROUP_SIZE                   = 0x11B0,
    KERNEL_COMPILE_WORK_GROUP_SIZE           = 0x11B1,
    KERNEL_LOCAL_MEM_SIZE                    = 0x11B2,
    KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE= 0x11B3,
    KERNEL_PRIVATE_MEM_SIZE                  = 0x11B4,
    KERNEL_GLOBAL_WORK_SIZE                  = 0x11B5,
}

enum : event_info
{
    EVENT_COMMAND_QUEUE                      = 0x11D0,
    EVENT_COMMAND_TYPE                       = 0x11D1,
    EVENT_REFERENCE_COUNT                    = 0x11D2,
    EVENT_COMMAND_EXECUTION_STATUS           = 0x11D3,
    EVENT_CONTEXT                            = 0x11D4,
}

enum : command_type
{
    COMMAND_NDRANGE_KERNEL                   = 0x11F0,
    COMMAND_TASK                             = 0x11F1,
    COMMAND_NATIVE_KERNEL                    = 0x11F2,
    COMMAND_READ_BUFFER                      = 0x11F3,
    COMMAND_WRITE_BUFFER                     = 0x11F4,
    COMMAND_COPY_BUFFER                      = 0x11F5,
    COMMAND_READ_IMAGE                       = 0x11F6,
    COMMAND_WRITE_IMAGE                      = 0x11F7,
    COMMAND_COPY_IMAGE                       = 0x11F8,
    COMMAND_COPY_IMAGE_TO_BUFFER             = 0x11F9,
    COMMAND_COPY_BUFFER_TO_IMAGE             = 0x11FA,
    COMMAND_MAP_BUFFER                       = 0x11FB,
    COMMAND_MAP_IMAGE                        = 0x11FC,
    COMMAND_UNMAP_MEM_OBJECT                 = 0x11FD,
    COMMAND_MARKER                           = 0x11FE,
    COMMAND_ACQUIRE_GL_OBJECTS               = 0x11FF,
    COMMAND_RELEASE_GL_OBJECTS               = 0x1200,
    COMMAND_READ_BUFFER_RECT                 = 0x1201,
    COMMAND_WRITE_BUFFER_RECT                = 0x1202,
    COMMAND_COPY_BUFFER_RECT                 = 0x1203,
    COMMAND_USER                             = 0x1204,
    COMMAND_BARRIER                          = 0x1205,
    COMMAND_MIGRATE_MEM_OBJECTS              = 0x1206,
    COMMAND_FILL_BUFFER                      = 0x1207,
    COMMAND_FILL_IMAGE                       = 0x1208,
}

enum : command_execution_status
{
    COMPLETE                                 = 0x0,
    RUNNING                                  = 0x1,
    SUBMITTED                                = 0x2,
    QUEUED                                   = 0x3,
}

enum : buffer_create_type
{
    BUFFER_CREATE_TYPE_REGION                = 0x1220,
}

enum : profiling_info
{
    PROFILING_COMMAND_QUEUED                 = 0x1280,
    PROFILING_COMMAND_SUBMIT                 = 0x1281,
    PROFILING_COMMAND_START                  = 0x1282,
    PROFILING_COMMAND_END                    = 0x1283,
}


