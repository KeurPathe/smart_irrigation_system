
_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;projet.c,39 :: 		void interrupt()
;projet.c,41 :: 		if (TMR1IF_bit){
	BTFSS      TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
	GOTO       L_interrupt0
;projet.c,42 :: 		timer1_overflows++;
	INCF       _timer1_overflows+0, 1
	BTFSC      STATUS+0, 2
	INCF       _timer1_overflows+1, 1
;projet.c,44 :: 		if (timer1_overflows == 10){ // 10*0.1s = 1s
	MOVLW      0
	XORWF      _timer1_overflows+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt63
	MOVLW      10
	XORWF      _timer1_overflows+0, 0
L__interrupt63:
	BTFSS      STATUS+0, 2
	GOTO       L_interrupt1
;projet.c,45 :: 		time++;
	MOVF       _time+0, 0
	MOVWF      R0+0
	MOVF       _time+1, 0
	MOVWF      R0+1
	MOVF       _time+2, 0
	MOVWF      R0+2
	MOVF       _time+3, 0
	MOVWF      R0+3
	INCF       R0+0, 1
	BTFSC      STATUS+0, 2
	INCF       R0+1, 1
	BTFSC      STATUS+0, 2
	INCF       R0+2, 1
	BTFSC      STATUS+0, 2
	INCF       R0+3, 1
	MOVF       R0+0, 0
	MOVWF      _time+0
	MOVF       R0+1, 0
	MOVWF      _time+1
	MOVF       R0+2, 0
	MOVWF      _time+2
	MOVF       R0+3, 0
	MOVWF      _time+3
;projet.c,46 :: 		timer1_overflows = 0;
	CLRF       _timer1_overflows+0
	CLRF       _timer1_overflows+1
;projet.c,48 :: 		if (pump_running){
	BTFSS      _pump_running+0, BitPos(_pump_running+0)
	GOTO       L_interrupt2
;projet.c,49 :: 		if (time > MIN_IRRIGATION_TIME)
	MOVF       _time+3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt64
	MOVF       _time+2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt64
	MOVF       _time+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt64
	MOVF       _time+0, 0
	SUBLW      10
L__interrupt64:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt3
;projet.c,50 :: 		not_enough = 0;
	BCF        _not_enough+0, BitPos(_not_enough+0)
L_interrupt3:
;projet.c,52 :: 		if (time > MAX_IRRIGATION_TIME)
	MOVF       _time+3, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt65
	MOVF       _time+2, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt65
	MOVF       _time+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt65
	MOVF       _time+0, 0
	SUBLW      20
L__interrupt65:
	BTFSC      STATUS+0, 0
	GOTO       L_interrupt4
;projet.c,53 :: 		too_much = 1;
	BSF        _too_much+0, BitPos(_too_much+0)
L_interrupt4:
;projet.c,54 :: 		}
	GOTO       L_interrupt5
L_interrupt2:
;projet.c,56 :: 		else if (time >= IRRIGATION_INTERVAL){
	MOVLW      0
	SUBWF      _time+3, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt66
	MOVLW      0
	SUBWF      _time+2, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt66
	MOVLW      0
	SUBWF      _time+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__interrupt66
	MOVLW      60
	SUBWF      _time+0, 0
L__interrupt66:
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt6
;projet.c,57 :: 		TMR1IE_bit = 0;
	BCF        TMR1IE_bit+0, BitPos(TMR1IE_bit+0)
;projet.c,58 :: 		TMR1ON_bit = 0;
	BCF        TMR1ON_bit+0, BitPos(TMR1ON_bit+0)
;projet.c,59 :: 		time_on = 0;
	BCF        _time_on+0, BitPos(_time_on+0)
;projet.c,60 :: 		time = 0;
	CLRF       _time+0
	CLRF       _time+1
	CLRF       _time+2
	CLRF       _time+3
;projet.c,61 :: 		wait = 0;
	BCF        _wait+0, BitPos(_wait+0)
;projet.c,62 :: 		}
L_interrupt6:
L_interrupt5:
;projet.c,63 :: 		}
L_interrupt1:
;projet.c,64 :: 		TMR1H = 109;
	MOVLW      109
	MOVWF      TMR1H+0
;projet.c,65 :: 		TMR1L = 132;
	MOVLW      132
	MOVWF      TMR1L+0
;projet.c,66 :: 		TMR1IF_bit = 0;
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;projet.c,67 :: 		}
L_interrupt0:
;projet.c,68 :: 		}
L_end_interrupt:
L__interrupt62:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_init_timer1:

;projet.c,70 :: 		void init_timer1(){
;projet.c,82 :: 		T1CON = 0x31;
	MOVLW      49
	MOVWF      T1CON+0
;projet.c,83 :: 		TMR1H = 109;
	MOVLW      109
	MOVWF      TMR1H+0
;projet.c,84 :: 		TMR1L = 132;
	MOVLW      132
	MOVWF      TMR1L+0
;projet.c,85 :: 		TMR1IF_bit = 0;
	BCF        TMR1IF_bit+0, BitPos(TMR1IF_bit+0)
;projet.c,86 :: 		TMR1IE_bit = 1;
	BSF        TMR1IE_bit+0, BitPos(TMR1IE_bit+0)
;projet.c,87 :: 		PEIE_bit = 1;
	BSF        PEIE_bit+0, BitPos(PEIE_bit+0)
;projet.c,88 :: 		GIE_bit = 1;
	BSF        GIE_bit+0, BitPos(GIE_bit+0)
;projet.c,89 :: 		}
L_end_init_timer1:
	RETURN
