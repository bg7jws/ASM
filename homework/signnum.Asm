.model small
.stack 200h
.data
msg1	db 0dh,0ah,'the number of negative is:','$'
msg2	db 0dh,0ah,'the biggest number is:','$'
arrayM	dw -1,-2h,'21','44',-34,'75','22',9ACDh,'54',-1,'46',04d5ah,'90',-32766,'62','37'
number	db 0
maxnum	dw 0
	db 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'; for indicate when dump memory
c10	db 10
.code
start:
	mov ax,@data
	mov ds,ax
	
	lea si,arrayM
	mov cx,16
	call getnum
		
	lea dx,msg1		;print the number of negative
	call dispinfo
	mov al,number
	call printnum
	
	lea si,arrayM
	mov cx,16
	call mybig
		
	lea dx,msg2		;print the number of biggest
	call dispinfo
	mov dx,maxnum
	call printhex
		
	int 3
	mov ax,4c00h
	int 21h
printhex	proc near
	push dx
	mov dl,dh
	call print1hex
	pop dx
	call print1hex	
	mov dl,'H'
	mov ah,2
	int 21h
	
	ret
printhex	endp
print1hex	proc near
	mov bl,dl
	mov cl,4
	shr dl,cl
	or dl,30h
	cmp dl,39h
	jbe ad1
	add dl,7
ad1:	mov ah,2
	int 21h
	mov dl,bl
	and dl,0fh
	or dl,30h
	cmp dl,39h
	jbe ad2
	add dl,7
ad2:	mov ah,2
	int 21h

	ret
print1hex endp
dispinfo	proc near
	mov ah,09h
	int 21h
	ret

dispinfo endp
getnum	proc near
	
loop1:	mov ax,[si];
	test ax,8000h;
	jns exit0
		inc number
exit0:	inc si
	inc si
	loop loop1
	ret

getnum endp
mybig	proc near
	dec cx
	mov ax,[si];


cont0:	mov bx,[si+2]
cont1:	cmp ax,bx;
		js compOF
			jno next
			xchg ax,bx
			jmp next		
		compOF:
			jo next
			xchg ax,bx
			jmp next
	jae next;
	mov ax,bx;
next:	inc si
	inc si
	loop cont0
	inc si
	inc si
	mov maxnum,ax
	
	ret
mybig endp
printnum proc near
;         push cx;
         mov cx,0;		;��ʼ��������
trantochar:
         mov ah,0;		;��λ��0
         cmp al,0;		;��λ��0��
         jz outtrantochar;	;�ǵĻ�ת���

         div c10;		;���ݳ���10
         mov dl,ah;		;��������dl
         mov dh,0;		;��λ��0
         push dx;		;ѹ��dx����

         inc cx;		;��������1
         jmp trantochar;	;���������

outtrantochar:
        cmp cx,0;		;����Ϊ0ʱ��cxΪ0���˳�����ӡ
        jz exit_printnum;

print:
        pop dx;			;���ѵ���stack�ڵ����������������λ�ȳ���
        add dx,30h;		;���ּ�30��ɶ�Ӧ��asc
        mov ah,02h;		;dos��ӡ���м�λ��ѭ�����Σ�λ���������ʱ������ۼ���cx��
        int 21h;
        loop print

exit_printnum:
;        pop cx;
        ret
printnum endp
end start