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
module borey.scene.node;
@safe:

import borey.util.vector;
import borey.util.quaternion;
import std.range;

/**
*   Scene node incapsulates position information about scene
*   objects. Each node handles releative position and rotation,
*   absolute position and rotation can be extracted by descenging
*   scene graph and accumulating releative attributes.
*
*   Scene nodes aren't created explicity, you should use
*   createChild method to attach new node to another. Scene manager
*   always has root scene node to attach to.
*/
interface ISceneNode
{
    synchronized
    {
        /**
        *   Returns scene node name to accessing by name.
        */
        string name() const @property;

        /**
        *   Returns node parent, or null to root scene node 
        *   (special case is detached scene node which won't be drawed).
        */
        shared(ISceneNode) parent() @property;

        /**
        *   Setting node parent. Does not remove node from
        *   children list of parent! 
        *
        *   See_Also: detachChild, attachChild for user code.
        */
        void parent(shared ISceneNode node) @property;

        /**
        *   Returns range of attached children.
        */
        InputRange!(shared ISceneNode) children() @property;

        /**
        *   Performing search of scene node by name, if recurse
        *   parameter is true, search will be recursive up to
        *   leafs of scene tree.
        *
        *   Returns: Range of finded nodes.
        */
        InputRange!(shared ISceneNode) find(string name, bool recurse = true);

        /**
        *   Creates child node with name. Setups default position and rotation.
        */
        shared(ISceneNode) createChild(string name, vector3df pos = vector3df.ZERO, Quaternion rot = Quaternion.UNIT);

        /**
        *   Detaches scene node from parent.
        *   
        *   Note: to make node invisible, use visble property.
        *   Note: If node is not attached, does nothing.
        */
        void detachChild(shared ISceneNode node);

        /**
        *   Attaches child scene node to this node.
        *
        *   Note: to make node invisible, use visble property.
        *   Note: if node already attached, does nothing.
        */
        void attachChild(shared ISceneNode node);

        /**
        *   If node is not visible, it won't be drawed as all it children.
        */
        bool visible() const @property;

        /**
        *   If node is not visible, it won't be drawed as all it children.
        */
        void visble(bool value) @property;

        /**
        *   Returns node local (relative the parent) position.
        */
        vector3df position() const @property;

        /**
        *   Sets node local position (relative the parent).
        */
        void position(vector3df val) @property;

        /**
        *   Return node local rotation (relative the parent).
        */
        Quaternion rotation() const @property;

        /**
        *   Sets node local rotation (relative the parent).
        */
        void rotation(Quaternion val) @property;

        /**
        *   Returns absolute location (relative the root node).
        */
        vector3df absolutePosition() const @property;

        /**
        *   Returns absolute roatation (relative the root node).
        */
        Quaternion absoluteRotation() const @property;
    }
}