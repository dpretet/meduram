#!/usr/bin/env bash

# -e: exit if one command fails
# -u: treat unset variable as an error
# -f: disable filename expansion upon seeing *, ?, ...
# -o pipefail: causes a pipeline to fail if any command fails
set -euf -o pipefail

svutRun -test ./top_2w_2r_unit_test.sv -f files.f -I ../src
