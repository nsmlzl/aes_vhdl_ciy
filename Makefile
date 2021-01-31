# modules
top_module := blinky
srcs := hdl/subbytes.vhd
srcs += hdl/key_schedule_func.vhd
srcs += hdl/key_scheduler.vhd
srcs += hdl/blinky.vhd
# testbenches
tbs := sim/subbytes_tb.vhd
tbs += sim/key_schedule_func_tb.vhd
tbs += sim/key_scheduler_tb.vhd
tbs += sim/blinky_tb.vhd

sim_targets := ${patsubst sim/%.vhd, %_SIM, ${tbs}}


ghdl := ghdl
ghdl_args := --workdir=build --std=08
# print colorful
yellow = `tput setaf 3`
reset = `tput sgr0`


plt_name = plot.ghw


# TODO: yosys synthesis
# TODO: nextpnr place and route


# GHDL
# simulate all units with ghdl
ghdl_simulation: ${sim_targets}
	@echo "${yellow}GHDL: Completed simulation succesfully!${reset}"

# simulate % unit with ghdl
%_SIM: %_ELAB
	@echo "${yellow}GHDL: Simulation of $*${reset}"
	@${ghdl} -r ${ghdl_args} $* --stop-time=500us --wave=${plt_name}

# elaborate % unit with ghdl
%_ELAB: ghdl_analysis
	@echo "${yellow}GHDL: Elaboration of $*${reset}"
	@${ghdl} -e ${ghdl_args} $*

# analyse all vhdl files with ghdl
ghdl_analysis: build/work-obj08.cf
build/work-obj08.cf: ${srcs} ${tbs}
	@mkdir -p build
	@echo "${yellow}GHDL: Analysis${reset}"
	@${ghdl} -a ${ghdl_args} $^

view_plot:
	gtkwave ${plt_name} ${gtkw}

ghdl_check_syntax:
	@echo "${yellow}GHDL: Syntax check${reset}"
	@${ghdl} -s ${ghdl_args} ${srcs} ${tbs}

.phony: clean
clean:
	rm -rf build *.ghw *.gtkw
