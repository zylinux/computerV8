;;; ram address
LOCATE	0x20000000

;;; define
GPIO_BASE_ADDR_H	EQU	0x8000						;GPIO Base Address High
GPIO_IN_OFFSET		EQU	0x0								;GPIO Input Port Register Offset
GPIO_OUT_OFFSET		EQU	0x4								;GPIO Output Port Register Offset
;;;data to show from 0-9
7SEG_DATA_0			EQU	0xC0
7SEG_DATA_1			EQU	0xF9
7SEG_DATA_2			EQU	0xA4
7SEG_DATA_3			EQU	0xB0
7SEG_DATA_4			EQU	0x99
7SEG_DATA_5			EQU	0x92
7SEG_DATA_6			EQU	0x82
7SEG_DATA_7			EQU	0xF8
7SEG_DATA_8			EQU	0x80
7SEG_DATA_9			EQU	0x90

	XORR	r0,r0,r0
;;; set function call
	ORI		r0,r1,high(CONV_NUM_TO_7SEG_DATA)
	SHLLI	r1,r1,16
	ORI		r1,r1,low(CONV_NUM_TO_7SEG_DATA)	;r1=CONV_NUM_TO_7SEG_DATA

	ORI		r0,r2,high(SET_GPIO_OUT)
	SHLLI	r2,r2,16
	ORI		r2,r2,low(SET_GPIO_OUT)						;r2=SET_GPIO_OUT

	ORI		r0,r3,high(WAIT_PUSH_SW)
	SHLLI	r3,r3,16
	ORI		r3,r3,low(WAIT_PUSH_SW)						;r3=WAIT_PUSH_SW

;;; reset count
_COUNTER_RESET:
	ORI		r0,r4,0														;r4=0 this is the count

_7SEG_COUNTER_LOOP:
;;; light up
	ORR		r0,r4,r16													;r16=r4 paramter
	CALL	r1																;call CONV_NUM_TO_7SEG_DATA
	ANDR	r0,r0,r0													;NOP

	ORR		r0,r17,r16												;r16=r17 paramter
	CALL	r2																;call SET_GPIO_OUT
	ANDR	r0,r0,r0													;NOP

	CALL	r3																;call WAIT_PUSH_SW
	ANDR	r0,r0,r0													;NOP

_COUNT_UP:
	ADDUI	r4,r4,1														;each time plus 1
	ORI		r0,r5,10													;r5=10
	BE		r5,r4,_COUNTER_RESET							;if r4==r5 means over 10 reset
	ANDR	r0,r0,r0													;NOP
	BE		r0,r0,_7SEG_COUNTER_LOOP
	ANDR	r0,r0,r0													;NOP


CONV_NUM_TO_7SEG_DATA:
	;; get low bits
	ORR		r0,r16,r18					;r18=r16
	XORR	r17,r17,r17					;r17=0 -Return Value clear
	XORR	r20,r20,r20					;r20=0
	;; 10
	ORI		r0,r21,10						;r21=10
_SUB10:
	BUGT	r18,r21,_CHECK_0		;if r18<r21(it means r18<10) jump to _CHECK_0
	ANDR	r0,r0,r0						;NOP
	ADDUI	r18,r18,-10
	ADDUI	r20,r20,1
	BE		r0,r0,_SUB10				;r21<r18 jump to _SUB10
	ANDR	r0,r0,r0						;NOP

_CHECK_0:
	ORI		r0,r21,0						;r21=0
	BNE		r18,r21,_CHECK_1		;if(r18!=0)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_0	;load 0 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_1:
	ORI		r0,r21,1						;r21=1
	BNE		r18,r21,_CHECK_2		;if(r18!=1)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_1	;load 1 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0					;NOP

_CHECK_2:
	ORI		r0,r21,2						;r21=2
	BNE		r18,r21,_CHECK_3		;if(r18!=2)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_2	;load 2 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_3:
	ORI		r0,r21,3						;r21=3
	BNE		r18,r21,_CHECK_4		;if(r18!=3)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_3	;load 3 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_4:
	ORI		r0,r21,4						;r21=4
	BNE		r18,r21,_CHECK_5		;if(r18!=4)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_4	;load 4 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_5:
	ORI		r0,r21,5						;r21=5
	BNE		r18,r21,_CHECK_6		;if(r18!=5)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_5	;load 5 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_6:
	ORI		r0,r21,6						;r21=6
	BNE		r18,r21,_CHECK_7		;if(r18!=6)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_6	;load 6 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_7:
	ORI		r0,r21,7						;r21=7
	BNE		r18,r21,_CHECK_8		;if(r18!=7)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_7	;load 7 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_8:
	ORI		r0,r21,8						;r21=8
	BNE		r18,r21,_CHECK_9		;if(r18!=8)
	ANDR	r0,r0,r0						;NOP
	ORI		r0,r22,7SEG_DATA_8	;load 8 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_CHECK_9:
	ORI		r0,r22,7SEG_DATA_9	;load 9 to show
	BE		r0,r0,_SET_RETURN_VALUE
	ANDR	r0,r0,r0						;NOP

_SET_RETURN_VALUE:
	ORR		r17,r22,r17					;r17=r22 load x to show
	BE		r0,r0,_CONV_NUM_TO_7SEG_DATA_RETURN
	ANDR	r0,r0,r0						;NOP

_CONV_NUM_TO_7SEG_DATA_RETURN:
	JMP		r31									;return back to CALL r1
	ANDR	r0,r0,r0						;NOP


SET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	STW		r17,r16,GPIO_OUT_OFFSET
_SET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP


WAIT_PUSH_SW:
	ORI		r0,r16,GPIO_BASE_ADDR_H
	SHLLI	r16,r16,16
_WAIT_PUSH_SW_ON:
	LDW		r16,r17,GPIO_IN_OFFSET
	BE		r0,r17,_WAIT_PUSH_SW_ON
	ANDR	r0,r0,r0					;NOP
_WAIT_PUSH_SW_OFF:
	LDW		r16,r17,GPIO_IN_OFFSET
	BNE		r0,r17,_WAIT_PUSH_SW_OFF
	ANDR	r0,r0,r0					;NOP
_WAIT_PUSH_SW_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP
