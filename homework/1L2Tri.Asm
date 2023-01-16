.model small
.stack 200h
.data
msg0	db 'please input number:1 2 3?',0dh,0ah,'$'
msg1	db 0dh,0ah,'******',0dh,0ah,'$'
msg2	db 0dh,0ah,'   *   ',0dh,0ah
	db '  ***  ',0dh,0ah
	db ' ***** ',0dh,0ah
	db '*******',0dh,0ah,'$'
msg3	db 0dh,0ah,'******',0dh,0ah
	db '******',0dh,0ah
	db '******',0dh,0ah
	db '******',0dh,0ah
	db '******',0dh,0ah
	db '******',0dh,0ah,'$'
.code
start:
	mov ax,@data
	mov ds,ax
	lea dx,msg0		;display message
	call dispmessage
	call getinput		;get KB input
	cmp al,31h		;compare with ascii 1,2,3
	je next1
	cmp al,32h
	je next2
	cmp al,33h
	je next3
	jmp exit0		;not 1,2,3, exit
next1:
	lea dx,msg1		;put 1 line address to dx
	jmp outputmsg
next2:
	lea dx,msg2		;put tri address to dx
	jmp outputmsg
next3:
	lea dx,msg3		;put quad address to dx
outputmsg:			;display * characters
	call dispmessage
	
exit0:	mov ax,4c00h
	int 21h
getinput	proc near
	mov ah,01h
	int 21h
	ret

getinput endp
dispmessage	proc near
	mov ah,9
	int 21h
	ret

dispmessage endp
end start
