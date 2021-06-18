;;; define
UART_BASE_ADDR_H	EQU	0x6000			;UART Base Address High
UART_STATUS_OFFSET	EQU	0x0				;UART Status Register Offset
UART_DATA_OFFSET	EQU	0x4				;UART Data Register Offset
UART_RX_INTR_MASK	EQU	0x1				;UART Receive Interrupt Mask
UART_TX_INTR_MASK	EQU	0x2				;UART Transmit Interrupt Mask


	XORR	r0,r0,r0

	ORI		r0,r1,high(CLEAR_BUFFER)	;CLEAR_BUFFER high r16
	SHLLI	r1,r1,16
	ORI		r1,r1,low(CLEAR_BUFFER)		;CLEAR_BUFFER low r16

	ORI		r0,r2,high(SEND_CHAR)			;SEND_CHAR high r16
	SHLLI	r2,r2,16
	ORI		r2,r2,low(SEND_CHAR)			;SEND_CHAR low r16

;;; UART clear buffer
	CALL	r1												;CLEAR_BUFFER
	ANDR	r0,r0,r0									;NOP

;;; send letters

	ORI		r0,r16,'H'								;r16 'H'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'e'								;r16 'e'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'l'								;r16 'l'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'l'								;r16 'l'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'o'								;r16 'o'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,','								;r16 ','
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'w'								;r16 'w'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'o'								;r16 'o'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'r'								;r16 'r'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'l'								;r16 'l'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'d'								;r16 'd'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

	ORI		r0,r16,'.'								;r16 '.'
	CALL	r2												;SEND_CHAR
	ANDR	r0,r0,r0									;NOP

;;; loop
LOOP:
	BE		r0,r0,LOOP								;loop
	ANDR	r0,r0,r0									;NOP

CLEAR_BUFFER:
	ORI		r0,r16,UART_BASE_ADDR_H			;UART Base Address high to r16
	SHLLI	r16,r16,16

_CHECK_UART_STATUS:
	LDW		r16,r17,UART_STATUS_OFFSET	;get STATUS

	ANDI	r17,r17,UART_RX_INTR_MASK
	BE		r0,r17,_CLEAR_BUFFER_RETURN	;Receive Interrupt bit _CLEAR_BUFFER_RETURN
	ANDR	r0,r0,r0					;NOP

_RECEIVE_DATA:
	LDW		r16,r17,UART_DATA_OFFSET		;read data and clear buffer

	LDW		r16,r17,UART_STATUS_OFFSET	;get STATUS
	XORI	r17,r17,UART_RX_INTR_MASK
	STW		r16,r17,UART_STATUS_OFFSET	;clear Receive Interrupt bit

	BNE		r0,r0,_CHECK_UART_STATUS		;return _CHECK_UART_STATUS
	ANDR	r0,r0,r0										;NOP
_CLEAR_BUFFER_RETURN:
	JMP		r31													;return ret
	ANDR	r0,r0,r0										;NOP


SEND_CHAR:
	ORI		r0,r17,UART_BASE_ADDR_H			;UART Base Address high to r16
	SHLLI	r17,r17,16
	STW		r17,r16,UART_DATA_OFFSET		;send r16

_WAIT_SEND_DONE:
	LDW		r17,r18,UART_STATUS_OFFSET	;get STATUS
	ANDI	r18,r18,UART_TX_INTR_MASK
	BE		r0,r18,_WAIT_SEND_DONE
	ANDR	r0,r0,r0

	LDW		r17,r18,UART_STATUS_OFFSET
	XORI	r18,r18,UART_TX_INTR_MASK
	STW		r17,r18,UART_STATUS_OFFSET	;clear Transmit Interrupt bit

	JMP		r31													;return ret
	ANDR	r0,r0,r0										;NOP
