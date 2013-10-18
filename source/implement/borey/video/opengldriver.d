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
module borey.video.opengldriver;
@safe:

import borey.log;
import borey.exception;
import borey.video.driver;
import borey.scene.manager;
import derelict.opengl3.gl3;
import derelict.util.exception;
import std.conv;

/**
*   Video driver based on opengl 3 and greater.
*/
class OpenGlDriver : IVideoDriver
{
    this(shared ILogger logger) @trusted
    {
        mLogger = logger;

        try
        {
            DerelictGL3.load();
        }
        catch(DerelictException e)
        {
            throw new BoreyLoggedException(mLogger, text("Failed to load OpenGlDriver: failed to load OpenGL. Details: ", e.msg));
        }
    }

    /**
    *   Returns information about incapsulated graphical API.
    *   For instance: 'OpenGL 3.2' or 'DirectX 11'.
    */
    string description() const @property @trusted
    {
        return "OpenGL "~to!string(mLoadedVersion);
    }

    /**
    *   Load context and underlying drawing services.
    *   Should be called after first window contex is created.
    */
    void initialize() @trusted
    {
        try
        {
            mLoadedVersion = DerelictGL3.reload();
        }
        catch(DerelictException e)
        {
            throw new BoreyLoggedException(mLogger, text("Failed to initialize OpenGL contex. Details: ", e.msg));
        }

        if(mLoadedVersion < GLVersion.GL33)
            throw new BoreyLoggedException(mLogger, text("OpenGL version too low. Minimum required: ", mLoadedVersion));

        mLogger.logNotice(text("[OpenGlDriver]: OpenGL driver loaded, version: ", mLoadedVersion));
    }

    /**
    *   Performs scene drawing including view frustum culling,
    *   applying different materials and model cashing.
    */
    void draw(shared ISceneManager manager)
    {

    }

    private
    {
        shared ILogger mLogger;
        GLVersion mLoadedVersion;
    }
}