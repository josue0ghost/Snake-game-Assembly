.MODEL  small
.STACK
.DATA   
    dimX    DB  ?   ;dimensionX
    dimY    DB  ?   ;dimensionX
    mpX DB  'ingrese dimension horizontal: $'
    mpY DB  'ingrese dimension vertical: $'
    minsj DB 'W = arriba, S = abajo, D = derecha, A = izquierda (DESACTIVE MAYUS)$'
    mer1 DB  'No se puede regresar$'
    mer2 DB  'Fin de Juego$'
    
    ; caracteres
    barrera DB 178d  ; #
    cuerpo DB 4fh   ; O
    fruta DB 40h    ; @
   

.CODE
program:

   ;inicio de programa
    MOV AX, @DATA  ;guardar direccion de segmento de datos
    MOV DS, AX
    
    call ingresodata
    
    mov ax, 0003h   ;limpia la pantalla
    int 10h
    
    call lineaH
    
    mov dl, 0dh
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h
    
    mov bl, dimY
    printVertical:
        call lineaV
        dec bl
    jnz printVertical
    
    call lineaH

    

    fin_juego:   
    XOR DX , DX             ;limpiar registro
    MOV DL , OFFSET mer2    ;prepara mer2 para imprimir
    MOV AH , 09h
    INT 21h                 ;imprime mer2
    
    fin_programa:
    ;instruccion de fin de programa
    MOV AH, 4Ch
    INT 21h
    
    
    
    ingresodata proc
    ;ingresar dimension horizontal
    XOR DX, DX              ;limpiar registro
    MOV DL, OFFSET mpX      ;prepara mpX para imprimir
    MOV AH, 09h
    INT 21h                 ;imprime mpX
    MOV DL, 13d             ;char de fin de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    MOV DL, 10d             ;char de salto de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    
    MOV AH, 01h             ;AL = teclado
    INT 21h
    SUB AL, 30h             ;ascii->digito
    MOV dimX, AL            ;dimX = AL
    ADD AL, dimX            ;dimX = dimX + dimX
    INC AL                  ;dimX = dimX + 1
    MOV dimX, AL
    MOV DL, 13d             ;char de fin de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    MOV DL, 10d             ;char de salto de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    
    ;ingresar dimension vertical
    XOR DX, DX              ;limpiar registro
    MOV DL, OFFSET mpY      ;prepara mpY para imprimir
    MOV AH, 09h
    INT 21h                 ;imprime mpY
    MOV DL, 13d             ;char de fin de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    MOV DL, 10d             ;char de salto de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    MOV AH, 01h             ;AL = teclado
    INT 21h
    SUB AL, 30h             ;ascii->digito
    MOV dimY, AL            ;dimY = AL
    ADD AL, dimY            ;dimY = dimY + dimY
    INC AL                  ;dimY = dimY + 1
    MOV dimY, AL
    MOV DL, 13d             ;char de fin de linea
    MOV AH, 02h 
    INT 21h 
    MOV DL, 10d             ;char de salto de linea
    MOV AH , 02h 
    INT 21h 
    
    ;instrucciones
    XOR DX, DX            
    MOV DL, OFFSET minsj 
    MOV AH , 09h
    INT 21h     
    MOV DL, 13d             ;char de fin de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    MOV DL, 10d             ;char de salto de linea
    MOV AH, 02h 
    INT 21h                 ;imprime caracter
    
    ret
    ingresodata endp
    
    lineaH proc
        xor cx, cx
        xor dx, dx
        
        mov cl, dimX
        add cl, 02h
        
        mov dl, barrera
        
        print:
        
        mov ah, 02h
        int 21h 
        
        loop print
        
        ret
    lineaH endp
    
    lineaV proc
        xor dx, dx
        xor cx, cx
        mov cl, dimX
        
        mov dl, barrera
        mov ah, 02h
        int 21h
        
        mov dl, 20h
        
        printV:
        mov ah, 02h
        int 21h
        loop printV
        
        mov dl, barrera
        mov ah, 02h
        int 21h
        
        mov dl, 0dh
        int 21h
        
        mov dl, 0ah
        int 21h
        
        ret
    lineaV endp

end program