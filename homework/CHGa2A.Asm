CRLF  MACRO               ;宏定义，回车换行
      MOV  	AH,02H
      MOV  	DL,0DH
      INT  	21H
      MOV  	AH,02H
      MOV  	DL,0AH
      INT  	21H
ENDM
DATA  	SEGMENT
BUF   	DB     82 DUP(?)
DATA  	ENDS
STACK1 	SEGMENT
STA   	DB    50 DUP(?)
TOP   	EQU   LENGTH STA
STACK1	ENDS
CODE  	SEGMENT
ASSUME  CS:CODE,DS:DATA,ES:DATA,SS:STACK1
START:  MOV  	AX,DATA
        MOV  	DS,AX
        MOV  	ES,AX
        MOV  	AX,STACK1    				;段寄存器和堆栈初始化
        MOV  	SS,AX
        MOV  	SP,TOP
        MOV  	BX,OFFSET BUF			;BX指向字符行缓冲区首址.
KKK:    MOV  	SI,0000H    				;偏移指针SI清0
GGG:    MOV  	AH,01H
        INT  	21H         				;接收键入字符
        CMP  	AL,03H
        JZ   	PPP         				;是CTRL-C键则转结束程序PPP
        CMP  	AL,0DH
        JZ   	BBB
        CMP  	AL,61H                      
        JB   	LLL                         ;AL<61H,转LLL
        CMP  	AL,7AH
        JA   	TTT     					;AL>7AH,不是小写字母转TTT
        SUB  	AL,20H          			;小写字母转为大写字母
;-----------------------------------
	mov  	[bx+si],al
	inc  	si
        jmp	GGG
LLL:    cmp  	al,41H                      
        jb   	TTT                         ;AL<41H,转TTT 不是大写字母转TTT
        cmp  	al,5AH
        ja   	TTT     					;AL>5AH,不是大写字母转TTT
        add  	al,20H
;-----------------------------------  
TTT:    MOV  	[BX+SI],AL      			;存入字符行缓冲区中
        INC  	SI              			;偏移指针加1
        JMP  	GGG
BBB:    PUSH    AX
        CRLF                               ;回车换行
	POP     AX 
	MOV  	[BX+SI],AL
        MOV  	AL,0AH
        MOV  	[BX+SI+1],AL    			;加入换行符
        MOV  	AL,'$'
        MOV  	[BX+SI+2],AL    			;再加一个`$`标志字符
        MOV  	AH,09H
        MOV  	DX,BX
        INT  	21H             			;显示转换后的字符串
        JMP  	KKK             			;循环
PPP:    MOV  	AX,4C00H	
        INT  	21H
CODE    ENDS                 					;返回DOS
END     START
