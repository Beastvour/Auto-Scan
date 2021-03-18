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

sub_EnumOutput(){
        echo "[+] Starting Domain Enumaration"
        echo "Domain : "$(wc $f_PATH/final_recon.txt)
        echo "[-] Subfinder"
        echo "[-] Findomain"
        echo "[-] Assetfinder"
        echo "[-] Amass"
        echo 
}

sub_Enum(){

    if [ ! -f $f_PATH/final_recon.txt ]; then
        sub_EnumOutput             
        
        subfinder -dL $f_URLS -silent -o $f_PATH/enum_sub
        screen -dm bash -c "assetfinder -subs-only $f_ASST | tee $f_PATH/enum_asset"
        findomain -f $f_PATH/enum_sub -q -u $f_PATH/enum_find | sort -u | tee $f_PATH/enum_find
        
        #cat $f_PATH/enum_find | sort -u | tee $f_PATH/enum_find
        amass enum -passive -df $f_PATH/enum_find -o $f_PATH/enum_amass
        
        cat $f_PATH/enum_* | sort -u | tee $f_PATH/final_recon.txt

        rm $f_PATH/enum_*
        echo "[+] Domain Enumaration Done"
        echo "-----------"
    else
        sub_EnumOutput
        echo "[+] Domain Enumaration Done"
        echo "-----------"
    fi

}

sub_Deep_Enum(){
    amass enum -src -ip -active -brute -d $f_ASST -o domain 
}

sub_Crwl(){
    echo "[+] Starting Crawling"   
    echo "Crawled : "$(wc $f_PATH/final_recon.txt)
    echo "[-] Starting Hakrawler "
    echo "[-] Starting WaybackUrls "
    echo     
    
    if [[ -f $f_PATH/crwl_* ]]; then
        echo "    -  Removing this file : " $(ls $f_PATH | grep crwl_*)
        rm $f_PATH/crwl_* 
    fi   

    sleep 0.1
    screen -S Crawl_Hakrawler -dm bash -c "cat $f_PATH/final_recon.txt | hakrawler -plain | tee $f_PATH/crwl_hakrawler ; notify-send -u critical 'CRAWL HAKRAWLER SCAN DONE' -i $f_SIGN/messagebox_info.png"
    screen -S Crawl_WaybackUrl -dm bash -c "cat $f_PATH/final_recon.txt | waybackurls | tee $f_PATH/crwl_waybackurls ; notify-send -u critical 'CRAWL WAYBACKURL SCAN DONE' -i $f_SIGN/messagebox_info.png"
    
    #sleep 0.5
    #screen -dmS Crwling zsh && sleep 1 && screen -S Crwling -p 0 -X stuff 'var=1 ; while [ \$var != 0 ] ; do var=\$(screen -list | grep -ic Crawl) ; echo "Crawling Still Running : " \$var ; sleep 0.1 ; done \n'"cat $f_PATH/crwl_* | sort -u | tee $f_PATH/final_crawl.txt \nrm $f_PATH/crwl_*\nif [ -f $f_PATH/final_crawl.txt ]; then notify-send -u critical 'ALL CRAWL SCAN DONE' -i $f_SIGN/messagebox_info.png; fi\nexit\n" 
    #&& screen -r Crwling
    
    sleep 0.1
    while [ $(screen -list | grep -ic Crawl) != 0 ]; do
        echo -ne "    - Waiting for crawling : Seconds $i"\\r
        let "i+=1"
        sleep 1
    done
    cat $f_PATH/crwl_* | sort -u | tee $f_PATH/final_crawl.txt
    rm $f_PATH/crwl_* 
    while [ ! -f $f_PATH/final_crawl.txt ]; do
        notify-send -u critical "    - File Not Exist Check Directory :"  $f_PATH"final_crawl.txt " -i $f_SIGN/messagebox_warning.png
        echo "    - Can't Procceed Next Step !!! File Not Exist Check Directory :"  $f_PATH"final_crawl.txt "
        sleep 5
    done

    echo "[+] Domain Crawling Done"
    echo "-----------"
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
    #sub_Enum
    #sub_Crwl
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
