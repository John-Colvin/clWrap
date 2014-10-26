module clWrap.util;

import std.range;

@property auto memSize(R)(R r)
    if(isInputRange!R && hasLength!R)
{
    return r.length * (ElementType!R).sizeof;
}
