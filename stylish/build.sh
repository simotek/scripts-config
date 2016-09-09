#!/bin/bash

function __build_help()
{
    # try - http://www.tldp.org/LDP/abs/html/here-docs.html thanks to cooper12 on reddit
    echo -e "  build  script- Build script for stylish"
    echo -e "\t Version 0.0.1"
  #  echo -e "--------------------------------------------------------------------------\n"
  #  echo -e "  Usage:"
  #  echo -e "\t hiset [name]\t\t Switchs to history with given session name"
  #  echo -e "\t hiset -l \t\t Lists all known sessions"
  #  echo -e "\t hiset --history \t Lists complete history of all sessions"
  #  echo -e "\t hiset --search [name]\t Searches for the string name in all history files"
    echo -e "--------------------------------------------------------------------------\n"
    echo -e "  Arguments:"
    echo -e "\t -c\t --conf [name]\t Specify the config file to read from."
    echo -e "\t -h\t --help\t\t\t Prints this help, See man hiset for more info"
    echo -e "--------------------------------------------------------------------------\n"
  #  echo -e "  Variables:"
  #  echo -e '\t$HISET\t\t The current session name.'
  #  echo -e '\t$HISET_PREFIX\t\t The prefix given to all history files, defaults to ".bash_history_hiset_"'
  #  echo -e '\t$HISET_DIR\t\t The directory where history files are stored, defaults to "$HOME"'
  #  echo -e '\n'
  #  echo -e '\t * note that long options may not work on all bsd systems'
}

function __build_template()
{
    echo "$1"
    local OUT_FILE=`dirname $0`/build/temp-`basename $1`
    rm -v $OUT_FILE
    
    cp -v `dirname $0`/template/`basename $1` $OUT_FILE
    
    echo "sed -i s/@@LINK@@/$SYL_LINK_COLOR/g $OUT_FILE"
    sed -i "s/@@LINK@@/$SYL_LINK_COLOR/g" $OUT_FILE
}

HST_CONF=0
HST_CONF_PARAM=""
HST_HELP=0
HST_INVALID=0

OPTS=`getopt -o :c:h: -l conf:,help -- "$@"` 

eval set -- "$OPTS"

while true ; do
    case "$1" in
        -c)     HST_CONF=1; HST_CONF_PARAM=$2; shift 2;;
        --conf) HST_CONF=1; HST_CONF_PARAM=$2; shift 2;;
        -h)     HST_HELP=1; shift;;
        --help) HST_HELP=1; shift;;
        --?)    HST_INVALID=1; shift; break;;
        --) shift; break;;
    esac
done
    
if [ $HST_INVALID -eq 1 ] ; then
    echo "Invalid option: see --help"
elif [ $HST_HELP -eq 1 ] ; then
    __build_help
elif [ $HST_CONF -eq 1 ] ; then

    if [ ! -e "$HST_CONF_PARAM" ] ; then
        echo "Config file not found."
        exit
    fi
    
    source "$HST_CONF_PARAM"

    mkdir -p "`dirname $0`/build"
    
    for f in `dirname $0`/template/*; do
        __build_template $f
    done
    #popd
    
    FINAL_FILE=`dirname $0`/final.css
    
    rm $FINAL_FILE
    find `dirname $0` -type f -name 'temp-*.css' -exec cat {} + >> $FINAL_FILE
    
else
    echo "Error"
fi

