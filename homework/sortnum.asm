.model small
.data
     count      db 50
     array      db 11,22,33,44,43,10,77,52,234,6
     		db 55,77,62,13,100,65,47,99,111,2
     		db 1,4,7,9,3,66,45,12,24,45
     		db 244,78,92,35,15,65,17,23,11,88
     		db 250,119,114,120,57,67,89,10,84,222
     msg1       db 0dh,0ah,'The source array number is:',0dh,0ah,20h,'$'
     msg2       db 0dh,0ah,'The sorted array number is:',0dh,0ah,20h,'$'
     msg3       db 0dh,0ah,'$'
     c10        db 10
     ckten	db 0
.stack         200h
.code
START:
        mov ax,@data;
        mov DS,ax;
        
        lea dx,msg1;
        mov ah,09h;
        int 21h;
        mov ch,0;
        mov cl,count;
        mov bx,0;
        outputsource:
     	
        mov ah,0;
        mov al,array[bx];
        call printnum;
        
        mov dl,' ';
        mov ah,02h;
        inc ckten;
        call check10;
        int 21h;

        inc bx; 
        loop outputsource

        lea si,array;
        mov ch,0;
        mov cl,count;
        call mysort;

        lea dx,msg2;
        mov ah,09h;
        int 21h;
        mov ch,0
        mov cl,count;
        mov bx,0;
        mov ckten,0;
     outputsortedarray:
        mov ah,0;
        mov al,array[bx];
        call printnum;
	inc ckten;
        call check10
        mov dl,' ';
        mov ah,02h;
        int 21h;

        inc bx;
        loop outputsortedarray
add count,1
        mov ax,4c00h;
        int 21h;
      
mysort proc near
;        push ax;
;        push cx;
        dec cx;
        mov ax,0;
      loop1:
        push cx;
        push si;
             loop2:
             mov al,byte ptr[si];
             cmp al,byte ptr[si+1];
             jbe next;

             xchg al,[si+1];
             xchg al,[si];

             next:
             inc si;
             loop loop2
       pop si;
       pop cx;
       loop loop1
;       pop cx;
;       pop ax;
       ret
mysort endp

printnum proc near
         push ax;
         push dx;
         push cx;
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
        pop cx;
        pop dx;
        pop ax;
        ret
printnum endp
check10 proc near
	
	cmp ckten,10;
	jne exit_check10
	lfandrt:
		mov ckten,0;
		push dx;
		push ax;
		lea dx,msg3;
        	mov ah,09h;
        	int 21h;
		pop ax;
		pop dx;
	exit_check10:
	ret
check10 endp
end	START
