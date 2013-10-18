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
/**
*   Describes model as number of meshes and additional information for
*   animation.
*/
module borey.video.model;

import borey.exception;
import borey.video.mesh;
import std.range;

/**
*   Throwed when mesh by name not found.
*/
class MeshNotFoundException : BoreyException
{
    this(string modelName,
        string file = __FILE__, size_t line = __LINE__)
    {
        super("Mesh with name "~modelName~" is not found!");
    }
}

interface IModel
{
    /**
    *   Returns name of this model, used to access model from scene node.
    */
    string name() const @property;

    /**
    *   Find mesh by name.
    *   Returns: finded mesh or throws MeshNotFoundException.
    */
    IMesh getMesh(string name);

    /**
    *   Returns mesh range for this model.
    */
    InputRange!IMesh meshes() @property;
}