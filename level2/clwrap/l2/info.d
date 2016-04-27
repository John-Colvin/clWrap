module clwrap.l2.info;

import clwrap.l2.errors;
import clwrap.l2.wrap;
import clwrap.cl;

import std.traits;
import std.meta;

/+
template getInfo(alias F)
{
    alias getInfo(uint flag) = .getInfo!(F, flag);
}+/

template getInfo(alias flag)
{
    auto getInfo(T, Args...)(T id, Args args)
    {
        foreach (Group; GetEARTs!T)
        {
            alias F = Group.F;
            foreach (eart; Group.EARTs)
            {
                static if(eart.flag == flag)
                {
                    static if(hasMember!(eart, "handler"))
                        return eart.handler(id, args);
                    else
                        return getInfoGeneric!(eart.ReturnT, F, flag)(id);
                }
            }
        }
        assert(false);
    }
}

auto getInfoGeneric(ReturnT, alias F, alias flag, T)(T id)
{
    static if(is(ReturnT : U[], U))
        return getArrayInfo!(U, F, flag)(id);
    else static if(isStaticArray!(ReturnT))
        return getStaticArrayInfo!(ReturnT, F, flag)(id);
    else
        return getValueInfo!(ReturnT, F, flag)(id);
}

auto getArrayInfo(ElemT, alias F, alias flag, T)(T id)
{
    size_t size;
    F(id, flag, 0, null, &size).clEnforce();
    assert(size % ElemT.sizeof == 0);
    ElemT[] value;
    value.length = size / ElemT.sizeof;
    F(id, flag, size, value.ptr, null).clEnforce();
    return value;
}

auto getStaticArrayInfo(ArrayT, alias F, alias flag, T)(T id)
{
    ArrayT value;
    F(id, flag, value.memSize, value.ptr, null).clEnforce();
    return value;
}

auto getValueInfo(V, alias F, alias flag, T)(T id)
{
    V value;
    F(id, flag, typeof(value).sizeof, &value, null).clEnforce();
    return value;
}

template GetEARTs(T)
{
    static if (is(T : cl.command_queue))
        alias GetEARTs = AliasSeq!queueInfoEnums;
    else static if (is(T : cl.platform_id))
        alias GetEARTs = AliasSeq!platformInfoEnums;
    else static if (is(T : cl.device_id))
        alias GetEARTs = AliasSeq!deviceInfoEnums;
    else static if (is(T : cl.context))
        alias GetEARTs = AliasSeq!contextInfoEnums;
    else static if (is(T : CLBuffer!X, X))
        alias GetEARTs = AliasSeq!memObjectInfoEnums;
    else static if (is(T : CLImage!X, X))
        alias GetEARTs = AliasSeq!imageInfoEnums;
    else static if (is(T : cl.sampler))
        alias GetEARTs = AliasSeq!samplerInfoEnums;
    else static if (is(T : cl.program))
        alias GetEARTs = AliasSeq!(programInfoEnums, programBuildInfoEnums);
    else static if (is(T : cl.kernel))
        alias GetEARTs = AliasSeq!(kernelInfoEnums, kernelArgInfoEnums, kernelWorkGroupInfoEnums);
    else static if (is(T : cl.event))
        alias GetEARTs = AliasSeq!(eventInfoEnums, eventProfilingInfoEnums);
}

private struct EnumAndReturnType(alias flag_, ReturnT_, alias handler_ = null)
{
    alias flag = flag_;
    alias ReturnT = ReturnT_;
    static if(!is(typeof(handler_) == typeof(null)))
        alias handler = handler_;
}

private alias EART = EnumAndReturnType;

private struct EARTGroup(alias F_, EARTs_...)
if (allSatisfy!(ApplyLeft!(isInstanceOf, EART), EARTs_))
{
    alias F = F_;
    alias EARTs = EARTs_;
}

alias queueInfoEnums = EARTGroup!(getCommandQueueInfo,
        EART!(QUEUE_CONTEXT, context),
        EART!(QUEUE_DEVICE, device_id),
        EART!(QUEUE_REFERENCE_COUNT, uint),
        EART!(QUEUE_PROPERTIES, command_queue_properties));

