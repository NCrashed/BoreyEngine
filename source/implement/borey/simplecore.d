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
import borey.video.window;
import derelict.glfw3.glfw3;
import derelict.util.exception;
import std.conv;
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

        try
        {
            DerelictGLFW3.load();
        } 
        catch(DerelictException e)
        {
            throw new BoreyLoggedException(mLogger, text("Failed to load SimpleBoreyCore: failed to load GLFW3 library. Details: ", e.msg));
        }
        mLogger.logNotice("[Core]: GLFW3 shared library loaded.");

        if (!glfwInit())
        {
            throw new BoreyLoggedException(mLogger, "Failed to initialize GLFW3 library!");
        }
    }

    /**
    *   Get default logger.
    */
    shared(ILogger) logger() @property
    {
        return mLogger;
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

    protected
    {
        IWindow mWindow;
        shared ILogger mLogger;
    }
}

/// TODO: it is not clean, if nobody creates core it fails.
@trusted shared static ~this() 
{
    glfwTerminate();
}