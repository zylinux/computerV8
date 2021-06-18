/**********basic headers**********/
`include "../include/nettype.h"
`include "../include/stddef.h"
`include "../include/global_config.h"
/**********chip module headers**********/
`include "../../cpu/include/cpu.h"
`include "../../bus/include/bus.h"
`include "../../io/rom/include/rom.h"
`include "../../io/timer/include/timer.h"
`include "../../io/uart/include/uart.h"
`include "../../io/gpio/include/gpio.h"
//chip module
module chip (
	//clk and reset
	input  wire						 clk,
	input  wire						 clk_,
	input  wire						 reset
	//UART
`ifdef IMPLEMENT_UART //UART
	, input	 wire					 uart_rx	  // UART rx pin
	, output wire					 uart_tx	  // UART tx pin
`endif
	//gpio
`ifdef IMPLEMENT_GPIO // GPIO
`ifdef GPIO_IN_CH //4
	, input wire [`GPIO_IN_CH-1:0]	 gpio_in	  //input
`endif
`ifdef GPIO_OUT_CH //18
	, output wire [`GPIO_OUT_CH-1:0] gpio_out	  //output
`endif
`ifdef GPIO_IO_CH //16
	, inout wire [`GPIO_IO_CH-1:0]	 gpio_io	  //input and output
