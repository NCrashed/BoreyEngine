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
    *   Get default logger.
    */
    shared(ILogger) logger() @property;

    /**
    *   Range of created windows.
    */
    InputRange!IWindow windows() @property;
}