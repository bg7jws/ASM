segment .data						;���ݶ�
array	times 100 dd 0				;����һ�����飬100��˫�֣���ʼ��Ϊ0

segment .text						;�����
global kmp							;kmpΪȫ��ʹ�ú���
extern strlen						;strlen���ⲿ����

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
	mov [array+4*edi], esi							;esi save in array[edi], array������edi�±�
	inc edi											;edi move 1 char
	jmp prefix										;continue find prefix
nequal:					;esi=0; array[edi] = esi
	xor esi, esi									;һ����������ͬ�ģ�esi����
	mov ah, [ecx+esi]
	cmp ah, al										;��ǰ�ַ��ٴκ͵�һ���ַ��Ƚ�
	jne next										;��ͬ��jmp next
	inc esi											;��ͬ��esi move 1 char
next:
	mov [array+4*edi], esi							;����equal�е�ͬ������
	inc edi											;edi move 1 char
	jmp prefix										;continue find prefix
;ֱ������00��ǰ׺������������ʱ��ǰ׺���б����������ͬ��esi����Ҫ�ٻ��ݵ�ƫ����
;����AAABC array �����ˣ�0��1��2��0��0��˫�ֵĸ�ʽ
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
	cmp esi, 0										;search string �е�һ���Ͳ�ƥ��ʱ��edi+1, esi���Ǵ�0��ʼ��esi����0����
	je next_u
	dec esi											;search string�ڶ���֮��Ų�ƥ��ʱ,���ݲ���ƥ�����search string �� esiƫ��ֵ
	push dword[array+4*esi]							
	pop esi											
	jmp search_loop									;continue search
next_u:												;search string �е�һ���Ͳ�ƥ��ʱ��edi+1, esi���Ǵ�0��ʼ��esi����0����
	inc edi
	jmp search_loop
	
found:												;pair success, edi-esi=begin of text pair address
	sub edi, esi
	jmp end											;ready for return
notfound:
	mov edi, 101									;set notfound mark
end:
	push dword [ebp+12]		;get search pattern length to esi	;Ϊstrlen����׼������,get the lenth of search_string
	call strlen													;call for strlen
	add esp, 4													;call ֮��ָ�esp
	mov esi, eax												;call return a number in eax, save it in esi

	mov ecx, 0				; ecx as counter
tochar:
	add dword[array + 4*ecx], 48	; convert number to character	;48=30H, change abs number to ASCII number
	inc ecx
	cmp ecx, esi
	jne tochar
	mov dword[array + 4*ecx], 10	; endline char					;mark end of ����ƥ��� 0a is Line feed

	mov eax, 4			; write system call							;��ϵͳ����׼����������ʾarray��ַ����Ĳ���ƥ���
	mov ebx, 1			; stdout
	mov ecx, array			; start address
	inc esi				; array length + endline char
	shl esi,2			; esi *= 4
	mov edx, esi	
	int $80															;call stdoutϵͳ����
	
	mov eax, edi	;return value in eax<-edi						;edi�б������ƥ��ɹ����text���ַ�ƫ�Ƶ�ַ,save in eax ready for kmp return
	mov esp, ebp	;recover to before call kmp
	pop ebp
	ret