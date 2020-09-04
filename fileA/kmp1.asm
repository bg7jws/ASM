;ml /Zi /c /coff  %1.asm
;link /subsystem:console %1.obj
.586p
.model flat,stdcall
option casemap:none
include windows.inc
include kernel32.inc
include user32.inc
include masm32.inc
includelib masm32.lib
includelib kernel32.lib
includelib user32.lib

kmp proto:dword,:dword
.data					;数据段
array	dword 100 dup(0)	;定义一个数组，100个双字，初始化为0
szMsg0	byte 'Please input the Text string, it should be longer than 2 characters.',0dh,0ah,0
messageSize0	db ($-szMsg0)
szMsg1	byte 'Invalid text, too short!',0dh,0ah,0
messageSize1	db ($-szMsg1)
szMsg2	byte 'Search pattern: ',0dh,0ah,0
messageSize2	db ($-szMsg2)
szMsg3	byte 'Prefix table:',0dh,0ah,0
messageSize3	db ($-szMsg3)
szMsg4	byte 0dh,0ah,'The search pattern could not find in the text.',0dh,0ah,0
messageSize4	db ($-szMsg4)
szMsg5	byte 0dh,0ah,'First position(index starting from 0):',0
messageSize5	db ($-szMsg5)
ConsoleHandle	dword ?
dwBytesWrite	dword ?
dwBytesPtn		dword ?
dwBytesText		dword ?
hStdOut			dword ?
hStdIn			dword ?
szText			byte 256 dup(0)
szSearchString	byte 12 dup(0)
szFmt			byte '%d',0
buffer			byte 10 dup(?)
foundmark		byte 0
.code						;代码段
start:
;获取标准输入输出的handle
	invoke	GetStdHandle, STD_OUTPUT_HANDLE							
		mov hStdOut,eax
	invoke	GetStdHandle, STD_INPUT_HANDLE
		mov hStdIn,eax
;控制台输入text,计算字节数，并结尾填0
	invoke StdOut, addr szMsg0	
	invoke	ReadConsole, hStdIn, addr szText, sizeof szText, addr dwBytesText, NULL	
		sub dwBytesText,2
		mov ebx,dwBytesText
		mov byte ptr szText[ebx],0
;判断字符数量是否大于2，否则显示错误信息
	.if dwBytesText < 2							
		invoke	WriteConsole, hStdOut, addr szMsg1, messageSize1, addr dwBytesWrite, NULL
		jmp leave_prog
	.endif
;控制台获取pattern串
	invoke StdOut, addr szMsg2					
	invoke	ReadConsole, hStdIn, addr szSearchString, sizeof szSearchString, addr dwBytesPtn, NULL
		sub dwBytesPtn,2
		mov ebx,dwBytesPtn
		mov byte ptr szSearchString[ebx],0
;控制台显示部分匹配表抬头，下一行显示部分匹配表，再两次换行后显示查找结果
	invoke StdOut, addr szMsg3
	invoke	kmp, addr szText, addr szSearchString
	.if foundmark == 0
		invoke StdOut, addr szMsg4
		jmp leave_prog
	.endif
	invoke	wsprintf, addr buffer, addr szFmt, eax	 
	invoke	StdOut, addr szMsg5
	invoke	StdOut, addr buffer
;程序结束退出		
leave_prog:
	invoke ExitProcess, 0
;------------------------------------------------------------------------------------------
kmp	proc Text:dword, SearchString:dword
	mov ecx, [ebp+12]	;ecx =  address of search string
	mov edx, [ebp+8]	;edx = address of text
	xor esi, esi		;si=0
	mov edi, 1			;di = 1	
	mov dword ptr [array],0	;initial array first as 0
prefix:
	mov ah, [ecx+esi]	;ah = search_string[esi]	;ah=first char
	mov al, [ecx+edi]	;al = search_string[edi]	;al=second char
	cmp al, 0			;if al == 0					;string end?
	je search			; continue with search		;yes begin search
	cmp al, ah			; if al == ah				;al=ah?
	je equal										;yes jmp to equal
	jmp nequal										;no jmp to neequal
equal:					;array[edi] = ++esi
	inc esi
	mov [array+4*edi], esi							;esi save in array[edi], array数组中edi下标
	inc edi											;edi move 1 char
	jmp prefix										;continue find prefix
nequal:					;esi=0; array[edi] = esi
	xor esi, esi									;一旦遇到不相同的，esi置零
	mov ah, [ecx+esi]
	cmp ah, al										;当前字符再次和第一个字符比较
	jne next										;不同，jmp next
	inc esi											;相同，esi move 1 char
next:
	mov [array+4*edi], esi							;类似equal中的同样操作
	inc edi											;edi move 1 char
	jmp prefix										;continue find prefix
;直到遇到00，前缀表计算结束，此时，前缀表中保存了如果相同，esi不需要再回溯的偏移量
;比如AAABC array 保存了，0，1，2，0，0用双字的格式
search:
	xor esi, esi		;esi=0						;initial source char begin from 0
	xor edi, edi		;edi=0						;initial text target char begin from 0
search_loop:
	mov ah, [ecx+esi]								;search string the esi char save in ah
	mov al, [edx+edi]								;text sting the edi char save in al
	cmp ah, 0										;search string end?
	je found			;if search string ends		;found success
	cmp al, 0										;text string end?
	je notfound		;if text ends					;not found
	cmp ah, al										;compare
	je pair											;pair to continue next esi and next edi
	jmp unpair										;unpair move esi and edi base on kmp algorithm
pair:				;edi++;esi++					;pair to continue next esi and next edi
	inc edi
	inc esi
	jmp search_loop
unpair:				;edi++;esi = array[esi]s	
	cmp esi, 0										;search string 中第一个就不匹配时候，edi+1, esi还是从0开始，esi保持0不变
	je next_u
	dec esi											;search string第二个之后才不匹配时,根据部分匹配表获得search string 的 esi偏移值
	push dword ptr [array+4*esi]							
	pop esi											
	jmp search_loop									;continue search
next_u:												;search string 中第一个就不匹配时候，edi+1, esi还是从0开始，esi保持0不变
	inc edi
	jmp search_loop
found:
	mov foundmark,1											;pair success, edi-esi=begin of text pair address
	sub edi, esi
	jmp goend											;ready for return
notfound:
	mov edi, 0										;set notfound mark
goend:
	mov esi,0
	.repeat	
		mov ebx,dword ptr [array+4*esi]
		invoke	wsprintf, addr buffer, addr szFmt, ebx
		invoke	StdOut, addr buffer
		inc esi
	.until (esi==dwBytesPtn)
	mov eax, edi	;return value in eax<-edi						;edi中保存的是匹配成功后的text首字符偏移地址,save in eax ready for kmp return
	ret
kmp endp
end	start