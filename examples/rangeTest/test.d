import clwrap; clwrap.ranges;

import std.range, std.array, std.conv, std.stdio, std.algorithm;

auto someKernelDef = CLKernelDef!("someKernel", 2,
        CLBuffer!float, "input",
        float, "b")
(q{
    input[gLinId] = exp(cos(input[gLinId] * b));
});

void main()
{
    auto output = new float[](1000);

    auto input = iota(1000).map!(to!float).array;

    auto inputBuff = cld.context.newBuffer(cl.MEM_COPY_HOST_PTR, input);
    someKernelDef.clCall(inputBuff, 3.4);
    cld.read(inputBuff, output, Yes.Blocking);
    output.writeln;
/+
    input
        .sliced(100, 10)
        .clBuff(cl.MEM_COPY_HOST_PTR)
        .clMap!(someKernelDef)(1.4f)
        .clCopy(output);

    auto someData = iota(1000).map!(to!float).array;

    auto someBuff = someData
        .clBuff(cl.MEM_READ_ONLY | cl.MEM_COPY_HOST_PTR);

    auto someOtherBuff = clBuff(1000);

    q{
        float b = cos(a0[gI(0)*gS(1) + gI(1)]);
        b *= a2;
        a1[gI(0)*gS(1) + gI(1)] = b;
    }.clCall(someBuff, someOtherBuff, PI);

    clCall!((a0, a1, a2),
    q{
        float b = cos(a0[gI(0)*gS(1) + gI(1)]);
        b *= a2;
        a1[gI(0)*gS(1) + gI(1)] = b
    })(someBuff, someOtherBuff, PI);

    writeln(output.clRead);
+/
}
