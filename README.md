scripts-config
==============

Scripts /  config files that i use across multiple machines, includes the hiset history script as described below 


Hiset
=====

hiset (history set) pronounced hi-set is a simple script to manage multiple history files, it works by manipulating __$HISFILE__ meaning that the history command can work as normal within the current session>
It also includes tab completion for everything to make life easier. [Blog about why i made this](http://simotek.net/tech/hiset-multiple-history-files-and-sessions-for-bash-and-other-tinkering/)


![Listing history files hiset -l](http://simotek.net/wp-content/gallery/hiset/hiset-list.jpg "Listing history files hiset -l")

Installation
------------
To install copy the hiset file to your local machine and source it in your .bashrc eg:
````bash
source hiset
````
You may also want to add your current session to your prompt by adding the __$HISET__ variable to the __$PS1__ Variable eg:
````bash
PS1="$PS1 $(echo $HISET)"
````

Usage
-----
hiset [name]            Switchs to history with given session name  
hiset -l                Lists all known sessions  
hiset --history         Lists complete history of all sessions  
hiset --search [name]   Searches for the string name in all history files  

Arguments
---------
-D  --delete [name] Deletes history file with the given name if it exists  
-h  --help          Prints this help, See man hiset for more info  
-H  --history       Prints the history of all sessions, to print the current session history use the history command  
-l  --list          Lists all known sessions.  
-r  --reset         Resets history to use standard .bash_history file  
-s  --search [name] Searches for name in all history files  

Variables
---------
$HISET              The current session name.  
$HISET_PREFIX       The prefix given to all history files, defaults to ".bash_history_hiset_"  
$HISET_DIR          The directory where history files are stored, defaults to "$HOME"  

![Searching with hiset -s](http://simotek.net/wp-content/gallery/hiset/hiset-search.jpg "Searching with hiset -s")

GPG Fingerprint
===============
5B87 DB9D 88DC F606 E489 CEC5 0922 C246 02F0 014B

Fish
=====
Note to self, clone the following before starting
https://github.com/simotek/tackle
https://github.com/justinmayer/tacklebox
