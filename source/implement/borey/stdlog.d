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
module borey.stdlog;

import borey.log;
import borey.exception;
import std.stream;
import std.path;
import std.stdio;
import std.file;
import std.conv;
import std.datetime;
import std.traits;

/**
*   Standarg implementation of ILogger interface.
*/
synchronized class CLogger : ILogger
{
    enum DEFAULT_DIR = "./logs";
    enum DEFAULT_EXT = ".log";

    nothrow
    {   
        /**
        *   Log file name.
        */
        string name() const @property @safe
        {
            return mName;
        }

        /**
        *   Full log name.
        */
        string location() const @property @safe
        {
            return mLocation;
        }

        /**
        *   Prints message into log. Displaying in the console
        *   controled by minOutputLevel property.
        */
        void log(lazy string message, ELOG_LEVEL level) const @trusted
        {
            scope(failure) {}

            if(level >= mMinOutputLevel)
                writeln(logsStyles[level]~message);

            try
            {
                auto timeString = Clock.currTime.toISOExtString();
                mLogFile.writeLine(text("[", timeString, "]:", logsStyles[level], message));
            }
            catch(Exception e)
            {
                writeln(logsStyles[ELOG_LEVEL.WARNING], "Failed to write into log ", mLocation);
            }
        }

        /*
        *   Returns: minimum log level,  will be printed in the console.
        */
        ELOG_LEVEL minOutputLevel() const @property @trusted
        {
            return mMinOutputLevel;
        }

        /*
        *   Setups minimum log level, 
        */
        void minOutputLevel(ELOG_LEVEL level) @property @trusted
        {
            mMinOutputLevel = level;
        }
    }

    this(string name, string dir = DEFAULT_DIR) @trusted
    {
        mName = name;
        mLocation = buildNormalizedPath(dir, name~DEFAULT_EXT);
        mMinOutputLevel = ELOG_LEVEL.NOTICE;

        try
        {
            mLogFile = new std.stream.File(mLocation, FileMode.Out);
        } 
        catch(OpenException e)
        {
            throw new BoreyException(text("Failed to create log with name ", mName, " and location ", mLocation, ". Details: ", e.msg));
        }
    }

    ~this()
    {
        close();
    }

    private
    {
        immutable(string) mName;
        immutable(string) mLocation;
        __gshared std.stream.File mLogFile;
        shared ELOG_LEVEL mMinOutputLevel;

        void close()
        {
            mLogFile.close();
        }
    }
}

/// Display styles
private immutable(string[ELOG_LEVEL]) logsStyles;

static this() 
{
    if(!exists(CLogger.DEFAULT_DIR))
    {
        mkdirRecurse(CLogger.DEFAULT_DIR);
    }

    logsStyles = [
        ELOG_LEVEL.NOTICE  :   "Notice: ",
        ELOG_LEVEL.WARNING :   "Warning: ",
        ELOG_LEVEL.DEBUG   :   "Debug: ",
        ELOG_LEVEL.FATAL   :   "FATAL ERROR: "
    ];
}

unittest
{
    import std.regex;
    import std.path;
    import std.file;
    import std.stdio;

    write("Testing log system... ");
    scope(success) writeln("Finished!");
    scope(failure) writeln("Failed!");

    auto logger = new shared CLogger("TestLog");
    logger.log("Notice msg!", ELOG_LEVEL.NOTICE);
    logger.log("Warning msg!", ELOG_LEVEL.WARNING);
    logger.log("Debug msg!", ELOG_LEVEL.DEBUG);
    logger.log("Fatal msg!", ELOG_LEVEL.FATAL);
    logger.close();

    auto f = new std.stdio.File(logger.location, "r");
    // Delete date string before cheking string
    assert(replace(f.readln()[0..$-1], regex(r"[\[][\p{InBasicLatin}]*[\]][:]"), "") == logsStyles[ELOG_LEVEL.NOTICE]~"Notice msg!", "Log notice testing fail!");
    assert(replace(f.readln()[0..$-1], regex(r"[\[][\p{InBasicLatin}]*[\]][:]"), "") == logsStyles[ELOG_LEVEL.WARNING]~"Warning msg!", "Log warning testing fail!");
    assert(replace(f.readln()[0..$-1], regex(r"[\[][\p{InBasicLatin}]*[\]][:]"), "") == logsStyles[ELOG_LEVEL.DEBUG]~"Debug msg!", "Log debug testing fail!");
    assert(replace(f.readln()[0..$-1], regex(r"[\[][\p{InBasicLatin}]*[\]][:]"), "") == logsStyles[ELOG_LEVEL.FATAL]~"Fatal msg!", "Log fatal testing fail!");
    f.close();

    remove(logger.location);
}