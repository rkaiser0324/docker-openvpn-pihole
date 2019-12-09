# docker-openvpn-pihole

Create a single docker-compose and get the benefits of [Pi-hole](https://pi-hole.net/) and [OpenVPN](https://openvpn.net) on any device, inside or outside your home network.  This was forked from [mr-bolle/docker-openvpn-pihole](https://github.com/mr-bolle/docker-openvpn-pihole) with some bugs fixed along with general usability enhancements.

Many thanks to:  
* GitHub @ [kylemanna/docker-openvpn](https://github.com/kylemanna/docker-openvpn/)  
* GitHub @ [pi-hole/docker-pi-hole](https://github.com/pi-hole/docker-pi-hole/)

Now you can use this repository with the hardware of type x86_x64 and AMR (tested with Raspberry Pi 2).

## Setup

### Server

1. Set up a dynamic DNS hostname for your home network via Namecheap, FreeDNS, etc. 
1. Configure your router to forward all traffic to that hostname, to the Docker container.
1. If on Windows, launch the Docker Quickstart Terminal.
1. Disable any DNS service running on port 53.  For Ubuntu 14, I needed to kill the process manually:
    ```bash
    ps -ef | grep bind
    kill -9 <processid>
    ```
1. Run the install script to initialize both OpenVPN and Pi-Hole:
    ```bash
    ./openvpn-install.sh
    ```
    1. Choose your dynamic DNS hostname and port, e.g., `vpn.example.com:443`
    1. Accept the default protocol of UDP
    1. Set the admin password for Pi-Hole
    1. Accept removal of any existing PKI if needed
    1. Enter a passphrase for the CA key
    1. Accept the common name of `Easy-RSA CA`
    1. Re-enter the CA passphrase from above
    1. Enter an alphanumeric client name, e.g., `windowsclient`.  This must be unique and not contain any special characters.
    1. Re-enter the CA passphrase from above
    1. Upon completion, you will see details for the OpenVPN and Pi-Hole configuration.  You can then log into the Pi-Hole admin page with your chosen password.

### Client

1. Set the DNS server to be the Pi-Hole IP address shown above; it will be the private address of the Docker machine (e.g., `192.168.99.100`).  
1. Follow the [OpenVPN setup instructions](https://openvpn.net/community-resources/how-to/):
    1. Update the `/etc/hosts` file to resolve the DNS hostname above, if necessary
    1. Install the OpenVPN software for [Windows](https://openvpn.net/community-resources/how-to/)
    1. Right-click the system tray icon to import the `/openvpn_data/*.ovpn` file for the client you created earlier
    1. Click Connect

## Troubleshooting

You can skip the install script and simply launch Pi-Hole separately via:
```bash
docker-compose up -d
# Reset to your desired admin password on the Pi-Hole container
docker exec -it vpn_pihole pihole -a -p <PIHOLE_ADMIN_PASSWORD> <PIHOLE_ADMIN_PASSWORD>
# Update gravity
docker exec -it vpn_pihole pihole -g
```

And also:

```bash
# Check the Pi-Hole configuration
docker exec -it vpn_pihole pihole -d
# Or log in via bash
docker exec -it vpn_pihole bash
```

Finally, there is a somewhat-outdated YouTube video showing setup steps here:

[![HowTo create this Container in about 4 Minutes](https://abload.de/img/screenshotcpjyo.jpg)](https://www.youtube.com/embed/8sRtCERYVzk)