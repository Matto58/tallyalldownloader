#!/bin/bash

fetchBase() {
    encodedName="$(echo -n "$3" | jq -sRr @uri)"
    # hack to ensure %2Fs in names are slashes in paths and not file/dir names
    encodedName="${encodedName//%2F//}"
    lookupUrl="$2$encodedName"
    actualUrl="$1$encodedName"
    #echo "$1 $2 $3 $4 $encodedName $lookupUrl $actualUrl"
    str=$4

    #echo "Base URL: $lookupUrl"

    curl -o /tmp/tallyallbase.txt -s "$lookupUrl"
    foundName="$(grep -i $str /tmp/tallyallbase.txt | sed -n "2p" | xargs)"
    if [ -z "$foundName" ]; then
        echo "Keyword '$str' not found in $3"
        exit
    fi
    rm /tmp/tallyallbase.txt


    echo -e "Name:\t$foundName"
    echo -e "URL:\t$1$3/$foundName"

    read -p "Download to the current directory? [y/N]" response
    if [ "${response,,}" != "y" ]; then exit; fi
    foundNameEncoded="$(echo -n "$foundName" | jq -sRr @uri)"
    #echo "$actualUrl/$foundNameEncoded"
    curl -o "$foundName" "$actualUrl/$foundNameEncoded"

    read -p "Also convert to 320kbit MP3 for Spotify? [Y/n]" response
    if [ "${response,,}" == "n" ]; then exit; fi
    mp3name="${foundName%%.*}.mp3"
    ffmpeg -y -i "$foundName" -b:a 320k "$mp3name" &> /dev/null
}

if [ -z "$1" ]; then
    echo "No artist provided"
    exit

# cojum dip
elif [ "$1" == "cd" ]; then
    coreUrl="https://archive.cojumpendium.net/go/Music/";
    lookupUrl="https://archive.cojumpendium.net/go/?dir=Music/";
    declare -A releases=(
        ["demo"]="[2005] The Greatest Demo CD in the Universe"
        ["aba"]="[2006] Anthropomorphic Bible Assault EP [CD FLAC]"
        ["to"]="[2008-2010] Turk Off EP ／ 2010 Remix"
        ["vj1"]="[2012] Videojuegos Volume 1 [Bandcamp FLAC]"
        ["vj2"]="[2012] Videojuegos Volume 2 [Bandcamp FLAC]"
        ["cdbc"]="[2014] Cojum Dip [Bandcamp FLAC]"
        ["cdweb"]="[2019] Cojum Dip [WEB FLAC]"
    )
    if [ -z $2 ]; then
        echo "No Cojum Dip release provided"
        exit
    fi
    release=$2
    if [ -z "${releases[${release}]}" ]; then
        echo "Invalid Cojum Dip release provided, valid are:"
        for id in "${!releases[@]}"; do echo -e "\t$id:\t${releases[$id]}"; done
        exit
    fi
    fetchBase "$coreUrl" "$lookupUrl" "${releases[${release}]}" $3

# tally hall
elif [ "$1" == "th" ]; then
    coreUrl="https://tallyall.club/go/Tally%20Hall/";
    lookupUrl="https://tallyall.club/go/?dir=Tally%20Hall/";
    declare -A releases=(
        ["aid"]="Admittedly Incomplete Demos"
        ["cd"]="Complete Demos"
        ["ge"]="Good & Evil"
        # would've been mmmm08 but everyone uses the 2008 version, unless they aren't, in which case they'll use mmmm05 and mmmm06
        ["mmmm"]="Marvin's Marvelous Mechanical Museum/2008 Version"
        ["mmmm05"]="Marvin's Marvelous Mechanical Museum/2005 Version"
        ["mmmm06"]="Marvin's Marvelous Mechanical Museum/2006 Version"
        ["pb"]="Party Boobytrap EP"
        ["rt"]="Residency Tour EP"
        ["sels"]="Selections From the Upcoming Marvin's Marvelous Mechanical Museum"
        ["pingry"]="The Pingry EP"
        ["wtth"]="Welcome to Tally Hall EP"
    )
    if [ -z $2 ]; then
        echo "No Tally Hall release provided"
        exit
    fi
    release=$2
    if [ -z "${releases[${release}]}" ]; then
        echo "Invalid Tally Hall release provided, valid are:"
        for id in "${!releases[@]}"; do echo -e "\t$id:\t${releases[$id]}"; done
        exit
    fi
    fetchBase "$coreUrl" "$lookupUrl" "${releases[${release}]}" $3

# miracle musical
elif [ "$1" == "mm" ]; then
    coreUrl="https://tallyall.club/go/members/Miracle%20Musical/";
    lookupUrl="https://tallyall.club/go/?dir=members/Miracle%20Musical/";
    declare -A releases=(
        ["hpii"]="Hawaii Part II"
        ["hpii2"]="Hawaii Part II Part ii"
        ["partii"]="Hawaii Partii"
    )
    if [ -z $2 ]; then
        echo "No Miracle Musical release provided"
        exit
    fi
    release=$2
    if [ -z "${releases[${release}]}" ]; then
        echo "Invalid Miracle Musical release provided, valid are:"
        for id in "${!releases[@]}"; do echo -e "\t$id:\t${releases[$id]}"; done
        exit
    fi
    fetchBase "$coreUrl" "$lookupUrl" "${releases[${release}]}" $3

else
    echo "Invalid artist provided, valid are: th - Tally Hall, cd - Cojum Dip, mm - Miracle Musical"
fi
