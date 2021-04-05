#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#

help(){
    echo 
    echo "Usage of NMAP "
    echo
    echo "-" 
    echo "Examples : 8NMAP.sh COMBINED_CRWL"
    echo "It will save file NMAP_REPORTS" 
    echo
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 

URLS=$1  

main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING NMAP EXPLOIT"
    echo "[-] nmap "
    echo ""
    echo
 
    nmap -sV --script=vulscan,vulners,"(*cve*)" -Pn -iL $URLS >> NMAP_REPORTS

    echo
    echo
    echo
    echo "[+] NMAP DONE"
    echo
    echo "-----------------------------------------------------"

    # for i in {0..3} ; do sleep 1 ; espeak "CRAWLING IS DONE" ; done
    notify-send -u critical -i terminal "NMAP exploit Execution complete"
}

main