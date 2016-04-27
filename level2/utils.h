
#ifndef CLWRAP_UTILS_H
#define CLWRAP_UTILS_H

// bunch of useful aliases for writing neater looking code

#define ND get_work_dim()

#define gId get_global_id
#define lId get_local_id

#define gN get_global_size
#define lN get_local_size

#define gI gId(0)
#define gJ gId(1)
#define gK gId(2)
#define gL gId(3)

#define lI lId(0)
#define lJ lId(1)
#define lK lId(2)
#define lL lId(3)

#if __OPENCL_C_VERSION__ >= 200

#define gLinId get_global_linear_id()
#define lLinId get_local_linear_id()

#else

#define LINIDIMPL(LG)                \
size_t LG##LinIdImpl(void);          \
size_t LG##LinIdImpl(void)           \
{                                    \
    size_t idx = LG##Id(ND-1);       \
    size_t stride = LG##N(ND-1);     \
    for (int i = ND-2; i >= 0; --i)  \
    {                                \
        idx += LG##Id(i) * stride;   \
        stride *= LG##N(i+1);        \
    }                                \
    return idx;                      \
}

LINIDIMPL(g)
LINIDIMPL(l)

#define gLinId gLinIdImpl()
#define lLinId lLinIdImpl()

#endif

// end of the include guard
#endif
