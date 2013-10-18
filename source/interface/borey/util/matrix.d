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
*   Module describes structure for square matrix.
*/
module borey.util.matrix;
@safe:

import borey.util.common : Radian;
import borey.util.vector;
import std.conv;
import std.array;
import std.math;

private T[size] initArray(T,int size)(T value)
{
    T ret[size];
    foreach(ref a; ret)
        a = value;
    return ret;
}

/**
*   Thrown when trying to get matrix without inverse (determinant == 0).
*/
class MatrixNoInverse: Exception
{
    this()
    {
        super("Matrix has no inverse!");
    }
}

/// Squared matrix
/**
*   Usefull with quaternion, vectora and opengl rotations.
*/
struct Matrix(size_t size, StoredType = float)
{
    StoredType m[size*size] = initArray!(StoredType, size*size)(0.0f);

    alias Matrix!(size) thistype;
    /// Vector of StoredType and size
    alias Vector!(StoredType, size) vectorst;
    /// 4d vector of stored type
    alias Vector!(StoredType, 4) vector4t;
    /// 3d vector of stored type
    alias Vector!(StoredType, 3) vector3t;
    /// 2d vector of stored type
    alias Vector!(StoredType, 2) vector2t;

    /// Loads matrix from StoredType array
    /**
    *   Matrix representation is column ordered,
    *   array representation is row ordered.
    *
    *   TODO: Make this func pure, when to!string become pure.
    */
    this(StoredType[size*size] data) @trusted
    {
        assert(data.length == size*size, "Matrix expected data length "~to!string(size*size)~" not a "~to!string(data.length));
        foreach(size_t i,j, ref val; this)
            val = data[j+i*size];
    } 

    pure nothrow
    {
        /**
        *   Loads matrix from rows array
        */
        void loadFromRows(vectorst[size] rows)
        {
            foreach(size_t i, ref row; rows)
            {
                for(size_t j=0; j<size; j++)
                    this[i,j] = row[j];
            }
        }

        /**
        *   Loads matrix from columns array
        */
        void loadFromColumns(vectorst[size] columns)
        {
            foreach(size_t j, ref col; columns)
            {
                for(size_t i=0; i<size; i++)
                    this[i,j] = col[i];
            }       
        }

        /// Zero filled matrix
        static thistype zeros() @property
        {
            thistype mt;
            foreach(ref val;mt.m)
                val = 0.0;
            return mt;
        }

        /// Identity matrix
        static thistype identity() @property
        {
            thistype mt = zeros;
            for(uint i = 0; i < size*size; i+=size+1)
                mt.m[i] = 1;
            return mt;
        }

        /// Matrix filled with ones
        static thistype ones() @property 
        {
            thistype mt;
            foreach(ref val;mt.m)
                val = 1.;   
            return mt;
        }

        StoredType opIndex(size_t i, size_t j) const
        in
        {
            assert( i < size, "Matrix i index overflow!" );
            assert( j < size, "Matrix j index overflow!" );
        }
        body
        {
            return m[i+j*size];
        }

        void opIndexAssign(StoredType val, size_t i, size_t j)
        in
        {
            assert( i < size, "Matrix i index overflow!" );
            assert( j < size, "Matrix j index overflow!" );
        }
        body
        {
            m[i+j*size] = val;
        }

        thistype opBinary(string op)(thistype b) const if(op=="+") 
        {
            auto ret = thistype.zeros;
            foreach(i,ref val; ret.m)
                val = m[i]+b.m[i];
            return ret;
        }

        thistype opBinary(string op)(thistype b) const if(op=="-") 
        {
            auto ret = thistype.zeros;
            foreach(i,ref val; ret.m)
                val = m[i]-b.m[i];
            return ret;
        }   

        vector4t opBinary(string op)(vector4t b) const if(op=="*" && size == 4) 
        {
            vector4t ret;
            ret.x = m[0]*b.x+m[4]*b.y+m[8]*b.z+m[12]*b.w;
            ret.y = m[1]*b.x+m[5]*b.y+m[9]*b.z+m[13]*b.w;
            ret.z = m[2]*b.x+m[6]*b.y+m[10]*b.z+m[14]*b.w;
            ret.w = m[3]*b.x+m[7]*b.y+m[11]*b.z+m[15]*b.w;
            return ret;
        }   

        vector3t opBinary(string op)(vector3t b) const if(op=="*" && size == 3) 
        {
            vector3t ret;
            ret.x = m[0]*b.x+m[3]*b.y+m[6]*b.z;
            ret.y = m[1]*b.x+m[4]*b.y+m[7]*b.z;
            ret.z = m[2]*b.x+m[5]*b.y+m[8]*b.z;
            return ret;
        }

        vector2t opBinary(string op)(vector2t b) const if(op=="*" && size == 2) 
        {
            vector2t ret;
            ret.x = m[0]*b.x+m[2]*b.y;
            ret.y = m[1]*b.x+m[3]*b.y;
            return ret;
        }
    }


