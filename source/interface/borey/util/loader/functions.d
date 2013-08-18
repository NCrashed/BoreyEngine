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
*   Module describes functions, which exported from engine implementation.
*/
module borey.util.loader.functions;
@safe:

import borey.core;

version(BOREY_DYNAMIC_LOADING)
{
    nothrow extern(C)
    {
        /**
        *   Initializes implementation shared library. Usually only setups
        *   proxy for garbage collector.
        *
        *   Returns:
        *       Library garbage collector, which application can use as proxy.
        */
        alias void* function() da_boreyEngineInitialize;

        /**
        *   Shut downs implementation shared library. Usually only clears
        *   proxy for garbage collector.
        */
        alias void function() da_boreyEngineTerminate;

        /**
        *   Main function imported from implementation lib. Creates
        *   engine core and returns it as interface.
        */
        alias IBoreyCore function() da_createBoreyCore;
    }

    __gshared
    {
        da_boreyEngineInitialize boreyEngineInitialize;
        da_boreyEngineTerminate boreyEngineTerminate;
        da_createBoreyCore createBoreyCore;
    }
}
else
{   
    extern(C)
    {
        /**
        *   Initializes implementation shared library. Usually only setups
        *   proxy for garbage collector.
        *
        *   Warning: For static linking with implementation library you should'not
        *   use gc proxy, it is reduntant.
        *
        *   Returns:
        *       Library garbage collector, which application can use as proxy.
        */ 
        extern void* boreyEngineInitialize();

        /**
        *   Shut downs implementation shared library. Usually only clears
        *   proxy for garbage collector.
        *
        *   Warning: For static linking with implementation library you should'not
        *   use gc proxy, it is reduntant.
        */
        extern void  boreyEngineTerminate();

        /**
        *   Main function imported from implementation lib. Creates
        *   engine core and returns it as interface.
        */
        extern IBoreyCore createBoreyCore(); 
    }
}