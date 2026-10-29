sudo ip link add link eth3 name eth3.1011 type vlan id 1011
sudo ip addr add 10.0.3.1/28 dev eth3.1011
sudo ip addr add fc00::3:1/123 dev eth3.1011
sudo ip link set dev eth3.1011 up

sudo ip link add link eth3 name eth3.1012 type vlan id 1012
sudo ip addr add 10.0.4.1/26 dev eth3.1012
sudo ip addr add fc00::4:1/123 dev eth3.1012
sudo ip link set dev eth3.1012 up


sudo ip link add link eth3 name eth3.1010 type vlan id 1010
sudo ip link set dev eth3.1010 up
sudo ip addr add 10.0.4.131/32 dev eth3.1010
sudo ip addr add 10.0.4.121/32 dev eth3.1010

sudo ip addr add fc00::4:131/128 dev eth3.1010
sudo ip addr add fc00::4:121/128 dev eth3.1010
sudo ip addr add fc00::4:151/128 dev eth3.1010
sudo ip addr add fc00::4:152/128 dev eth3.1010
sudo ip addr add fc00::4:153/128 dev eth3.1010

sudo ip addr add 10.0.4.133/32 dev eth3.1010
sudo ip addr add fc00::4:133/128 dev eth3

sudo ip addr add 10.0.1.150/32 dev eth3
sudo ip addr add 10.0.1.151/32 dev eth3
