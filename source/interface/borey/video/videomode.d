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
*   Module describes structure, holding information about current video mode.
*/
module borey.video.videomode;

/**
*   Struct describing video mode of the monitor. Includes size, color bits
*   and refresh rate of
*/
struct VideoMode
{
    /// The width, in screen coordinates, of the video mode.
    uint width;

    /// The height, in screen coordinates, of the video mode.
    uint height;

    /// The bit depth of the red channel of the video mode.
    uint redBits;

    /// The bit depth of the green channel of the video mode.
    uint greenBits;

    /// The bit depth of the blue channel of the video mode.
    uint blueBits;

    /// The refresh rate, in Hz, of the video mode.
    uint refreshRate;
}