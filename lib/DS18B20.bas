'****************************************************************
'*  Name    : DS18B20.bas                                       *
'*  Author  : Ismael Valentin                                   *
'*  Date    : 15/11/2022                                        *
'*  Version : 1.0                                               *
'**************************************************************** 
'            
' CIRCUITO                                      
' ----------------------
' PULL UP R 4.7k
'          GND--------
'         /
'---------
'---------DT---++-----               
'---------     || RESISTOR 4.7 k
'         \
'          5v--++-----
'                                    
'        
' COMO USAR                                                 
' ----------------------
' PORTAS PADRAO D0 D1 D2
'
' >_ NO CABECALHO IMPORTE A BIBLIOTECA  
'
' Include "lib/DS18B20.bas"                 ; incluir a biblioteca
'
' >_ PARA EFETUAR A LEITURA CHAME A FUNCAO
' 
' lib_ds18b20(0)                            ; le o sensor na porta D0
' ou 
' lib_ds18b20(1)                            ; le o sensor na porta D1          
' ou 
' lib_ds18b20(2)                            ; le o sensor na porta D2
'           
' DS18B20_value         (Byte)              ; retorna o valor inteiro da 
'                                           ; temperatura           
' DS18B20_dec           (Word)              ; retorna o valor decimal
' DS18B20_get_signal    (Byte)              ; retorna o sinal + ou - 
'
' Print At 1, 1, "TEMP1: ", Dec DS18B20_value, ".", Dec DS18B20_dec         
'
'****************************************************************

Dim DS18B20_Temp As Word            ; Holds the temperature value
Dim DS18B20_C As Byte               ; Holds the counts remaining value
Dim DS18B20_CPerD As Byte           ; Holds the Counts per degree C value

Dim decimal1 As Word
Dim DS18B20_dec As Word   
Dim DS18B20_converter  As Word
Dim DS18B20_value  As Word   
                              
Symbol DS18B20_DQ0 = PORTD.0     
Symbol DS18B20_DQ1 = PORTD.1 
        
Proc lib_ds18b20(ByRef _port As Byte)

    DS18B20_Temp = 0

    '**************************************************************** 
    ' CONFIGURACAO
    '**************************************************************** 
    If _port == 0 Then
        OWrite DS18B20_DQ0, 1, [$CC, $44]                                   ' Send Calculate Temperature command         
        Repeat 
            DelayMS 25                                                      ' Wait until conversion is complete 
            ORead DS18B20_DQ0, 4, [DS18B20_C]                               ' Keep reading low pulses until
        Until DS18B20_C <> 0                                                ' the DS1820 is finished.        
        OWrite DS18B20_DQ0, 1, [$CC, $BE]                                   ' Send Read ScratchPad command
        ORead DS18B20_DQ0, 2,[DS18B20_Temp.LowByte, DS18B20_Temp.HighByte, DS18B20_C, DS18B20_C, DS18B20_C, DS18B20_C, DS18B20_C, DS18B20_CPerD]
        
    ElseIf _port == 1 Then         
        OWrite DS18B20_DQ1, 1, [$CC, $44]                                   ' Send Calculate Temperature command        
        Repeat 
            DelayMS 25                                                      ' Wait until conversion is complete 
            ORead DS18B20_DQ1, 4, [DS18B20_C]                               ' Keep reading low pulses until
        Until DS18B20_C <> 0                                                ' the DS1820 is finished.        
        OWrite DS18B20_DQ1, 1, [$CC, $BE]                                   ' Send Read ScratchPad command
        ORead DS18B20_DQ1, 2,[DS18B20_Temp.LowByte, DS18B20_Temp.HighByte, DS18B20_C, DS18B20_C, DS18B20_C, DS18B20_C, DS18B20_C, DS18B20_CPerD]
             
    EndIf            
    
    '****************************************************************
            
    If DS18B20_Temp .13 = 1 Then                                            'Se a temperatura for negativa
        DS18B20_Temp = ~ DS18B20_Temp                                       'Inverta bits nas informações de entrada, 1-> 0, 0-> 1
        DS18B20_Temp = DS18B20_Temp +1                                      'Aumentar as informações em 1 .
    EndIf
    
    DS18B20_converter = DS18B20_Temp * 625                                  'Como usamos a precisão de 12 bits, cada valor corresponde a 0,0625 graus Celsius .
    DS18B20_value = Div32 10000
                                     
    DS18B20_converter = DS18B20_Temp * 625
    DS18B20_dec = Div32 100      
                 
EndProc

