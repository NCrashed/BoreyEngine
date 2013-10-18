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
module borey.resource.manager;

import borey.exception;
import borey.log;
import borey.resource.fabric;
import borey.resource.pack;
import borey.resource.item;
import borey.resource.group;
import std.range;
import std.conv;

/**
*   Thrown when fabric extension conflict detected.
*/
class FabricConflictException : BoreyLoggedException
{
    /// First fabric (registered)
    immutable IResourceFabric first;
    /// Second fabric, wich was tried to be registered
    immutable IResourceFabric second;
    /// Problem extension
    string extension;

    this(shared ILogger logger, immutable IResourceFabric first, immutable IResourceFabric second, string extension,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.first = first;
        this.second = second;
        this.extension = extension;
        super(logger, text("Detected extension conflict for resource fabrics '",first.name
            ,"' and '",second.name,"'! Problem extension: ", extension), file, line);
    }
}

/**
*   Thrown when resource package name conflict detected.
*/
class PackConflictException : BoreyLoggedException
{
    /// First pack (registered)
    IResourcePack first;
    /// Second pack, wich was tried to be registered
    IResourcePack second;

    this(shared ILogger logger, IResourcePack first, IResourcePack second,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.first = first;
        this.second = second;
        super(logger, text("[ResourceManager]: Detected name conflict for resource packs! Problem resoure pack: ",
            first.name), file, line);
    }
}

/**
*   Thrown when resource can't be located.
*/
class ResourceNotFoundException : BoreyLoggedException
{
    /// Problem resource
    string name;
    /// Pack where search were performed
    IResourcePack pack;
    /// Group where search were performed
    string group;

    this(shared ILogger logger, string name, IResourcePack pack, string group,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        this.group = group;
        this.pack = pack;
        super(logger, text("[ResourceManager]: Resource with name ",name," not found in resource pack ",pack.name, 
            " and resource group ", group), file, line);
    }
}

/**
*   Thrown when resource can't be located.
*/
class ResourceLoadingException : BoreyLoggedException
{
    /// Problem resource
    string name;
    /// Pack where search were performed
    IResourcePack pack;
    /// Group where search were performed
    string group;

    this(shared ILogger logger, string name, IResourcePack pack, string group, lazy string msg,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        this.group = group;
        this.pack = pack;
        super(logger, text("[ResourceManager]: Failed to load resource ", name, " in resource pack ", pack.name, 
            " and resource group ", group, ". Details: ", msg), file, line);
    }
}

/**
*   Thrown when trying to load resource from unknown resource pack.
*/
class PackNotRegisteredException : BoreyLoggedException
{
    /// Pack name
    string name;

    this(shared ILogger logger, string name,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        super(logger, text("[ResourceManager]: Cannot find pack with name ", name), file, line);
    }
}

/**
*   Thrown when resource can't be located.
*/
class UnknownResourceTypeException : BoreyLoggedException
{
    /// Problem resource
    string name;
    /// Pack where search were performed
    IResourcePack pack;
    /// Group where search were performed
    string group;
    /// Problem extension
    string extension;

    this(shared ILogger logger, string name, IResourcePack pack, string group, string extension,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        this.group = group;
        this.pack = pack;
        this.extension = extension;
        super(logger, text("[ResourceManager]: Failed to load resource ", name, " in resource pack ", pack.name, 
            " and resource group ", group, ". Details: Unknown resource type for extension '", extension, "'!"), 
            file, line);
    }
}

/**
*   Resource manager handles all loaded resource packs and resource
*   fabrics. Also manager provides uniform interface for accessing
*   available resources.
*/
interface IResourceManager
{
    enum DEFAULT_RESOURCE_PACK = "core";
    enum DEFAULT_RESOURCE_PACK_PATH = "../assets";

    synchronized
    {
        /**
        *   Resource manager tries to register default resource
        *   pack. Usually it is IResourceManager.DEFAULT_RESOURCE_PACK
        *   within local storage.
        */
        void registerDefaultPacks();

        /**
        *   Returns: available resource types to be loaded.
        */
        InputRange!string handledResourceTypes() @property;

        /**
        *   Returns: range of registered extensions.
        */
        InputRange!string registeredExtensions() @property;

        /**
        *   Register resource fabric in manager. If another
        *   fabric handling same extension is detected, then
        *   FabricConflictException is thrown.
        */
        void registerFabric(IResourceFabric fabric);

        /**
        *   Tries to locate and load resource with name in resource pack and 
        *   using resource group to filter resources.
        *
        *   Throws: ResourceNotFoundException, ResourceLoadingException, UnknownResourceTypeException
        */
        shared(IResource) getResource(string name, string group = IResourcePack.DEFAULT_RESOURCE_GROUP, 
            string pack = DEFAULT_RESOURCE_PACK);

        /**
        *   Tries to locate and load resource with name in source pack and
        *   using resource group to filter resources. It is a wrapper,
        *   that cast result of getResource to specified ResourceType.
        *
        *   Throws: ResourceNotFoundException, ResourceLoadingException, UnknownResourceTypeException
        */
        final shared(ResourceType) getResourceAs(ResourceType : IResource)(string name, 
            string group = IResourcePack.DEFAULT_RESOURCE_GROUP, 
            string pack = DEFAULT_RESOURCE_PACK)
        {
            auto retResource = cast(shared ResourceType)getResource(name, group, pack);

            if(retResource is null)
            {
                throw new ResourceLoadingException(logger, name, group, pack, 
                    text("Failed to cast resource to type ", ResourceType.stringof));
            }
        }

        /// Accessing logger for local using
        protected shared(ILogger) logger() @property;

        /**
        *   Returns: range of loaded resource packs.
        */
        InputRange!IResourcePack loadedPacks() @property;

        /**
        *   Tries to load resource pack into the manager.
        *   Will throw PackConflictException if name of resource
        *   pack is conflicting with already loaded packs.
        *   
        *   Throws: PackConflictException
        */
        void registerPack(IResourcePack pack);
    }
}