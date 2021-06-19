;;; adjust RAM address
	LOCATE	0x20000000

;;; define
GPIO_BASE_ADDR_H	EQU	0x8000			;GPIO Base Address High
GPIO_OUT_OFFSET		EQU	0x4					;GPIO Data Register Offset

GPIO_DATA_7SEG1_1	EQU	0xFF82			;82(1-0000010) sel 0 and display 6

;;; set
	XORR	r0,r0,r0
	ORI		r0,r1,GPIO_BASE_ADDR_H
	SHLLI	r1,r1,16									;GPIO Base Address to r1

	ORI		r0,r2,GPIO_DATA_7SEG1_1		;r2=0xFF82 it will show all 8 sel with number 6 on development board

	STW		r1,r2,GPIO_OUT_OFFSET			;(r1+GPIO_OUT_OFFSET) = r2

;; loop
LOOP:
	BE		r0,r0,LOOP
	ANDR	r0,r0,r0									;NOP
