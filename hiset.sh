#!/bin/bash

# Copyright (C) 2014 Simon Lees
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation  and/or other materials provided with the distribution.
# 3. Neither the names of the copyright holders nor the names of any
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.


function __hst_help()
{
    echo -e "  hiset - A bash history file manager"
    echo -e "\t Version 0.0.1b01"
    echo -e "--------------------------------------------------------------------------\n"
    echo -e "  Usage:"
    echo -e "\t hiset [name]\t\t Switchs to history with given session name"
    echo -e "\t hiset -l \t\t Lists all known sessions"
    echo -e "\t hiset --history \t Lists complete history of all sessions"
    echo -e "\t hiset --search [name]\t Searches for the string name in all history files"
    echo -e "--------------------------------------------------------------------------\n"
    echo -e "  Arguments:"
    echo -e "\t -D\t --delete [name]\t Deletes history file with the given name if it exists"
    echo -e "\t -h\t --help\t\t\t Prints this help, See man hiset for more info"
    echo -e "\t -H\t --history\t\t Prints the history of all sessions, to print the current session history use the history command"
    echo -e "\t -l\t --list\t\t\t Lists all known sessions."
    echo -e "\t -r\t --reset\t\t Resets history to use standard .bash_history file"
    echo -e "\t -s\t --search [name]\t Searches for name in all history files"
    echo -e "--------------------------------------------------------------------------\n"
    echo -e "  Variables:"
    echo -e '\t$HISET\t\t The current session name.'
    echo -e '\t$HISET_PREFIX\t\t The prefix given to all history files, defaults to ".bash_history_hiset_"'
    echo -e '\t$HISET_DIR\t\t The directory where history files are stored, defaults to "$HOME"'
}

function __hst_history()
{
    local LOCAL_DIR=$HISET_DIR
    if [ -z "$LOCAL_DIR" ]; then
        LOCAL_DIR=$HOME
    fi
    local LOCAL_PREFIX=$HISET_PREFIX
    if [ -z "$LOCAL_PREFIX" ]; then
        LOCAL_PREFIX=".bash_history_hiset_"
    fi
    
    # As a hack color the colon black, if someone can figure out how to remove it and preserve colors
    # that would be fantastic
    local TMP_GREP_COLORS=$GREP_COLORS
    export GREP_COLORS='se=30'
    
    # First Print out original .bash_history
    echo -e "\033[01;34mHistory from \033[01;33m.bash_history\033[00m"
    grep  -n -T --binary-files=text "" $HOME/.bash_history
    
    pushd $LOCAL_DIR >/dev/null
    for F in `find . -maxdepth 1 -name "$LOCAL_PREFIX*"`; do
        # Leave $HISET till last
        local CUT_FILE=${F#${F:0:${#LOCAL_PREFIX}+2}}
        if [ "$CUT_FILE"!="$HISET" ]; then
            echo -e "\033[01;34mHistory from \033[01;33m${CUT_FILE}\033[00m"
            grep -n -T --binary-files=text "" $F
        fi
    done
    popd >/dev/null
    
    # Print out the current session (Its probably the one the user cares about
    if [ -n "$HISET" ]; then
        echo -e "\033[01;34mHistory from \033[01;33m${HISET}\033[00m"
        grep -n -T --binary-files=text  "" $HOME/$LOCAL_PREFIX$HISET
    fi
    export GREP_COLORS=$TMP_GREP_COLORS

}

function __hiset_search()
{
    local LOCAL_DIR=$HISET_DIR
    if [ -z "$LOCAL_DIR" ]; then
        LOCAL_DIR=$HOME
    fi
    local LOCAL_PREFIX=$HISET_PREFIX
    if [ -z "$LOCAL_PREFIX" ]; then
        LOCAL_PREFIX=".bash_history_hiset_"
    fi
    
    # As a hack color the colon black, if someone can figure out how to remove it and preserve colors
    # that would be fantastic
    local TMP_GREP_COLORS=$GREP_COLORS
    export GREP_COLORS='se=30'
    
    # First Print out original .bash_history
    cat $HOME/.bash_history | grep  -n --label=".bash_history" -H -T --binary-files=text "$1"
    
    pushd $LOCAL_DIR >/dev/null
    for F in `find . -maxdepth 1 -name "$LOCAL_PREFIX*"`; do
        # Leave $HISET till last
        local CUT_FILE=${F#${F:0:${#LOCAL_PREFIX}+2}}
        local TMP_COUNT=$(grep -c $1 $F)
        if [ $TMP_COUNT -gt 0 ]; then
            cat $F | grep -n --label="$CUT_FILE" -H -T --binary-files=text "$1"
        fi
    done
    popd >/dev/null
    
    export GREP_COLORS=$TMP_GREP_COLORS
}

function hiset()
{
    local HST_DELETE=0
    local HST_DELETE_PARAM=""
    local HST_HELP=0
    local HST_HISTORY=0
    local HST_INVALID=0
    local HST_LIST=0
    local HST_RESET=0
    local HST_SEARCH=0
    local HST_SEARCH_PARAM=""

    OPTS=`getopt -o :D:hHlrs: -l delete:,help,history,History,list,reset,search: -- "$@"`
    if [ $? != 0 ]
    then
        HST_INVALID=1
    fi

    eval set -- "$OPTS"
    
    
    
    while true ; do
        case "$1" in
            -D)     HST_DELETE=1; HST_DELETE_PARAM=$2; shift 2;;
            --delete) HST_DELETE=1; HST_DELETE_PARAM=$2; shift 2;;
            -h)     HST_HELP=1; shift;;
            --help) HST_HELP=1; shift;;
            -H)     HST_HISTORY=1; shift;;
            --History) HST_HISTORY=1; shift;;
            --history) HST_HISTORY=1; shift;;
            -l)     HST_LIST=1; shift;;
            --list) HST_LIST=1; shift;;
            -r)     HST_RESET=1; shift;;
            --reset) HST_RESET=1; shift;;
            -s)     HST_SEARCH=1; HST_SEARCH_PARAM=$2; shift 2;;
            --search) HST_SEARCH=1; HST_SEARCH_PARAM=$2; shift 2;;
            --?)    HST_INVALID=1; shift; break;;
            --) shift; break;;
        esac
    done
    
    local LOCAL_DIR=$HISET_DIR
    if [[ -z "$LOCAL_DIR" ]]; then
        LOCAL_DIR=$HOME
    fi
    local LOCAL_PREFIX=$HISET_PREFIX
    if [[ -z "$LOCAL_PREFIX" ]]; then
        LOCAL_PREFIX=".bash_history_hiset_"
    fi
       
    
    if [ $HST_INVALID -eq 1 ] ; then
        echo "Invalid option: see --help"
    elif [ $HST_DELETE -eq 1 ] ; then
        if [ -f "$LOCAL_DIR/$LOCAL_PREFIX$HST_DELETE_PARAM" ]; then
            rm "$LOCAL_DIR/$LOCAL_PREFIX$HST_DELETE_PARAM"
        fi
    elif [ $HST_HELP -eq 1 ] ; then
        __hst_help
    elif [ $HST_HISTORY -eq 1 ] ; then
        __hst_history
    elif [ $HST_LIST -eq 1 ] ; then
        pushd $LOCAL_DIR >/dev/null
        for F in `find . -maxdepth 1 -name "$LOCAL_PREFIX*"`; do
            # Leave $HISET till last
            local CUT_FILE=${F#${F:0:${#LOCAL_PREFIX}+2}}
            
            # output a * next to current
            if [ "$CUT_FILE" == "$HISET" ]; then
                echo -e "\033[01;33m${CUT_FILE} \033[01;34m*\033[00m"
            else
                echo -e "\033[01;33m${CUT_FILE}\033[00m"
            fi
        done
        popd >/dev/null
    elif [ $HST_RESET -eq 1 ] ; then
        export HISTFILE="$HOME/.bash_history"
        export HISET=""
    elif [ $HST_SEARCH -eq 1 ] ; then
        __hiset_search $HST_SEARCH_PARAM
    else
        if [ -n $1 ]; then
            # Write current history to existing history file
            history -a
            
            # Make new directory if it doesn't exist
            mkdir -p $LOCAL_DIR
                        
            export HISTFILE="$LOCAL_DIR/$LOCAL_PREFIX$1"
            export HISET=$1
            
            # touch the new file to make sure it exists
            touch $HISTFILE
            # load new history file
            history -r $HISTFILE
            
        else
	    history -a
        
            export HISTFILE="$HOME/.bash_history"
            export HISET=""
        fi
    fi
    
    # TBD: implement http://stackoverflow.com/questions/14786984/best-way-to-parse-cmdline-args-bash 
    # and move history into this command
	
	# you may want your history file in your prompt
	#export PS1="\[$(ppwd)\]\u@\h-\[$(echo $HISET)\]:\w>"
}

