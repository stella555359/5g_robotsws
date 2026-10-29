
#NSA TDD FS -BIP logs Collection
#:'
bsh 1:2 "fpga_rw wa 0xDF1D0398 0x3002000C" > /dev/null
sleep 1
bsh 1:2 "fpga_rw wa 0xDF1D0394 0x3001000C" > /dev/null
sleep 1
bsh 1:2 "fpga_rw wa 0xDF1D0394 0x1003000A" > /dev/null
sleep 1
bsh 1:2 "fpga_rw wa 0xDF1D039C 0x3001000A" > /dev/null
sleep 1
bsh 1:2 "fpga_rw wa 0xDF1D0394 0x3001000C" > /dev/null
sleep 1
dbgrrc mirror sport 3 dport 3 e b > /dev/null
dbgrrc mirror sport 4 dport 3 e b > /dev/null
dbgrrc mirror sport 7 dport 3 e b > /dev/null
dbgrrc mirror sport 2 dport 3 e b > /dev/null
dbgrrc mirror sport 6 dport 3 e b > /dev/null
sleep 1
dbgrrc mirror sport 20 dport 3 e b > /dev/null
dbgrrc mirror sport 21 dport 3 e b > /dev/null
dbgrrc mirror sport 22 dport 3 e b > /dev/null
dbgrrc mirror sport 23 dport 3 e b > /dev/null
dbgrrc mirror sport 15 dport 3 e b > /dev/null
dbgrrc mirror sport 25 dport 3 e b > /dev/null
sleep 1
tcpdump -i etha01 -s 0 -U -n -B 16384 -w -
