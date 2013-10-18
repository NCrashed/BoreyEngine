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
module borey.resource.filesystem;

import borey.exception;
import borey.log;
import borey.resource.archive;
import borey.resource.pack;
import std.range;
import std.algorithm;
import std.container;
import std.stream;
import std.conv;
import std.file;
import std.path;

/**
*   Archive based on filesystem directory hierarchy.
*   No compressing, the simpliest archive type.
*/
class FileSystemArchive : IArchive
{
    /**
    *   Creates archive from logger and archive root path.
    */
    this(shared ILogger logger, string name)
    {
        mName = name.absolutePath;
        mLogger = logger;

        if(exists(name) && isFile(name))
            throw new ArchiveLoadingException(logger, name, "tried to replace file with same name.");
        else if(!exists(name))
            mkdirRecurse(name);
    }

    /// Returns name of archive
    /**
    *   Name of files system archive is path to root folder.
    */
    string name() const @property
    {
        return mName;
    }

    /// Returns true if archive can read resources
    bool readable() const @property
    {
        return true; /// TODO: add manual check
    }

    /// Returns true if archive can write resources
    bool writeable() const @property
    {
        return true; /// TODO: add manual check
    }

    /**
    *   Returns range of available files in archive.
    *
    *   Params:
    *   prefix = path to find from, if specified path is not
    *           exists in archive throws exception PathIsNotExistsException.
    *   recurse = if true will list also all subdirectories.
    */
    InputRange!string getAvaiableFiles(string prefix = "/", bool recurse = true)
    {
        if(!checkPathSecurity(buildPath(name, prefix)))
            throw new PackSecurityException(mLogger, this.name, "", prefix);

        DList!string list;
        foreach(e; dirEntries(buildPath(mName, prefix), recurse ? SpanMode.breadth : SpanMode.shallow, false))
        {
            list.insert(e.name);
        }

        return list[].inputRangeObject;
    }

    /**
    *   Checks file existance in archive with specified fullName without extensions.
    *   Note: Function can find more than one file with same extension.
    *
    *   Params:
    *   fullName =  File name without extension.
    *   extensions = There method will write finded files extensions.
    *
    *   Returns: true if file is located in the archive.
    */
    bool hasFile(string fullName, out string[] extensions)
    {
        auto path = buildPath(name, fullName);
        if(!checkPathSecurity(path))
            throw new PackSecurityException(mLogger, this.name, "", fullName);

        auto builder = appender!(string[]);

        auto files = dirEntries(path.rootName, SpanMode.breadth).filter!(a => a.name.startsWith(path));
        if(files.empty) return false;

        foreach(e; files)
        {
            builder.put(e.name.extension);
        }

        extensions = builder.data;
        return true;
    }

    /**
    *   If file with name fullName is exists, returns stream to read it,
    *   else throws exception PathIsNotExistsException.
    *   
    *   Should throw UnsupportedReadException if readable property is set to false.
    *
    *   Throws: PathIsNotExistsException, UnsupportedReadException, PackSecurityException
    */
    InputStream read(string fullName)
    {
        string path = buildPath(name, fullName);
        if(!checkPathSecurity(path))
            throw new PackSecurityException(mLogger, this.name, "", fullName);

        if(!exists(path))
            throw new PathIsNotExistsException(mLogger, this, fullName);

        return new File(path, FileMode.In);
    }

    /**
    *   If archive supports writing, writes content of stream into it.
    *   Should automatically create all needed directories.
    *   If replace is set to false and another file is located at fullName,
    *   should throw FileConflictException.
    *
    *   Throws: UnsupportedWriteException, FileConflictException
    */
    void write(string fullName, Stream stream, bool replace = false)
    {
        string path = buildPath(name, fullName);
        if(!checkPathSecurity(path))
            throw new PackSecurityException(mLogger, this.name, "", fullName);

        if(exists(path) && !replace)
            throw new FileConflictException(mLogger, this, fullName);

        auto file = new File(path, FileMode.Out);
        scope(exit) file.close();
        file.copyFrom(stream);
    }

    /// Checks path to be in root path
    private bool checkPathSecurity(string checkPath)
    {
        return name.startsWith(absolutePath(checkPath));
    }

    private
    {
        shared ILogger mLogger;
        string mName;
    }
}