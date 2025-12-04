;******************************************************************************
;                              PROYECTO FINAL
;******************************************************************************
#include registers.inc
; Autora: Daniela Fonseca Zumbado
; Version: 1.0
; Descripción: Este proyecto implementa un velódromo con 4 modos de operación,
; el cual
;******************************************************************************
;                 INICIALIZACION DE VECTOR DE INTERRUPCIONES
;******************************************************************************
                                Org $3E4A
                                dw Maquina_Tiempos
                                
;*******************************************************************************
;                            DEFINICION DE VALORES
;*******************************************************************************

;--- Aqui se colocan los valores de carga para los timers baseT  ----

tTimer1mS:        EQU 50     ;Base de tiempo de 1 mS (20uS x 50)
tTimer10mS:       EQU 500    ;Base de tiempo de 10 mS (20uS x 500)
tTimer100mS:      EQU 5000   ;Base de tiempo de 100 mS (20uS x 5000)
tTimer1S:         EQU 50000  ;Base de tiempo de 1 segundo (20uS x 50000)

;--- Valores para la Tarea Espera ---

LDEspera:         EQU $01    ; Mascara para encender LED de Tarea Espera

;--- Valores para la Tarea Configurar ---

LDConfig:         EQU $02    ; Mascara para encender LED de Tarea Configurar

MinNumVueltas:    EQU 3      ; Minimo numero de vueltas
MaxNumVueltas:    EQU 20     ; Maximo numero de vueltas

;--- Valores para la Tarea Correr ---

LDCorrer:         EQU $04    ; Mascara para encender LED de Tarea Correr

tTimerCal:        EQU 100    ; Tiempo de timer de calculo de 1 S (100 mS x 100)
tTimerError:      EQU 3      ; Tiempo de timer de error de 3 S (1 S x 3)

DeltaS:           EQU 50     ; Distancia entre sensores de 50 m
DeltaM:           EQU 150    ; Distancia a Inicio de Mensaje de 150 m
DeltaP:           EQU 250    ; Distancia a pantalla de 250 m

PortRele:                    ; Puerto al que se encuentra conectado el Rele
Rele:

VMin:             EQU 35     ; Velocidad minima de 35 km/h
VMax:             EQU 90     ; Velocidad maxima de 90 km/h

;--- Valores para la Tarea Resumen ---

LDResumen:        EQU $08    ; Mascara para encender LED de Tarea Resumen

;--- Valores para la Tarea Teclado ---

tSupRebTCL:       EQU 10     ; Tiempo de supresion de rebotes x 1 mS (Teclado)

F1:               EQU $EF    ; Mascara para funcion 1 - Modo espera
F2:               EQU $DF    ; Mascara para funcion 2 - Modo configurar
F3:               EQU $BF    ; Mascara para funcion 3 - Modo correr
F4:               EQU $7F    ; Mascara para funcion 4 - Modo resumen

;--- Valores para la Tarea Brillo ---

tTimerBrillo:     EQU 4
MaskSCF:

;--- Valores para la Tarea Led Testigo

tTimerLDTst:      EQU 5      ; Tiempo de parpadeo de LED testigo x 100 mS

;--- Valores para las tareas Leer PB1 y Leer PB2

PortPB:           EQU PTIH   ; Se define el puerto donde se ubica el PB
MaskPB1:          EQU $08    ; Se define el bit 3 del PB en el puerto
MaskPB2:          EQU $01    ; Se define el bit 0 del PB en el puerto

tSupRebPB1:       EQU 10     ; Tiempo de supresion de rebotes x 1 mS (PB)
tSupRebPB2:       EQU 10     ; Tiempo de supresion de rebotes x 1 mS (PB)
tShortP1:         EQU 25     ; Tiempo minimo ShortPress x 10 mS
tLongP1:          EQU 2      ; Tiempo minimo LongPress en segundos
tShortP2:         EQU 25     ; Tiempo minimo ShortPress x 10 mS
tLongP2:          EQU 2      ; Tiempo minimo LongPress en segundos

;--- Valores para la Tarea PantallaMUX ---

tTimerDigito:     EQU 2

MaxCountTicks:    EQU 100    ; Cantidad máxima de ticks para los dígitos

DIG1:             EQU $01    ; Dígito 1 de la pantalla MUX
DIG2:             EQU $02    ; Dígito 2 de la pantalla MUX
DIG3:             EQU $04    ; Dígito 3 de la pantalla MUX
DIG4:             EQU $08    ; Dígito 4 de la pantalla MUX

OFF:              EQU $BB    ; Offset de comando de apagado en la tabla Segment
GUIONES:          EQU $AA    ; Offset de comando de guin en la tabla Segment

;--- Valores para la Tarea LCD ---

tTimer2ms:        EQU 100    ; Tiempo de timer de 2 mS (20uS x 100)
tTimer40uS:       EQU 2      ; Tiempo de timer de 40 uS (20uS x 2)
tTimer260uS:      EQU 13     ; Tiempo de timer de 260 uS (20uS x 13)

EOB:              EQU $FF

Clear_Display:    EQU $01

ADD_L1:           EQU $80    ; Direccion de la linea 1 del LCD
ADD_L2:           EQU $C0    ; Direccion de la linea 2 del LCD

;--- Banderas ---

ShortP1:          EQU $01    ; Bandera de pulso corto en boton PB1
LongP1:           EQU $02    ; Bandera de pulso largo en boton PB1
ShortP2:          EQU $04    ; Bandera de pulso corto en boton PB2
LongP2:           EQU $08    ; Bandera de pulso largo en boton PB2
ArrayOK:          EQU $10    ; Bandera de que array se lleno correctamente

RS:               EQU $01
LCD_OK:           EQU $02
FinSendLCD:       EQU $04
Second_Line:      EQU $08

LD_Red:           EQU $10
LD_Green:         EQU $20
LD_Blue:          EQU $40

;--- Valores generales ---

Carga_TC4:

;*******************************************************************************
;                   DECLARACION DE LAS ESTRUCTURAS DE DATOS
;*******************************************************************************

;--- Estructuras de datos de Tarea Configurar ---

EstPres_TConfig:  ds 2       ; Variable para guardar el estado de Tarea Config
ValorNumVueltas:  ds 1       ; Variable temporal para el numero de vueltas
NumVueltas:       ds 1       ; Variable final para el numero de vueltas

;--- Estructuras de datos de Tarea Correr ---

EstPres_TCorrer:  ds 2       ; Variable para guardar el estado de Tarea Correr
DeltaT:           ds 1
Velocidad:        ds 1
AcumVelocidad:    ds 2
Vueltas:          ds 1

;--- Estructuras de datos de Tarea Brillo ---

EstPres_TBrillo:  ds 2       ; Variable para guardar el estado de Tarea Brillo

;--- Estructuras de datos de Tarea Teclado ---
                  ORG $1000
MAX_TCL:          db $05     ; Limite maximo del tamano de Num_Array
Tecla:            ds 1       ; Variable para guardar la tecla actual
Tecla_IN:         ds 1       ; Variable para guardar la tecla ingresada
Cont_TCL:         ds 1       ; Variable para guardar tamano actual de Num_Array
Patron:           ds 1       ; Variable para guardar patron a escribir y leer
                             ; en el teclado
Funcion:          ds 1       ; Variable para guardar patron a escribir en LEDs
EstPres_TCL:      ds 2       ; Variable para direccion de estado de maquina de
                             ; estados Tarea_Teclado

                  ORG $1010
