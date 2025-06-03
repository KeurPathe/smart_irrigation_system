// automatic irrigation system

#define pin_soil_mosture PORTA.RA0
#define pin_dht PORTD.RD1
#define pin_motor PORTD.RD2
#define TIMER1_PRESCALE 8
#define IRRIGATION_INTERVAL 60 // wait between cycles (60s for prototype, 3600s for real world)
#define MIN_IRRIGATION_TIME 10 // minimum pump run time   (10s for prototype, 15s for real world)
#define MAX_IRRIGATION_TIME 20 // maximum pump run time  (20s for prototype, 180s for real world)
#define FLOW 1                // flow   (80-120L/h = 2.2-3.3cL/s): 
                              // for 5V: flow = Q/T = 33/35 = 0.94cl/s ~ 1 cl/s
#define seuil_temperature 30
#define seuil_humidity 20
#define seuil_moisture 35

// Connections de LCD
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
// Fin de connections

unsigned char humidity_int, humidity_dec, temp_int, temp_dec, checksum;

unsigned int temperature, humidity, soil_moisture, temp_soil_moisture, i, water_consummed = 0, timer1_overflows = 0;
char temperature_txt[7], humidity_txt[7], soil_moisture_txt[7], water_consummed_txt[7], pump_txt[9], mode_txt[7], wait_txt[2];
bit valid_sensor_data, need_water, pump_running, too_much, not_enough, wait, time_on, cycle;

volatile unsigned long time = 0, irrigation_duration = 0, irrigation_session = 0;

void interrupt()
{
    if (TMR1IF_bit){
        timer1_overflows++;

        if (timer1_overflows == 10){ // 10*0.1s = 1s
            time++;
            timer1_overflows = 0;

            if (pump_running){
                if (time > MIN_IRRIGATION_TIME)
                    not_enough = 0;

                if (time > MAX_IRRIGATION_TIME)
                    too_much = 1;
            }

            else if (time >= IRRIGATION_INTERVAL){
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
    /*
      1s avec TMR1
      quartz: 12MHz
      0.1s = (1/12*10^6)*4*8*37500 et 0.1s*10=1s
      Prescaler = 8
      TMR1 = 37500
      TMR1 = 256TMRH+TMRL, avec TMRH = 255-TMRH_init = 146
                             et TMRL = 256-TMRL_init = 124
      donc TMRH_init = 109
           TMRL_init = 132
    */
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
    pin_motor = 1; //=1 if normally open, =0 if normally close
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

    // UART
    UART1_Init(9600);
    delay_ms(200);
    ADC_Init();
    delay_ms(500);
    Lcd_Cmd(_LCD_CLEAR);
}

void initialization_dht(){
    // the sensor should be in low state before sending sending data
    TRISD.RD1 = 0;
    pin_dht = 0;
    delay_ms(20); // should be greater than 18ms
    pin_dht = 1;
    delay_us(50);
    TRISD.RD1 = 1;
}

unsigned char check_dht_response(){
    delay_us(40);
    if (pin_dht == 0){
        delay_us(80);
        if (pin_dht == 1){
            delay_us(40);
            return 1;
        }
    }
    return 0;
}

char data_dht(){
    char i, r = 0;
    for (i = 0; i < 8; i++){
        while (!pin_dht)
            ; // wait the signal to go 1
        delay_us(30);
        if (pin_dht == 0) r &= ~(1 << (7 - i)); // bit clear

        else r |= (1 << (7 - i)); // bit set
        while (pin_dht); // wait the signal to go 0
    }
    return r;
}

void display_on_lcd(){
    Lcd_Out(1, 1, "T = ");
    Lcd_Out(1, 5, temperature_txt);
    Lcd_Chr(1, 5 + strlen(temperature_txt), 223); // Symbole �
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
    delay_ms(100); // power up time
    
    IntToStr(wait, wait_txt);
    Ltrim(wait_txt);

    if(pump_running) irrigation_session = time;
    else irrigation_session = 0;

    // water consommation
    water_consummed = FLOW * (irrigation_duration + irrigation_session);
    IntToStr(water_consummed, water_consummed_txt);
    Ltrim(water_consummed_txt);

    // soil_mosture
    soil_moisture = 0;
    for (i = 0; i < 4; i++){
        temp_soil_moisture = 100 * (1000 - ADC_Read(0)) / (1000 - 200);
        if (temp_soil_moisture < 0) temp_soil_moisture = 0;
        if (temp_soil_moisture > 100) temp_soil_moisture = 100;
        soil_moisture = soil_moisture + temp_soil_moisture;
    }

    IntToStr(soil_moisture / i, soil_moisture_txt);
    Ltrim(soil_moisture_txt);

    // dht
    initialization_dht();

    if (check_dht_response()){
        humidity_int = data_dht(); // first 8 bits from dht(integral part of humidity)
        humidity_dec = data_dht(); // next 8 bits from dht(decimal part of humidity)
        temp_int = data_dht();     // next 8 bits from dht(integral part of temperature)
        temp_dec = data_dht();     // next 8 bits from dht(decimal part of temperature)
        checksum = data_dht();     // last 8 bits from dht(parity bit)
        valid_sensor_data = 0;
        if (checksum == ((humidity_int + humidity_dec + temp_int + temp_dec) & 0xFF)){ //&0xFF to take 8 bits
            valid_sensor_data = 1;
            temperature = temp_int;
            humidity = humidity_int;
            IntToStr(temperature, temperature_txt);
            IntToStr(humidity, humidity_txt);
            Ltrim(temperature_txt);
            Ltrim(humidity_txt);

            // Display on LCD
            display_on_lcd();
            // sending_to_arduino
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
    pin_motor = 1;
    Lcd_Out(2, 9, "Mode:MAN");
}

void automatic_mode(){
     mode_txt[0] = 'A';
     mode_txt[1] = 'U';
     mode_txt[2] = 'T';
     mode_txt[3] = 'O';
     mode_txt[4] = '\0';
    // Pump
    need_water = (temperature > seuil_temperature) || (humidity < seuil_humidity) || (soil_moisture < seuil_moisture);

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
            pin_motor = 0;
            pump_running = 1;
        }

        else if (need_water && !too_much){
            pump_running = 1;
            if (time_on == 0){
                init_timer1();
                time_on = 1;
                time = 0; // Reset timer for this irrigation cycle
            }
            pump_txt[5] = 'O';
            pump_txt[6] = 'N';
            pump_txt[7] = ' ';
            pump_txt[8] = '\0';
            pin_motor = 0;
        }

        else{
            if(pump_running){
                irrigation_duration += irrigation_session;
                pump_running = 0;
                time = 0;
                wait = 1;
            }
            pin_motor = 1;
            pump_txt[5] = 'O';
            pump_txt[6] = 'F';
            pump_txt[7] = 'F';
            pump_txt[8] = '\0';
        }
    }
    else{
        pump_running = 0;
        pin_motor = 1;
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