alias platformInfoEnums = EARTGroup!(getPlatformInfo,
        EART!(PLATFORM_PROFILE, char[]),
        EART!(PLATFORM_VERSION, char[]),
        EART!(PLATFORM_NAME, char[]),
        EART!(PLATFORM_VENDOR, char[]),
        EART!(PLATFORM_EXTENSIONS, char[]),
        EART!(PLATFORM_VERSION, char[]),
        EART!(PLATFORM_ICD_SUFFIX_KHR, char[]));

alias deviceInfoEnums = EARTGroup!(getDeviceInfo,
        EART!(DEVICE_ADDRESS_BITS, uint),
        EART!(DEVICE_AFFINITY_DOMAINS_EXT, device_partition_property_ext[]),
        EART!(DEVICE_AVAILABLE, bool),
        EART!(DEVICE_BUILT_IN_KERNELS, char[]),
        EART!(DEVICE_COMPILER_AVAILABLE, bool),
        EART!(DEVICE_COMPUTE_CAPABILITY_MAJOR_NV, uint),
        EART!(DEVICE_COMPUTE_CAPABILITY_MINOR_NV, uint),
        EART!(DEVICE_DOUBLE_FP_CONFIG, device_fp_config),
        EART!(DEVICE_ENDIAN_LITTLE, bool),
        EART!(DEVICE_ERROR_CORRECTION_SUPPORT, bool),
        EART!(DEVICE_EXECUTION_CAPABILITIES, device_exec_capabilities),
        EART!(DEVICE_EXTENSIONS, char[]),
        EART!(DEVICE_GLOBAL_MEM_CACHELINE_SIZE, uint),
        EART!(DEVICE_GLOBAL_MEM_CACHE_SIZE, ulong),
        EART!(DEVICE_GLOBAL_MEM_CACHE_TYPE, device_mem_cache_type),
        EART!(DEVICE_GLOBAL_MEM_SIZE, ulong),
        EART!(DEVICE_GPU_OVERLAP_NV, bool),
        EART!(DEVICE_HALF_FP_CONFIG, device_fp_config),
        EART!(DEVICE_HOST_UNIFIED_MEMORY, bool),
        EART!(DEVICE_IMAGE2D_MAX_HEIGHT, size_t),
        EART!(DEVICE_IMAGE2D_MAX_WIDTH, size_t),
        EART!(DEVICE_IMAGE3D_MAX_DEPTH, size_t),
        EART!(DEVICE_IMAGE3D_MAX_HEIGHT, size_t),
        EART!(DEVICE_IMAGE3D_MAX_WIDTH, size_t),
        EART!(DEVICE_IMAGE_MAX_ARRAY_SIZE, size_t),
        EART!(DEVICE_IMAGE_MAX_BUFFER_SIZE, size_t),
        EART!(DEVICE_IMAGE_SUPPORT, bool),
        EART!(DEVICE_INTEGRATED_MEMORY_NV, bool),
        EART!(DEVICE_KERNEL_EXEC_TIMEOUT_NV, bool),
        EART!(DEVICE_LINKER_AVAILABLE, bool),
        EART!(DEVICE_LOCAL_MEM_SIZE, ulong),
        EART!(DEVICE_LOCAL_MEM_TYPE, device_local_mem_type),
        EART!(DEVICE_MAX_CLOCK_FREQUENCY, uint),
        EART!(DEVICE_MAX_COMPUTE_UNITS, uint),
        EART!(DEVICE_MAX_CONSTANT_ARGS, uint),
        EART!(DEVICE_MAX_CONSTANT_BUFFER_SIZE, ulong),
        EART!(DEVICE_MAX_MEM_ALLOC_SIZE, ulong),
        EART!(DEVICE_MAX_PARAMETER_SIZE, size_t),
        EART!(DEVICE_MAX_READ_IMAGE_ARGS, uint),
        EART!(DEVICE_MAX_SAMPLERS, uint),
        EART!(DEVICE_MAX_WORK_GROUP_SIZE, size_t),
        EART!(DEVICE_MAX_WORK_ITEM_DIMENSIONS, uint),
        EART!(DEVICE_MAX_WORK_ITEM_SIZES, size_t[]),
        EART!(DEVICE_MAX_WRITE_IMAGE_ARGS, uint),
        EART!(DEVICE_MEM_BASE_ADDR_ALIGN, uint),
        EART!(DEVICE_MIN_DATA_TYPE_ALIGN_SIZE, uint),
        EART!(DEVICE_NAME, char[]),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_CHAR, uint),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_DOUBLE, uint),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_FLOAT, uint),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_HALF, uint),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_INT, uint),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_LONG, uint),
        EART!(DEVICE_NATIVE_VECTOR_WIDTH_SHORT, uint),
        EART!(DEVICE_OPENCL_C_VERSION, char[]),
        EART!(DEVICE_PARENT_DEVICE, device_id),
        EART!(DEVICE_PARENT_DEVICE_EXT, device_id),
        EART!(DEVICE_PARTITION_AFFINITY_DOMAIN, device_affinity_domain[]),
        EART!(DEVICE_PARTITION_MAX_SUB_DEVICES, uint),
        EART!(DEVICE_PARTITION_PROPERTIES, device_partition_property[]),
        EART!(DEVICE_PARTITION_STYLE_EXT, device_partition_property_ext[]),
        EART!(DEVICE_PARTITION_TYPE, device_partition_property[]),
        EART!(DEVICE_PARTITION_TYPES_EXT, device_partition_property_ext[]),
        EART!(DEVICE_PLATFORM, platform_id),
        EART!(DEVICE_PREFERRED_INTEROP_USER_SYNC, bool),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_CHAR, uint),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_DOUBLE, uint),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_FLOAT, uint),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_HALF, uint),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_INT, uint),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_LONG, uint),
        EART!(DEVICE_PREFERRED_VECTOR_WIDTH_SHORT, uint),
        EART!(DEVICE_PRINTF_BUFFER_SIZE, size_t),
        EART!(DEVICE_PROFILE, char[]),
        //EART!(DEVICE_PROFILING_TIMER_OFFSET_AMD,    //Can't find what type it expects
        EART!(DEVICE_PROFILING_TIMER_RESOLUTION, size_t),
        EART!(DEVICE_QUEUE_PROPERTIES, command_queue_properties),
        EART!(DEVICE_REFERENCE_COUNT, uint),
        EART!(DEVICE_REFERENCE_COUNT_EXT, uint),
        EART!(DEVICE_REGISTERS_PER_BLOCK_NV, uint),
        EART!(DEVICE_SINGLE_FP_CONFIG, device_fp_config),
        //EART!(DEVICE_TERMINATE_CAPABILITY_KHR, device_terminate_capability_khr), //return type doesn't exist...
        EART!(DEVICE_TYPE, device_type),
        EART!(DEVICE_VENDOR, char[]),
        EART!(DEVICE_VENDOR_ID, uint),
        EART!(DEVICE_VERSION, char[]),
        EART!(DEVICE_WARP_SIZE_NV, uint),
        EART!(DRIVER_VERSION, char[]));

