.model small
.data
.stack
.code
program:
    mov ax, @data
    mov ds, ax
    
    mov cx, 10
    mov bx, 10
    
    loop2:
    
    mov dl, 10
    mov ah, 02h
    int 21h
    
    loop1:
    
    mov dl, 23h ;caracter 
    mov ah, 02h
    int 21h
    
    dec cx
    jnz loop1
    
    ;reinicio el valor de cx a 10
    mov cx, 10
    
    dec bx
    jnz loop2
  
    ;finalizar programa
    mov ah, 4ch
    int 21h
end program