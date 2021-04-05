#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#


help(){

    echo 
    echo "Usage of HTTP "
    echo
    echo "-" 
    echo "Examples : 2HTTP.sh COMBINED_ENUM "
    echo "File Will Be Saved : COMBINED_HTTP"
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 


URLS=$1 

main(){
    echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING HTTP PROBERS "
    echo "[-] httpx [-] httprobe"
    echo "File Will Be Saved : COMBINED_HTTP"
    echo  
    echo
    cat $URLS | httprobe -c 200 -t 20000 | tee HTTP_HTTPROBE
    httpx -l $URLS -silent -timeout 20 -o HTTP_HTTPX
    httpx -l $URLS -title -content-length -status-code -timeout 20 -o HTTP_STATUS_CODE
     
    echo
    echo
    echo
    cat HTTP_HTTPROBE HTTP_HTTPX | sort -u | tee COMBINED_HTTP
    echo "HTTP : "$(wc COMBINED_HTTP)
    echo "[+] HTTP PROVING DONE"
    echo
    echo "-----------------------------------------------------"

    rm HTTP_HTTPROBE HTTP_HTTPX
    # for i in {0..3} ; do sleep 1 ; espeak "HTTP PROVING IS DONE" ; done
    notify-send -u critical -i terminal "Http Proving Execution complete"
}

main