.model	small
.stack	100h
.data
buffer	db 81,?,81 dup (0)
letter	db 0
digit	db 0
other	db 0
msgres	db 0dh,0ah,'The counted result of the program:','$'
msglet	db 0dh,0ah,'letter:','$'
msgdig	db 0dh,0ah,'digit:','$'
msgoth	db 0dh,0ah,'other:','$'
c10	db 10

.code
start:
	mov ax,@data						;initial
	mov ds,ax
	;dos call get input a string from KB
	lea dx,buffer
	mov ah,0ah
	int 21h
	mov cx,0
	mov cl,buffer[1]
	lea si,buffer[2]
loop1:
	mov al,[si]
	cmp al,0dh
	je finish
		cmp al,30h
		jb oth
		cmp al,39h
		ja let						;if it is digit, below 30h other+1,above 30h go letter
		inc digit
		jmp cont
	let:	cmp al,41h					;after determine digit, below 41h other+1,abover 5ah go shift
		jb oth
		cmp al,5ah
		ja shift
		inc letter					;below 5ah, lettle+1
		jmp cont
	shift:	cmp al,61h					;below 61h, other+1
		jb oth
		cmp al,7ah					;above 7ah, other+1
		ja oth
		inc letter					;inside 61-71, letter+1
		jmp cont
	oth:	inc other
cont:	inc si							;continue next character,loop time in cx
	loop loop1						

finish:
	lea dx,msgres						;print result line
	mov ah,09
	int 21h
	
	lea dx,msglet						;print litte msg
	mov ah,09
	int 21h
	mov al,letter
	call printnum						;print how many letter
	
	lea dx,msgdig						;print digit msg
	mov ah,09
	int 21h
	mov al,digit
	call printnum						;print how many digit
	
	lea dx,msgoth						;print othermsg
	mov ah,09
	int 21h
	mov al,other
	call printnum						;pring how many other
	
        mov     ax, 4C00h					;exit to dos
        int     21h
printnum proc near
         push ax		;保存现场
         push dx
         push cx
         mov cx,0		;初始化计数器
trantochar:
         mov ah,0		;高位置0
         cmp al,0		;低位是0吗？
         jz outtrantochar	;是的话转输出
         div c10		;数据除以10
         mov dl,ah		;余数放入dl
         mov dh,0		;高位置0
         push dx		;压入dx待用
         inc cx			;计数器加1
         jmp trantochar;	;继续算除法

outtrantochar:
        cmp cx,0		;数字为0时候，cx为0，退出不打印
        jz exit_printnum

print:
        pop dx			;将堆叠到stack内的数字逐个弹出。高位先出来
        add dx,30h		;数字加30变成对应的asc
        mov ah,02h		;dos打印，有几位就循环几次，位数在算除的时候逐次累加在cx里
        int 21h
        loop print
exit_printnum:
	pop cx			;恢复现场
	pop dx
	pop ax
	ret
printnum endp
end start
