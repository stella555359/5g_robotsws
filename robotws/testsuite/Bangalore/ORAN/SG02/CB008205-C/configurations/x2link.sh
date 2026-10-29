sudo systemctl restart networking.service
		sleep 3
		sudo ip a add 10.0.1.121/24 dev eth3
		sudo ip a add 10.0.1.131/24 dev eth3
		sudo ip a add 10.0.1.132/24 dev eth3
		sudo ip a add 10.0.1.133/24 dev eth3
		sudo ip a add 10.0.1.134/24 dev eth3
		sudo ip a add 10.0.1.135/24 dev eth3
		sudo ip a add 10.0.1.136/24 dev eth3
		sudo ip a add 10.0.1.137/24 dev eth3
		sudo ip a add 10.0.1.138/24 dev eth3
		sudo ip a add 10.0.1.150/24 dev eth3
		sudo ip a add 10.0.1.112/24 dev eth3

		sleep 3
		killall -9 egate
		sudo killall -9 edaemon
		cd /opt/iphy/latest
		sudo ./edaemon --port 22222
		./egate --port 20000
		echo done
		sleep 5

		{
		sleep 3
		echo cfg file=/home/ute/MN/UTE/robotws/testsuite/Bangalore/ORAN/SG02/CB008205-C/configurations/basic_wts.cfg
		sleep 6
		echo enb_x2_link_up enb=1 target=2
		sleep 1
		} | telnet localhost 20000
		sleep 10
