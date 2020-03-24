all: synth

synth:
	echo "INFO: Start synthesis"
	yosys syn/top_1w_2r.ys
