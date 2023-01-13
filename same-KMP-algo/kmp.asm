segment .data						;数据段
array	times 100 dd 0				;定义一个数组，100个双字，初始化为0

segment .text						;代码段
global kmp							;kmp为全局使用函数
extern strlen						;strlen是外部函数

kmp:
	push ebp
	mov ebp, esp

	mov ecx, [ebp+12]	;ecx =  address of search string
	mov edx, [ebp+8]	;edx = address of text
	xor esi, esi		;si=0
	mov edi, 1			;di = 1	
	mov dword [array], 0	;initial array first as 0
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
	push dword[array+4*esi]							
	pop esi											
	jmp search_loop									;continue search
next_u:												;search string 中第一个就不匹配时候，edi+1, esi还是从0开始，esi保持0不变
	inc edi
	jmp search_loop
	
found:												;pair success, edi-esi=begin of text pair address
	sub edi, esi
	jmp end											;ready for return
notfound:
	mov edi, 101									;set notfound mark
end:
	push dword [ebp+12]		;get search pattern length to esi	;为strlen函数准备参数,get the lenth of search_string
	call strlen													;call for strlen
	add esp, 4													;call 之后恢复esp
	mov esi, eax												;call return a number in eax, save it in esi

	mov ecx, 0				; ecx as counter
tochar:
	add dword[array + 4*ecx], 48	; convert number to character	;48=30H, change abs number to ASCII number
	inc ecx
	cmp ecx, esi
	jne tochar
	mov dword[array + 4*ecx], 10	; endline char					;mark end of 部分匹配表 0a is Line feed

	mov eax, 4			; write system call							;给系统调用准备参数，显示array地址保存的部分匹配表
	mov ebx, 1			; stdout
	mov ecx, array			; start address
	inc esi				; array length + endline char
	shl esi,2			; esi *= 4
	mov edx, esi	
	int $80															;call stdout系统调用
	
	mov eax, edi	;return value in eax<-edi						;edi中保存的是匹配成功后的text首字符偏移地址,save in eax ready for kmp return
	mov esp, ebp	;recover to before call kmp
	pop ebp
	ret