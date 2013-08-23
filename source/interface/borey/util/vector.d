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
*   Module describes 2d, 3d and 4d vectors.
*/
module borey.util.vector;
@safe:

import std.math;
import std.traits;
import std.array;
import std.conv;
import borey.util.quaternion;
import borey.util.common : Radian;

alias Vector!(float,4) vector4df;
alias Vector!(float,3) vector3df;
alias Vector!(float,2) vector2df;

alias Vector!(int, 4) vector4di;
alias Vector!(int, 3) vector3di;
alias Vector!(int, 2) vector2di;

alias Vector!(uint, 4) vector4du;
alias Vector!(uint, 3) vector3du;
alias Vector!(uint, 2) vector2du;

alias Vector!(long, 4) vector4dl;
alias Vector!(long, 3) vector3dl;
alias Vector!(long, 2) vector2dl;

alias Vector!(ulong, 4) vector4dul;
alias Vector!(ulong, 3) vector3dul;
alias Vector!(ulong, 2) vector2dul;

alias Vector!(size_t, 4) vector4dst;
alias Vector!(size_t, 3) vector3dst;
alias Vector!(size_t, 2) vector2dst;

immutable ZUNIT = vector3df(0,0,1);
immutable XUNIT = vector3df(1,0,0);
immutable YUNIT = vector3df(0,1,0);
immutable ZVEC = vector3df(0,0,0);

private T[size] initArray(T,int size)(T value)
{
    T ret[size];
    foreach(ref a; ret)
        a = value;
    return ret;
}

/// Templated vector struct
/**
*   Vector with defined stored type and dimention size.
*   StType describes stored type.
*   size represent dimension count.
*   Notes: Vectors can be caste to each other.
*   Notes: Cross product make sense only for 2d and 3d vectors.
*   For 2d vectors result is 3d vector. 4d vectors w component will
*   be ignored.
*/
struct Vector(StType, uint size)
{
    /**
    *   Stored type
    */
    alias StType StorageType;

    /**
    *   Components count
    */
    enum dimentions = size;

    static if(isFloatingPoint!(StType))
    {
        StType m[size] = initArray!(StType,size)(0.0);
    } else
    {
        StType m[size];
    }

    alias Vector!(StType, size) thistype;

    /**
    *   TODO: When to become pure, make this pure.
    */
    this(StType[] vals...) @trusted
    {
        assert(vals.length == size, "Passed wrong arguments count to "~thistype.stringof~" constructor! Needed: "~to!string(size)~", but geted: "~to!string(vals.length));
        foreach(i,ref val; m)
            val = vals[i];
    }

    pure nothrow @property 
    {
        static if(size > 0)
        {
            StType x() const 
            {
                return m[0];
            }

            void x(StType val) 
            {
                m[0] = val;
            }
        }

        static if(size > 1)
        {
            StType y() const 
            {
                return m[1];
            }

            void y(StType val) 
            {
                m[1] = val;
            }
        }

        static if(size > 2)
        {
            StType z() const 
            {
                return m[2];
            }

            void z(StType val) 
            {
                m[2] = val;
            }
        }

        static if(size > 3)
        { 
            StType w() const 
            {
                return m[3];
            }

            void w(StType val) 
            {
                m[3] = val;
            }
        }
    }

