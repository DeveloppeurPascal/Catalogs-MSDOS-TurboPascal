@echo off
set code=index
lha a c:\olf_soft\lzh\%code% *.doc *.msq *.exe setup.cfg
set code=
echo on
