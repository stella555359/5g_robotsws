sudo sysctl -w net.sctp.sack_timeout=200
sudo sysctl -w net.sctp.rto_initial=25000
sudo sysctl -w net.sctp.rto_max=40000
sudo sysctl -w net.sctp.rto_min=25000

sudo ip addr add 10.0.3.151/24 dev eth3
sudo ip addr add 10.0.3.153/24 dev eth3
sudo ip addr add 10.0.3.1/24 dev eth3
sudo ip addr add 10.0.2.20/24 dev eth4
sudo ip addr add 192.168.6.252/24 dev eth2
sudo ip addr add 192.168.6.253/24 dev eth2
sudo ip addr add 192.168.6.254/24 dev eth2
sudo ip addr add 10.0.1.25/24 dev eth3
sudo ip addr add 10.0.2.1/24 dev eth4
sudo ip addr add 10.0.1.112/24 dev eth3
sudo ip addr add 10.0.1.121/24 dev eth3
sudo ip addr add 10.0.1.131/24 dev eth3
sudo ip addr add 10.0.1.133/24 dev eth3
sudo ip addr add 10.0.1.134/24 dev eth3
sudo ip addr add 10.0.1.135/24 dev eth3
sudo ip addr add 10.0.1.136/24 dev eth3
sudo ip addr add 10.0.1.137/24 dev eth3


sudo ip addr add 10.0.2.20 dev eth4
sudo ip addr add 10.0.2.21 dev eth4
sudo ip addr add 10.0.2.22 dev eth4
sudo ip addr add 10.0.2.23 dev eth4
sudo ip addr add 10.0.2.24 dev eth4
sudo ip addr add 10.0.2.25 dev eth4
sudo ip addr add 10.0.2.26 dev eth4
sudo ip addr add 10.0.2.27 dev eth4
sudo ip addr add 10.0.2.28 dev eth4

sudo ip addr add 10.0.1.200 dev eth3
sudo ip addr add 10.0.1.210 dev eth3
sudo ip addr add 10.0.1.220 dev eth3
sudo ip addr add 10.0.1.230 dev eth3
sudo ip addr add 10.0.1.240 dev eth3
sudo ip addr add 10.0.1.241 dev eth3
sudo ip addr add 10.0.1.242 dev eth3
sudo ip addr add 10.0.1.243 dev eth3
sudo ip addr add 10.0.1.244 dev eth3

