module clWrap.info;

import derelict.opencl.cl;
import derelict.opengl3.gl3;
import clWrap.errors;

import std.typetuple, std.traits;

/+
template getInfo(alias F)
{
    alias getInfo(uint flag) = .getInfo!(F, flag);
}+/

auto getInfo(alias F, uint flag, EARTs ...)(void* id)
{
    foreach(eart; EARTs)
    {
        static if(eart.v == flag)
        {
            static if(is(eart.T == char[]))
            {
                size_t size;
                F(id, flag, 0, null, &size)
                    .clEnforce();
                auto value = new char[size];
                F(id, flag, size, value.ptr, null)
                    .clEnforce();
            }
            else static if(isStaticArray!(eart.T))
            {
                eart.T value;
                F(id, flag, value.memSize, value.ptr, null)
                    .clEnforce();
            }
            else static if(isArray!(eart.T))
            {
                auto value = eart.handler(id);
                F(id, flag, value.memSize, value.ptr, null)
                    .clEnforce();
            }
            else
            {
                eart.T value;
                F(id, flag, typeof(value).sizeof, &value, null)
                    .clEnforce();
            }

            return value;
        }
    }
    assert(false);
}

private template EnumAndReturnType(alias v_, T_, alias handler = null)
{
    alias v = v_;
    alias T = T_;
}

private alias EART = EnumAndReturnType;

alias queueInfoEnums = TypeTuple!(
        EART!(CL_QUEUE_CONTEXT, cl_context),
        EART!(CL_QUEUE_DEVICE, cl_device_id),
        EART!(CL_QUEUE_REFERENCE_COUNT, cl_uint),
        EART!(CL_QUEUE_PROPERTIES, cl_command_queue_properties));

alias platformInfoEnums = TypeTuple!(
        EART!(CL_PLATFORM_PROFILE, char[]),
        EART!(CL_PLATFORM_VERSION, char[]),
        EART!(CL_PLATFORM_NAME, char[]),
        EART!(CL_PLATFORM_VENDOR, char[]),
        EART!(CL_PLATFORM_EXTENSIONS, char[]),
        EART!(CL_PLATFORM_VERSION, char[]),
        EART!(CL_PLATFORM_ICD_SUFFIX_KHR, char[]));

