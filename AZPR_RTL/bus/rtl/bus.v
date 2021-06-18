/**********basic headers**********/
`include "../../top/include/nettype.h"
`include "../../top/include/stddef.h"
`include "../../top/include/global_config.h"
/**********bus header**********/
`include "../include/bus.h"
/**********bus module**********/
module bus (
	input  wire				   clk,
	input  wire				   reset,
	/**********master **********/
	//master shared signal
	output wire [`WordDataBus] m_rd_data, //slave read data
	output wire				   m_rdy_,	   			//slave ready
	//master 0
	input  wire				   m0_req_,
	input  wire [`WordAddrBus] m0_addr,
	input  wire				   m0_as_,
	input  wire				   m0_rw,
	input  wire [`WordDataBus] m0_wr_data,
	output wire				   m0_grnt_,
	//master 1
	input  wire				   m1_req_,
	input  wire [`WordAddrBus] m1_addr,
	input  wire				   m1_as_,
	input  wire				   m1_rw,
	input  wire [`WordDataBus] m1_wr_data,
	output wire				   m1_grnt_,
	//master 2
	input  wire				   m2_req_,
	input  wire [`WordAddrBus] m2_addr,
	input  wire				   m2_as_,
	input  wire				   m2_rw,
	input  wire [`WordDataBus] m2_wr_data,
	output wire				   m2_grnt_,
	//master 3
	input  wire				   m3_req_,
	input  wire [`WordAddrBus] m3_addr,
	input  wire				   m3_as_,
	input  wire				   m3_rw,
	input  wire [`WordDataBus] m3_wr_data,
	output wire				   m3_grnt_,

	/**********slave**********/
	//slave shared signal
	output wire [`WordAddrBus] s_addr,
	output wire				   s_as_,
	output wire				   s_rw,
	output wire [`WordDataBus] s_wr_data,
	//slave 0
	input  wire [`WordDataBus] s0_rd_data,
	input  wire				   s0_rdy_,
	output wire				   s0_cs_,
	//slave 1
	input  wire [`WordDataBus] s1_rd_data,
	input  wire				   s1_rdy_,
	output wire				   s1_cs_,
	//slave 2
	input  wire [`WordDataBus] s2_rd_data,
	input  wire				   s2_rdy_,
	output wire				   s2_cs_,
	//slave 3
	input  wire [`WordDataBus] s3_rd_data,
	input  wire				   s3_rdy_,
	output wire				   s3_cs_,
	//slave 4
	input  wire [`WordDataBus] s4_rd_data,
	input  wire				   s4_rdy_,
	output wire				   s4_cs_,
	//slave 5
	input  wire [`WordDataBus] s5_rd_data,
	input  wire				   s5_rdy_,
	output wire				   s5_cs_,
	//slave 6
	input  wire [`WordDataBus] s6_rd_data,
	input  wire				   s6_rdy_,
	output wire				   s6_cs_,
	//slave 7
	input  wire [`WordDataBus] s7_rd_data,
	input  wire				   s7_rdy_,
	output wire				   s7_cs_
);

	/**********bus arbiter**********/
	//given a request mx_req_, see mx_grnt_ output
	bus_arbiter bus_arbiter (
			.clk		(clk),
		.reset		(reset),
		//master 0
		.m0_req_	(m0_req_),
		.m0_grnt_	(m0_grnt_),
		//master 1
		.m1_req_	(m1_req_),
		.m1_grnt_	(m1_grnt_),
		//master 2
		.m2_req_	(m2_req_),
		.m2_grnt_	(m2_grnt_),
		//master 3
		.m3_req_	(m3_req_),
		.m3_grnt_	(m3_grnt_)
	);

	/**********master mux**********/
	//given
	bus_master_mux bus_master_mux (
		//master 0
		.m0_addr	(m0_addr),	  	// �A�h���X
		.m0_as_		(m0_as_),	  		// �A�h���X�X�g���[�u
		.m0_rw		(m0_rw),	  		// �ǂ݁^����
		.m0_wr_data (m0_wr_data), // �������݃f�[�^
		.m0_grnt_	(m0_grnt_),	  	// �o�X�O�����g
		//master 1
		.m1_addr	(m1_addr),	  	// �A�h���X
		.m1_as_		(m1_as_),	  		// �A�h���X�X�g���[�u
		.m1_rw		(m1_rw),	  		// �ǂ݁^����
		.m1_wr_data (m1_wr_data), // �������݃f�[�^
		.m1_grnt_	(m1_grnt_),	  	// �o�X�O�����g
		//master 2
		.m2_addr	(m2_addr),	  	// �A�h���X
		.m2_as_		(m2_as_),	  		// �A�h���X�X�g���[�u
		.m2_rw		(m2_rw),	  		// �ǂ݁^����
		.m2_wr_data (m2_wr_data), // �������݃f�[�^
		.m2_grnt_	(m2_grnt_),	  	// �o�X�O�����g
		//master 3
		.m3_addr	(m3_addr),	  	// �A�h���X
		.m3_as_		(m3_as_),	  		// �A�h���X�X�g���[�u
		.m3_rw		(m3_rw),	  		// �ǂ݁^����
		.m3_wr_data (m3_wr_data), // �������݃f�[�^
		.m3_grnt_	(m3_grnt_),	  	// �o�X�O�����g
		/**********slave shared singal **********/
		.s_addr		(s_addr),	  	//slave address
		.s_as_		(s_as_),	  	//slave address select
		.s_rw		(s_rw),		  		//slave write/read
		.s_wr_data	(s_wr_data)	//slave write data
	);

	/**********bus decoder**********/
	//given a address, generate a cs
	bus_addr_dec bus_addr_dec (
		.s_addr		(s_addr),	  //address from cpu
		/**********select a cs**********/
		.s0_cs_		(s0_cs_),	  //cs 0
		.s1_cs_		(s1_cs_),	  //cs 1
		.s2_cs_		(s2_cs_),	  //cs 2
		.s3_cs_		(s3_cs_),	  //cs 3
		.s4_cs_		(s4_cs_),	  //cs 4
		.s5_cs_		(s5_cs_),	  //cs 5
		.s6_cs_		(s6_cs_),	  //cs 6
		.s7_cs_		(s7_cs_)	  //cs 7
	);

	/**********slave mux**********/
	//given a cs , connect m_rd_data and m_rdy_ to right slave sx_rd_data and sx_rdy_
	bus_slave_mux bus_slave_mux (
		.s0_cs_		(s0_cs_),	  //cs0
		.s1_cs_		(s1_cs_),
		.s2_cs_		(s2_cs_),
		.s3_cs_		(s3_cs_),
		.s4_cs_		(s4_cs_),
		.s5_cs_		(s5_cs_),
		.s6_cs_		(s6_cs_),
		.s7_cs_		(s7_cs_),
		//slave 0
		.s0_rd_data (s0_rd_data), //s0 read data
		.s0_rdy_	(s0_rdy_),	    //s0 ready
		//slave 1
		.s1_rd_data (s1_rd_data),
		.s1_rdy_	(s1_rdy_),
		//slave 2
		.s2_rd_data (s2_rd_data),
		.s2_rdy_	(s2_rdy_),
		//slave 3
		.s3_rd_data (s3_rd_data),
		.s3_rdy_	(s3_rdy_),
	 	//slave 4
		.s4_rd_data (s4_rd_data),
		.s4_rdy_	(s4_rdy_),
		//slave 5
		.s5_rd_data (s5_rd_data),
		.s5_rdy_	(s5_rdy_),
		//slave 6
		.s6_rd_data (s6_rd_data),
		.s6_rdy_	(s6_rdy_),
		//slave 7
		.s7_rd_data (s7_rd_data),
		.s7_rdy_	(s7_rdy_),
		/********** master shared singal **********/
		.m_rd_data	(m_rd_data),  //master read data
		.m_rdy_		(m_rdy_)	  		//master ready
	);

endmodule
