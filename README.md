# computerV8
This is a really cool project.  Let's build a computer !!!
############################Purpose#################################
This is a great project to help who wants to understand the basic that how do cpu,compiler,os,application work from super low level layer.
I would like to share the knowledge to you and hear what you think that I could do to improve this repo. I am really a fresh new for this FPGA area.

##########################Story Of Mine###################################
My major is computer science(CS). when I was doing my undergraduate courses in CS, I was so freaking confused on anything that computer does.
At that moment, everyone tells me that computer is just a calculator, but how come a calculator can display pictures, play videos, doing games ?
A lot of question marks floating in my mind all the time. I have nothing but confusion !!! I swore that I must figure everything out, and I wanted to know the truth of everything.
I joined work and started to buy various books and study materials for self-study. The way of self-study is very painful, but every time you understand a knowledge point, you will be extremely happy.
The point makes the line, the line makes the surface, and the surface makes the body.
Later, I wanted to continue to study as a graduate student, and I was very eager to go to computer engineering or electronic engineering major.
But the graduate school told me that I had not taken any relevant courses in the undergraduate course. they rejected me in computer engineering or electronic engineering major.
I had no choice but to join computer science again in master. So I did. I got computer science again !
Actually my story also proves one thing, the degree is not that important related to what you want to do.

########################Project Goal#####################################
Step 0 -> translate the code comments from Japanese to English, setup Quartus (Quartus Prime 18.1) Standard Edition.
Step 1 -> Logic verilog cpu code runs with Intel Altera(Quartus (Quartus Prime 18.1) Standard Edition) FPGA with a Development board.
Step 2 -> Verify all examples code with in the book could run perfectly.
Step 3 -> Desgin a board (name TBD), need to plan what should be in the board, sdram ? ddr ? emmc ? display ? usb ?
Step 4 -> Add jtag interface to cpu
Step 5 -> Add RISC-V instruction set to cpu
Step 6 -> Use Gcc to compiler RISC-V code to verify cpu
Step 7 -> Port RTOS
Step 8 -> Add MMU or MPU to cpu
Step 9 -> Port linux or equivalent os
Step 10 -> make a game device to kids

########################Copyright##############################
I am not familiar with copyright stuff. but I wanted to declare the basic code of this project. It is from a book which I highly 1000% recommend you to read(CPU�������T����HDL�ˤ���Փ���OӋ?�����u��?�ץ������ߥ󥰡�).
It will help you a lot on understanding the concept of cpu instructions,pipeline,bus,interrupts,registers etc. Original book is Japanese verison.I really don't understand Japanese.
I was trying so hard to look up a English version book. Unfortunately, I did not find any. please let me know if it is a english version exist.
In the meanwhile, I have found a Chinese version. I can read it. I am so happy about that. I might spend time to translate his book if I get his permission whatever in future, who knows we will see.
https://gihyo.jp/book/2012/978-4-7741-5338-4/support

######################Folder Structure################################
AZPR_RTL:(all FPGA cpu verilog code)
altera[...]                                       --because i using altera, so need to at least make 3 ip(altera_dcm,altera_dpram,altera_sprom to replace top->lib folder 3 modules,there is one most important file altera\minitop.mif, it is a rom booloader builtin to fpga)
bus[...]                                          --bus related
cpu[...]                                          --alu
io
  gpio[...]                                       -- gpio
  rom[...]                                        -- rom
  timer[...]                                      -- timer
  uart[...]                                       -- uart
top
  include
        [global_config.h nettype.h stddef.h]      -- global headers
  lib
        [x_s3e_dcm.v x_s3e_dpram.v x_s3e_sprom.v] -- these files only for simulation
  rtl
        [chip_top.v chip.v clk_gen.v]             -- these files are for top
  test
        [chip_top_test.v                          -- simulation top
        xxx.prg
        yyy.prg
        sim.cmd
        test.dat]
pictures:
  development_board_related (how to program the external flash to development board)

program:(all examples)
  azprasm:(compiler)
    azprasm.exe xxx.asm -o xxx.bin -p xxx.prg --coe xxx.coe
    xxx.coe is rom hex file for ROM IP loading to init
    xxx.bin is AZ processor run file
    xxx.prg is a file to run the simulation, it is good reference to us
  sample_program:(all examples)
    1_led_run_rom:
                  azprasm.exe led.asm -o led.bin -p led.prg --coe led.coe
                  led:
                      LED3 [14] 0x3BFFF
                      LED2 [15] 0x37FFF
                      LED1 [16] 0x2FFFF
                      LED0 [17] 0x1FFFF
    2_seriral_run_rom:
                  azprasm.exe serial.asm -o serial.bin -p serial.prg --coe serial.coe
    3_loader_run_rom_ram:
                  azprasm.exe loader.asm -o loader.bin -p loader.prg --coe loader.coe
                  azprasm.exe prog.asm -o prog.bin -p prog.prg --coe prog.coe
    4_exception_interrupt_run_in_ram:
                  azprasm.exe timer.asm -o timer.bin -p timer.prg --coe timer.coe
                  azprasm.exe exception.asm -o exception.bin -p exception.prg --coe exception.coe
    5_seg_run_in_ram:
                  azprasm.exe 7seg_10.asm -o 7seg_10.bin -p 7seg_10.prg --coe 7seg_10.coe
                  azprasm.exe 7seg_counter.asm -o 7seg_counter.bin -p 7seg_counter.prg --coe 7seg_counter.coe
    6_timer_run_in_ram:
                  azprasm.exe kitchen_timer.asm -o kitchen_timer.bin -p kitchen_timer.prg --coe kitchen_timer.coe

proj:(all Quartus (Quartus Prime 18.1) Standard Edition project files)

tools:(serial computer tool)

###########################changes##################################
1) I have changed gpio.v (because if you dont not connect gpio_in[3],gpio_in[2],gpio_in[1],only connect gpio_in[0] with original verilog code, it will cause issue, becuase we dont know the status gpio_in[3],gpio_in[2],gpio_in[1] is 0 or 1 )

`ifdef GPIO_IN_CH
					`GPIO_ADDR_IN_DATA	: begin
						//rd_data	 <= #1 {{`WORD_DATA_W-`GPIO_IN_CH{1'b0}},
						//				gpio_in};
						rd_data	 <= #1 {{`WORD_DATA_W-1{1'b0}}, //modified by min zhang
										gpio_in[0]};
					end
`endif
2) in global_config.h need `timescale 1ns/1ps defined, because some other verilog files using #1 for delay. everyone which uses # to delay timing , need `timescale 1ns/1ps,so just put it into a common header
will solve this issue.
/********** SIMULATION**********/
	`timescale 1ns/1ps

#############################quartus IDE simulation set up################################
if you want to use quartus to do the simulation(modelsim-altera):
1) mif file for rom and ram should be in proj\simulation\AZPR_RTL\altera\
minitop.mif for rom.
ram.mif for ram.

#############################quartus IDE ################################
there is a pictures folder, it has lot of screenshot to show you how to use quartus etc.
