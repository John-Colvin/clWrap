import clWrap, std.stdio, std.algorithm, std.conv, std.array;

void main(string[] args)
{
    if (args.length != 2 || args[1].empty)
        stderr.writeln("Error: please provide platform name");

    auto platform = getChosenPlatform(args[1]);
    auto devices = platform.getDevices(cl.DEVICE_TYPE_GPU);
    devices.map!(getInfo!(cl.DEVICE_NAME))
        .joiner("\n").writeln;
}
