sudo ip link add link eth3 name eth3.601 type vlan id 601
sudo ip addr add 10.0.3.1/24 dev eth3.601
sudo ip addr add fc00::3:1/119 dev eth3.601
sudo ip link set dev eth3.601 up



sudo ip link add link eth3 name eth3.602 type vlan id 602
sudo ip addr add 10.0.5.1/24 dev eth3.602
sudo ip addr add fc00::5:1/119 dev eth3.602
sudo ip link set dev eth3.602 up

sleep 5

sudo ip link add link eth3 name eth3.600 type vlan id 600
sudo ip link set dev eth3.600 up
sudo ip addr add 10.0.3.131/32 dev eth3.600
sudo ip addr add 10.0.3.132/32 dev eth3.600
sudo ip addr add 10.0.3.133/32 dev eth3.600
sudo ip addr add 10.0.3.134/32 dev eth3.600
sudo ip addr add 10.0.3.135/32 dev eth3.600
sudo ip addr add 10.0.3.136/32 dev eth3.600
sudo ip addr add 10.0.3.137/32 dev eth3.600
sudo ip addr add 10.0.3.138/32 dev eth3.600
sudo ip addr add 10.0.3.139/32 dev eth3.600
sudo ip addr add 10.0.3.140/32 dev eth3.600
sudo ip addr add 10.0.3.141/32 dev eth3.600
sudo ip addr add 10.0.3.142/32 dev eth3.600
sudo ip addr add 10.0.3.143/32 dev eth3.600
sudo ip addr add 10.0.3.144/32 dev eth3.600
sudo ip addr add 10.0.3.145/32 dev eth3.600
sudo ip addr add 10.0.3.146/32 dev eth3.600
sudo ip addr add 10.0.3.147/32 dev eth3.600
sudo ip addr add 10.0.3.148/32 dev eth3.600
sudo ip addr add 10.0.3.149/32 dev eth3.600
sudo ip addr add 10.0.3.150/32 dev eth3.600


sleep 5


sudo ip addr add fc00::3:83/128 dev eth3.600
sudo ip addr add fc00::3:84/128 dev eth3.600
sudo ip addr add fc00::3:85/128 dev eth3.600
sudo ip addr add fc00::3:86/128 dev eth3.600
sudo ip addr add fc00::3:87/128 dev eth3.600
sudo ip addr add fc00::3:88/128 dev eth3.600
sudo ip addr add fc00::3:89/128 dev eth3.600
sudo ip addr add fc00::3:8a/128 dev eth3.600
sudo ip addr add fc00::3:8b/128 dev eth3.600
sudo ip addr add fc00::3:8c/128 dev eth3.600
sudo ip addr add fc00::3:8d/128 dev eth3.600
sudo ip addr add fc00::3:8e/128 dev eth3.600
sudo ip addr add fc00::3:8f/128 dev eth3.600
sudo ip addr add fc00::3:90/128 dev eth3.600
sudo ip addr add fc00::3:91/128 dev eth3.600
sudo ip addr add fc00::3:92/128 dev eth3.600
sudo ip addr add fc00::3:93/128 dev eth3.600
sudo ip addr add fc00::3:94/128 dev eth3.600
sudo ip addr add fc00::3:95/128 dev eth3.600
sudo ip addr add fc00::3:96/128 dev eth3.600

sleep 5

sudo ip addr add 10.0.5.131/32 dev eth3
sudo ip addr add 10.0.5.132/32 dev eth3
sudo ip addr add 10.0.5.133/32 dev eth3
sudo ip addr add 10.0.5.134/32 dev eth3
sudo ip addr add 10.0.5.135/32 dev eth3
sudo ip addr add 10.0.5.136/32 dev eth3
sudo ip addr add 10.0.5.137/32 dev eth3
sudo ip addr add 10.0.5.138/32 dev eth3
sudo ip addr add 10.0.5.139/32 dev eth3
sudo ip addr add 10.0.5.140/32 dev eth3

sleep 5

