.include "hardware.inc"
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
    ldi r30,lo8(tri);
    ldi r31,hi8(tri);
    ldi r28,0xA2
    ldi r29,0x00
skip_restart:
    ldi r19,2;
    call spi_send_data;
    reti


start:
    ldi r17,(1<<DDC0)|(1<<DDC1)|(1<<DDC2)|(1<<DDC3)|(1<<DDC4)
    out DDRC,r17
    ldi r17,0
    out PORTC,r17
    ldi r17,0xff
    out DDRD,r17
    ldi r16,0b00110000;reset
    call send_char
    call delay
    call delay
    call send_char
    call delay
    call delay
    call send_char
    call delay
    call delay
    ldi r16,0b00111000;setup 8bits
    call send_char
    call delay

    ldi r16,0b00001000;display off
    call send_char
    call delay
    
    ldi r16,0b00000001;lcd_clear
    call send_char
    call delay

    ldi r16,0b00000110;shift cursor on write
    call send_char
    call delay

    ldi r16,0b00001100;display on
    call send_char
    call delay
    
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
    sei
    
    ldi r28,0
    ldi r29,0
done:
    ldi r16,0b01001000;
    call send_char
    ldi r16,0b01000010;
    call send_char
    ldi r16,0b01010010;
    call send_char
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
    call delay_handle
    call delay_handle
    ret


delay_handle:
  ldi r20,0xFF
delay_loop:
  nop
  dec r20
  brne delay_loop
  ret

spi_master_init:
  ;;2~SS SDCard  3:MOSI  4:MISO  5:SCK
  ldi r17, (1<<DDB2)|(1<<DDB3)|(1<<DDB5)   ;
  out DDRB,r17 ;DDRB
  ldi r17,(1<<SPE)|(1<<MSTR);
  out SPCR,r17 ;;SPI Control Register 
  ldi r17,(1<<SPI2X)
  out SPSR,r17
  sbi PORTC,4
  ret;

spi_send_data:
  cbi PORTC,4
spi_send_data_loop:
  lpm r21,Z+;
  out SPDR,r21 ;SPI data register
spi_wait_transmit:
  in r18,SPSR ;SPI Status register
  sbrs r18,SPIF ;check spi interrupt bit
  rjmp spi_wait_transmit;
  dec r19;
  brne spi_send_data_loop ;;remember to bring SS high after 16 clocks

  sbi PORTC,4
  ret


;;data
.include "tri.inc"
