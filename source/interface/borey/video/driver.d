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
*   Incapsulates drawing pipeline.
*/
module borey.video.driver;
@safe:

import borey.video.model;
import borey.scene.manager;

/**
*   Handles shaders loading, object retrieving from scene manager, loading
*   hardware buffers into video memory and actually drawing.
*/
interface IVideoDriver
{
    /**
    *   Returns information about incapsulated graphical API.
    *   For instance: 'OpenGL 3.2' or 'DirectX 11'.
    */
    string description() const @property;

    /**
    *   Load context and underlying drawing services.
    *   Should be called after first window contex is created.
    */
    void initialize();

    /**
    *   Performs scene drawing including view frustum culling,
    *   applying different materials and model cashing.
    */
    void draw(shared ISceneManager manager);

    protected
    {
        
    }
}