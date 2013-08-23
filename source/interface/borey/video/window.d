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
*   Module provides interface to work with natives windows.
*/
module borey.video.window;
@safe:

import borey.exception;
import borey.video.monitor;
import borey.util.vector;

/**
*   Exception class used by IWindow to report about errors.
*/
class WindowException : BoreyException
{
    this(lazy string msg)
    {
        super(msg);
    }
}

/**
*   Represents interface for window.
*/
interface IWindow
{
    /**
    *   Returns current title of the window.
    */
    string title() const @property 
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Setups current title of the window.
    */
    void title(string val) @property
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Returns current size of the window.
    */
    vector2du size() const @property 
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Setups current size of the window.
    */
    void size(vector2du vec) @property
    in
    {
        assert(!isDestroyed());
    }    

    /**
    *   Returns current position of left upper window corner.
    */
    vector2du position() const @property
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Setups current position of left upper windw corner.
    */
    void position(vector2du vec) @property
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   If window is fullscreen.
    */
    bool isFullscreen() const
    in
    {
        assert(!isDestroyed());
    }    

    /**
    *   Returns true if window is resizable
    */
    bool resizable() const @property
    in
    {
        assert(!isDestroyed());
    } 

    /**
    *   Returns true if window visible
    */
    bool visible() const @property
    in
    {
        assert(!isDestroyed());
    } 

    /**
    *   If val is false, hides window, if true shows.
    */
    final void visible(bool val) @property
    in
    {
        assert(!isDestroyed());
    } 
    body    
    {
        if(val)
            show();
        else
            hide();
    }

    /**
    *   Returns true if window created with system head and controls.
    */
    bool decorated() const @property
    in
    {
        assert(!isDestroyed());
    } 

    /**
    *   Returns true if window is minimized/iconified.
    */
    bool minimized() const @property
    in
    {
        assert(!isDestroyed());
    } 

    /**
    *   Returns true if window is currently focused for input.
    */
    bool focused() const @property
    in
    {
        assert(!isDestroyed());
    } 

    /**
    *   Hides window. If window already hided or in fullscreen
    *   mode does nothing.
    */
    void hide()
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Shows window. If window already showed or in fullscreen
    *   mode does nothing.
    */
    void show()
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Minize/Iconify the window. If window already minized, does 
    *   nothing. In fullscreen mode resolution will be temporaly
    *   returned to desctop one.
    */
    void minimize()
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Restores window if it was minimized. If window was in fullscreen
    *   mode, restores original resolution.
    */
    void restore()
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Returns current monitor of the fullscreen window.
    *   If window is not fullscreen, returns null.
    */
    IMonitor monitor() @property 
    in
    {
        assert(!isDestroyed());
    }    

    /**
    *   Returns current monitor of the fullscreen window.
    *   If window is not fullscreen, returns null.
    */
    const(IMonitor) monitor() @property const
    in
    {
        assert(!isDestroyed());
    }  

    /**
    *   Makes window contex current, allowing drawing on
    *   the window surface.
    */
    void setContexCurrent()
    in
    {
        assert(!isDestroyed());
    }    

    /**
    *   Swaps drawing buffers of the window. If vertical synchronization is set, waits
    *   specified interval before swapping.
    *   
    *   See_also: swapInterval(uint count)
    */
    void swapBuffers()
    in
    {
        assert(!isDestroyed());
    }   

    /**
    *   Setups count of refreshes before window buffers should be swapped. Setting to 0
    *   helps to measure performance, setting to 1 and greater to remove glitching or tearing.
    *
    *   Warning: Driver can ignore this call.
    *   Notes: By default vsync disables (interval is zero).
    */
    void swapInterval(uint count) @property
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Returns: actual size of drawing region in window.
    */
    vector2du framebufferSize() const @property 
    in
    {
        assert(!isDestroyed());
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
    void destroy();

    /**
    *   Returns: if window was destroyed by calling 
    *   destroyWindow.
    */
    bool isDestroyed() const;

    /**
    *   Returns true if someone want's to close window,
    *   usefull for gently closing with performing some
    *   terminating actions.
    */
    bool shouldBeClosed() const @property
    in
    {
        assert(!isDestroyed());
    }

    /**
    *   Setups close flag. Setting false can be used
    *   to cancel closing event.
    */
    void shouldBeClosed(bool value) @property
    in
    {
        assert(!isDestroyed());
    }

    /// Called when position changes
    alias void delegate(IWindow window, uint x, uint y) PosChangedDelegate;

    /// Called when size changes
    alias void delegate(IWindow window, uint width, uint height) SizeChangedDelegate;

    /// Called when framebuffer size changes
    alias void delegate(IWindow window, uint width, uint height) FramebufferSizeChangedDelegate;

    /// Called when window refreshed
    alias void delegate(IWindow window) RefreshDelegate;

    /// Called when window is going to be closed
    alias void delegate(IWindow window) CloseDelegate;

    /// Called when window get/loose focus
    alias void delegate(IWindow window, bool focused) FocusChangedDelegate;

    /// Called when window iconfied/restored
    alias void delegate(IWindow window, bool minimized) MinimizedDelegate;

    /**
    *   Setups new delegate to position changing event. Returns old delegate or null.
    */
    PosChangedDelegate posChangedDelegate(PosChangedDelegate newDelegate) @property;

    /**
    *   Returns current delegated for position changing event.
    */
    PosChangedDelegate posChangedDelegate() @property;

    /**
    *   Setups new delegate to window size changing event. Returns old delegate or null.
    */
    SizeChangedDelegate sizeChangedDelegate(SizeChangedDelegate newDelegate) @property;

    /**
    *   Returns current delegated for window size changing event.
    */
    SizeChangedDelegate sizeChangedDelegate() @property;

    /**
    *   Setups new delegate to framebuffer size changing event. Returns old delegate or null.
    */
    FramebufferSizeChangedDelegate framebufferSizeChangedDelegate(FramebufferSizeChangedDelegate newDelegate) @property;

    /**
    *   Returns current delegated for framebuffer size changing event.
    */
    FramebufferSizeChangedDelegate framebufferSizeChangedDelegate() @property;   

    /**
    *   Setups new delegate to window refreshing event. Returns old delegate or null.
    */
    RefreshDelegate refreshDelegate(RefreshDelegate newDelegate) @property;

    /**
    *   Returns current delegated for window refreshing event.
    */
    RefreshDelegate refreshDelegate() @property;

    /**
    *   Setups new delegate to window closing event. Returns old delegate or null.
    */
    CloseDelegate closeDelegate(CloseDelegate newDelegate) @property;

    /**
    *   Returns current delegated for window closing event.
    */
    CloseDelegate closeDelegate() @property;

    /**
    *   Setups new delegate to window focusing changing event. Returns old delegate or null.
    */
    FocusChangedDelegate focusChangedDelegate(FocusChangedDelegate newDelegate) @property;

    /**
    *   Returns current delegated for window focusing changing event.
    */
    FocusChangedDelegate focusChangedDelegate() @property;

    /**
    *   Setups new delegate to window iconify/restore event. Returns old delegate or null.
    */
    MinimizedDelegate minimizedDelegate(MinimizedDelegate newDelegate) @property;

    /**
    *   Returns current delegated for window iconify/restore changing event.
    */
    MinimizedDelegate minimizedDelegate() @property;
}