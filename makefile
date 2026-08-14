
# -----------------------------------------------------------------------------
# Development Makefile
#
# This Makefile reflects the workflow used during the development and
# verification of the processor. It will evolve into a standardized public
# build system as the project matures.
# -----------------------------------------------------------------------------


# Compiler
IVERILOG = iverilog

# verilator --binary -Wall


# Output executable
OUT = sim/datapath_out
OUT2 = sim/datapath2_out
OUT1 = sim/datapath1_out
CONTRL = sim/controller_out
CPU_OUT = sim/cpu_out
PROCESSOR_O = sim/processor_out

# Verilog source files
SRC = rtl/datapath.v rtl/alu.v rtl/extend.v rtl/mux.v rtl/adder.v rtl/register.v rtl/pc.v tb/integration/tb_datapath.v
SRC2 = rtl/datapath.v rtl/alu.v rtl/extend.v rtl/mux.v rtl/adder.v rtl/register.v rtl/pc.v tb/integration/tb_datapath2.v
SRC1 = rtl/datapath.v rtl/alu.v rtl/extend.v rtl/mux.v rtl/adder.v rtl/register.v rtl/pc.v tb/integration/tb_datapath1.v
COND_DECODER = rtl/cond_decoder.v 
CONTROLLER = rtl/controller.v rtl/decoder.v rtl/cond_decoder.v tb/integration/tb_controller.sv
CPU = \
	rtl/cpu/cpu.v \
	rtl/cpu/controller.v \
	rtl/cpu/datapath.v \
	rtl/cpu/alu.v \
	rtl/cpu/extend.v \
	rtl/cpu/mux.v \
	rtl/cpu/adder.v \
	rtl/cpu/register.v \
	rtl/cpu/pc.v \
	rtl/cpu/decoder.v \
	rtl/cpu/cond_decoder.v \
	tb/system/tb_processor_system.sv


PNR = --up5k --package sg48 --json build/top.json --pcf fpga/soc.pcf --asc build/top.asc
RTL =  \
		rtl/cpu/cpu.v \
		rtl/cpu/controller.v \
		rtl/cpu/datapath.v \
		rtl/cpu/alu.v \
		rtl/cpu/extend.v \
		rtl/cpu/mux.v \
		rtl/cpu/adder.v \
		rtl/cpu/register.v \
		rtl/cpu/pc.v \
		rtl/cpu/decoder.v \
		rtl/cpu/cond_decoder.v \
		fpga/top.v \
		rtl/processor_system.v \
		rtl/memory/data_mem.v \
		rtl/memory/instr_mem.v \
		rtl/peripherals/uart_tx.v \
		rtl/peripherals/button_controller.v \
		rtl/trace/trace.v

PROCESSOR_S = \
		rtl/cpu/cpu.v \
		rtl/cpu/controller.v \
		rtl/cpu/datapath.v \
		rtl/cpu/alu.v \
		rtl/cpu/extend.v \
		rtl/cpu/mux.v \
		rtl/cpu/adder.v \
		rtl/cpu/register.v \
		rtl/cpu/pc.v \
		rtl/cpu/decoder.v \
		rtl/cpu/cond_decoder.v \
		rtl/processor_system.v \
		rtl/memory/data_mem.v \
		rtl/memory/instr_mem.v \
		tb/system/tb_processor_system.sv

# gtk waves files
WAVE = sim/waves/datapath.vcd
WAVE2 = sim/waves/datapath2.vcd
WAVE1 = sim/waves/datapath1.vcd
WAVE3 = sim/waves/controller.vcd
WAVE4 = sim/waves/cpu.vcd

# Default target
all:
	$(IVERILOG) -o $(OUT) $(SRC)

# Run simulation
run:
	vvp $(OUT)

# Clean generated files
##clean:
#	rm -f $(OUT)

dt2: 
	$(IVERILOG) -o $(OUT2) $(SRC2)

run2: 
	vvp $(OUT2)

gtk:
	gtkwave $(WAVE)

gtk2:
	gtkwave $(WAVE2)

alu:
	$(IVERILOG) -o $(OUT1) $(SRC1)

alu_run:
	vvp $(OUT1)

alu_gtk:
	gtkwave $(WAVE1)

controller: 
	$(IVERILOG) -g2012 -o $(CONTRL) $(CONTROLLER)

control_run:
	vvp $(CONTRL)

cpu:
	$(IVERILOG) -g2012 -o $(CPU_OUT) $(CPU)

cpu_run:
	vvp $(CPU_OUT)

soc:
	yosys -p "synth_ice40 -top top -json build/top.json" $(RTL)

route_soc:
	nextpnr-ice40 $(PNR)

processor:
	$(IVERILOG) -g2012 -o $(PROCESSOR_O) $(PROCESSOR_S)
system:
	vvp $(PROCESSOR_O)

