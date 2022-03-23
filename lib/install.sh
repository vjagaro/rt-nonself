PUBLIC_IFACE=$(ip route ls default | awk '{print $5}')

echo "Getting latest packages..."

_rt_indent apt-get update -q

echo "Upgrading packages..."

DEBIAN_FRONTEND=noninteractive _rt_indent apt-get upgrade -qqy

echo "Configuring hostname..."

echo "$SERVER_HOSTNAME" >/etc/hostname
hostname -F /etc/hostname

echo "Configuring /etc/hosts..."

cat <<-EOF >/etc/hosts
# /etc/hosts
127.0.0.1       localhost
127.0.1.1       $SERVER_HOSTNAME

# The following lines are desirable for IPv6 capable hosts
::1             localhost ip6-localhost ip6-loopback
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

echo "Configuring /etc/resolv.conf"

rm /etc/resolv.conf
cat <<-EOF >/etc/resolv.conf
nameserver 1.1.1.1
nameserver 1.0.0.1
EOF

echo "Configuring firewall..."

_rt_apt_ensure nftables

cat <<-EOF >/etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
  chain input {
    type filter hook input priority filter; policy accept;

    iifname "lo" accept
    ct state { established, related } counter accept
    ct state invalid counter drop
    ip protocol icmp counter accept
    ip6 nexthdr ipv6-icmp counter accept

    tcp dport ssh counter accept
    iifname "$WG_IFACE" tcp dport domain counter accept
    iifname "$WG_IFACE" udp dport domain counter accept
    udp dport $WG_PORT counter accept

    counter reject
  }

  chain forward {
    type filter hook forward priority filter; policy accept;
    ct state { established, related } counter accept
    iifname "$WG_IFACE" oifname "$PUBLIC_IFACE" counter accept
    counter reject
  }

  chain output {
    type filter hook output priority filter; policy accept;
    counter accept
  }

  chain prerouting {
    type nat hook prerouting priority dstnat; policy accept;
    counter accept
  }

  chain postrouting {
    type nat hook postrouting priority srcnat; policy accept;
    iifname "$WG_IFACE" oifname "$PUBLIC_IFACE" counter masquerade
    counter accept
  }
}
EOF

_rt_indent systemctl enable nftables
_rt_indent systemctl restart nftables

echo "Enabling IP forwarding..."

cat <<-EOF >/etc/sysctl.d/ip_forwarding.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
_rt_indent sysctl --quiet --system

echo "Installing network utilities..."

_rt_apt_ensure bind9-dnsutils bind9-host netcat nmap openssh-client openssl \
  qrencode tcpdump

echo "Installing automatic upgrades..."

_rt_apt_ensure unattended-upgrades apt-listchanges

echo "Installing Dnsmasq..."

_rt_apt_ensure dnsmasq

echo "Installing Wireguard..."

_rt_apt_ensure wireguard

echo "Configuring Wireguard..."

touch /etc/wireguard/$WG_IFACE.conf
chmod 600 /etc/wireguard/$WG_IFACE.conf
cat <<-EOF >/etc/wireguard/$WG_IFACE.conf
[Interface]
Address = $WG_IPV4_NET.$WG_LAST_OCTET/24
Address = $WG_IPV6_NET::$WG_LAST_OCTET/64
SaveConfig = true
ListenPort = $WG_PORT
PrivateKey = $WG_PRIVATE_KEY
PostUp = systemctl restart dnsmasq
EOF

_rt_indent systemctl enable wg-quick@$WG_IFACE
_rt_indent systemctl start wg-quick@$WG_IFACE
