#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#


help(){
    echo 
    echo "Usage of CRAWL "
    echo
    echo "-" 
    echo "Examples : 4CRWL.sh COMBINED_ENUM or COMBINED_HTTP / NAMEOFSITE"
    echo "File Will Be Saved : COMBINED_CRWL"
}

if [ "$1" == "-h" ]; then help ; exit 0 ; fi
if [ ! -f "$1" ]; then help ; echo ; echo "File Not Found !" ;  exit 2 ; fi 
#if [ ! -d "STKO"     ]; then mkdir -p STKO ;     fi


URLS=$1  
#NAME=$2

main(){
	echo "-----------------------------------------------------"
    echo
    echo "[+] STARTING CRAWLING"
    echo "[-] waybackurls [-] gau"
    echo  
    echo

    #screen -AmdS $NAME-CRAWLING_HAKRAWLER bash
    #screen -AmdS $NAME-CRAWLING_WAYBACKURLS bash
    #screen -AmdS $NAME-CRAWLING_GAU bash
    sleep 1
    cat $URLS | waybackurls | tee CRAWLING_WAYBACKURLS
    #screen -S $NAME-CRAWLING_HAKRAWLER -p 0 -X stuff $'cat '"$URLS"' | hakrawler -plain -usewayback >> CRAWLING_HAKRAWLER ; exit \r'
    # screen -r CRAWLING_HAKRAWLER

    echo 
    echo 
    echo "GAU"
    sleep 3
    cat $URLS | sed 's~http[s]*://~~g' | sed 's/\/.*//' | awk -F"." '{print $(NF-1)"."$NF}' | sort -u | gau | tee CRAWLING_GAU
    #screen -S $NAME-CRAWLING_WAYBACKURLS -p 0 -X stuff $'cat '"$URLS"' | waybackurls >> CRAWLING_WAYBACKURLS ; exit \r'
    #screen -r CRAWLING_WAYBACKURLS

    #screen -S $NAME-CRAWLING_GAU -p 0 -X stuff $'cat '"$URLS"' | gau -subs -random-agent >> CRAWLING_GAU ; exit \r'
    # screen -r CRAWLING_GAU

    #while [ $(screen -list | grep -ic $NAME-CRAWLING) != 0 ]; do
    #    echo -ne "      - Waiting For Crawling : Seconds $i : Session Running $(screen -list | grep -ic $NAME-CRAWLING)" \\r
    #    let "i+=1"
    #    sleep 1
    #done

    echo
    echo
    echo
    cat CRAWLING_* | sort -u | tee COMBINED_CRWL
    echo "DOMAIN : "$(wc COMBINED_CRWL)
    echo "[+] CRAWLING DONE"
    echo
    echo "-----------------------------------------------------"

    rm -rf CRAWLING_*
    # for i in {0..3} ; do sleep 1 ; espeak "CRAWLING IS DONE" ; done
    notify-send -u critical -i terminal "crawling Execution complete"
}

main
