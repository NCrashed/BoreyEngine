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