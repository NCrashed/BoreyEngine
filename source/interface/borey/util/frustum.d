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
module borey.util.frustum;

import borey.util.matrix;
import borey.util.plane;

/**
*   Struct describes view frustum of camera (clipped prism) and used
*   to perform view culling for scene graph.
*
*   TODO: add frustum constructing for othogonal projection.
*/
struct ViewFrustum
{
    /// Projection matrix
    Matrix!4 projection;

    /**
    *   Creating view frustum with perspective projection.
    *
    *   Params:
    *   fovy   = Viewing angle in radians. Usually around [30..90] degrees.
    *   aspect = Relation between vieport height and width.
    *   zNear  = Near clipping plane.
    *   zFar   = Far clipping plane.
    */
    this(Radian fovy, float aspect, float zNear, float zFar)
    {
        projection = borey.util.matrix.projection(fovy, aspect, zNear, zFar);
    }

    /// Near clipping plane
    /**
    *   Calculates near clipping plane in world coordinates.
    */
    plane3df getNearPlane(Matrix!4 viewMatrix) const
    {
        auto vec = viewMatrix.getRow(3) + viewMatrix.getRow(2);
        return plane3df(vec.x, vec.y, vec.z, vec.w);
    }

    /// Far clipping plane
    /**
    *   Calculates far clipping plane in world coordinates.
    */
    plane3df getFarPlane(Matrix!4 viewMatrix) const
    {
        auto vec = viewMatrix.getRow(3) - viewMatrix.getRow(2);
        return plane3df(vec.x, vec.y, vec.z, vec.w);
    }

    /// Left clipping plane
    /**
    *   Calculates left clipping plane in world coordinates.
    */    
    plane3df getLeftPlane(Matrix!4 viewMatrix) const
    {
        auto vec = viewMatrix.getRow(3) + viewMatrix.getRow(0);
        return plane3df(vec.x, vec.y, vec.z, vec.w);        
    }

    /// Right clipping plane
    /**
    *   Calculates right clipping plane in world coordinates.
    */     
    plane3df getRightPlane(Matrix!4 viewMatrix) const
    {
        auto vec = viewMatrix.getRow(3) - viewMatrix.getRow(0);
        return plane3df(vec.x, vec.y, vec.z, vec.w);        
    }

    /// Upper clipping plane
    /**
    *   Calculates upper clipping plane in world coordinates.
    */     
    plane3df getUpperPlane(Matrix!4 viewMatrix) const
    {
        auto vec = viewMatrix.getRow(3) - viewMatrix.getRow(1);
        return plane3df(vec.x, vec.y, vec.z, vec.w);        
    }

    /// Bottom clipping plane
    /**
    *   Calculates bottom clipping plane in world coordinates.
    */     
    plane3df getBottomPlane(Matrix!4 viewMatrix) const
    {
        auto vec = viewMatrix.getRow(3) + viewMatrix.getRow(1);
        return plane3df(vec.x, vec.y, vec.z, vec.w);        
    }
}