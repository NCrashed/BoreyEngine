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
*   Simple realization of ISceneNode.
*/
module borey.scene.simplenode;
@safe:

import borey.log;
import borey.scene.node;
import borey.util.common;
import borey.util.vector;
import borey.util.quaternion;
import std.algorithm;
import std.container;
import std.range;

/**
*   Basic scene node, implements minimum functionality.
*/
synchronized class SimpleSceneNode : ISceneNode
{
    this(string name, shared ISceneNode parent, shared ILogger logger) @trusted
    {
        mLogger = logger;
        mName = name;
        mParent = parent;
        mChildren = DList!(shared ISceneNode)();
    }

    /**
    *   Returns scene node name to accessing by name.
    */
    string name() const @property
    {
        return mName;
    }

    /**
    *   Returns node parent, or null to root scene node 
    *   (special case is detached scene node which won't be drawed).
    */
    shared(ISceneNode) parent() @property
    {
        return mParent;
    }

    /**
    *   Setting node parent. 
    *
    *   See_Also: detachChild, attachChild for user code.
    */
    void parent(shared ISceneNode node) @property
    {
        mParent = node;
    }

    /**
    *   Returns range of attached children.
    */
    InputRange!(shared ISceneNode) children() @property @trusted
    {
        return innerChildren[].inputRangeObject();
    }

    /**
    *   Performing search of scene node by name, if recurse
    *   parameter is true, search will be recursive up to
    *   leafs of scene tree.
    *
    *   Returns: Range of finded nodes.
    */
    InputRange!(shared ISceneNode) find(string name, bool recurse = true) @trusted
    {
        if(innerChildren.empty)
        {
            return inputRangeObject(cast(shared(ISceneNode)[])[]);
        }

        if(!recurse)
        {
            return filter!(a => a.name == name)(innerChildren[]).inputRangeObject();
        } 
        else
        {
            DList!(shared ISceneNode) temp;
            foreach(ref child; cast()mChildren)
            {
                temp.insertBack(child.find(name));
            }
            return chain(innerChildren[].filter!(a => a.name == name), temp[]).inputRangeObject();

            // Workaround, flatten problems with empty ranges
            //return chain(innerChildren[].filter!(a => a.name == name),
            //    flatten(innerChildren[].map!(a => a.find(name))) ).inputRangeObject();
        }
    }

    /**
    *   Creates child node with name. Setups default position and rotation.
    */
    shared(ISceneNode) createChild(string name, vector3df pos = vector3df.ZERO, Quaternion rot = Quaternion.UNIT) @trusted
    {
        auto node = new shared SimpleSceneNode(name, this, mLogger);
        node.position = pos;
        node.rotation = rot;
        innerChildren.insertBack(node);
        return node;
    }

    /**
    *   Detaches scene node from parent.
    *   
    *   Note: to make node invisible, use visble property.
    *   Note: If node is not attached, does nothing.
    */
    void detachChild(shared ISceneNode node) @trusted
    {
        auto res = std.algorithm.find(innerChildren[], node);
        if(res.empty) return;

        node.parent = null;
        innerChildren.remove(res);
    }

    /**
    *   Attaches child scene node to this node.
    *
    *   Note: to make node invisible, use visble property.
    *   Note: if node already attached, does nothing.
    */
    void attachChild(shared ISceneNode node) @trusted
    {
        auto res = std.algorithm.find(innerChildren[], node);
        if(!res.empty) return;

        node.parent = this;
        innerChildren.insertFront(node);
    }

    /**
    *   If node is not visible, it won't be drawed as all it children.
    */
    bool visible() const @property
    {
        return mVisible;
    }

    /**
    *   If node is not visible, it won't be drawed as all it children.
    */
    void visble(bool value) @property
    {
        mVisible = value;
    }

    /**
    *   Returns node local (relative the parent) position.
    */
    vector3df position() const @property @trusted
    {
        return mPosition;
    }

    /**
    *   Sets node local position (relative the parent).
    */
    void position(vector3df val) @property @trusted
    {
        mPosition = val;
    }

    /**
    *   Return node local rotation (relative the parent).
    */
    Quaternion rotation() const @property @trusted
    {
        return mRotation;
    }

    /**
    *   Sets node local rotation (relative the parent).
    */
    void rotation(Quaternion val) @property @trusted
    {
        mRotation = val;
    }

    /**
    *   Returns absolute location (relative the root node).
    */
    vector3df absolutePosition() const @property
    {
        if(mParent is null)
            return position;
        else
            return mParent.position + position;
    }

    /**
    *   Returns absolute roatation (relative the root node).
    */
    Quaternion absoluteRotation() const @property
    {
        if(mParent is null)
            return rotation;
        else
            return mParent.rotation + rotation;
    }

    /// Avoid boilerplate casting everywhere
    private DList!(shared ISceneNode) innerChildren() @property @trusted
    {
        return cast()mChildren;
    }

    protected
    {
        string mName;
        shared ILogger mLogger;
        ISceneNode mParent;
        bool mVisible = true;
        DList!(shared ISceneNode) mChildren;
    }
    private
    {
        __gshared vector3df mPosition;
        __gshared Quaternion mRotation = Quaternion.UNIT;
    }
}

@trusted unittest
{
    import std.stdio;
    
    write("Testing simple scene node....");
    scope(failure) writeln("Failed");
    scope(success) writeln("Finished!");


    auto root = new shared SimpleSceneNode("root", null, null);
    auto aNode = root.createChild("a");
    auto bNode = root.createChild("b");
    auto cNode = root.createChild("c");

    auto a2Node = bNode.createChild("a");
    auto b2Node = cNode.createChild("b");

    auto a3Node = a2Node.createChild("a");
    
    assert(root.find("a").map!"a.name".equal(["a", "a", "a"]));
    assert(root.find("b").map!"a.name".equal(["b", "b"]));
    assert(root.find("c", false).map!"a.name".equal(["c"]));
}