.model small
.stack 100h
.data
varX	db '8765'                                      ;预定于一个数
Yhead	db 5,?                                    ;定义键盘输入缓冲区
ansY	db 5 dup(?)                                    ;缓冲区从此处才是接收的字符
msg1	db 0dh,0ah,'guess this number:','$'            ;定义提示信息
result	db 0dh,0ah                                ;显示结果信息
passA	db ?
	db 'A'						;位置正确数字正确						
passB	db ?
	db 'B'						;数字正确位置不对,显示结束
	db '$'
mycode	db 0dh,0ah,'171$'

.code
start:
	mov ax,@data
	mov ds,ax
	mov es,ax		     ;initial
again:	mov passA,30h
	mov passB,30h		;init the A and B
	lea dx,msg1		;display message
	mov ah,9
	int 21h
	lea dx,Yhead		;get 4 numbers from KB
	mov ah,0ah
	int 21h
	
	mov cx,4		;4 times loop
	mov si,offset varX	;init the pointer
	mov di,offset ansY
loopA:	mov al,[si]		;compare the number and your number
	cmp al,[di]
	jne cont0
	inc passA		;number and position all get right
cont0:	inc si
	inc di
	loop loopA
	
	mov cx,4		;4 times loop
	mov si,0		;si=0
loop1:	push cx
	mov cx,4		;4 times inner loop
	mov di,0		;di=0
	mov al,varX[si]		;compare the number and your number
loop0:	cmp si,di
	je cont			;only for get the number match but wrong position
	cmp al,ansY[di]		;so skip si=di
	je countB		;if equ then passB+1
	jmp cont
countB:	inc passB
cont:	inc di			
	loop loop0
	inc si			;every si compare with other 3 numbers
	pop cx			;restore the outer loop time
	loop loop1	
	
displayresult:			;after all loop,display the result
	lea dx,result
	mov ah,9
	int 21h	
	
	cmp passA,34h		;if passA=4,then get return to dos
	je exit0
	jmp again
	
exit0:	lea dx,mycode		;display mycode
	mov ah,9
	int 21h
	mov ah,4ch		;exit to dos
	int 21h
end start