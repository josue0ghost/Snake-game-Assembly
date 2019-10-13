.model small
.stack
.data
    dimX DB ?   ;dimensionX
    dimY DB ?   ;dimensionX
    mpX DB 'Ingrese dimension horizontal: $'
    mpY DB 'Ingrese dimension vertical: $'
    minsj DB 'W = arriba, S = abajo, D = derecha, A = izquierda (DESACTIVE MAYUS)$'
    mer1 DB 'No se puede regresar$'
    mer2 DB 'Fin de Juego$'
    mer3 DB 'Presione cualquier tecla para continuar...$'
    fin DB 00h
    
    limX DB ?
    limY DB ?
    
    ;cc
    ccX DB ?
    ccY DB ?
    
    ;movimientos
    arriba DB 77h       ;w
    abajo DB 73h        ;s
    izquierda DB 61h    ;a
    derecha DB  64h     ;d
    salir DB 78h        ;x
    ; caracteres
    barrera DB 178d  ; #
    cuerpo DB 4fh   ; O
    fruta DB 40h    ; @
    
    ;variables extra
    regA DW 0
    regB DW 0
    regC DW 0
    regD DW 0
    posSiz DB 0
    posLis DB ? ;varible de lista
.code
program proc far
    mov ax, @data
    mov ds, ax
    xor ax, ax    
    xor dx, dx

    call ingreso_datos    
    call instrucciones

    pantalla:
    call impresion_pantalla
    call leer_teclado

    cmp fin, 01h        ; si pierde, termina el programa
    jz fin_programa 
    jmp pantalla

    
    fin_programa:
    mov ah, 4ch
    int 21h

fin_juego proc
    call limpiar

    mov dl, offset mer2
    mov ah, 09h
    int 21h

    mov fin, 01h

    call presskey
    
    ret
fin_juego endp

impresion_pantalla proc
    call impresion_limites
    ;call movCursor
    CALL imprimirSer ;Ver linea 383

    ;mov dl, cuerpo
    ;mov ah, 02h
    ;int 21h

    ret
impresion_pantalla endp

leer_teclado proc
    mov ah, 08h             ;lee teclado
    int 21h

    cmp al, arriba
    jz mov_arriba
    
    cmp al, abajo
    jz mov_abajo

    cmp al, izquierda
    jz mov_izquierda

    cmp al, derecha
    jz mov_derecha

    cmp al, salir
    jz exit

    ; si no es ninguno no hace nada
    ret

    mov_arriba:
    sub ccY, 01h
    CALL moverPos ;Ver linea 406
    CALL verificar_cuerpo ;Ver linea 143
    call verificar_lim
    ret

    mov_abajo:
    add ccY, 01h
    CALL moverPos ;Ver linea 406
    CALL verificar_cuerpo ;Ver linea 143
    call verificar_lim
    ret

    mov_izquierda:
    sub ccX, 01h
    CALL moverPos ;Ver linea 406
    CALL verificar_cuerpo ;Ver linea 143
    call verificar_lim
    ret

    mov_derecha:
    add ccX, 01h
    CALL moverPos ;Ver linea 406
    CALL verificar_cuerpo ;Ver linea 143
    call verificar_lim
    ret

    exit:
    call fin_juego
    ret
leer_teclado endp

verificar_cuerpo proc
    ;si se mueve encima de su cuerpo
    CALL guardar
    CALL clean
    MOV CL , posSiz
    MOV AH, posLis[0]
    MOV AL, posLis[1]
    MOV SI, 2
    verCic:
    CMP SI , CX
    JZ fin_verC
    MOV BH , posLis[SI]
    INC SI
    MOV BL , posLis[SI]
    INC SI
    CMP AX , BX
    JZ sobreCuerpo
    JMP verCic
    
    sobreCuerpo:
    CALL reset
    CALL fin_juego
    ret
    
    fin_verC:
    CALL reset
    ret
verificar_cuerpo endp    

verificar_lim proc
    ;si esta Y o X en 0

    cmp ccY, 00h
    jz fuera_rango

    cmp ccX, 00h
    jz fuera_rango

    mov bh, limY
    cmp ccY, bh           ;renglon = impresion_limites
    jz fuera_rango

    mov bh, limX
    cmp ccX, bh             ;columna = impresion_limites
    jz fuera_rango

    ret

    fuera_rango:
    call fin_juego
    ret
verificar_lim endp

