.386
.model flat,stdcall
option casemap:none
include c:\masm32\include\user32.inc
include c:\masm32\include\windows.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\comdlg32.inc
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\comdlg32.lib

.data
szFileName      db '\\.\\physicaldrive0',0

szBuffer        db 512 dup (0)
@hFile          dd ?
@dwBytesRead    dd ?
;@szLogFile      db MAX_PATH dup(?)
.const
szErrOpenFile   db 'open file error!',0
szFileNameNew   db 'boot.bin',0
szErrCreateFile db 'Can not create boot.bin!',0
szSuccess       db 'Read MBR and write boot.bin success, check your boot.bin',0
szSuccessCap    db 'Success',0
.code
start:
invoke  CreateFile,addr szFileName,GENERIC_READ,FILE_SHARE_READ,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
        .if eax==INVALID_HANDLE_VALUE
                invoke MessageBox,NULL,addr szErrOpenFile,NULL,MB_OK or MB_ICONEXCLAMATION
                jmp exit
        .endif
mov     @hFile,eax
invoke  ReadFile,@hFile,addr szBuffer,sizeof szBuffer,addr @dwBytesRead,0
invoke  CloseHandle,@hFile
invoke  lstrcpy,addr szFileNameNew,addr szFileNameNew
invoke  CreateFile,addr szFileNameNew,GENERIC_WRITE,FILE_SHARE_READ,0,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,0
        .if eax != INVALID_HANDLE_VALUE
                mov @hFile,eax
                invoke WriteFile,@hFile,addr szBuffer,sizeof szBuffer,addr @dwBytesRead,0
                invoke CloseHandle,@hFile
                ;invoke wsprintf,addr szBuffer,addr szSuccess
                invoke MessageBox,NULL,addr szSuccess,addr szSuccessCap,MB_OK or MB_ICONINFORMATION
        .else
                invoke MessageBox,NULL,addr szErrCreateFile,NULL,MB_OK or MB_ICONEXCLAMATION
        .endif

exit:
invoke  ExitProcess,0
end     start