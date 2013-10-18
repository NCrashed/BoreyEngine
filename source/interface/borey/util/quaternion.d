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
*   Module describes quaternion structure used for rotation.
*/
module borey.util.quaternion;

import borey.util.vector;
import borey.util.matrix;
import borey.util.common : Radian;

import std.math;
import std.conv;

/// Normalization accuracy
/**
*   Without this equality checks will be
*   unrobust.
*/
private enum TEST_DELTA = 0.0001;

private immutable Quaternion ZERO_QUATERNION = Quaternion(0,0,0,0);
private immutable Quaternion UNIT_QUATERNION = Quaternion(1,0,0,0);

/// Mathematic object to descirbe rotations.
struct Quaternion
{
    double x = 0.0;
    double y = 0.0;
    double z = 0.0;
    double w = 0.0;

    pure nothrow
    {
        /**
        *   Returns quaternion filled with zeros.
        */
        static Quaternion ZERO() @property
        {
            return ZERO_QUATERNION;
        }

        /**
        *   Returns quaternion presenting no rotation.
        */
        static Quaternion UNIT() @property
        {
            return UNIT_QUATERNION;
        }

        /// Default constructor
        this(double x, double y, double z, double w)
        {
            this.x = x;
            this.y = y;
            this.z = z;
            this.w = w;
        }

        /// Creating from axis and angle
        /**
        *   @par vAxis rotation axis
        *   @par angle angle to rotate in radians
        */
        this(vector3df vAxis, Radian angle)
        {
            set(vAxis, angle);
        }

        /// Creating from Euler angles
        this(double pitch, double yaw, double roll)
        {
            double cos_z_2 = cos(0.5*roll);
            double cos_y_2 = cos(0.5*yaw);
            double cos_x_2 = cos(0.5*pitch);

            double sin_z_2 = sin(0.5*roll);
            double sin_y_2 = sin(0.5*yaw);
            double sin_x_2 = sin(0.5*pitch);

            // and now compute quaternion
            w = cos_z_2*cos_y_2*cos_x_2 + sin_z_2*sin_y_2*sin_x_2;
            x = cos_z_2*cos_y_2*sin_x_2 - sin_z_2*sin_y_2*cos_x_2;
            y = cos_z_2*sin_y_2*cos_x_2 + sin_z_2*cos_y_2*sin_x_2;
            z = sin_z_2*cos_y_2*cos_x_2 - cos_z_2*sin_y_2*sin_x_2;
        }

        /// Creating from 3x3 rotation matrix
        this(Matrix!(3) m)
        {
            double tr = m[0,0] + m[1,1] + m[2,2]; // trace of martix
            if (tr > 0.0f)  // if trace positive than "w" is biggest component
            {    
                x = (m[1,2] - m[2,1]);
                y = (m[2,0] - m[0,2]);
                z = (m[0,1] - m[1,0]);
                w = (tr+1.0f);
                auto t = 0.5/sqrt( w );  // "w" contain the "norm * 4"
                x*=t;
                y*=t;
                z*=t;
                w*=t;
            }
            else if( (m[0,0] > m[1,1] ) && ( m[0,0] > m[2,2]) )  // Some of vector components is bigger
            {
                x = (1.0f + m[0,0] - m[1,1] - m[2,2]);
                y = (m[1,0] + m[0,1]);
                z = (m[2,0] + m[0,2]);
                w = (m[1,2] - m[2,1]);
                auto t = 0.5/sqrt( x ); 
                x*=t;
                y*=t;
                z*=t;
                w*=t;
            }
            else if ( m[1,1] > m[2,2] )
            {
                x = m[1,0] + m[0,1];
                y = 1.0f + m[1,1] - m[0,0] - m[2,2];
                z = m[2,1] + m[1,2];
                w = m[2,0] - m[0,2]; 
                auto t = 0.5/sqrt( y ); 
                x*=t;
                y*=t;
                z*=t;
                w*=t;
            }
            else
            {
                x = m[2,0] + m[0,2];
                y = m[2,1] + m[1,2];
                z = 1.0f + m[2,2] - m[0,0] - m[1,1];
                w = m[0,1] - m[1,0];
                auto t = 0.5/sqrt( z ); 
                x*=t;
                y*=t;
                z*=t;
                w*=t;
            }
        }

        /// Transforms to 4x4 rotation matrix
        Matrix!(4) toMatrix() const
        {
            Matrix!(4) ret;
            double wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2;
            auto s  = 2./length();  // 4 mul 3 add 1 div
            x2 = x * s;    y2 = y * s;    z2 = z * s;
            xx = x * x2;   xy = x * y2;   xz = x * z2;
            yy = y * y2;   yz = y * z2;   zz = z * z2;
            wx = w * x2;   wy = w * y2;   wz = w * z2;

            ret[0,0] = 1.0f - (yy + zz);
            ret[1,0] = xy - wz;
            ret[2,0] = xz + wy;

            ret[0,1] = xy + wz;
            ret[1,1] = 1.0f - (xx + zz);
            ret[2,1] = yz - wx;

            ret[0,2] = xz - wy;
            ret[1,2] = yz + wx;
            ret[2,2] = 1.0f - (xx + yy);
            ret[3,3] = 1.0f;
            return ret;
        }

        /// Resets quaternion
        /**
        *   @par vAxis rotation axis
        *   @par angle angle to rotate in radians
        */
        void set(vector3df vAxis, Radian angle)
        {
            vAxis.normalize();

            // Normalizing angle
            while(angle >= PI*2)
            {
                angle -= PI*2;
            }
            while(angle <= -PI*2)
            {
                angle += PI*2;
            }

            auto t = sin(angle/2);
            x = vAxis.x*t;
            y = vAxis.y*t;
            z = vAxis.z*t;
            w = cos(angle/2);
        }

        /// Returns vector rotation is about
        vector3df axis() const @property
        {
            vector3df ret;
            auto angle = acos(w);
            auto t = sin(acos(w));
            ret.x = x/t;
            ret.y = y/t;
            ret.z = z/t;
            return ret;
        }

        /// Returns vector part
        vector3df vec() const @property
        {
            vector3df ret;
            ret.x = x;
            ret.y = y;
            ret.z = z;
            return ret;
        }

        /// Setups vector part
        void vec(vector3df v) @property
        {
            x = v.x;
            y = v.y;
            z = v.z;
        }

        /// Returns scalar part
        double scalar() const @property
        {
            return w;
        }

        /// Setups scalar part
        void scalar(double val) @property
        {
            w = val;
        }

        /// Returns angle rotation is about
        double angle() const @property
        {
            return 2*acos(w);
        }

        Quaternion opBinary(string op)(Quaternion q) const if(op=="+") 
        {
            Quaternion ret;
            ret.x = x + q.x;
            ret.y = y + q.y;
            ret.z = z + q.z;
            ret.w = w + q.w;
            return ret;
        }

        Quaternion opBinary(string op)(Quaternion q) const if(op=="-") 
        {
            Quaternion ret;
            ret.x = x - q.x;
            ret.y = y - q.y;
            ret.z = z - q.z;
            ret.w = w - q.w;
            return ret;
        }

        Quaternion opBinary(string op)(Quaternion q) const if(op=="*") 
        {
            Quaternion ret; // a = w, b = x, c = y, d = z
            ret.x = w*q.x + x*q.w + y*q.z - z*q.y; // a1*b2+b1*a2+c1*d2-d1*c2
            ret.y = w*q.y - x*q.z + y*q.w + z*q.x; // a1*c2-b1*d2+c1*a2+d1*b2
            ret.z = w*q.z + x*q.y - y*q.x + z*q.w; // a1*d2+b1*c2-c1*b2+d1*a2
            ret.w = w*q.w - x*q.x - y*q.y - z*q.z; // a1*a2-b1*b2-c1*c2-d1*d2
            return ret;
        }

        /// Length
        double length() @property const
        {
            return sqrt(w*w + x*x + y*y + z*z);
        }

        /// Squared length
        double length2() @property const
        {
            return w*w + x*x + y*y + z*z;
        }

        /// Quaternion conjugation (inverting w component)
        Quaternion conjugation() @property const
        {
            Quaternion ret;
            ret.x = x;
            ret.y = y;
            ret.z = z;
            ret.w = -w;
            return ret;
        }

        /// Sets quaternion length to 1
        void normalize()
        {
            auto l = length;
            x = x/l;
            y = y/l;
            z = z/l;
        }

        Quaternion normalized() const
        {
            Quaternion ret;
            auto l = length;
            ret.x = x/l;
            ret.y = y/l;
            ret.z = z/l;
            ret.w = w;
            return ret;
        }

        /// Inverted quaternion, conjugation + normalization
        Quaternion invert() const
        {
            Quaternion ret = conjugation();
            auto l = length;
            ret.x /= l;
            ret.y /= l;
            ret.z /= l;
            return ret;
        }
    }

