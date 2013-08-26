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
*   Module describes mouse buttons and button states.
*/
module borey.mouse;
@safe:

import std.bitmanip;

/// Describes mouse buttons
enum MouseButton
{
    BUTTON_1 = 0,
    BUTTON_2 = 1,
    BUTTON_3 = 2,
    BUTTON_4 = 3,
    BUTTON_5 = 4,
    BUTTON_6 = 5,
    BUTTON_7 = 6,
    BUTTON_8 = 7,
    LEFT  = BUTTON_1,
    RIGHT = BUTTON_2,
    MIDDLE = BUTTON_3
}

/// Describes mouse button position: pressed or relased.
enum MouseButtonPosition
{
    PRESS,
    RELEASE
}

/**
*   Describes mouse button state to pass into input callbacks.
*/
struct MouseButtonState
{
    /// Mouse button pressed/released
    MouseButton button;
    /// Pressed/released
    MouseButtonPosition position;

    /// Modifier key flags 
    mixin(bitfields!( 
        bool, "shift",   1, 
        bool, "control", 1, 
        bool, "alt",     1, 
        bool, "_super",  1,
        uint, "",        4));    
}