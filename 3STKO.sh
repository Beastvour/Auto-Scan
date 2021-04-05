#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#


help(){
    echo 
    echo "Usage of STKO "
    echo
    echo "-" 
    echo "Examples : 3HTTP.sh COMBINED_ENUM or COMBINED_HTTP "
    echo "File Will Be Saved : STKO/STKO_*"
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 
if [ ! -d "STKO"     ]; then mkdir -p STKO ;     fi


URLS=$1 
pyasubdover="python3 /home/kali/files/github/subdover/subdover.py"
CHROME="/home/kali/files/github/chromium-latest-linux/864970/chrome-linux/chrome"
NTHIM="/home/kali/files/github/NtHiM/target/debug/NtHiM"
main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING SUBDOMAIN TAKEOVER"
    echo "[-] subzy [-] subdover [-] subjack [-] aquatone"
    echo  
    echo

    subzy -targets $URLS -timeout 30 | tee STKO/STKO_subzy
    #subjack -v -w $URLS -t 30 -t 20 -o STKO/STKO_subjack
    #$pyasubdover -l $URLS -t 20 -o STKO/STKO_subdover
    cat $URLS | aquatone -http-timeout 20000 -scan-timeout 20000 -ports xlarge -chrome-path $CHROME -out STKO/STKO_aquatone
    $NTHIM -f $URLS --threads 50 >> STKO/STKO_NtHiM


    echo
    echo
    echo
    echo "[+] SUBDOMAIN TAKEOVER DONE"
    echo
    echo "-----------------------------------------------------"
    # for i in {0..3} ; do sleep 1 ; espeak "SUBDOMAIN TAKEOVER IS DONE" ; done
    notify-send -u critical -i terminal "Subdomain takeover Execution complete"
}

main