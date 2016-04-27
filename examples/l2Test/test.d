import clWrap;

import std.range, std.array, std.conv, std.stdio, std.algorithm;

auto someKernelDef = CLKernelDef!("someKernel", 2,
        CLBuffer!(float), "input", float, "b")
(q{
    input[gLinId] = exp(cos(input[gLinId] * b));
});

void main()
{
    auto platform = getChosenPlatform();

    auto devices = platform.getDevices(cl.DEVICE_TYPE_GPU);
    auto context = createContext(devices);
    auto queue = context.createCommandQueue(devices[0]);
    auto kernel = context.createProgram(someKernelDef)
        .buildProgram
        .createKernel!"someKernel";

    auto input = iota(90).map!(to!float).array;

    auto buff = context.newBuffer(cl.MEM_COPY_HOST_PTR, input);

    kernel.setArgs(buff, 1.4f);
    queue.enqueueCLKernel(kernel, [10UL, 9UL]);

    auto output = new float[](90);
    queue.read(buff, output, Yes.Blocking);

    writeln(output);
}
