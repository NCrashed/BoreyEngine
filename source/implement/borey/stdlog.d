// Copyright (с) 2013 Gushcha Anton <ncrashed@gmail.com>
/*
* This file is part of Borey Engine.
*
* Boost Software License - Version 1.0 - August 17th, 2003
* 
* Permission is hereby granted, free of charge, to any person or organization
* obtaining a copy of the software and accompanying documentation covered by
* this license (the "Software") to use, reproduce, display, distribute,
* execute, and transmit the Software, and to prepare derivative works of the
* Software, and to permit third-parties to whom the Software is furnished to
* do so, all subject to the following:
* 
* The copyright notices in the Software and this entire statement, including
* the above license grant, this restriction and the following disclaimer,
* must be included in all copies of the Software, in whole or in part, and
* all derivative works of the Software, unless such copies or derivative
* works are solely in the form of machine-executable object code generated by
* a source language processor.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
* SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
* FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
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