if [[ "$1" == "RUN" ]]
then
    shift

    _B="$PWD"
    cd "$DOCS_DIR"

    if [[ "$1" == "serve" ]]; then
        mkdocs serve -a $DOCS_SERVER
    else
        mkdocs $*
    fi

    cd "$_B"
else
    if [[ "$1" == "HELP" || "$1" == "SHORT_HELP" ]]
    then
        if [[ "$1" == "SHORT_HELP" ]]
        then
            echo -e "Run the mkdocs software."
        else
            echo "With this command you can ${c_moxcol_green}serve${c_helpdesc} your documentation application."
        fi
    fi
fi
