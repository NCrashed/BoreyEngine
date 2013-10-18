// Copyright (с) 2013 Gushcha Anton <ncrashed@gmail.com>
/*
* This file is part of Borey Engine.
*
* Boost Software License - Version 1.0 - August 17th, 2003
* 
* Permission is hereby granted, free of charge, to any person or organization
* obtaining a copy of the software and accompanying documentation covered by
* this license (the "Software") to use, reproduce, display, distribute,
* execute, and transmit the Software, and to prepare derivative works of the
* Software, and to permit third-parties to whom the Software is furnished to
* do so, all subject to the following:
* 
* The copyright notices in the Software and this entire statement, including
* the above license grant, this restriction and the following disclaimer,
* must be included in all copies of the Software, in whole or in part, and
* all derivative works of the Software, unless such copies or derivative
* works are solely in the form of machine-executable object code generated by
* a source language processor.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
* SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
* FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
*/
// This file is written in D programming language
/**
*   Describes structure handling video gamma ramp of a monitor.
*/
module borey.video.gammaramp;
@safe:

/**
*   Represents gamma ramp of a monitor.
*/
struct GammaRamp 
{
    ushort[] red;
    ushort[] green;
    ushort[] blue;

    invariant() 
    {
        assert(red.length == green.length);
        assert(red.length == blue.length);
        assert(green.length == blue.length);
    }

    this(this)
    {
        red = red.dup;
        green = green.dup;
        blue = blue.dup;
    }

    /**
    *   All arrays (red, green, blue) have same length,
    *   this method provides their length without accessing
    *   to them.
    */
    size_t length() const @property
    {
        return red.length;
    }
}