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
*   Describe mapping from GLFW3 keys to Borey keys.
*/
module borey.glfwkeymap;
@safe:

import borey.keyboard;
import borey.mouse;
import derelict.glfw3.types;

/**
*   Constructs KeyState from glfw3 raw information.
*/
KeyState fromGLFWKeyState(int key, int scancode, int action, int mods) pure nothrow
{
    KeyState keyState;
    keyState.key = fromGLFWKey(key);
    keyState.scancode = cast(uint)scancode;

    switch(action)
    {
        case GLFW_PRESS:
        {
            keyState.position = KeyPosition.PRESS;
            break;
        }
        case GLFW_RELEASE:
        {
            keyState.position = KeyPosition.RELEASE;
            break;
        }
        case GLFW_REPEAT:
        {
            keyState.position = KeyPosition.REPEAT;
            break;
        }
        default:
        {
            // invalid program state
            keyState.position = KeyPosition.PRESS;
        }
    }

    keyState.shift = (mods & GLFW_MOD_SHIFT) == GLFW_MOD_SHIFT;
    keyState.control = (mods & GLFW_MOD_CONTROL) == GLFW_MOD_CONTROL;
    keyState.alt = (mods & GLFW_MOD_ALT) == GLFW_MOD_ALT;
    keyState._super = (mods & GLFW_MOD_SUPER) == GLFW_MOD_SUPER;

    return keyState;
}

/**
*   Constructs MouseButtonState from glfw3 raw information.
*/
MouseButtonState fromGLFWButtonState(int button, int action, int mods) pure nothrow
{
    MouseButtonState buttonState;
    buttonState.button = fromGLFWButton(button);

    switch(action)
    {
        case GLFW_PRESS:
        {
            buttonState.position = MouseButtonPosition.PRESS;
            break;
        }
        case GLFW_RELEASE:
        {
            buttonState.position = MouseButtonPosition.RELEASE;
            break;
        }
        default:
        {
            // invalid program state
            buttonState.position = MouseButtonPosition.PRESS;
        }
    }

    buttonState.shift = (mods & GLFW_MOD_SHIFT) == GLFW_MOD_SHIFT;
    buttonState.control = (mods & GLFW_MOD_CONTROL) == GLFW_MOD_CONTROL;
    buttonState.alt = (mods & GLFW_MOD_ALT) == GLFW_MOD_ALT;
    buttonState._super = (mods & GLFW_MOD_SUPER) == GLFW_MOD_SUPER;

    return buttonState;
}

/**
*   Converts GLFW3 mouse button to Borey button.
*/
MouseButton fromGLFWButton(int button) pure nothrow
{
    switch(button)
    {
        case GLFW_MOUSE_BUTTON_LEFT:
            return MouseButton.LEFT;
        case GLFW_MOUSE_BUTTON_RIGHT:
            return MouseButton.RIGHT;
        case GLFW_MOUSE_BUTTON_MIDDLE:
            return MouseButton.MIDDLE;
        case GLFW_MOUSE_BUTTON_4:
            return MouseButton.BUTTON_4;
        case GLFW_MOUSE_BUTTON_5:
            return MouseButton.BUTTON_5;
        case GLFW_MOUSE_BUTTON_6:
            return MouseButton.BUTTON_6;
        case GLFW_MOUSE_BUTTON_7:
            return MouseButton.BUTTON_7;
        case GLFW_MOUSE_BUTTON_8:
            return MouseButton.BUTTON_8;
        default:
            return MouseButton.BUTTON_1;
    }
}

