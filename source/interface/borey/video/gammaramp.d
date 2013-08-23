// Copyright (с) 2013 Gushcha Anton <ncrashed@gmail.com>
/*
*   This file is part of Borey Engine.
*
*    Borey Engine is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    Borey Engine is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with Borey Engine.  If not, see <http://www.gnu.org/licenses/>.
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