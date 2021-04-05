#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#

help(){
    echo 
    echo "Usage of SQL "
    echo
    echo "-" 
    echo "Examples : 9SQLI.sh COMBINED_CRWL"
    echo "It will save file " 
    echo
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 

URLS=$1  

main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING SQL EXPLOIT"
    echo "[-] dsss.py "
    echo ""
    echo
    
    cat COMBINED_CRWL | grep "=" | xargs -I@ python3 /home/kali/files/github/DSSS/dsss.py -u "@" >> SQLI_DSSS_REPORTS
    
    echo
    echo
    echo
    echo "[+] SQL DONE"
    echo
    echo "-----------------------------------------------------"

    # for i in {0..3} ; do sleep 1 ; espeak "CRAWLING IS DONE" ; done
    notify-send -u critical -i terminal "SQL exploit Execution complete"
}

main