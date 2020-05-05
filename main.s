.include "hardware.inc"
.include "mem.inc"
.org 0x0000
    jmp start
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer
    jmp timer

timer:
    sbiw r28,1     
    brcc skip_restart
    clc
    ldi r30,0x00;
    ldi r31,0x01;
    ldi r28,0xA2
    ldi r29,0x00
skip_restart:
    cbi PORTC,4
    call spi_send_data;
    call spi_send_data;
    sbi PORTC,4
    reti


start:
    ldi r17,(1<<DDC0)|(1<<DDC1)|(1<<DDC2)|(1<<DDC3)|(1<<DDC4)|(1<<DDC5)
    out DDRC,r17
    ldi r17,0b00111000
    out PORTC,r17
    ldi r17,0xff
    out DDRD,r17
    ldi r16,0b00110000;reset
    call send_char
    call send_char
    call send_char
    ldi r16,0b00111000;setup 8bits
    call send_char

    ldi r16,0b00001000;display off
    call send_char
    
    ldi r16,0b00000001;lcd_clear
    call send_char

    ldi r16,0b00000110;shift cursor on write
    call send_char

    ldi r16,0b00001100;display on
    call send_char
    
    sbi PORTC, 0
    call spi_master_init;

    ;setup timer for interrupts
    

    ldi r17,(1<<WGM01)
    out TCCR0A,r17
    ldi r17,(1<<CS01)
    out TCCR0B,r17
    ldi r17,82
    out OCR0A,r17
    ldi r17,(1<<OCIE0A)
    sts TIMSK0,r17


    ldi r17,0
    mov r0,r17
    ldi r17,0
    mov r1,r17
    ldi r17,0x46
    mov r2,r17
    ldi r17,0x01
    mov r3,r17
    ldi r17,0x00
    mov r4,r17
    call load_table


    ldi r30,0x00;
    ldi r31,0x01;
    ldi r28,0xA2
    ldi r29,0x00



    

done:
    nop
    rjmp done



send_char:
    out PORTD,r16
    sbi PORTC,2
    call delay
    cbi PORTC,2
    call delay
    ret


delay:
    call delay_handle
    call delay_handle
    call delay_handle
    call delay_handle
    call delay_handle
    call delay_handle
    ret


delay_handle:
  ldi r20,0xff
delay_loop:
  nop
  dec r20
  brne delay_loop
  ret

spi_master_init:
  ;;2:SS  3:MOSI  4:MISO  5:SCK
  ldi r17, (1<<DDB2)|(1<<DDB3)|(1<<DDB5)   ;
  out DDRB,r17 ;DDRB
  ldi r17,(1<<SPE)|(1<<MSTR);
  out SPCR,r17 ;;SPI Control Register 
  ;;ldi r17,(1<<SPI2X)
  ;;out SPSR,r17
  sbi PORTC,4
  ret;

spi_send_data:
  ld r21,Z+;
  out SPDR,r21 ;SPI data register
spi_wait_transmit:
  in r18,SPSR ;SPI Status register
  sbrs r18,SPIF ;check spi interrupt bit
  rjmp spi_wait_transmit;
  ret



spi_send_data_rom:
  in r18,SPSR ;SPI Status register
  sbrs r18,SPIF ;check spi interrupt bit
  rjmp spi_send_data_rom;
  ret




load_table:
   cli
   movw r30,r0 ;use r0 and r1 pass in rom table data start 
   movw r28,r2 ;use r2 and r3 pass in rom table data end
   sbrs r4,0
   rjmp table_one
   ldi r26,lo8(table2);
   ldi r27,hi8(table2);
   rjmp finish_rom_table_start
   table_one:
   ldi r26,0x00;
   ldi r27,0x01;
   finish_rom_table_start:
   ldi r17,0
   out DDRD,r17
   ldi r17,0
   out PORTD,r17
   cbi PORTC,5
   cbi DDRC,5

read_rom_loop:
   out SPDR,r31 ;addr high to spi
   call spi_send_data_rom
   out SPDR,r30 ;addr low to spi
   call spi_send_data_rom 
   cbi PORTC,1 ;RCLK low
   call delay
   sbi PORTC,1 ;RCLK high
   call delay
   cbi PORTC,1 ;RCLK low
   call delay
   call delay
   call delay
   call delay
   in r18,PIND ;read data from the pins
   st X+,r18  ;store data wavetable
   adiw r30,1 ;add one to rom location
   cp r28,r30
   brne read_rom_loop
   cp r29,r31
   brne read_rom_loop
   sbi PORTC,5
   sbi DDRC,5
   ldi r17,0xff
   out DDRD,r17
   ldi r17,0
   out PORTD,r17
   sei
   ret




