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
*   Realization of IWindow with GLFW3 library.
*/
module borey.video.glfwwindow;
@safe:

import borey.exception;
import borey.log;
import borey.video.window;
import borey.video.monitor;
import borey.video.glfwmonitor;
import borey.util.vector;
import derelict.glfw3.glfw3;
import derelict.opengl3.constants : GL_TRUE;
import std.string;

class GLFW3Window : IWindow
{
    /**
    *   Creates underlying GLFW3 window with size (width, height) and tittle.
    *   If monitor set to null, windowed mode window will be created, else
    *   window will be fullscreen at that monitor.
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
    this(shared ILogger logger, uint width, uint height, string tittle, GLFW3Monitor monitor = null, 
        bool resizable = false, bool visible = true, bool decorated = true) @trusted
    {
        this.logger = logger;
        this.winMonitor = monitor;

        logger.logNotice("!");

        glfwDefaultWindowHints();
        glfwWindowHint(GLFW_RESIZABLE,  resizable);
        glfwWindowHint(GLFW_VISIBLE,    visible);
        glfwWindowHint(GLFW_DECORATED,  decorated);

        logger.logNotice("!!");
        this.window = glfwCreateWindow(width, height, tittle.toStringz, monitor is null ? null : monitor.pointer, null);
        if(this.window is null)
        {
            throw new WindowException("[GLFW3Window]: Failed to create underlying glfw3 window!");
        }

        logger.logNotice("!");
    }

    invariant()
    {
        if(!destroyed)
        {
            assert(!!window);
            assert(!!logger);
        }
    }

    /**
    *   Returns current title of the window.
    */
    string title() @property const   
    {
        return mTitle;
    }

    /**
    *   Setups current title of the window.
    */
    void title(string val) @property @trusted
    {
        mTitle = val;
        glfwSetWindowTitle(window, val.toStringz);
    }

    /**
    *   Returns current size of the window.
    */
    vector2du size() @property const @trusted
    {
        int width, height;
        glfwGetWindowSize(cast(GLFWwindow*) window, &width, &height);

        return vector2du(cast(uint)width, cast(uint)height);
    }

    /**
    *   Setups current size of the window.
    */
    void size(vector2du vec) @property @trusted  
    {
        glfwSetWindowSize(cast(GLFWwindow*) window, vec.x, vec.y);
    }

    /**
    *   Returns current position of left upper window corner.
    */
    vector2du position() const @property @trusted
    {
        int x, y;
        glfwGetWindowPos(cast(GLFWwindow*) window, &x, &y);
        return vector2du(cast(uint)x, cast(uint)y);
    }

    /**
    *   Setups current position of left upper windw corner.
    */
    void position(vector2du vec) @property @trusted
    {
        glfwSetWindowPos(cast(GLFWwindow*) window, vec.x, vec.y);
    }

    /**
    *   If window is fullscreen.
    */
    bool isFullscreen() const @trusted
    {
        return glfwGetWindowMonitor(cast(GLFWwindow* )window) !is null;
    }

    /**
    *   Returns true if window is resizable
    */
    bool resizable() const @property @trusted
    {
        return glfwGetWindowAttrib(cast(GLFWwindow* )window, GLFW_RESIZABLE) != 0;
    }

    /**
    *   Returns true if window visible
    */
    bool visible() const @property @trusted
    {
        return glfwGetWindowAttrib(cast(GLFWwindow* )window, GLFW_VISIBLE) != 0;
    }

    /**
    *   Returns true if window created with system head and controls.
    */
    bool decorated() const @property @trusted
    {
        return glfwGetWindowAttrib(cast(GLFWwindow* )window, GLFW_DECORATED) != 0;
    }

    /**
    *   Returns true if window is minimized/iconified.
    */
    bool minimized() const @property @trusted
    {
        return glfwGetWindowAttrib(cast(GLFWwindow* )window, GLFW_ICONIFIED) != 0;
    }

    /**
    *   Returns true if window is currently focused for input.
    */
    bool focused() const @property @trusted
    {
        return glfwGetWindowAttrib(cast(GLFWwindow* )window, GLFW_FOCUSED) != 0;
    }

    /**
    *   Returns current monitor of the fullscreen window.
    *   If window is not fullscreen, returns null.
    */
    const(IMonitor) monitor() @property const   
    {   
        return winMonitor;
    }

    /**
    *   Returns current monitor of the fullscreen window.
    *   If window is not fullscreen, returns null.
    */
    IMonitor monitor() @property
    {   
        return winMonitor;
    }

    /**
    *   Hides window. If window already hided or in fullscreen
    *   mode does nothing.
    */
    void hide() @trusted
    { 
        glfwHideWindow(window);
    }

