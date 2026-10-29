sudo ip link add link eth3 name eth3.901 type vlan id 901
sudo ip addr add 10.0.1.1/24 dev eth3.901
sudo ip addr add fc00::1:1/119 dev eth3.901
sudo ip link set dev eth3.901 up

sudo ip link add link eth3 name eth3.902 type vlan id 902
sudo ip addr add 10.0.3.1/24 dev eth3.902
sudo ip addr add fc00::3:1/119 dev eth3.902
sudo ip link set dev eth3.902 up

sudo ip link add link eth3 name eth3.903 type vlan id 903
sudo ip addr add 10.0.4.1/24 dev eth3.903
sudo ip addr add fc00::4:1/119 dev eth3.903
sudo ip link set dev eth3.903 up

sudo ip link add link eth3 name eth3.904 type vlan id 904
sudo ip addr add 10.0.5.1/24 dev eth3.904
sudo ip addr add fc00::5:1/119 dev eth3.904
sudo ip link set dev eth3.904 up

sudo ip link add link eth3 name eth3.905 type vlan id 905
sudo ip addr add 10.0.6.1/24 dev eth3.905
sudo ip addr add fc00::6:1/119 dev eth3.905
sudo ip link set dev eth3.905 up

sudo ip link add link eth3 name eth3.906 type vlan id 906
sudo ip addr add 10.0.7.1/24 dev eth3.906
sudo ip addr add fc00::7:1/119 dev eth3.906
sudo ip link set dev eth3.906 up


sudo ip link add link eth3 name eth3.907 type vlan id 907
sudo ip addr add 10.0.8.1/24 dev eth3.907
sudo ip addr add fc00::8:1/119 dev eth3.907
sudo ip link set dev eth3.907 up

sudo ip link add link eth3 name eth3.908 type vlan id 908
sudo ip addr add 10.0.9.1/24 dev eth3.908
sudo ip addr add fc00::9:1/119 dev eth3.908
sudo ip link set dev eth3.908 up

sudo ip link add link eth3 name eth3.909 type vlan id 909
sudo ip addr add 10.0.10.1/24 dev eth3.909
sudo ip addr add fc00::a:1/119 dev eth3.909
sudo ip link set dev eth3.909 up

sudo ip link add link eth3 name eth3.910 type vlan id 910
sudo ip addr add 10.0.11.1/24 dev eth3.910
sudo ip addr add fc00::b:1/119 dev eth3.910
sudo ip link set dev eth3.910 up

sudo ip addr add 10.0.1.131/32 dev eth3.901
sudo ip addr add 10.0.1.132/32 dev eth3.901
sudo ip addr add 10.0.1.133/32 dev eth3.901
sudo ip addr add 10.0.1.134/32 dev eth3.901
sudo ip addr add 10.0.1.135/32 dev eth3.901
sudo ip addr add 10.0.1.121/32 dev eth3.901
sudo ip addr add 10.0.1.141/32 dev eth3.901
sudo ip addr add 10.0.1.151/32 dev eth3.901
sudo ip addr add 10.0.3.131/32 dev eth3.902
sudo ip addr add 10.0.3.132/32 dev eth3.902
sudo ip addr add 10.0.3.133/32 dev eth3.902
sudo ip addr add 10.0.3.134/32 dev eth3.902
sudo ip addr add 10.0.3.135/32 dev eth3.902
sudo ip addr add 10.0.4.131/32 dev eth3.903
sudo ip addr add 10.0.4.132/32 dev eth3.903
sudo ip addr add 10.0.4.133/32 dev eth3.903
sudo ip addr add 10.0.4.134/32 dev eth3.903
sudo ip addr add 10.0.4.135/32 dev eth3.903
sudo ip addr add 10.0.5.131/32 dev eth3.904
sudo ip addr add 10.0.5.132/32 dev eth3.904
sudo ip addr add 10.0.5.133/32 dev eth3.904
sudo ip addr add 10.0.5.134/32 dev eth3.904
sudo ip addr add 10.0.5.135/32 dev eth3.904
sudo ip addr add 10.0.6.131/32 dev eth3.905
sudo ip addr add 10.0.6.132/32 dev eth3.905
sudo ip addr add 10.0.6.133/32 dev eth3.905
sudo ip addr add 10.0.6.134/32 dev eth3.905
sudo ip addr add 10.0.6.135/32 dev eth3.905
sudo ip addr add 10.0.7.131/32 dev eth3.906
sudo ip addr add 10.0.7.132/32 dev eth3.906
sudo ip addr add 10.0.7.133/32 dev eth3.906
sudo ip addr add 10.0.7.134/32 dev eth3.906
sudo ip addr add 10.0.7.135/32 dev eth3.906
sudo ip addr add 10.0.8.131/32 dev eth3.907
sudo ip addr add 10.0.8.132/32 dev eth3.907
sudo ip addr add 10.0.8.133/32 dev eth3.907
sudo ip addr add 10.0.8.134/32 dev eth3.907
sudo ip addr add 10.0.8.135/32 dev eth3.907
sudo ip addr add 10.0.9.131/32 dev eth3.908
sudo ip addr add 10.0.9.132/32 dev eth3.908
sudo ip addr add 10.0.9.133/32 dev eth3.908
sudo ip addr add 10.0.9.134/32 dev eth3.908
sudo ip addr add 10.0.9.135/32 dev eth3.908
sudo ip addr add 10.0.10.131/32 dev eth3.909
sudo ip addr add 10.0.10.132/32 dev eth3.909
sudo ip addr add 10.0.10.133/32 dev eth3.909
sudo ip addr add 10.0.10.134/32 dev eth3.909
sudo ip addr add 10.0.10.135/32 dev eth3.909
sudo ip addr add 10.0.11.131/32 dev eth3.910
sudo ip addr add 10.0.11.132/32 dev eth3.910
sudo ip addr add 10.0.11.133/32 dev eth3.910
sudo ip addr add 10.0.11.134/32 dev eth3.910
sudo ip addr add 10.0.11.135/32 dev eth3.910

