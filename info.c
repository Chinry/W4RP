#ifndef F_CPU
#define F_CPU 16000000
#endif
#ifndef __AVR_ATmega328__
#define __AVR_ATmega328__
#endif
#include <avr/io.h>
#include <stdio.h>
#include <avr/interrupt.h>
#include <avr/eeprom.h>
#include <avr/sleep.h>

#include "avr_mcu_section.h"
AVR_MCU(F_CPU, "atmega328");
AVR_MCU_VCD_FILE("my_trace_file.vcd", 10000000);

const struct avr_mmcu_vcd_trace_t _mytrace[]  _MMCU_ = {
	{ AVR_MCU_VCD_SYMBOL("PORTB"), .what = (void*)&PORTB, },	
	{ AVR_MCU_VCD_SYMBOL("SPDR"), .what = (void*)&SPDR, },	
};
//AVR_MCU_VCD_PORT_PIN('B', 3, "mosi");




//void func(){}

