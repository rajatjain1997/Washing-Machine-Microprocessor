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
	* Port B: 
		0. Agitator
		1. Wash Tub
		2. Buzzer 3
		3. Buzzer 2
		4. Buzzer 1
	* Port C:
		0. Seven Seg Display
		1. Seven Seg Display
		2. Seven Seg Display
		3. Seven Seg Display
		4. Gate of counter 0
		5. Gate of counter 1
		6. Gate of counter 3
* _8259_
	* IR
		0. Counter 0
		1. Counter 1
		2. Counter 2
* _8253_
	* CLK = ??
