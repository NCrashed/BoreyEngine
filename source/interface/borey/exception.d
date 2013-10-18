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
*   Module defines exception, which will be thrown when something goes wrong.
*/
module borey.exception;
@safe:

import borey.log;

/**
*   Base exception for Borey Engine.
*/
class BoreyException : Exception 
{
    this(lazy string msg, 
        string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, file, line);
    }
}

/**
*   This exception used for fatal errors, that
*   have to be logged any way.
*/
class BoreyLoggedException : BoreyException
{
    this(shared const ILogger logger, lazy string msg,
        string file = __FILE__, size_t line = __LINE__)
    {
        logger.logFatal(msg);
        super(msg, file, line);
    }
}

/**
*   Handy way to handle exception in C callbacks. Taked from
*   http://www.gamedev.net/page/resources/_/technical/general-programming/d-exceptions-and-c-callbacks-r3323
*   Author: Walter Bright
*/
class CallbackThrowable : Throwable 
{
    // This is for the previously saved CallbackThrowable, if any.
    CallbackThrowable nextCT;

    // The file and line params aren't strictly necessary, but they are good
    // for debugging.
    this( Throwable payload, CallbackThrowable t,
            string file = __FILE__, size_t line = __LINE__ ) 
    {
        // Call the superclass constructor that takes file and line info,
        // and make the wrapped exception part of this exception's chain.
        super( "An exception was thrown from a C callback.", file, line, payload );

        // Store a reference to the previously saved CallbackThrowable
        nextCT = t;
    }
    
    // This method aids in propagating non-Exception throwables up the callstack.
    void throwWrappedError() 
    {
        // Test if the wrapped Throwable is an instance of Exception and throw it
        // if it isn't. This will cause Errors and any other non-Exception Throwable
        // to be rethrown.
        if( cast( Exception )next is null ) 
        {
            throw next;
        }
    }

    /**
    *   Wrapper for other modules that only defines callbacks but aren't
    *   able to extract chain by themself.
    */
    static synchronized void storeCallbackThrowable(Throwable payload,
                string file = __FILE__, size_t line = __LINE__) @trusted
    {
        _rethrow = new CallbackThrowable(payload, _rethrow, file, line);
    }

    /**
    *   Checks chain of stored callback exceptions and errors and 
    *   throws them.
    */
    static synchronized void rethrowCallbackThrowables() @trusted
    {
        if( _rethrow !is null ) 
        {
            // Loop through each CallbackThrowable in the chain and rethrow the first
            // non-Exception throwable encountered.    
            for( auto ct = _rethrow; ct !is null; ct = ct.nextCT ) 
            {
                ct.throwWrappedError();
            }
            
            // No Errors were caught, so all we have are Exceptions.
            // Throw the saved CallbackThrowable.
            auto t = _rethrow;
            _rethrow = null;
            throw t;
        }    
    }  
    
    private static __gshared CallbackThrowable _rethrow;
}


