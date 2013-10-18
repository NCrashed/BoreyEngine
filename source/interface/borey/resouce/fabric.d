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
module borey.resource.fabric;

import borey.resource.item;
import std.stream;
import std.range;

/**
*   Resource fabric tells resouce manager how to construct
*   resources and maps extensions to resource types.
*/
interface IResourceFabric
{
    /**
    *   Returns name of fabric.
    */
    string name() const @property;

    /**
    *   Returns names of handled resource types.
    *   Note: This method used only for providing information
    *   about system features.
    */
    InputRange!string handledResourceTypes() const @property;

    /**
    *   Returns extensions of resource files which
    *   the fabric can handle.
    */
    InputRange!string extensions() const @property;

    /**
    *   Creates new resource from input stream, full name of resource and
    *   it extension.
    */
    shared(IResource) load(InputStream stream, string fullName, string extension);
}