function _hiset()
{


    local LOCAL_DIR=$HISET_DIR
    if [[ -z "$LOCAL_DIR" ]]; then
        LOCAL_DIR=$HOME
    fi
    local LOCAL_PREFIX=$HISET_PREFIX
    if [[ -z "$LOCAL_PREFIX" ]]; then
        LOCAL_PREFIX=".bash_history_hiset_"
    fi

    local HST_COMP=""
    pushd $LOCAL_DIR >/dev/null
        for F in `find . -maxdepth 1 -name "$LOCAL_PREFIX*"`; do
            # Leave $HISET till last
            local CUT_FILE=${F#${F:0:${#LOCAL_PREFIX}+2}}
            
            # output a * next to current
            if [ -z "$HST_COMP" ]; then
                HST_COMP=$CUT_FILE
            else
                HST_COMP="$HST_COMP $CUT_FILE"
            fi
        done
    popd >/dev/null

    local cur=${COMP_WORDS[COMP_CWORD]}
    COMPREPLY=( $(compgen -W "$HST_COMP" -- $cur) )
    
    local HST_LONG_OPTS="--delete --help --history --History --list --reset --search"
    local HST_SHORT_OPTS="-D -h -H -l -r -s"
    if [[ "$cur" == --* ]]; then
        if [[ "$cur" != "--delete" ]]; then
            COMPREPLY=( $(compgen -W "$HST_LONG_OPTS" -- $cur) )
        fi
    fi
    
    if [[ "$cur" == -* ]]; then
        if [[ "$cur" != "--delete" ]]; then
            COMPREPLY=( $(compgen -W "$HST_LONG_OPTS $HST_SHORT_OPTS" -- $cur) )
        fi
    fi
}
complete -F _hiset hiset
