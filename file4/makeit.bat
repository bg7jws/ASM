ml /c /coff  %1.asm
link /subsystem:console %1.obj
del %1.obj
dir %1.*
