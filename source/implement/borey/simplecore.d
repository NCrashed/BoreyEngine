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
*   Standart realization of borey.core.IBoreyCore interface. It has only one
*   window and cannot handle multiple ones.
*/
module borey.simplecore;
@safe:

import borey.core;
import borey.exception;
import borey.constants;
import borey.log;
import borey.stdlog;
import borey.video.driver;
import borey.video.opengldriver;
import borey.video.window;
import borey.video.glfwwindow;
import borey.video.monitor;
import borey.video.glfwmonitor;
import borey.scene.manager;
import borey.scene.simplemanager;
import borey.resource.manager;
import borey.resource.simplemanager;
import borey.util.common;
import derelict.glfw3.glfw3;
import derelict.util.exception;
import std.algorithm;
import std.conv;
import std.string;
import std.range;
import core.time;

/**
*   The simpliest realization of IBoreyCore, which can handle only one
*   window at the time. Based on GLFW3 library.
*
*   TODO: add check to trying initialize multiple cores!
*/
class SimpleBoreyCore : IBoreyCore
{
    enum GENERAL_LOG_NAME = "general";

    pure nothrow const
    {
        /**
        *   Returns: version of loaded engine.
        */
        string getVersion()
        {
            return BOREY_ENGINE_VERSION;
        }

        /**
        *   Returns: copyright notes.
        */
        string copyright() @property
        {
            return COPYRIGHT_NOTICE;
        }

        /**
        *   Returns: true if core can handle many windows, else false.
        */
        bool supportManyWindows() @property
        {
            return false;
        }
    }

    this() @trusted
    {
        mLogger = new shared CLogger(GENERAL_LOG_NAME);
        staticThis = this;

        try
        {
            DerelictGLFW3.load();
        } 
        catch(DerelictException e)
        {
            throw new BoreyLoggedException(mLogger, text("Failed to load SimpleBoreyCore: failed to load GLFW3 library. Details: ", e.msg));
        }
        mLogger.logNotice("[SimpleCore]: GLFW3 shared library loaded.");

        glfwSetErrorCallback(cast(GLFWerrorfun)(&glfw3_error_callback));
        if (!glfwInit())
        {
            throw new BoreyLoggedException(mLogger, "Failed to initialize GLFW3 library!");
        }
        mLogger.logNotice("[SimpleCore]: GLFW3 library initialized.");

        mVideoDriver = new OpenGlDriver(mLogger);
        mResourceManager = new shared SimpleResourceManager(mLogger);
        mResourceManager.registerDefaultPacks();
        mSceneManager = new shared SimpleSceneManager(mLogger);
    }

    void terminate()
    {
        if(mWindow !is null)
            mWindow.destroy();
        mWindow = null;
    }

    /**
    *   Get default logger.
    */
    shared(ILogger) logger() @property
    {
        return mLogger;
    }

    /**
    *   Returns current resource manager.
    */
    shared(IResourceManager) resourceManager() @property
    {
        return mResourceManager;
    }

