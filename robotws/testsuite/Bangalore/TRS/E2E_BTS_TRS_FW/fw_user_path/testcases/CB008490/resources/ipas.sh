sudo ip a d 10.0.1.1/24 dev eth3
sudo ip link add link eth3 name eth3.650 type vlan id 650
sudo ip link set dev eth3.650 up

sudo ip a a 10.0.1.1/24 dev eth3.650
sudo ip a a 10.0.1.131/24 dev eth3
sudo ip a a 10.0.1.132/24 dev eth3
sudo ip a a 10.0.1.133/24 dev eth3
sudo ip a a 10.0.1.134/24 dev eth3
sudo ip a a 10.0.1.135/24 dev eth3
sudo ip a a 10.0.1.136/24 dev eth3
sudo ip a a 10.0.1.137/24 dev eth3