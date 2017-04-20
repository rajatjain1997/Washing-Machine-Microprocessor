# Washing-Machine-Microprcessor

## Addresses
* _Memory_
	* RAM: 00000h - 00FFFh
	* ROM: FF000h - FFFFFh
* _IO_
	* 8255:	00h - 07h 
	* 8253: 08h - 0Fh
	* 8259: 10h - 12h

## Interfacing
* _8255_
	* Port A:
		1. Start
		2. Stop
		3. Load
		4. Resume
		5. Door Lock
		6. Water Max
		7. Water Min
	* Port B: 
		1. Agitator
		2. Wash Tub
		3. Buzzer 3
		4. Buzzer 2
		5. Buzzer 1
	* Port C:
		1. Seven Seg Display
		2. Seven Seg Display
		3. Seven Seg Display
		4. Seven Seg Display
		5. Gate of counter 0
		6. Gate of counter 1
		7. Gate of counter 3
* _8259_
	* IR
		1. Counter 0
		2. Counter 1
		3. Counter 2
* _8253_
	* CLK = 1 Hz (1 count/second)
