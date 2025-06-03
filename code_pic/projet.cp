#line 1 "D:/Programmation & simulation/Projets/système d'irrigation automatique/projet/projet5/projet.c"
#line 17 "D:/Programmation & simulation/Projets/système d'irrigation automatique/projet/projet5/projet.c"
sbit LCD_D4 at RB0_bit;
sbit LCD_D5 at RB1_bit;
sbit LCD_D6 at RB2_bit;
sbit LCD_D7 at RB3_bit;
sbit LCD_RS at RB4_bit;
sbit LCD_EN at RB5_bit;
sbit LCD_D4_Direction at TRISB0_bit;
sbit LCD_D5_Direction at TRISB1_bit;
sbit LCD_D6_Direction at TRISB2_bit;
sbit LCD_D7_Direction at TRISB3_bit;
sbit LCD_RS_Direction at TRISB4_bit;
sbit LCD_EN_Direction at TRISB5_bit;


unsigned char humidity_int, humidity_dec, temp_int, temp_dec, checksum;

unsigned int temperature, humidity, soil_moisture, temp_soil_moisture, i, water_consummed = 0, timer1_overflows = 0;
char temperature_txt[7], humidity_txt[7], soil_moisture_txt[7], water_consummed_txt[7], pump_txt[9], mode_txt[7], wait_txt[2];
bit valid_sensor_data, need_water, pump_running, too_much, not_enough, wait, time_on, cycle;

volatile unsigned long time = 0, irrigation_duration = 0, irrigation_session = 0;

void interrupt()
{
 if (TMR1IF_bit){
 timer1_overflows++;

 if (timer1_overflows == 10){
 time++;
 timer1_overflows = 0;

 if (pump_running){
 if (time >  10 )
 not_enough = 0;

 if (time >  20 )
 too_much = 1;
 }

 else if (time >=  60 ){
 TMR1IE_bit = 0;
 TMR1ON_bit = 0;
 time_on = 0;
 time = 0;
 wait = 0;
 }
 }
 TMR1H = 109;
 TMR1L = 132;
 TMR1IF_bit = 0;
 }
}

void init_timer1(){
#line 82 "D:/Programmation & simulation/Projets/système d'irrigation automatique/projet/projet5/projet.c"
 T1CON = 0x31;
 TMR1H = 109;
 TMR1L = 132;
 TMR1IF_bit = 0;
 TMR1IE_bit = 1;
 PEIE_bit = 1;
 GIE_bit = 1;
}

void initialization_pic(){
 TRISA = 0x01;
 TRISB = 0x00;
 TRISD = 0x01;
 PORTB = 0x00;
  PORTD.RD2  = 1;
 need_water = 0;
 pump_running = 0;
 time_on = 0;
 too_much = 0;
 not_enough = 1;
 wait = 0;

 pump_txt[0] = 'P';
 pump_txt[1] = 'U';
 pump_txt[2] = 'M';
 pump_txt[3] = 'P';
 pump_txt[4] = ':';
 pump_txt[5] = 'O';
 pump_txt[6] = 'F';
 pump_txt[7] = 'F';
 pump_txt[8] = '\0';

 mode_txt[0] = 'A';
 mode_txt[1] = 'U';
 mode_txt[2] = 'T';
 mode_txt[3] = 'O';
 mode_txt[4] = '\0';

 Lcd_Init();
 delay_ms(200);
 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);
 Lcd_Out(1, 1, "System turning");
 Lcd_Out(2, 7, "on...");


 UART1_Init(9600);
 delay_ms(200);
 ADC_Init();
 delay_ms(500);
 Lcd_Cmd(_LCD_CLEAR);
}

void initialization_dht(){

 TRISD.RD1 = 0;
  PORTD.RD1  = 0;
 delay_ms(20);
  PORTD.RD1  = 1;
 delay_us(50);
 TRISD.RD1 = 1;
}

unsigned char check_dht_response(){
 delay_us(40);
 if ( PORTD.RD1  == 0){
 delay_us(80);
 if ( PORTD.RD1  == 1){
 delay_us(40);
 return 1;
 }
 }
 return 0;
}

char data_dht(){
 char i, r = 0;
 for (i = 0; i < 8; i++){
 while (! PORTD.RD1 )
 ;
 delay_us(30);
 if ( PORTD.RD1  == 0) r &= ~(1 << (7 - i));

 else r |= (1 << (7 - i));
 while ( PORTD.RD1 );
 }
 return r;
}

void display_on_lcd(){
 Lcd_Out(1, 1, "T = ");
 Lcd_Out(1, 5, temperature_txt);
 Lcd_Chr(1, 5 + strlen(temperature_txt), 223);
 Lcd_Out(1, 6 + strlen(temperature_txt), "C H = ");
 Lcd_Out(1, 12 + strlen(temperature_txt), humidity_txt);
 Lcd_Out(1, 12 + strlen(temperature_txt) + strlen(humidity_txt), "%");

 Lcd_Out(2, 1, "M = ");
 Lcd_Out(2, 5, soil_moisture_txt);
 Lcd_Out(2, 5 + strlen(soil_moisture_txt), "% ");
}

