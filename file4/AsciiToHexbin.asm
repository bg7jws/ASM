; sub proc name AsciiToHexbin.asm
; use as: invoke AsciiToHexbin, addr szBuffer
; szBuffer use for input
; eax use for output
.code
AsciiToHexbin	proc, lpOffset:dword
	local	data_001:dword
			pushad
			mov ecx,0ah
			xor eax,eax
			xor ebx,ebx
			mov esi,lpOffset
	loc_001:
			mov bl,[esi]
			cmp bl,0
			je short loc_003
			sub bl,30h
			cmp bl,9
			ja short loc_002
			mul ecx
			add eax,ebx
	loc_002:
			inc esi
			jmp short loc_001
	loc_003:
			mov data_001,eax
			popad
			mov eax,data_001
			ret
AsciiToHexbin	endp