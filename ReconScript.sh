#!/bin/bash

display_help(){
    echo 
    echo "Usage : [FILE] [PATH] [ASSETFINDER SPECIFIC URL] optional [URL FOR HARVESTER]"
    echo 
    echo "        First list of Urls"
    echo "        Second path to save file"
    echo "        Third Specified url for assetfinder doesn't accept contain host file'"
    echo "        Fourth Url for theHarvester"
    echo 
}

if [ "$1" == "-h" ]; then
    display_help
    exit 0
fi

if [ $# -lt 3 ]; then
    display_help
    exit 2
fi

if [ ! -f $1 ]; then
    echo 
    echo "File Not Exist : " $1 
    exit 2
fi

date_now=$(date "+%F")

f_URLS=$1
c_NAME=$2
f_PATH=$c_NAME/$date_now
f_ASST=$3
f_HVRL=$4
f_SIGN=/usr/share/icons/Windows-10-Icons/256x256/status
i=1



sub_DEEP_ENUM(){
    amass enum -src -ip -active -brute -d $f_ASST -o domain 
}



if [ ! -d "$f_PATH" ];      then mkdir -p $f_PATH ;      fi
if [ ! -d "$f_PATH/stko" ]; then mkdir -p $f_PATH/stko ; fi


sub_ENUM(){
    if [ $(ls | grep -ic enum_) != 0  ]; then 
        echo "      -  Removing this file : " $(ls | grep enum_)
        rm -rf $f_PATH/enum_*
    fi

    if [ ! -f $f_PATH/final_recon.txt ]; then
        echo "[+] Starting domain enumaration"
        echo "[-] subfinder [-] findomain [-] assetfinder [-] amass"
        echo 
        subfinder -dL $f_URLS -silent -o $f_PATH/enum_sub
        screen -dm bash -c "assetfinder -subs-only $f_ASST | tee $f_PATH/enum_asset"
        findomain -f $f_PATH/enum_sub -q -u $f_PATH/enum_find | sort -u | tee $f_PATH/enum_find
        amass enum -passive -df $f_PATH/enum_find -o $f_PATH/enum_amass
        cat $f_PATH/enum_* | sort -u | tee $f_PATH/final_recon.txt
        echo "Domain : "$(wc $f_path/final_recon.txt)
        echo "[+] Domain Enumaration Done"
        echo "-----------"
    else
        echo "[+] Starting domain enumaration"
        echo "[-] subfinder [-] findomain [-] assetfinder [-] amass"
        echo
        echo "File Exist ! "
        echo "Domain : "$(wc $f_path/final_recon.txt)
        echo "-----------"
    fi

    rm -rf $f_PATH/enum_*
}





sub_HTTP(){
    if [ $(ls | grep -ic http_) != 0  ]; then 
        echo "      -  Removing this file : " $(ls | grep http_)
        rm -rf $f_PATH/http_*
    fi

    if [ ! -f $f_PATH/final_http.txt ]; then
        echo "[+] Starting Http "
        echo "[-] Httpx [-] Httprobe"
        echo
        httpx -l $f_PATH/final_recon.txt -o $f_PATH/http_httpx.txt
        cat $f_PATH/final_recon.txt | httprobe -c 200 | tee http_httprobe.txt
        cat http_* | sort -u | tee final_http.txt
        echo "Http : "$(wc $f_path/final_http.txt)
        echo "[+] Http Done"
        echo "-----------"
    else 
        echo "[+] Starting Http "
        echo "[-] Httpx [-] Httprobe"
        echo 
        echo "File Exist ! "
        echo "Http : "$(wc $f_path/final_http.txt)
        echo "-----------"
    fi 

    rm -rf $f_PATH/http_*
}




sub_STKO(){
    #dig - host
    subzy -targets --hide_fails $f_PATH/final_recon.txt | tee $f_PATH/stko/stko_subzy.txt
    subdover --list $f_PATH/final_recon.txt -t 100 -o $f_PATH/stko/stko_subdover.txt 
    subjack -w $f_PATH/final_recon.txt -t 100 -o $f_PATH/stko/stko_subjack.txt
    cat $f_PATH/final_recon.txt | aquatone -chrome-path ~/files/github/chromium-latest-linux/864970/chrome-linux/chrome -out aquatone
}





sub_CRWL(){
    if [ $(ls | grep -ic crwl_) != 0  ]; then 
        echo "    -  Removing this file : " $(ls | grep crwl_)
        rm -rf $f_PATH/crwl_*
    fi
    
    if [ ! -f $f_PATH/final_crawl.txt ]; then   
        echo "[+] Starting Crawling"   
        echo "[-] Hakrawler [-] WaybackUrls "
        echo
        screen -S Crawl_Hakrawler -dm bash -c "cat $f_PATH/final_recon.txt | hakrawler -plain | tee $f_PATH/crwl_hakrawler ; notify-send -u critical 'CRAWL HAKRAWLER SCAN DONE' -i $f_SIGN/messagebox_info.png"
        sleep 0.5
        screen -S Crawl_WaybackUrl -dm bash -c "cat $f_PATH/final_recon.txt | waybackurls | tee $f_PATH/crwl_waybackurls ; notify-send -u critical 'CRAWL WAYBACKURL SCAN DONE' -i $f_SIGN/messagebox_info.png"
        sleep 0.5
        while [ $(screen -list | grep -ic Crawl_) != 0 ]; do
            echo -ne "      - Waiting for crawling : Seconds $i"\\r
            let "i+=1"
            sleep 1
        done
        cat $f_PATH/crwl_* | sort -u | tee $f_PATH/final_crawl.txt
        echo "Crawling : "$(wc $f_path/final_crawl.txt)
        echo "[+] Crawling Done"
        echo "-----------"
    else 
        echo "[+] Starting Crawling"   
        echo "[-] Hakrawler [-] WaybackUrls "
        echo
        echo "File Exist ! "
        echo "Crawling : "$(wc $f_path/final_crawl.txt)
        echo "-----------"
    fi

    rm -rf $f_PATH/crwl_*
}







sub_Wprs(){
    
    echo "[+] Starting Wordpress Exploiting"
    echo "[-] Wpscan"
    screen -dmS Crwling zsh && sleep 1 && screen -S Crwling -p 0 -X stuff "cat $f_PATH/final_recon.txt | grep wordpress | xargs -I@ wpscan --url @ --enumerate vp --api-token  $wpscan_api_token >> $f_PATH/wpscan.txt ; notify-send -u critical 'WORDPRESS SCAN DONE' 'using wpscan' -i $f_SIGN/messagebox_info.png"
}

sub_Thvr(){
    echo "[+] Starting Data Collecting "
    echo "[-] theHarvester"
    screen -S harvestEmail -dm bash -c "cat ~/files/myBruteWords/SourcetheHarvester | xargs -I@ theHarvester -d $f_HVRL -b @ -f $f_PATH/theHarvestMail ; notify-send -u critical 'THEHARVESTEMAIL SCAN DONE' 'theHarvestEmail' -i $f_SIGN/messagebox_info.png"
}

sub_nuclei(){
    echo   
}

sub_xss(){
    echo
}

sub_asn(){
    #Lazy subdomain enumaration 
    screen -S ASN -dm bash -c "echo $c_NAME | metabigor net --org -v | awk '{print $3}' | sed 's/[[0-9]]\+\.//g' | xargs -I@ prips @ | hakrevdns | anew $f_PATH/asn.txt"
}


main(){
    #sub_DEEP_ENUM
    #sub_ENUM
    #sub_HTTP
    #sub_STKO
    #sub_CRWL
    sub_Wprs
    #sub_xss
    #sub_nuclei
    #asn
    if [ ! -z "$f_HVRL" ]; then
        sub_Thvr
    fi
    #sub_Wprs // Still not available 
}
# -i $f_SIGN/messagebox_warning.png
# -i $f_SIGN/messagebox_info.png
main 


# if ! command -v subdover &> /dev/null ;then echo "COMMAND could not be found" ;  else echo "sad" ; fi
