module clWrap.clSelect;

import clWrap.wrap;
import std.file;
import std.process;
import std.path : buildPath, dirName;
import std.algorithm;
import std.exception;
import std.typecons;
import std.string;
import std.conv;

immutable string[] configFileNames;
shared static this()
{
    configFileNames = [
        buildPath([getcwd(), "chirpletCLConfig"]),
        buildPath(
                [environment.get("XDG_CONFIG_HOME",
                    buildPath([environment.get("HOME"), ".config"])),
                "chirpletCLConfig"])
    ];
}

    /+
void writeConfig(CLPlatform platform)
{
    auto platName = platform.getInfo!CL_PLATFORM_NAME();
    write(configFileName,
            "{\n    \"platformName\": \"" ~ platName ~ "\"\n}");
}+/
    
auto readConfig(string configFileName = null)
{
    foreach(fileName; [configFileName] ~ configFileNames)
    {
        if(fileName.exists && fileName.isFile)
        {
            auto cText = readText(fileName);
            cText.findSkip(":").enforce();
            cText.findSkip("\"").enforce();
            return cText.until("\"");
        }
    }
    throw new Exception("No config file found");
}

/** Finds first platform that matches the name specified in the
 * config file.
 */
auto getChosenPlatform()
{
    auto name = readConfig().to!string;
    auto platforms = getPlatforms();

    foreach(platform; platforms)
    {
        if(platform.getInfo!CL_PLATFORM_NAME
                .indexOf(name, CaseSensitive.no) != -1)
        {
            return platform;
        }
    }
    throw new Exception("No platform matching \"" ~ name ~ "\" found");
}