    /// Multipling matrix O(n^3)
    thistype opBinary(string op)(const thistype b) const if(op=="*") 
    {
        auto ret = thistype.zeros;
        foreach(size_t i,j, ref val; ret )
        {
            StoredType summ = 0.;
            for(size_t r=0; r<size; r++)
            {
                summ += this[i,r]*b[r,j];
            }
            val = summ;
        }
        return ret;
    }

    /// Iterating over elements
    int opApply(int delegate(ref StoredType) dg) @trusted
    {
        foreach(ref val;m)
        {
            auto result = dg(val);
            if (result) return result;
        }
        return 0;
    }

    /// Iterating over elements
    int opApply(int delegate(size_t, size_t, ref StoredType) dg) @trusted
    {
        foreach(k,ref val;m)
        {
            auto result = dg(cast(size_t)(k%size), cast(size_t)(k/size), val);
            if (result) return result;
        }
        return 0;
    }

    /// Iterating over elements
    int opApply(int delegate(StoredType) dg) const @trusted 
    {
        foreach(ref val;m)
        {
            auto result = dg(val);
            if (result) return result;
        }
        return 0;
    }

    /// Iterating over elements
    int opApply(int delegate(size_t, size_t, StoredType) dg) const @trusted
    {
        foreach(k,ref val;m)
        {
            auto result = dg(cast(size_t)(k%size), cast(size_t)(k/size), val);
            if (result) return result;
        }
        return 0;
    }

    /// Returns matrix row
    vectorst getRow(size_t i) const
    {
        auto ret = new StoredType[size];
        for(size_t j=0; j<size; j++)
        {
            ret[j] = this[i,j];
        }
        return vectorst(ret);
    }

    /// Returns matrix column
    vectorst getColumn(size_t i) const
    {
        auto ret = new StoredType[size];
        for(size_t j=0; j<size; j++)
        {
            ret[j] = this[j,i];
        }
        return vectorst(ret);        
    }

    /// Swaps rows
    void swapRows(size_t i1, size_t i2)
    {
        auto temp = getRow(i2);
        for(size_t j=0; j<size; j++)
        {
            this[i2,j] = this[i1,j];
            this[i1,j] = temp[j];
        }   
    }

    /// Swaps columns
    void swapColumns(size_t i1, size_t i2) 
    {
        auto temp = getColumn(i2);
        for(size_t j=0; j<size; j++)
        {
            this[j,i2] = this[j,i1];
            this[j,i1] = temp[j];
        }       
    }

