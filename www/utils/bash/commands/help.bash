c_helpcmd=$c_moxcol_green
c_helpdesc=$c_moxcol_gray

if [[ "$1" == "RUN" ]]
then
    shift

    _B="$PWD"
    cd "$BASE"

    if [[ "$1" == "" ]]
    then

        for file in $M_UTILS_BASH_DIR/commands/*.bash
        do
            filename=$(basename -- "$file")
            filename="${filename%.*}"
            # Provide a tmp file to write output.
            mkdir -p "$BASE/tmp"
            tmp=$BASE/tmp/${filename}.log
            shorthelp=`$file SHORT_HELP "$tmp"`
            shorthelp_args=""
            if [[ -f "$tmp" ]]; then
                IFS=$'\r\n' GLOBIGNORE='*' command eval 'shorthelp_args=($(cat $tmp))'
                rm $tmp
            fi
            # shorthelp_args is now an array of lines of that output.
            # Output sample:
            # SubCommand 1
            # Description 1
            # SubCommand 2
            # Description 2
            # so on...

            if [[ "$shorthelp" != "" ]]; then
                prnt $M_TAG "INFO" "  ${c_helpcmd}mox ${filename}${c_helpdesc}: ${shorthelp}${c_reset}"

                if [[ "$shorthelp_args" != "" ]]; then
                    len=$(( (${#shorthelp_args[@]} / 2) - 1))
                    for ((i=0;i<=$len;i++)); do
                        prnt $M_TAG "INFO" "  ${c_helpcmd}mox $filename ${shorthelp_args[(2 * $i)]}${c_helpdesc}: ${shorthelp_args[(2 * $i + 1)]}${c_reset}"
                    done
                fi
            fi
        done
        prnt $M_TAG "INFO" "  ${c_helpcmd}mox help [command]${c_helpdesc}: Help on a specific mox command.${c_reset}"

    else
        _P="$M_UTILS_BASH_DIR/commands/$1.bash"
        if [[ -f "$_P" ]]
        then
            _help=`"$_P" HELP`
            if [[ "$_help" != "" ]]
            then
                prnt $M_TAG "INFO" "Help for ${c_helpcmd}mox ${1}${c_prnt_info} below:\n${c_helpdesc}${_help}"
            fi
        fi
    fi
    cd "$_B"
else
    if [[ "$1" == "HELP" || "$1" == "SHORT_HELP" ]]
    then
        if [[ "$1" == "HELP" ]]
        then
            prnt $M_TAG "INFO" "Replace me help command help."
        fi
    fi
fi