alias deviceInfoEnums = TypeTuple!(
        EART!(CL_DEVICE_ADDRESS_BITS, cl_uint),
        EART!(CL_DEVICE_AFFINITY_DOMAINS_EXT, cl_device_partition_property_ext[]), //special case
        EART!(CL_DEVICE_AVAILABLE, cl_bool),
        EART!(CL_DEVICE_BUILT_IN_KERNELS, char[]),
        EART!(CL_DEVICE_COMPILER_AVAILABLE, cl_bool),
        EART!(CL_DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, cl_uint),
        EART!(CL_DEVICE_COMPUTE_CAPABILITY_MINOR_NV, cl_uint),
        EART!(CL_DEVICE_DOUBLE_FP_CONFIG, cl_device_fp_config),
        EART!(CL_DEVICE_ENDIAN_LITTLE, cl_bool),
        EART!(CL_DEVICE_ERROR_CORRECTION_SUPPORT, cl_bool),
        EART!(CL_DEVICE_EXECUTION_CAPABILITIES, cl_device_exec_capabilities),
        EART!(CL_DEVICE_EXTENSIONS, char[]),
        EART!(CL_DEVICE_GLOBAL_MEM_CACHELINE_SIZE, cl_uint),
        EART!(CL_DEVICE_GLOBAL_MEM_CACHE_SIZE, cl_ulong),
        EART!(CL_DEVICE_GLOBAL_MEM_CACHE_TYPE, cl_device_mem_cache_type),
        EART!(CL_DEVICE_GLOBAL_MEM_SIZE, cl_ulong),
        EART!(CL_DEVICE_GPU_OVERLAP_NV, cl_bool),
        EART!(CL_DEVICE_HALF_FP_CONFIG, cl_device_fp_config),
        EART!(CL_DEVICE_HOST_UNIFIED_MEMORY, cl_bool),
        EART!(CL_DEVICE_IMAGE2D_MAX_HEIGHT, size_t),
        EART!(CL_DEVICE_IMAGE2D_MAX_WIDTH, size_t),
        EART!(CL_DEVICE_IMAGE3D_MAX_DEPTH, size_t),
        EART!(CL_DEVICE_IMAGE3D_MAX_HEIGHT, size_t),
        EART!(CL_DEVICE_IMAGE3D_MAX_WIDTH, size_t),
        EART!(CL_DEVICE_IMAGE_MAX_ARRAY_SIZE, size_t),
        EART!(CL_DEVICE_IMAGE_MAX_BUFFER_SIZE, size_t),
        EART!(CL_DEVICE_IMAGE_SUPPORT, cl_bool),
        EART!(CL_DEVICE_INTEGRATED_MEMORY_NV, cl_bool),
        EART!(CL_DEVICE_KERNEL_EXEC_TIMEOUT_NV, cl_bool),
        EART!(CL_DEVICE_LINKER_AVAILABLE, cl_bool),
        EART!(CL_DEVICE_LOCAL_MEM_SIZE, cl_ulong),
        EART!(CL_DEVICE_LOCAL_MEM_TYPE, cl_device_local_mem_type),
        EART!(CL_DEVICE_MAX_CLOCK_FREQUENCY, cl_uint),
        EART!(CL_DEVICE_MAX_COMPUTE_UNITS, cl_uint),
        EART!(CL_DEVICE_MAX_CONSTANT_ARGS, cl_uint),
        EART!(CL_DEVICE_MAX_CONSTANT_BUFFER_SIZE, cl_ulong),
        EART!(CL_DEVICE_MAX_MEM_ALLOC_SIZE, cl_ulong),
        EART!(CL_DEVICE_MAX_PARAMETER_SIZE, size_t),
        EART!(CL_DEVICE_MAX_READ_IMAGE_ARGS, cl_uint),
        EART!(CL_DEVICE_MAX_SAMPLERS, cl_uint),
        EART!(CL_DEVICE_MAX_WORK_GROUP_SIZE, size_t),
        EART!(CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS, cl_uint),
        EART!(CL_DEVICE_MAX_WORK_ITEM_SIZES, size_t[]), //special case
        EART!(CL_DEVICE_MAX_WRITE_IMAGE_ARGS, cl_uint),
        EART!(CL_DEVICE_MEM_BASE_ADDR_ALIGN, cl_uint),
        EART!(CL_DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, cl_uint),
        EART!(CL_DEVICE_NAME, char[]),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_CHAR, cl_uint),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE, cl_uint),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_FLOAT, cl_uint),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_HALF, cl_uint),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_INT, cl_uint),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_LONG, cl_uint),
        EART!(CL_DEVICE_NATIVE_VECTOR_WIDTH_SHORT, cl_uint),
        EART!(CL_DEVICE_OPENCL_C_VERSION, char[]),
        EART!(CL_DEVICE_PARENT_DEVICE, cl_device_id),
        EART!(CL_DEVICE_PARENT_DEVICE_EXT, cl_device_id),
        EART!(CL_DEVICE_PARTITION_AFFINITY_DOMAIN, cl_device_affinity_domain[]), //special case
        EART!(CL_DEVICE_PARTITION_MAX_SUB_DEVICES, cl_uint),
        EART!(CL_DEVICE_PARTITION_PROPERTIES, cl_device_partition_property[]), //special case
        EART!(CL_DEVICE_PARTITION_STYLE_EXT, cl_device_partition_property_ext[]), //special case
        EART!(CL_DEVICE_PARTITION_TYPE, cl_device_partition_property[]), //special case
        EART!(CL_DEVICE_PARTITION_TYPES_EXT, cl_device_partition_property_ext[]), //special case
        EART!(CL_DEVICE_PLATFORM, cl_platform_id),
        EART!(CL_DEVICE_PREFERRED_INTEROP_USER_SYNC, cl_bool),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, cl_uint),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, cl_uint),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, cl_uint),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_HALF, cl_uint),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_INT, cl_uint),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_LONG, cl_uint),
        EART!(CL_DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, cl_uint),
        EART!(CL_DEVICE_PRINTF_BUFFER_SIZE, size_t),
        EART!(CL_DEVICE_PROFILE, char[]),
        //EART!(CL_DEVICE_PROFILING_TIMER_OFFSET_AMD,    //Can't find what type it expects
        EART!(CL_DEVICE_PROFILING_TIMER_RESOLUTION, size_t),
        EART!(CL_DEVICE_QUEUE_PROPERTIES, cl_command_queue_properties),
        EART!(CL_DEVICE_REFERENCE_COUNT, cl_uint),
        EART!(CL_DEVICE_REFERENCE_COUNT_EXT, cl_uint),
        EART!(CL_DEVICE_REGISTERS_PER_BLOCK_NV, cl_uint),
        EART!(CL_DEVICE_SINGLE_FP_CONFIG, cl_device_fp_config),
        //EART!(CL_DEVICE_TERMINATE_CAPABILITY_KHR, cl_device_terminate_capability_khr), //return type doesn't exist...
        EART!(CL_DEVICE_TYPE, cl_device_type),
        EART!(CL_DEVICE_VENDOR, char[]),
        EART!(CL_DEVICE_VENDOR_ID, cl_uint),
        EART!(CL_DEVICE_VERSION, char[]),
        EART!(CL_DEVICE_WARP_SIZE_NV, cl_uint),
        EART!(CL_DRIVER_VERSION, char[]));

