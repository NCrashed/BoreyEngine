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
module borey.resource.archivemanager;

import borey.log;
import borey.exception;
import borey.resource.archive;
import std.range;
import std.conv;

/**
*   Thrown when archive name collision detected.
*/
class ArchiveConflictException : BoreyLoggedException
{
    /// Fabric've already been registered
    IArchiveFabric first;
    /// New fabric which cause conflict
    IArchiveFabric second;

    this(shared ILogger logger, IArchiveFabric first, IArchiveFabric second,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.first = first;
        this.second = second;
        super(logger, text("Name conflict between '",first.name,"' archive type and '",second.name,"' archive type!"), file, line);
    }
}

/**
*   Thrown when manager cannot find archive that able to open 
*   particular path.
*/
class ArchiveNotFoundException : BoreyLoggedException
{
    /// Problem path
    string path;

    this(shared ILogger logger, string path,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.path = path;
        super(logger, text("Cannot find archive type to open path '",path,"'!"), file, line);
    }
}

/**
*   Manager that knows about all loaded archive types. All fabric types need to be registered
*   in archive manager, otherwise resource system wouldn't able to use them.
*/
interface IArchiveManager
{
    /// Returns range of loaded archive types.
    InputRange!IArchiveFabric fabrics() @property;

    /// Tries to find first archive type available to open particular path
    /**
    *   If cannot find any archive type, will throw ArchiveNotFoundException.
    *
    *   Throws: ArchiveNotFoundException
    */
    IArchiveFabric findByPath(string path);

    /// Tries to find archive with specified name
    /**
    *   If cannot find archive fabric, will throw ArchiveNotFoundException.
    *
    *   Throws: ArchiveNotFoundException
    */
    IArchiveFabric findByName(string name);

    /// Registers new archive fabric in system
    /**
    *   If new fabric cause name collision and overwrite is false, then
    *   ArchiveConflictException will be thrown, otherwise old fabric will
    *   be overwritten by new one.
    *
    *   Throws: ArchiveConflictException
    */
    void registerFabric(IArchiveFabric fabric, bool overwrite = false);
}