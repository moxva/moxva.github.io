#!/bin/bash

#######################################################
# MOXVA - .bashrc
#------------------------------------------------------
# Sections:
#   1) Env and variables
#   2) Common logic
#   3) PS1
#   4) ENV
#   5) Internal
#
# This file should be included in the prod environment.
#
#######################################################

export LC_CTYPE="en_US.UTF-8"
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

# ----- Variables -----
# BASE_WWW: The location of Moxva/www
# BASE: The base location of Moxva

if [ $IS_LIVE ]; then
    export BASE="/home/moxva/website"
else
    export BASE="$PWD"
fi

if [[ "$BASE_WWW" == "" ]]; then
    export BASE_WWW="$BASE/www"
    export PATH="$BASE:$PATH"
fi

# ----- ENV -----
# Load env.

if [ -f $BASE/.env ]
then
    set -a
    . $BASE/.env
    set +a
fi

# .env that is not on live servers.
if [ -f $BASE/.local.env ]
then
    set -a
    . $BASE/.local.env
    set +a
fi

# detect if server.
if [ -f ".is-live" ]; then
    export IS_LIVE=1
fi

# ----- Variables Cont'd -----

if [[ "$DOCS_DIR" == "" ]]; then
    export DOCS_DIR="$BASE/www/docs"
fi

if [[ "$M_UTILS_DIR" == "" ]]; then
    export M_UTILS_DIR="$BASE_WWW/utils"
    export M_UTILS_BASH_DIR="$M_UTILS_DIR/bash"
    export PATH="$M_UTILS_BASH_DIR:$PATH"
fi

declare -l hostname # Lower-case
export hostname=$HOSTNAME
if [[ "$PYTHONPATH" == "" ]]; then
    export PYTHONPATH="${BASE_WWW}/backend"
fi
if [[ "$GOPATH" == "" ]]; then
    export GOPATH=$HOME/gocode
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1
DEFAULT_PS1=$PS1

# ---- Common logic -----
# Functions..

function mox() { source $M_UTILS_BASH_DIR/m.sh $@; }

function proxy() {
    PROXY="http://127.0.0.1:57883"

    if [[ "$1" == "status" ]]; then
        if [[ "$http_proxy" != "" ]]; then
            echo -e "proxy on: $http_proxy"
        else
            echo -e "proxy off"
        fi
    elif [[ "$1" == "off" ]]; then
        export http_proxy=""
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$http_proxy"
        export https_proxy="$http_proxy"
    elif [[ "$1" == "on" ]]; then
        export http_proxy="$PROXY"
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$http_proxy"
        export https_proxy="$http_proxy"
    else
        if [[ "$http_proxy" != "" ]]; then
            export http_proxy=""
        else
            export http_proxy="$PROXY"
        fi
        export HTTP_PROXY="$http_proxy"
        export HTTPS_PROXY="$http_proxy"
        export https_proxy="$http_proxy"
    fi
}
alias proxify=`proxy`

function www() {
    cd $BASE_WWW;
}
function dj() {
    python $BASE_WWW/backend/manage.py $@;
}

export -f mox
export -f www
export -f dj

# ----- PS1 -----
# Create a nice PS1 prompt, depending on the host and system.

function virtualenv_info(){
    # Get Virtual Env
    if [[ -n "$VIRTUAL_ENV" ]]; then
        # Strip out the path and just leave the env name
        venv=${VIRTUAL_ENV##*\\}
        venv="$(basename "$venv")"
    else
        # In case you don't have one activated
        venv=''
    fi
    [[ -n "$venv" ]] && echo "($venv)─"
}

# ----- Internal -----
#

if [[ -f "$M_UTILS_BASH_DIR/env.sh" ]]; then
    source "$M_UTILS_BASH_DIR/env.sh"
fi

if [ ! $IS_SERVER ]
then
    source "$BASE_WWW/venv/Scripts/activate"
    echo -e "${c_moxcol_main_dark}Switched to Moxva successfully.${c_reset}"
else
    # TODO: Activate venv normally on server.
    :
fi

PS_OS="\[$(tput bold)\]\[\033[38;5;112m\]${OSTYPE}\[$(tput sgr0)\]" # OS type info
PS_VI="\`virtualenv_info\`$(tput sgr0)" # Virtual env info: Adds dash if there is env
PS_UH="\e[1;31m\]\u\[\e[0;31m\]@\[\e[1;31m\]\h\[\e[m\]$(tput sgr0)" # User and host info
PS_GIT="\`__git_ps1\`" # Git info
PS_CWD="\[\e[1;35m\]\w\[\e[m\]"
PS_TIME="\[\e[90m\]\D{%d/%m/%Y} \t$(tput sgr0)"
PSS=""
PSS="$PSS$(tput sgr0)┌─[$PS_TIME]\n"
PSS="$PSS$(tput sgr0)├─$PS_VI[\[$PS_UH]─$PS_OS─[$PS_CWD]\[\e[34m\]$PS_GIT\[\e[m\]\n"
PSS="$PSS$(tput sgr0)└──\[\e[1;34m\]◆\[\e[m\] "
export PS1=$PSS

# check checkin logs for recent checkin sessions for the day...
MOL_BALLOT_1=$MOL_BALLOT_EMPTY
MOL_BALLOT_2=$MOL_BALLOT_EMPTY
MOL_BALLOT_3=$MOL_BALLOT_EMPTY

needwelcoming=0
dt=$(date '+%d/%m/%Y');
if [[ ! -f "$BASE/checkins.log" ]]; then
    touch "$BASE/checkins.log"
fi
ci=$(grep -E "($USERNAME).*($dt)" $BASE/checkins.log)
if [[ -z "$ci" ]]; then
    needwelcoming=1
else
    MOL_BALLOT_1="$MOL_BALLOT_TRUE"
fi

OUT=$( { for i in {1..6}
    do
        vname="MOL_IMG${MOL_ENV_IMGID}"
        if [[ ! -z "${vname}_$i" ]]; then
            tmp1L="MOL_LINE_$i"
            tmp1R="${vname}_$i"
        else
            tmp1L="MOL_LINE_$i"
            tmp1R=""
        fi
        o="${!tmp1L}\t${!tmp1R}"
        o=${o/\$MOL_BALLOT_1/${MOL_BALLOT_1}}
        o=${o/\$MOL_BALLOT_2/${MOL_BALLOT_2}}
        o=${o/\$MOL_BALLOT_3/${MOL_BALLOT_3}}
        echo -e "$o"
    done
} | column -t -c 2 -n -e -s $'\t')

echo -e "$OUT";

if [[ "$MOL_BALLOT_1" == "$MOL_BALLOT_EMPTY" ]]
then
    needwelcoming=1
fi

if [[ "$needwelcoming" == "1" ]]
then
    $M_UTILS_BASH_DIR/init.sh welcome
fi
