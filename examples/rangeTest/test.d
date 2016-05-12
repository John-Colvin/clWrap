import clwrap, clwrap.ranges;
import mir.ndslice;
import std.range, std.array, std.conv, std.stdio, std.algorithm, std.exception, std.math;

auto myKernel = CLKernelDef!("someKernel",
        CLBuffer!float, "input",
        float, "b")
(q{
    input[gLinId] = input[gLinId] * b;
});

void printMatrix(S)(S s)
{
    writefln("[%([%(%5g %)]%|\n %)]", s);
}

void main()
{
    auto input = iota(40).map!(to!float).array;
    auto output = (new float[40]).sliced(8, 5);

    auto inputBuff = input.sliced(8, 5).toBuffer(cl.MEM_COPY_HOST_PTR);

    auto kern = myKernel.clBuildKernel;
    inputBuff.clMap!kern(2.0f).enqueue;

    inputBuff
        .clRead(output)
        .byElement
        .zip(input.map!"a*2.0f")
        .all!(t => approxEqual(t.expand))
        .enforce;

    writeln("read the whole thing\n");
    output.printMatrix;
    writeln();
    output[] = float.nan;

    writeln("read strided 2 along dim 0\n");
    inputBuff.strided!0(2)
        .clRead(output.strided!0(2));
    output.printMatrix;
    writeln();
    output[] = float.nan;

    writeln("read sliced (1,1) to ($,$) then strided 2 along dim 0\n");
    inputBuff[1..$, 1..$].strided!0(2)
        .clRead(output[1 ..$, 1..$].strided!0(2));
    output.printMatrix;
}

