;ml /c /coff  %1.asm
;link /subsystem:windows %1.obj
.586
.model flat, stdcall
option casemap:none
include		windows.inc
include		kernel32.inc
include		user32.inc
includelib	kernel32.lib
includelib	user32.lib

.data
sysTime SYSTEMTIME <>
CapMsg	db '系统当前时间',0
szFmt	db '%d年%2d月%2d日',0dh,0ah,0dh,0ah
		db '%2d:%2d:%2d',0
buffer	db 80 dup(0)
.code
start:
invoke GetLocalTime,offset sysTime

movzx esi,sysTime.wYear
movzx edi,sysTime.wMonth
movzx edx,sysTime.wDay
movzx eax,sysTime.wHour
movzx ebx,sysTime.wMinute
movzx ecx,sysTime.wSecond

invoke wsprintf, addr buffer,addr szFmt,esi,edi,edx,eax,ebx,ecx
invoke MessageBox, NULL, offset buffer, offset CapMsg, MB_ICONQUESTION
invoke ExitProcess, 0
end		start