    pure nothrow
    {
        /// Read access
        StType opIndex(size_t i) const
        in
        {
            assert( i < size, "Vector i index overflow!" );
        }
        body
        {
            return m[i];
        }

        /// Write access
        void opIndexAssign(StType val, size_t i)
        in
        {
            assert( i < size, "Vector i index overflow!" );
        }
        body
        {
            m[i] = val;
        }

        /// Transform 4->3 
        T opCast(T)() const if(is(T==Vector!(StType,3)) && size == 4) 
        {
            Vector!(StType,3) v;
            v.x = x;
            v.y = y;
            v.z = z;
            return v;
        }

        /// Transform 4->2 
        T opCast(T)() const if(is(T==Vector!(StType,2)) && size == 4)  
        {
            Vector!(StType,2) v;
            v.x = x;
            v.y = y;
            return v;
        }   

        /// Transform 3->4 
        T opCast(T)() const if(is(T==Vector!(StType,4)) && size == 3) 
        {
            Vector!(StType,4) v;
            v.x = x;
            v.y = y;
            v.z = z;
            static if(isFloatingPoint!(StType))
            {
                v.w = 0.0;
            }
            return v;
        }

        /// Transform 3->2 
        T opCast(T)() const if(is(T==Vector!(StType,2)) && size == 3) 
        {
            Vector!(StType,2) v;
            v.x = x;
            v.y = y;
            return v;
        }   

        /// Transform 2->4 
        T opCast(T)() const if(is(T==Vector!(StType,4)) && size == 2) 
        {
            Vector!(StType,4) v;
            v.x = x;
            v.y = y;
            static if(isFloatingPoint!(StType))
            {
                v.z = 0.0;
                v.w = 0.0;
            }
            return v;
        }   

        /// Transform 2->3 
        T opCast(T)() const if(is(T==Vector!(StType,3)) && size == 2) 
        {
            Vector!(StType,3) v;
            v.x = x;
            v.y = y;
            static if(isFloatingPoint!(StType))
            {
                v.z = 0.0;
            }
            return v;
        }

        /// Scalar product
        StType dot(thistype v) const
        {
            StType temp;
            static if(isFloatingPoint!(StType))
            {
                temp = 0.0;
            }       

            foreach(i,val; v.m)
                temp += m[i]*val;

            return temp;
        }

        /// Projection on vector v
        thistype project(thistype v) const
        {
            auto vn = v.normalized();
            return this.dot(vn)*vn;
        }

        /// Унарный минус
        thistype opUnary(string op)() const if(op == "-") 
        {
            thistype ret;
            foreach(i,val; m)
                ret.m[i] = -val;
            return ret;
        }

        thistype opBinary(string op)(thistype v) const if (op == "+") 
        {
            thistype ret;
            foreach(i,val;v.m)
                ret.m[i] = m[i]+val;

            return ret;
        }

        auto ref thistype opOpAssign(string op)(thistype v) if(op == "+")
        {
            foreach(i,val; v.m)
                m[i] += val;
            return this;
        }

        thistype opBinary(string op)(thistype v) const if (op == "-") 
        {
            thistype ret;
            foreach(i,val;v.m)
                ret.m[i] = m[i]-val;

            return ret;
        }

        auto ref thistype opOpAssign(string op)(thistype v) if(op == "-")
        {
            foreach(i,val; v.m)
                m[i] -= val;

            return ret;
        }

        thistype opBinary(string op)(StType val) const if (op == "*") 
        {
            thistype ret;
            foreach(i,coord; m)
                ret.m[i] = coord*val;

            return ret;
        }

        auto ref thistype opOpAssign(string op)(StType val) if (op == "*")
        {
            foreach(ref mval; m)
                mval *= val;

            return ret;
        }

        thistype opBinaryRight(string op)(StType val) const if (op == "*") 
        {
            thistype ret;
            foreach(i,coord; m)
                ret.m[i] = coord*val;

            return ret;
        }

        bool opEquals(thistype v) const
        {
            bool ret = true;
            foreach(i,coord; v.m)
                ret = ret && approxEqual(m[i], coord);

            return ret;
        }

        /**
        *   Angle betweens this and v in radians.
        */
        Radian angle(thistype v) const
        {
            return cast(double)(dot(v)/length);
        }

        /// Vector length
        double length() const @property
        {
            StType temp;
            static if(isFloatingPoint!(StType))
            {
                temp = 0.;
            }   

            foreach(val; m)
                temp += val*val;

            return sqrt(cast(double)(temp));
        }

        /// Vector length squared
        /**
        *   Much more fast than length
        */
        double length2() const @property
        {
            StType temp;
            static if(isFloatingPoint!(StType))
            {
                temp = 0.;
            }   

            foreach(val; m)
                temp += val*val;

            return cast(double)(temp);
        }

        /// Set length of vector to 1
        void normalize()
        {
            auto l = length;
            foreach(ref val; m)
                val /= l;
        }

        /// Return new vector which length is 1 and oriented same way
        thistype normalized() const
        {
            thistype ret;
            auto l = length;
            foreach(i,val; m)
                ret[i] = cast(StType)(val/l);
            return ret;
        }

        static if(size == 3 || size == 4)
        {
            /// Cross product
            thistype cross(thistype v) const
            {
                thistype ret;
                ret.x = y*v.z - v.y*z;
                ret.y = v.x*z - x*v.z;
                ret.z = x*v.y - v.x*y;
                static if(size == 4 && isFloatingPoint!(StType))
                {
                    ret.w = 0;
                }
                return ret;
            }
        }

        static if(size == 2)
        {
            /// Cross product
            Vector!(StType, 3) cross(thistype v)
            {
                Vector!(StType, 3) ret;
                ret.z = x*v.y - v.x*y;
                return ret;     
            }
        }

        static if(size == 3 && isFloatingPoint!StType)
        {
            /// Casting to quaternion
            T opCast(T)() if(is(T==Quaternion))
            {
                return Quaternion.create(normalized, length);
            }
        }
    }
}

@trusted unittest
{
    import std.stdio;
    import std.math;
    import std.conv;

    write("Testing vectors... ");
    scope(success) writeln("Finished!");
    scope(failure) writeln("Failed!");

    vector3df a;
    a.x = 1;
    a.y = 2;
    a.z = 3;

    vector3df b;
    b.x = 3;
    b.y = 2;
    b.z = 1;

    auto c = a.cross(b);
    assert( c.x == -4 && c.y == 8 && c.z == -4, "Vector cross product failed! "~ to!string(c));

    a.normalize();
    assert(approxEqual(a.length, 1.), "Normalization test failed!" );
}