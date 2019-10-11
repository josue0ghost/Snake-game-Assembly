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
    sub ccY, 01h
    ret

    mov_abajo:
    add ccY, 01h
    ret

    mov_izquierda:
    sub ccX, 01h
    ret

    mov_derecha:
    add ccX, 01h
    ret

    exit:
    call fin_juego
    ret
leer_teclado endp

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
    ;calcular el centro del tablero
    mov bh, 0h
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
 
program endp
end program