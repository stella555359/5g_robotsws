sudo ip link delete dev eth3.600
sudo ip link delete dev eth3.601
sudo ip link delete dev eth3.602
sudo ip link delete dev eth3.603
sudo ip link delete dev eth3.604
sudo ip link delete dev eth3.605
sudo ip link delete dev eth3.606
sudo ip link delete dev eth3.607
sudo ip link delete dev eth3.608
sudo ip link delete dev eth3.609
sudo ip link delete dev eth3.610
sudo ip link delete dev eth3.611

sudo ip addr flush dev eth3

sudo ip link add link eth3 name eth3.600 type vlan id 600
sudo ip addr add 10.0.1.1/24 dev eth3.600 
sudo ip addr add fc00::1:1/123 dev eth3.600 
sudo ip link set dev eth3.600 up

sudo ip link add link eth3 name eth3.601 type vlan id 601
sudo ip addr add 10.0.3.1/24 dev eth3.601 
sudo ip addr add fc00::3:1/123 dev eth3.601 
sudo ip link set dev eth3.601 up

sudo ip link add link eth3 name eth3.602 type vlan id 602
sudo ip addr add 10.0.4.1/24 dev eth3.602 
sudo ip addr add fc00::4:1/123 dev eth3.602 
sudo ip link set dev eth3.602 up

sudo ip link add link eth3 name eth3.603 type vlan id 603
sudo ip addr add 10.0.5.1/24 dev eth3.603 
sudo ip addr add fc00::5:1/123 dev eth3.603 
sudo ip link set dev eth3.603 up

sudo ip link add link eth3 name eth3.604 type vlan id 604
sudo ip addr add 10.0.6.1/24 dev eth3.604 
sudo ip addr add fc00::6:1/123 dev eth3.604 
sudo ip link set dev eth3.604 up


sudo ip link add link eth3 name eth3.605 type vlan id 605
sudo ip addr add 10.0.7.1/24 dev eth3.605 
sudo ip addr add fc00::7:1/123 dev eth3.605 
sudo ip link set dev eth3.605 up


sudo ip link add link eth3 name eth3.606 type vlan id 606
sudo ip addr add 10.0.8.1/24 dev eth3.606 
sudo ip addr add fc00::8:1/123 dev eth3.606 
sudo ip link set dev eth3.606 up


sudo ip link add link eth3 name eth3.607 type vlan id 607
sudo ip addr add 10.0.9.1/24 dev eth3.607 
sudo ip addr add fc00::9:1/123 dev eth3.607 
sudo ip link set dev eth3.607 up

sudo ip link add link eth3 name eth3.608 type vlan id 608
sudo ip addr add 10.0.10.1/24 dev eth3.608 
sudo ip addr add fc00::a:1/123 dev eth3.608 
sudo ip link set dev eth3.608 up

sudo ip link add link eth3 name eth3.609 type vlan id 609
sudo ip addr add 10.0.11.1/24 dev eth3.609 
sudo ip addr add fc00::b:1/123 dev eth3.609 
sudo ip link set dev eth3.609 up

sudo ip link add link eth3 name eth3.610 type vlan id 610
sudo ip addr add 10.0.12.1/24 dev eth3.610 
sudo ip addr add fc00::c:1/123 dev eth3.610 
sudo ip link set dev eth3.610 up

sudo ip link add link eth3 name eth3.611 type vlan id 611
sudo ip addr add 10.0.13.1/24 dev eth3.611 
sudo ip addr add fc00::d:1/123 dev eth3.611 
sudo ip link set dev eth3.611 up

sudo ip link add link eth3 name eth3.612 type vlan id 612
sudo ip addr add 10.0.14.1/24 dev eth3.612 
sudo ip addr add fc00::e:1/123 dev eth3.612 
sudo ip link set dev eth3.612 up

sudo ip link add link eth3 name eth3.613 type vlan id 613
sudo ip addr add 10.0.15.1/24 dev eth3.613 
sudo ip addr add fc00::f:1/123 dev eth3.613 
sudo ip link set dev eth3.613 up

sudo ip link add link eth3 name eth3.614 type vlan id 614
sudo ip addr add 10.0.16.1/24 dev eth3.614 
sudo ip addr add fc00::10:1/123 dev eth3.614 
sudo ip link set dev eth3.614 up

sudo ip link add link eth3 name eth3.615 type vlan id 615
sudo ip addr add 10.0.17.1/24 dev eth3.615 
sudo ip addr add fc00::11:1/123 dev eth3.615 
sudo ip link set dev eth3.615 up

sudo ip link add link eth3 name eth3.616 type vlan id 616
sudo ip addr add 10.0.18.1/24 dev eth3.616 
sudo ip addr add fc00::12:1/123 dev eth3.616 
sudo ip link set dev eth3.616 up

sudo ip link add link eth3 name eth3.617 type vlan id 617
sudo ip addr add 10.0.19.1/24 dev eth3.617 
sudo ip addr add fc00::13:1/123 dev eth3.617 
sudo ip link set dev eth3.617 up

sudo ip link add link eth3 name eth3.618 type vlan id 618
sudo ip addr add 10.0.20.1/24 dev eth3.618 
sudo ip addr add fc00::14:1/123 dev eth3.618 
sudo ip link set dev eth3.618 up

sudo ip link add link eth3 name eth3.619 type vlan id 619
sudo ip addr add 10.0.21.1/24 dev eth3.619 
sudo ip addr add fc00::15:1/123 dev eth3.619 
sudo ip link set dev eth3.619 up

sudo ip link add link eth3 name eth3.620 type vlan id 620
sudo ip addr add 10.0.22.1/24 dev eth3.620 
sudo ip addr add fc00::16:1/123 dev eth3.620 
sudo ip link set dev eth3.620 up

sudo ip link add link eth3 name eth3.621 type vlan id 621
sudo ip addr add 10.0.23.1/24 dev eth3.621 
sudo ip addr add fc00::17:1/123 dev eth3.621 
sudo ip link set dev eth3.621 up



sudo ip a a 10.0.100.1/24 dev eth3
sudo ip a a 10.0.101.1/24 dev eth3
sudo ip a a 10.0.102.1/24 dev eth3
sudo ip a a 10.0.103.1/24 dev eth3
sudo ip a a 10.0.104.1/24 dev eth3
sudo ip a a 10.0.105.1/24 dev eth3
sudo ip a a 10.0.106.1/24 dev eth3
sudo ip a a 10.0.1.133/24 dev eth3
sudo ip a a 10.0.1.134/24 dev eth3
sudo ip a a 10.0.1.135/24 dev eth3
sudo ip a a 10.0.1.136/24 dev eth3
sudo ip a a 10.0.1.137/24 dev eth3

sudo ip a a fc00::100:1/126 dev eth3
sudo ip a a fc00::101:1/126 dev eth3
sudo ip a a fc00::102:1/126 dev eth3
sudo ip a a fc00::103:1/126 dev eth3
sudo ip a a fc00::104:1/126 dev eth3
sudo ip a a fc00::105:1/126 dev eth3
sudo ip a a fc00::106:1/126 dev eth3
sudo ip a a fc00::1:133/126 dev eth3

sudo ip a a 10.0.107.1/24 dev eth3
sudo ip a a 10.0.108.1/24 dev eth3
sudo ip a a 10.0.109.1/24 dev eth3
sudo ip a a 10.0.110.1/24 dev eth3
sudo ip a a fc00::107:1/126 dev eth3
sudo ip a a fc00::108:1/126 dev eth3
sudo ip a a fc00::109:1/126 dev eth3
sudo ip a a fc00::10a:1/126 dev eth3