; end of _init_timer1

_initialization_pic:

;projet.c,91 :: 		void initialization_pic(){
;projet.c,92 :: 		TRISA = 0x01;
	MOVLW      1
	MOVWF      TRISA+0
;projet.c,93 :: 		TRISB = 0x00;
	CLRF       TRISB+0
;projet.c,94 :: 		TRISD = 0x01;
	MOVLW      1
	MOVWF      TRISD+0
;projet.c,95 :: 		PORTB = 0x00;
	CLRF       PORTB+0
;projet.c,96 :: 		pin_motor = 1; //=1 if normally open, =0 if normally close
	BSF        PORTD+0, 2
;projet.c,97 :: 		need_water = 0;
	BCF        _need_water+0, BitPos(_need_water+0)
;projet.c,98 :: 		pump_running = 0;
	BCF        _pump_running+0, BitPos(_pump_running+0)
;projet.c,99 :: 		time_on = 0;
	BCF        _time_on+0, BitPos(_time_on+0)
;projet.c,100 :: 		too_much = 0;
	BCF        _too_much+0, BitPos(_too_much+0)
;projet.c,101 :: 		not_enough = 1;
	BSF        _not_enough+0, BitPos(_not_enough+0)
;projet.c,102 :: 		wait = 0;
	BCF        _wait+0, BitPos(_wait+0)
;projet.c,104 :: 		pump_txt[0] = 'P';
	MOVLW      80
	MOVWF      _pump_txt+0
;projet.c,105 :: 		pump_txt[1] = 'U';
	MOVLW      85
	MOVWF      _pump_txt+1
;projet.c,106 :: 		pump_txt[2] = 'M';
	MOVLW      77
	MOVWF      _pump_txt+2
;projet.c,107 :: 		pump_txt[3] = 'P';
	MOVLW      80
	MOVWF      _pump_txt+3
;projet.c,108 :: 		pump_txt[4] = ':';
	MOVLW      58
	MOVWF      _pump_txt+4
;projet.c,109 :: 		pump_txt[5] = 'O';
	MOVLW      79
	MOVWF      _pump_txt+5
;projet.c,110 :: 		pump_txt[6] = 'F';
	MOVLW      70
	MOVWF      _pump_txt+6
;projet.c,111 :: 		pump_txt[7] = 'F';
	MOVLW      70
	MOVWF      _pump_txt+7
;projet.c,112 :: 		pump_txt[8] = '\0';
	CLRF       _pump_txt+8
;projet.c,114 :: 		mode_txt[0] = 'A';
	MOVLW      65
	MOVWF      _mode_txt+0
;projet.c,115 :: 		mode_txt[1] = 'U';
	MOVLW      85
	MOVWF      _mode_txt+1
;projet.c,116 :: 		mode_txt[2] = 'T';
	MOVLW      84
	MOVWF      _mode_txt+2
;projet.c,117 :: 		mode_txt[3] = 'O';
	MOVLW      79
	MOVWF      _mode_txt+3
;projet.c,118 :: 		mode_txt[4] = '\0';
	CLRF       _mode_txt+4
;projet.c,120 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;projet.c,121 :: 		delay_ms(200);
	MOVLW      4
	MOVWF      R11+0
	MOVLW      12
	MOVWF      R12+0
	MOVLW      51
	MOVWF      R13+0
L_initialization_pic7:
	DECFSZ     R13+0, 1
	GOTO       L_initialization_pic7
	DECFSZ     R12+0, 1
	GOTO       L_initialization_pic7
	DECFSZ     R11+0, 1
	GOTO       L_initialization_pic7
	NOP
	NOP
;projet.c,122 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;projet.c,123 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;projet.c,124 :: 		Lcd_Out(1, 1, "System turning");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr1_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,125 :: 		Lcd_Out(2, 7, "on...");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      7
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr2_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,128 :: 		UART1_Init(9600);
	MOVLW      77
	MOVWF      SPBRG+0
	BSF        TXSTA+0, 2
	CALL       _UART1_Init+0
;projet.c,129 :: 		delay_ms(200);
	MOVLW      4
	MOVWF      R11+0
	MOVLW      12
	MOVWF      R12+0
	MOVLW      51
	MOVWF      R13+0
L_initialization_pic8:
	DECFSZ     R13+0, 1
	GOTO       L_initialization_pic8
	DECFSZ     R12+0, 1
	GOTO       L_initialization_pic8
	DECFSZ     R11+0, 1
	GOTO       L_initialization_pic8
	NOP
	NOP
;projet.c,130 :: 		ADC_Init();
	CALL       _ADC_Init+0
;projet.c,131 :: 		delay_ms(500);
	MOVLW      8
	MOVWF      R11+0
	MOVLW      157
	MOVWF      R12+0
	MOVLW      5
	MOVWF      R13+0
L_initialization_pic9:
	DECFSZ     R13+0, 1
	GOTO       L_initialization_pic9
	DECFSZ     R12+0, 1
	GOTO       L_initialization_pic9
	DECFSZ     R11+0, 1
	GOTO       L_initialization_pic9
	NOP
	NOP
;projet.c,132 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;projet.c,133 :: 		}
L_end_initialization_pic:
	RETURN