void sending_data(){
 UART1_Write_Text(temperature_txt);
 UART1_Write_Text(",");
 UART1_Write_Text(humidity_txt);
 UART1_Write_Text(",");
 UART1_Write_Text(soil_moisture_txt);
 UART1_Write_Text(",");
 UART1_Write_Text(water_consummed_txt);
 UART1_Write_Text(",");
 UART1_Write_Text(mode_txt);
 UART1_Write_Text(",");
 UART1_Write_Text(pump_txt);
 UART1_Write_Text(",");
 UART1_Write_Text(wait_txt);
 UART1_Write_Text("\r\n");
}

void sensors_process(){
 delay_ms(100);

 IntToStr(wait, wait_txt);
 Ltrim(wait_txt);

 if(pump_running) irrigation_session = time;
 else irrigation_session = 0;


 water_consummed =  1  * (irrigation_duration + irrigation_session);
 IntToStr(water_consummed, water_consummed_txt);
 Ltrim(water_consummed_txt);


 soil_moisture = 0;
 for (i = 0; i < 4; i++){
 temp_soil_moisture = 100 * (1000 - ADC_Read(0)) / (1000 - 200);
 if (temp_soil_moisture < 0) temp_soil_moisture = 0;
 if (temp_soil_moisture > 100) temp_soil_moisture = 100;
 soil_moisture = soil_moisture + temp_soil_moisture;
 }

 IntToStr(soil_moisture / i, soil_moisture_txt);
 Ltrim(soil_moisture_txt);


 initialization_dht();

 if (check_dht_response()){
 humidity_int = data_dht();
 humidity_dec = data_dht();
 temp_int = data_dht();
 temp_dec = data_dht();
 checksum = data_dht();
 valid_sensor_data = 0;
 if (checksum == ((humidity_int + humidity_dec + temp_int + temp_dec) & 0xFF)){
 valid_sensor_data = 1;
 temperature = temp_int;
 humidity = humidity_int;
 IntToStr(temperature, temperature_txt);
 IntToStr(humidity, humidity_txt);
 Ltrim(temperature_txt);
 Ltrim(humidity_txt);


 display_on_lcd();

 sending_data();
 }
 }
}

void manual_mode()
{
 mode_txt[0] = 'M';
 mode_txt[1] = 'A';
 mode_txt[2] = 'N';
 mode_txt[3] = 'U';
 mode_txt[4] = '\0';
 if (pump_running){
 irrigation_duration += irrigation_session;
 TMR1IE_bit = 0;
 TMR1ON_bit = 0;
 time = 0;
 wait = 0;
 }
 wait = 0;
 pump_running = 0;
  PORTD.RD2  = 1;
 Lcd_Out(2, 9, "Mode:MAN");
}

void automatic_mode(){
 mode_txt[0] = 'A';
 mode_txt[1] = 'U';
 mode_txt[2] = 'T';
 mode_txt[3] = 'O';
 mode_txt[4] = '\0';

 need_water = (temperature >  30 ) || (humidity <  20 ) || (soil_moisture <  35 );

 if (time_on == 0){
 too_much = 0;
 not_enough = 1;
 }

 if (!wait){
 if (pump_running && not_enough){
 pump_txt[5] = 'O';
 pump_txt[6] = 'N';
 pump_txt[7] = ' ';
 pump_txt[8] = '\0';
  PORTD.RD2  = 0;
 pump_running = 1;
 }

 else if (need_water && !too_much){
 pump_running = 1;
 if (time_on == 0){
 init_timer1();
 time_on = 1;
 time = 0;
 }
 pump_txt[5] = 'O';
 pump_txt[6] = 'N';
 pump_txt[7] = ' ';
 pump_txt[8] = '\0';
  PORTD.RD2  = 0;
 }

 else{
 if(pump_running){
 irrigation_duration += irrigation_session;
 pump_running = 0;
 time = 0;
 wait = 1;
 }
  PORTD.RD2  = 1;
 pump_txt[5] = 'O';
 pump_txt[6] = 'F';
 pump_txt[7] = 'F';
 pump_txt[8] = '\0';
 }
 }
 else{
 pump_running = 0;
  PORTD.RD2  = 1;
 pump_txt[5] = 'O';
 pump_txt[6] = 'F';
 pump_txt[7] = 'F';
 pump_txt[8] = '\0';
 }

 Lcd_Out(2, 9, pump_txt);
}

void main(){
 initialization_pic();

 while (1){
 sensors_process();
 if (valid_sensor_data){
 if (PORTD.RD0 == 1){
 manual_mode();
 }
 else{
 automatic_mode();
 }
 }
 delay_ms(1000);
 }
}