    pure nothrow
    {
        /// Mult row by value
        void mulRow(size_t i, StoredType value)
        {
            for(size_t j=0; j<size; j++)
                this[i,j] = this[i,j]*value;
        }

        /// Mult column by value
        void mulColumn(size_t j, StoredType value)
        {
            for(size_t i=0; i<size; i++)
                this[i,j] = this[i,j]*value;
        }

        bool opEqual(thistype b) const
        {
            bool ret = true;
            foreach(i, ref val; m)
                ret = ret && val == b.m[i];
            return ret;
        }

        /// Approx equality check
        bool approxEqual(thistype b) const
        {
            bool ret = true;
            foreach(i, ref val; m)
                ret = ret && std.math.approxEqual(val,b.m[i]);
            return ret;     
        }

        static if(is(StoredType == float))
        {
            /// Getting pointer to opengl
            const(float*) toOpenGL() const
            {
                return &m[0];
            }

            /// Getting pointer to opengl
            float* toOpenGL()
            {
                return &m[0];
            }            
        }
    }

    string toString() const @trusted
    {
        auto s = appender!string();
        for(size_t i=0; i<size; i++)
        {
            s.put("| ");
            for(size_t j=0; j<size; j++)
            {
                s.put(to!string(this[i,j]));
                s.put(" ");
            }
            s.put("|\n");
        }
        return s.data;
    }

    /// Creating matrix from opengl matrix
    /**
    *   Warning: Array bounds don't checked!
    */
    static thistype fromOpenGL(float* glMatr) pure nothrow @system
    {
        thistype ret;
        foreach(i,ref val; ret.m)
            val = glMatr[i];
        return ret;
    }

    /// Returns transposed matrix
    thistype transposed() @property const
    {
        auto ret = thistype.zeros;
        foreach(i, j, val; this)
            ret[j,i] = val;
        return ret;
    }

    /// Returns matrix determinant
    /**
    *   Uses Gauss method.
    */
    double determinant() const @property 
    {
        static if(size == 1) return m[0];
        else
        {
            // Copy matrix
            thistype matrix = this;

            // Number of permutations
            uint s = 0;

            // Transforming to triangle-like matrix
            mainloop: for(size_t i = 0; i<size; i++)
            {
                // Special case, if first element is zero, swaps rows
                if(matrix[i,i] == 0)
                {
                    bool failed = true;
                    for(size_t m=i+1; m<size; i++)
                    {
                        if(matrix[m,i] != 0)
                        {
                            s++;
                            matrix.swapRows(i, m);
                            failed = false;
                            break;
                        }
                    }
                    if(failed) break mainloop;              
                }
                // Substract rows
                for(size_t j = i+1; j<size; j++)
                {
                    matrix.substractRows(j, i, matrix[j,i]/matrix[i,i]);
                }
            }

            // Triangle matrix determinant is product of all elements of main diagonal.
            double ret = 1;
            for(size_t i = 0; i<size; i++)
                ret *= matrix[i,i];

            // Sign correction depending on permutations count
            if(s % 2 == 1)
            {
                ret *= -1;
            }   
            return ret; 
        }   
    } 

    /// Returns inversed matrix
    /**
    *   If there is no inversed matrix, throws MatrixNoInverse.
    */
    thistype inverse() @property
    {
        if(this.determinant == 0) 
            throw new MatrixNoInverse();

        static if(size == 1) return 1/m[0];
        else
        {
            // Matrix to be transformed
            thistype ret = thistype.identity;
            thistype matrix = this;

            // Primary pass, transforming to triangle matrix
            mainloop: for(size_t i = 0; i<size; i++)
            {
                // Special case, if first element is zero, swaps rows
                if(matrix[i,i] == 0)
                {
                    bool failed = true;
                    for(size_t m=i+1; m<size; i++)
                    {
                        if(matrix[m,i] != 0)
                        {
                            ret.swapRows(i, m);
                            matrix.swapRows(i, m);
                            failed = false;
                            break;
                        }
                    }
                    if(failed) break mainloop;              
                }
                
                // Divide by first element
                ret.mulRow(i, 1/matrix[i,i]);
                matrix.mulRow(i, 1/matrix[i,i]);

                // Substruct rows
                for(size_t j = i+1; j<size; j++)
                {
                    ret.substractRows(j, i, matrix[j,i]);
                    matrix.substractRows(j, i, matrix[j,i]);
                }
            }

            // Reverse pass, transforming to identity matrix
            for(size_t i=size-1; i>0; i--)
            {
                for(ptrdiff_t j=i-1; j>=0; j--)
                {
                    ret.substractRows(j, i, matrix[j,i]);
                    matrix.substractRows(j, i, matrix[j,i]);                
                } 
            }

            return ret; 
        }               
    }

