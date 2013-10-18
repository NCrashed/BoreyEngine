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
module borey.video.shader.base;

import borey.exception;
import borey.log;
import borey.resource.item;
import borey.resource.fabric;
import std.conv;
import std.stream;

/**
*   Thrown when shader compilation problems occure.
*/
class ShaderCompilationException : BoreyLoggedException
{
    /// Name of shader (usually resource location)
    string name;

    this(shared const ILogger logger, string name, lazy string msg,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        super(logger, text("Failed to compile shader ", name, ". Reason:\n", msg),
            file, line);
    }
}

/**
*   Thrown when shader compilation problems occure.
*/
class ShaderCheckException : BoreyLoggedException
{
    /// Name of shader (usually resource location)
    string name;

    this(shared const ILogger logger, string name, lazy string msg,
        string file = __FILE__, size_t line = __LINE__)
    {
        this.name = name;
        super(logger, text("Shader check up is failed! Shader name: ", name, ". Reason:\n", msg),
            file, line);
    }
}

/**
*   Interface to shared functionality between vertex and fragment
*   shaders, such as setting input values, loading and compiling.
*/
interface IShaderResource: IResource 
{
    /**
    *   Returns loaded shader id.
    */
    uint id() @property;
}

/**
*   Fabric for shaders resources. Will automatically compile
*   and check shader on loading.
*/
interface IShaderFabric : IResourceFabric
{
    /**
    *   Loading shader from resouce (ex. file).
    *   Will perform compilation and throw ShaderCompilationException if failed.
    *   After compilation shader is checked and if something is wrong ShaderCheckException 
    *   exception is thrown.
    *
    *   Throws: ShaderCompilationException, ShaderCheckException
    */
    override shared(IShaderResource) load(InputStream stream, string fullName, string extension);
}