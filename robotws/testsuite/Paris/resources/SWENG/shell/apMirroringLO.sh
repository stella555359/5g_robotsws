
dbgnac set port 1 loop e t
dbgnac mirror sport 12 dport 1 e b
dbgnac mirror sport 16 dport 1 e b
dbgnac mirror sport 1 dport 20 e b
ifconfig nac_eth1 up
