.model small
.stack 200h
.data
car	db 41h,'$'
direct	db 00
up	db 48h
down	db 50h
left	db 4bh
right	db 4dh

.code
start:
	mov ax,@data			;initial
	mov ds,ax
	
	mov ax,0600h			;clear the screen
	mov bh,07h
	mov cx,0000
	mov dx,184fh
	int 10h

	mov dx,1005h			; set a position
ggg:	mov bh,00h
	mov ah,02h
	int 10h
	
	mov dl,41h			;display a car
	mov ah,02h
	int 21h
	
getpos:	mov bh,00
	mov ah,03h			;read this car position
	int 10h
	dec dl
	push dx			;save position

stop0:	mov ah,10h			;get director from kb
	int 16h
	mov direct,ah
	cmp ah,39h			;space to park and any key return DOS
	je gopark
		
	mov ax,0600h			;clear the screen
	mov bh,07h
	mov cx,0000
	mov dx,184fh
	int 10h
	pop dx			;recall position
	
	mov al,direct
	cmp al,up			;set new position
	je goup
	cmp al,down
	je godown
	cmp al,left
	je goleft
	cmp al,right
	je goright
	jmp stop0
goup:	dec dh
	jmp ggg
godown:	inc dh
	jmp ggg
goleft:	dec dl
	jmp ggg
goright:inc dl
	jmp ggg

gopark:	mov ah,1			;press any to return DOS
	int 21h
	mov ah,4ch
	int 21h	
	ret
end start
