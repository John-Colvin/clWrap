module clwrap.l2.util;

import std.range;

//deal with arrays seperately, in part to avoid any
//narrow-string idiocy
@property auto memSize(R)(R r)
    if (is(R : T[], T))
{
    static if (is(R : T[], T))
        return r.length * T.sizeof;
    else
        static assert(false);
}

@property auto memSize(R)(R r)
    if(isInputRange!R && hasLength!R && !is(R : T[], T))
{
    return r.length * (ElementType!R).sizeof;
}
