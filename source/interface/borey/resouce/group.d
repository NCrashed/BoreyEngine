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
module borey.resource.group;

import std.range;

/**
*   Resouce group describes grouping mechanism among resouce packs.
*   Used to group textures, shaders, models together and simplify
*   their naming.
*/
interface IResourceGroup
{
    /// Returns name of resource group.
    string name() const @property;

    /**
    *   Returns range of entries where manager should
    *   search resources. For instance, 'textures/space'.
    */
    InputRange!string entries() @property;

    /**
    *   Adds entry to resource group. Entry used as
    *   prefixes to find resources in resource packs.
    */
    void addEntry(string entry);
}

/**
*   Default resource group implementation.
*
*   Example:
*   ---------
*   resourcePack.addResourceGroup(new ResourceGroup("textures", "/textures", "/images", "/photos"));
*   resourcePack.addResourceGroup(new ResourceGroup("models", "/models"));
*   ---------
*/
class ResourceGroup : IResourceGroup
{
    /**
    *   Fast way to construct resource group is pass all
    *   entries in constructor.
    */
    this(string name, string[] entries...)
    {
        mName = name;
        mEntries = entries;
    }

    /// Returns name of resource group.
    string name() const @property
    {
        return mName;
    }

    /**
    *   Returns range of entries where manager should
    *   search resources. For instance, 'textures/space'.
    */
    InputRange!string entries() @property
    {
        return mEntries.inputRangeObject();
    }

    /**
    *   Adds entry to resource group. Entry used as
    *   prefixes to find resources in resource packs.
    */
    void addEntry(string entry)
    {
        mEntries ~= entry;
    }

    private
    {
        string mName;
        string[] mEntries;
    }
}