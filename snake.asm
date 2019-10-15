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
    mer4 DB 'No puede regresar$'
    fin DB 00h              ;booleano para fin de juego
    
    limX DB ?               ;limites de la matriz
    limY DB ?
    
    ;coordenadas de cabeza
    ccX DB ?
    ccY DB ?
    ;coordenadas de fruta
    cmX DB ?
    cmY DB ?
    enF DB 00h              ;bool para ver si come fruta

    ;punteo
    spunteo DB 'Puntos: $'
    score DB 00h
    
    diez DB 10d
    residuo DB ?
    cociente DB ?
    
    ;movimientos
    arriba DB 77h       ;w
    abajo DB 73h        ;s
    izquierda DB 61h    ;a
    derecha DB  64h     ;d
    salir DB 78h        ;x
    ; caracteres
    barrera DB 178d     ; ?
    cuerpo DB 02h       ; ?
    fruta DB 40h        ; @
    
    ;variables extra
    movAnte DB 0        ;movimiento anterior
    regA DW 0
    regB DW 0
    regC DW 0
    regD DW 0
    posSiz DB 0         ;tamano de lista
    posLis DB ?         ;varible de lista
.code
program proc far
    mov ax, @data
    mov ds, ax
    xor ax, ax    
    xor dx, dx

    call ingreso_datos    
    call instrucciones
    call generar_fruta
    call impresion_limites
    
    pantalla:
    call impresion_pantalla
    call leer_teclado

    cmp fin, 01h        ; si pierde, termina el programa
    jz fin_programa 
    jmp pantalla

    
    fin_programa:
    mov ah, 4ch
    int 21h

limpiar proc
    mov ax, 0003h   ;limpia la pantalla
    int 10h

    ret
limpiar endp

fin_juego proc
    call limpiar
    
    xor ax, ax
    xor dx, dx
    
    mov dl, offset mer2
    mov ah, 09h
    int 21h

    mov fin, 01h        ;bool gameover = true
    
    mov dl, 0dh         ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h         
    
    xor ax, ax
    xor dx, dx
    
    mov dl, offset spunteo     ;imprime Punteo:
    mov ah, 09h
    int 21h
    
    xor ax, ax
    mov dl, score
    mov al, dl
    div diez                ;divide entre 10 para obtener el numero con 2 digitos
    
    mov residuo, al         ;guardo los resultados
    mov cociente, ah
    add residuo, 30h        ;obtengo ascii
    add cociente, 30h   
    
    mov dl, residuo
    mov ah, 02h
    int 21h             ;imprime puntaje
    mov dl, cociente
    int 21h             ;imprime puntaje
    
    call presskey
    
    ret
fin_juego endp

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

    mov ah, 08h             ;interrupcion que espera una
    int 21h                 ;entrada de teclado
    
    ret
presskey endp

imprimir_fruta proc
    call movFruta           ;mueve el cursor para imprimir la fruta

    mov dl, fruta           ;imprime la fruta
    mov ah, 02h
    int 21h 

    ret
imprimir_fruta endp

mostrarRegreso proc
    CALL guardar
    CALL clean
    
    CALL limpiar 
    MOV DL , offset mer4    ;muestra mensaje de error cuando el jugador
    MOV AH , 09h            ;intenta mover de regreso la serpiente
    INT 21h
    CALL presskey
    
    CALL reset
    RET
mostrarRegreso endp

generar_fruta proc
    generarX:
    mov ah, 2ch         ;obtiene la hora
    int 21h
    
    ;ch->horas; cl->minutos; dh->segundos; dl->milisegundos
    
    cmp dl, 0h          ;si milisegundos es igual a 0 lo vuelve a generar
    jz generarX
    
    mov bh, limX
    dec bh
    cmp bh, dl          ;si milisegundos es mayor a los limites lo vuelve a generar
    js generarX

    mov cmX, dl         ;asigna a cmX

    generarY:
    mov ah, 2ch         ;obtiene la hora
    int 21h

    ;ch->horas; cl->minutos; dh->segundos; dl->milisegundos

    cmp dl, 0h          ;si milisegundos es igual a 0 lo vuelve a generar
    jz generarY
    
    mov bh, limY
    dec bh
    cmp bh, dl          ;si segundos es mayor a los limites lo vuelve a generar
    js generarY
    
    mov cmY, dl         ;asigna a cmY          
    
    ;si la fruta no cae encima de su cuerpo
    CALL guardar
    CALL clean
    MOV CL , posSiz
    MOV AH, cmX         ;coordenadas de la fruta
    MOV AL, cmY
    MOV SI, 0
    verFrutaCuerpo:
    CMP SI , CX
    JZ frutaCorrecta
    MOV BH , posLis[SI]
    INC SI
    MOV BL , posLis[SI]
    INC SI
    CMP AX , BX
    JZ frutaSobreCuerpo
    JMP verFrutaCuerpo

    frutaSobreCuerpo:
    CALL reset
    JMP generarX

    frutaCorrecta:
    CALL reset
    ret
