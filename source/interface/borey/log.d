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
/**
*   Provides interface for logging capacities.
*/
module borey.log;
@safe:

import std.conv;

/**
*   Log levels defines style of the messages.
*   Printing in console can be controled by
*   ILogger.minOutputLevel property.
*/
enum ELOG_LEVEL
{
    NOTICE,
    WARNING,
    DEBUG,
    FATAL,
}

/**
*   Interface for lazy logging. Assumes to be nothrow.
*   Underlying realization should be concurrent safe.
*/
interface ILogger
{
    nothrow synchronized 
    {
        /**
        *   Log file name.
        */
        string name() @property const;

        /**
        *   Full log name.
        */
        string location() @property const;

        /**
        *   Prints message into log. Displaying in the console
        *   controled by minOutputLevel property.
        */
        void log(lazy string message, ELOG_LEVEL level);

        /*
        *   Returns: minimum log level,  will be printed in the console.
        */
        ELOG_LEVEL minOutputLevel() @property;

        /*
        *   Setups minimum log level, 
        */
        void minOutputLevel(ELOG_LEVEL level) @property;
    }

    // wrappers for easy logging
    final nothrow synchronized  @trusted
    {
        /**
        *   Wrapper for handy debug messages.
        *   Warning: main purpose for debug messages, thus it is not lazy.
        */
        void logDebug(ELOG_LEVEL level = ELOG_LEVEL.DEBUG, E...)(E args)
        {
            scope(failure) {}
            log(text(args), level);
        }

        void logNotice(lazy string message)
        {
            log(message, ELOG_LEVEL.NOTICE);
        }

        void logWarning(lazy string message) 
        {
            log(message, ELOG_LEVEL.WARNING);
        }

        void logFatal(lazy string message)
        {
            log(message, ELOG_LEVEL.FATAL);
        }
    }
}