Num_Array:        ds 5       ; Array donde guardar valores ingresados por el
                             ; teclado
                             
;--- Estructuras de datos de Tarea Led Testigo ---

EstPres_LDTst:    ds 2       ; Variable para guardar el estado de Tarea Led
                             ; Testigo
                             
;--- Estructuras de datos de Tarea Leer PB1 y Leer PB2 ---

EstPres_LeerPB1:  ds 2       ; Variable para guardar estado de Leer PB1
EstPres_LeerPB2:  ds 2       ; Variable para guardar estado de Leer PB2

;--- Estructuras de datos de Tarea PantallaMUX ---

                          ORG $1020
EstPres_PantallaMUX:    ds 2 ; Variable para guardar estado de tarea de pantalla
                             ; multiplexada
DSP1:             ds 1
DSP2:             ds 1
DSP3:             ds 1
DSP4:             ds 1
LEDS:             ds 1       ; Variable para almacenar el estado de los leds
Cont_Dig:         ds 1
Brillo:           ds 1

;--- Estructuras de datos de subrutinas de Conversion ---

BCD:              ds 1
Cont_BCD:         ds 1
BCD1:             ds 1
BCD2:             ds 1

;--- Estructuras de datos de Tarea LCD ---

IniDsp:           db $28     ; Function Set
                  db $28     ; Function Set
                  db $06     ; Entry Mode Set
                  db $0C     ; Display ON/OFF - (D) = 1, (C) = 0, (B) = 0
                  db $FF     ; Fin de trama
Punt_LCD:         ds 2
CharLCD:          ds 1
Msg_L1:           ds 2       ; Puntero a mensaje para la primera linea de LCD
Msg_L2:           ds 2       ; Puntero a mensaje para la segunda linea de LCD
EstPres_SendLCD:  ds 2       ; Variable para guardar estado de Tarea Send LCD
EstPres_TareaLCD: ds 2       ; Variable para guardar estado de Tarea LCD

;--- Banderas ---

                  ORG $1070
Banderas_1:       ds 1       ; Variable de banderas para botones y Array OK
Banderas_2:       ds 1       ; Variable de banderas para comandos LCD

;--- Estructuras de datos generales ---

                  ORG $1080
LED_Testigo:      ds 1

;--- Tablas ---

; Patrones de segmentos a mostrar en display de 7 segmentos
                  ORG $1100
Segment:          db $3F                ; 0
                  db $06                ; 1
                  db $5B                ; 2
                  db $4F                ; 3
                  db $66                ; 4
                  db $6D                ; 5
                  db $7D                ; 6
                  db $07                ; 7
                  db $7F                ; 8
                  db $6F                ; 9
                  db $40                ; guion
                  db $00                ; apagado

; Codigos de Teclas validas
                  ORG $1110
Teclas:           db $01,$02,$03        ; 1, 2, 3
                  db $04,$05,$06        ; 4, 5, 6
                  db $07,$08,$09        ; 7, 8, 9
                  db $0B,$00,$0E        ; B, 0, E

;--- Mensajes de la aplicacion ---
                      ORG $1200
Msg_Modo_Espera_P1:   fcc "*VELODROMO  623*"
                      db $FF
Msg_Modo_Espera_P2:   fcc "**MODO  ESPERA**"
                      db $FF
Msg_Modo_Config_P1:   fcc "MODO  CONFIGURAR"
                      db $FF
Msg_Modo_Config_P2:   fcc "* NUM  VUELTAS *"
                      db $FF
Msg_Espera_Inicio_P1: fcc "* MODO  CORRER *"
                      db $FF
Msg_Espera_Inicio_P2: fcc "ESPERANDO INICIO"
                      db $FF
Msg_Espera_S1_P1:     fcc "* MODO  CORRER *"
                      db $FF
Msg_Espera_S1_P2:     fcc "ESPERANDO S1... "
                      db $FF
Msg_Espera_S2_P1:     fcc "* MODO  CORRER *"
                      db $FF
Msg_Espera_S2_P2:     fcc "ESPERANDO S2... "
                      db $FF
Msg_TimerPant_P1:     fcc "**MODO  CORRER**"
                      db $FF
Msg_TimerPant_P2:     fcc "TIniP      TFinP"
                      db $FF
Msg_Resultados_P1:    fcc "* MODO  CORRER *"
                      db $FF
Msg_Resultados_P2:    fcc "VELOC.   VUELTAS"
                      db $FF
Msg_Alerta_Vel_P1:    fcc "**  VELOCIDAD **"
                      db $FF
Msg_Alerta_Vel_P2:    fcc "*FUERA DE RANGO*"
                      db $FF
Msg_Fin_Ciclo_P1:     fcc "* MODO  CORRER *"
                      db $FF
Msg_Fin_Ciclo_P2:     fcc "**FIN DE CICLO**"
                      db $FF
Msg_Resumen_P1:       fcc "  MODO RESUMEN  "
                      db $FF
Msg_Resumen_P2:       fcc "VUELTAS    VELOC"
                      db $FF
Msg_Vacio:            fcc ""
                      db $FF

;===============================================================================
;                              TABLA DE TIMERS
;===============================================================================
                  ORG $1500
Tabla_Timers_BaseT:

Timer1mS:       ds 2       ;Timer 1 ms con base a tiempo de interrupcion
Timer10mS:      ds 2       ;Timer para generar la base de tiempo 10 mS
Timer100mS:     ds 2       ;Timer para generar la base de tiempo de 100 mS
Timer1S:        ds 2       ;Timer para generar la base de tiempo de 1 Seg.
Timer40uS:      ds 2
Timer260uS:     ds 2
CounterTicks:   ds 2

Fin_BaseT       dW $FFFF

Tabla_Timers_Base1mS

Timer_RebPB1:   ds 1
Timer_RebPB2:   ds 1
Timer_RebTCL:   ds 1
Timer_Digito:   ds 1
Timer2mS:       ds 1

Fin_Base1mS:    dB $FF

Tabla_Timers_Base10mS

Timer_SHP1:     ds 1
Timer_SHP2:     ds 1

Fin_Base10ms:   dB $FF

Tabla_Timers_Base100mS

Timer1_100mS:   ds 1
TimerLDTst:     ds 1
TimerBrillo:    ds 1
TimerCal:       ds 1
TimerIniPant:   ds 1
TimerFinPant:   ds 1

Fin_Base100mS:  dB $FF

Tabla_Timers_Base1S

Timer_LP1:       ds 1
Timer_LP2:       ds 1
SegundosTCM:     ds 1
TimerError:     ds 1

Fin_Base1S:      dB $FF

;===============================================================================
;                              CONFIGURACION DE HARDWARE
;===============================================================================
                              Org $2000

        BSet DDRB,$FF     ;Habilitacion de los LEDs
        BSet DDRJ,$02     ;como comprobacion del timer de 1 segundo
        BSet PTJ,$02      ;haciendo toogle

        BSet DDRP,$7F
        BSet PTP,$0F      ; Apaga display

        BClr MCCTL,#$04   ; Borrar enable
        Movb #$E3,MCCTL   ; Habilitar interrupciones module count down con
                          ; divisor 16
        BSet MCCTL,#$04   ; Poner el enable
        Movw #30,MCCNT    ; Cargar valor inicial de contador

        Movb #$F0,DDRA
        BSet PUCR,$01

