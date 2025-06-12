data segment
string db "Hello World", 24h
data ends
code segment
assume cs:code,ds:data
start:
mov ax,data
mov ds,ax
mov dx,offset string
mov ah,09h
int 21h
mov ah,4ch
int 21h
code ends
end start