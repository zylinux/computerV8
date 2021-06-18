;;; adjust RAM address
	LOCATE	0x20000000

;;; define
GPIO_BASE_ADDR_H	EQU	0x8000			;GPIO Base Address High
GPIO_OUT_OFFSET		EQU	0x4				;GPIO Data Register Offset

GPIO_DATA_7SEG1_1	EQU	0x00F9
GPIO_DATA_7SEG2_0	EQU	0xC000

;;;
	XORR	r0,r0,r0
	ORI		r0,r1,GPIO_BASE_ADDR_H		;GPIO Base Address
	SHLLI	r1,r1,16

	ORI		r0,r2,GPIO_DATA_7SEG1_1
	ORI		r2,r2,GPIO_DATA_7SEG2_0

	STW		r1,r2,GPIO_OUT_OFFSET

;; loop
LOOP:
	BE		r0,r0,LOOP
	ANDR	r0,r0,r0					;NOP
