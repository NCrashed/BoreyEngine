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
    this(lazy string msg)
    {
        super(msg);
    }
}

/**
*   This exception used for fatal errors, that
*   have to be logged any way.
*/
class BoreyLoggedException : BoreyException
{
    this(shared ILogger logger, lazy string msg)
    {
        logger.logFatal(msg);
        super(msg);
    }
}