;===============================================================================
;                           PROGRAMA PRINCIPAL
;===============================================================================

        Movw #tTimer1mS,Timer1mS
        Movw #tTimer10mS,Timer10mS         ;Inicia los timers de bases de tiempo
        Movw #tTimer100mS,Timer100mS
        Movw #tTimer1S,Timer1S

        Movb #tTimerLDTst,TimerLDTst  ;inicia timer parpadeo led testigo
        Movb #0,Timer_LP1
        Movb #0,Timer_LP2

        ; Inicializacion de estados de maquinas de estado
        Movw #TConfig_Est1,EstPres_TConfig
        Movw #TCorrer_Est1,EstPres_TCorrer
        Movw #TareaLDTst_Est1,EstPres_LDTst
        Movw #PantallaMUX_Est1,EstPres_PantallaMUX
        Movw #LeerPB1_Est1,EstPres_LeerPB1
        Movw #LeerPB2_Est1,EstPres_LeerPB2
        Movw #Teclado_Est1,EstPres_TCL
        Movw #TareaLCD_Est1,EstPres_TareaLCD
        Movw #TareaSendLCD_Est1,EstPres_SendLCD
        Movw #TareaBrillo_Est1,EstPres_TBrillo

        ; Inicializacion de Pantalla LCD (timers)
        Movw #tTimer260uS,Timer260uS
        Movw #tTimer40uS,Timer40uS

        Movb #$C0,ATD0CTL2
        Movb #$20,ATD0CTL3
        Movb #$90,ATD0CTL4

        ; Pantalla MUX
        Movb #$01,Cont_Dig
        Movb #$BB,BCD2
        Movb #$BB,BCD1

        ; Pantalla LCD
        Clr Banderas_1
        Clr LEDS
        Clr Vueltas
        Clr AcumVelocidad
        Clr 1,AcumVelocidad
        Clr Velocidad
        Clr NumVueltas

        ; Teclado
        Movb #$FF,Tecla
        Movb #$FF,Tecla_IN
        Movb #$00,Cont_TCL
        Movb #$FF,Num_Array

        Movb #$00,Patron
        Movb #F1,Funcion

        Lds #$3BFF
        Cli
        Clr Banderas_1

        Jsr Init_LCD
        Bra Despachador_Tareas

;******************************************************************************
;                              INICIALICION LCD
;******************************************************************************

Init_LCD        ; Inicializacion de Pantalla LCD (otros)
                ;Movw #Msg_Modo_Espera_P1,Msg_L1
                ;Movw #Msg_Modo_Espera_P2,Msg_L2
                ;BClr Banderas_2,LCD_OK
                Movb #$FF,DDRK                    ; Inicializar como salida
                Movw #IniDsp,Punt_LCD             ; Cargar direccion de comandos
                BClr Banderas_2,RS                ; Inicializar banderas en 0
                BClr Banderas_2,Second_Line
                BClr Banderas_2,LCD_OK
                Ldx Punt_LCD                      ; Cargar direccion de tabla
Init_LCD_Loop   Movb 1,X+,CharLCD                 ; Pasar dato de IniDsp a CharLCD
                Ldaa CharLCD                      ; Cargar dato desde CharLCD
                Cmpa #$FF                         ; Llego a End of Block (EOB)?
                Bne Call_SendLCD_2
                Movb #Clear_Display,CharLCD       ; Cargar en CharLCD cmd Clear
Call_SendLCD_1  Jsr SendLCD                       ; Enviar cmd Clear
                BrClr Banderas_2,FinSendLCD,Call_SendLCD_1
                Bra FIN_Init_LCD
Call_SendLCD_2  Jsr SendLCD                       ; Si no, enviar dato
                BrClr Banderas_2,FinSendLCD,Call_SendLCD_2
                BClr Banderas_2,FinSendLCD        ; Apagar bandera FinSendLCD
                Bra Init_LCD_Loop                 ; Cargar siguiente dato
FIN_Init_LCD    Movb tTimer2mS,Timer2mS
Timer2mS_Reach0 Jsr Decre_TablaTimers             ; Decrementar timers
                Tst Timer2mS
                Bne Timer2mS_Reach0
                Rts

;===============================================================================
;                          DESPACHADOR DE TAREAS
;===============================================================================

Despachador_Tareas
                BrSet Banderas_2,LCD_OK,NoNewMsg
                Jsr Tarea_LCD
NoNewMsg        Jsr Decre_TablaTimers
                Jsr Tarea_Modo_Espera
                Jsr Tarea_Configurar
                Jsr Tarea_Correr
                Jsr Tarea_Resumen
                Jsr Tarea_Led_Testigo
                Jsr Tarea_PantallaMUX
                Jsr Tarea_LeerPB1
                Jsr Tarea_LeerPB2
                Jsr Tarea_Teclado
                Jsr Tarea_Brillo
                Bra Despachador_Tareas

;*******************************************************************************
;                                TAREA MODO ESPERA
;*******************************************************************************

Tarea_Modo_Espera
                Ldaa Funcion
                Cmpa #F1
                Bne FIN_Modo_Espera
                Movw #Msg_Modo_Espera_P1,Msg_L1
                Movw #Msg_Modo_Espera_P2,Msg_L2
                BClr Banderas_2,LCD_OK
                Movb #$BB,BCD1
                Movb #$BB,BCD2
                Jsr BCD_7Seg
                Movb #$01,LEDS
FIN_Modo_Espera Rts

;*******************************************************************************
;                              TAREA MODO CONFIGURAR
;*******************************************************************************

Tarea_Configurar:
                Ldaa Funcion
                Cmpa #F2
                Bne Rst_TConfig
                Movb #$02,LEDS
                Ldx EstPres_TConfig
                Jsr 0,X
                Bra FIN_TConfig
Rst_TConfig     Movw #TConfig_Est1,EstPres_TConfig
FIN_TConfig     Rts

;======================= TAREA MODO CONFIGURAR ESTADO 1 ========================

TConfig_Est1:
                Ldaa Funcion
                Movw #Msg_Modo_Config_P1,Msg_L1
                Movw #Msg_Modo_Config_P2,Msg_L2
                BClr Banderas_2,LCD_OK
                Ldaa NumVueltas
                Jsr BIN_BCD_MUXP
                Movb #$BB,BCD2
                Movb BCD,BCD1
                Jsr BCD_7Seg
                Jsr Borrar_Num_Array
                BClr Banderas_1,ArrayOK
                Movw #TConfig_Est2,EstPres_TConfig
FIN_TConfig_1   Rts

;======================= TAREA MODO CONFIGURAR ESTADO 2 ========================

TConfig_Est2:
                Ldaa Funcion
                BrClr Banderas_1,ArrayOK,FIN_TConfig_2
                Jsr BCD_BIN
                Ldaa ValorNumVueltas
                Cmpa #MinNumVueltas
                Bcs BorrarNumArr_TC
                Cmpa #MaxNumVueltas
                Bhi BorrarNumArr_TC
                Ldaa ValorNumVueltas
                Jsr BIN_BCD_MUXP
                Movb #$BB,BCD2
                Movb BCD,BCD1
                Jsr BCD_7Seg
                Movb ValorNumVueltas,NumVueltas
BorrarNumArr_TC Jsr Borrar_Num_Array
                Movw #TConfig_Est1,EstPres_TConfig
FIN_TConfig_2   Rts