    /**
    *   Range of created windows.
    */
    InputRange!IWindow windows() @property @trusted
    {
        if(mWindow !is null)
            return mWindow.only.inputRangeObject();
        else
            return takeNone!(IWindow[])().inputRangeObject();
    }

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
        bool resizable = false, bool visible = true, bool decorated = true)
    {
        if(mWindow !is null)
        {
            clearCurrentContext();
            mWindow.destroy();
            mWindow = null;
        }

        mWindow = new GLFW3Window(mLogger, width, height, title, cast(GLFW3Monitor)monitor, resizable, visible, decorated);

        if(makeCurrent)
        {
            mWindow.setContexCurrent();
        }
        mVideoDriver.initialize();
        
        return mWindow;
    }

    /**
    *   Drops current drawing context binded to any window.
    *   Used to detach context before destroying windows.
    */
    void clearCurrentContext() @trusted
    {
        glfwMakeContextCurrent(null);
    }

    /**
    *   Gets current binded context or null if none is binded.
    */
    IWindow getCurrentContext() @trusted
    {
        auto ptr = glfwGetCurrentContext();
        if(ptr !is null)
        {
            if(mWindow.isDestroyed()) // logic error
            {
                debug 
                {
                    assert(false, "Binded context of destroyed window!");    
                } else
                {
                    clearCurrentContext();
                    return null;
                }
            }

            return mWindow;
        }
        return null;
    }

    /**
    *   Returns main monitor of the pc.
    */
    IMonitor primaryMonitor() @property @trusted
    {
        auto monptr = glfwGetPrimaryMonitor();
        if(monptr is null)
            throw new BoreyLoggedException(mLogger, "[SimpleCore]: Failed to get primary monitor!");

        return new GLFW3Monitor(monptr, mLogger);
    }

    /**
    *   Returns a range of available monitors.
    */
    InputRange!IMonitor monitors() @property @trusted
    {
        int size;
        auto monArray = glfwGetMonitors(&size);
        if(monArray is null)
            throw new BoreyLoggedException(mLogger, "[SimpleCore]: Failed to get monitors list!");

        return reduce!((acc, monitor) => acc ~ new GLFW3Monitor(monitor, mLogger))
            (cast(IMonitor[])[], monArray[0..cast(size_t)size]).inputRangeObject();
    }

    /**
    *   Returns inner implementation list of monitors. For implementation use purpose.
    */
    protected auto innerMonitors() @property @trusted
    {
        int size;
        auto monArray = glfwGetMonitors(&size);
        if(monArray is null)
            throw new BoreyLoggedException(mLogger, "[SimpleCore]: Failed to get monitors list!");

        return reduce!((acc, monitor) => acc ~ new GLFW3Monitor(monitor, mLogger))
            (cast(GLFW3Monitor[])[], monArray[0..cast(size_t)size]);
    }

    /**
    *   Setups delegate which will be called when a monitor
    *   disconnected or connected to system.
    */
    void onMonitorChangeCallback(OnMonitorChangeDelegate deleg) @property @trusted
    {
        if(deleg is null)
        {
            currDeleg = null;
            glfwSetMonitorCallback(null);
            return;
        }

        currDeleg = deleg;

        // Callaback passed to glfw3 library
        extern(C) void callback(GLFWmonitor* monptr, int event)
        {
            assert(!!staticThis.currDeleg);
            MONITOR_EVENT tempEvent;

            if(event == GLFW_CONNECTED)
                tempEvent = MONITOR_EVENT.CONNECTED;
            else if(event == GLFW_DISCONNECTED)
                tempEvent = MONITOR_EVENT.DISCONNECTED;
            else
                return;

            auto findRes = find!"a.equals(b)"(staticThis.innerMonitors, monptr);
            if(findRes.empty) 
            {
                staticThis.mLogger.logWarning("[SimpleCore]: Received monitor change event for unlisted monitor!");
                return;
            }

            staticThis.currDeleg(findRes.front, tempEvent);
        }

        glfwSetMonitorCallback(cast(GLFWmonitorfun)&callback);
    }

    /**
    *   Processes only those events that have already been received and then returns immediately. 
    */
    void pollEvents() @trusted
    {
        glfwPollEvents();
        // rethrow all generated exceptions in callbacks
        CallbackThrowable.rethrowCallbackThrowables();
    }

    /**
    *   If value is true, event loop in method runEventLoop() should close all windows and return
    *   at next loop iteration.
    */
    void shouldExit(bool value) @property
    {
        mShouldExit = value;
    }

    /**
    *   If value is true, event loop in method runEventLoop() should close all windows and return
    *   at next loop iteration.
    */
    bool shouldExit() @property
    {
        return mShouldExit;
    }

    /**
    *   Begins infinite loop of event processing and drawing. Exits when all windows are closed
    *   or shouldExit flag is set to true.
    */
    void runEventLoop()
    {
        while(!mWindow.shouldBeClosed && !shouldExit)
        {
            mVideoDriver.draw(mSceneManager);
            mWindow.swapBuffers();
            pollEvents();
        }

        if(mWindow.closeDelegate !is null)
            mWindow.closeDelegate()(mWindow);
    }

    IVideoDriver videoDriver() @property
    {
        return mVideoDriver;
    }

    shared(ISceneManager) sceneManager() @property
    {
        return mSceneManager;
    }
    
    /**
    *   Returns current delegate for on change events.
    *   See_also: onMonitorChangeCallback(OnMonitorChangeDelegate)
    */
    OnMonitorChangeDelegate onMonitorChangeCallback() const @property
    {
        return currDeleg;
    }

    protected
    {
        IWindow mWindow;
        IVideoDriver mVideoDriver;
        shared ISceneManager mSceneManager;
        shared SimpleResourceManager mResourceManager;
        static shared ILogger mLogger;
        bool mShouldExit = false;
    }
    private
    {
        OnMonitorChangeDelegate currDeleg;
        static SimpleBoreyCore staticThis; // For callbacks
    }

    private static extern(C) void glfw3_error_callback(int error, const char* message) nothrow @trusted
    {
        mLogger.logWarning(text("[GLFW3]: ", message.fromStringz));
    }
}

/// TODO: it is not clean, if nobody creates core it fails.
@trusted shared static ~this() 
{
    glfwTerminate();
}