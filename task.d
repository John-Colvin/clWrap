module clWrap.task;

import std.typetuple : TT = TypeTuple;
import std.algorithm;
import std.range;
import std.array;

import clWrap.wrap;

//sometimes no need for events that check partial completion for
//pipes, OpenCL 2.0 has pipes built in.

//Ranges to work over are *arguments*, not queueing parameters.
//They could be stored with memory objects for simple cases.
//In some cases they are genuinely seperate from memory though.
//represented by a set of min-max pairs. max CL_DEVICE_MAX_WORK_ITEM_DIMENSIONS
//pairs.
//The generalisation of this is a set of D ranges.

//General case of events

//special cases: openCL kernels, native function.

//what defines something as enqueueable? must define typeList to be called with
// must define number of dimensions it is parallelised over

// currently just represents preperations for a task, doesn't have
// anything to say once you've enqueued it.
struct Task(Queueable, dependencies = DependsOn!())
    if(is(dependencies : DependsOn!X, X ...))
{
    Queueable work;

    alias dependencyTypes = dependencies;

    static if(isNativeFunction!Queueable)
    {
        pragma(msg, "native function");
        alias ArgTypes = ParameterTypeTuple!(work);
    }
    else static if(isCLKernel!Queueable)
    {
        pragma(msg, "cl kernel");
        alias ArgTypes = work.ArgTypes;
    }
    else static assert(false, 
            "Task type \"" ~ Queueable.stringof ~ "\" not supported");

    ArgTypes defaultArgs;

    size_t[2][work.nParallelDims][cl_command_queue] globalRange;
    size_t[work.nParallelDims][cl_command_queue] localSize;
    
    void setArgs(Args...)(Args args)
    {
        defaultArgs = args;
    }
    
    auto instance(cl_command_queue queue)
    {
        return TaskInstance!(typeof(this))(work,
                queue,
                globalRange[queue],
                localSize[queue],
                defaultArgs);
    }

    cl_event[] opCall(Args...)(Args args)
    {
        auto queues = globalRange.keys; //HAVE TO DO BETTER!!!!

        return queues.map!instance.map!enqueue.array;
    }
}

auto task(Queueable, dependencies = DependsOn!())(Queueable queueable)
{
    Task!Queueable t;
    t.work = queueable;
    return t;
}

private template ExtractTypes(Args ...)
{
    static if(Args.length == 0)
        alias ExtractTypes = TT!();
    else
    {
        static if(is(typeof(Args[0])))
            alias T = typeof(Args[0]);
        else
            alias T = Args[0];
        alias ExtractTypes = TT!(T, ExtractTypes!(Args[1..$]));
    }
}

struct DependsOn(Tasks ...)
{
    alias types = ExtractTypes!Tasks;
}

template isNativeFunction(alias F)
{
    enum isNativeFunction = false;
}

template isCLKernel(alias F)
{
    static if(is(F : Kernel!X, X...))
        enum isCLKernel = true;
    else
        enum isCLKernel = false;
}

struct TaskInstance(TaskT)
{
    cl_event[] blockers;

    size_t[2][TaskT.work.nParallelDims] globalRange;
    size_t[TaskT.work.nParallelDims] localSize;

    TaskT.ArgTypes args;

    cl_command_queue queue;

    typeof(TaskT.work) work;

    this(typeof(TaskT.work) work,
            cl_command_queue queue,
            size_t[2][TaskT.work.nParallelDims] globalRange,
            size_t[TaskT.work.nParallelDims] localSize,
            TaskT.ArgTypes args)
    {
        this.work = work;
        this.args = args;
        this.localSize = localSize;
        this.globalRange = globalRange;
        this.queue = queue;
    }

    cl_event opCall()
    {
        return enqueue();
    }

    cl_event opCall(TaskT.ArgTypes args)
    {
        this.args = args;
        return enqueue();
    }

    cl_event enqueue()
    {
        cl_event ev;
        static if(isNativeFunction!(typeof(TaskT.work)))
        {
            static assert(false, "not implemented");
        }
        else static if(isCLKernel!(typeof(TaskT.work)))
        {
            clSetKernelArgs(work, args);
            clEnqueueCLKernel(queue, work,
                    globalRange[].map!"a[1] - a[0]".array,
                    globalRange[].map!"a[0]".array,
                    localSize[],
                    blockers[],
                    &ev);
        }
        else static assert(false, 
                "Task type \"" ~ typeof(queueable).stringof ~ "\" not supported");
        return ev;
    }

    auto dependsOn(cl_event[] events)
    {
        blockers ~= events;
        return this;
    }

    auto dependsOn(cl_event event)
    {
        blockers ~= event;
        return this;
    }
}

//Directed Acyclic Graph
//Can be implicitly created through dependsOn.
//Jobs have to be scheduled in topological order as they can't
//wait for a non-existant event (dummy events???)
//Should be able to do transitive reduction at any point to
//clean it up, then topological sort.

//What levels are required here:

//    default setup for a task: queues, ranges, arguments.

//    inidividual instantiation of a task: override defaults, has an event associated with it
//    and can form a part of the DAG

// The DAG must be creatable on the fly: in the general case it is infinite (e.g. non-terminating
// loop enqueueing work).

// Can find sub-graphs that can treated as a single event. Essentially we have a graph of graphs,
// where the granualarity is decided by what?
// A subgraph can be modeled as a single event iff all inputs are required to start and all
// outputs are simultaneously blocking i.e. nothing that depends on any part of the subgraph can
// start unless all parts of the subgraph are complete

//Dummy events: essentially requires an internal 



//Can't help feeling Haskell would have something lovely for all this....