    /**
    *   Solves system of linear equation system with Gauss Jordan method. Column freeColumn
    *   consits of free constants of equation system. If there is no inverted matrix
    *   (more than one solution), MatrixNoInverse exception is thrown.
    */
    vectorst solveLinear(in vectorst freeColumn) const
    {
        if(this.determinant == 0) 
            throw new MatrixNoInverse();

        static if(size == 1) return vectorst(freeColumn[0]/m[0]);
        else
        {
            // Vector to be transformed
            vectorst ret = freeColumn;
            thistype matrix = this;

            // Primary pass, transforming to triangle matrix
            mainloop: for(size_t i = 0; i<size; i++)
            {
                // Special case, if first element is zero, swaps rows
                if(matrix[i,i] == 0)
                {
                    bool failed = true;
                    for(size_t m=i+1; m<size; i++)
                    {
                        if(matrix[m,i] != 0)
                        {
                            auto temp = ret[i];
                            ret[i] = ret[m];
                            ret[m] = temp;

                            matrix.swapRows(i, m);
                            failed = false;
                            break;
                        }
                    }
                    if(failed) break mainloop;              
                }
                
                // Divide by first element
                ret[i] = ret[i]/matrix[i,i]; 
                matrix.mulRow(i, 1/matrix[i,i]);
                
                // Subscribe rows
                for(size_t j = i+1; j<size; j++)
                {
                    ret[j] = ret[j]-ret[i]*matrix[j,i];
                    matrix.substractRows(j, i, matrix[j,i]);
                }
            }

            // Reverse pass, transforming to identity matrix
            for(size_t i=size-1; i>0; i--)
            {
                for(ptrdiff_t j=i-1; j>=0; j--)
                {
                    ret[j] = ret[j]-ret[i]*matrix[j,i];
                    matrix.substractRows(j, i, matrix[j,i]);            
                } 
            }

            return ret; 
        }                       
    }

    /**
    *   Transfomed matrix to echelon matrix.
    */
    thistype rowEchelon() @property const
    {
        static if(size == 1) return this;
        else
        {
            thistype matrix = this;

            // Primary pass, transform to triangle matrix
            mainloop: for(size_t i = 0; i<size; i++)
            {
                // Special case, if first element is zero, swaps rows
                if(matrix[i,i] == 0)
                {
                    bool failed = true;
                    for(size_t m=i+1; m<size; i++)
                    {
                        if(matrix[m,i] != 0)
                        {
                            matrix.swapRows(i, m);
                            failed = false;
                            break;
                        }
                    }
                    if(failed) break mainloop;              
                }

                // Divide by first element
                matrix.mulRow(i, 1/matrix[i,i]);

                // Subscribe rows
                for(size_t j = i+1; j<size; j++)
                {
                    matrix.substractRows(j, i, matrix[j,i]);
                }

            }
            return matrix;
        }       
    }

    /**
    *   Calculates rang of the matrix
    */
    size_t rang() @property const
    {
        auto matrix = rowEchelon;

        size_t ret = 0;
        for(size_t i = 0; i<size; i++)
        {
            if(matrix.getRow(i) != vectorst(0.0f,0.0f,0.0f))
                ret+=1;
        }
        return ret;                         
    }

