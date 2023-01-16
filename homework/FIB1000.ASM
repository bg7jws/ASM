.model small
.stack 100h
.data
array	dw 64 dup(3030h)
buffer	db 5 dup(0),'$'		;define a buffer for change numbers to ascii use
crlf	db 0dh,0ah,24h
.code
start:
	mov ax,@data
	mov ds,ax
	
	mov word ptr array[0],0
	mov word ptr array[2],1
	mov si,4
	mov cx,26
	mov ax,0
	add ax,array[si-4]
loop1:
	add ax,array[si-4]	
	jc ext1
	mov array[si],ax
	inc si
	inc si
	loop loop1
ext1:	
	shr si,1
	mov cx,si
	mov si,0
loop2:	
	mov dx,word ptr array[si]
	call printnum
	lea dx,crlf
	mov ah,09h
	int 21h
	inc si
	inc si
	loop loop2
	
	mov ah,4ch
	int 21h
printnum	proc near		;sub for display number
	push ds					;this sub will change DX number to ASC.
	push di					;use buffer(5 bytes space) as the buffer save temp ASC
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
end	start