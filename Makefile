init:
	rm -rf build
	mkdir build
	ghdl -a --workdir=build --std=08 subbytes.vhd
	ghdl -a --workdir=build --std=08 subbytes_tb.vhd
	echo "ghdl project initialized!"

elaborate: init
	ghdl -e --workdir=build --std=08 subbytes_tb

simulate: elaborate
	ghdl -r --workdir=build --std=08 subbytes_tb --stop-time=53us --wave=plot.ghw

clean:
	rm -rf build
	rm plot.ghw

# TODO: yosys synthesis
# TODO: nextpnr place and route
