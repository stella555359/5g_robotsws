sudo ip link add link eth3 name eth3.601 type vlan id 601
sudo ip link set dev  eth3.601 up
sudo ip a a 10.0.1.1/24  dev eth3.601 
sudo ip a a 10.0.1.3/24  dev eth3.601 
sudo ip a d 10.0.1.3/24  dev eth3.601 
sudo ip a a 10.0.1.33/24  dev eth3.601 
sudo ip a a 10.0.1.36/24  dev eth3.601 
sudo ip a a 10.0.1.38/24  dev eth3.601 
sudo ip a a fc00::1:12/119  dev eth3.601 
sudo ip a a fc00::1:11/119  dev eth3.601 
sudo ip a a fc00::1:10/119  dev eth3.601 
sudo ip a a fc00::1:1/119  dev eth3.601 