sudo ip addr add fc00::5:83/128 dev eth3
sudo ip addr add fc00::5:84/128 dev eth3
sudo ip addr add fc00::5:85/128 dev eth3
sudo ip addr add fc00::5:86/128 dev eth3
sudo ip addr add fc00::5:87/128 dev eth3
sudo ip addr add fc00::5:88/128 dev eth3
sudo ip addr add fc00::5:89/128 dev eth3
sudo ip addr add fc00::5:8a/128 dev eth3
sudo ip addr add fc00::5:8b/128 dev eth3
sudo ip addr add fc00::5:8c/128 dev eth3

sleep 5


sudo ip route add 10.0.3.2 dev eth3.601 src 10.0.3.131
sudo ip route add 10.0.3.3 dev eth3.601 src 10.0.3.132
sudo ip route add 10.0.3.4 dev eth3.601 src 10.0.3.133
sudo ip route add 10.0.3.5 dev eth3.601 src 10.0.3.134
sudo ip route add 10.0.3.6 dev eth3.601 src 10.0.3.135
sudo ip route add 10.0.3.7 dev eth3.601 src 10.0.3.136
sudo ip route add 10.0.3.8 dev eth3.601 src 10.0.3.137
sudo ip route add 10.0.3.9 dev eth3.601 src 10.0.3.138
sudo ip route add 10.0.3.10 dev eth3.601 src 10.0.3.139
sudo ip route add 10.0.3.11 dev eth3.601 src 10.0.3.140
sudo ip route add 10.0.3.12 dev eth3.601 src 10.0.3.141
sudo ip route add 10.0.3.13 dev eth3.601 src 10.0.3.142
sudo ip route add 10.0.3.14 dev eth3.601 src 10.0.3.143
sudo ip route add 10.0.3.15 dev eth3.601 src 10.0.3.144
sudo ip route add 10.0.3.16 dev eth3.601 src 10.0.3.145
sudo ip route add 10.0.3.17 dev eth3.601 src 10.0.3.146
sudo ip route add 10.0.3.18 dev eth3.601 src 10.0.3.147
sudo ip route add 10.0.3.19 dev eth3.601 src 10.0.3.148
sudo ip route add 10.0.3.20 dev eth3.601 src 10.0.3.149
sudo ip route add 10.0.3.21 dev eth3.601 src 10.0.3.150


sleep 5


sudo ip -6 route add fc00::3:2 dev eth3.601 src fc00::3:83
sudo ip -6 route add fc00::3:3 dev eth3.601 src fc00::3:84
sudo ip -6 route add fc00::3:4 dev eth3.601 src fc00::3:85
sudo ip -6 route add fc00::3:5 dev eth3.601 src fc00::3:86
sudo ip -6 route add fc00::3:6 dev eth3.601 src fc00::3:87
sudo ip -6 route add fc00::3:7 dev eth3.601 src fc00::3:88
sudo ip -6 route add fc00::3:8 dev eth3.601 src fc00::3:89
sudo ip -6 route add fc00::3:9 dev eth3.601 src fc00::3:8a
sudo ip -6 route add fc00::3:a dev eth3.601 src fc00::3:8b
sudo ip -6 route add fc00::3:b dev eth3.601 src fc00::3:8c
sudo ip -6 route add fc00::3:c dev eth3.601 src fc00::3:8d
sudo ip -6 route add fc00::3:d dev eth3.601 src fc00::3:8e
sudo ip -6 route add fc00::3:e dev eth3.601 src fc00::3:8f
sudo ip -6 route add fc00::3:f dev eth3.601 src fc00::3:90
sudo ip -6 route add fc00::3:10 dev eth3.601 src fc00::3:91
sudo ip -6 route add fc00::3:11 dev eth3.601 src fc00::3:92
sudo ip -6 route add fc00::3:12 dev eth3.601 src fc00::3:93
sudo ip -6 route add fc00::3:13 dev eth3.601 src fc00::3:94
sudo ip -6 route add fc00::3:14 dev eth3.601 src fc00::3:95
sudo ip -6 route add fc00::3:15 dev eth3.601 src fc00::3:96


sleep 5


sudo ip a a 10.0.1.131/32 dev eth3
sudo ip a a 10.0.1.132/32 dev eth3
sudo ip a a 10.0.1.133/32 dev eth3
sudo ip a a 10.0.1.134/32 dev eth3
sudo ip a a 10.0.1.135/32 dev eth3
sudo ip a a 10.0.1.136/32 dev eth3
sudo ip a a 10.0.1.137/32 dev eth3