    /**
    *   Maps function func to each element of matrix.
    */
    void apply(alias func)()
    {
        static assert(__traits(compiles, "func(0.0f)"), "Function "~func.stringof~" cannot be called with (float)");
        foreach(i,j,ref val; this)
            val = func(val);
    }

    private
    {
        /// Subtract one row multipled by value from another row. row(k1)-row(k2)*val
        void substractRows(size_t k1, size_t k2, double val)
        {
            auto kv2 = getRow(k2)*val;
            for(size_t i = 0; i<size; i++)
            {
                this[k1,i] = this[k1,i]-kv2[i];
            }
        }   
    }
}

@trusted unittest
{
    import std.stdio;

    write("Testing matrixes module...");
    scope(success) writeln("Finished!");
    scope(failure) writeln("Failed!");

    auto a = Matrix!(2).zeros;
    auto b = Matrix!(2).ones;
    auto c = Matrix!(2).identity;

    assert(a[0,0] == 0, "Generation zeros fails!");
    assert(b[0,0] == 1, "Generation ones fails!");
    assert(c[0,0] == 1 && c[1,0] == 0, "Generation identity fails!");

    b = b+b;
    assert(b[0,0] == 2 && b[1,0] == 2 && b[0,1] == 2 && b[1,1] == 2, "Summing failed!");

    b = c*b;
    assert(b[0,0] == 2 && b[1,0] == 2 && b[0,1] == 2 && b[1,1] == 2, "Multiplication failed!");

    auto aa = Matrix!(4).zeros;
    aa[0,0] = 1; aa[0,1] = 2; aa[0,2] = 3; aa[0,3] = 4;
    aa[1,0] = 5; aa[1,1] = 6; aa[1,2] = 7; aa[1,3] = 8;
    aa[2,0] = 9; aa[2,1] = 10; aa[2,2] = 11; aa[2,3] = 12;
    aa[3,0] = 13; aa[3,1] = 14; aa[3,2] = 15; aa[3,3] = 16;

    auto bb = Matrix!(4).zeros;
    bb[0,0] = 16; bb[0,1] = 15; bb[0,2] = 14; bb[0,3] = 13;
    bb[1,0] = 12; bb[1,1] = 11; bb[1,2] = 10; bb[1,3] = 9;
    bb[2,0] = 8; bb[2,1] = 7; bb[2,2] = 6; bb[2,3] = 5;
    bb[3,0] = 4; bb[3,1] = 3; bb[3,2] = 2; bb[3,3] = 1;

    Matrix!(4) cc = aa*bb;

    assert(
        cc[0,0] == 80 && cc[0,1] == 70 && cc[0,2] == 60 && cc[0,3] == 50 &&
        cc[1,0] ==240 && cc[1,1] ==214 && cc[1,2] ==188 && cc[1,3] ==162 &&
        cc[2,0] ==400 && cc[2,1] ==358 && cc[2,2] ==316 && cc[2,3] ==274 &&
        cc[3,0] ==560 && cc[3,1] ==502 && cc[3,2] ==444 && cc[3,3] ==386,"Multiplication failed!");

    auto aat = aa.transposed;
    assert(
        aat[0,0] == 1 && aat[0,1] == 5 && aat[0,2] == 9 && aat[0,3] == 13 &&
        aat[1,0] == 2 && aat[1,1] == 6 && aat[1,2] ==10 && aat[1,3] == 14 &&
        aat[2,0] == 3 && aat[2,1] == 7 && aat[2,2] ==11 && aat[2,3] == 15 &&
        aat[3,0] == 4 && aat[3,1] == 8 && aat[3,2] ==12 && aat[3,3] == 16,"Transpose failed!"); 

    // Test determinant
    auto m1 = Matrix!(3)([
        1.0f, 2.0f, 3.0f,
        4.0f, 5.0f, 6.0f,
        7.0f, 8.0f, 9.0f
        ]);
    assert(m1.determinant == 0, "Determinant failed!");

    auto m2 = Matrix!(3)([
        0.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 0.0f,
        2.0f, 2.0f, 2.0f
        ]);
    assert(m2.determinant == 0, "Determinant failed!");

    auto m3 = Matrix!(3)([
        4.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 0.0f,
        0.0f, 0.0f, 2.0f
        ]);
    assert(m3.determinant == -2, "Determinant failed!");    

    auto m4 = Matrix!(3)([
        4.0f, 1.0f, 1.0f,
        1.0f, 0.0f, 5.0f,
        0.0f,25.0f, 2.0f
        ]);
    assert(m4.determinant == -477, "Determinant failed!");      

    // Test inverse
    auto m5 = Matrix!(3)([
        1.0f, 1.0f, 1.0f,
        4.0f, 2.0f, 1.0f,
        9.0f, 3.0f, 1.0f        
        ]);
    auto m5i = Matrix!(3)([
         0.5f,-1.0f, 0.5f,
        -2.5f, 4.0f,-1.5f,
         3.0f,-3.0f, 1.0f       
        ]);
    assert(m5.inverse == m5i, "Inverse failed!");

    auto m6 = Matrix!(3)([
        3.0f, 2.0f, 2.0f,
        1.0f, 3.0f, 1.0f,
        5.0f, 3.0f, 4.0f        
        ]);
    auto m6i = Matrix!(3)([
          1.8f,-0.4f,-0.8f,
          0.2f, 0.4f,-0.2f,
         -2.4f, 0.2f, 1.4f      
        ]);
    assert(m6.inverse.approxEqual(m6i), "Inverse failed!"); 

    // Test Gauss-Jordan
    auto m7 = Matrix!(3)([
        1.0f, 1.0f, 1.0f,
        4.0f, 2.0f, 1.0f,
        9.0f, 3.0f, 1.0f        
        ]); 
    auto m7free = m7.vectorst(0,1,3);
    assert(m7.solveLinear(m7free) == m7.vectorst(0.5,-0.5,0), "Linear solve failed!");

    // Test apply
    auto m8 = Matrix!(3)([
        1.0f, 1.0f, 1.0f,
        4.0f, 2.0f, 1.0f,
        9.0f, 3.0f, 1.0f        
        ]); 

    auto m8e = Matrix!(3)([
        E, E, E,
        exp(4.0f), exp(2.0f), E,
        exp(9.0f), exp(3.0f), E     
        ]); 
    m8.apply!(exp)();

    assert(m8.approxEqual(m8e), "Apply failed!");   

    // Test matrix rang
    auto m9 = Matrix!(3)([
        -0.17f, 0.17f, 0.0f,
        0.0f, -0.17f, 0.17f,
        0.08f, 0.0f, -0.08f     
        ]);
    assert(m9.rang == 2, "Rang failed!");
}