sudo ip addr add fc00::1:131/128 dev eth3.901
sudo ip addr add fc00::1:132/128 dev eth3.901
sudo ip addr add fc00::1:133/128 dev eth3.901
sudo ip addr add fc00::1:134/128 dev eth3.901
sudo ip addr add fc00::1:135/128 dev eth3.901
sudo ip addr add fc00::3:131/128 dev eth3.902
sudo ip addr add fc00::3:132/128 dev eth3.902
sudo ip addr add fc00::3:133/128 dev eth3.902
sudo ip addr add fc00::3:134/128 dev eth3.902
sudo ip addr add fc00::3:135/128 dev eth3.902
sudo ip addr add fc00::4:131/128 dev eth3.903
sudo ip addr add fc00::4:132/128 dev eth3.903
sudo ip addr add fc00::4:133/128 dev eth3.903
sudo ip addr add fc00::4:134/128 dev eth3.903
sudo ip addr add fc00::4:135/128 dev eth3.903
sudo ip addr add fc00::5:131/128 dev eth3.904
sudo ip addr add fc00::5:132/128 dev eth3.904
sudo ip addr add fc00::5:133/128 dev eth3.904
sudo ip addr add fc00::5:134/128 dev eth3.904
sudo ip addr add fc00::5:135/128 dev eth3.904
sudo ip addr add fc00::6:131/128 dev eth3.905
sudo ip addr add fc00::6:132/128 dev eth3.905
sudo ip addr add fc00::6:133/128 dev eth3.905
sudo ip addr add fc00::6:134/128 dev eth3.905
sudo ip addr add fc00::6:135/128 dev eth3.905
sudo ip addr add fc00::7:131/128 dev eth3.906
sudo ip addr add fc00::7:132/128 dev eth3.906
sudo ip addr add fc00::7:133/128 dev eth3.906
sudo ip addr add fc00::7:134/128 dev eth3.906
sudo ip addr add fc00::7:135/128 dev eth3.906
sudo ip addr add fc00::8:131/128 dev eth3.907
sudo ip addr add fc00::8:132/128 dev eth3.907
sudo ip addr add fc00::8:133/128 dev eth3.907
sudo ip addr add fc00::8:134/128 dev eth3.907
sudo ip addr add fc00::8:135/128 dev eth3.907
sudo ip addr add fc00::9:131/128 dev eth3.908
sudo ip addr add fc00::9:132/128 dev eth3.908
sudo ip addr add fc00::9:133/128 dev eth3.908
sudo ip addr add fc00::9:134/128 dev eth3.908
sudo ip addr add fc00::9:135/128 dev eth3.908
sudo ip addr add fc00::a:131/128 dev eth3.909
sudo ip addr add fc00::a:132/128 dev eth3.909
sudo ip addr add fc00::a:133/128 dev eth3.909
sudo ip addr add fc00::a:134/128 dev eth3.909
sudo ip addr add fc00::a:135/128 dev eth3.909
sudo ip addr add fc00::b:131/128 dev eth3.910
sudo ip addr add fc00::b:132/128 dev eth3.910
sudo ip addr add fc00::b:133/128 dev eth3.910
sudo ip addr add fc00::b:134/128 dev eth3.910
sudo ip addr add fc00::b:135/128 dev eth3.910



