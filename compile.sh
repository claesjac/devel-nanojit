#!/bin/sh

#gcc -DAVMPLUS_UNIX -DJS_NO_FASTCALL -c -o Assembler.o Assembler.cpp
#gcc -DAVMPLUS_UNIX -DJS_NO_FASTCALL -c -o avmplus.o avmplus.cpp
#gcc -DAVMPLUS_UNIX -DJS_NO_FASTCALL -c -o Fragmento.o Fragmento.cpp
#gcc -DAVMPLUS_UNIX -DJS_NO_FASTCALL -c -o LIR.o LIR.cpp
#gcc -DAVMPLUS_UNIX -DJS_NO_FASTCALL -c -o Nativei386.o Nativei386.cpp
#gcc -DAVMPLUS_UNIX -DJS_NO_FASTCALL -c -o RegAlloc.o RegAlloc.cpp

g++ -dynamiclib -o libnanojit.dylib -DFEATURE_NANOJIT -DAVMPLUS_IA32 -DAVMPLUS_UNIX -DJS_NO_FASTCALL Assembler.cpp Fragmento.cpp LIR.cpp Nativei386.cpp RegAlloc.cpp avmplus.cpp