alias contextInfoEnums = TypeTuple!(
        EART!(CL_CONTEXT_REFERENCE_COUNT, cl_uint),
        EART!(CL_CONTEXT_DEVICES, cl_device_id[]), //special case
        EART!(CL_CONTEXT_PROPERTIES, cl_context_properties[]),
        EART!(CL_CONTEXT_NUM_DEVICES, cl_uint),
//        EART!(CL_CONTEXT_D3D10_PREFER_SHARED_RESOURCES_KHR, cl_bool),
//        EART!(CL_CONTEXT_D3D11_PREFER_SHARED_RESOURCES_KHR, cl_bool)
        );

alias memObjectInfoEnums = TypeTuple!(
        EART!(CL_MEM_TYPE, cl_mem_object_type),
        EART!(CL_MEM_FLAGS, cl_mem_flags),
        EART!(CL_MEM_SIZE, size_t),
        EART!(CL_MEM_HOST_PTR, void*),
        EART!(CL_MEM_MAP_COUNT, cl_uint),
        EART!(CL_MEM_REFERENCE_COUNT, cl_uint),
        EART!(CL_MEM_CONTEXT, cl_context),
        EART!(CL_MEM_ASSOCIATED_MEMOBJECT, cl_mem),
        EART!(CL_MEM_OFFSET, size_t),
//        EART!(CL_MEM_D3D10_RESOURCE_KHR, ID3D10Resource*),
//        EART!(CL_MEM_DX9_MEDIA_ADAPTER_TYPE_KHR, cl_dx9_media_adapter_type_khr),
//        EART!(CL_MEM_DX9_MEDIA_SURFACE_INFO_KHR, cl_dx9_surface_info_khr),
//        EART!(CL_MEM_D3D11_RESOURCE_KHR, ID3D11Resource*)
        );

alias imageInfoEnums = TypeTuple!(
        EART!(CL_IMAGE_FORMAT, cl_image_format),
        EART!(CL_IMAGE_ELEMENT_SIZE, size_t),
        EART!(CL_IMAGE_ROW_PITCH, size_t),
        EART!(CL_IMAGE_SLICE_PITCH, size_t),
        EART!(CL_IMAGE_WIDTH, size_t),
        EART!(CL_IMAGE_HEIGHT, size_t),
        EART!(CL_IMAGE_DEPTH, size_t),
        EART!(CL_IMAGE_ARRAY_SIZE, size_t),
        EART!(CL_IMAGE_BUFFER, cl_mem),
        EART!(CL_IMAGE_NUM_MIP_LEVELS, cl_uint),
        EART!(CL_IMAGE_NUM_SAMPLES, cl_uint),
//        EART!(CL_IMAGE_D3D10_SUBRESOURCE_KHR, ID3D10Resource*),
//        EART!(CL_IMAGE_DX9_MEDIA_PLANE_KHR, cl_uint),
//        EART!(CL_IMAGE_DX9_MEDIA_SURFACE_PLANE_KHR, cl_uint),
//        EART!(CL_IMAGE_D3D11_SUBRESOURCE_KHR, ID3D11Resource*)
        );

alias samplerInfoEnums = TypeTuple!(
        EART!(CL_SAMPLER_REFERENCE_COUNT, cl_uint),
        EART!(CL_SAMPLER_CONTEXT, cl_context),
        EART!(CL_SAMPLER_NORMALIZED_COORDS, cl_bool),
        EART!(CL_SAMPLER_ADDRESSING_MODE, cl_addressing_mode),
        EART!(CL_SAMPLER_FILTER_MODE, cl_filter_mode));