;*******************************************************************************
;                                TAREA MODO CORRER
;*******************************************************************************

Tarea_Correr:
                Ldaa Funcion
                Cmpa #F3
                Bne Rst_TCorrer
                Ldx EstPres_TCorrer
                Jsr 0,X
                Bra FIN_TCorrer
Rst_TCorrer     Movw #TCorrer_Est1,EstPres_TCorrer
FIN_TCorrer     Rts

;========================= TAREA MODO CORRER ESTADO 1 ==========================

TCorrer_Est1:
                Movb #$04,LEDS                    ; Se activa led de modo correr
                Movw #Msg_Espera_Inicio_P1,Msg_L1 ; Se envia Mensaje Esperando
                Movw #Msg_Espera_Inicio_P2,Msg_L2 ; Inicio a la pantalla LCD
                BClr Banderas_2,LCD_OK            ; Se borra la bandera LCD_OK
                Movb #$BB,BCD2                    ; Apagar display de 7 seg
                Movb #$BB,BCD1
                Jsr BCD_7Seg
                Movw #TCorrer_Est2,EstPres_TCorrer
FIN_TCorrer_1   Rts

;========================= TAREA MODO CORRER ESTADO 2 ==========================

TCorrer_Est2:
                BrClr Banderas_1,LongP2,FIN_TCorrer_2 ; Se activó botón de inicio?
                Clr DeltaT                        ; Borrar variables relaciona-
                Clr Velocidad                     ; das con la subrutina
                Clr TimerIniPant                  ; Calcula
                Clr TimerFinPant
                BClr Banderas_1,ShortP2           ; Borrar bandera de Short Press
                Movw #TCorrer_Est3,EstPres_TCorrer
FIN_TCorrer_2   Rts

;========================= TAREA MODO CORRER ESTADO 3 ==========================

TCorrer_Est3:
                Movw #Msg_Espera_S1_P1,Msg_L1     ; Se envia Mensaje Esperando
                Movw #Msg_Espera_S1_P2,Msg_L2     ; S1 a la pantalla LCD
                BClr Banderas_2,LCD_OK            ; Se borra la bandera LCD_OK
                Movb #$BB,BCD2                    ; Apagar display de 7 seg
                Movb #$BB,BCD1
                Jsr BCD_7Seg
                Movw #TCorrer_Est4,EstPres_TCorrer
FIN_TCorrer_3   Rts

;========================= TAREA MODO CORRER ESTADO 4 ==========================

TCorrer_Est4:
                BrClr Banderas_1,ShortP1,FIN_TCorrer_4 ; Se activó S1 (PH3)?
                Movb #tTimerCal,TimerCal          ; Cargar timer de calculo
                BClr Banderas_1,ShortP1           ; Borrar bandera de Short Press
                Movw #Msg_Espera_S2_P1,Msg_L1     ; Se envia Mensaje Esperando
                Movw #Msg_Espera_S2_P2,Msg_L2     ; S2 a la pantalla LCD
                BClr Banderas_2,LCD_OK            ; Se borra la bandera LCD_OK
                Movw #TCorrer_Est5,EstPres_TCorrer
FIN_TCorrer_4   Rts

;========================= TAREA MODO CORRER ESTADO 5 ==========================

TCorrer_Est5:
                BrClr Banderas_1,ShortP2,Bra_To_Fin ; Se activó S2 (PH0)?
                ;BClr Banderas_1,ShortP2
                Jsr Calcula
                Ldaa Velocidad
                Cmpa #VMin
                Blo Fuera_Rango
                Cmpa #VMax
                Bhi Fuera_Rango
                Movw #Msg_TimerPant_P1,Msg_L1
                Movw #Msg_TimerPant_P2,Msg_L2
                BClr Banderas_2,LCD_OK
                Ldaa TimerIniPant
                Jsr BIN_BCD_MUXP
                Movb BCD,BCD2
                Ldaa TimerFinPant
                Jsr BIN_BCD_MUXP
                Movb BCD,BCD1
                Jsr BCD_7Seg
                Movw #TCorrer_Est6,EstPres_TCorrer
Bra_To_Fin      Bra FIN_TCorrer_5
Fuera_Rango     Movw #Msg_Alerta_Vel_P1,Msg_L1
                Movw #Msg_Alerta_Vel_P2,Msg_L2
                BClr Banderas_2,LCD_OK
                Ldaa Velocidad
                Cmpa #99
                Bhi Poner_Guion
                Ldaa Velocidad
                Jsr BIN_BCD_MUXP
                Movb BCD,BCD2
                Movb #$BB,BCD1
                Bra Mensaje_Borrar
Poner_Guion     Movb #$AA,BCD2
                Movb #$AA,BCD1
Mensaje_Borrar  Jsr BCD_7Seg
                Movw Msg_Vacio,Msg_L1
                Movw Msg_Vacio,Msg_L2
                BClr Banderas_2,LCD_OK
                Movb #tTimerError,TimerError
                Movw #TCorrer_Est7,EstPres_TCorrer
FIN_TCorrer_5   Rts

;========================= TAREA MODO CORRER ESTADO 6 ==========================

TCorrer_Est6:
                Tst TimerIniPant
                Bne FIN_TCorrer_6
                Inc Vueltas
                Ldd AcumVelocidad
                Addb Velocidad
                Adca #0
                Std AcumVelocidad
                Ldaa Velocidad
                Jsr BIN_BCD_MUXP
                Movb BCD,BCD2
                Movb Vueltas,BCD1
                Jsr BCD_7Seg
                Movw #Msg_Resultados_P1,Msg_L1
                Movw #Msg_Resultados_P2,Msg_L2
                BClr Banderas_2,LCD_OK
                Movw #TCorrer_Est8,EstPres_TCorrer
FIN_TCorrer_6   Rts

;========================= TAREA MODO CORRER ESTADO 7 ==========================

TCorrer_Est7:
                Tst TimerError
                Bne FIN_TCorrer_7
                Movw #TCorrer_Est3,EstPres_TCorrer
FIN_TCorrer_7   Rts

;========================= TAREA MODO CORRER ESTADO 8 ==========================

TCorrer_Est8:
               Tst TimerFinPant
               Bne FIN_TCorrer_8
               Ldaa Vueltas
               Bne PasarA_TC_3
               BClr Banderas_1,LongP2
               Movw #Msg_Fin_Ciclo_P1,Msg_L1
               Movw #Msg_Fin_Ciclo_P2,Msg_L2
               BClr Banderas_2,LCD_OK
               Movw #TCorrer_Est2,EstPres_TCorrer
               Bra FIN_TCorrer_8
PasarA_TC_3    Movw #TCorrer_Est3,EstPres_TCorrer
FIN_TCorrer_8  Rts

;*******************************************************************************
;                               TAREA MODO RESUMEN
;*******************************************************************************

Tarea_Resumen:
               Ldaa Funcion
               Cmpa #F4
               Bne FIN_Resumen
               Movb #$08,LEDS
               Tst Vueltas
               Beq Entrada_Es_0
               Ldaa Vueltas
               Tfr A,X
               Ldd AcumVelocidad
               Idiv
               Tfr X,A
Call_BIN_BCD   Jsr BIN_BCD_MUXP
               Movb BCD,BCD1
               Ldaa Vueltas
               Jsr BIN_BCD_MUXP
               Movb BCD,BCD2
               Jsr BCD_7Seg
               Movw #Msg_Resumen_P1,Msg_L1
               Movw #Msg_Resumen_P2,Msg_L2
               BClr Banderas_2,LCD_OK
               Bra FIN_Resumen