alias contextInfoEnums = EARTGroup!(getContextInfo,
        EART!(CONTEXT_REFERENCE_COUNT, uint),
        EART!(CONTEXT_DEVICES, device_id[]),
        EART!(CONTEXT_PROPERTIES, context_properties[]),
        EART!(CONTEXT_NUM_DEVICES, uint),
//        EART!(CONTEXT_D3D10_PREFER_SHARED_RESOURCES_KHR, bool),
//        EART!(CONTEXT_D3D11_PREFER_SHARED_RESOURCES_KHR, bool)
        );

alias memObjectInfoEnums = EARTGroup!(getMemObjectInfo,
        EART!(MEM_TYPE, mem_object_type),
        EART!(MEM_FLAGS, mem_flags),
        EART!(MEM_SIZE, size_t),
        EART!(MEM_HOST_PTR, void*),
        EART!(MEM_MAP_COUNT, uint),
        EART!(MEM_REFERENCE_COUNT, uint),
        EART!(MEM_CONTEXT, context),
        EART!(MEM_ASSOCIATED_MEMOBJECT, mem),
        EART!(MEM_OFFSET, size_t),
//        EART!(MEM_D3D10_RESOURCE_KHR, ID3D10Resource*),
//        EART!(MEM_DX9_MEDIA_ADAPTER_TYPE_KHR, dx9_media_adapter_type_khr),
//        EART!(MEM_DX9_MEDIA_SURFACE_INFO_KHR, dx9_surface_info_khr),
//        EART!(MEM_D3D11_RESOURCE_KHR, ID3D11Resource*)
        );