/**
*   Converts GLFW3 key to Borey key.
*/
Key fromGLFWKey(int key) pure nothrow @trusted
{
    switch(key)
    {
        case GLFW_KEY_SPACE:
            return Key.SPACE;
        case GLFW_KEY_APOSTROPHE:
            return Key.APOSTROPHE;
        case GLFW_KEY_COMMA:
            return Key.COMMA;
        case GLFW_KEY_MINUS:
            return Key.MINUS;
        case GLFW_KEY_PERIOD:
            return Key.PERIOD;
        case GLFW_KEY_SLASH:
            return Key.SLASH;
        case GLFW_KEY_0:
            return Key.KEY_0;
        case GLFW_KEY_1:
            return Key.KEY_1;
        case GLFW_KEY_2:
            return Key.KEY_2;
        case GLFW_KEY_3:
            return Key.KEY_3;
        case GLFW_KEY_4:
            return Key.KEY_4;
        case GLFW_KEY_5:
            return Key.KEY_5;
        case GLFW_KEY_6:
            return Key.KEY_6;
        case GLFW_KEY_7:
            return Key.KEY_7;
        case GLFW_KEY_8:
            return Key.KEY_8;
        case GLFW_KEY_9:
            return Key.KEY_9;
        case GLFW_KEY_SEMICOLON:
            return Key.SEMICOLON;
        case GLFW_KEY_EQUAL:
            return Key.EQUAL;
        case GLFW_KEY_A:
            return Key.A;
        case GLFW_KEY_B:
            return Key.B;
        case GLFW_KEY_C:
            return Key.C;
        case GLFW_KEY_D:
            return Key.D;
        case GLFW_KEY_E:
            return Key.E;
        case GLFW_KEY_F:
            return Key.F;
        case GLFW_KEY_G:
            return Key.G;
        case GLFW_KEY_H:
            return Key.H;
        case GLFW_KEY_I:
            return Key.I;
        case GLFW_KEY_J:
            return Key.J;
        case GLFW_KEY_K:
            return Key.K;
        case GLFW_KEY_L:
            return Key.L;
        case GLFW_KEY_M:
            return Key.M;
        case GLFW_KEY_N:
            return Key.N;
        case GLFW_KEY_O:
            return Key.O;
        case GLFW_KEY_P:
            return Key.P;
        case GLFW_KEY_Q:
            return Key.Q;
        case GLFW_KEY_R:
            return Key.R;
        case GLFW_KEY_S:
            return Key.S;
        case GLFW_KEY_T:
            return Key.T;
        case GLFW_KEY_U:
            return Key.U;
        case GLFW_KEY_V:
            return Key.V;
        case GLFW_KEY_W:
            return Key.W;
        case GLFW_KEY_X:
            return Key.X;
        case GLFW_KEY_Y:
            return Key.Y;
        case GLFW_KEY_Z:
            return Key.Z;
        case GLFW_KEY_LEFT_BRACKET:
            return Key.LEFT_BRACKET;
        case GLFW_KEY_BACKSLASH:
            return Key.BACKSLASH;
        case GLFW_KEY_RIGHT_BRACKET:
            return Key.RIGHT_BRACKET;
        case GLFW_KEY_GRAVE_ACCENT:
            return Key.GRAVE_ACCENT;
        case GLFW_KEY_WORLD_1:
            return Key.WORLD_1;
        case GLFW_KEY_WORLD_2:
            return Key.WORLD_2;
        case GLFW_KEY_ESCAPE:
            return Key.ESCAPE;
        case GLFW_KEY_ENTER:
            return Key.ENTER;
        case GLFW_KEY_TAB:
            return Key.TAB;
        case GLFW_KEY_BACKSPACE:
            return Key.BACKSPACE;
        case GLFW_KEY_INSERT:
            return Key.INSERT;
        case GLFW_KEY_DELETE:
            return Key.DELETE;
        case GLFW_KEY_RIGHT:
            return Key.RIGHT;
        case GLFW_KEY_LEFT:
            return Key.LEFT;
        case GLFW_KEY_DOWN:
            return Key.DOWN;
        case GLFW_KEY_UP:
            return Key.UP;
        case GLFW_KEY_PAGE_UP:
            return Key.PAGE_UP;
        case GLFW_KEY_PAGE_DOWN:
            return Key.PAGE_DOWN;
        case GLFW_KEY_HOME:
            return Key.HOME;
        case GLFW_KEY_END:
            return Key.END;
        case GLFW_KEY_CAPS_LOCK:
            return Key.CAPS_LOCK;
        case GLFW_KEY_SCROLL_LOCK:
            return Key.SCROLL_LOCK;
        case GLFW_KEY_NUM_LOCK:
            return Key.NUM_LOCK;
        case GLFW_KEY_PRINT_SCREEN:
            return Key.PRINT_SCREEN;
        case GLFW_KEY_PAUSE:
            return Key.PAUSE;
        case GLFW_KEY_F1:
            return Key.F1;
        case GLFW_KEY_F2:
            return Key.F2;
        case GLFW_KEY_F3:
            return Key.F3;
        case GLFW_KEY_F4:
            return Key.F4;
        case GLFW_KEY_F5:
            return Key.F5;
        case GLFW_KEY_F6:
            return Key.F6;
        case GLFW_KEY_F7:
            return Key.F7;
        case GLFW_KEY_F8:
            return Key.F8;
        case GLFW_KEY_F9:
            return Key.F9;
        case GLFW_KEY_F10:
            return Key.F10;
        case GLFW_KEY_F11:
            return Key.F11;
        case GLFW_KEY_F12:
            return Key.F12;
        case GLFW_KEY_F13:
            return Key.F13;
        case GLFW_KEY_F14:
            return Key.F14;
        case GLFW_KEY_F15:
            return Key.F15;
        case GLFW_KEY_F16:
            return Key.F16;
        case GLFW_KEY_F17:
            return Key.F17;
        case GLFW_KEY_F18:
            return Key.F18;
        case GLFW_KEY_F19:
            return Key.F19;
        case GLFW_KEY_F20:
            return Key.F20;
        case GLFW_KEY_F21:
            return Key.F21;
        case GLFW_KEY_F22:
            return Key.F22;
        case GLFW_KEY_F23:
            return Key.F23;
        case GLFW_KEY_F24:
            return Key.F24;
        case GLFW_KEY_F25:
            return Key.F25;
        case GLFW_KEY_KP_0:
            return Key.KP_0;
        case GLFW_KEY_KP_1:
            return Key.KP_1;
        case GLFW_KEY_KP_2:
            return Key.KP_2; 
        case GLFW_KEY_KP_3:
            return Key.KP_3;   
        case GLFW_KEY_KP_4:
            return Key.KP_4;
        case GLFW_KEY_KP_5:
            return Key.KP_5;
        case GLFW_KEY_KP_6:
            return Key.KP_6;
        case GLFW_KEY_KP_7:
            return Key.KP_7;
        case GLFW_KEY_KP_8:
            return Key.KP_8;
        case GLFW_KEY_KP_9:
            return Key.KP_9;
        case GLFW_KEY_KP_DECIMAL:
            return Key.KP_DECIMAL;
        case GLFW_KEY_KP_DIVIDE:
            return Key.KP_DIVIDE;
        case GLFW_KEY_KP_MULTIPLY:
            return Key.KP_MULTIPLY;
        case GLFW_KEY_KP_SUBTRACT:
            return Key.KP_SUBTRACT;
        case GLFW_KEY_KP_ADD:
            return Key.KP_ADD;
        case GLFW_KEY_KP_ENTER:
            return Key.KP_ENTER;
        case GLFW_KEY_KP_EQUAL:
            return Key.KP_EQUAL;
        case GLFW_KEY_LEFT_SHIFT:
            return Key.LEFT_SHIFT;
        case GLFW_KEY_LEFT_CONTROL:
            return Key.LEFT_CONTROL;
        case GLFW_KEY_LEFT_ALT:
            return Key.LEFT_ALT;
        case GLFW_KEY_LEFT_SUPER:
            return Key.LEFT_SUPER;
        case GLFW_KEY_RIGHT_SHIFT:
            return Key.RIGHT_SHIFT;
        case GLFW_KEY_RIGHT_CONTROL:
            return Key.RIGHT_CONTROL;
        case GLFW_KEY_RIGHT_ALT:
            return Key.RIGHT_ALT;
        case GLFW_KEY_RIGHT_SUPER:
            return Key.RIGHT_SUPER;
        case GLFW_KEY_MENU:
            return Key.MENU;
        case GLFW_KEY_UNKNOWN:
            goto default;
        default:
            return Key.UNKNOWN;
    }
}