alias programInfoEnums = TypeTuple!(
        EART!(CL_PROGRAM_REFERENCE_COUNT, cl_uint),
        EART!(CL_PROGRAM_CONTEXT, cl_context),
        EART!(CL_PROGRAM_NUM_DEVICES, cl_uint),
        EART!(CL_PROGRAM_DEVICES, cl_device_id[]), //special case
        EART!(CL_PROGRAM_SOURCE, char[]),
        EART!(CL_PROGRAM_BINARY_SIZES, size_t[]), //special case
        EART!(CL_PROGRAM_BINARIES, ubyte[][]), //special case
        EART!(CL_PROGRAM_NUM_KERNELS, size_t),
        EART!(CL_PROGRAM_KERNEL_NAMES, char[]));

alias programBuildInfoEnums = TypeTuple!(
        EART!(CL_PROGRAM_BUILD_STATUS, cl_build_status),
        EART!(CL_PROGRAM_BUILD_OPTIONS, char[]),
        EART!(CL_PROGRAM_BUILD_LOG, char[]),
        EART!(CL_PROGRAM_BINARY_TYPE, cl_program_binary_type));

alias kernelInfoEnums = TypeTuple!(
        EART!(CL_KERNEL_FUNCTION_NAME, char[]),
        EART!(CL_KERNEL_NUM_ARGS, cl_uint),
        EART!(CL_KERNEL_REFERENCE_COUNT, cl_uint),
        EART!(CL_KERNEL_CONTEXT, cl_context),
        EART!(CL_KERNEL_PROGRAM, cl_program),
        EART!(CL_KERNEL_ATTRIBUTES, char[]));

alias kernelArgInfoEnums =TypeTuple!(
        EART!(CL_KERNEL_ARG_ADDRESS_QUALIFIER, cl_kernel_arg_address_qualifier),
        EART!(CL_KERNEL_ARG_ACCESS_QUALIFIER, cl_kernel_arg_access_qualifier),
        EART!(CL_KERNEL_ARG_TYPE_NAME, char[]),
        EART!(CL_KERNEL_ARG_TYPE_QUALIFIER, cl_kernel_arg_type_qualifier),
        EART!(CL_KERNEL_ARG_NAME, char[]));

alias kernelWorkGroupInfoEnums = TypeTuple!(
        EART!(CL_KERNEL_WORK_GROUP_SIZE, size_t),
        EART!(CL_KERNEL_COMPILE_WORK_GROUP_SIZE, size_t[3]),
        EART!(CL_KERNEL_LOCAL_MEM_SIZE, cl_ulong),
        EART!(CL_KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE, size_t),
        EART!(CL_KERNEL_PRIVATE_MEM_SIZE, cl_ulong),
        EART!(CL_KERNEL_GLOBAL_WORK_SIZE, size_t[3]));

alias eventInfoEnums = TypeTuple!(
        EART!(CL_EVENT_COMMAND_QUEUE, cl_command_queue),
        EART!(CL_EVENT_COMMAND_TYPE, cl_command_type),
        EART!(CL_EVENT_REFERENCE_COUNT, cl_uint),
        EART!(CL_EVENT_COMMAND_EXECUTION_STATUS, cl_int),
        EART!(CL_EVENT_CONTEXT, cl_context));

alias eventProfilingInfoEnums = TypeTuple!(
        EART!(CL_PROFILING_COMMAND_QUEUED, cl_ulong),
        EART!(CL_PROFILING_COMMAND_SUBMIT, cl_ulong),
        EART!(CL_PROFILING_COMMAND_START, cl_ulong),
        EART!(CL_PROFILING_COMMAND_END, cl_ulong));

alias glTextureInfoEnums = TypeTuple!(
        EART!(CL_GL_TEXTURE_TARGET, GLenum),
        EART!(CL_GL_MIPMAP_LEVEL, GLint),
        EART!(CL_GL_NUM_SAMPLES, GLsizei));

alias glContextInfoEnums = TypeTuple!(
        EART!(CL_CURRENT_DEVICE_FOR_GL_CONTEXT_KHR, cl_device_id),
        EART!(CL_DEVICES_FOR_GL_CONTEXT_KHR, cl_device_id[]));