`endif
`endif
);

	//masters
	wire [`WordDataBus] m_rd_data;
	wire				m_rdy_;
	// 0 IF Stage
	wire				m0_req_;				  		//0 request
	wire [`WordAddrBus] m0_addr;				//0 address
	wire				m0_as_;					  	//0 address select
	wire				m0_rw;					  	//0 write/read
	wire [`WordDataBus] m0_wr_data;			//0 write data
	wire				m0_grnt_;				  	//0 grant
	// 1 MEM Stage
	wire				m1_req_;
	wire [`WordAddrBus] m1_addr;
	wire				m1_as_;
	wire				m1_rw;
	wire [`WordDataBus] m1_wr_data;
	wire				m1_grnt_;
	// 2 unused
	wire				m2_req_;
	wire [`WordAddrBus] m2_addr;
	wire				m2_as_;
	wire				m2_rw;
	wire [`WordDataBus] m2_wr_data;
	wire				m2_grnt_;
	// 3 unused
	wire				m3_req_;
	wire [`WordAddrBus] m3_addr;
	wire				m3_as_;
	wire				m3_rw;
	wire [`WordDataBus] m3_wr_data;
	wire				m3_grnt_;

	//slaves
	wire [`WordAddrBus] s_addr;				// slave address
	wire				s_as_;					  	// slave address select
	wire				s_rw;					  		// slave write/read
	wire [`WordDataBus] s_wr_data;			// slave write data
	// 0 to ROM   0x0000_0000 0x1FFF_FFFF
	wire [`WordDataBus] s0_rd_data;			// 0 slave read data
	wire				s0_rdy_;				  		// 0 ready to access
	wire				s0_cs_;					  	// 0 cs to access
	// 1 to SPM   0x2000_0000 0x3FFF_FFFF
	wire [`WordDataBus] s1_rd_data;
	wire				s1_rdy_;
	wire				s1_cs_;
	// 2 to TIMER 0x4000_0000 0x5FFF_FFFF
	wire [`WordDataBus] s2_rd_data;
	wire				s2_rdy_;
	wire				s2_cs_;
	// 3 to UART  0x6000_0000 0x7FFF_FFFF
	wire [`WordDataBus] s3_rd_data;
	wire				s3_rdy_;
	wire				s3_cs_;
	// 4 to GPIO  0x8000_0000 0x9FFF_FFFF
	wire [`WordDataBus] s4_rd_data;
	wire				s4_rdy_;
	wire				s4_cs_;
	// 5 unused   0xA000_0000 0xBFFF_FFFF
	wire [`WordDataBus] s5_rd_data;
	wire				s5_rdy_;
	wire				s5_cs_;
	// 6 unused   0xC000_0000 0xDFFF_FFFF
	wire [`WordDataBus] s6_rd_data;
	wire				s6_rdy_;
	wire				s6_cs_;
	// 7 unused   0xE000_0000 0xFFFF_FFFF
	wire [`WordDataBus] s7_rd_data;
	wire				s7_rdy_;
	wire				s7_cs_;
	//timer
	wire				   irq_timer;			  // timer irq
	wire				   irq_uart_rx;			  // UART IRQ rx
	wire				   irq_uart_tx;			  // UART IRQ tx
	wire [`CPU_IRQ_CH-1:0] cpu_irq;				  // CPU IRQ

	//irqs
	assign cpu_irq = {{`CPU_IRQ_CH-3{`LOW}},
					  irq_uart_rx, irq_uart_tx, irq_timer};

	/*********************MASTER********************/
	//CPU
	cpu cpu (
		//clk and reset
		.clk			 (clk),
		.clk_			 (clk_),
		.reset			 (reset),
		// IF Stage
		.if_bus_rd_data	 (m_rd_data),
		.if_bus_rdy_	 (m_rdy_),
		.if_bus_grnt_	 (m0_grnt_),
		.if_bus_req_	 (m0_req_),
		.if_bus_addr	 (m0_addr),
		.if_bus_as_		 (m0_as_),
		.if_bus_rw		 (m0_rw),
		.if_bus_wr_data	 (m0_wr_data),
		// MEM Stage
		.mem_bus_rd_data (m_rd_data),
		.mem_bus_rdy_	 (m_rdy_),
		.mem_bus_grnt_	 (m1_grnt_),
		.mem_bus_req_	 (m1_req_),
		.mem_bus_addr	 (m1_addr),
		.mem_bus_as_	 (m1_as_),
		.mem_bus_rw		 (m1_rw),
		.mem_bus_wr_data (m1_wr_data),
		//irq
		.cpu_irq		 (cpu_irq)
	);

	//master 2 unused
	assign m2_addr	  = `WORD_ADDR_W'h0;
	assign m2_as_	  = `DISABLE_;
	assign m2_rw	  = `READ;
	assign m2_wr_data = `WORD_DATA_W'h0;
	assign m2_req_	  = `DISABLE_;
	//master 3 unused
	assign m3_addr	  = `WORD_ADDR_W'h0;
	assign m3_as_	  = `DISABLE_;
	assign m3_rw	  = `READ;
	assign m3_wr_data = `WORD_DATA_W'h0;
	assign m3_req_	  = `DISABLE_;

	/*********************SLAVE********************/
	//slave 0 to rom
	rom rom (
		//Clock & Reset
		.clk			 (clk),
		.reset			 (reset),
		//Bus Interface
		.cs_			 (s0_cs_),
		.as_			 (s_as_),
		.addr			 (s_addr[`RomAddrLoc]),
		.rd_data		 (s0_rd_data),
		.rdy_			 (s0_rdy_)
	);

	//slave 1 to Scratch Pad Memory
	assign s1_rd_data = `WORD_DATA_W'h0;
	assign s1_rdy_	  = `DISABLE_;

	//slave 2 to timer
`ifdef IMPLEMENT_TIMER
	timer timer (
		.clk			 (clk),
		.reset			 (reset),
		//bus related
		.cs_			 (s2_cs_),				  		//slave 2 cs
		.as_			 (s_as_),				  		//slave address select
		.addr			 (s_addr[`TimerAddrLoc]), 	//slave address
		.rw				 (s_rw),				  		//slave Read / Write
		.wr_data		 (s_wr_data),			  		//slave write data
		.rd_data		 (s2_rd_data),			  		//slave 2 read data
		.rdy_			 (s2_rdy_),				  		//slave 2 ready
		//timer irq
		.irq			 (irq_timer)
	 );
`else
	assign s2_rd_data = `WORD_DATA_W'h0;
	assign s2_rdy_	  = `DISABLE_;
	assign irq_timer  = `DISABLE;
`endif
	//slave 3 to UART
`ifdef IMPLEMENT_UART
	uart uart (
		.clk			 (clk),
		.reset			 (reset),
		//bus related
		.cs_			 (s3_cs_),						//slave 3 cs
		.as_			 (s_as_),				  		//slave address select
		.rw				 (s_rw),				  		//slave Read / Write
		.addr			 (s_addr[`UartAddrLoc]), 	//slave address
		.wr_data		 (s_wr_data),			  		//slave write data
		.rd_data		 (s3_rd_data),			  		//slave 3 read data
		.rdy_			 (s3_rdy_),				  		//slave 3 ready
		//UART irq
		.irq_rx			 (irq_uart_rx),
		.irq_tx			 (irq_uart_tx),
		//rx and tx pin
		.rx				 (uart_rx),
		.tx				 (uart_tx)
	);
`else
	assign s3_rd_data  = `WORD_DATA_W'h0;
	assign s3_rdy_	   = `DISABLE_;
	assign irq_uart_rx = `DISABLE;
	assign irq_uart_tx = `DISABLE;
`endif

	//slave 4 to GPIO
`ifdef IMPLEMENT_GPIO
	gpio gpio (
		.clk			 (clk),
		.reset			 (reset),
		//bus related
		.cs_			 (s4_cs_),				 		//slave 4 cs
		.as_			 (s_as_),				 		//slave address select
		.rw				 (s_rw),				 		// Read / Write
		.addr			 (s_addr[`GpioAddrLoc]), 	//slave address
		.wr_data		 (s_wr_data),			 		//slave write data
		.rd_data		 (s4_rd_data),			 		//slave 4 read data
		.rdy_			 (s4_rdy_)				 		//slave 4 ready
		//gpio pin
`ifdef GPIO_IN_CH
		, .gpio_in		 (gpio_in)
`endif
`ifdef GPIO_OUT_CH
		, .gpio_out		 (gpio_out)
`endif
`ifdef GPIO_IO_CH
		, .gpio_io		 (gpio_io)
`endif
	);
