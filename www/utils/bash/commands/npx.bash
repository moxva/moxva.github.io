if [[ "$1" == "RUN" ]]
then
    shift

    _B="$PWD"
    cd "$BASE"

    npx $*

    cd "$_B"
else
    if [[ "$1" == "HELP" || "$1" == "SHORT_HELP" ]]
    then
        if [[ "$1" == "SHORT_HELP" ]]
        then
            echo -e "Run the NPM's NPX."
        else
            echo "This command is used to run the NPM's NPX in the root of the project."
        fi
    fi
fi