; end of _initialization_pic

_initialization_dht:

;projet.c,135 :: 		void initialization_dht(){
;projet.c,137 :: 		TRISD.RD1 = 0;
	BCF        TRISD+0, 1
;projet.c,138 :: 		pin_dht = 0;
	BCF        PORTD+0, 1
;projet.c,139 :: 		delay_ms(20); // should be greater than 18ms
	MOVLW      78
	MOVWF      R12+0
	MOVLW      235
	MOVWF      R13+0
L_initialization_dht10:
	DECFSZ     R13+0, 1
	GOTO       L_initialization_dht10
	DECFSZ     R12+0, 1
	GOTO       L_initialization_dht10
;projet.c,140 :: 		pin_dht = 1;
	BSF        PORTD+0, 1
;projet.c,141 :: 		delay_us(50);
	MOVLW      49
	MOVWF      R13+0
L_initialization_dht11:
	DECFSZ     R13+0, 1
	GOTO       L_initialization_dht11
	NOP
	NOP
;projet.c,142 :: 		TRISD.RD1 = 1;
	BSF        TRISD+0, 1
;projet.c,143 :: 		}
L_end_initialization_dht:
	RETURN
; end of _initialization_dht

_check_dht_response:

;projet.c,145 :: 		unsigned char check_dht_response(){
;projet.c,146 :: 		delay_us(40);
	MOVLW      39
	MOVWF      R13+0
L_check_dht_response12:
	DECFSZ     R13+0, 1
	GOTO       L_check_dht_response12
	NOP
	NOP
;projet.c,147 :: 		if (pin_dht == 0){
	BTFSC      PORTD+0, 1
	GOTO       L_check_dht_response13
;projet.c,148 :: 		delay_us(80);
	MOVLW      79
	MOVWF      R13+0
L_check_dht_response14:
	DECFSZ     R13+0, 1
	GOTO       L_check_dht_response14
	NOP
	NOP
;projet.c,149 :: 		if (pin_dht == 1){
	BTFSS      PORTD+0, 1
	GOTO       L_check_dht_response15
;projet.c,150 :: 		delay_us(40);
	MOVLW      39
	MOVWF      R13+0
L_check_dht_response16:
	DECFSZ     R13+0, 1
	GOTO       L_check_dht_response16
	NOP
	NOP
;projet.c,151 :: 		return 1;
	MOVLW      1
	MOVWF      R0+0
	GOTO       L_end_check_dht_response
;projet.c,152 :: 		}
L_check_dht_response15:
;projet.c,153 :: 		}
L_check_dht_response13:
;projet.c,154 :: 		return 0;
	CLRF       R0+0
;projet.c,155 :: 		}
L_end_check_dht_response:
	RETURN
; end of _check_dht_response

_data_dht:

