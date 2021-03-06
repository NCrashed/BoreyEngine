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
module borey.resource.pack;

import borey.log;
import borey.exception;
import borey.resource.group;
import borey.resource.archive;
import std.typecons;
import std.stream;
import std.range;
import std.conv;

/**
*   Thrown when resource package name conflict detected.
*/
class GroupConflictException : BoreyLoggedException
{
    /// Problem group name
    string name;
    /// Problem resource pack
    string pack;

    this(shared ILogger logger, string name, string pack,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        this.pack = pack;
        super(logger, text("Detected name conflict for resource groups in resrouce pack '",pack,"'! Problem resoure group: ", name),
            file, line);
    }
}

/**
*   Thrown when trying to access no existing resource group.
*/
class GroupNotExistsException : BoreyLoggedException
{
    /// Problem group name
    string name;
    /// Problem resource pack
    string pack;

    this(shared ILogger logger, string name, string pack,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        this.pack = pack;
        super(logger, text("There is no resource group '",name,"' in resource pack '",pack,"'!"),
            file, line);
    }
}

/**
*   Thrown when trying to add (or load resource) resource group with path entries,
*   wich 'getting out' of pack root path.
*/
class PackSecurityException : BoreyLoggedException
{
    /// Problem resource pack
    string pack;
    /// Problem group name
    string name;
    /// Problem entry
    string entry;

    this(shared ILogger logger, string pack, string name, string entry,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.pack = pack;
        this.name = name;
        this.entry = entry;
        super(logger, text("Possible access to files higher than pack root! Group name '",
            name,"', entry name '",entry,"'' in resource pack '",pack),
            file, line);
    }
}

/**
*   Resource pack descirbes huge independent groups of
*   resources.
*/
interface IResourcePack
{
    enum DEFAULT_RESOURCE_GROUP = "general";

    /// Returns name of resource pack
    string name() const @property;

    /// Returns root path of resource pack
    string path() const @property;

    /**
    *   Tries to add default groups to resource pack.
    *   Usually it is IResourcePack.DEFAULT_RESOURCE_GROUP.
    */
    void registerDefaultResourceGroups();

    /// Returns underlying archive
    IArchive archive() @property;

    /// Tuple to return from hasResource
    alias Tuple!(
        bool, "finded", 
        string, "extension",
        string, "fullName") ResourceSearch;

    /**
    *   Checks if resource pack contains resource name in
    *   specified resource group.
    *   
    *   Returns: tuple of search result and file extension (empty string if search failed).
    *   Throws: GroupNotExistsException if group is not registered.
    */
    ResourceSearch hasResource(string name, string group = DEFAULT_RESOURCE_GROUP);

    /**
    *   Tries to open resource with name and group.
    *
    *   Throws: ResourceNotFoundException, ResourceLoadingException if failed to find/load resource.
    *   Throws: GroupNotExistsException if group is not registered.
    */
    InputStream getResource(string name, string group = DEFAULT_RESOURCE_GROUP);

    /**
    *   Get range of available resource groups.
    */
    const(InputRange!IResourceGroup) resourceGroups() const @property;

    /**
    *   Registers resource group in packe.
    *
    *   Throws: GroupConflictException
    */
    void addResourceGroup(IResourceGroup group);
}