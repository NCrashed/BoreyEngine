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
module borey.video.mesh;
@safe:

import borey.video.buffer;

/**
*   Describes mesh - a part of model with shared material. Incapsulates
*   vertex, indexes buffers.
*/
interface IMesh
{
    /**
    *   Returns mesh name used for accessing mesh in IModel.
    */
    string name() @property;

    /**
    *   Returns vertex buffer storing 3d vertices of the mesh.
    */
    IVertexBuffer3D vertexBuffer() @property;

    /**
    *   Returns vertex buffer storing normal for each vertex from
    *   vertex buffer.
    */
    IVertexBuffer3D normalBuffer() @property;

    /**
    *   Returns vertex buffer storing texture coordinates for each
    *   vertex from vertex buffer.
    */
    IVertexBuffer2D uvBuffer() @property;

    /**
    *   Returns index buffer storing triangle vertex indecies from
    *   vertex buffer.
    */
    IIndexBuffer indexBuffer() @property;
}