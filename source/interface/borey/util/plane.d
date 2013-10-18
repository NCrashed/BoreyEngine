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
module borey.util.plane;

import borey.util.vector;
import std.traits;
import std.math;

alias Plane!float plane3df;
alias Plane!int   plane3di;

/**
*   Describes mathematic 3d plane.
*   Plane is described by two basis vectors and
*   origin point to handle local coordinate system. 
*/
struct Plane(Type)
    if(isNumeric!Type)
{
    alias Vector!(Type, 3) planeVector;
    alias Vector!(Type, 2) localVector;

    /**
    *   Constructs plane from normal vector, and normal origin.
    */
    this(planeVector vecNormal, planeVector vecOrigin)
    {
        vecNormal.normalize();
        mBasisU = (mBasisU - vecOrigin.project(vecNormal)).normalized();
        mBasisV = mBasisU.cross(vecNormal).normalized();
        mOrigin = vecOrigin;
    }

    /**
    *   Constructs plane from classic equation.
    *   Params:
    *   A = x normal coordinate
    *   B = y normal coordinate
    *   C = z normal coordinate
    *   D = distance between plane and origin
    */
    this(Type A, Type B, Type C, Type D)
    {
        auto norm = planeVector(A, B, C).normalized;

        if(!approxEqual(norm.x, 0))
        {
            mOrigin.x = cast(Type)(- D / cast(float)norm.x);
            mOrigin.y = 0;
            mOrigin.z = 0;
        }
        else if(!approxEqual(norm.y, 0))
        {
            mOrigin.x = 0;
            mOrigin.y = cast(Type)(- D / cast(float)norm.y);
            mOrigin.z = 0;
        }
        else if(!approxEqual(norm.z, 0))
        {
            mOrigin.x = 0;
            mOrigin.y = 0;
            mOrigin.z = cast(Type)(- D / cast(float)norm.z);
        }

        mBasisU = (mBasisU - mOrigin.project(norm)).normalized();
        mBasisV = mBasisU.cross(norm).normalized();
    }

    /// Returns first basis vector
    planeVector basisU() const @property
    {
        return mBasisU;
    }

    /// Returns second basis vector
    planeVector basisV() const @property
    {
        return mBasisV;
    }

    /// Returns plane basis origin
    planeVector origin() const @property
    {
        return mOrigin;
    }

    /// Transform local plane coordinates to world
    planeVector fromLocal(Type u, Type v) const
    {
        return mOrigin + mBasisV*v + mBasisU*u;
    }

    /// Transform local plane coordinates to world
    planeVector fromLocal(localVector pos) const
    {
        return mOrigin + mBasisV*pos.y + mBasisU*pos.x;
    }

    /// Transform world coordinates to plane
    /**
    *   If point is not on plane, projects it on the plain.
    */
    localVector toLocal(planeVector pos) const
    {
        localVector ret;
        ret.x = cast(Type)pos.project(mBasisU).length;
        ret.y = cast(Type)pos.project(mBasisV).length;
        return ret;
    }

    /// Calculates plane normal
    planeVector normal() const @property
    {
        return mBasisU.cross(mBasisV);
    }

    private
    {
        /// Basis U vector
        planeVector mBasisU;
        /// Basis V vector
        planeVector mBasisV;
        /// Translation point
        planeVector mOrigin;
    }

    invariant()
    {
        assert(approxEqual(mBasisU.dot(mBasisV), 0), "Basis vectors must be orthogonal!");
        assert(approxEqual(cast(float)mBasisU.length2, 1.0f), "Basis vector U must be normalized!");
        assert(approxEqual(cast(float)mBasisV.length2, 1.0f), "Basis vector V must be normalized!");
    }
}