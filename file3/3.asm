;ml /Zi /c /coff  %1.asm
;link /subsystem:console %1.obj
.386
.model flat, stdcall
option casemap:none
include		windows.inc
include		kernel32.inc
;include		user32.inc
includelib	kernel32.lib
;includelib	user32.lib

.data
crlf	equ <0dh,0ah>
message	db crlf,crlf,'¿ØÖÆÌ¨Êä³ö',crlf
		db '----------',crlf
messageSize	db ($-message)
ConsoleHandle	dword 0
ByteWritten		dword ?
.code
main proc
	invoke GetStdHandle,STD_OUTPUT_HANDLE
	mov ConsoleHandle,eax
	invoke WriteConsole, ConsoleHandle, offset message, messageSize, offset ByteWritten, 0
	invoke ExitProcess, 0
main endp
end main