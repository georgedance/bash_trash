#!/bin/bash

# these are defaults, and shouldn't overwrite user defined vars
if [ -z $XDG_CONFIG_HOME ]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z $XDG_DATA_HOME ]; then
    export XDG_DATA_HOME="$HOME/.local/share"
fi
if [ -z $TRASHDIR ]; then
    export TRASHDIR="$XDG_DATA_HOME/Trash"
fi



function trash-init() {

    if [ ! -d $TRASHDIR ]; then
        mkdir -pv $TRASHDIR
    fi
    if [ ! -d $TRASHDIR/files ]; then
        mkdir -pv $TRASHDIR/files
    fi
    if [ ! -d $TRASHDIR/info ]; then
        mkdir -pv $TRASHDIR/info
    fi

}

# when this file is sourced, it should run this function automatically
trash-init



# main trash functions

function trash-list() {

    # returns 1 if there aren't any files in $TRASHDIR

    FILELIST=$(ls "$TRASHDIR"/files | xargs)

    if [ "$FILELIST" ]; then
        printf "%s\t%s\t%s\n" "Filename" "Deleted On" "File Path"
        for file in $FILELIST
        do
            _trash_infofile_validate "$file" && printf "%s\t%s\t%s\n" "$file" \
                "`date -d$TRASH_DATE +'%a, %_d %b %I:%M %p'`" "$TRASH_PATH"
        done
    else
        return 1
    fi

}

function trash-put() {

    # this should essentially replace your "rm".

    for file in "$@"
    do
        # find how to avoid race conditions
        #  - pray to avoid race conditions
        # if a file in $TRASHDIR/info with the same name already exists, title it something else and try again
        #  - append "underscore number" to filename, where number is 1 greater than whatever's already there

        # test if the file exists
        # TODO: 
        if [ ! -e $file ]; then
            echo file \'$file\' doesn\'t exist!
            continue
        fi

        name=$(basename $file)

        #set -x
        # actually check lockfiles instead of files in trash
        number=$(ls $TRASHDIR/files | grep "^${name}_\?[1-9]\?[0-9]\?[0-9]\?$" | wc -l)
        #set +x
        if [ $number -gt 0 ]; then
            number=$(echo _$number)
        else
            number=""
        fi

# o o f .   TODO: redo this whole locking thing.
:<<'EOF'
# look for lock, if there is a lock, change name, if not, make lock 
#mkdir -pv $TRASHDIR/work
TRASH_LOCK="$TRASHDIR/work/$name$number.lockfile"
while [ $(flock -n $TRASH_LOCK) ]
do 
    number=$(echo $number | cut -d'_' -f2-)
    number=$((number + 1))
    number=$(echo _$number)
    TRASH_LOCK="$TRASHDIR/work/$name$number.lockfile"
    touch $TRASH_LOCK
done
EOF

        _trash_infofile_create "$file" "$number"

        # DEBUG
        # -vi flags for verbosity
        mv "$file" "$TRASHDIR/files/$name$number"
    done

}

function trash() {

    # passes the parameters onto trash-put. you may want to alias rm to trash.

    trash-put "$@"

}

# TODO: implement this function
function trash-restore() {

    echo unimplemented

}

# FIXME: redo this whole function
function trash-empty() {

    # this behaviour tried to emulate trash-cli's trash-empty. it works alright though.

    echo "Would empty the following trash directories:"

    TRASHDIRS="$TRASHDIR"

    for dir in "$TRASHDIRS"
    do
        printf "\t- %s\n" $dir
    done
    read -p "Proceed? (y/n): " choice
    case "$choice" in
        y|Y|yes|YES|Yes)
            echo "continuing"
            for dir in "$TRASHDIRS"
            do
                # check if there are actually files to delete
                for file in "$(ls $dir/files/)"
                do
                    # danger
                    $(which rm) -vi "$dir/files/$file"
                done
            done
            ;;
        *)
            echo "cancelled"
            ;;
    esac

}

# TODO: implement this function
function trash-rm() {

    # find matching files and prompt to remove if there is multiple files

    echo unimplemented

}



# internal functions

function _trash_infofile_validate() {

    # read $TRASHDIR/info files and present as a list
    #  - must ignore everything except the header, Path=, and DeletionDate=
    #     - must use the first occurence of each

    infoval="$1"

    TRASH_HEADER=$(grep "^\[Trash Info\]" "$TRASHDIR/info/$infoval.trashinfo" 2> /dev/null)
    if [ "$TRASH_HEADER" ]; then
        # DEBUG
        #echo header found: $TRASH_HEADER
        echo -ne
        # no return here, incase the .trashinfo file is messed up, but still has path and date
    fi

    TRASH_PATH=$(grep "^Path=" "$TRASHDIR/info/$infoval.trashinfo" 2> /dev/null)
    if [ "$TRASH_PATH" ]; then
        # DEBUG
        #echo path found: $TRASH_PATH
        TRASH_PATH=$(echo $TRASH_PATH | cut -d= -f2-)
    else
        return 1
    fi

    TRASH_DATE=$(grep "^DeletionDate=" "$TRASHDIR/info/$infoval.trashinfo" 2> /dev/null)
    if [ "$TRASH_DATE" ]; then
        # DEBUG
        #echo date found: $TRASH_DATE
        TRASH_DATE=$(echo $TRASH_DATE | cut -d= -f2-)
    else
        return 1
    fi

    return 0

}

function _trash_infofile_create() {

    # create file in $TRASHDIR/info for file
    #  - put header
    #  - escape filename
    #     - urlencode()
    #  - get timestamp
    #     - YYYY-MM-DDThh:mm:ss format
    #date -Iseconds | cut -d+ -f1

    infocrt="$1"
    infocrtnum="$2"

    # not sure if this check is entirely neccesary...
    if [ $3 ]; then
        echo only use this function with 2 parameters. exiting now.
        win_pause
        exit
    fi

    TRASHINFOFILE="$TRASHDIR/info/$infocrt$infocrtnum.trashinfo"

    echo [Trash Info] >> $TRASHINFOFILE
    echo Path=`urlencode $(realpath $infocrt)` >> $TRASHINFOFILE
    echo DeletionDate=`date -Iseconds | cut -d+ -f1` >> $TRASHINFOFILE
    echo >> $TRASHINFOFILE

}



# utility functions

function urlencode() {

    TEXT="$@"
    python -c "import urllib.parse; print(urllib.parse.quote('$TEXT'))"

}

function urldecode() {

    TEXT="$@"
    python -c "import urllib.parse; print(urllib.parse.unquote('$TEXT'))"

}

function win_pause() {

    read -p "Press any key to continue..."

}