    /**
    *   Shows window. If window already showed or in fullscreen
    *   mode does nothing.
    */
    void show() @trusted
    {
        glfwShowWindow(window);
    }

    /**
    *   Minize/Iconify the window. If window already minized, does 
    *   nothing. In fullscreen mode resolution will be temporaly
    *   returned to desctop one.
    */
    void minimize() @trusted
    {
        glfwIconifyWindow(window);
    }

    /**
    *   Restores window if it was minimized. If window was in fullscreen
    *   mode, restores original resolution.
    */
    void restore() @trusted
    {
        glfwRestoreWindow(window);
    }

    /**
    *   Makes window contex current, allowing drawing on
    *   the window surface.
    */
    void setContexCurrent() @trusted
    {
        glfwMakeContextCurrent(window);
        glfwSwapInterval(mSwapInterval);
    }

    /**
    *   Swaps drawing buffers of the window. If vertical schynronization is set, waits
    *   specified interval before swapping.
    *   
    *   See_also: IBoreyCore.swapInterval(uint count)
    */
    void swapBuffers() @trusted
    {
        glfwSwapBuffers(window);
    }

    /**
    *   Setups count of refreshes before window buffers should be swapped. Setting to 0
    *   helps to measure performance, setting to 1 and greater to remove glitching or tearing.
    *
    *   Warning: Driver can ignore this call.
    */
    void swapInterval(uint count)
    {
        mSwapInterval = count;
    }

    /**
    *   Returns: actual size in pixels of drawing region in window.
    */
    vector2du framebufferSize() const @property @trusted
    {
        int width, height;
        glfwGetFramebufferSize(cast(GLFWwindow*) window, &width, &height);
        return vector2du(cast(uint)width, cast(uint)height);
    }

    /**
    *   Destroys underlying native window.
    *   After this call all other methods will 
    *   throw assert errors in debug version and
    *   return default values in release.
    *
    *   Warning: Drawing context of window shouldn't
    *   be current in none main threads.
    */
    void destroy() @trusted
    {
        glfwDestroyWindow(window);
        winMonitor = null;
        mTitle = "";
        destroyed = true;
    }

    /**
    *   Returns: if window was destroyed by calling 
    *   destroyWindow.
    */
    bool isDestroyed() const
    {
        return destroyed;
    }

    /**
    *   Returns true if someone want's to close window,
    *   usefull for gently closing with performing some
    *   terminating actions.
    */
    bool shouldBeClosed() const @property @trusted
    {
        return glfwWindowShouldClose(cast(GLFWwindow*) window) != 0;
    }

    /**
    *   Setups close flag. Setting false can be used
    *   to cancel closing event.
    */
    void shouldBeClosed(bool value) @property @trusted
    {
        glfwSetWindowShouldClose(window, value);
    }

    /**
    *   Checks if underlying pointer equals other.
    */
    bool equals(GLFWwindow* other)
    {
        return window == other;
    }

    /**
    *   Returns inner pointer.
    */
    GLFWwindow* pointer() @property
    {
        return window;
    }

    /**
    *   Setups new delegate to position changing event. Returns old delegate or null.
    */
    PosChangedDelegate posChangedDelegate(PosChangedDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr, int x, int y)
        {
            try 
            {
                if(!!mPosChangedDelegate)
                    mPosChangedDelegate(mCallbackWindowMap[ptr], cast(uint)x, cast(uint)y);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }
        }

        mCallbackWindowMap[window] = this;