alias imageInfoEnums = EARTGroup!(getImageInfo,
        EART!(IMAGE_FORMAT, image_format),
        EART!(IMAGE_ELEMENT_SIZE, size_t),
        EART!(IMAGE_ROW_PITCH, size_t),
        EART!(IMAGE_SLICE_PITCH, size_t),
        EART!(IMAGE_WIDTH, size_t),
        EART!(IMAGE_HEIGHT, size_t),
        EART!(IMAGE_DEPTH, size_t),
        EART!(IMAGE_ARRAY_SIZE, size_t),
        EART!(IMAGE_BUFFER, mem),
        EART!(IMAGE_NUM_MIP_LEVELS, uint),
        EART!(IMAGE_NUM_SAMPLES, uint),
//        EART!(IMAGE_D3D10_SUBRESOURCE_KHR, ID3D10Resource*),
//        EART!(IMAGE_DX9_MEDIA_PLANE_KHR, uint),
//        EART!(IMAGE_DX9_MEDIA_SURFACE_PLANE_KHR, uint),
//        EART!(IMAGE_D3D11_SUBRESOURCE_KHR, ID3D11Resource*)
        );

alias samplerInfoEnums = EARTGroup!(getSamplerInfo,
        EART!(SAMPLER_REFERENCE_COUNT, uint),
        EART!(SAMPLER_CONTEXT, context),
        EART!(SAMPLER_NORMALIZED_COORDS, bool),
        EART!(SAMPLER_ADDRESSING_MODE, addressing_mode),
        EART!(SAMPLER_FILTER_MODE, filter_mode));

alias programInfoEnums = EARTGroup!(getProgramInfo,
        EART!(PROGRAM_REFERENCE_COUNT, uint),
        EART!(PROGRAM_CONTEXT, context),
        EART!(PROGRAM_NUM_DEVICES, uint),
        EART!(PROGRAM_DEVICES, device_id[]),
        EART!(PROGRAM_SOURCE, char[]),
        EART!(PROGRAM_BINARY_SIZES, size_t[]),
        EART!(PROGRAM_BINARIES, ubyte[][], (obj)
            {
                //Good god I hate the openCL API...
                auto sizes = obj.getInfo!PROGRAM_BINARY_SIZES;
                auto buffs = new ubyte[][sizes.length];
                //use the first half of buffs for the pointers
                auto buffPtrs = (cast(ubyte**)buffs.ptr)[0..sizes.length];
                foreach(i, ref buffPtr; buffPtrs)
                    buffPtr = (new ubyte[sizes[i]]).ptr;
                getProgramInfo(obj.id, PROGRAM_BINARIES,
                        buffPtrs.length, buffPtrs.ptr, null).clEnforce();
                foreach_reverse(i; 0..sizes.length)
                {//intersperse the lengths, from last to first.
                    buffs[i] = buffPtrs[i][0 .. sizes[i]];
                }
                return buffs;
            }),
        EART!(PROGRAM_NUM_KERNELS, size_t),
        EART!(PROGRAM_KERNEL_NAMES, char[]));

template ProgramBuildInfoEART(alias flag, ReturnT)
{
    auto impl(cl.kernel id, cl.device_id device)
    {
        auto forward(cl.program program, cl.program_build_info param_name,
                size_t param_value_size, void* param_value,
                size_t* param_value_size_ret)
        {
            return cl.getProgramBuildInfo(program, device, param_name,
                    param_value_size, param_value, param_value_size_ret);
        }
        return getInfoGeneric!(ReturnT, forward, flag)(id);
    }
    alias ProgramBuildInfoEART = EART!(flag, ReturnT, impl);
}

alias programBuildInfoEnums = EARTGroup!(getProgramBuildInfo,
        EART!(PROGRAM_BUILD_STATUS, build_status),
        EART!(PROGRAM_BUILD_OPTIONS, char[]),
        EART!(PROGRAM_BUILD_LOG, char[]),
        EART!(PROGRAM_BINARY_TYPE, program_binary_type));

