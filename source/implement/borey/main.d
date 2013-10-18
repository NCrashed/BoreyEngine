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
*   Util module to initialize engine shared library.
*/
module borey.main;

import borey.core;
import borey.simplecore;

import core.runtime; 
import core.memory;
import std.c.stdlib; 
import std.string; 

version(BOREY_DYNAMIC_LOADING)
{
    extern (C) 
    { 
        void* gc_getProxy();
    } 

    version(Windows)
    {
        import std.c.windows.windows; 

        HINSTANCE g_hInst; 
        size_t counter;

        extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) 
        { 
            switch (ulReason) 
            { 
                case DLL_PROCESS_ATTACH: 
                {
                    if(counter == 0)
                        Runtime.initialize(); 
                    counter += 1;
                    break; 
                }
                case DLL_PROCESS_DETACH: 
                {
                    if(counter == 0)
                        Runtime.terminate();
                    else
                        counter -= 1; 
                    break; 
                }
                case DLL_THREAD_ATTACH: 
                    return false; 
                case DLL_THREAD_DETACH:
                    return false; 
            } 

            g_hInst = hInstance; 
            return true; 
        } 
    } 
}

extern(C)
{
    /**
    *   Setups gc proxy, should be called when loading library.
    */
    export void* boreyEngineInitialize() 
    { 
        version(BOREY_DYNAMIC_LOADING)
            return gc_getProxy(); 
        else
            return null;
    } 

    /**
    *   Terminates library, cleares gc proxy. Should be called when
    *   unloading library.
    */
    export void boreyEngineTerminate() 
    { 
    }

    /**
    *   Creates borey core and sends it to the application.
    */
    export IBoreyCore createBoreyCore()
    {
        return new SimpleBoreyCore();
    }
}

version(unittest)
{
    void main() {}
}