/**
*   Returns matrix that translate vector by (x, y, z) vector.
*/
Matrix!4 translateMtrx(float x, float y, float z) pure nothrow 
{
    Matrix!4 ret;
    ret[0,0] = 1.0f; ret[0,1] = 0.0f; ret[0,2] = 0.0f; ret[0,3] = x;
    ret[1,0] = 0.0f; ret[1,1] = 1.0f; ret[1,2] = 0.0f; ret[1,3] = y;
    ret[2,0] = 0.0f; ret[2,1] = 0.0f; ret[2,2] = 1.0f; ret[2,3] = z;
    ret[3,0] = 0.0f; ret[3,1] = 0.0f; ret[3,2] = 0.0f; ret[3,3] = 1.0f;
    return ret;
} 

/**
*   Returns matrix that scale vector by (x, y, z) vector.
*/
Matrix!4 scaleMtrx(float x, float y, float z)  pure nothrow
{
    Matrix!4 ret;
    ret[0,0] = x   ; ret[0,1] = 0.0f; ret[0,2] = 0.0f; ret[0,3] = 0.0f;
    ret[1,0] = 0.0f; ret[1,1] = y   ; ret[1,2] = 0.0f; ret[1,3] = 0.0f;
    ret[2,0] = 0.0f; ret[2,1] = 0.0f; ret[2,2] = z   ; ret[2,3] = 0.0f;
    ret[3,0] = 0.0f; ret[3,1] = 0.0f; ret[3,2] = 0.0f; ret[3,3] = 1.0f;
    return ret;
} 

