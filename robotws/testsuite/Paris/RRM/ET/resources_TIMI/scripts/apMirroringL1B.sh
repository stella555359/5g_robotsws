bsh 1:2 "fpga_rw wa 0xDF1D0398 0x3002000C" > /dev/null
bsh 1:2 "fpga_rw wa 0xDF1D0394 0x3001000C" > /dev/null
dbgrrc mirror sport 3 dport 21 e b > /dev/null
dbgrrc mirror sport 4 dport 21 e b > /dev/null
dbgrrc mirror sport 6 dport 21 enable both > /dev/null
dbgrrc mirror sport 20 dport 21 e b > /dev/null
dbgrrc mirror sport 21 dport 21 e b > /dev/null
dbgrrc mirror sport 22 dport 21 e b > /dev/null
dbgrrc mirror sport 23 dport 21 e b > /dev/null
dbgrrc mirror sport 15 dport 21 e b > /dev/null
dbgrrc mirror sport 25 dport 21 e b > /dev/null

bsh 1:1 "tcpdump -i ethbp1 -s 0 -U -n -B 16384 -w -"