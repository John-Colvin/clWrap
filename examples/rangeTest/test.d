import clwrap, clwrap.ranges;
import mir.ndslice;
import std.range, std.array, std.conv, std.stdio, std.algorithm, std.exception, std.math;

auto myKernel = CLKernelDef!("someKernel",
        CLBuffer!float, "input",
        float, "b")
(q{
    input[gLinId] = input[gLinId] * b;
});

void main()
{
    auto input = iota(40).map!(to!float).array;
    auto output = (new float[40]).sliced(8, 5);

    auto inputBuff = input.sliced(8, 5).toBuffer(cl.MEM_COPY_HOST_PTR);

    auto kern = myKernel.clBuildKernel;
    inputBuff.clMap!kern(2.0f).enqueue;

    inputBuff.clRead(output);
    foreach(elIn, elOut; zip(input.map!"a*2.0f", output.byElement))
        enforce(elIn.approxEqual(elOut));
}

