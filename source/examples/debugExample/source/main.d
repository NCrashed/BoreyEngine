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
*   Debug example, changes occasionally.
*/
module main;

import borey.core;
import borey.util.loader.loader;
import std.stdio;
import std.conv;

int main(string[] args)
{
    auto boreyCore = initBoreyCore();
    scope(exit) boreyCore.terminate();

    writeln(boreyCore.getVersion());
    writeln(boreyCore.copyright);
    writeln("Can engine handle many windows: ", boreyCore.supportManyWindows);

    boreyCore.logger.logNotice("Hi, it is test log message!");

    auto window = boreyCore.createWindow(640, 480, "Test window");

    boreyCore.runEventLoop();
    return 0;
}