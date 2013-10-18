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