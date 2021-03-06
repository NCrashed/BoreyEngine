// Copyright (с) 2013 Gushcha Anton <ncrashed@gmail.com>
/*
* This file is part of Borey Engine.
*
* Boost Software License - Version 1.0 - August 17th, 2003
* 
* Permission is hereby granted, free of charge, to any person or organization
* obtaining a copy of the software and accompanying documentation covered by
* this license (the "Software") to use, reproduce, display, distribute,
* execute, and transmit the Software, and to prepare derivative works of the
* Software, and to permit third-parties to whom the Software is furnished to
* do so, all subject to the following:
* 
* The copyright notices in the Software and this entire statement, including
* the above license grant, this restriction and the following disclaimer,
* must be included in all copies of the Software, in whole or in part, and
* all derivative works of the Software, unless such copies or derivative
* works are solely in the form of machine-executable object code generated by
* a source language processor.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
* SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
* FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
* DEALINGS IN THE SOFTWARE.
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