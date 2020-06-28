.model small
.stack 100h
.data
table0	dw 2007,50200,43941,?		;define a table of years
	dw 2008,60590,52778,?
	dw 2009,61883,54517,?
	dw 2010,50440,46239,?
	dw 2011,59403,53533,?
	dw 2012,56804,49623,?
	dw 2013,50375,43690,?
	dw 2014,55397,53436,?
	dw 2015,56491,52877,?
	dw 2016,63885,63831,?
	dw 2017,62629,55768,?
	dw 2018,53736,52660,?
	dw 2019,60995,53184,?
buffer	db 5 dup(0),'$'		;define a buffer for change numbers to ascii use
crlf	db 0dh,0ah,024h		;define carry return and line feed
space	db 8 dup(20h),'$'	;define space of two numbers
years	db 13			;how many years
.code
start:
	mov ax,@data		;initial data segment
	mov ds,ax
	mov es,ax		;initial es segment
	mov si,2		;define the first income offset in table0
	mov di,4		;define the first expense offset in table0
	mov cl,years		;move years as the loop times
loop0:	mov ax,table0[si]	;the income put in to ax
	sub ax,table0[di]	;income - expense get the rest
	mov table0[si+4],ax	;put the rest into the table0
	add si,8		;next year income address
	add di,8		;next year expense address
	loop loop0		;loop for cx-year times
	
	mov cx,0		;initial the counter
	mov si,0		;initial the pointer in table0 offset
loop1:	mov dx,table0[si]	;move the number in to dx
	cmp cx,4		;compare if the 5th number in one line,(form 0 to 4,the 4 is 5th number)
	jne next0		;if not, continue next0
		push dx		;if this the 5th number, then change to next line,save DX first
		mov dx,offset crlf	;get the crlf address
		mov ah,9
		int 21h			;dos call for change line
		mov cx,0		;counter reset to 0
		pop dx			;restore DX at here
	dec years			;year counter -1,get
	jz finish			;if yesrs reached, go finish
next0:	call printnum			;call sub for display number
		mov dx,offset space	;display space between 2 numbers
		mov ah,9
		int 21h			;dos call for display
	inc cx				;counter +1
	inc si				;pointer to next number
	inc si
	jmp loop1			;repeat display numbers in table0, not use cx as loop
finish:
	mov ah,4ch			;finish and return to DOS
	int 21h

printnum	proc near		;sub for display number
	push ds				;this sub will change DX number to ASC.
	push di				;use buffer(5 bytes space) as the buffer save temp ASC
	push dx
	push cx
	push ax
	
	mov cx,0
	lea di,buffer
dec16out1:
	push cx
	mov ax,dx
	mov dx,0
	mov cx,10
	div cx
	xchg ax,dx
	add al,30h
	mov [di],al
	inc di
	pop cx
	inc cx
	cmp dx,0
	jnz dec16out1
dec16out2:
	dec di
	mov al,[di]
	push dx
	mov dl,al
	mov ah,2
	int 21h
	pop dx
	loop dec16out2
	
	pop ax
	pop cx
	pop dx
	pop di
	pop ds
	ret
printnum endp

end start
