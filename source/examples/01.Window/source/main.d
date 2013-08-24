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
*   Borey Engine first example. It shows how to create window and
*   handle basic window events.
*/
module main;

import borey.core;
import borey.util.loader.loader;
import std.stdio;
import std.conv;

int main(string[] args)
{
    // Initializing core
    auto boreyCore = initBoreyCore();
    // Terminate when living main scope
    scope(exit) boreyCore.terminate();

    // Create window
    auto window = boreyCore.createWindow(640, 480, "Test window");
    // Example for fullscreen
    //auto window = boreyCore.createWindow(640, 480, "Test window", boreyCore.primaryMonitor());

    // Binding delegates for window events
    window.posChangedDelegate = 
        (win, x, y) @trusted => boreyCore.logger.logNotice(text("Window pos is now: (",x,",",y,")"));
    
    window.sizeChangedDelegate = 
        (win, width, height) @trusted => boreyCore.logger.logNotice(text("Window size is now: (", width, ",", height, ")"));
    
    window.framebufferSizeChangedDelegate =
        (win, width, height) @trusted => boreyCore.logger.logNotice(text("Window framebuffer size is now: (", width, ",", height, ")"));
   
    window.closeDelegate = 
        (win) @trusted => boreyCore.logger.logNotice(text("Window is closing!"));

    window.focusChangedDelegate = 
        (win, flag) @trusted => boreyCore.logger.logNotice(text("Window focused: ", flag));
    
    window.minimizedDelegate = 
        (win, flag) @trusted => boreyCore.logger.logNotice(text("Window iconified: ", flag));

    // Start infinite event-drawing loop
    boreyCore.runEventLoop();
    return 0;
}