generar_fruta endp

movFruta proc
    mov bh, 0h      ;pagina 0
    mov dl, cmX     ;en dl se guardan las columnas
    mov dh, cmY     ;en dh se guardan los renglones
    
    mov ah, 02h     ;coloca cursor
    int 10h    
    ret
movFruta endp 

reset_campo proc
    mov bh, 0h
    mov dl, 01h     ;columnas
    mov dh, 01h     ;renglon
    
    mov ah, 02h     ;colocar cursor en (1,1)
    int 10h
    
    xor cx, cx
    mov cl, limY
    dec cl          ;cl = limY - 1
    imp_espacios:
    mov bh, limX
    dec bh          ;bh = limX - 1
    
    imp_esp2:
    
    mov dl, 32d     ;espacio
    mov ah, 02h
    int 21h
    
    dec bh
    jnz imp_esp2
    
    mov dl, 01h     ;columna 1
    inc dh          ;dh + 1
    int 10h         ;mueve cursor
    
    loop imp_espacios
    
    
    ret
reset_campo endp

impresion_pantalla proc
    call reset_campo
    call imprimir_fruta
    call imprimir_score

    CALL imprimirSer    ;imprime serpiente
    
    call killbug        ;correccion de error menor
    
    ret
impresion_pantalla endp

moverSerpiente proc
    CALL verificar_cuerpo   ;ver linea 394
    call verificar_lim      ;ve si toca los limites de la matriz
    MOV movAnte, AL

    ret
moverSerpiente endp

leer_teclado proc
    mov ah, 08h             ;lee teclado guardando el ascii en AL
    int 21h
    MOV AH , movAnte        ;mueve anterior a un registro
    
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
    ret                             ; si no es ninguno no hace nada

    mov_arriba:
    CMP AH , abajo                  ;no puede regresar
    JZ regreso2                     ;salto intermedio
    sub ccY, 01h                    ;para subir, debe restar Y
    call verificar_fruta            ;verifica si come una fruta
    cmp enF, 01h                    ;bool de fruta comida
    jz insAR                        ;insertar arriba
    CALL moverPos                   ;mueve las posiciones de la serpiente
    call moverSerpiente
    ret 
    insAR:                          
    mov enF, 00h
    CALL ingresarPos                ;aumenta el tamano de la serpiete
    call moverSerpiente
    ret

    mov_derecha:
    jmp mov_derecha2                ;salto intermedio

    mov_abajo:
    CMP AH , arriba                 ;no puede regresar
    JZ regreso
    add ccY, 01h                    ;para bajar, debe sumar Y
    call verificar_fruta            ;verifica si come una fruta
    cmp enF, 01h                    ;bool de fruta comida
    jz insAB                        ;insertar abajo
    CALL moverPos                   
    call moverSerpiente
    ret
    insAB:
    mov enF, 00h
    CALL ingresarPos                
    call moverSerpiente
    ret

    exit:               
    jmp exit2                       ;salto intermedio
    
    regreso2:
    jmp regreso                     ;salto intermedio

    mov_izquierda:
    CMP AH , derecha                ;no puede regresar
    JZ regreso
    sub ccX, 01h                    ;para moverse a la izquierda debe restar X
    call verificar_fruta            ;verifica si come fruta
    cmp enF, 01h                    ;bool de fruta comida
    jz insIZ                        ;insertar a la izquierda
    CALL moverPos 
    call moverSerpiente
    ret
    insIZ:
    mov enF, 00h
    CALL ingresarPos 
    call moverSerpiente
    ret

    mov_derecha2:
    CMP AH , izquierda              ;no puede regresar
    JZ regreso
    add ccX, 01h                    ;para moverse a la derecha debe sumar X
    call verificar_fruta            ;verifica si come fruta
    cmp enF, 01h                    ;bool de fruta comida
    jz insDE                        ;insertar a derecha
    call moverPos 
    call moverSerpiente
    ret
    insDE:
    mov enF, 00h
    call ingresarPos 
    call moverSerpiente
    ret
    
    exit2:
    call fin_juego                  ;fin de juego
    ret

    regreso:
    CALL mostrarRegreso             ;mensaje de que no puede regresar
    RET
leer_teclado endp

