;;; adjust RAM address
	LOCATE	0x20000000

;;; define
GPIO_BASE_ADDR_H	EQU	0x8000		;GPIO Base Address High
GPIO_OUT_OFFSET		EQU	0x4				;GPIO Output Port Register Offset

;;; LED
	XORR	r0,r0,r0
	ORI		r0,r1,GPIO_BASE_ADDR_H	;GPIO Base Address����16�r�b�g��r1�ɃZ�b�g
	SHLLI	r1,r1,16								;left shit 16 bits set r1 to 0x80000000
	ORI		r0,r2,0x2								;set value 0x2 to high 16 bits to r2
	SHLLI	r2,r2,16								;left shit 16 bits
	ORI		r2,r2,0xFFFF						;set r2 to 0x00002fff on my board only led[1] on light
	STW		r1,r2,GPIO_OUT_OFFSET		;GPIO Output Port offset is 4, kind of doing 0x80000004=0x00002fff


;;; LOOP
LOOP:
	BE		r0,r0,LOOP							;LOOP
	ANDR	r0,r0,r0								;NOP
