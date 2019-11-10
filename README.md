# docker-openvpn-pihole

Create a single docker-compose and get the benefits of [Pi-hole](https://pi-hole.net/) and [OpenVPN](https://openvpn.net) on any device, inside or outside your home network.  This was forked from [mr-bolle/docker-openvpn-pihole](https://github.com/mr-bolle/docker-openvpn-pihole) with some bugs fixed along with general usability enhancements.

Many thanks to:  
* GitHub @ [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn/)  
* GitHub @ [pi-hole/docker-pi-hole](https://github.com/pi-hole/docker-pi-hole/)

Now you can use this repository with the Hardwaretype x86_x64 and amr (Test with Raspberry Pi 2)

*YouTube: HowTo create this Container in about 4 Minutes*
[![HowTo create this Container in about 4 Minutes](https://abload.de/img/screenshotcpjyo.jpg)](https://www.youtube.com/embed/8sRtCERYVzk)

[Changelog](https://github.com/mr-bolle/docker-openvpn-pihole/blob/master/CHANGELOG.md)

## Setup

1. Set up a dynamic DNS hostname for your home network via Namecheap, FreeDNS, etc. 
1. Configure your router to forward all traffic to that hostname, to the Docker container.
1. If on Windows, launch the Docker Quickstart Terminal.
1. Run the install script:
```bash
openvpn-install.sh
```

To check a running container:
```bash
docker container exec vpn_pihole bash
```

1. OpenVPN create certificate and first user [Source](https://github.com/kylemanna/docker-openvpn/blob/master/docs/docker-compose.md)

Follow User Entry you have to made
:bulb: **All [default] values can be accepted with ENTER** :bulb:
1. `Please enter your dynDNS Addess:` enter your dynDNS Domain (example: `vpn.example.com`)
2. `Please choose your Protocol (tcp / [udp])` you can change the OpenVPN to tcp, default is udp
3. `Would you change your Pi-Hole Admin Password` the currend default password read from docker-compose
4. `Enter PEM pass phrase:` this password is for your ca.key - and you need this to create a User Certificate
5. `Common Name (eg: your user, host, or server name) [Easy-RSA CA]:` (default Easy-RSA CA)
6. `Please Provide Your Client Name` with this Name you create your first OpenVPN Client
