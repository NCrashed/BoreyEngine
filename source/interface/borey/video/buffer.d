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
*   Module describes hardware buffers storing 3D and 2D verticies and
*   indexes. Buffers have to watch their data and reload it to hardware
*   if needed. Also buffers should be concurrent safe to handle dynamic
*   geometry.
*/
module borey.video.buffer;

import borey.util.vector;
import std.range;

/**
*   Watched buffer. If data is changed, should be reloaded to hardware.
*/
interface IHardwareBuffer
{
    /**
    *   Returns true if someone changed buffer data and the hardware
    *   data should be reloaded.
    *
    *   Note: should be noblocking to not block rendering thread.
    */
    bool dataChanged() @property;

    /**
    *   Loads buffer data to hardware. Called while initializing and
    *   when data is changed.
    *
    *   Note: synchronized to be shure no write operations is performed.
    */
    synchronized void hardwareLoad();
}

/**
*   Buffer storing 3D vertices.
*/
interface IVertexBuffer3D : IHardwareBuffer
{
    /**
    *   Clears buffer and loads vertex range into buffer.
    */
    synchronized void load(InputRange!vector3df data);
}

/**
*   Buffer storing 2D vertices.
*/
interface IVertexBuffer2D : IHardwareBuffer
{
    /**
    *   Clears buffer and loads vertex range into buffer.
    */
    synchronized void load(InputRange!vector2df data);
}

/**
*   Buffer storing indexes.
*/
interface IIndexBuffer : IHardwareBuffer
{
    /**
    *   Clears buffer and loads vertex range into buffer.
    */
    synchronized void load(InputRange!uint data);
}