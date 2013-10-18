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
*   Simple implementation of scene manager, fully relies to user
*   propert scene graph construction.
*/
module borey.scene.simplemanager;
@safe:

import borey.log;
import borey.scene.manager;
import borey.scene.node;
import borey.scene.simplenode;
import borey.util.frustum;
import std.range;

/**
*   Simple implementation of scene manager, fully relies to user
*   propert scene graph construction.
*/
synchronized class SimpleSceneManager : ISceneManager
{
    this(shared ILogger logger)
    {
        mLogger = logger;
        mRootNode = new shared SimpleSceneNode(ISceneManager.ROOT_SCENE_NODE, null, logger);
    }

    /**
    *   Returns root scene node. All nodes should be
    *   attached to root node to be rendered.
    */
    shared(ISceneNode) rootSceneNode() @property
    {
        return mRootNode;
    }

    /**
    *   Perform view frustum culling. Returns range of scene
    *   nodes to be rendered. Output range consists of
    *   all scene nodes to be rendered, all tree descending
    *   incapsulated in range. Invisible nodes not included in
    *   range.
    */
    InputRange!RenderNode fetchNodesByFrustum(ViewFrustum view)
    {
        return (new RenderNode[0]).inputRangeObject();
    }

    private
    {
        shared ILogger mLogger;
        shared ISceneNode mRootNode;
    }
}