    /// Rotates vector by this quaternion
    /**
    *   Param v - vector to be rotated.
    *
    *   TODO: When to!string become pure, make this func pure.
    */
    vector3df rotate(vector3df v) nothrow
    in
    {
        assert(abs(length-1.0)<=TEST_DELTA, "Quaternion need to be prepared with method 'prepare', length ("~to!string(length)~") with accuracy ("~to!string(TEST_DELTA)~") didn't match expected value (1).");  
    }
    body    
    {
        Quaternion vq;
        vq.vec = v;
        vq.w = 0.0f;
        auto vqt = this*vq*conjugation();
        return vqt.vec*(-1);
    }

    /// Rotates vector by axis and angle
    /**
    *   Static version of rotate. Vector and angle
    *   is transformed into quaternion and vector v
    *   will be rotated around getted quaternion.
    *
    *   Returns: rotated vector
    *   TODO: When to!string become pure, make this func pure.
    */
    static vector3df rotate(vector3df v, vector3df vAxis, Radian angle) nothrow
    {
        auto q = Quaternion(vAxis, angle);
        return q.rotate(v);
    }


    /// Transform to 3 dimensional vector
    T opCast(T)() const pure nothrow if(is(T == vector3df)) 
    {
        return vec.normalized*scalar;
    }    
}

