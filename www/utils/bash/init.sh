#!/bin/bash

#######################################################
# Moxva Init bash
#------------------------------------------------------
# This script includes useful functions for refreshing
# memory on the workspace.
#
# It includes checkins (based on current environment
# checkins.log file)
#
# This file should be included in the prod environment.
#
# See the file  .bashrc  for more details.
#
#######################################################

SCRIPT=$(readlink -f "$0")
export LC_CTYPE="en_US.UTF-8"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

# Dotenv load : Already loaded.

# Welcoming part.

# Some functions.

SPIN=""
fn_spin() {
    if [ $# -eq 0 ]; then
        if [ "$SPIN" == "" ] || [ "$SPIN" == "toggle" ]; then
            call_silent "python" "$M_UTILS_DIR/python/spin.py"
            SPIN=$!
        else
            kill -9 $SPIN 2>/dev/null
            wait $SPIN 2>/dev/null
            echo " "
            tput cuu 1 && tput el && echo -ne "\033[2K\r \n";
            SPIN=""
        fi
    elif [ "$1" == "on" ]; then
        if [ "$SPIN" != "" ]; then
            fn_spin "off"
        fi
        shift
        call_silent "python" "$M_UTILS_DIR/python/spin.py" $*
        SPIN=$!
    elif [ "$1" == "off" ]; then
        if [ "$SPIN" == "" ]; then
            echo "(SPIN) subprocess is not set."
        else
            kill -9 $SPIN 2>/dev/null
            wait $SPIN 2>/dev/null
            echo " "
            tput cuu 1 && tput el && echo -ne "\033[2K\r \n";
            SPIN=""
        fi
    fi
}

if [ "$1" == "welcome" ]; then
    shift
    fn_spin on
    read -n 1 menuchoiceinput
    if [ "$menuchoiceinput" == "1" ]; then
        echo -e "\n${c_moxcol_main} ${chr_check}  Thank you${COL_RESET}"
        MOL_BALLOT_1="$MOL_BALLOT_TRUE"
        dt=$(date '+%d/%m/%Y %H:%M:%S');
        echo -e "$MOL_BALLOT_1 \"${USERNAME// /-}\" has checked in on $dt" >> $BASE/checkins.log
    elif [ "$menuchoiceinput" == "2" ]; then
        shift 2
        echo -e "\n${c_moxcol_main} ${chr_check} ${COL_RESET}"
        MOL_BALLOT_1="$MOL_BALLOT_TRUE"
        dt=$(date '+%d/%m/%Y %H:%M:%S');
        echo -e "$MOL_BALLOT_1 \"${USERNAME// /-}\" has checked in on $dt" >> $BASE/checkins.log
    elif [ "$menuchoiceinput" == "3"]; then
        echo -e "\n${c_moxcol_main}You are welcome to get assistance, my name is "${USERNAME}". How can I help?"
        :
    fi
    fn_spin off
elif [ "$1" == "card" ]; then
    :: # Check the card details
fi
