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
module borey.scene.manager;
@safe:

import borey.util.vector;
import borey.util.matrix;
import borey.util.frustum;
import borey.scene.node;
import borey.video.model;
import std.range;

/**
*   Manager which handle all scene objects. Manager
*   can construct it own scene hierarchy to provide
*   fast view frustum culling.
*/
interface ISceneManager
{
    /// Name of root node
    enum ROOT_SCENE_NODE = "root";

    synchronized
    {
        /**
        *   Returns root scene node. All nodes should be
        *   attached to root node to be rendered.
        */
        shared(ISceneNode) rootSceneNode() @property;

        /**
        *   Struct handles all needed information for
        *   video driver to render scene node.
        */
        struct RenderNode
        {
            /// Models to be rendered
            InputRange!IModel models;
            /// Absolute position
            vector3df position;
            /// Absolute rotation
            Matrix!4 rotation;
        }

        /**
        *   Perform view frustum culling. Returns range of scene
        *   nodes to be rendered. Output range consists of
        *   all scene nodes to be rendered, all tree descending
        *   incapsulated in range. Invisible nodes not included in
        *   range.
        */
        InputRange!RenderNode fetchNodesByFrustum(ViewFrustum view);
    }
}