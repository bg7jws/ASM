;findfile.asm
;ml /c /coff findfile.asm
;link /subsystem:console findfile.obj

.386
.model flat,stdcall
option casemap:none
include C:\masm32\include\windows.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\kernel32.inc
includelib C:\masm32\lib\masm32.lib
includelib C:\masm32\lib\kernel32.lib

SearchForFile   PROTO   :DWORD,:DWORD

.data
CRLF            EQU <0dh,0ah>
szUsage         db 'findfile <filename>',CRLF,0
szPrompt        db 'sample for find file with name.',CRLF,0
stDir           db 'C:',256 dup(0)
szBuf           db 128 dup(0)
.code


start:                
        invoke  StdOut, addr szPrompt
        invoke  ArgClC,1,addr szBuf
        cmp     eax,1
        jnz     no_arg
        cmp     byte ptr[szBuf],00h
        jz      no_arg
        invoke  SearchForFile,addr stDir,addr szBuf
        leave_prog:
                invoke ExitProcess,0
        no_arg:
                invoke StdOut,addr szUsage
        jmp     leave_prog        


SearchForFile   PROC    StartPath:DWORD,FileToFind:DWORD
                LOCAL   WFD:WIN32_FIND_DATA
                LOCAL   fPath[260]:BYTE
                LOCAL   fPath2[260]:BYTE
                LOCAL   hFind:DWORD
                jmp @F
                WildCard        db '\*',0
                foundat         db 'Found: ',0
                szCRLF          db CRLF,0
                @@:
                        lea edi,fPath
                        push edi
                        mov esi,StartPath
                        mov ecx,256
                        rep movsb
                        pop edi

                        xor al,al
                        scasb
                        jnz $-1
                        dec edi         ;用于在fPath里面找到最后一个空字符

                        mov al,'\'      ;然后在后面补充\*用于生成完整的函数参数fPath
                        stosb
                        mov al,'*'
                        stosb

                        lea edi,WFD.cFileName
                        mov ecx,260
                        xor al,al
                        rep stosb       ;清空cFileName区域准备找到文件时读入文件相关信息

                        invoke FindFirstFile,addr fPath,addr WFD
                        push eax
                        mov hFind,eax
                        pop ebx

                        .while ebx>0
                                lea esi,WFD.cFileName
                                lodsw
                                .if AX!=02e2eh && AX!=0002eh
                                        lea edi,WFD
                                        mov eax,[edi]
                                        .if ax & FILE_ATTRIBUTE_DIRECTORY       ;if it is a dir
                                                sub esi,2
                                                lea edi,fPath2
                                                push edi
                                                xor al,al
                                                mov ecx,260
                                                rep stosb
                                                mov edi,[esp]
                                                lea eax,fPath
                                                invoke lstrcpy,edi,eax
                                                mov al,'*'                      ;find * and change to 00
                                                scasb
                                                jnz $-1
                                                dec edi
                                                mov byte ptr[edi],00h
                                                invoke lstrcat,edi,esi          ;link full name to fPath2
                                                pop edi

                                                pushad
                                                invoke SearchForFile,edi,FileToFind     ;in sub-dir re-find
                                                popad
                                        .else
                                        sub esi,2               ;it is file, compare them
                                        invoke lstrcmpi,FileToFind,esi
                                        or eax,eax              ;make an operation only for next jz use
                                        jz found_file
                                        .endif
                                .endif
                                
                                lea edi,WFD.cFileName           ;clear last find
                                mov ecx,260
                                xor al,al
                                rep stosb
                                
                                invoke FindNextFile,hFind,addr WFD
                                mov ebx,eax
                        .endw
        _cls_fnd:
                invoke FindClose,hFind
                ret
        found_file:
        lea edi,fPath2
        invoke lstrcpy,edi,addr fPath           ;fPath copy to fPath2,and find * change to 00
        mov al,'*'                              ;then link cFileName to fPath2

        scasb
        jnz $-1
        dec edi
        mov byte ptr[edi],00h
        lea edi,WFD.cFileName
        invoke lstrcat,addr fPath2,edi

        invoke StdOut,addr foundat
        invoke StdOut,addr fPath2
        invoke StdOut,addr szCRLF 
        jmp _cls_fnd
SearchForFile   ENDP
end start