#!/bin/bash

# CHARACTERS
# Moxva Badge Logo
export chr_badge=" "
export chr_moxva_tag="$chr_badge "
export M_TAG=$chr_moxva_tag
export chr_check="✔️"
export chr_cross="❌"
export chr_middot="·"
# COLORS
export c_black=$(tput setaf 0)
export c_red=$(tput setaf 1)
export c_green=$(tput setaf 2)
export c_yellow=$(tput setaf 3)
export c_blue=$(tput setaf 4)
export c_magenta=$(tput setaf 5)
export c_cyan=$(tput setaf 6)
export c_white=$(tput setaf 7)
export c_normal=$(tput sgr0)
export c_bold=`tput bold`
export c_dim='\e[2m'
export c_underline=`tput smul`
export c_reset=`tput sgr0`
export esc='\033'

source "$M_UTILS_BASH_DIR/colors.sh"
export c_prnt_info=$c_moxcol_main_light

# print beautifully. This function is rewritten in Python:
# core.management.utils.prnt

prnt() {
    local _tag=$M_TAG
    local _type="info"
    local _msg=""
    local _col=""

    if [[ $QUIET -gt 0 ]]; then
        return
    fi

    if [[ $# -eq 3 ]]; then
        _tag=$1
        _type=$2
        _msg="$3"
    fi
    if [[ $# -eq 2 ]]; then
        _tag=$1
        _msg="$2"
    fi
    if [[ $# -eq 1 ]]; then
        _msg="$1"
    fi

    if [[ "${_type^^}" == "INFO" ]]; then
        _type="INFO"
        _col=${c_prnt_info}
    elif [[ "${_type^^}" == "WARNING" || "${_type^^}" == "WARN" ]]; then
        _type="WARN"
        _col=${c_yellow}
    elif [[ "${_type^^}" == "ERROR" || "${_type^^}" == "ERR" || "${_type^^}" == "CRITICAL" || "${_type^^}" == "CRIT" ]]; then
        _type="${c_red}ERROR"
        _col=${c_red}
    elif [[ "${_type^^}" == "DEBUG" || "${_type^^}" == "DEBG" || "${_type^^}" == "DBUG" || "${_type^^}" == "DBG" ]]; then
        _type="DEBUG"
        _col=${c_green}
    fi

    if [[ "${_type^^}" == "DEBUG" ]]; then
        if [[ $DEBUG -lt 1 ]]; then
            return
        fi
    fi

    if [[ ! "$IS_LIVE" ]]; then
        tagcol="$c_moxcol_main_dark"
    else
        tagcol="$c_moxcol_main"
    fi
    echo -e "${tagcol}${_tag}/${c_bold}${_type}${c_reset}${tagcol}:${c_reset} ${_col}${_msg}${c_reset}"
}
export -f prnt

# Convert path from Windows to POSIX
path_posix() { echo "$1" | sed -r -e 's/^([^:]+):/\/\1/' -e 's/\\/\//g'; }
# Convert path from POSIX to Windows
path_windows() { echo "$1" | sed -e 's|^/\(.\)/|\1:\\|g' -e 's|/|\\|g'; }
# Convert path by auto detection of system (msys/win32 otherwise POSIX)
path_auto() {
    local p=""
    if [[ "$OSTYPE" != "msys" && "$OSTYPE" != "win32" ]]; then
        p="posix"
    else
        p="windows"
    fi
    echo `path_$p "$1"`
}
# Check if glob has files
glob_exists() {
    for f in $1; do
        ## Check if the glob gets expanded to existing files.
        ## If not, f here will be exactly the pattern above
        ## and the exists test will evaluate to false.
        [ -e "$f" ] && echo "1" || echo "0"
        break
    done
}
# Take a directory and return valid git-commitable files.
git_dir_to_files() {
    git ls-files --exclude-standard "$1"
}
# Take a path and check if it is git ignored.
git_ignored() {
    if [[ $(git check-ignore "$1") == "$1" ]]; then echo "1"; else echo "0"; fi
}

export -f path_posix
export -f path_windows
export -f path_auto
export -f glob_exists
export -f git_dir_to_files
export -f git_ignored

# Start subprocess silently.
call_silent() { { 2>&3 "$@"& } 3>&2 2>/dev/null; }

export -f call_silent

SPIN=""
# Spin function (off, on, or automatic)
spin() {
    local pa=`path_auto "$BASE/utils/python/spin.py"`
    if [ $# -eq 0 ]; then
        if [ "$SPIN" == "" ]; then
            call_silent "python" "$pa"
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
            _fn_spin "off"
        fi
        shift
        call_silent "python" "$pa" $*
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

export SPIN
export -f spin
