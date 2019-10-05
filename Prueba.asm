.MODEL  small
.DATA   ;segmento de datos
    px1 DB  ?   ;posicionX serpiente1
    py1 DB  ?   ;posicionY serpiente1
    px2 DB  ?   ;posicionX serpiente2
    py2 DB  ?   ;posicionY serpiente2
    px3 DB  ?   ;posicionX serpiente3
    py3 DB  ?   ;posicionY serpiente3
    px4 DB  ?   ;posicionX serpiente4
    py4 DB  ?   ;posicionY serpiente4
    dimX    DB  ?   ;dimensionX
    dimY    DB  ?   ;dimensionX
    mpX DB  'ingrese dimension horizontal$'
    mpY DB  'ingrese dimension vertical$'
    mer1 DB  'No se puede regresar$'
    mer2 DB  'Fin de Juego$'
.STACK  ;segmento de pila
.CODE
programa:   ;inicio de programa
    MOV AX , @DATA  ;guardar direccion de segmento de datos
    MOV DS , AX
    
    ;ingresar dimension horizontal
    XOR DX , DX ;limpiar registro
    MOV DX , OFFSET mpX    ;prepara mpX para imprimir
    MOV AH , 09h
    INT 21h ;imprime mpX
    MOV DL , 13 ;char de fin de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    MOV DL , 10 ;char de salto de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    MOV AH , 01h    ;AL = teclado
    INT 21h
    SUB AL , 30h    ;ascii->digito
    MOV px1 , AL    ;px1 = AL
    SUB AL , 1  ;AL = AL - 1
    MOV px2 , AL    ;px2 = AL
    SUB AL , 1  ;AL = AL - 1
    MOV px3 , AL    ;px3 = AL
    SUB AL , 1  ;AL = AL - 1
    MOV px4 , AL    ;px4 = AL
    ADD AL , 3  ;AL = AL + 3
    MOV dimX , AL   ;dimX = AL
    ADD AL , dimX   ;dimX = dimX + dimX
    SUB AL , 1  ;dimX = dimX - 1
    MOV dimX , AL
    MOV DL , 13 ;char de fin de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    MOV DL , 10 ;char de salto de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    
    ;ingresar dimension vertical
    XOR DX , DX ;limpiar registro
    MOV DX , OFFSET mpY    ;prepara mpY para imprimir
    MOV AH , 09h
    INT 21h ;imprime mpY
    MOV DL , 13 ;char de fin de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    MOV DL , 10 ;char de salto de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    MOV AH , 01h    ;AL = teclado
    INT 21h
    SUB AL , 30h    ;ascii->digito
    MOV py1 , AL   ;py1 = AL
    MOV py2 , AL   ;py2 = AL
    MOV py3 , AL   ;py3 = AL
    MOV py4 , AL   ;py4 = AL
    MOV dimY , AL   ;dimY = AL
    ADD AL , dimY   ;dimY = dimY + dimY
    SUB AL , 1  ;dimY = dimY - 1
    MOV dimY , AL
    MOV DL , 13 ;char de fin de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    MOV DL , 10 ;char de salto de linea
    MOV AH , 02h 
    INT 21h ;imprime caracter
    
    
    
    JMP fin_programa    ;salta a la etiqueta fin_programa

fin_programa:   ;etiqueta fin_programa
    XOR DX , DX ;limpiar registro
    MOV DX , OFFSET mer2    ;prepara mer2 para imprimir
    MOV AH , 09h
    INT 21h ;imprime mer2
    ;instruccion de fin de programa
    MOV AH, 4Ch
    INT 21h
END programa