ingreso_datos proc
    ;ingreso de datos
    call limpiar

    mov dl, offset mpX  
    mov ah, 09h
    int 21h
    
    mov ah, 01h         ;ingreso de dimensiones en X
    int 21h
    
    sub al, 30h         ;asi se obtiene el numero real en vez del ascii
    mov ccX, al             
    add ccX, 01h        ;cursor al centro
    add al, al          
    add al, 01h         ;al = 2*dimX + 1
    mov dimX, al
    
    mov dl, 0dh         ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h
    
    mov dl, offset mpY  ;imprime mpY
    mov ah, 09h
    int 21h
    
    mov ah, 01h         ;ingreso de dimensiones en Y
    int 21h
    
    sub al, 30h         ;asi se obtiene el numero real en vez del ascii
    mov ccY, al         
    add ccY, 01h        ;cursor al centro
    add al, al          
    add al, 01h         ;al = 2*dimY + 1
    mov dimY, al
    
    mov dl, 0dh         ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h
    
    CALL serPrueba
    CALL ingresarPos
    ret
ingreso_datos endp

serPrueba proc ;crea una sepiente inicial de 5 segmentos, ver linea 240
    SUB ccX , 4
    CALL ingresarPos ;Ver Linea 441
    INC ccX
    CALL ingresarPos ;Ver Linea 441
    INC ccX
    CALL ingresarPos ;Ver Linea 441
    INC ccX
    CALL ingresarPos ;Ver Linea 441
    INC ccX
    RET
serPrueba endp

movCursor proc
    ;calcular el centro del tablero
    mov bh, 0h      ;pagina 0
    mov dl, ccX
    mov dh, ccY
    
    mov ah, 02h     ;coloca cursor
    int 10h    
    ret
movCursor endp    

limpiar proc
    mov ax, 0003h   ;limpia la pantalla
    int 10h

    ret
limpiar endp

impresion_limites proc
    call limpiar
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
    ret
impresion_limites endp

instrucciones proc
    call limpiar

    ;como ya no vamos a usar mpX y mpY los podemos cambiar jeje
    mov bh, dimX             
    mov limX, bh
    add limX, 01h                 ;son los l?mites para snake
    mov bh, dimY
    mov limY, bh
    add limY, 01h                 

    xor dx, dx
    mov dl, offset minsj    ;imprime instrucciones
    mov ah, 09h
    int 21h
    
    mov dl, 0dh         ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h
    
    call presskey

    ret
instrucciones endp

presskey proc
    xor dx, dx
    mov dl, 0dh             ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h

    mov dl, offset mer3        
    mov ah, 09h
    int 21h

    mov ah, 08h
    int 21h
    ret
presskey endp

lineaH proc
    xor cx, cx
    xor dx, dx
    
    mov cl, dimX
    add cl, 02h
    
    mov dl, barrera
    mov ah, 02h
    print:                
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
    
    mov dl, 20h             ; espacio
    mov ah, 02h
    printV:        
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

imprimirSer proc ;imprime serpiente en pantalla
    CALL guardar
    CALL clean
    MOV CL , posSiz
    MOV SI , 0
    ciclo2:
    MOV DL , posLis[SI]
    INC SI
    MOV DH , posLis[SI]
    INC SI
    
    MOV BH ,0
    MOV AH , 02h
    INT 10h
    
    MOV DL , cuerpo
    MOV AH , 02h
    INT 21h 
    
    LOOP ciclo2
    CALL reset
    RET
imprimirSer endp
moverPos proc ;mueve las posiciones de la sepiente
    CALL guardar
    CALL clean
    
    MOV BL , posSiz
    MOV DI , BX
    MOV SI , BX
    SUB SI , 2
    moverCic: ; Ciclo que mueve las posiciones
    CMP SI , 0
    JZ moverCicFin
    
    DEC SI
    DEC DI
    MOV AL , posLis[SI]
    MOV posLis[DI] , AL
    
    DEC SI
    DEC DI
    MOV AL , posLis[SI]
    MOV posLis[DI] , AL
    
    JMP moverCic
    moverCicFin: ; coloca los valore nuevos de la cabeza
    DEC DI
    MOV AL , ccY
    MOV posLis[DI] , AL
    
    DEC DI
    MOV AL , ccX
    MOV posLis[DI] , AL
    
    CALL reset
    RET
moverPos endp
ingresarPos proc ;inserta 2 posiciones m?s a la lista
    ADD posSiz , 2
    CALL moverPos
    RET
ingresarPos endp
guardar proc ; guarda los registros para evitar perder datos
    MOV regA , AX
    MOV regB , BX
    MOV regC , CX
    MOV regD , DX
    RET
guardar endp
reset proc ; inserta los valores guardados en los registros
    MOV AX , regA
    MOV BX , regB
    MOV CX , regC
    MOV DX , regD
    RET
reset endp
clean proc ;limpia los registros
    XOR AX ,AX
    XOR BX ,BX
    XOR CX ,CX
    XOR DX ,DX
    RET
clean endp
program endp
end program