;projet.c,157 :: 		char data_dht(){
;projet.c,158 :: 		char i, r = 0;
	CLRF       data_dht_r_L0+0
;projet.c,159 :: 		for (i = 0; i < 8; i++){
	CLRF       R2+0
L_data_dht17:
	MOVLW      8
	SUBWF      R2+0, 0
	BTFSC      STATUS+0, 0
	GOTO       L_data_dht18
;projet.c,160 :: 		while (!pin_dht)
L_data_dht20:
	BTFSC      PORTD+0, 1
	GOTO       L_data_dht21
;projet.c,161 :: 		; // wait the signal to go 1
	GOTO       L_data_dht20
L_data_dht21:
;projet.c,162 :: 		delay_us(30);
	MOVLW      29
	MOVWF      R13+0
L_data_dht22:
	DECFSZ     R13+0, 1
	GOTO       L_data_dht22
	NOP
	NOP
;projet.c,163 :: 		if (pin_dht == 0) r &= ~(1 << (7 - i)); // bit clear
	BTFSC      PORTD+0, 1
	GOTO       L_data_dht23
	MOVF       R2+0, 0
	SUBLW      7
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__data_dht72:
	BTFSC      STATUS+0, 2
	GOTO       L__data_dht73
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__data_dht72
L__data_dht73:
	COMF       R0+0, 1
	MOVF       R0+0, 0
	ANDWF      data_dht_r_L0+0, 1
	GOTO       L_data_dht24
L_data_dht23:
;projet.c,165 :: 		else r |= (1 << (7 - i)); // bit set
	MOVF       R2+0, 0
	SUBLW      7
	MOVWF      R0+0
	MOVF       R0+0, 0
	MOVWF      R1+0
	MOVLW      1
	MOVWF      R0+0
	MOVF       R1+0, 0
L__data_dht74:
	BTFSC      STATUS+0, 2
	GOTO       L__data_dht75
	RLF        R0+0, 1
	BCF        R0+0, 0
	ADDLW      255
	GOTO       L__data_dht74
L__data_dht75:
	MOVF       R0+0, 0
	IORWF      data_dht_r_L0+0, 1
L_data_dht24:
;projet.c,166 :: 		while (pin_dht); // wait the signal to go 0
L_data_dht25:
	BTFSS      PORTD+0, 1
	GOTO       L_data_dht26
	GOTO       L_data_dht25
L_data_dht26:
;projet.c,159 :: 		for (i = 0; i < 8; i++){
	INCF       R2+0, 1
;projet.c,167 :: 		}
	GOTO       L_data_dht17
L_data_dht18:
;projet.c,168 :: 		return r;
	MOVF       data_dht_r_L0+0, 0
	MOVWF      R0+0
;projet.c,169 :: 		}
L_end_data_dht:
	RETURN
; end of _data_dht

_display_on_lcd:

;projet.c,171 :: 		void display_on_lcd(){
;projet.c,172 :: 		Lcd_Out(1, 1, "T = ");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr3_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,173 :: 		Lcd_Out(1, 5, temperature_txt);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _temperature_txt+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,174 :: 		Lcd_Chr(1, 5 + strlen(temperature_txt), 223); // Symbole �
	MOVLW      _temperature_txt+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	ADDLW      5
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      223
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;projet.c,175 :: 		Lcd_Out(1, 6 + strlen(temperature_txt), "C H = ");
	MOVLW      _temperature_txt+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	ADDLW      6
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      ?lstr4_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,176 :: 		Lcd_Out(1, 12 + strlen(temperature_txt), humidity_txt);
	MOVLW      _temperature_txt+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	ADDLW      12
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      _humidity_txt+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,177 :: 		Lcd_Out(1, 12 + strlen(temperature_txt) + strlen(humidity_txt), "%");
	MOVLW      _temperature_txt+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	ADDLW      12
	MOVWF      FLOC__display_on_lcd+0
	MOVLW      _humidity_txt+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	ADDWF      FLOC__display_on_lcd+0, 0
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      ?lstr5_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,179 :: 		Lcd_Out(2, 1, "M = ");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr6_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,180 :: 		Lcd_Out(2, 5, soil_moisture_txt);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      5
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _soil_moisture_txt+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,181 :: 		Lcd_Out(2, 5 + strlen(soil_moisture_txt), "% ");
	MOVLW      _soil_moisture_txt+0
	MOVWF      FARG_strlen_s+0
	CALL       _strlen+0
	MOVF       R0+0, 0
	ADDLW      5
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      ?lstr7_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,182 :: 		}
L_end_display_on_lcd:
	RETURN
; end of _display_on_lcd

_sending_data:

;projet.c,184 :: 		void sending_data(){
;projet.c,185 :: 		UART1_Write_Text(temperature_txt);
	MOVLW      _temperature_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,186 :: 		UART1_Write_Text(",");
	MOVLW      ?lstr8_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,187 :: 		UART1_Write_Text(humidity_txt);
	MOVLW      _humidity_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,188 :: 		UART1_Write_Text(",");
	MOVLW      ?lstr9_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,189 :: 		UART1_Write_Text(soil_moisture_txt);
	MOVLW      _soil_moisture_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,190 :: 		UART1_Write_Text(",");
	MOVLW      ?lstr10_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,191 :: 		UART1_Write_Text(water_consummed_txt);
	MOVLW      _water_consummed_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,192 :: 		UART1_Write_Text(",");
	MOVLW      ?lstr11_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,193 :: 		UART1_Write_Text(mode_txt);
	MOVLW      _mode_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,194 :: 		UART1_Write_Text(",");
	MOVLW      ?lstr12_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,195 :: 		UART1_Write_Text(pump_txt);
	MOVLW      _pump_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,196 :: 		UART1_Write_Text(",");
	MOVLW      ?lstr13_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,197 :: 		UART1_Write_Text(wait_txt);
	MOVLW      _wait_txt+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,198 :: 		UART1_Write_Text("\r\n");
	MOVLW      ?lstr14_projet+0
	MOVWF      FARG_UART1_Write_Text_uart_text+0
	CALL       _UART1_Write_Text+0
;projet.c,199 :: 		}
L_end_sending_data:
	RETURN
; end of _sending_data

_sensors_process:

;projet.c,201 :: 		void sensors_process(){
;projet.c,202 :: 		delay_ms(100); // power up time
	MOVLW      2
	MOVWF      R11+0
	MOVLW      134
	MOVWF      R12+0
	MOVLW      153
	MOVWF      R13+0
L_sensors_process27:
	DECFSZ     R13+0, 1
	GOTO       L_sensors_process27
	DECFSZ     R12+0, 1
	GOTO       L_sensors_process27
	DECFSZ     R11+0, 1
	GOTO       L_sensors_process27
;projet.c,204 :: 		IntToStr(wait, wait_txt);
	MOVLW      0
	BTFSC      _wait+0, BitPos(_wait+0)
	MOVLW      1
	MOVWF      FARG_IntToStr_input+0
	CLRF       FARG_IntToStr_input+1
	MOVLW      _wait_txt+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;projet.c,205 :: 		Ltrim(wait_txt);
	MOVLW      _wait_txt+0
	MOVWF      FARG_Ltrim_string+0
	CALL       _Ltrim+0
;projet.c,207 :: 		if(pump_running) irrigation_session = time;
	BTFSS      _pump_running+0, BitPos(_pump_running+0)
	GOTO       L_sensors_process28
	MOVF       _time+0, 0
	MOVWF      _irrigation_session+0
	MOVF       _time+1, 0
	MOVWF      _irrigation_session+1
	MOVF       _time+2, 0
	MOVWF      _irrigation_session+2
	MOVF       _time+3, 0
	MOVWF      _irrigation_session+3
	GOTO       L_sensors_process29
L_sensors_process28:
;projet.c,208 :: 		else irrigation_session = 0;
	CLRF       _irrigation_session+0
	CLRF       _irrigation_session+1
	CLRF       _irrigation_session+2
	CLRF       _irrigation_session+3
L_sensors_process29:
;projet.c,211 :: 		water_consummed = FLOW * (irrigation_duration + irrigation_session);
	MOVF       _irrigation_session+0, 0
	ADDWF      _irrigation_duration+0, 0
	MOVWF      R0+0
	MOVF       _irrigation_duration+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _irrigation_session+1, 0
	MOVWF      R0+1
	MOVF       R0+0, 0
	MOVWF      _water_consummed+0
	MOVF       R0+1, 0
	MOVWF      _water_consummed+1
;projet.c,212 :: 		IntToStr(water_consummed, water_consummed_txt);
	MOVF       R0+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _water_consummed_txt+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;projet.c,213 :: 		Ltrim(water_consummed_txt);
	MOVLW      _water_consummed_txt+0
	MOVWF      FARG_Ltrim_string+0
	CALL       _Ltrim+0
;projet.c,216 :: 		soil_moisture = 0;
	CLRF       _soil_moisture+0
	CLRF       _soil_moisture+1
;projet.c,217 :: 		for (i = 0; i < 4; i++){
	CLRF       _i+0
	CLRF       _i+1
L_sensors_process30:
	MOVLW      0
	SUBWF      _i+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sensors_process79
	MOVLW      4
	SUBWF      _i+0, 0
L__sensors_process79:
	BTFSC      STATUS+0, 0
	GOTO       L_sensors_process31
;projet.c,218 :: 		temp_soil_moisture = 100 * (1000 - ADC_Read(0)) / (1000 - 200);
	CLRF       FARG_ADC_Read_channel+0
	CALL       _ADC_Read+0
	MOVF       R0+0, 0
	SUBLW      232
	MOVWF      R0+0
	MOVF       R0+1, 0
	BTFSS      STATUS+0, 0
	ADDLW      1
	SUBLW      3
	MOVWF      R0+1
	MOVLW      100
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	CALL       _Mul_16X16_U+0
	MOVLW      32
	MOVWF      R4+0
	MOVLW      3
	MOVWF      R4+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      _temp_soil_moisture+0
	MOVF       R0+1, 0
	MOVWF      _temp_soil_moisture+1
;projet.c,219 :: 		if (temp_soil_moisture < 0) temp_soil_moisture = 0;
	MOVLW      0
	SUBWF      R0+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sensors_process80
	MOVLW      0
	SUBWF      R0+0, 0
L__sensors_process80:
	BTFSC      STATUS+0, 0
	GOTO       L_sensors_process33
	CLRF       _temp_soil_moisture+0
	CLRF       _temp_soil_moisture+1
L_sensors_process33:
;projet.c,220 :: 		if (temp_soil_moisture > 100) temp_soil_moisture = 100;
	MOVF       _temp_soil_moisture+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__sensors_process81
	MOVF       _temp_soil_moisture+0, 0
	SUBLW      100
L__sensors_process81:
	BTFSC      STATUS+0, 0
	GOTO       L_sensors_process34
	MOVLW      100
	MOVWF      _temp_soil_moisture+0
	MOVLW      0
	MOVWF      _temp_soil_moisture+1
L_sensors_process34:
;projet.c,221 :: 		soil_moisture = soil_moisture + temp_soil_moisture;
	MOVF       _temp_soil_moisture+0, 0
	ADDWF      _soil_moisture+0, 1
	MOVF       _temp_soil_moisture+1, 0
	BTFSC      STATUS+0, 0
	ADDLW      1
	ADDWF      _soil_moisture+1, 1
;projet.c,217 :: 		for (i = 0; i < 4; i++){
	INCF       _i+0, 1
	BTFSC      STATUS+0, 2
	INCF       _i+1, 1
;projet.c,222 :: 		}
	GOTO       L_sensors_process30
L_sensors_process31:
;projet.c,224 :: 		IntToStr(soil_moisture / i, soil_moisture_txt);
	MOVF       _i+0, 0
	MOVWF      R4+0
	MOVF       _i+1, 0
	MOVWF      R4+1
	MOVF       _soil_moisture+0, 0
	MOVWF      R0+0
	MOVF       _soil_moisture+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R0+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       R0+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _soil_moisture_txt+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;projet.c,225 :: 		Ltrim(soil_moisture_txt);
	MOVLW      _soil_moisture_txt+0
	MOVWF      FARG_Ltrim_string+0
	CALL       _Ltrim+0
;projet.c,228 :: 		initialization_dht();
	CALL       _initialization_dht+0
;projet.c,230 :: 		if (check_dht_response()){
	CALL       _check_dht_response+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_sensors_process35
;projet.c,231 :: 		humidity_int = data_dht(); // first 8 bits from dht(integral part of humidity)
	CALL       _data_dht+0
	MOVF       R0+0, 0
	MOVWF      _humidity_int+0
;projet.c,232 :: 		humidity_dec = data_dht(); // next 8 bits from dht(decimal part of humidity)
	CALL       _data_dht+0
	MOVF       R0+0, 0
	MOVWF      _humidity_dec+0
;projet.c,233 :: 		temp_int = data_dht();     // next 8 bits from dht(integral part of temperature)
	CALL       _data_dht+0
	MOVF       R0+0, 0
	MOVWF      _temp_int+0
;projet.c,234 :: 		temp_dec = data_dht();     // next 8 bits from dht(decimal part of temperature)
	CALL       _data_dht+0
	MOVF       R0+0, 0
	MOVWF      _temp_dec+0
;projet.c,235 :: 		checksum = data_dht();     // last 8 bits from dht(parity bit)
	CALL       _data_dht+0
	MOVF       R0+0, 0
	MOVWF      _checksum+0
;projet.c,236 :: 		valid_sensor_data = 0;
	BCF        _valid_sensor_data+0, BitPos(_valid_sensor_data+0)
;projet.c,237 :: 		if (checksum == ((humidity_int + humidity_dec + temp_int + temp_dec) & 0xFF)){ //&0xFF to take 8 bits
	MOVF       _humidity_dec+0, 0
	ADDWF      _humidity_int+0, 0
	MOVWF      R1+0
	CLRF       R1+1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVF       _temp_int+0, 0
	ADDWF      R1+0, 1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVF       _temp_dec+0, 0
	ADDWF      R1+0, 1
	BTFSC      STATUS+0, 0
	INCF       R1+1, 1
	MOVLW      255
	ANDWF      R1+0, 0
	MOVWF      R3+0
	MOVF       R1+1, 0
	MOVWF      R3+1
	MOVLW      0
	ANDWF      R3+1, 1
	MOVLW      0
	XORWF      R3+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__sensors_process82
	MOVF       R3+0, 0
	XORWF      R0+0, 0
L__sensors_process82:
	BTFSS      STATUS+0, 2
	GOTO       L_sensors_process36
;projet.c,238 :: 		valid_sensor_data = 1;
	BSF        _valid_sensor_data+0, BitPos(_valid_sensor_data+0)
;projet.c,239 :: 		temperature = temp_int;
	MOVF       _temp_int+0, 0
	MOVWF      _temperature+0
	CLRF       _temperature+1
;projet.c,240 :: 		humidity = humidity_int;
	MOVF       _humidity_int+0, 0
	MOVWF      _humidity+0
	CLRF       _humidity+1
;projet.c,241 :: 		IntToStr(temperature, temperature_txt);
	MOVF       _temperature+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       _temperature+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _temperature_txt+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;projet.c,242 :: 		IntToStr(humidity, humidity_txt);
	MOVF       _humidity+0, 0
	MOVWF      FARG_IntToStr_input+0
	MOVF       _humidity+1, 0
	MOVWF      FARG_IntToStr_input+1
	MOVLW      _humidity_txt+0
	MOVWF      FARG_IntToStr_output+0
	CALL       _IntToStr+0
;projet.c,243 :: 		Ltrim(temperature_txt);
	MOVLW      _temperature_txt+0
	MOVWF      FARG_Ltrim_string+0
	CALL       _Ltrim+0
;projet.c,244 :: 		Ltrim(humidity_txt);
	MOVLW      _humidity_txt+0
	MOVWF      FARG_Ltrim_string+0
	CALL       _Ltrim+0
;projet.c,247 :: 		display_on_lcd();
	CALL       _display_on_lcd+0
;projet.c,249 :: 		sending_data();
	CALL       _sending_data+0
;projet.c,250 :: 		}
L_sensors_process36:
;projet.c,251 :: 		}
L_sensors_process35:
;projet.c,252 :: 		}
L_end_sensors_process:
	RETURN
; end of _sensors_process

_manual_mode:

;projet.c,254 :: 		void manual_mode()
;projet.c,256 :: 		mode_txt[0] = 'M';
	MOVLW      77
	MOVWF      _mode_txt+0
;projet.c,257 :: 		mode_txt[1] = 'A';
	MOVLW      65
	MOVWF      _mode_txt+1
;projet.c,258 :: 		mode_txt[2] = 'N';
	MOVLW      78
	MOVWF      _mode_txt+2
;projet.c,259 :: 		mode_txt[3] = 'U';
	MOVLW      85
	MOVWF      _mode_txt+3
;projet.c,260 :: 		mode_txt[4] = '\0';
	CLRF       _mode_txt+4
;projet.c,261 :: 		if (pump_running){
	BTFSS      _pump_running+0, BitPos(_pump_running+0)
	GOTO       L_manual_mode37
;projet.c,262 :: 		irrigation_duration += irrigation_session;
	MOVF       _irrigation_session+0, 0
	ADDWF      _irrigation_duration+0, 1
	MOVF       _irrigation_session+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _irrigation_session+1, 0
	ADDWF      _irrigation_duration+1, 1
	MOVF       _irrigation_session+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _irrigation_session+2, 0
	ADDWF      _irrigation_duration+2, 1
	MOVF       _irrigation_session+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _irrigation_session+3, 0
	ADDWF      _irrigation_duration+3, 1
;projet.c,263 :: 		TMR1IE_bit = 0;
	BCF        TMR1IE_bit+0, BitPos(TMR1IE_bit+0)
;projet.c,264 :: 		TMR1ON_bit = 0;
	BCF        TMR1ON_bit+0, BitPos(TMR1ON_bit+0)
;projet.c,265 :: 		time = 0;
	CLRF       _time+0
	CLRF       _time+1
	CLRF       _time+2
	CLRF       _time+3
;projet.c,266 :: 		wait = 0;
	BCF        _wait+0, BitPos(_wait+0)
;projet.c,267 :: 		}
L_manual_mode37:
;projet.c,268 :: 		wait = 0;
	BCF        _wait+0, BitPos(_wait+0)
;projet.c,269 :: 		pump_running = 0;
	BCF        _pump_running+0, BitPos(_pump_running+0)
;projet.c,270 :: 		pin_motor = 1;
	BSF        PORTD+0, 2
;projet.c,271 :: 		Lcd_Out(2, 9, "Mode:MAN");
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr15_projet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,272 :: 		}
L_end_manual_mode:
	RETURN
; end of _manual_mode

_automatic_mode:

;projet.c,274 :: 		void automatic_mode(){
;projet.c,275 :: 		mode_txt[0] = 'A';
	MOVLW      65
	MOVWF      _mode_txt+0
;projet.c,276 :: 		mode_txt[1] = 'U';
	MOVLW      85
	MOVWF      _mode_txt+1
;projet.c,277 :: 		mode_txt[2] = 'T';
	MOVLW      84
	MOVWF      _mode_txt+2
;projet.c,278 :: 		mode_txt[3] = 'O';
	MOVLW      79
	MOVWF      _mode_txt+3
;projet.c,279 :: 		mode_txt[4] = '\0';
	CLRF       _mode_txt+4
;projet.c,281 :: 		need_water = (temperature > seuil_temperature) || (humidity < seuil_humidity) || (soil_moisture < seuil_moisture);
	MOVF       _temperature+1, 0
	SUBLW      0
	BTFSS      STATUS+0, 2
	GOTO       L__automatic_mode85
	MOVF       _temperature+0, 0
	SUBLW      30
L__automatic_mode85:
	BTFSS      STATUS+0, 0
	GOTO       L_automatic_mode39
	MOVLW      0
	SUBWF      _humidity+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__automatic_mode86
	MOVLW      20
	SUBWF      _humidity+0, 0
L__automatic_mode86:
	BTFSS      STATUS+0, 0
	GOTO       L_automatic_mode39
	MOVLW      0
	SUBWF      _soil_moisture+1, 0
	BTFSS      STATUS+0, 2
	GOTO       L__automatic_mode87
	MOVLW      35
	SUBWF      _soil_moisture+0, 0
L__automatic_mode87:
	BTFSS      STATUS+0, 0
	GOTO       L_automatic_mode39
	CLRF       R0+0
	GOTO       L_automatic_mode38
L_automatic_mode39:
	MOVLW      1
	MOVWF      R0+0
L_automatic_mode38:
	BTFSC      R0+0, 0
	GOTO       L__automatic_mode88
	BCF        _need_water+0, BitPos(_need_water+0)
	GOTO       L__automatic_mode89
L__automatic_mode88:
	BSF        _need_water+0, BitPos(_need_water+0)
L__automatic_mode89:
;projet.c,283 :: 		if (time_on == 0){
	BTFSC      _time_on+0, BitPos(_time_on+0)
	GOTO       L_automatic_mode40
;projet.c,284 :: 		too_much = 0;
	BCF        _too_much+0, BitPos(_too_much+0)
;projet.c,285 :: 		not_enough = 1;
	BSF        _not_enough+0, BitPos(_not_enough+0)
;projet.c,286 :: 		}
L_automatic_mode40:
;projet.c,288 :: 		if (!wait){
	BTFSC      _wait+0, BitPos(_wait+0)
	GOTO       L_automatic_mode41
;projet.c,289 :: 		if (pump_running && not_enough){
	BTFSS      _pump_running+0, BitPos(_pump_running+0)
	GOTO       L_automatic_mode44
	BTFSS      _not_enough+0, BitPos(_not_enough+0)
	GOTO       L_automatic_mode44
L__automatic_mode60:
;projet.c,290 :: 		pump_txt[5] = 'O';
	MOVLW      79
	MOVWF      _pump_txt+5
;projet.c,291 :: 		pump_txt[6] = 'N';
	MOVLW      78
	MOVWF      _pump_txt+6
;projet.c,292 :: 		pump_txt[7] = ' ';
	MOVLW      32
	MOVWF      _pump_txt+7
;projet.c,293 :: 		pump_txt[8] = '\0';
	CLRF       _pump_txt+8
;projet.c,294 :: 		pin_motor = 0;
	BCF        PORTD+0, 2
;projet.c,295 :: 		pump_running = 1;
	BSF        _pump_running+0, BitPos(_pump_running+0)
;projet.c,296 :: 		}
	GOTO       L_automatic_mode45
L_automatic_mode44:
;projet.c,298 :: 		else if (need_water && !too_much){
	BTFSS      _need_water+0, BitPos(_need_water+0)
	GOTO       L_automatic_mode48
	BTFSC      _too_much+0, BitPos(_too_much+0)
	GOTO       L_automatic_mode48
L__automatic_mode59:
;projet.c,299 :: 		pump_running = 1;
	BSF        _pump_running+0, BitPos(_pump_running+0)
;projet.c,300 :: 		if (time_on == 0){
	BTFSC      _time_on+0, BitPos(_time_on+0)
	GOTO       L_automatic_mode49
;projet.c,301 :: 		init_timer1();
	CALL       _init_timer1+0
;projet.c,302 :: 		time_on = 1;
	BSF        _time_on+0, BitPos(_time_on+0)
;projet.c,303 :: 		time = 0; // Reset timer for this irrigation cycle
	CLRF       _time+0
	CLRF       _time+1
	CLRF       _time+2
	CLRF       _time+3
;projet.c,304 :: 		}
L_automatic_mode49:
;projet.c,305 :: 		pump_txt[5] = 'O';
	MOVLW      79
	MOVWF      _pump_txt+5
;projet.c,306 :: 		pump_txt[6] = 'N';
	MOVLW      78
	MOVWF      _pump_txt+6
;projet.c,307 :: 		pump_txt[7] = ' ';
	MOVLW      32
	MOVWF      _pump_txt+7
;projet.c,308 :: 		pump_txt[8] = '\0';
	CLRF       _pump_txt+8
;projet.c,309 :: 		pin_motor = 0;
	BCF        PORTD+0, 2
;projet.c,310 :: 		}
	GOTO       L_automatic_mode50
L_automatic_mode48:
;projet.c,313 :: 		if(pump_running){
	BTFSS      _pump_running+0, BitPos(_pump_running+0)
	GOTO       L_automatic_mode51
;projet.c,314 :: 		irrigation_duration += irrigation_session;
	MOVF       _irrigation_session+0, 0
	ADDWF      _irrigation_duration+0, 1
	MOVF       _irrigation_session+1, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _irrigation_session+1, 0
	ADDWF      _irrigation_duration+1, 1
	MOVF       _irrigation_session+2, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _irrigation_session+2, 0
	ADDWF      _irrigation_duration+2, 1
	MOVF       _irrigation_session+3, 0
	BTFSC      STATUS+0, 0
	INCFSZ     _irrigation_session+3, 0
	ADDWF      _irrigation_duration+3, 1
;projet.c,315 :: 		pump_running = 0;
	BCF        _pump_running+0, BitPos(_pump_running+0)
;projet.c,316 :: 		time = 0;
	CLRF       _time+0
	CLRF       _time+1
	CLRF       _time+2
	CLRF       _time+3
;projet.c,317 :: 		wait = 1;
	BSF        _wait+0, BitPos(_wait+0)
;projet.c,318 :: 		}
L_automatic_mode51:
;projet.c,319 :: 		pin_motor = 1;
	BSF        PORTD+0, 2
;projet.c,320 :: 		pump_txt[5] = 'O';
	MOVLW      79
	MOVWF      _pump_txt+5
;projet.c,321 :: 		pump_txt[6] = 'F';
	MOVLW      70
	MOVWF      _pump_txt+6
;projet.c,322 :: 		pump_txt[7] = 'F';
	MOVLW      70
	MOVWF      _pump_txt+7
;projet.c,323 :: 		pump_txt[8] = '\0';
	CLRF       _pump_txt+8
;projet.c,324 :: 		}
L_automatic_mode50:
L_automatic_mode45:
;projet.c,325 :: 		}
	GOTO       L_automatic_mode52
L_automatic_mode41:
;projet.c,327 :: 		pump_running = 0;
	BCF        _pump_running+0, BitPos(_pump_running+0)
;projet.c,328 :: 		pin_motor = 1;
	BSF        PORTD+0, 2
;projet.c,329 :: 		pump_txt[5] = 'O';
	MOVLW      79
	MOVWF      _pump_txt+5
;projet.c,330 :: 		pump_txt[6] = 'F';
	MOVLW      70
	MOVWF      _pump_txt+6
;projet.c,331 :: 		pump_txt[7] = 'F';
	MOVLW      70
	MOVWF      _pump_txt+7
;projet.c,332 :: 		pump_txt[8] = '\0';
	CLRF       _pump_txt+8
;projet.c,333 :: 		}
L_automatic_mode52:
;projet.c,335 :: 		Lcd_Out(2, 9, pump_txt);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      9
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      _pump_txt+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;projet.c,336 :: 		}
L_end_automatic_mode:
	RETURN
