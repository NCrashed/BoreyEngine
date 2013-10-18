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
module borey.resource.localpack;

import borey.resource.pack;
import borey.log;
import borey.exception;
import borey.resource.manager;
import borey.resource.group;
import borey.resource.archive;
import std.algorithm;
import std.container;
import std.stream;
import std.range;
import std.conv;
import std.path;

/**
*   Resoure pack, that located on same machine, usually
*   uses file system archive or compressed archives.
*/
class LocalResourcePack : IResourcePack
{
    /**
    *   Creates local resource pack.
    *
    *   Params:
    *   logger = logger to use,
    *   name = resource pack name,
    *   path = resource pack location to open archive
    */
    this(shared ILogger logger, string name, string path)
    {
        mLogger = logger;
        mName = name;
        mPath = path;
    }

    /// Returns name of resource pack
    string name() const @property
    {
        return mName;
    }

    /// Returns root path of resource pack
    string path() const @property
    {
        return mPath;
    }

    /**
    *   Tries to add default groups to resource pack.
    *   Usually it is IResourcePack.DEFAULT_RESOURCE_GROUP.
    */
    void registerDefaultResourceGroups()
    {
        addResourceGroup(new ResourceGroup(IResourcePack.DEFAULT_RESOURCE_GROUP, "/"));
    }

    /// Returns underlying archive
    IArchive archive() @property; ///TODO: HEEEEEEEEEEEEEEEEERRRRRRRRREEEEEEEEEEEEEE

    /**
    *   Checks if resource pack contains resource name in
    *   specified resource group.
    *   
    *   Returns: tuple of search result and file extension (empty string if search failed).
    */
    ResourceSearch hasResource(string name, string groupName = DEFAULT_RESOURCE_GROUP)
    {
        // simple cache to prevent double hasResource calling.
        if(name != "" && cachedName == name)
            return ResourceSearch(true, cachedExtension, cachedFullName);

        auto res = ResourceSearch(false, "", "");

        IResourceGroup group = groupByName(groupName);

        foreach(entry; group.entries)
        {
            string[] extensions;
            auto fullPath = buildNormalizedPath(entry, name);

            if(!checkPathSecurity(fullPath))
                throw new PackSecurityException(mLogger, this.name, group.name, entry);

            if(archive.hasFile(fullPath, extensions))
            {
                assert(extensions.length > 0, "Invalid program state! If hasFile succeded, it should return non zero length extensions list!");

                res.finded = true;
                cachedName = name;
                res.fullName = cachedFullName = fullPath~"."~extensions[0];
                res.extension = cachedExtension = extensions[0];

                if(extensions.length > 1)
                {
                    mLogger.logWarning(text("[LocalResourcePack]: Finded more than one resource with same name and different extensions, 
                        please, use resource groups to avoid this. Finded extensions: ", extensions));
                }
                break;
            }
        }

        return res;
    }

    /**
    *   Tries to open resource with name and group.
    *
    *   Throws: ResourceNotFoundException, ResourceLoadingException if failed to find/load resource.
    */
    InputStream getResource(string name, string group = DEFAULT_RESOURCE_GROUP)
    {
        auto search = hasResource(name, group);
        if(!search.finded)
            throw new ResourceNotFoundException(mLogger, name, this, group);
        
        try
        {
            return archive.read(search.fullName);
        }
        catch(Exception e)
        {
            throw new ResourceLoadingException(mLogger, name, this, group, e.msg);
        }
    }

    /**
    *   Get range of available resource groups.
    */
    const(InputRange!IResourceGroup) resourceGroups() const @property
    {
        return groups[].inputRangeObject();
    }

    /**
    *   Registers resource group in packe.
    *
    *   Throws: GroupConflictException
    */
    void addResourceGroup(IResourceGroup group)
    {
        auto findRes = groups[].find!"a.name == b"(group.name);
        if(!findRes.empty)
            throw new GroupConflictException(mLogger, group.name, this.name);

        foreach(entry; group.entries)
        {
            if(!checkPathSecurity(buildNormalizedPath(mPath, entry)))
                throw new PackSecurityException(mLogger, this.name, group.name, entry);
        }

        groups.insertBack(group);
    }

    /**
    *   Find group by name.
    *   Throws: GroupNotExistsException if cannot find.
    */
    protected IResourceGroup groupByName(string name) 
    {
        auto findRes = groups[].find!"a.name == b"(name);
        
        if(findRes.empty)
            throw new GroupNotExistsException(mLogger, name, this.name);

        return findRes.front;
    }

    /// To prevent boilerplate casting
    private auto groups() const @property @trusted
    {
        return cast()mGroups;
    }

    /// Checks path to be in root path
    private bool checkPathSecurity(string checkPath)
    {
        return absolutePath(mPath).countUntil(absolutePath(checkPath)) == 0;
    }

    private
    {
        string mName;
        string mPath;
        shared ILogger mLogger;
        DList!IResourceGroup mGroups;

        string cachedName;
        string cachedExtension;
        string cachedFullName;
    }
}