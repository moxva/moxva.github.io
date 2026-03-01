if [[ "$1" == "RUN" ]]
then
    shift

    _B="$PWD"
    cd "$BASE_WWW/backend"

    if [[ "$1" == "serve" ]]; then
        shift
        if [[ "$1" == "" ]]; then
            dj runserver $DEV_SERVER
        else
            dj runserver $*
        fi
    elif [[ "$1" == "coverage" ]]; then
        shift
        # Exclude open if found last.
        if [[ "${@:$#}" == "open" ]]; then
            args=${@:1:$#-1}
        else
            args=$*
        fi
        if [[ "$1" != "xml" && "$1" != "html" && "$1" != "open" \
           && "$1" != "debug" && "$1" != "report"
        ]]; then
            python -m coverage run manage.py test $args
        else
            if [[ "$1" == "html" ]]; then
                :
            fi
            python -m coverage $args

            # Customize the HTML here if needed.

            if [[ "$1" == "html" ]]; then
                shift
                res="file://`path_auto $BASE_WWW`/backend/htmlcov/index.html"
                prnt "HTML Coverage generated in \"$res\""
                if [[ "$1" == "open" ]]; then
                    if [[ "$BROWSER" ]]; then
                        case "$BROWSER" in
                            firefox) firefox "$res" ;;
                        esac
                    fi
                fi
            fi
        fi

    elif [[ "$1" == "update" ]]; then
        shift
        if [[ "$1" == "pip" ]]; then
            cd "$BASE"
            if [[ "$IS_LIVE" ]]; then
                pip-compile -U prod.requirements.in
                python -m pip install -r prod.requirements.txt
            else
                pip-compile -U local.requirements.in
                python -m pip install -r local.requirements.txt
            fi
        fi
    elif [[ "$1" == "url" || "$1" == "urls" ]]; then
        shift
        python manage.py show_urls --format=table $*

    elif [[ "$1" == "dump" ]]; then
        shift
        if [[ "$1" == "database" || "$1" == "db" ]]; then
            shift
            dt=$(date '+%d-%m-%Y--%H-%M-%S');
            if [[ "$1" != "" ]]; then
                app_name=$1
                shift
                name="$BASE/backups/backup-$HOSTNAME-$app_name-$dt.json"
                prnt "Creating db backup for ${c_moxcol_lime}${app_name}${c_prnt_info}, please wait..."
            else
                name="$BASE/backups/backup-$HOSTNAME-$dt.json"
                prnt "Creating db backup, please wait..."
            fi
            python manage.py dumpdata --indent 4 --exclude auth --exclude contenttypes --exclude sessions --natural-foreign $* >$name
            retVal=$?
            if [ $retVal -ne 0 ]; then
                prnt "Backup was not created due to errors."
            else
                prnt "Backup created: ${c_white}\"$name\"${c_prnt_info}"
            fi
        fi
    elif [[ "$1" == "zip" ]]; then
        shift
        dj zip $*
    elif [[ "$1" == "jspo" ]]; then
        shift
        dj makemessages --all -e js -d djangojs --ignore="resources/i18n/**/djangojs.js" --ignore="**/locale/djangojs.pot" --ignore="**/htmlcov/**/*.js" $*
    elif [[ "$1" == "jsmo" ]]; then
        shift
        dj compilejsi18n $*
    elif [[ "$1" == "makepo" ]]; then
        shift
        dj makemessages --ignore venv -l $*
    elif [[ "$1" == "makemo" ]]; then
        shift
        dj compilemessages $*
    else
        dj $*
    fi
    cd "$_B"
else
    if [[ "$1" == "HELP" || "$1" == "SHORT_HELP" ]]
    then
        if [[ "$2" != "" ]]; then
            echo "serve" >"$2"
            echo "Run server ${c_moxcol_green}env:DEV_SERVER${c_moxcol_gray}(=$DEV_SERVER)${c_reset}" >>"$2"

            echo "coverage [app]" >>"$2"
            echo "Coverage tests the Django project." >>"$2"

            echo "coverage xml" >>"$2"
            echo "Generate the XML for coverage" >>"$2"

            echo "coverage html [open]" >>"$2"
            echo "Generate HTML and opens in ${c_moxcol_green}env:BROWSER${c_moxcol_gray}(=`basename "$BROWSER"`)${c_reset}" >>"$2"

            echo "update pip" >>"$2"
            echo "Updates local PIP packages." >>"$2"

            echo "urls [app]" >>"$2"
            echo "Shows urls." >>"$2"

            echo "dump db [app]" >>"$2"
            echo "Dumps database." >>"$2"

            echo "zip" >>"$2"
            echo "Zips all/new site file(s) into. mox.${c_moxcol_green}env:HOSTNAME${c_moxcol_gray}(=$HOSTNAME)${c_reset}.zip" >>"$2"

            echo "jspo" >>"$2"
            echo "Collect Javascript translations, makesmessages of all for DjangoJS domain." >>"$2"

            echo "jsmo" >>"$2"
            echo "Collect Javascript translations, compilejsi18n and copies to frontend." >>"$2"

            echo "makepo [locale]" >>"$2"
            echo "Updates .PO files for the specific locale (ar, en ...etc)." >>"$2"

            echo "makemo" >>"$2"
            echo "Collect .PO files and compile them." >>"$2"
        fi
        if [[ "$1" == "SHORT_HELP" ]]
        then
            echo -e "Run the Django helper (preferrable way instead of just calling dj.)"
        else
            echo -e "Run the Django helper (cd into BASE_WWW/backend and do dj. then back.)\nIt's the preferrable way instead of just calling dj."
        fi
    fi
fi
