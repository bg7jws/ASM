.586p
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
MBR_Size        equ 512
szTextBufSize   equ 1000h*2

.data
hDevice         dd ?                            ;hd handle
dwNumberOfBytesRead     dd ?
MBR             db MBR_Size dup(?)              ;MBR buffer
hMessage        DD ?                            ;Messagebox handle
szHD            db '\\.\\physicaldrive0',0      ;hd device name
szFmt           db '%08X: %02X %02X %02X %02X %02X %02X %02X %02X-%02X %02X %02X %02X %02X %02X %02X %02X ',0
szSucMsg0       db 'HardDisk Master Boot Record',0
szErrMsg1       db 'HDD Read Error',0
szErrMsg2       db 'Can not open HardDisk',0

.code
;input: pDATA=buffer here is MBR buffer,dwoffset=offset from buffer here is 0,dwsize=size of buffer here is 200h
;output:hex list for dwsize bytes
;call:  invoke PrinfHexDump,addr MBR,0,MBR_Size

PrintHexDump    proc uses esi edi ebx pDATA:DWORD,dwoffset:DWORD,dwsize:DWORD
LOCAL           dwcurrentoffset:DWORD           ;save offset for temp
LOCAL           pTextBuffer:DWORD               ;address for list text buffer
LOCAL           szTextBuf[2000h]:BYTE
;invoke          GetProcessHeap
;invoke          HeapAlloc,eax,HEAP_NO_SERIALIZE + HEAP_ZERO_MEMORY,szTextBufSize
lea     eax,szTextBuf
mov     pTextBuffer,eax
.if eax !=NULL
        mov pTextBuffer,eax
        mov edi,eax
        invoke  RtlZeroMemory,edi,szTextBufSize
        mov esi,pDATA
        push dwoffset
        pop dwcurrentoffset
        mov ebx,dwsize
        .if (esi != NULL) && (ebx != 0)
                shr ebx,4
                .while ebx
                        mov ecx,16
                        xor eax,eax
                        .while ecx
                                dec ecx
                                mov al,[esi][ecx]
                                push eax
                        .endw
                        invoke wsprintf,edi,offset szFmt,dwcurrentoffset
                        add edi,eax
                        xor ecx,ecx
                        .while ecx<16
                                mov al,[esi][ecx]
                                .if al<20h || al>127
                                        mov al,'.'
                                .endif
                                stosb
                                inc ecx
                        .endw
                        mov al,0dh
                        stosb
                        mov al,0ah
                        stosb
                        add esi,16
                        add dwcurrentoffset,16
                        dec ebx
               .endw
               invoke MessageBox,NULL,pTextBuffer,addr szSucMsg0,0
        .endif
        invoke GetProcessHeap
        invoke HeapFree,eax,HEAP_NO_SERIALIZE,pTextBuffer
.endif
ret
PrintHexDump    endp

Main    proc uses esi ebx
invoke  CreateFile,addr szHD,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,0,NULL
.if eax !=INVALID_HANDLE_VALUE
        mov hDevice,eax
        invoke  ReadFile,hDevice,addr MBR,MBR_Size,addr dwNumberOfBytesRead,NULL
        .if eax != 0
                invoke  PrintHexDump,addr MBR,0,MBR_Size
        .else
                invoke  MessageBox,hMessage,addr szErrMsg1,NULL,MB_ICONEXCLAMATION
        .endif
        invoke  CloseHandle,hDevice
.else
        invoke  MessageBox,hMessage,addr szErrMsg2,NULL,MB_ICONEXCLAMATION
.endif
invoke  ExitProcess,0
Main    endp
end     Main