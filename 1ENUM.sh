#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#
 
help(){

    echo 
    echo "Usage of ENUM "
    echo
    echo "-" 
    echo "Examples : 1ENUM.sh domains.txt output"
    echo 
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
# if [ -z "$2" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 

for p in subfinder assetfinder findomain amass ; do
    hash "$p" &>/dev/null && echo "[✅] Installed - $p" || echo "[❌] Installed - $p";
done

URL=$1  
DATE=$(date "+%F") 
DIRECTORY_FILENAME=F-$URL/$DATE

if [ ! -d "$DIRECTORY_FILENAME" ]; then mkdir -p $DIRECTORY_FILENAME ; fi

main(){
    echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING SUBDOMAIN ENUMERATION"
    echo "[-] subfinder [-] findomain [-] assetfinder [-] amass"
    echo
    echo  

    screen -AmdS $URL-ENUM_SUBFINDER   bash
    screen -AmdS $URL-ENUM_ASSETFINDER bash 
    screen -AmdS $URL-ENUM_FINDOMAIN   bash 
    screen -AmdS $URL-ENUM_AMASS       bash
    sleep 1

    screen -S $URL-ENUM_SUBFINDER -p 0 -X stuff $'subfinder -dL '"$URL"' -silent -o '"$DIRECTORY_FILENAME/ENUM_SUBFINDER"'; exit \r'
    # screen -r $URL-ENUM_SUBFINDER

    screen -S $URL-ENUM_ASSETFINDER -p 0 -X stuff $'cat '"$URL"' | assetfinder -subs-only | tee '"$DIRECTORY_FILENAME/ENUM_ASSETFINDER"'; exit \r'
    # screen -r $URL-ENUM_ASSETFINDER

    screen -S $URL-ENUM_FINDOMAIN -p 0 -X stuff $'findomain -f '"$URL"' -q -u '"$DIRECTORY_FILENAME/ENUM_FINDOMAIN"'; exit \r'
    # screen -r $URL-ENUM_FINDOMAIN

    screen -S $URL-ENUM_AMASS -p 0 -X stuff $'amass enum -passive -df '"$URL"' -o '"$DIRECTORY_FILENAME/ENUM_AMASS"'; exit \r'
    # screen -r $URL-ENUM_AMASS

    while [ $(screen -list | grep -ic $URL-ENUM) != 0 ]; do
        echo -ne "      - Waiting For Subdomain Enumeration : Seconds $i : Session Running $(screen -list | grep -ic $URL-ENUM)" \\r
        let "i+=1"
        sleep 1
    done

    echo
    echo
    echo
    cat $DIRECTORY_FILENAME/ENUM_* | sort -u | tee $DIRECTORY_FILENAME/COMBINED_ENUM
    echo "DOMAIN : "$(wc $DIRECTORY_FILENAME/COMBINED_ENUM)
    echo "[+] DOMAIN ENUMERATION DONE"
    echo
    echo "-----------------------------------------------------"

    rm -rf $DIRECTORY_FILENAME/ENUM_*
    # for i in {0..3} ; do sleep 1 ; espeak "DOMAIN ENUMERATION IS DONE" ; done
    notify-send -u critical -i terminal "Domain Enumeration Execution complete"
}

main