unittest
{
    import std.stdio;
    import std.math;
    import std.conv;

    import borey.util.matrix;

    write("Testing quaternion... ");
    scope(success) writeln("Finished!");
    scope(failure) writeln("Failed!");

    Quaternion quat = Quaternion(vector3df(0,1,0), PI/2.0f);
    auto vec = quat.rotate(vector3df(1.0f,0.0f,0.0f));
    //assert(approxEqual(vec.x,0) && vec.y == 0 && approxEqual(vec.z,1), "Quaternion rotation failed! v="~to!string(vec)); 

    vec = quat.rotate(vec);
    //assert(approxEqual(vec.x,-1) && vec.y == 0 && approxEqual(vec.z,0), "Quaternion rotation failed! v="~to!string(vec)); 

    // Heavy testing of rotations, matrix and quaternion rotation must be equal!
    vector3df a = vector3df(1.0f,2.0f,3.0f);

    for(float angle = 0.0f; angle <= 2*PI; angle+=PI/20.0f)
    {
        auto b = rotationMtrx3(angle, 0.0f, 0.0f)*a;
        auto q = Quaternion(angle, 0.0f, 0.0f);
        auto c = q.rotate(a);
        assert(b == c, text("Rotation pitch test failed for angle = ",angle,". ",b," != ", c));
    }

    a = vector3df(1.0f,2.0f,3.0f);
    for(float angle = 0.0f; angle <= 2*PI; angle+=PI/20.0f)
    {
        auto b = rotationMtrx3(0.0f, angle, 0.0f)*a;
        auto q = Quaternion(0.0f, angle, 0.0f);
        auto c = q.rotate(a);
        assert(b == c, text("Rotation yaw test failed for angle = ",angle,". ",b," != ", c));
    }

    a = vector3df(1.0f,2.0f,3.0f);
    for(float angle = 0.0f; angle <= 2*PI; angle+=PI/20.0f)
    {
        auto b = rotationMtrx3(0.0f, 0.0f, angle)*a;
        auto q = Quaternion(0.0f, 0.0f, angle);
        auto c = q.rotate(a);
        assert(b == c, text("Rotation roll test failed for angle = ",angle,". ",b," != ", c));
    }

}