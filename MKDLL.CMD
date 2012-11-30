@echo off
if "%1"=="/?" goto error

link386 /A:4 /BASE:0x12000000 /NOD /NOL mkres.obj, RXASTRES.dll, nul, , mkres;

rc RXASTRES.RC RXASTRES.DLL

goto end
:error
echo Usage: MKDLL
:end
