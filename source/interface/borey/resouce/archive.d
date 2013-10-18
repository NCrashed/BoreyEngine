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
module borey.resource.archive;

import borey.exception;
import borey.log;
import std.range;
import std.stream;
import std.conv;

/**
*   Thrown when loading of archive is failed.
*/
class ArchiveLoadingException : BoreyLoggedException
{
    /// Problem path
    string path;

    this(shared ILogger logger, string path, lazy string msg,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.path = path;
        super(logger, text("[Archive]: Failed to load archive with path '", path, "'! Details: ", msg), file, line);
    }
}

/**
*   Thrown when trying to access not existing path
*   in archive.
*/
class PathIsNotExistsException : BoreyLoggedException
{
    /// Problem path
    string path;
    /// Problem archive
    IArchive archive;

    this(shared ILogger logger, IArchive archive, string path,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.archive = archive;
        this.path = path;
        super(logger, text("Path '",path," is not exists in archive '",archive.name,"'"), file, line);
    }
}

/**
*   Thrown when trying to access not existing path
*   in archive.
*/
class UnsupportedReadException : BoreyLoggedException
{
    /// Problem archive
    IArchive archive;

    this(shared ILogger logger, IArchive archive,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.archive = archive;
        super(logger, text("Archive '",archive.name,"' doesn't support read access!"), file, line);
    }
}

/**
*   Thrown when trying to access not existing path
*   in archive.
*/
class UnsupportedWriteException : BoreyLoggedException
{
    /// Problem archive
    IArchive archive;

    this(shared ILogger logger, IArchive archive,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.archive = archive;
        super(logger, text("Archive '",archive.name,"' doesn't support write access!"), file, line);
    }
}

/**
*   Thrown when trying to access not existing path
*   in archive.
*/
class FileConflictException : BoreyLoggedException
{
    /// Problem path
    string path;
    /// Problem archive
    IArchive archive;

    this(shared ILogger logger, IArchive archive, string path,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.path = path;
        this.archive = archive;
        super(logger, text("Found another file at '", path,"' in archive '",archive.name,"'!"), file, line);
    }
}

/**
*   Describes container object, which can extract/insert
*   resources. Archive can be a file system, zip archive
*   or remote ftp server.
*/
interface IArchive
{
    /// Returns name of archive
    string name() const @property;

    /// Returns true if archive can read resources
    bool readable() const @property;

    /// Returns true if archive can write resources
    bool writeable() const @property;

    /**
    *   Returns range of available files in archive.
    *
    *   Params:
    *   prefix = path to find from, if specified path is not
    *           exists in archive throws exception PathIsNotExistsException.
    *   recurse = if true will list also all subdirectories.
    */
    InputRange!string getAvaiableFiles(string prefix = "/", bool recurse = true);

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
    bool hasFile(string fullName, out string[] extensions);

    /**
    *   If file with name fullName is exists, returns stream to read it,
    *   else throws exception PathIsNotExistsException.
    *   
    *   Should throw UnsupportedReadException if readable property is set to false.
    *
    *   Throws: PathIsNotExistsException, UnsupportedReadException, PackSecurityException
    */
    InputStream read(string fullName);

    /**
    *   If archive supports writing, writes content of stream into it.
    *   Should automatically create all needed directories.
    *   If replace is set to false and another file is located at fullName,
    *   should throw FileConflictException.
    *
    *   Throws: UnsupportedWriteException, FileConflictException, PackSecurityException
    */
    void write(string fullName, Stream stream, bool replace = false);
}