Entrada_Es_0   Ldaa #$00
               Bra Call_BIN_BCD
FIN_Resumen    Rts

;*******************************************************************************
;                                  TAREA BRILLO
;*******************************************************************************

Tarea_Brillo:
                Ldx EstPres_TBrillo
                Jsr 0,X
                Rts

;============================ TAREA BRILLO ESTADO 1 ============================

TareaBrillo_Est1:
                Movb #tTimerBrillo,TimerBrillo    ; Inicializar timer
                Movw #TareaBrillo_Est2,EstPres_TBrillo
FIN_TBrillo_1   Rts

;============================ TAREA BRILLO ESTADO 2 ============================

TareaBrillo_Est2:
                Tst TimerBrillo                   ; Cuando se acaba el timer
                Bne FIN_TBrillo_2                 ; iniciar un ciclo de conver-
                Movb #$87,ATD0CTL5                ; sion
                Movw #TareaBrillo_Est3,EstPres_TBrillo
FIN_TBrillo_2   Rts

;============================ TAREA BRILLO ESTADO 3 ============================

TareaBrillo_Est3:
                BrClr ATD0STAT0,$80,FIN_TBrillo_3
                Ldd ADR00H                        ; Obtener suma de 4 mediciones
                Addd ADR01H
                Addd ADR02H
                Addd ADR03H
                Lsrd                              ; Dividir entre 4 para obtener
                Lsrd                              ; el promedio
                Ldy #100                          ; Normalizar
                Emul                              ; Brillo = (Promedio)*100/255
                Ldx #255
                Idiv
                Tfr X,A
                Cmpa #100                         ; Si es 100, escribir Brillo
                Bne EscribirBrillo                ; como 99 para evitar que solo
                Movb #99,Brillo                   ; quede encendido 1 dgito
                Bra Brillo_Est1
EscribirBrillo  Staa Brillo                       ; Si es menor a 100, escribir
Brillo_Est1     Movw #TareaBrillo_Est1,EstPres_TBrillo ; ese valor a Brillo
FIN_TBrillo_3   Rts

;*******************************************************************************
;                               SUBRUTINA CALCULA
;*******************************************************************************

Calcula:
                Ldd #tTimerCal                    ; tTimerCal=100
                Subb TimerCal                     ; tTimerCal-(tTimerCal)
                Ldx #10                           ; Pasar a cantidad de ticks
                Idiv
                Tfr X,A                           ; Mover parte baja a A
                Staa DeltaT
                Ldaa #DeltaS                      ; DeltaS=50 mts
                Ldab #36
                Mul                               ; (DeltaS)*36
                Pshd
                Ldaa DeltaT                       ; Paso DeltaT calculado a X
                Tfr A,X
                Puld
                Idiv                              ; (DeltaS)*36/DeltaT
                Tfr X,D
                Ldx #10
                Idiv                              ; (DeltaS)*36/(DeltaT*10)
                Tfr X,A
                Staa Velocidad                    ; Velocidad=(DeltaS)*36/(DeltaT*10)
                Ldaa #DeltaM                      ; DeltaM = 150 mts
                Ldab #100
                Mul                               ; (DeltaM)*100
                Pshd
                Ldaa Velocidad
                Tfr A,X
                Puld
                Idiv                              ; (DeltaM)*100/(Velocidad)
                Tfr X,D
                Ldx #36
                Idiv                              ; (DeltaP)*100/((Velocidad)*36)
                Tfr X,A
                Staa TimerIniPant                 ; TimerIniPant = lo de arriba
                Ldaa #DeltaP                      ; DeltaP = 250 mts
                Ldab #100
                Mul                               ; (DeltaP)*100
                Pshd
                Ldaa Velocidad
                Tfr A,X
                Puld
                Idiv                              ; (DeltaP)*100/(Velocidad)
                Tfr X,D
                Ldx #36
                Idiv                              ; (DeltaP)*100/((Velocidad)*36)
                Tfr X,A
                Staa TimerFinPant                 ; TimerFinPant = lo de arriba
                Rts


;*******************************************************************************
;                               SUBRUTINA BCD_BIN
;*******************************************************************************

BCD_BIN:
                Ldaa Num_Array
                Ldab #10
                Mul
                Ldx #Num_Array
                Ldaa 1,X
                Aba
                Staa ValorNumVueltas
                Rts

;=============================== BCD 7 SEGMENTOS ===============================
;
; Descripcion: Esta subrutina toma los valores de BCD1 y BCD2, y busca en la
; tabla de patrones de segmentos el segmento correspondiente al digito de cada
; nibble. Luego, guarda los resultados en las variables Dsp1, Dsp2, Dsp3 y Dsp4
; de la siguiente forma:
;
;       BCD2 -> Dsp1:Dsp2
;       BCD1 -> Dsp3:Dsp4

BCD_7Seg:
                Ldx #Segment
                Ldaa BCD2
                Anda #$F0                         ; Obtener nibble alto de BCD2
                Lsra                              ; y desplazar a la parte baja
                Lsra
                Lsra
                Lsra
                Ldab A,X                          ; Cargar patron de segmento
                Stab DSP1                         ; Guardar en DISP1
                Ldaa BCD2
                Anda #$0F                         ; Obtener nibble bajo de BCD2
                Ldab A,X                          ; Cargar patron de segmento
                Stab DSP2                         ; Guardar en DISP2
                Ldaa BCD1
                Anda #$F0                         ; Obtener nibble alto de BCD1
                Lsra                              ; y desplazar a la parte baja
                Lsra
                Lsra
                Lsra
                Ldab A,X                          ; Cargar patron de segmento
                Stab DSP3                         ; Guardar en DISP3
                Ldaa BCD1
                Anda #$0F                         ; Obtener nibble bajo de g 2
                Ldab A,X                          ; Cargar patron de segmento
                Stab DSP4                         ; Guardar en DISP4
FIN_BCD7_Seg    Rts

;================================= BIN BCD MUXP ================================

BIN_BCD_MUXP
                Movb #7,Cont_BCD
                Clr BCD
BIN_BCD_Loop    Lsla                              ; Pasar bits a BCD por medio
                Rol BCD                           ; del carry
                Psha                              ; Guardar entrada en la pila
                Ldab BCD
                Andb #$0F                         ; Obtener nibble bajo de BCD
                Cmpb #$05
                Bcs Nibble_Alto
                Addb #$03
Nibble_Alto     Pshb                              ; Guardar nibble bajo actuali-
                Ldab BCD                          ; zado en la pila
                Andb #$F0
                Cmpb #$50
                Bcs Dec_Cont_BCD
                Addb #$30
Dec_Cont_BCD    Pula                              ; Cargar nibble bajo
                Aba                               ; Sumar nibble bajo y alto
                Staa BCD                          ; Actualizar valor en BCD
                Pula                              ; Recargar valor de entrada
                Dec Cont_BCD                      ; Decrementar #de desplazamiento
                Tst Cont_BCD                      ; Verificar si llego a cero,
                Bne BIN_BCD_Loop                  ; Si no, continuar loop
                Lsla                              ; Desplazar x ultima vez a la
                Rol BCD                           ; izquierda
FIN_BIN_BCD     Rts

