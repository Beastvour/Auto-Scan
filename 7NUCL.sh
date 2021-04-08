#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#

help(){
    echo 
    echo "Usage of NUCL "
    echo
    echo "-" 
    echo "Examples : 7NUCL.sh COMBINED_HTTP"
    echo "It will save to folder nuclei/*" 
    echo
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 
if [ ! -d "nuclei" ]; then mkdir -p nuclei ; fi

URLS=$1  

main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING NUCLEI"
    echo "[-] nuclei "
    echo ""
    echo
 
    nuclei -l $URLS -t /home/kali/nuclei-templates/cves/ -silent -c 50 -o nuclei/cves
    nuclei -l $URLS -t /home/kali/nuclei-templates/vulnerabilities/ -silent -c 50 -o nuclei/vulnerabilities
    nuclei -l $URLS -t /home/kali/nuclei-templates/misconfiguration/ -silent -c 50 -o nuclei/misconfiguration
    nuclei -l $URLS -t /home/kali/nuclei-templates/exposed-tokens/ -silent -c 50 -o nuclei/exposed-tokens
    nuclei -l $URLS -t /home/kali/nuclei-templates/exposed-panels/ -silent -c 50 -o nuclei/exposed-panels
    nuclei -l $URLS -t /home/kali/nuclei-templates/fuzzing/ -silent -c 50 -o nuclei/fuzzing
    nuclei -l $URLS -t /home/kali/nuclei-templates/default-logins/ -silent -c 50 -o nuclei/default-logins
    nuclei -l $URLS -t /home/kali/nuclei-templates/technologies/ -silent -c 50 -o nuclei/technologies
    nuclei -l $URLS -t /home/kali/nuclei-templates/takeovers/ -silent -c 50 -o nuclei/takeovers

    echo
    echo
    echo
    echo "[+] nuclei DONE"
    echo
    echo "-----------------------------------------------------"

    # for i in {0..3} ; do sleep 1 ; espeak "CRAWLING IS DONE" ; done
    notify-send -u critical -i terminal "NUCLEI exploit Execution complete"
}

main
