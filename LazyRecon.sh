#!/bin/bash

#
# Create by Joe Marie Pines on 03/18/21
#


display_help(){
    echo 
    echo "Usage : [FILE] [OUTPUT] [URL FOR: ASSETFINDER/HARVESTER]"
    echo "        @Example LazyRecon.sh host.txt hackerone hackerone.com"
    echo "        First list of Urls"
    echo "        Output Directory"
    echo "        Third Specified url for theHarvester/assetfinder'"
    echo 
}


if [ "$1" == "-h" ]; then display_help ; exit 0 ; fi
if [ $# -lt 3     ]; then display_help ; exit 2 ; fi
if [ ! -f $1      ]; then echo ; echo "File Not Exist : " $1 ; display_help ; exit 2 ; fi


error=NULL
echo "Checking Command If Exist !"
for p in subfinder assetfinder findomain amass httprobe httpx subzy subjack aquatone hakrawler waybackurls wpscan theHarvester ; do
    hash "$p" &>/dev/null && echo "[✅] Installed - $p" || echo "[❌] Installed - $p" $error=Err
done


f_URLS=$1
f_NAME=$2
f_URLL=$3
f_DATE=$(date "+%F")
f_PATH=$f_NAME/$f_DATE
f_SIGN=/usr/share/icons/Windows-10-Icons/256x256/status

# NAMING FILE VARIABLE 
FILE_HTTP=final_http.txt
FILE_RECON=final_recon.txt
FILE_HTTPRESPONSE=final_httpResponse.txt


if [ "$error" != "Err"       ]; then echo "Everything Installed " ; else echo "Missing Install" ; exit 1 ; fi
if [ ! -d "$f_PATH"          ]; then mkdir -p $f_PATH ;          fi
if [ ! -d "$f_PATH/stko"     ]; then mkdir -p $f_PATH/stko ;     fi
if [ ! -d "$f_PATH/wprs"     ]; then mkdir -p $f_PATH/wprs ;     fi
if [ ! -d "$f_PATH/thvr"     ]; then mkdir -p $f_PATH/thvr ;     fi


sub_DEEP_ENUM(){
    amass enum -src -ip -active -brute -d $f_URLL -o domain 
}


sub_ENUM(){
    if [ $(ls | grep -ic enum_) != 0  ]; then 
        echo "      -  Removing this file : " $(ls | grep enum_)
        rm -rf $f_PATH/enum_*
    fi

    if [ ! -f $f_PATH/$FILE_RECON ]; then
        echo "[+] Starting domain enumaration"
        echo "[-] subfinder [-] findomain [-] assetfinder [-] amass"
        echo 
        subfinder -dL $f_URLS -silent -o $f_PATH/enum_sub
        screen -dm zsh -c "assetfinder -subs-only $f_URLL | tee $f_PATH/enum_asset"
        findomain -f $f_PATH/enum_sub -q -u $f_PATH/enum_find
        amass enum -passive -df $f_PATH/enum_find -o $f_PATH/enum_amass
        cat $f_PATH/enum_* | sort -u | tee $f_PATH/$FILE_RECON
        echo "Domain : "$(wc $f_PATH/$FILE_RECON)
        echo "[+] Domain Enumaration Done"
        echo "-----------"
    else
        echo "[+] Starting domain enumaration"
        echo "[-] subfinder [-] findomain [-] assetfinder [-] amass"
        echo
        echo "File Exist ! "
        echo "Domain : "$(wc $f_PATH/$FILE_RECON)
        echo "-----------"
    fi

    rm -rf $f_PATH/enum_*
    cat $f_PATH/$FILE_RECON | httpx -title -content-length -status-code -silent >> $f_PATH/$FILE_HTTPRESPONSE
    notify-send -u CRITICAL -i messagebox_info "ENUM"
}


sub_HTTP(){
    if [ $(ls | grep -ic http_) != 0  ]; then 
        echo "      -  Removing this file : " $(ls | grep http_)
        rm -rf $f_PATH/http_*
    fi

    if [ ! -f $f_PATH/$FILE_HTTP ]; then
        echo "[+] Starting Http "
        echo "[-] Httpx [-] Httprobe"
        echo
        httpx -l $f_PATH/$FILE_RECON -o $f_PATH/http_httpx
        cat $f_PATH/$FILE_RECON | httprobe -c 200 | tee $f_PATH/http_httprobe
        cat $f_PATH/http_* | sort -u | tee $f_PATH/$FILE_HTTP
        echo "Http : "$(wc $f_PATH/$FILE_HTTP)
        echo "[+] Http Done"
        echo "-----------"
    else 
        echo "[+] Starting Http "
        echo "[-] Httpx [-] Httprobe"
        echo 
        echo "File Exist ! "
        echo "Http : "$(wc $f_PATH/$FILE_HTTP)
        echo "-----------"
    fi 

    rm -rf $f_PATH/http_*
    rm -rf $f_PATH/$FILE_RECON_httpx.txt
    notify-send -u CRITICAL -i messagebox_info "HTTP"
}


sub_STKO(){
    if [ $(ls | grep -ic stko_) != 0  ]; then 
        echo "    -  Removing this file : " $(ls | grep stko_)
        rm -rf $f_PATH/stko_*
    fi
    #dig - host
    echo "[+] Starting Subdomain Takeover"
    echo "[-] subzy [-] subdover [-] subjack [-] aquatone"
    echo
    subzy -targets $f_PATH/$FILE_RECON | tee      $f_PATH/stko/stko_subzy
    python3 ~/files/github/subdover/subdover.py -l    $f_PATH/$FILE_RECON -t 100 -o $f_PATH/stko/stko_subdover
    subjack -v -w  $f_PATH/$FILE_RECON -t 100 -o  $f_PATH/stko/stko_subjack
    cat            $f_PATH/$FILE_RECON | aquatone -ports xlarge -chrome-path ~/files/github/chromium-latest-linux/864970/chrome-linux/chrome -out $f_PATH/stko/stko_aquatone
    echo "[+] Subdomain Takeover Done"
    echo "-----------"
    notify-send -u CRITICAL -i messagebox_info "STKO"
}


sub_CRWL(){
    if [ $(ls | grep -ic crwl_) != 0  ]; then 
        echo "    -  Removing this file : " $(ls | grep crwl_)
        rm -rf $f_PATH/crwl_*
    fi
    
    if [ ! -f $f_PATH/final_crawl.txt ]; then   
        echo "[+] Starting Crawling"   
        echo "[-] hakrawler [-] waybackurls "
        echo
        screen -S Crawl_Hakrawler  -dm zsh -c "cat $f_PATH/$FILE_RECON | hakrawler -plain | tee $f_PATH/crwl_hakrawler   ; notify-send -u critical 'CRAWL HAKRAWLER SCAN DONE'"
        sleep 0.5
        screen -S Crawl_WaybackUrl -dm zsh -c "cat $f_PATH/$FILE_RECON | waybackurls      | tee $f_PATH/crwl_waybackurls ; notify-send -u critical 'CRAWL WAYBACKURL SCAN DONE'"
        sleep 0.5
        screen -S Crawl_Gau        -dm zsh -c "cat $f_PATH/$FILE_RECON | gau              | tee $f_PATH/crwl_gau         ; notify-send -u critical 'CRAWL GAU SCAN DONE'"
        sleep 0.5
 
        i=1
        while [ $(screen -list | grep -ic Crawl_) != 0 ]; do
            echo -ne "      - Waiting for crawling : Seconds $i"\\r
            let "i+=1"
            sleep 1
        done
        cat $f_PATH/crwl_* | sort -u | tee $f_PATH/final_crawl.txt
        echo "Crawling : "$(wc $f_PATH/final_crawl.txt)
        echo "[+] Crawling Done"
        echo "-----------"
    else 
        echo "[+] Starting Crawling"   
        echo "[-] Hakrawler [-] WaybackUrls "
        echo
        echo "File Exist ! "
        echo "Crawling : "$(wc $f_PATH/final_crawl.txt)
        echo "-----------"
    fi
    
    rm -rf $f_PATH/crwl_*
    notify-send -u CRITICAL -i messagebox_info "CRWL"
}


sub_WPRS(){
    echo "[+] Starting Wordpress Exploiting"
    echo "[-] Wpscan [-] Zoom"
    echo
    screen -dm zsh -c "cat $f_PATH/$FILE_HTTP | xargs -I@ wpscan --url @ --enumerate vp --api-token $wpscan_api_token >> $f_PATH/wprs/wpscan;exit\n"
    screen -dm zsh -c "cat $f_PATH/$FILE_HTTP | xargs -I@ python ~/files/github/Zoom/zoom.py -u @ | tee                  $f_PATH/wprs/stko_zoom;exit\n"
    echo "[+] Wpscan Done"
    echo "-----------"
}


sub_THVR(){
    echo "[+] Starting Data Collecting "
    echo "[-] theHarvester"
    echo
    screen -dm zsh -c "cat ~/files/myBruteWords/SourcetheHarvester | xargs -I@ theHarvester -d $f_URLL -b @ -f $f_PATH/thvr/theHarvestMail ; exit \n"
    echo "[+] Data Collecting Done"
    echo "-----------"
}


sub_XXSS(){
    echo "[+] Starting XSS"
    echo ""
    echo

    echo "[+] XSS Done"
    echo "-----------"
}


sub_NUCL(){
    echo   
}


sub_AASN(){
    screen -S ASN -dm zsh -c "echo $f_NAME | metabigor net --org -v | awk '{print $3}' | sed 's/[[0-9]]\+\.//g' | xargs -I@ prips @ | hakrevdns | anew $f_PATH/asn.txt"
}


main(){
    #sub_DEEP_ENUM
    sub_ENUM
    sub_HTTP
    sub_STKO
    sub_CRWL
    sub_WPRS
    sub_THVR
    sub_XXSS
    #sub_NUCL
    #sub_AASN
}

main 
