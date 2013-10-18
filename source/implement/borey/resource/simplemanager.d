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
/**
*   Minimalistic implementation of resource manager, without caching.
*/
module borey.resource.simplemanager;

import borey.exception;
import borey.log;
import borey.resource.manager;
import borey.resource.fabric;
import borey.resource.pack;
import borey.resource.localpack;
import borey.resource.item;
import std.algorithm;
import std.container;
import std.range;
import std.conv;

synchronized class SimpleResourceManager : IResourceManager
{
    this(shared ILogger logger)
    {
        mLogger = logger;
    }

    /**
    *   Resource manager tries to register default resource
    *   pack. Usually it is IResourceManager.DEFAULT_RESOURCE_PACK
    *   within local storage.
    */
    void registerDefaultPacks()
    {
        auto pack = new LocalResourcePack(mLogger, 
            IResourceManager.DEFAULT_RESOURCE_PACK, IResourceManager.DEFAULT_RESOURCE_PACK_PATH);

        pack.registerDefaultResourceGroups();
        registerPack(pack);
    }

    /**
    *   Returns: available resource types to be loaded.
    */
    InputRange!string handledResourceTypes() @property
    {
        DList!string temp;
        foreach(fabric; fabrics)
        {
            temp.insertBack(fabric.handledResourceTypes);
        }

        return temp[].inputRangeObject();
    }

    /**
    *   Returns: range of registered extensions.
    */
    InputRange!string registeredExtensions() @property
    {
        DList!string temp;
        foreach(fabric; fabrics)
        {
            temp.insertBack(fabric.handledResourceTypes);
        }

        return temp[].inputRangeObject();
    }

    /**
    *   Register resource fabric in manager. If another
    *   fabric handling same extension is detected, then
    *   FabricConflictException is thrown.
    */
    void registerFabric(IResourceFabric fabric)
    {
        checkExtensions(fabric);

        fabrics.insertBack(fabric);
        mLogger.logNotice(text("[Resource Manager]: Registered new fabric ",fabric.name," for resource types: ", fabric.handledResourceTypes));
    }

    /**
    *   Tries to locate and load resource with name in resource pack and 
    *   using resource group to filter resources.
    *
    *   Throws: ResourceNotFoundException, ResourceLoadingException
    */
    shared(IResource) getResource(string name, string group = IResourcePack.DEFAULT_RESOURCE_GROUP, 
        string packName = DEFAULT_RESOURCE_PACK) @trusted
    {
        auto pack = packByName(packName);

        auto search = pack.hasResource(name, group);
        if(search.finded)
        {
            if(search.extension !in mFabricMap)
                throw new UnknownResourceTypeException(mLogger, name, pack, group, search.extension);

            auto fabric = cast()mFabricMap[search.extension];
            return fabric.load(pack.getResource(name, group), name, search.extension);
        }
        else
        {
            throw new ResourceNotFoundException(mLogger, name, pack, group);
        }
    }


    /// Accessing logger for local using
    protected shared(ILogger) logger() @property
    {
        return mLogger;
    }

    /**
    *   Returns: range of loaded resource packs.
    */
    InputRange!IResourcePack loadedPacks() @property
    {
        return packs[].inputRangeObject();
    }

    /**
    *   Tries to load resource pack into the manager.
    *   Will throw PackConflictException if name of resource
    *   pack is conflicting with already loaded packs.
    *   
    *   Throws: PackConflictException
    */
    void registerPack(IResourcePack pack)
    {
        checkPacksNames(pack);

        packs.insertBack(pack);
        mLogger.logNotice(text("[ResourceManager]: Added resource pack '", pack.name,"'"));
    }

    /// for inner use, avoid casting shared
    private auto fabrics() @property @trusted
    {
        return cast()mFabrics;
    }

    /// for inner use, avoid casting shared
    private auto packs() const @property @trusted
    {
        return cast()mPacks;
    }

    /// If finds conflict, throws exception
    private void checkExtensions(IResourceFabric fabric)
    {
        foreach(regExt; registeredExtensions)
        {
            if(!fabric.extensions.find(regExt).empty)
            {
                throw new FabricConflictException(mLogger, cast(immutable)fabricByExtension(regExt), cast(immutable)fabric, regExt);
            }
        }
    }

    /// If finds conflict, throws exception
    private void checkPacksNames(IResourcePack checkPack)
    {
        foreach(pack; packs)
        {
            if(pack.name == checkPack.name)
            {
                throw new PackConflictException(mLogger, pack, checkPack);
            }
        }
    }

    /// Will throw Error if not finded
    protected IResourceFabric fabricByExtension(string ext)
    {
        assert(ext in mFabricMap, "Invalid program state! Extension "~ext~" must be in map!");
        
        return cast()mFabricMap[ext];
    }

    /**
    *   Find pack by name.
    * 
    *   Throws: PackNotRegisteredException
    */
    protected IResourcePack packByName(string name)
    {
        auto res = packs[].find!"a.name == b"(name);

        if(res.empty)
            throw new PackNotRegisteredException(mLogger, name);

        return res.front;
    }

    private
    {
        DList!IResourceFabric mFabrics;
        DList!IResourcePack mPacks;
        IResourceFabric[string] mFabricMap;
        shared(ILogger) mLogger;
    }
}