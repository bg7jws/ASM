;ml /c /coff  %1.asm
;link /subsystem:console %1.obj
.586
.model flat, stdcall
option casemap:none
include		windows.inc
include		kernel32.inc
include		user32.inc
includelib	kernel32.lib
includelib	user32.lib
.data
message			byte 'input a number:',0
messageSize=($-message)
dwBytesWrite	dword ?
dwBytesRead		dword ?
hStdOut			dword ?
hStdIn			dword ?
szBuffer		byte 64 dup(0)
szFmt			byte '你输入的数是%d',0
buffer			byte 128 dup(?)
CapMsg			byte 'Output',0
.code
include AsciiToHexbin.asm
main proc
invoke	GetStdHandle, STD_OUTPUT_HANDLE
		mov hStdOut,eax
invoke	GetStdHandle, STD_INPUT_HANDLE
		mov hStdIn,eax
invoke	SetConsoleTextAttribute, hStdOut, FOREGROUND_GREEN or FOREGROUND_INTENSITY
invoke	WriteConsole, hStdOut, addr message, messageSize, addr dwBytesWrite, NULL
invoke	ReadConsole, hStdIn, addr szBuffer, sizeof szBuffer, addr dwBytesRead, NULL
		sub dwBytesRead,2
		mov ebx,dwBytesRead
		mov byte ptr szBuffer[ebx],0
invoke	AsciiToHexbin, addr szBuffer
invoke	wsprintf, addr buffer, addr szFmt, eax
invoke	MessageBox, NULL, offset buffer, offset CapMsg, MB_OK
invoke	ExitProcess, 0
main endp
end main