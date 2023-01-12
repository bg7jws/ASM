;ml /c /coff filename
;link /subsystem:console filename
.386
.model	flat, stdcall
option	casemap:none
include windows.inc
include kernel32.inc
include user32.inc
includelib kernel32.lib
includelib user32.lib
.data
a		db 10 dup(0)
buffer	db 20 dup(0)
Caption	db '输出', 0
szFmt	db 'The Result is %d', 0
i		db 0
sum		db 0

.code
start:
	mov edi, 0
	.while (i < 10)
		mov al, i
		mov a[edi], al
		inc i
		inc edi
	.endw
	mov i, 0
	mov edi, 0
	.while (i < 10)
		mov al, a[edi]
		add sum, al
		inc i
		inc edi
	.endw
	xor eax, eax
	mov al,sum
	invoke wsprintf, addr buffer, addr szFmt, eax
	invoke MessageBox, NULL, offset buffer, offset Caption, MB_OK
	invoke ExitProcess, 0
end start