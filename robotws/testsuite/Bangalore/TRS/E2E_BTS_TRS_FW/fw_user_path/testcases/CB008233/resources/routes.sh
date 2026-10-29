sudo ip link add link eth3 name eth3.600 type vlan id 600
sudo ip addr del 10.0.1.1/24 dev eth3
sudo ip addr add 10.0.1.1/24 dev eth3.600
sudo ip addr add fc00::1:1/126 dev eth3.600
sudo ip link set dev eth3.600 up


sudo ip a a 10.0.1.131/24 dev eth3
sudo ip a a 10.0.1.132/24 dev eth3
sudo ip a a 10.0.1.133/24 dev eth3
sudo ip a a 10.0.1.134/24 dev eth3
sudo ip a a 10.0.1.135/24 dev eth3
sudo ip a a 10.0.1.136/24 dev eth3
sudo ip a a 10.0.1.137/24 dev eth3