;******************************************************************************
;                               TAREA LED TESTIGO
;******************************************************************************

Tarea_Led_Testigo
                Ldx EstPres_LDTst
                Jsr 0,X
FinLedTest      Rts

;========================= TAREA LED TESTIGO ESTADO 1 ==========================

TareaLDTst_Est1
                Tst TimerLDTst                    ; Si el timer no se ha acabado
                Bne FIN_LDTst_1                   ; se mantiene en este estado
                BSet PTP,LD_Red                   ; Encender color rojo y apagar
                BClr PTP,LD_Green                 ; el resto
                BClr PTP,LD_Blue
                Movw #TareaLDTst_Est2,EstPres_LDTst
                Movb #tTimerLDTst,TimerLDTst
FIN_LDTst_1     Rts

;========================= TAREA LED TESTIGO ESTADO 2 ==========================

TareaLDTst_Est2
                Tst TimerLDTst                    ; Si el timer no se ha acabado
                Bne FIN_LDTst_2                   ; se mantiene en este estado
                BClr PTP,LD_Red                   ; Encender color verde y apagar
                BSet PTP,LD_Green                 ; el resto
                BClr PTP,LD_Blue
                Movw #TareaLDTst_Est3,EstPres_LDTst
                Movb #tTimerLDTst,TimerLDTst
FIN_LDTst_2     Rts

;========================= TAREA LED TESTIGO ESTADO 3 ==========================

TareaLDTst_Est3
                Tst TimerLDTst                    ; Si el timer no se ha acabado
                Bne FIN_LDTst_3                   ; se mantiene en este estado
                BClr PTP,LD_Red                   ; Encender color azul y apagar
                BClr PTP,LD_Green                 ; el resto
                BSet PTP,LD_Blue
                Movw #TareaLDTst_Est1,EstPres_LDTst
                Movb #tTimerLDTst,TimerLDTst
FIN_LDTst_3     Rts

;******************************************************************************
;                               TAREA LEER PB1
;******************************************************************************

Tarea_LeerPB1:
                Ldx EstPres_LeerPB1
                Jsr 0,X
FinTareaPB1     Rts

;============================= LEER PB1 ESTADO 1 ===============================

LeerPB1_Est1
                BrSet PortPB,MaskPB1,FIN_Est1      ; Si el boton es presionado
No_FIN_Est1     Movb #tSupRebPB1,Timer_RebPB1       ; Cargar timers
                Movb #tShortP1,Timer_SHP1
                Movb #tLongP1,Timer_LP1
                Movw #LeerPB1_Est2,EstPres_LeerPB1 ; Continuar a estado 2
FIN_Est1        Rts

;============================= LEER PB1 ESTADO 2 ===============================

LeerPB1_Est2
                Tst Timer_RebPB1                   ; Si se agota el timer
                Bne FIN_Est2                      ; verificar si aun sigue pre-
                BrSet PortPB,MaskPB1,Ret_Est1_1    ; sionado el boton
                Movw #LeerPB1_Est3,EstPres_LeerPB1
                Bra FIN_Est2
Ret_Est1_1      Movw #LeerPB1_Est1,EstPres_LeerPB1 ; Sino regresar a estado 1
FIN_Est2        Rts

;============================= LEER PB1 ESTADO 3 ===============================

LeerPB1_Est3
                Tst Timer_SHP1                     ; Verificar si el timer short
                Bne FIN_Est3                      ; press se agoto
                BrSet PortPB,MaskPB1,Ret_Est1_2    ; Si se presiona el boton
                Movw #LeerPB1_Est4,EstPres_LeerPB1 ; Sino, pasar a estado 4
                Bra FIN_Est3
Ret_Est1_2      BSet Banderas_1,ShortP1              ; Levantar bandera ShortP y
                Movw #LeerPB1_Est1,EstPres_LeerPB1 ; regresar a estado 1
FIN_Est3        Rts

;============================= LEER PB1 ESTADO 4 ===============================

LeerPB1_Est4
                Tst Timer_LP1                      ; Si no se agota el timer long
                Bne TestPB1                        ; press, y se presiona el boton
                BrClr PortPB,MaskPB1,FIN_Est4      ; es un short press
                BSet Banderas_1,LongP1
Ret_Est1_3      Movw #LeerPB1_Est1,EstPres_LeerPB1 ; sino es un long press
                Bra FIN_Est4
TestPB1         BrClr PortPB,MaskPB1,FIN_Est4
                BSet Banderas_1,ShortP1
                Bra Ret_Est1_3
FIN_Est4        Rts

;******************************************************************************
;                               TAREA LEER PB2
;******************************************************************************

Tarea_LeerPB2:
                Ldx EstPres_LeerPB2
                Jsr 0,X
FinTareaPB2     Rts

;============================= LEER PB2 ESTADO 1 ===============================

LeerPB2_Est1
                BrSet PortPB,MaskPB2,FIN_Est1_2    ; Si el boton es presionado
No_FIN_Est1_2   Movb #tSupRebPB2,Timer_RebPB2      ; Cargar timers
                Movb #tShortP2,Timer_SHP2
                Movb #tLongP2,Timer_LP2
                Movw #LeerPB2_Est2,EstPres_LeerPB2 ; Continuar a estado 2
FIN_Est1_2      Rts

;============================= LEER PB2 ESTADO 2 ===============================

LeerPB2_Est2
                Tst Timer_RebPB2                   ; Si se agota el timer
                Bne FIN_Est2_2                     ; verificar si aun sigue pre-
                BrSet PortPB,MaskPB2,Ret_Est1_1_2  ; sionado el boton
                Movw #LeerPB2_Est3,EstPres_LeerPB2
                Bra FIN_Est2_2
Ret_Est1_1_2    Movw #LeerPB2_Est1,EstPres_LeerPB2 ; Sino regresar a estado 1
FIN_Est2_2      Rts

;============================= LEER PB2 ESTADO 3 ===============================

LeerPB2_Est3
                Tst Timer_SHP2                     ; Verificar si el timer short
                Bne FIN_Est3_2                     ; press se agoto
                BrSet PortPB,MaskPB2,Ret_Est1_2_2  ; Si se presiona el boton
                Movw #LeerPB2_Est4,EstPres_LeerPB2 ; Sino, pasar a estado 4
                Bra FIN_Est3_2
Ret_Est1_2_2    BSet Banderas_1,ShortP2            ; Levantar bandera ShortP y
                Movw #LeerPB2_Est1,EstPres_LeerPB2 ; regresar a estado 1
FIN_Est3_2      Rts

;============================= LEER PB2 ESTADO 4 ===============================

LeerPB2_Est4
                Tst Timer_LP2                      ; Si no se agota el timer long
                Bne TestPB2                        ; press, y se presiona el boton
                BrClr PortPB,MaskPB2,FIN_Est4_2    ; es un short press
                BSet Banderas_1,LongP2
Ret_Est1_3_2    Movw #LeerPB2_Est1,EstPres_LeerPB2 ; sino es un long press
                Bra FIN_Est4
TestPB2         BrClr PortPB,MaskPB2,FIN_Est4_2
                BSet Banderas_1,ShortP2
                Bra Ret_Est1_3_2
FIN_Est4_2      Rts

;*******************************************************************************
;                             TAREA PANTALLA MUX
;*******************************************************************************

Tarea_PantallaMUX
                Ldx EstPres_PantallaMUX
                Jsr 0,X
                Rts

