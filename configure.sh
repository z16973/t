#!/bin/sh

# Download and install V2Ray
mkdir /tmp/v2ray
curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray/v2ray.zip https://github.com/v2fly/v2ray-core/releases/latest/download/v2ray-linux-64.zip
unzip /tmp/v2ray/v2ray.zip -d /tmp/v2ray
install -m 755 /tmp/v2ray/v2ray /usr/local/bin/v2ray
install -m 755 /tmp/v2ray/v2ctl /usr/local/bin/v2ctl

# Remove temporary directory
rm -rf /tmp/v2ray

# V2Ray new configuration
install -d /usr/local/etc/v2ray
cat << EOF > /usr/local/etc/v2ray/config.json
{
    "inbounds": [
        {
            "port": 8080,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "ad806487-2d26-4636-98b6-ab85cc8521f7",
                        "alterId": 64
                    }
                ],
                "disableInsecureEncryption": true
            },
            "streamSettings": {
                "network": "ws"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

cat << EOF > /root/mudb_port.txt
8080
EOF

ip tuntap add tap0 mode tap
ip addr add 10.99.254.1/24 dev tap0
ip link set tap0 up

iptables -P FORWARD ACCEPT

iptables -t nat -A POSTROUTING -s 10.99.254.0/24 ! -d 10.99.254.0/24 -j MASQUERADE

while read line
do
	iptables -t nat -A PREROUTING -i eth0 -p tcp --dport $line -j DNAT --to-destination 10.99.254.2
	iptables -t nat -A PREROUTING -i eth0 -p udp --dport $line -j DNAT --to-destination 10.99.254.2
done < /root/mudb_port.txt

export LD_PRELOAD="/root/liblkl.so"
export LKL_HIJACK_NET_QDISC="root|fq"
export LKL_HIJACK_SYSCTL="net.ipv4.tcp_congestion_control=bbr;net.ipv4.tcp_fastopen=3;net.ipv4.tcp_wmem=4096 87380 2147483647"
export LKL_HIJACK_NET_IFTYPE="tap"
export LKL_HIJACK_NET_IFPARAMS="tap0"
export LKL_HIJACK_NET_IP="10.99.254.2"
export LKL_HIJACK_NET_NETMASK_LEN="24"
export LKL_HIJACK_NET_GATEWAY="10.99.254.1"
export LKL_HIJACK_OFFLOAD="0x9983"

/usr/local/bin/v2ray -config /usr/local/etc/v2ray/config.json &
# /root/rinetd -f -c /root/config-port.conf raw eth0 &


# Run V2Ray

