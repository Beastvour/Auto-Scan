#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#


help(){

    echo 
    echo "Usage of ENUM "
    echo
    echo "-" 
    echo "Examples : 5XXSS.sh COMBINED_CRAWL  "
    echo 
    #echo "File Will Be Saved : COMBINED_CRAWLING"
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 


URLS=$1  

main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING XSS"
    echo "[-] kxss [-] dalfox"
    echo "File Will CREATE : 'XSS_FUZZ' for Vulnerable Sites"
    echo "Vulnerable POC Will Be SAVED : 'XSS_DALFOX_POC'"
    echo

    cat $URLS | sort -u | grep "=" | kxss | sed 's/URL: //' | tee XSS_FUZZ
    cat XSS_FUZZ | sed 's/=.*/=/' | sort -u | dalfox pipe --custom-payload /home/kali/files/myBruteWords/xss-payload.txt --timeout 20 -o XSS_DALFOX_POC

    echo
    echo
    echo
    echo "[+] XSS DONE"
    echo
    echo "-----------------------------------------------------"

    # for i in {0..3} ; do sleep 1 ; espeak "CRAWLING IS DONE" ; done
    notify-send -u critical -i terminal "XSS Exploit Execution complete"
}

main