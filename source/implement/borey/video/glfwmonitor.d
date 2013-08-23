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
*   Realization of borey.video.IMonitor using GLFW3 library.
*/
module borey.video.glfwmonitor;

import borey.log;
import borey.exception;
import borey.video.monitor;
import borey.video.gammaramp;
import borey.video.videomode;
import borey.util.common;
import borey.util.vector;
import derelict.glfw3.glfw3;
import std.algorithm;
import std.range;
import std.conv;

/**
*   Realization of borey.video.IMonitor using GLFW3 library.
*/
class GLFW3Monitor : IMonitor
{
    /// Wraps GLFW3 monitor
    this(GLFWmonitor* monitor, shared ILogger logger)
    {
        assert(monitor !is null, "Critical error! Monitor passed to be wrapped is null!");

        this.monitor = monitor;
        this.logger = logger;
    }

    invariant()
    {
        assert(!!monitor);
        assert(!!logger);
    }

    /**
    *   Returns human readable monitor name.
    */
    string name() const @property @trusted
    {
        return glfwGetMonitorName(cast(GLFWmonitor*)monitor).fromStringz;
    }

    /**
    *   Returns physical size of the monitor.
    */
    vector2du size() const @property @trusted
    {
        int width, height;
        glfwGetMonitorPhysicalSize(cast(GLFWmonitor*)monitor, &width, &height);
        return vector2du(cast(uint)width, cast(uint)height);
    }

    /**
    *   Returns screen position, in screen coordinates, of the upper-left corner of the specified monitor.
    */
    vector2di position() const @property @trusted
    {
        int xpos, ypos;
        glfwGetMonitorPos(cast(GLFWmonitor*)monitor, &xpos, &ypos);
        return vector2di(xpos, ypos);
    }

    /**
    *   Returns current gamma ramp of the monitor.
    *   Can throw BoreyException if internal error occured.
    */
    GammaRamp gammaRamp() const @property @trusted
    {
        auto ramp = glfwGetGammaRamp(cast(GLFWmonitor*)monitor);
        if(ramp is null)
            throw new BoreyLoggedException(logger, "[GLFW3Monitor]: Failed to get gamma ramp! Monitor name: "~name);

        return GammaRamp(
                ramp.red  [0..cast(size_t)ramp.size].dup,
                ramp.green[0..cast(size_t)ramp.size].dup,
                ramp.blue [0..cast(size_t)ramp.size].dup
            );
    }

    /**
    *   Sets gamma ramp ot the monitor.
    *   Notes: Gamma ramp sizes other than 256 are not supported by all hardware.
    */
    void gammaRamp(GammaRamp ramp) @property @trusted
    {
        if(ramp.length != 256)
            logger.logWarning(text("[GLFW3Monitor]: Gamma ramp sizes other than 256 (passed ",ramp.length,") are not supported by all hardware."));
        
        auto glfwRamp = GLFWgammaramp(
                ramp.red.ptr,
                ramp.green.ptr,
                ramp.blue.ptr,
                cast(uint)ramp.length
            );

        glfwSetGammaRamp(monitor, &glfwRamp);
    }

    /**
    *   Generates a 256-element gamma ramp from the specified exponent and then sets gammaRamp with it.
    */
    void setGamma(float exponent) @property @trusted
    {
        glfwSetGamma(monitor, exponent);
    }

    /**
    *   This function returns the current video mode of the specified monitor. 
    *   If you are using a full screen window, the return value will therefore depend on whether it is focused.
    */
    VideoMode videoMode() const @property @trusted
    {
        auto mode = glfwGetVideoMode(cast(GLFWmonitor*) monitor);
        if(mode is null)
            throw new BoreyLoggedException(logger, "[GLFW3Monitor]: Failed to get monitor video mode! Monitor name: "~name);

        return VideoMode(
                mode.width, mode.height,
                mode.redBits, mode.greenBits, mode.blueBits,
                mode.refreshRate
            );
    }

    /**
    *   Returns a range of available video modes for this monitor.
    */
    InputRange!VideoMode videoModes() const @property @trusted
    {
        int size;
        auto modeArray = glfwGetVideoModes(cast(GLFWmonitor*) monitor, &size);
        if(modeArray is null)
            throw new BoreyLoggedException(logger, "[GLFW3Monitor]: Failed to get monitor video modes list! Monitor name: "~name);
    
        return inputRangeObject(reduce!((acc, mode) => acc ~ VideoMode(
                mode.width, mode.height,
                mode.redBits, mode.greenBits, mode.blueBits,
                mode.refreshRate
            ))(cast(VideoMode[])[], modeArray[0..cast(size_t)size]));
    } 

    /**
    *   Returns underlying pointer to GLFW3 monitor.
    *   Used, for instance, for creating windows.
    */
    GLFWmonitor* pointer() @property
    {
        return monitor;
    }

    /**
    *   Used to find monitor by underlying pointer.
    */
    bool equals(GLFWmonitor* other)
    {
        return monitor == other;
    }

    private
    {
        GLFWmonitor* monitor;
        shared ILogger logger;
    }
}