/**
*   Returns matrix from Euler angles.
*/
Matrix!4 rotationMtrx(float pitch, float yaw, float roll) pure nothrow
{
    Matrix!4 ret;
    ret[0,0] = cos(yaw)*cos(roll);  ret[0,1] = -cos(pitch)*sin(roll)+sin(pitch)*sin(yaw)*cos(roll);     ret[0,2] = sin(pitch)*sin(roll)+cos(pitch)*sin(yaw)*cos(roll);  ret[0,3] = 0.0f;
    ret[1,0] = cos(yaw)*sin(roll);  ret[1,1] = cos(pitch)*cos(roll)+sin(pitch)*sin(yaw)*sin(roll);      ret[1,2] = -sin(pitch)*cos(roll)+cos(pitch)*sin(yaw)*sin(roll); ret[1,3] = 0.0f;
    ret[2,0] = -sin(yaw);           ret[2,1] = sin(pitch)*cos(yaw);                                     ret[2,2] = cos(pitch)*cos(yaw);                                 ret[2,3] = 0.0f;
    ret[3,0] = 0.0f;                ret[3,1] = 0.0f;                                                    ret[3,2] = 0.0f;                                                ret[3,3] = 1.0f;
    return ret; 
}

@trusted unittest
{
    import std.stdio;
    import std.conv;
    import std.math;
    import borey.util.vector;

    write("Testing rotation matrix... ");
    scope(success) writeln("Finished!");
    scope(failure) writeln("Failed!");

    auto a = vector4df(1,0,0,1);
    a = rotationMtrx(0,PI/2.,0)*a;
    assert(approxEqual(a.x,0) && approxEqual(a.z, -1) && a.y == 0 && a.w == 1, "Vertex rotation failed: "~to!string(a));

    a = rotationMtrx(PI/2, 0, 0)*a;
    assert(approxEqual(a.x,0) && approxEqual(a.y, 1) && approxEqual(a.z, 0) && a.w == 1, "Vertex rotation failed: "~to!string(a));
}

/// Returns rotation matrix from Euler matrix
/**
*   See_also: version for 4 dimensional vectors.
*/
Matrix!3 rotationMtrx3(float pitch, float yaw, float roll)
{
    Matrix!3 ret;
    ret[0,0] = cos(yaw)*cos(roll);  ret[0,1] = -cos(pitch)*sin(roll)+sin(pitch)*sin(yaw)*cos(roll);     ret[0,2] = sin(pitch)*sin(roll)+cos(pitch)*sin(yaw)*cos(roll); 
    ret[1,0] = cos(yaw)*sin(roll);  ret[1,1] = cos(pitch)*cos(roll)+sin(pitch)*sin(yaw)*sin(roll);      ret[1,2] = -sin(pitch)*cos(roll)+cos(pitch)*sin(yaw)*sin(roll); 
    ret[2,0] = -sin(yaw);           ret[2,1] = sin(pitch)*cos(yaw);                                     ret[2,2] = cos(pitch)*cos(yaw);                                 
    return ret; 
}

