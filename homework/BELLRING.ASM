stack segment stack
	db 128 dup(0)
stack ends

data segment   
msg1		db 'bell ring',0dh,0ah,'$' 
cont0 		dw 1
times 		dw 0               ;the times of operation
intSeg 		dw 0      
intOffset 	dw 0   
frequancy  	dw 2046  
data ends

code segment   
	assume cs:code,ds:data,ss:stack
main proc far        
	mov ax,data
	mov ds,ax	
	
	;install new interruption  
    	push ds     
	mov ax,351ch
    	int 21h
	mov intSeg,es  
    	mov intOffset,bx     
	mov ax,seg ring 
    	mov ds,ax
    	mov dx,offset ring     ;now ds:dx is the new address of 1ch ISR
    	mov ax,251ch
	int 21h  
	pop ds   	
	
	;ring and print
wait0:	cmp times,10         ;operate for 6 times
	jne wait0
    
	;restore old interruption
	mov dx,intOffset
	mov ds,intSeg
	mov ax,251ch
	int 21h
    
	;return to dos
	mov ah,4ch    
	int 21h
main endp          

ring	proc near             ;new 1ch ISR
	mov ax,data    
	mov ds,ax
	dec cont0
	jnz finish
	inc times
	mov cont0,54
	
	;make sound	
	mov cx,10000           ;loop enough times to make sound	
beep:
	in al,61h
	or al,03h
	out 61h, al
	mov al,0b6h
	out 43h,al
	mov bx,frequancy
	mov al,bl
	out 42h,al
	mov al,bh
	out 42h,al
	in al,61h
	and al,0fch
	out 61h, al
	loop beep
	
	mov dx,offset msg1
	mov ah,9h              
	int 21h                 ;print the message
finish:   
	iret
ring endp     
code ends      
end main  