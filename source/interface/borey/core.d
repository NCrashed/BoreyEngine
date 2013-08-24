// Copyright (с) 2013 Gushcha Anton <ncrashed@gmail.com>
/*
*	This file is part of Borey Engine.
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
*   Module provides access to all subsytems of the Borey Engine. This interface
*   should be obtained by programm before using any engine features.
*/
module borey.core;
@safe:

import borey.log;
import borey.video.window;
import borey.video.monitor;
import std.range;

/**
*   Main interface of the Borey Engine. It grands access to all engine
*   subsystems.
*/
interface IBoreyCore
{
    pure nothrow const
    {
        /**
        *   Returns: version of loaded engine.
        */
        string getVersion();

        /**
        *   Returns: copyright notes.
        */
        string copyright() @property;

        /**
        *   Returns: true if core can handle many windows, else false.
        */
        bool supportManyWindows() @property;
    }

    /**
    *   Closes all underlying resources.
    */
    void terminate();

    /**
    *   Get default logger.
    */
    shared(ILogger) logger() @property;

    /**
    *   Range of created windows.
    */
    InputRange!IWindow windows() @property;

    /**
    *   Creates window with specified size (sizex, sizey) and title. If makeCurrent is true,
    *   contex of the window becomes current, and you can draw on it immidiately.
    *   If not null monitor parameter is passed, window will become fullscreen on that monitor.
    *
    *   Warning: Actual size of window may be different especially for fullscreen mode.
    *   Notes: Throws WindowException on errors.
    *   Notes: This realization recreates window on following calls.
    *
    *   Params:
    *   logger = Logger to use,
    *   width = window width, can be adjusted for fullscreen window;
    *   height = window height, can be adjusted for fullscreen window;
    *   tittle = window tittle;
    *   monitor = if not null, window will be fullscreen on this monitor;
    *   resizable = should be window size resizable;
    *   visible = if true, window will be created and showed immidietly;
    *   decorated = if false, window head and control buttons won't be created.
    *
    *   Warning: Window should be created in main thread.
    */
    IWindow createWindow(uint width, uint height, string title, IMonitor monitor = null, bool makeCurrent = true,
        bool resizable = false, bool visible = true, bool decorated = true);

    /**
    *   Drops current drawing context binded to any window.
    *   Used to detach context before destroying windows.
    */
    void clearCurrentContext();

    /**
    *   Gets current binded context or null if none is binded.
    */
    IWindow getCurrentContext();

    /**
    *   Returns main monitor of the pc.
    */
    IMonitor primaryMonitor() @property;

    /**
    *   Returns a range of available monitors.
    */
    InputRange!IMonitor monitors() @property;

    /**
    *   Enum describes events that can be passed to on change delegate.
    *   See_also: OnMonitorChangeDelegate, onMonitorChangeCallback
    */
    enum MONITOR_EVENT
    {
        CONNECTED,
        DISCONNECTED
    }

    /**
    *   Delegate type used by property onMonitorChangeCallback.
    */
    alias void delegate(IMonitor, MONITOR_EVENT) OnMonitorChangeDelegate;

    /**
    *   Setups delegate which will be called when the monitor
    *   disconnected or connected to system.
    */
    void onMonitorChangeCallback(OnMonitorChangeDelegate deleg) @property;

    /**
    *   Returns current delegate for on change events.
    *   See_also: onMonitorChangeCallback(OnMonitorChangeDelegate)
    */
    OnMonitorChangeDelegate onMonitorChangeCallback() const @property;

    /**
    *   Processes only those events that have already been received and then returns immediately. 
    */
    void pollEvents();

    /**
    *   If value is true, event loop in method runEventLoop() should close all windows and return
    *   at next loop iteration.
    */
    void shouldExit(bool value) @property;

    /**
    *   If value is true, event loop in method runEventLoop() should close all windows and return
    *   at next loop iteration.
    */
    bool shouldExit() @property;

    /**
    *   Begins infinite loop of event processing and drawing. Exits when all windows are closed
    *   or shouldExit flag is set to true.
    */
    void runEventLoop();
}