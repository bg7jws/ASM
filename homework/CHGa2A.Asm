CRLF  MACRO               ;�궨�壬�س�����
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
        MOV  	AX,STACK1    				;�μĴ����Ͷ�ջ��ʼ��
        MOV  	SS,AX
        MOV  	SP,TOP
        MOV  	BX,OFFSET BUF			;BXָ���ַ��л�������ַ.
KKK:    MOV  	SI,0000H    				;ƫ��ָ��SI��0
GGG:    MOV  	AH,01H
        INT  	21H         				;���ռ����ַ�
        CMP  	AL,03H
        JZ   	PPP         				;��CTRL-C����ת��������PPP
        CMP  	AL,0DH
        JZ   	BBB
        CMP  	AL,61H                      
        JB   	LLL                         ;AL<61H,תLLL
        CMP  	AL,7AH
        JA   	TTT     					;AL>7AH,����Сд��ĸתTTT
        SUB  	AL,20H          			;Сд��ĸתΪ��д��ĸ
;-----------------------------------
	mov  	[bx+si],al
	inc  	si
        jmp	GGG
LLL:    cmp  	al,41H                      
        jb   	TTT                         ;AL<41H,תTTT ���Ǵ�д��ĸתTTT
        cmp  	al,5AH
        ja   	TTT     					;AL>5AH,���Ǵ�д��ĸתTTT
        add  	al,20H
;-----------------------------------  
TTT:    MOV  	[BX+SI],AL      			;�����ַ��л�������
        INC  	SI              			;ƫ��ָ���1
        JMP  	GGG
BBB:    PUSH    AX
        CRLF                               ;�س�����
	POP     AX 
	MOV  	[BX+SI],AL
        MOV  	AL,0AH
        MOV  	[BX+SI+1],AL    			;���뻻�з�
        MOV  	AL,'$'
        MOV  	[BX+SI+2],AL    			;�ټ�һ��`$`��־�ַ�
        MOV  	AH,09H
        MOV  	DX,BX
        INT  	21H             			;��ʾת������ַ���
        JMP  	KKK             			;ѭ��
PPP:    MOV  	AX,4C00H	
        INT  	21H
CODE    ENDS                 					;����DOS
END     START