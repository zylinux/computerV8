;;; adjust RAM address
LOCATE	0x20000000

;;; define
TIMER_BASE_ADDR_H			EQU	0x4000		;Timer Base Address High
TIMER_CTRL_OFFSET			EQU	0x0				;Timer Control Register Offset
TIMER_INTR_OFFSET			EQU	0x4				;Timer Interrupt Register Offset
TIMER_EXPIRE_OFFSET		EQU	0x8				;Timer Expiration Register Offset
GPIO_BASE_ADDR_H			EQU	0x8000		;GPIO Base Address High
GPIO_OUT_OFFSET				EQU	0x4				;GPIO Data Register Offset


	XORR	r0,r0,r0					;r0 = 0

	ORI		r0,r1,high(SET_GPIO_OUT)
	SHLLI	r1,r1,16
	ORI		r1,r1,low(SET_GPIO_OUT)			;SET_GPIO_OUT to r1

	ORI		r0,r2,high(GET_GPIO_OUT)
	SHLLI	r2,r2,16
	ORI		r2,r2,low(GET_GPIO_OUT)			;GET_GPIO_OUT to r2

;;; LED all off
	ORI		r0,r16,0x1
	SHLLI	r16,r16,16
	ORI		r16,r16,0xFFFF
	CALL	r1													;call SET_GPIO_OUT
	ANDR	r0,r0,r0

;;; setup exception handler to special control register
	ORI		r0,r3,high(EXCEPT_HANDLER)	; high 16bits
	SHLLI	r3,r3,16
	ORI		r3,r3,low(EXCEPT_HANDLER)		; low 16bits
	WRCR	r3,c4

;;; Interrupt initialization
	;; Mask
	ORI		r0,r3,0xFE									;Interrupt Mask
	WRCR	r3,c6												;write control register c6

	;; Status
	ORI		r0,r3,0x2										;set up Status, Interrupt enable and cpu execution mode(IE:1,EM:0)
	WRCR	r3,c0												;write control register c0

;;; timer initialization
	;; Expiration Register
	ORI		r0,r3,TIMER_BASE_ADDR_H			;Timer Base Address high 16bits to r3
	SHLLI	r3,r3,16
	ORI		r0,r4,0x98									;high 16bits expire count 0x98
	SHLLI	r4,r4,16
	ORI		r4,r4,0x9680								;low 16bits expire count  0x9680 1second with 10M clk
	STW		r3,r4,TIMER_EXPIRE_OFFSET		;setup expire count
	;; Control Register
	ORI		r0,r4,0x3										;Periodic:1, Start:1
	STW		r3,r4,TIMER_CTRL_OFFSET			;setup Timer Control Register, kick off the timer now

;; LOOP
LOOP:
	BE		r0,r0,LOOP									;LOOP
	ANDR	r0,r0,r0										;NOP

;;;led set
SET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	STW		r17,r16,GPIO_OUT_OFFSET
_SET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP
;;;led get
GET_GPIO_OUT:
	ORI		r0,r17,GPIO_BASE_ADDR_H
	SHLLI	r17,r17,16
	LDW		r17,r16,GPIO_OUT_OFFSET
_GET_GPIO_OUT_RETURN:
	JMP		r31
	ANDR	r0,r0,r0					;NOP


;; exception handler when the timer expire, it will be called
EXCEPT_HANDLER:
	;; clear Interrupt flags
	ORI		r0,r24,TIMER_BASE_ADDR_H	;Timer Base Address high 16bits to r24
	SHLLI	r24,r24,16
	STW		r24,r0,TIMER_INTR_OFFSET	;clear Interrupt

	;;  LED reverse
	CALL	r2
	ANDR	r0,r0,r0
	ORI		r0,r24,1
	SHLLI	r24,r24,16
	XORR	r16,r24,r16
	CALL	r1
	ANDR	r0,r0,r0

	;; stall delay judgement
	RDCR	c5,r24										;read special control register c5 to r24
	ANDI	r24,r24,0x8
	BE		r0,r24,GOTO_EXRT					;check bit[3] delay flag,if it is 0.means no delay happened
	ANDR	r0,r0,r0									;NOP
	RDCR	c3,r24										;here means check bit[3] delay flag is 1 (delay happened, return address need to -4) read special control register c3 EPC to r24
	ADDUI	r24,r24,-4								;EPC-4
	WRCR	r24,c3										;write a new value to special control register c3 EPC
GOTO_EXRT:
	;; return ret
	EXRT
	ANDR	r0,r0,r0									;NOP
