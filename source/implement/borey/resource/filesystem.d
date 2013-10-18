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