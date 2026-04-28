NAME = cpu
SRC = *.sv
DUT = cpu
LPF = ../icepi-zero.lpf

wave:
	iverilog ./$(NAME)/$(SRC) ./testbenches/$(DUT)_tb.sv
	vvp a.out
	gtkwave wave.vcd

build:
	yosys -p "synth_ecp5 -top top -json $(NAME).json" ./$(NAME)/$(SRC)
	nextpnr-ecp5 --25k --package CABGA256 --json $(NAME).json --lpf $(LPF) --textcfg $(NAME).config
	ecppack --svf $(NAME).svf $(NAME).config $(NAME).bit

run: build
	openFPGALoader -cft231X --pins=7:3:5:6 $(NAME).bit

flash: build
	openFPGALoader -cft231X --pins=7:3:5:6 $(NAME).bit -f

clean:
	rm $(NAME).json $(NAME).config $(NAME).svf $(NAME).bit
