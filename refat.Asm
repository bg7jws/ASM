.model small
.stack 400h
.data
		db 'BEGINDEBUG'
fat1table	db 1200h dup(00)
fat2table	db 1200h dup(00)
msg1		db 0dh,0ah,'double 1.44M floppy disk fat have made'
		db 0dh,0ah,'from address 200H to 25ffH'
		db 0dh,0ah,'modify the end mark before use it!!!'
		db 0dh,0ah,'copy boot+fat+fdt+data to make a floppy IMG','$'
errmsg		db 0dh,0ah,'write error!!!','$'
errflag		db 0
filename	db 'REFAT',0
fhandle		dw 0

.code
start:
		mov ax,@data
		mov ds,ax
		mov es,ax
		
		mov si,offset fat1table
		call maketable
		mov si,offset fat1table
		mov di,offset fat2table
		mov cx,1200h
		rep movsb
int 3
		call write_file			;write as a disk file
		;call write_fat_dsk		;write FDD FAT area
		cmp errflag,1			;compare the error flag
		je exit0
exit1:		mov dx,offset msg1		;display infomation
		mov cx,1200h
		mov ah,9
		int 21h
		jmp exit0
		
		
exit0:		mov ah,4ch			;exit to DOS
		int 21h
write_file	proc near
	
		mov ah,3ch			;open file
		mov cx,00
		mov dx,offset filename
		int 21h
		jc error
		mov fhandle,ax
		
		mov bx,fhandle			;write file
		mov cx,2400h
		mov dx,offset fat1table
		mov ah,40h
		int 21h
		jc error
		mov ah,3eh
		mov bx,fhandle
		int 21h
		jc error
		jmp w_fin
		
error:		mov errflag,1			;write error message if error
		mov dx,offset errmsg
		mov ah,9
		int 21h	
		jmp w_fin
w_fin:	ret

write_file endp
write_fat_dsk	proc near
	mov al,11h				;int 13h write to FDD
	mov ah,3
	mov bx,offset fat1table
	mov cx,0001h
	mov dx,0000h
	int 13h
	cmp ah,00
	je w_ok
	mov errflag,1
	mov dx,offset errmsg
	mov ah,9
	int 21h
w_ok:	
	ret

write_fat_dsk endp
maketable proc near
	mov si,offset fat1table
	mov byte ptr [si],0F0h			;write first 3 bytes
	mov byte ptr [si+1],0FFh
	mov byte ptr [si+2],0FFh
	mov si,3
	mov ax,3h	;the cluster number
	mov bx,4h	;the next cluster number
	mov dx,3h	;the address of cluster number
	mov cx,200h
	
loop1:	push ax					;calculate the clusters
	push bx
	push cx
	mov byte ptr fat1table[si],al
	
	mov cx,4
loop11:	ror bx,1
	loop loop11
	
	or bh,ah	
	mov byte ptr fat1table[si+1],bh			
	mov byte ptr fat1table[si+2],bl
	pop cx
	pop bx
	pop ax
	inc ax
	inc ax
	inc bx
	inc bx
	add si,3
	loop loop1
	ret
maketable endp

end start
		
