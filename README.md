Preambula
=========

Recently i was porting Irrlicht engine to D programming language, i like it structure separated into interface 
and releazation layers. But when i stared porting realization, i came with a lot of C++ styled code, which hard
to port to D in pretty way. I don't need majority of the Irrlicht features such as: deprecated devices, software
renderers, quake scene nodes and so on. Thefore i decided to create simple in use D-style graphic engine.


Borey Engine
============
The main goal of the project is provide crossplatform easy in use graphic engine. It architecture based on
implementation-realization separation to simplify interaction with users. Currently releazation is based
on GLFW3 library and OpenGL, may be in future i will add DirectX and/or SDL releazation.

**Borey Engine is on very early developmen stage, api can change dramatically at any moment!**

Requirements
===========
You need:
* [GLFW3 library](https://github.com/glfw/glfw)
* OpenGL compatible drivers
* [dub](http://code.dlang.org/download)

Compilation
===========

Until engine is not published in dub packate registry:
```
git clone https://github.com/ncrashed/BoreyEngine
cd BoreyEngine
dub build
```

And examples:
```
dub add-local . ~master
cd source/examples/<example-you-want>
dub build
```

License
=======

Engine is publishing under GPLv3 license. See LICENSE file.