;=========================== PANTALLA MUX ESTADO 1 =============================

PantallaMUX_Est1:
                Tst Timer_Digito
                Bne FIN_PantMUX_1
                Movb #tTimerDigito,Timer_Digito
                Ldaa Cont_Dig
                Cmpa #$01
                Bne GoTo_Disp2
                BClr PTP,DIG1
                Movb DSP1,PORTB
                Bra Inc_Cont_Dig
GoTo_Disp2      Cmpa #$02
                Bne GoTo_Disp3
                BClr PTP,DIG2
                Movb DSP2,PORTB
                Bra Inc_Cont_Dig
GoTo_Disp3      Cmpa #$03
                Bne GoTo_Disp4
                BClr PTP,DIG3
                Movb DSP3,PORTB
                Bra Inc_Cont_Dig
GoTo_Disp4      Cmpa #$04
                Bne GoTo_Leds
                BClr PTP,DIG4
                Movb DSP4,PORTB
                Bra Inc_Cont_Dig
GoTo_Leds       BClr PTJ,$02
                Ldaa LEDS
                Movb LEDS,PORTB
                Movb #$01,Cont_Dig
                Bra Inc_Ticks
Inc_Cont_Dig    Inc Cont_Dig
Inc_Ticks       Movw #MaxCountTicks,CounterTicks
                Movw #PantallaMUX_Est2,EstPres_PantallaMUX
FIN_PantMUX_1   Rts

;=========================== PANTALLA MUX ESTADO 2 =============================

PantallaMUX_Est2:
                Ldaa #MaxCountTicks
                Suba Brillo
                Sex A,D
                Cpd CounterTicks
                Bls FIN_PantMUX_2
                BSet PTP,$0F
                BSet PTJ,$02
                Movw #PantallaMUX_Est1,EstPres_PantallaMUX
FIN_PantMUX_2   Rts

;******************************************************************************
;                                  SEND LCD
;******************************************************************************

SendLCD:
                Ldy EstPres_SendLCD
                Jsr 0,Y
                Rts

;============================= SEND LCD ESTADO 1 ===============================

TareaSendLCD_Est1:
                Ldaa CharLCD                      ; Cargar caracter a enviar
                Anda #$F0                         ; Filtrar la parte alta
                Lsra                              ; Guardar en los bits 5:2 del
                Lsra                              ; puerto K
                Staa PORTK
                BrSet Banderas_2,RS,Set_RS        ; Si es un comando, borrar
                BClr PORTK,RS                     ; PORTK.0
                Bra Enable_LCD
Set_RS          BSet PORTK,RS                     ; Si es dato, levantar PORTK.0
Enable_LCD      BSet PORTK,$02                    ; Habilitar LCD
                Movw #tTimer260uS,Timer260uS
                Movw #TareaSendLCD_Est2,EstPres_SendLCD
FIN_SendLCD_1   Rts

;============================= SEND LCD ESTADO 2 ===============================

TareaSendLCD_Est2:
                Ldd Timer260uS                    ; Mientras no se acabe el timer
                Bne FIN_SendLCD_2                 ; se mantiene en este estado
                BClr PORTK,$02                    ; Deshabilita LCD
                Ldaa CharLCD                      ; Carga caracter a enviar
                Anda #$0F                         ; Filtra solo la parte baja
                Lsla                              ; Guarda en los bits 5:2 del
                Lsla                              ; puerto K
                Staa PORTK
                BrSet Banderas_2,RS,Set_RS_2      ; Si es un comando, borrar
                BClr PORTK,RS                     ; PORTK.0
                Bra Load_Timer
Set_RS_2        BSet PORTK,RS                     ; Si es dato, levantar PORTK.0
Load_Timer      BSet PORTK,$02                    ; Habilitar LCD
                Movw #tTimer260uS,Timer260uS
                Movw #TareaSendLCD_Est3,EstPres_SendLCD
FIN_SendLCD_2   Rts

;============================= SEND LCD ESTADO 3 ===============================

TareaSendLCD_Est3:
                Ldd Timer260uS                    ; Mientras no se acabe el timer
                Bne FIN_SendLCD_3                 ; se mantiene en este estado
                BClr PORTK,$02                    ; Deshabilitar LCD
                Movw #tTimer40uS,Timer40uS
                Movw #TareaSendLCD_Est4,EstPres_SendLCD
FIN_SendLCD_3   Rts

;============================= SEND LCD ESTADO 4 ===============================

TareaSendLCD_Est4:
                Ldd Timer40uS                     ; Mientras no se acabe el timer
                Bne FIN_SendLCD_4                 ; se mantiene en este estado
                BSet Banderas_2,FinSendLCD        ; Activa bandera FinSendLCD
                Movw #TareaSendLCD_Est1,EstPres_SendLCD
FIN_SendLCD_4   Rts

;******************************************************************************
;                                  TAREA LCD
;******************************************************************************

Tarea_LCD:
                Ldx EstPres_TareaLCD
                Jsr 0,X
                Rts

;============================= TAREA LCD ESTADO 1 ===============================

TareaLCD_Est1:
                BClr Banderas_2,FinSendLCD        ; Borrar banderas FinSendLCD
                BClr Banderas_2,RS                ; y RS
                BrSet Banderas_2,Second_Line,Line_2
                Movb #ADD_L1,CharLCD              ;
                Movw Msg_L1,Punt_LCD
                Bra FIN_TareaLCD_1
Line_2          Movb #ADD_L2,CharLCD
                Movw Msg_L2,Punt_LCD
FIN_TareaLCD_1  Jsr SendLCD
                Movw #TareaLCD_Est2,EstPres_TareaLCD
                Rts

;============================= TAREA LCD ESTADO 2 ===============================

TareaLCD_Est2
                BrClr Banderas_2,FinSendLCD,Call_SendLCD_4
                BClr Banderas_2,FinSendLCD
                BSet Banderas_2,RS
                Ldx Punt_LCD
                Movb 1,X+,CharLCD
                Stx Punt_LCD
                Ldaa CharLCD
                Cmpa #$FF
                Bne Call_SendLCD_4
                BrSet Banderas_2,Second_Line,SwitchLine
                BSet Banderas_2,Second_Line
                Bra SigEst_LCD
SwitchLine      BClr Banderas_2,Second_Line
                BSet Banderas_2,LCD_OK
SigEst_LCD      Movw #TareaLCD_Est1,EstPres_TareaLCD
                Bra FIN_TareaLCD_2
Call_SendLCD_4  Jsr SendLCD
FIN_TareaLCD_2  Rts

;******************************************************************************
;                               TAREA TECLADO
;******************************************************************************

Tarea_Teclado   Ldx EstPres_TCL
                Jsr 0,X
                Rts

;============================= TECLADO ESTADO 1 ================================

Teclado_Est1    Jsr Leer_Teclado                  ; Si se presiona alguna tecla
                Ldaa Tecla
                Cmpa #$FF
                Beq FIN_Tecl_Est1
                Movb #tSupRebTCL,Timer_RebTCL     ; carga timer de supresion de
                Movw #Teclado_Est2,EstPres_TCL   ; rebotes y siguiente estado
FIN_Tecl_Est1   Rts

;============================= TECLADO ESTADO 2 ================================