; end of _automatic_mode

_main:

;projet.c,338 :: 		void main(){
;projet.c,339 :: 		initialization_pic();
	CALL       _initialization_pic+0
;projet.c,341 :: 		while (1){
L_main53:
;projet.c,342 :: 		sensors_process();
	CALL       _sensors_process+0
;projet.c,343 :: 		if (valid_sensor_data){
	BTFSS      _valid_sensor_data+0, BitPos(_valid_sensor_data+0)
	GOTO       L_main55
;projet.c,344 :: 		if (PORTD.RD0 == 1){
	BTFSS      PORTD+0, 0
	GOTO       L_main56
;projet.c,345 :: 		manual_mode();
	CALL       _manual_mode+0
;projet.c,346 :: 		}
	GOTO       L_main57
L_main56:
;projet.c,348 :: 		automatic_mode();
	CALL       _automatic_mode+0
;projet.c,349 :: 		}
L_main57:
;projet.c,350 :: 		}
L_main55:
;projet.c,351 :: 		delay_ms(1000);
	MOVLW      16
	MOVWF      R11+0
	MOVLW      57
	MOVWF      R12+0
	MOVLW      13
	MOVWF      R13+0
L_main58:
	DECFSZ     R13+0, 1
	GOTO       L_main58
	DECFSZ     R12+0, 1
	GOTO       L_main58
	DECFSZ     R11+0, 1
	GOTO       L_main58
	NOP
	NOP
;projet.c,352 :: 		}
	GOTO       L_main53
;projet.c,353 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