ver_cuerpo_fruta proc
    ;si la fruta no cae encima de su cuerpo
    CALL guardar
    CALL clean
    MOV CL , posSiz
    MOV AH, cmX
    MOV AL, cmY
    MOV SI, 0
    verCicF:
    CMP SI , CX
    JZ fin_verCF
    MOV BH , posLis[SI]
    INC SI
    MOV BL , posLis[SI]
    INC SI
    CMP AX , BX
    JZ sobreCuerpoF
    JMP verCicF
    
    sobreCuerpoF:
    CALL reset
    CALL fin_juego
    ret
    
    fin_verCF:
    CALL reset
    ret
ver_cuerpo_fruta endp   

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

    cmp ccY, 00h        ;para ver si topa con la parede superior
    jz fuera_rango

    cmp ccX, 00h        ;para ver si topa con la parede izquierda
    jz fuera_rango

    mov bh, limY        ;para ver si topa con la pared derecha
    cmp ccY, bh         ;renglon = impresion_limites
    jz fuera_rango

    mov bh, limX        ;para ver si topa con la pared inferior
    cmp ccX, bh         ;columna = impresion_limites
    jz fuera_rango

    ret                 ;si no topa con nada, hace nada

    fuera_rango:
    call fin_juego
    ret
verificar_lim endp

imprimir_score proc
    xor ax, ax
    xor dx, dx
    
    mov dl, 00h
    mov dh, dimY
    add dh, 02h         ;para colocar el cursor abajo del todo

    mov ah, 02h         ;coloca cursor
    int 10h    
    
    xor ax, ax
    xor dx, dx
    
    mov dl, offset spunteo     ;imprime Punteo:
    mov ah, 09h
    int 21h

    xor ax, ax
    mov dl, score
    mov al, dl
    div diez                ;divide entre 10 para obtener el numero con 2 digitos
    
    mov residuo, al         ;guardo los resultados
    mov cociente, ah
    add residuo, 30h        ;obtengo ascii
    add cociente, 30h   
    
    mov dl, residuo
    mov ah, 02h
    int 21h             ;imprime puntaje
    mov dl, cociente
    int 21h             ;imprime puntaje
    
    ret
imprimir_score endp

puntos proc
    add score, 01h           ;incrementa en 1 el score
    ret
puntos endp

verificar_fruta proc
    mov bh, cmY
    cmp ccY, bh         ;para ver si encuentra fruta en Y
    jz comp_X
    ret                 ;si no esta en las mismas cc de Y hace nada

    comp_X:
    mov bh, cmX
    cmp ccX, bh         ;para ver si encuentra fruta en X
    jz sumar_score

    ret                 ;si no esta en las mismas xx de X, hace nada

    sumar_score:
    mov enF, 01h        ;bandera de comer fruta
    call puntos
    call generar_fruta
    ret
verificar_fruta endp

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
    
    ;CALL serPrueba
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
    mov bh, 0h      ;pagina 0
    mov dl, ccX     ;en dl se guardan las columnas
    mov dh, ccY     ;en dh se guardan los renglones
    
    mov ah, 02h     ;coloca cursor
    int 10h    
    ret
movCursor endp    

impresion_limites proc
    call limpiar
    call lineaH     ;imprime linea horizontal
    
    mov dl, 0dh     ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h
    
    mov bl, dimY    ;bl es nuestro contador porque cl ya est? siendo usado en lineaV
    printVertical:
    call lineaV     ;imprime varias veces los limites de los lados
    dec bl          ;decrementa el contador
    jnz printVertical
    
    call lineaH     ;imprime la linea inferior
    ret
impresion_limites endp

instrucciones proc
    call limpiar

    mov bh, dimX             
    mov limX, bh
    add limX, 01h           ;son los limites para snake
    mov bh, dimY
    mov limY, bh
    add limY, 01h                 

    xor dx, dx
    mov dl, offset minsj    ;imprime instrucciones
    mov ah, 09h
    int 21h
    
    mov dl, 0dh             ;fin y salto de linea
    mov ah, 02h
    int 21h
    mov dl, 0ah
    int 21h
    
    call presskey

    ret
instrucciones endp

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

moverPos proc               ;mueve las posiciones de la sepiente
    CALL guardar
    CALL clean
    
    MOV BL , posSiz
    MOV DI , BX
    MOV SI , BX
    SUB SI , 2
    moverCic:               ; Ciclo que mueve las posiciones
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
    moverCicFin:            ; coloca los valore nuevos de la cabeza
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

killbug proc
    call guardar
    call clean
    
    mov bh, 0h      ;pagina 0
    mov dl, 0     ;en dl se guardan las columnas
    mov dh, 0     ;en dh se guardan los renglones
    
    mov ah, 02h     ;coloca cursor
    int 10h
    
    mov dl, barrera
    mov ah, 02h
    int 21h
    mov dl, barrera
    mov ah, 02h
    int 21h
    
    call reset
    RET
killbug endp

program endp
end program