Teclado_Est2    Tst Timer_RebTCL                  ; Si no se agota el timer,
                Bne FIN_Tecl_Est2                 ; verifica si Tecla = Tecla_IN
                Movb Tecla,Tecla_IN
                Jsr Leer_Teclado
                Ldaa Tecla_IN
                Cmpa Tecla
                Bne Regr_Tecl_Est1
                Movw #Teclado_Est3,EstPres_TCL   ; Si son iguales pasa a est 3
                Bra FIN_Tecl_Est2
Regr_Tecl_Est1  Movw #Teclado_Est1,EstPres_TCL   ; Sino se devuelve al 1
FIN_Tecl_Est2   Rts
;============================= TECLADO ESTADO 3 ================================

Teclado_Est3    Jsr Leer_Teclado
                Ldaa Tecla
                Cmpa #$FF
                Bne FIN_Tecl_Est3
                Ldaa Tecla_IN                     ; Si la tecla ingresada es de
                Cmpa #15                          ; funcion, la guarda se
                Bhi Guardar_Funcion
                Movw #Teclado_Est4,EstPres_TCL   ; devuelve al estado 1
                Bra FIN_Tecl_Est3
Guardar_Funcion Movb Tecla_IN,Funcion             ; sino pasa al estado 4
                Movw #Teclado_Est1,EstPres_TCL
FIN_Tecl_Est3   Rts

;============================= TECLADO ESTADO 4 ================================

Teclado_Est4    Ldaa Tecla_IN
                Ldab Cont_TCL
                Ldx #Num_Array
                Cmpb Max_TCL                    ; Si alcanzo el maximo de cifras
                Beq Es_Borrar
                Tstb                            ; Es la primera tecla?
                Beq Primera_Tecla
                Cmpa #$0B                       ; Es la tecla Borrar ($0B)?
                Bne Es_Enter2
                Tst Cont_TCL                    ; El offset llego a 0?
                Bne Borrar_Tecl
                Bra FIN_Tecl_Est4
Es_Borrar       Cmpa #$0B                       ; Es la tecla Borrar ($0B)?
                Bne Es_Enter
Borrar_Tecl     Dec Cont_TCL                    ; Borrar la tecla de Num_Array
                Ldab Cont_TCL
                Movb #$FF,B,X
                Bra FIN_Tecl_Est4
Es_Enter        Cmpa #$0E                       ; Es la tecla Enter ($0E)?
                Bne FIN_Tecl_Est4
Fin_Num_Arr     Movb #0,Cont_TCL                ; Resetear offset
                Movw #Teclado_Est1,EstPres_TCL
                BSet Banderas_1,ArrayOK         ; Indicar que Num_Array esta listo
                Bra FIN_Tecl_Est4
Primera_Tecla   Cmpa #$0B                       ; Es la tecla Borrar ($0B)?
                Beq FIN_Tecl_Est4
                Cmpa #$0E                       ; Es la tecla Enter ($0E)?
                Beq FIN_Tecl_Est4
                Bra Agregar_Tecl
Es_Enter2       Cmpa #$0E
                Beq Fin_Num_Arr
Agregar_Tecl    Movb Tecla_IN,B,X               ; Guardar la tecla ingresada
                Inc Cont_TCL                    ; en Num_Array
FIN_Tecl_Est4   Movb #$FF,Tecla_IN              ; Limpiar valor Tecla_IN
                Movw #Teclado_Est1,EstPres_TCL ; Regresar a estado 1
                Rts

;******************************************************************************
;                          SUBRUTINA LEER TECLADO
;******************************************************************************

Leer_Teclado    Clra
                Movb #$EF,Patron                ; Patron 11101111 para puerto A
                Ldx #Teclas                     ; Direccion de tabla Teclas
Cont_Lectura    Movb Patron,PORTA               ; Escribir Patron en puerto A
                BrClr PORTA,$01,Obt_Tecla       ; Si el bit 0 de PORTA es 0,
                Inca                            ; el btn esta en la 1er columna
                BrClr PORTA,$02,Obt_Tecla       ; Si el bit 1 de PORTA es 0,
                Inca                            ; el btn esta en la 2da columna
                BrClr PORTA,$04,Obt_Tecla       ; Si el bit 2 de PORTA es 0,
                Inca                            ; el btn esta en la 2da columna
                BrClr PORTA,$08,Escribir_Patron
                Ldab Patron
                Cmpb #$78                       ; Si Patron llega a 01111000,
                Beq Clr_Tecla                   ; no se presiono ninguna tecla
                Lsl Patron                      ; Desplazar a la izquierda
                Bra Cont_Lectura
Clr_Tecla       Movb #$FF,Tecla                 ; Limpiar valor de Tecla
                Bra FIN_Leer_Tecl
Obt_Tecla       Movb A,X,Tecla                  ; Cargar valor de Tecla de tabla
                Bra FIN_Leer_Tecl
Borrar_Tecl_2   Movb #$FF,Tecla                 ; Limpiar valor de Tecla
                Bra FIN_Leer_Tecl
Escribir_Patron BSet Patron,$0F                 ; Patron.3:Patron.0 = $F
                Movb Patron,Tecla               ; Pasar Patron a Tecla
FIN_Leer_Tecl   Rts

;******************************************************************************
;                        SUBRUTINA BORRAR NUM ARRAY
;******************************************************************************

Borrar_Num_Array
                Ldx #Num_Array
                Clra
Ciclo_BNA       Movb #$FF,1,X+                  ; Limpiar posicion de memoria
                Inca                            ; actual en Num_Array con $FF
                Cmpa MAX_TCL                    ; Si llega al maximo de elementos
                Bne Ciclo_BNA                   ; salir
                Rts

;******************************************************************************
;                       SUBRUTINA DECRE_TABLATIMERS
;******************************************************************************

Decre_TablaTimers:
                Ldd Timer1mS
                Bne Timer_10mS
                Movw #tTimer1mS,Timer1mS
                Ldx #Tabla_Timers_Base1mS
                Jsr Decre_Timers
Timer_10mS      Ldd Timer10mS
                Bne Timer_100mS
                Movw #tTimer10mS,Timer10mS
                Ldx #Tabla_Timers_Base10mS
                Jsr Decre_Timers
Timer_100mS     Ldd Timer100mS
                Bne Timer_1S
                Movw #tTimer100mS,Timer100mS
                Ldx #Tabla_Timers_Base100mS
                Jsr Decre_Timers
Timer_1S        Ldd Timer1S
                Bne Rt_Decre_Timers
                Movw #tTimer1S,Timer1S
                Ldx #Tabla_Timers_Base1S
                Jsr Decre_Timers
Rt_Decre_Table  Rts

Decre_Timers:
                Ldaa 0,X
                Beq Inc_X_Index
                Cmpa #$FF
                Beq Rt_Decre_Timers
                Dec 0,X
Inc_X_Index     Inx
                Bra Decre_Timers
Rt_Decre_Timers Rts

;******************************************************************************
;                       SUBRUTINA DE ATENCION A RTI
;******************************************************************************

Maquina_Tiempos:
               Ldx #Tabla_Timers_BaseT
               Jsr Decre_Timers_BaseT
               BSet MCFLG,$80
               Rti

Decre_Timers_BaseT:
               Ldy 2,X+
               Cpy #0
               Beq Decre_Timers_BaseT
               Cpy #$FFFF
               Beq Rt_Decre_BaseT
               Dey
               Sty -2,X
               Bra Decre_Timers_BaseT
Rt_Decre_BaseT Rts