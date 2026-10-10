CHMer 1.2.0
Copyright (C) 2019-2026 by Alexey Kolesnikov.
Email: ak@blu-disc.net
Website: https://github.com/AlekseyKolesnikov/CHMer


A simple CHM creation tool.

Requires:
  * Microsoft HTML Help Workshop (https://blu-disc.net/download/htmlhelp.exe) - for CHM
  * build_webhelp.exe next to CHMer.exe (included) - for WebHelp, Python is not needed

Uses:
  * SynEdit (https://github.com/SynEdit/SynEdit)
  * Rx Library (http://www.micrel.cz/RxLib/dfiles.htm)
  * HyperParse by Winston Kotzan (included)
  * PyInstaller (https://pyinstaller.org) - to build build_webhelp.exe

Features:
  * Update HTML titles with tree titles - scans all used htmls and replaces <title>...</title> with the corresponding names of the content tree nodes.
  * Simple validation: checks for unused HTMLs and missed files.
  * Ctrl+Space in the HTML editor opens the context menu for inserting a tag/symbol.
  * Compile WebHelp (Ctrl+F9) - an HTML version of the help with contents, index and search that works from a local folder or a web server. The output folder is set in Project settings (relative to the project folder); when it is empty, the build asks for it, and Shift+click the button selects another one. The folder must be empty or contain a previous WebHelp: it is replaced on every build.
  * CHMer settings, like the WebHelp output folder, are stored in the .hhp as comment lines after "; [CHMer]", so HTML Help Workshop ignores them.

Building build_webhelp.exe:
  The WebHelp is built by WebHelp\build_webhelp.py. WebHelp\build_webhelp_exe.bat compiles it into build_webhelp.exe, so users don't need Python.
  Requires:
    * Python 3.8 or later (https://www.python.org/downloads/windows/). The exe runs on the Windows versions this Python supports (Python 3.8 is the last one for Windows 7) and is 64-bit when this Python is 64-bit.
    * Internet access on the first run: PyInstaller is downloaded into a private virtual environment in %TEMP%\CHMer_build_webhelp, the system Python is not changed.
  Run WebHelp\build_webhelp_exe.bat - it copies build_webhelp.exe to bin and bin64, next to CHMer.exe.
  Run it again after changing build_webhelp.py, webhelp.js or webhelp.css: they are packed into the exe.
