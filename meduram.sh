#!/usr/bin/env bash

# -e: exit if one command fails
# -u: treat unset variable as an error
# -f: disable filename expansion upon seeing *, ?, ...
# -o pipefail: causes a pipeline to fail if any command fails
set -euf -o pipefail

# Current script path; doesn't support symlink
MEDUDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Bash color codes
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
# Reset
Color_Off='\033[0m'

function printerror {
    echo -e "${Red}ERROR: ${1}${Color_Off}"
}

function printwarning {
    echo -e "${Yellow}WARNING: ${1}${Color_Off}"
}

function printinfo {
    echo -e "${Blue}INFO: ${1}${Color_Off}"
}

function printsuccess {
    echo -e "${Green}INFO: ${1}${Color_Off}"
}

help() {
    echo -e "${Blue}"
    echo ""
    echo "NAME"
    echo ""
    echo "      A FPGA multi-port BRAM IP"
    echo ""
    echo "SYNOPSIS"
    echo ""
    echo "      ./meduram.sh -h"
    echo ""
    echo "      ./meduram.sh help"
    echo ""
    echo "      ./meduram.sh syn"
    echo ""
    echo "      ./meduram.sh sim"
    echo ""
    echo "DESCRIPTION"
    echo ""
    echo "      This flow handles the different operations available"
    echo ""
    echo "      ./meduram.sh help|-h"
    echo ""
    echo "      Print the help menu"
    echo ""
    echo "      ./meduram.sh syn"
    echo ""
    echo "      Launch the synthesis script relying on Yosys"
    echo ""
    echo "      ./meduram.sh sim"
    echo ""
    echo "      Launch all available testsuites"
    echo ""
    echo -e "${Color_Off}"
}

main() {

    echo ""
    printinfo "Start Meduram Flow"

    # If no argument provided, preint help and exit
    if [[ $# -eq 0 ]]; then
        help
        exit 1
    fi

    # Print help
    if [[ $1 == "-h" || $1 == "help" ]]; then

        help
        exit 0
    fi

    source scripts/setup.sh

    if [[ $1 == "sim" ]]; then
        cd "$MEDUDIR/sim"
        ./run.sh
        return $?
    fi

    if [[ $1 == "syn" ]]; then
        cd "$MEDUDIR/syn"
        yosys top_2w_2r.ys
        return $?
    fi
}

main "$@"
