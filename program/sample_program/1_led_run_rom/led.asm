;;; symbol define
GPIO_BASE_ADDR_H	EQU	0x8000		;GPIO Base Address High
GPIO_OUT_OFFSET		EQU	0x4				;GPIO Output Port Register Offset

;;; LED on
	XORR	r0,r0,r0
	ORI		r0,r1,GPIO_BASE_ADDR_H	;GPIO Base Address high 16 bits to r1
	SHLLI	r1,r1,16								;left shit 16 bits set r1 to 0x80000000
	ORI		r0,r2,0x0								;set value 0x0 to high 16 bits to r2
	SHLLI	r2,r2,16								;left shit 16 bits
	ORI		r2,r2,0x3FFF						;set r2 to 0x00003fff on my board all 4 leds light
	STW		r1,r2,GPIO_OUT_OFFSET		;GPIO Output Port offset is 4, kind of doing 0x80000004=0x00003fff

LOOP:
	BE		r0,r0,LOOP							;return LOOP
	ANDR	r0,r0,r0								;NOP
