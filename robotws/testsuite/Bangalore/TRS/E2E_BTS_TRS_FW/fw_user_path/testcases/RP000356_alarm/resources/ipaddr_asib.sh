sudo ip a a 10.0.1.1/24 dev eth3
sudo ip a a 10.0.1.5/24 dev eth3
sudo ip a a 10.0.1.10/24 dev eth3
sudo ip -6 a a fc00::1:1/120 dev eth3
sudo ip -6 a a fc00::1:5/120 dev eth3
sudo ip -6 a a fc00::1:10/120 dev eth3
sudo ip link set dev eth3 up
sudo ip r a 10.0.5.10 via 10.0.1.2 dev eth3
sudo ip -6 r a fc00::5:10 via fc00::1:2 dev eth3
