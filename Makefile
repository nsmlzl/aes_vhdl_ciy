# modules
top_module := top
srcs := hdl/aes_package.vhd
srcs += hdl/subbytes.vhd
srcs += hdl/key_schedule_func.vhd
srcs += hdl/key_scheduler.vhd
srcs += hdl/shift_row.vhd
srcs += hdl/top.vhd
# testbenches
tbs := sim/aes_package_tb.vhd
tbs += sim/subbytes_tb.vhd
tbs += sim/key_schedule_func_tb.vhd
tbs += sim/key_scheduler_tb.vhd
tbs += sim/shift_row_tb.vhd

sim_targets := $(patsubst sim/%.vhd, %_SIM, $(tbs))

builddir := build


docker_ghdl := docker run --rm -it -v $(shell pwd):/work -w /work hdlc/ghdl:yosys
ghdl := $(docker_ghdl) ghdl
ghdl_args := --workdir=$(builddir) --std=08
stop_time := 500us

docker_yosys := docker run --rm -it -v $(shell pwd):/work -w /work hdlc/ghdl:yosys
yosys := $(docker_yosys) yosys

docker_nextpnr := docker run --rm -it -v $(shell pwd):/work -w /work hdlc/nextpnr:ice40
nextpnr-ice40 := $(docker_nextpnr) nextpnr-ice40

docker_icepack := docker run --rm -it -v $(shell pwd):/work -w /work hdlc/icestorm
icepack := $(docker_icepack) icepack

# print colorful
yellow := `tput setaf 3`
reset := `tput sgr0`


plt_name := plot.ghw

fpga := lp8k


# GHDL
# simulate all units with ghdl
ghdl_simulation: $(sim_targets)
	@echo "$(yellow)GHDL: Simulation succesfull!$(reset)"

# simulate % unit with ghdl
%_SIM: %_ELAB
	@echo "$(yellow)GHDL: Simulation of $*$(reset)"
	@$(ghdl) -r $(ghdl_args) $* --stop-time=$(stop_time) --wave=$(plt_name)

# elaborate % unit with ghdl
%_ELAB: ghdl_analysis
	@echo "$(yellow)GHDL: Elaboration of $*$(reset)"
	@$(ghdl) -e $(ghdl_args) $*

# analyse all vhdl files with ghdl
ghdl_analysis: build/work-obj08.cf
$(builddir)/work-obj08.cf: $(srcs) $(tbs)
	@mkdir -p build
	@echo "$(yellow)GHDL: Analysis$(reset)"
	@$(ghdl) -a $(ghdl_args) $^

view_plot:
	gtkwave $(plt_name) $(gtkw)

ghdl_syntax_check: $(builddir)/work-obj08.cf
	@echo "$(yellow)GHDL: Syntax check$(reset)"
	@$(ghdl) -s $(ghdl_args) $(srcs) $(tbs)

ghdl_synth_check: $(builddir)/work-obj08.cf
	@echo "$(yellow)GHDL: Synthesis check$(reset)"
	$(ghdl) --synth $(ghdl_args) $(top_module)

# YOSYS - synthesis
synthesis: $(builddir)/$(top_module).json
$(builddir)/%.json : $(srcs)
	@mkdir -p build
	@$(yosys) -m ghdl -p 'ghdl $(srcs) -e $*; synth_ice40 -json $@'
	@echo "$(yellow)YOSYS: Synthesis succesfull!$(reset)"

# NEXTPNR - place and route
pandr: $(builddir)/$(top_module).asc
$(builddir)/%.asc: $(builddir)/%.json
	@$(nextpnr-ice40) --$(fpga) --package cm81 --pcf pins.pcf --asc $@ --json $^
	@echo "$(yellow)NEXTPNR: Place & route succesfull!$(reset)"

# ICEPACK - generate bitstream
bin: $(builddir)/$(top_module).bin
$(builddir)/%.bin: $(builddir)/%.asc
	@$(icepack) $^ $@
	@echo "$(yellow)ICEPACK: Generation bitstream succesfull!$(reset)"

# TINYPROG - program device with bitstream
prog: $(builddir)/$(top_module).bin
	@tinyprog -p $^
	@echo "$(yellow)TINYPROG: Flashing succesfull!$(reset)"

# start docker container
docker_yosys docker_ghdl docker_nextpnr docker_icepack:
	$($@) bash

.phony: clean
clean:
	rm -rf build *.ghw *.gtkw
