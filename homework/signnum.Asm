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
         mov cx,0;		;初始化计数器
trantochar:
         mov ah,0;		;高位置0
         cmp al,0;		;低位是0吗？
         jz outtrantochar;	;是的话转输出

         div c10;		;数据除以10
         mov dl,ah;		;余数放入dl
         mov dh,0;		;高位置0
         push dx;		;压入dx待用

         inc cx;		;计数器加1
         jmp trantochar;	;继续算除法

outtrantochar:
        cmp cx,0;		;数字为0时候，cx为0，退出不打印
        jz exit_printnum;

print:
        pop dx;			;将堆叠到stack内的数字逐个弹出。高位先出来
        add dx,30h;		;数字加30变成对应的asc
        mov ah,02h;		;dos打印，有几位就循环几次，位数在算除的时候逐次累加在cx里
        int 21h;
        loop print

exit_printnum:
;        pop cx;
        ret
printnum endp
end start