        auto old = mPosChangedDelegate;
        mPosChangedDelegate = newDelegate;
        glfwSetWindowPosCallback(window, cast(GLFWwindowposfun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for position changing event.
    */
    PosChangedDelegate posChangedDelegate() @property @trusted
    {
        return mPosChangedDelegate;
    }

    /**
    *   Setups new delegate to window size changing event. Returns old delegate or null.
    */
    SizeChangedDelegate sizeChangedDelegate(SizeChangedDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr, int width, int height)
        {
            try
            {
                if(!!mSizeChangedDelegate)
                    mSizeChangedDelegate(mCallbackWindowMap[ptr], cast(uint)width, cast(uint)height);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }            
        }

        mCallbackWindowMap[window] = this;

        auto old = mSizeChangedDelegate;
        mSizeChangedDelegate = newDelegate;
        glfwSetWindowSizeCallback(window, cast(GLFWwindowsizefun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for window size changing event.
    */
    SizeChangedDelegate sizeChangedDelegate() @property @trusted
    {
        return mSizeChangedDelegate;
    }

    /**
    *   Setups new delegate to framebuffer size changing event. Returns old delegate or null.
    */
    FramebufferSizeChangedDelegate framebufferSizeChangedDelegate(
            FramebufferSizeChangedDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr, int width, int height)
        {
            try
            {
                if(!!mFramebufferSizeChangedDelegate)
                    mFramebufferSizeChangedDelegate(mCallbackWindowMap[ptr], cast(uint)width, cast(uint)height);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }            
        }

        mCallbackWindowMap[window] = this;
        
        auto old = mFramebufferSizeChangedDelegate;
        mFramebufferSizeChangedDelegate = newDelegate;
        glfwSetFramebufferSizeCallback(window, cast(GLFWframebuffersizefun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for framebuffer size changing event.
    */
    FramebufferSizeChangedDelegate framebufferSizeChangedDelegate() @property @trusted
    {
        return mFramebufferSizeChangedDelegate;
    }

    /**
    *   Setups new delegate to window refreshing event. Returns old delegate or null.
    */
    RefreshDelegate refreshDelegate(RefreshDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr)
        {
            try
            {
                if(!!mRefreshDelegate)
                    mRefreshDelegate(mCallbackWindowMap[ptr]);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }            
        }

        mCallbackWindowMap[window] = this;
        
        auto old = mRefreshDelegate;
        mRefreshDelegate = newDelegate;
        glfwSetWindowRefreshCallback(window, cast(GLFWwindowrefreshfun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for window refreshing event.
    */
    RefreshDelegate refreshDelegate() @property @trusted
    {
        return mRefreshDelegate;
    }

    /**
    *   Setups new delegate to window closing event. Returns old delegate or null.
    */
    CloseDelegate closeDelegate(CloseDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr)
        {
            try
            {
                if(!!mCloseDelegate)
                    mCloseDelegate(mCallbackWindowMap[ptr]);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }            
        }

        mCallbackWindowMap[window] = this;
        
        auto old = mCloseDelegate;
        mCloseDelegate = newDelegate;
        glfwSetWindowCloseCallback(window, cast(GLFWwindowclosefun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for window closing event.
    */
    CloseDelegate closeDelegate() @property @trusted
    {
        return mCloseDelegate;
    }

    /**
    *   Setups new delegate to window focusing changing event. Returns old delegate or null.
    */
    FocusChangedDelegate focusChangedDelegate(FocusChangedDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr, int flag)
        {
            try
            {
                if(!!mFocusCangedDelegate)
                    mFocusCangedDelegate(mCallbackWindowMap[ptr], flag == GL_TRUE ? true : false);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }            
        }

        mCallbackWindowMap[window] = this;
        
        auto old = mFocusCangedDelegate;
        mFocusCangedDelegate = newDelegate;
        glfwSetWindowFocusCallback(window, cast(GLFWwindowfocusfun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for window focusing changing event.
    */
    FocusChangedDelegate focusChangedDelegate() @property @trusted
    {
        return mFocusCangedDelegate;
    }

    /**
    *   Setups new delegate to window iconify/restore event. Returns old delegate or null.
    */
    MinimizedDelegate minimizedDelegate(MinimizedDelegate newDelegate) @property @trusted
    {
        extern(C) void callback(GLFWwindow* ptr, int flag)
        {
            try
            {
                if(!!mFocusCangedDelegate)
                    mFocusCangedDelegate(mCallbackWindowMap[ptr], flag == GL_TRUE ? true : false);
            }
            catch(Throwable th)
            {
                // Save a new CallbackThrowable that wraps t and chains _rethrow.
                CallbackThrowable.storeCallbackThrowable(th);
            }            
        }

        mCallbackWindowMap[window] = this;
        
        auto old = mFocusCangedDelegate;
        mFocusCangedDelegate = newDelegate;
        glfwSetWindowIconifyCallback(window, cast(GLFWwindowiconifyfun)&callback);
        return old;
    }

    /**
    *   Returns current delegated for window iconify/restore changing event.
    */
    MinimizedDelegate minimizedDelegate() @property @trusted
    {
        return mMinimizedDelegate;
    }

    private
    {
        GLFWwindow* window;
        IMonitor    winMonitor;
        shared ILogger logger;
        bool destroyed = false;
        uint mSwapInterval;
        string mTitle;

        __gshared
        {
            PosChangedDelegate mPosChangedDelegate;
            SizeChangedDelegate mSizeChangedDelegate;
            FramebufferSizeChangedDelegate mFramebufferSizeChangedDelegate;
            RefreshDelegate mRefreshDelegate;
            CloseDelegate mCloseDelegate;
            FocusChangedDelegate mFocusCangedDelegate;
            MinimizedDelegate mMinimizedDelegate;

            // to retrieve from C callbacks
            static IWindow[GLFWwindow*] mCallbackWindowMap;
        }
    }
}