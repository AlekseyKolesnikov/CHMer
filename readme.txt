CHMer 1.0.11
Copyright (C) 2019-2020 by Alexey Kolesnikov.
Email: ak@blu-disc.net
Website: https://github.com/AlekseyKolesnikov/CHMer


A simple CHM creation tool.

Requires:
  * Microsoft HTML Help Workshop (https://blu-disc.net/download/htmlhelp.exe)

Uses: 
  * SynEdit (https://github.com/SynEdit/SynEdit)
  * Rx Library (http://www.micrel.cz/RxLib/dfiles.htm)
  * HyperParse by Winston Kotzan (included)

Features:
  * Update HTML titles with tree titles - scans all used htmls and replaces <title>...</title> with the corresponding names of the content tree nodes.
  * Check unused HTMLs - compares all htmls in the project with all htmls in the project folder.
