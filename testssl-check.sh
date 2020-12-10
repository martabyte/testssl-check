#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'

NC='\033[0m' # No Color

declare -A sslVulnList=(
    ['heartbleed']="-sV --script=ssl-heartbleed -p 443"
    ['ccs']="-sV --script=ssl-ccs-injection -p 443"
    ['lucky13']="-cipher AES128-SHA -connect"
    ['sweet32']="-cipher PSK-3DES-EDE-CBC-SHA -connect" # 3DES ciphers not available on newer openssl
    ['sec-cli-init-renego']="-connect"
    ['sec-renego']="-connect"
    ['crime']="-connect"
    ['breach']="-connect" # TO-DO: Send the GET message automatically from the script (?)
    ['poodle']="-ssl3 -connect" # ssl3 not available on newer openssl
    ['freak']="-cipher EXP-RC4-MD5 -connect" # EXPORT ciphers not available on newer openssl
    ['drown']="-ssl2 -connect" # ssl2 not available on newer openssl
    ['logjam']="-cipher EXP-RC4-MD5 -connect" # EXPORT ciphers not available on newer openssl
    ['beast']="-tls1 -cipher AES128-SHA -connect"
    ['rc4']="-cipher ECDH-RSA-RC4-SHA -connect" # RC4 ciphers not available on newer openssl
    ['ssl-enum-ciphers']="--script=ssl-enum-ciphers -p 443"
    ['ssl2']="-ssl2 -connect"
    ['ssl3']="-ssl3 -connect"
    ['tls1']="-tls1 -connect"
    ['tls1_1']="-tls1_1 -connect"
    ['tls1_2']="-tls1_2 -connect"
    ['tls1_3']="-tls1_3 -connect"
)

# test -z checks if a varible's length is zero 
if test -z $1; then # If there's no parameter specified
    echo "Introduce a valid OpenSSL vulnerability and target!"
    echo "Usage: ./testssl-check.sh {vulnerability} {target} [-brief] [-list]"
    exit 0
    elif [ $1 == '-list' ]; then # If the first parameter is '-list'
        echo "Available TestSSL Checks:"
        for key in "${!sslVulnList[@]}"; do # The "!" prints the keys, without the "!" it prints the values
            echo -e "\t $key"
        done

        # The following line also prints the keys but in the same line
        #echo "${!sslVulnList[@]}"

        exit 0
        elif test -z $2; then # If there's no second parameter specified after the first - Missing target
            echo "Introduce a valid OpenSSL vulnerability and target!"
            echo "Usage: ./testssl-check.sh {vulnerability} {target} [-brief] [-list]"
            exit 0
fi

brief=0
if test $3; then   
    if [ $3 == '-brief' ];
        then brief=1;
    fi
fi

sslVuln=$1
target=$2

if [ ${target: -4} != ":443"  ]; # Checks if the last 4 chars of the target are :443, if not, it adds it to the target
	then target="${target}:443"
fi


set -u # To treat unset variables as an error

case $sslVuln in
    'heartbleed')
        echo -e "${YELLOW}$ ${BLUE}nmap${NC} ${sslVulnList[$sslVuln]} $target"
        nmap ${sslVulnList[$sslVuln]} $target
        ;;

    'ccs')
        echo -e "${YELLOW}$ ${BLUE}nmap${NC} ${sslVulnList[$sslVuln]} $target"
        nmap ${sslVulnList[$sslVuln]} $target
        ;;

    'ssl-enum-ciphers')
        echo -e "${YELLOW}$ ${BLUE}nmap${NC} ${sslVulnList[$sslVuln]} $target"
        nmap ${sslVulnList[$sslVuln]} $target
        ;;

    *)
        if [ $brief == 1 ]; then
            echo -e "${YELLOW}$ ${BLUE}openssl${NC} s_client ${sslVulnList[$sslVuln]} $target -brief"
            openssl s_client ${sslVulnList[$sslVuln]} $target -brief
            else
                echo -e "${YELLOW}$ ${BLUE}openssl${NC} s_client ${sslVulnList[$sslVuln]} $target"
                openssl s_client ${sslVulnList[$sslVuln]} $target
        fi
        ;;
esac
