import clwrap, clwrap.ranges;
import mir.ndslice;
import std.range, std.array, std.conv, std.stdio, std.algorithm;

auto myKernel = CLKernelDef!("someKernel",
        CLBuffer!float, "input",
        float, "b")
(q{
    input[gLinId] = exp(cos(input[gLinId] * b));
});

void main()
{
    auto output = new float[](1000);

    auto input = iota(1000).map!(to!float).array;

    auto inputBuff = input.sliced(100, 10).toBuffer(cl.MEM_COPY_HOST_PTR);

    inputBuff.clMap!myKernel(3.4f).enqueue;

    inputBuff.read(output);
}

