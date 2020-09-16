#!/usr/bin/env bash

# -e: exit if one command fails
# -u: treat unset variable as an error
# -f: disable filename expansion upon seeing *, ?, ...
# -o pipefail: causes a pipeline to fail if any command fails
# set -euf -o pipefail

echo "Start Meduram test flow"

svutRun -test ./top_2w_2r_core_unit_test.sv -f files.f -I ../src | tee log
ret=$?

if [[ $ret != 0 ]]; then
    echo "Execution of core testsuite failed"
    exit 1
fi

ec=$(grep -c "ERROR:" log)

if [[ $ec != 0 ]]; then
    echo "Execution suffered $ec issues"
    exit 1
else
    echo "Execution of core testsuite successfully finished"
fi

svutRun -test ./top_2w_2r_axi4lite_unit_test.sv -f files.f -I ../src | tee log
ret=$?

if [[ $ret != 0 ]]; then
    echo "Execution of axi4-lite testsuite failed"
    exit 1
fi

ec=$(grep -c "ERROR:" log)

if [[ $ec != 0 ]]; then
    echo "Execution suffered $ec issues"
    exit 1
else
    echo "Execution of axi4-lite testsuite successfully finished"
fi

echo "Meduram test flow successfully terminated ^^"
