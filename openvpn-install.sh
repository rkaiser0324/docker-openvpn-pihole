#!/bin/bash
#
# Author: Muhammad Asim
# CoAuthor: mr-bolle
#
# Instructions: https://www.youtube.com/watch?v=NQpzIh7kSkY

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${CYAN}This script uses \"the best image of OpenVPN for Docker on earth by kylemanna/openvpn\".${NC}"

if [ `uname -m` != 'x86_64' ]; then
         echo "Building Docker Image from the kylemanna/openvpn repository..."
         # docker build -t kylemanna/openvpn https://github.com/kylemanna/docker-openvpn.git
             git clone https://github.com/kylemanna/docker-openvpn.git && cd docker-openvpn
                 # change alpine image
#                     sed -i "/FROM/s/latest/3.8/g" Dockerfile
                      sed -i "/FROM/s/aarch64/arm32v7/g" Dockerfile.aarch64
                      sed -i "/FROM/s/latest/alpine/g" Dockerfile.aarch64
                      sed -i "/FROM/s/3.5/latest/g" Dockerfile.aarch64
                      docker build --no-cache -t kylemanna/openvpn -f Dockerfile.aarch64 .
                 cd .. && rm -f -r docker-openvpn
     else
         echo "Pulling the Docker Image from kylemanna/openvpn repository..."
         docker pull kylemanna/openvpn
fi

echo -e "${YELLOW}Creating directory at /openvpn_data...${NC}"

mkdir -p $PWD/openvpn_data && OVPN_DATA=$PWD/openvpn_data

echo -e "OpenVPN data path is set to: $OVPN_DATA"

export OVPN_DATA

read -p "Enter your dynamic DNS server hostname and port (e.g., vpn.example.com:443): " IP

read -p "Choose your VPN protocol (tcp / [udp]): " PROTOCOL
    
    if [ "$PROTOCOL" != "tcp" ]; then

        PROTOCOL="udp"   # set the default Protocol 
        # echo -e "\n***********************************************************"
        # echo -e "\n * Your Domain is: $PROTOCOL://$IP *"
        # echo -e "\n***********************************************************"
    else
        PROTOCOL="tcp"   # change Protocol to tcp
        # echo -e "\n***********************************************************"
        # echo -e "\n * Your Domain is: $PROTOCOL://$IP *"
        # echo -e "\n***********************************************************"
    fi


# set the Pi-Hole Web Admin Password
# read current PiHole Admin Password from docker-compose.yml
PIHOLE_PASSWORD_OLD=`grep 'WEBPASSWORD' docker-compose.yml | awk '{print $2}'`

# Pi-Hole Web Admin Password
read -p "Please enter the Pi-Hole Admin Password (default [$PIHOLE_PASSWORD_OLD]): " PIHOLE_PASSWORD_NEW
    PIHOLE_PASSWORD_NEW=${PIHOLE_PASSWORD_NEW:-$PIHOLE_PASSWORD_OLD}   # set the default Password (if user skip this entry)

#    echo "new: $PIHOLE_PASSWORD_NEW"
#    echo "old: $PIHOLE_PASSWORD_OLD"

            if [ "$PIHOLE_PASSWORD_NEW" != $PIHOLE_PASSWORD_OLD ]; then
                # change password
                sed -in "/WEBPASSWORD/s/$PIHOLE_PASSWORD_OLD/$PIHOLE_PASSWORD_NEW/g" docker-compose.yml        # search for WEBPASSWORD and replace this Password
                PIHOLE_PASSWORD_now=`grep 'WEBPASSWORD' docker-compose.yml | awk '{print $2}'`
        
        # echo -e "\n***********************************************************"
        # echo -e "\n * New Pi-Hole Password is set: $PIHOLE_PASSWORD_now *"
        # echo -e "\n***********************************************************"
        
            else
                # use default password
                PIHOLE_PASSWORD_now=`grep 'WEBPASSWORD' docker-compose.yml | awk '{print $2}'`
                
        # echo -e "\n***********************************************************"
        # echo -e "\n * You don't change Pi-Hole Password: $PIHOLE_PASSWORD_now *"
        # echo -e "\n***********************************************************"             
            fi

echo -e "${YELLOW}Reading IPv4 from Pi-Hole container...${NC}"

# read IPv4 from Pi-Hole Container 
PIHOLE_IP=`grep 'ipv4' docker-compose.yml | awk ' NR==2 {print $2}'`
docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -n $PIHOLE_IP -u $PROTOCOL://$IP 
# more Option: https://github.com/kylemanna/docker-openvpn/blob/master/bin/ovpn_genconfig

echo -e "${YELLOW}Initializing PKI.  You can safely ignore any SSL warnings due to a missing .rnd file. When prompted, enter the same hostname as before...${NC}"
# https://superuser.com/a/1485301 and https://github.com/openssl/openssl/issues/7754

docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki

read -p "Enter your alphanumeric client name (e.g., \"myclient\"): " CLIENTNAME

echo -e "${YELLOW}Generating a client certificate named \"$CLIENTNAME\" with the same passphrase you gave for the server...${NC}"

# echo -e "\nI am adding a client with name $CLIENTNAME\n"
 
docker run -v $OVPN_DATA:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full $CLIENTNAME nopass

echo -e "${YELLOW}Retrieving the client configuration with embedded certificates...${NC}"

echo -e "\n$CLIENTNAME ok\n"

docker run -v $OVPN_DATA:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient $CLIENTNAME > $OVPN_DATA/$CLIENTNAME.ovpn

# read current ServerIP
# HostIP=`ip -4 addr show scope global dev eth0 | grep inet | awk '{print \$2}' | cut -d / -f 1`
# TODO: This will fail on MacOS, no `ip` command
# if [ hostname -i ] then
#     # read IP with Linux Host
#     HostIP=`hostname -i`
# else
#     # read IP with MacOS Host
#     HostIP=`ipconfig getifaddr en0`
# fi

# TODO support geting IP address on Windows Quickstart Terminal
HostIP=192.168.1.101

# Show all values
echo -e "${CYAN}____________________________________________________________________________${NC}"
echo -e "${CYAN}    Your VPN Domain is:                $PROTOCOL://$IP                      ${NC}"
echo -e "${CYAN}    Your Pi-Hole Password is set:      $PIHOLE_PASSWORD_now                 ${NC}"
echo -e "${CYAN}    Your Pi-Hole Admin Page is set to: http://$HostIP:8081/admin            ${NC}"
echo -e "${CYAN}____________________________________________________________________________${NC}\n"

#Note: If you remove the docker container by mistake, simply copy and paster 4TH Step, all will set as previously.

#END

#To revoke a client or user 
# docker run --volumes-from ovpn-data --rm -it kylemanna/openvpn ovpn_revokeclient 1234 remove

# *******************************************************************************************************************


# create a new sub-network (if not exist)
docker network inspect vpn-net &>/dev/null || 
    docker network create --driver=bridge --subnet=172.110.1.0/24 --gateway=172.110.1.1 vpn-net

# set DNSSEC=true to pihole/setupVars.conf 
mkdir -p pihole && echo "DNSSEC=true" >> pihole/setupVars.conf
echo "API_QUERY_LOG_SHOW=blockedonly" >> pihole/setupVars.conf

# run docker-compose
docker-compose up -d

echo -e "${GREEN}Docker container started.${NC}"
