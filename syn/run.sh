#!/usr/bin/env bash

# -e: exit if one command fails
# -u: treat unset variable as an error
# -f: disable filename expansion upon seeing *, ?, ...
# -o pipefail: causes a pipeline to fail if any command fails
set -euf -o pipefail

if [[ ! -f "./vsclib013.lib" ]]; then
    wget http://www.vlsitechnology.org/synopsys/vsclib013.lib
fi

yosys -V
yosys ./top_2w_2r_core.ys | tee yosys_top_2w_2r_core.log