alias kernelInfoEnums = EARTGroup!(getKernelInfo,
        EART!(KERNEL_FUNCTION_NAME, char[]),
        EART!(KERNEL_NUM_ARGS, uint),
        EART!(KERNEL_REFERENCE_COUNT, uint),
        EART!(KERNEL_CONTEXT, context),
        EART!(KERNEL_PROGRAM, program),
        EART!(KERNEL_ATTRIBUTES, char[]));

template KernelArgEART(alias flag, ReturnT)
{
    auto impl(cl.kernel id, cl.uint_ arg_indx)
    {
        auto forward(cl.kernel kernel, cl.kernel_arg_info param_name,
                size_t param_value_size, void* param_value,
                size_t* param_value_size_ret)
        {
            return cl.getKernelArgInfo(kernel, arg_indx, param_name,
                    param_value_size, param_value, param_value_size_ret);
        }
        return getInfoGeneric!(ReturnT, forward, flag)(id);
    }
    alias KernelArgEART = EART!(flag, ReturnT, impl);
}

alias kernelArgInfoEnums = EARTGroup!(getKernelArgInfo,
        KernelArgEART!(KERNEL_ARG_ADDRESS_QUALIFIER, kernel_arg_address_qualifier),
        KernelArgEART!(KERNEL_ARG_ACCESS_QUALIFIER, kernel_arg_access_qualifier),
        KernelArgEART!(KERNEL_ARG_TYPE_NAME, char[]),
        KernelArgEART!(KERNEL_ARG_TYPE_QUALIFIER, kernel_arg_type_qualifier),
        KernelArgEART!(KERNEL_ARG_NAME, char[]));

template KernelWorkGroupEART(alias flag, ReturnT)
{
    auto impl(cl.kernel id, cl.device_id device)
    {
        auto forward(cl.kernel kernel, cl.kernel_work_group_info param_name,
                size_t param_value_size, void* param_value,
                size_t* param_value_size_ret)
        {
            return cl.getKernelWorkGroupInfo(kernel, device, param_name,
                    param_value_size, param_value, param_value_size_ret);
        }
        return getInfoGeneric!(ReturnT, forward, flag)(id);
    }
    alias KernelWorkGroupEART = EART!(flag, ReturnT, impl);
}

alias kernelWorkGroupInfoEnums = EARTGroup!(getKernelWorkGroupInfo,
        KernelWorkGroupEART!(KERNEL_WORK_GROUP_SIZE, size_t),
        KernelWorkGroupEART!(KERNEL_COMPILE_WORK_GROUP_SIZE, size_t[3]),
        KernelWorkGroupEART!(KERNEL_LOCAL_MEM_SIZE, ulong),
        KernelWorkGroupEART!(KERNEL_PREFERRED_WORK_GROUP_SIZE_MULTIPLE, size_t),
        KernelWorkGroupEART!(KERNEL_PRIVATE_MEM_SIZE, ulong),
        KernelWorkGroupEART!(KERNEL_GLOBAL_WORK_SIZE, size_t[3]));

alias eventInfoEnums = EARTGroup!(getEventInfo,
        EART!(EVENT_COMMAND_QUEUE, command_queue),
        EART!(EVENT_COMMAND_TYPE, command_type),
        EART!(EVENT_REFERENCE_COUNT, uint),
        EART!(EVENT_COMMAND_EXECUTION_STATUS, int),
        EART!(EVENT_CONTEXT, context));

alias eventProfilingInfoEnums = EARTGroup!(getEventProfilingInfo,
        EART!(PROFILING_COMMAND_QUEUED, ulong),
        EART!(PROFILING_COMMAND_SUBMIT, ulong),
        EART!(PROFILING_COMMAND_START, ulong),
        EART!(PROFILING_COMMAND_END, ulong));
/+
alias glTextureInfoEnums = EARTGroup!(getGLTextureInfo,
        EART!(GL_TEXTURE_TARGET, GLenum),
        EART!(GL_MIPMAP_LEVEL, GLint),
        EART!(GL_NUM_SAMPLES, GLsizei));

alias glContextInfoEnums = EARTGroup!(getGLContextInfoKHR,
        EART!(CURRENT_DEVICE_FOR_GL_CONTEXT_KHR, device_id),
        EART!(DEVICES_FOR_GL_CONTEXT_KHR, device_id[]));
+/