/// Returns perspective projection matrix
/**
*   Matrix transforms camera coordinates into window space.
*   Params:
*   fovy   = Viewing angle in radians. Usually around [30..90] degrees.
*   aspect = Relation between vieport height and width.
*   zNear  = Near clipping plane.
*   zFar   = Far clipping plane.
*
*   Notes: Resulting matrix usually used to get MVP matrix (Model-View-Projection).
*/
Matrix!4 projection(Radian fovy, float aspect, float zNear, float zFar)
{
    float top = zNear*tan(fovy/2.0f);
    float right = top / aspect;

    /*Matrix!4 getProj(float l, float r, float b, float t, float n, float f)
    {
        Matrix!4 ret;
        ret[0,0] = 2*n/(r-l);   ret[0,1] = 0.0f;        ret[0,2] = (r+l)/(r-l);         ret[0,3] = 0.0f;
        ret[1,0] = 0.0f;        ret[1,1] = 2*n/(t-b);   ret[1,2] = (t+b)/(t-b);         ret[1,3] = 0.0f;
        ret[2,0] = 0.0f;        ret[2,1] = 0.0f;        ret[2,2] = -(f+n)/(f-n);        ret[2,3] = -2*f*n/(f-n);
        ret[3,0] = 0.0f;        ret[3,1] = 0.0f;        ret[3,2] = -1.0f;               ret[3,3] = 0.0f;    
        return ret;
    }*/

    Matrix!4 getProj(float r, float t, float n, float f)
    {
        Matrix!4 ret;
        ret[0,0] = n/r;         ret[0,1] = 0.0f;        ret[0,2] = 0.0f;                ret[0,3] = 0.0f;
        ret[1,0] = 0.0f;        ret[1,1] = n/t;         ret[1,2] = 0.0f;                ret[1,3] = 0.0f;
        ret[2,0] = 0.0f;        ret[2,1] = 0.0f;        ret[2,2] = -(f+n)/(f-n);        ret[2,3] = -2*f*n/(f-n);
        ret[3,0] = 0.0f;        ret[3,1] = 0.0f;        ret[3,2] = -1.0f;               ret[3,3] = 0.0f;    
        return ret;
    }

    return getProj(right, top, zNear, zFar);
}

/// Returns camera matrix
/**
*   Matrx transforms world coordinates into camera space.
*   Params:
*   eye = Camera position.
*   at  = Camera target.
*   up  = Camera up direction.
*
*   Notes: Resulting matrix is used to construct MVP matrix (Model-View-Projection).
*/
Matrix!4 lookAt(vector3df eye, vector3df at, vector3df up)
{
    auto zaxis = at-eye;
    zaxis.normalize();
    auto xaxis = up.cross(zaxis);
    xaxis.normalize();
    auto yaxis = zaxis.cross(xaxis);

    Matrix!4 ret;
    //ret[0,0] = xaxis.x;         ret[0,1] = yaxis.x;         ret[0,2] = zaxis.x;         ret[0,3] = 0.0f;
    //ret[1,0] = xaxis.y;         ret[1,1] = yaxis.y;         ret[1,2] = zaxis.y;         ret[1,3] = 0.0f;
    //ret[2,0] = xaxis.z;         ret[2,1] = yaxis.z;         ret[2,2] = zaxis.z;         ret[2,3] = 0.0f;
    //ret[3,0] = -xaxis.dot(eye); ret[3,1] = -yaxis.dot(eye); ret[3,2] = -zaxis.dot(eye); ret[3,3] = 1.0f;  

    ret[0,0] = xaxis.x;         ret[0,1] = xaxis.y;         ret[0,2] = xaxis.z;         ret[0,3] = -xaxis.dot(eye);
    ret[1,0] = yaxis.x;         ret[1,1] = yaxis.y;         ret[1,2] = yaxis.z;         ret[1,3] = -yaxis.dot(eye);
    ret[2,0] = zaxis.x;         ret[2,1] = zaxis.y;         ret[2,2] = zaxis.z;         ret[2,3] = -zaxis.dot(eye);
    ret[3,0] = 0.0f;            ret[3,1] = 0.0f;            ret[3,2] = 0.0f;            ret[3,3] = 1.0f;    

    return ret; 
}

/// TransformedVector = ScaleMatrix * RotationMatrix * TranslationMatrix * OriginalVector;