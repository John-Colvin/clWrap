import clWrap, std.stdio, std.algorithm, std.conv, std.array;

int main(string[] args)
{
    if (args.length != 2 || args[1].empty)
    {
        stderr.writeln("Error: please provide platform name");
        return 1;
    }

    auto platform = getChosenPlatform(args[1]);
    auto devices = platform.getDevices(cl.DEVICE_TYPE_GPU);
    devices.map!(getInfo!(cl.DEVICE_NAME))
        .joiner("\n").writeln;

    return 0;
}
