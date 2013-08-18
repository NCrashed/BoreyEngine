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
*   Module provides derelict style loader for Borey Engine implementation.
*
*   Example demonstates low-level way to load implementation lib with
*   setting garbage collector proxy. Application will use the shared lib
*   gc.
*
*   Example:
*   -------
*   extern(C) 
*   {
*       void gc_setProxy(void* p); 
*       void gc_clrProxy(); 
*   }
*
*   void loadEngine()
*   {
*      DerelictBorey.load(); // loads implementation lib
*       
*      gc_setProxy(boreyEngineInitialize()); // sets proxy for library
*      
*      // unloading library
*      gc_clrProxy();
*      boreyEngineTerminate();
*
*      DerelictBorey.unload(); // optional, will be called when terminating application
*   }
*   -------
*/
module borey.util.loader.loader;
@trusted:

public import borey.util.loader.functions;
import borey.core;

version(BOREY_DYNAMIC_LOADING)
{
    import borey.exception;
    import std.conv;

    private
    {
        import derelict.util.loader;
        import derelict.util.system;
        import derelict.util.exception;

        static if(Derelict_OS_Windows)
            enum libNames = "borey-engine.dll";
        else static if(Derelict_OS_Posix)
            enum libNames = "libborey-engine.so, ./libborey-engine.so";
        else
            static assert(0, "Need to implement Borey Engine libNames for this operating system.");
    }

    class BoreyEngineLoader : SharedLibLoader
    {
        protected
        {
            override void loadSymbols()
            {
                try
                {
                    bindFunc(cast(void**)&boreyEngineInitialize, "boreyEngineInitialize");
                    bindFunc(cast(void**)&boreyEngineTerminate, "boreyEngineTerminate");
                    bindFunc(cast(void**)&createBoreyCore, "createBoreyCore");
                } 
                catch(DerelictException e)
                {
                    throw new BoreyException(text("Failed to load Borey Engine implementation! Details: ", e.msg));
                }
            }
        }

        public
        {
            this()
            {
                super(libNames);
            }
        }
    }

    __gshared BoreyEngineLoader DerelictBorey;

    shared static this()
    {
        DerelictBorey = new BoreyEngineLoader();
    }

    private
    {
        import borey.util.loader.loader;
        import core.atomic;

        shared bool isCoreLoaded = false;

        extern(C) 
        {
           void gc_setProxy(void* p); 
           void gc_clrProxy(); 
        }
    }

    /**
    *   Loads implementaton lib and queries core with specified characteristics.
    *   Note: concurrency safe.
    */
    IBoreyCore initBoreyCore() @trusted
    {
        if(!atomicLoad(isCoreLoaded)) 
        {
            DerelictBorey.load(); // loads implementation lib
            gc_setProxy(boreyEngineInitialize()); // sets proxy for library
            atomicStore(isCoreLoaded, true);
        }

        return createBoreyCore();
    }

    shared static ~this()
    {
        if(cas(&isCoreLoaded, true, false))
        {
            // unloading library
            gc_clrProxy();
            boreyEngineTerminate();        
        }
        DerelictBorey.unload();
    }
}
else
{
    /**
    *   Loads implementaton lib and queries core with specified characteristics.
    *   Note: concurrency safe.
    */
    IBoreyCore initBoreyCore() @trusted
    {
        return createBoreyCore();
    }

    shared static this()
    {
        boreyEngineInitialize();
    }

    shared static ~this()
    {
        boreyEngineTerminate();
    }
}