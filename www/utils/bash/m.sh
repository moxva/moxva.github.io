#!/bin/bash

#######################################################
# Moxva - m.sh
#------------------------------------------------------
# Sections:
#   1) Commands
#       - server
#
# This file should be included in the prod environment.
#
#######################################################

SCRIPT=$(readlink -f "$0")

#region Commands
    _CMD="help"

    #region help
    if [[ "$1" == "help" ]]; then
        _CMD="help"
    fi
    #endregion

    #region NPM/NPX
    if [[ "$1" == "npm" ]]; then
        _CMD="npm"
    fi
    if [[ "$1" == "npx" ]]; then
        _CMD="npx"
    fi
    #endregion

    #region docs
    if [[ "$1" == "docs" || \
        "$1" == "documentation" ]]; then
        _CMD="docs"
    fi
    #endregion

    #region dj
    if [[ "$1" == "dj" || \
        "$1" == "django" ]]; then
        _CMD="dj"
    fi
    #endregion

    #region lint
    if [[ "$1" == "lint" || \
        "$1" == "pylint" ]]; then
        _CMD="lint"
    fi
    #endregion

    #region statics (DEPRECATED)
    # if [[ "$1" == "statics" || \
    #     "$1" == "static" ]]; then
    #     _CMD="statics"
    # fi
    #endregion

    #region w3validate
    if [[ "$1" == "w3validate" || \
        "$1" == "w3v" ]]; then
        _CMD="w3validate"
    fi
    #endregion

    #region Execute command.
    if [ -f "$M_UTILS_BASH_DIR/commands/$_CMD.bash" ]; then
        shift
        source "$M_UTILS_BASH_DIR/commands/$_CMD.bash" RUN $*
    else
        prnt $M_TAG "ERROR" "Command \"$_CMD\" not found."
    fi
    #endregion

#endregion