`else
	assign s4_rd_data = `WORD_DATA_W'h0;
	assign s4_rdy_	  = `DISABLE_;
`endif

	//slave 5 unused
	assign s5_rd_data = `WORD_DATA_W'h0;
	assign s5_rdy_	  = `DISABLE_;

	//slave 6 unused
	assign s6_rd_data = `WORD_DATA_W'h0;
	assign s6_rdy_	  = `DISABLE_;

	//slave 7 unused
	assign s7_rd_data = `WORD_DATA_W'h0;
	assign s7_rdy_	  = `DISABLE_;

	/**********BUS**********/
	bus bus (
		.clk			 (clk),
		.reset			 (reset),
		/**********MASTER**********/
		//shared read signal
		.m_rd_data		 (m_rd_data),			 //read data
		.m_rdy_			 (m_rdy_),				 //ready
		//master 0
		.m0_req_		 (m0_req_),				 	//0 request
		.m0_addr		 (m0_addr),				 	//0 address
		.m0_as_			 (m0_as_),				//0 address select
		.m0_rw			 (m0_rw),				//0 write /read
		.m0_wr_data		 (m0_wr_data),			//0 write data
		.m0_grnt_		 (m0_grnt_),			//0 grant
		//master 1
		.m1_req_		 (m1_req_),				 	//1 request
		.m1_addr		 (m1_addr),				 	//1 address
		.m1_as_			 (m1_as_),				//1 address select
		.m1_rw			 (m1_rw),				//1 write /read
		.m1_wr_data		 (m1_wr_data),			//1 write data
		.m1_grnt_		 (m1_grnt_),			//1 grant
		//master 2
		.m2_req_		 (m2_req_),				 	//2 request
		.m2_addr		 (m2_addr),				 	//2 address
		.m2_as_			 (m2_as_),				//2 address select
		.m2_rw			 (m2_rw),				//2 write /read
		.m2_wr_data		 (m2_wr_data),			//2 write data
		.m2_grnt_		 (m2_grnt_),			//2 grant
		//master 3
		.m3_req_		 (m3_req_),				 	//3 request
		.m3_addr		 (m3_addr),				 	//3 address
		.m3_as_			 (m3_as_),				//3 address select
		.m3_rw			 (m3_rw),				//3 write /read
		.m3_wr_data		 (m3_wr_data),			//3 write data
		.m3_grnt_		 (m3_grnt_),			//3 grant
		/**********sLAVE**********/
		//shared write signal
		.s_addr			 (s_addr),				//address
		.s_as_			 (s_as_),				//address select
		.s_rw			 (s_rw),				 		//wirte/read
		.s_wr_data		 (s_wr_data),			//write data
		//slave 0
		.s0_rd_data		 (s0_rd_data),			//slave 0 read data
		.s0_rdy_		 (s0_rdy_),				 	//slave 0 ready
		.s0_cs_			 (s0_cs_),				//slave 0 cs
		//slave 1
		.s1_rd_data		 (s1_rd_data),			//slave 1 read data
		.s1_rdy_		 (s1_rdy_),				 	//slave 1 ready
		.s1_cs_			 (s1_cs_),				//slave 1 cs
		//slave 2
		.s2_rd_data		 (s2_rd_data),			//slave 2 read data
		.s2_rdy_		 (s2_rdy_),				 	//slave 2 ready
		.s2_cs_			 (s2_cs_),				//slave 2 cs
		//slave 3
		.s3_rd_data		 (s3_rd_data),			//slave 3 read data
		.s3_rdy_		 (s3_rdy_),				 	//slave 3 ready
		.s3_cs_			 (s3_cs_),				//slave 3 cs
		//slave 4
		.s4_rd_data		 (s4_rd_data),			//slave 4 read data
		.s4_rdy_		 (s4_rdy_),				 	//slave 4 ready
		.s4_cs_			 (s4_cs_),				//slave 4 cs
		//slave 5
		.s5_rd_data		 (s5_rd_data),			//slave 5 read data
		.s5_rdy_		 (s5_rdy_),				 	//slave 5 ready
		.s5_cs_			 (s5_cs_),				//slave 5 cs
		//slave 6
		.s6_rd_data		 (s6_rd_data),			//slave 6 read data
		.s6_rdy_		 (s6_rdy_),				 	//slave 6 ready
		.s6_cs_			 (s6_cs_),				//slave 6 cs
		//slave 7
		.s7_rd_data		 (s7_rd_data),			//slave 7 read data
		.s7_rdy_		 (s7_rdy_),				 	//slave 7 ready
		.s7_cs_			 (s7_cs_)				//slave 7 cs
	);

endmodule
