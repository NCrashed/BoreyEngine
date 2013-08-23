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
*   Module provides interface to native monitors.
*/
module borey.video.monitor;
@safe:

import borey.video.gammaramp;
import borey.video.videomode;
import borey.util.vector;
import std.range;

/**
*   Interface to native monitor. Used to setup windows in fullscreen
*   mode.
*/
interface IMonitor
{
    /**
    *   Returns human readable monitor name.
    */
    string name() const @property;

    /**
    *   Returns physical size of the monitor.
    */
    vector2du size() const @property;

    /**
    *   Returns screen position, in screen coordinates, of the upper-left corner of the specified monitor.
    */
    vector2di position() const @property;

    /**
    *   Returns current gamma ramp of the monitor.
    *   Can throw BoreyException if internal error occured.
    */
    GammaRamp gammaRamp() const @property;

    /**
    *   Sets gamma ramp ot the monitor.
    *   Notes: Gamma ramp sizes other than 256 are not supported by all hardware.
    */
    void gammaRamp(GammaRamp ramp) @property;

    /**
    *   Generates a 256-element gamma ramp from the specified exponent and then sets gammaRamp with it.
    */
    void setGamma(float exponent) @property;

    /**
    *   This function returns the current video mode of the specified monitor. 
    *   If you are using a full screen window, the return value will therefore depend on whether it is focused.
    */
    VideoMode videoMode() const @property;

    /**
    *   Returns a range of available video modes for this monitor.
    */
    InputRange!VideoMode videoModes() const @property;
}