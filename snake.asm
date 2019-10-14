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
    
    ;coordenadas de cabeza
    ccX DB ?
    ccY DB ?
    ;coordenadas de fruta
    cmX DB ?
    cmY DB ?
    
    ;punteo
    spunteo DB 'Puntos: $'
    score DB 00h

    ;movimientos
    arriba DB 77h       ;w
    abajo DB 73h        ;s
    izquierda DB 61h    ;a
    derecha DB  64h     ;d
    salir DB 78h        ;x

    ; caracteres
    barrera DB 178d     ; #
    cuerpo DB 4fh       ; O
    fruta DB 40h        ; @
.code
program proc far
    mov ax, @data
    mov ds, ax
    xor ax, ax    
    xor dx, dx

    call ingreso_datos    
    call instrucciones
    call generar_fruta

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
    call movFruta

    mov dl, fruta     ;imprime la fruta
    mov ah, 02h
    int 21h 

    ret
imprimir_fruta endp

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

impresion_pantalla proc
    call impresion_limites
    call imprimir_fruta
    ;call imprimir_score

    call movCursor

    mov dl, cuerpo
    mov ah, 02h
    int 21h
    
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
    sub ccY, 01h        ;para subir se debe restar debido a c?mo est? definida la matriz de consola
    call verificar_lim
    call verificar_fruta
    ret

    mov_abajo:
    add ccY, 01h        ;para bajar se debe sumar debido a c?mo est? definida la matriz de consola
    call verificar_lim
    call verificar_fruta
    ret

    mov_izquierda:
    sub ccX, 01h        ;para ir a la izq se debe restar debido a c?mo est? definida la matriz de consola
    call verificar_lim
    call verificar_fruta
    ret

    mov_derecha:
    add ccX, 01h        ;para ir a la der se debe sumar debido a c?mo est? definida la matriz de consola
    call verificar_lim
    call verificar_fruta
    ret

    exit:
    call fin_juego
    ret
leer_teclado endp

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
    mov dl, 00h
    mov dh, dimY
    add dh, 01h         ;para colocar el cursor abajo del todo

    mov ah, 02h         ;coloca cursor
    int 10h    

    mov dl, spunteo     ;imprime "Punteo: "
    mov ah, 09h
    int 21h

    mov dl, score
    add dl, 30h         ;obtiene el ascii
    mov ah, 02h
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

    ret
ingreso_datos endp

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
 
program endp
end program