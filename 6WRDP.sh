#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#

help(){

    echo 
    echo "Usage of ENUM "
    echo
    echo "-" 
    echo "Examples : 6WRDP.sh COMBINED_ENUM"
    echo 
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 


URLS=$1  

main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING WORDPRESS EXPLOIT"
    echo "[-] wpscan"
    echo ""
    echo
 
    screen -AmdS EXPLOIT_WORDSPRESS bash
    screen -S EXPLOIT_WORDSPRESS -p 0 -X stuff $'cat '"$URLS"' | xargs -I@ wpscan --url @ --enumerate vp --api-token '"$wpscan_api_token"' >> WORDSPRESS_REPORT'
    screen -r EXPLOIT_WORDSPRESS

    echo
    echo
    echo
    echo "[+] WPSCAN DONE"
    echo
    echo "-----------------------------------------------------"

    # for i in {0..3} ; do sleep 1 ; espeak "CRAWLING IS DONE" ; done
    notify-send -u critical -i terminal "WORDPRESS exploit Execution complete"
}

main