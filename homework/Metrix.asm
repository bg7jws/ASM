.model small
.stack 100h                    ;remark stack it can run correct,otherwise convert not run
.data
metrix0	dw 4 dup(4 dup(?)
;metrix0	dw 1,2,3,4
;	dw 1,2,3,4
;	dw 1,2,3,4
;	dw 1,2,3,4
metrix1	dw 4 dup(4 dup(?))	;metrix buffer
metrix2 dw 4 dup(4 dup(?))

buffer	db 5 dup(0),'$'		;define a buffer for change numbers to ascii use
crlf	db 0dh,0ah,024h		;define carry return and line feed
space	db 09h'$'			;define tab for space of two numbers
metrixm	db 4			;define metrix M*N as 4*4
metrixn	db 4
.code
start:	mov ax,@data		;initial data segment
	mov ds,ax
	mov es,ax		;initial es segment
	lea si,metrix0		;get metrix0
	call metrixmake
;	lea si,metrix0		;convert to metrix'
;	lea di,metrix1
	call metrixconvert
	lea si,metrix0		;add metrix0+'
	lea di,metrix1
	lea bx,metrix2
	call metrixadd

	lea si,metrix0		;initial the pointer to Metrix0 offset
	call dispmetrix
	call prtcrlf
	call prtcrlf
	lea si,metrix1		;initial the pointer to Metrix' offset
	call dispmetrix
	call prtcrlf
	call prtcrlf
	lea si,metrix2		;initial the pointer to Metrix0+' offset
	call dispmetrix
	call prtcrlf
	call prtcrlf
finish:
	mov ah,4ch			;finish and return to DOS
	int 21h
metrixadd	proc near
	mov ch,0
	mov cl,metrixn		;initial the Row		
loop15:	push cx			;save Row
	mov cl,metrixm		;initial the Col
loop16:		mov ax,[si]	;move the number in to metrix
		add ax,[di]
		mov [bx],ax
		inc si		;pointer to next number
		inc si
		inc di
		inc di
		inc bx
		inc bx
		loop loop16	;loop for M Col
	pop cx			;recall Rol
	loop loop15		;loop for N Row
	ret
metrixadd endp
metrixmake	proc near
	mov ch,0
	mov cl,metrixn		;initial the Row		
loop11:	push cx			;save Row
	mov cl,metrixm		;initial the Col
loop12:		call dec16in	;call sub get 1 number
		mov [si],dx	;move the number in to metrix
		inc si		;pointer to next number
		inc si
		loop loop12	;loop for M Col
	pop cx			;recall Rol
	loop loop11		;loop for N Row
	ret
metrixmake endp
dec16in proc near
	push cx
	push ax
	mov dx,0
dec16in1:
	mov ah,1
	int 21h
	sub al,30h
	jl dec16in2
	cmp al,9h
	jg dec16in2
	cbw
	push ax
	mov ax,dx
	mov cx,10
	mul cx
	mov dx,ax
	pop ax
	add dx,ax
	jmp dec16in1
dec16in2:
	pop ax
	pop cx
	ret
dec16in endp
metrixconvert 	proc near
	
	mov bh,0		;bh is the Col of metrix0
	mov bl,metrixm		;how many item a Col
	mov ch,0
	mov cl,metrixn		;initial the loop Row		
loop13:	push cx			;save Row
	mov al,0
	mov cl,metrixm		;initial the Col
loop14:		mov ah,0
		push ax
		mul bl
		add al,bh
		add ax,ax
		mov si,ax
		mov dx,metrix0[si]
		mov metrix1[di],dx	;move the number in to metrix
		inc di			;pointer to next number
		inc di
		pop ax
		inc al
		loop loop14		;loop for M Col
	inc bh
	pop cx				;recall Rol
	loop loop13			;loop for N Row
	ret

metrixconvert endp
prtcrlf	proc near
	mov dx,offset crlf		;get the crlf address
	mov ah,9
	int 21h				;dos call for change line
	ret
prtcrlf endp
dispmetrix	proc near
	mov ch,0
	mov cl,metrixn		;initial the Row		
loop21:	push cx			;save Row
	mov cl,metrixm		;initial the Col
loop22:		mov dx,[si]	;move the number in to dx
		call printnum
		mov dx,offset space	;display space between 2 numbers
		mov ah,9
		int 21h			;dos call for display
		inc si			;pointer to next number
		inc si
	loop loop22			;loop for M Col
	pop cx				;recall Rol
	call prtcrlf
	loop loop21			;loop for N Row
	ret
dispmetrix endp
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