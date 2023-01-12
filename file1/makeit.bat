rem makeit bat file
ml /c /coff  %1.asm
link /subsystem:windows %1.obj
del %1.obj
dir %1.*
