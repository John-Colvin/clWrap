import clWrap;

import std.range, std.array, std.conv, std.stdio;

auto someKernelDef = CLKernelDef!("someKernel", 2,
        CLBuffer!(float), "input", float, "b")
(q{
    size_t i = get_global_id(0);
    size_t j = get_global_id(1);

    input[i + j] = exp(cos(input[i + j] * b));
});

void main()
{
    writeln(someKernelDef.source);
    auto platform = getChosenPlatform();

    auto devices = platform.getDevices(cl.DEVICE_TYPE_GPU);
    auto context = createContext(devices);
    auto queue = context.createCommandQueue(devices[0]);
    auto kernel = context.createProgram(someKernelDef)
        .buildProgram
        .createKernel!"someKernel";

    auto input = iota(110).array.to!(float[]);

    auto buff = context.newBuffer(cl.MEM_COPY_HOST_PTR, input);

    kernel.setArgs(buff, 1.4f);
    queue.enqueueCLKernel(kernel, [100UL, 10UL]);

    auto output = new float[](110);
    queue.read(buff, output, Yes.Blocking);

    writeln(output);
}
