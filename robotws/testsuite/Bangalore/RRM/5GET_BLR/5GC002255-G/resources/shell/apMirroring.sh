bsh 1:2 "fpga_rw wa 0xDF1D0398 0x3002000C"
bsh 1:2 "fpga_rw wa 0xDF1D0394 0x3001000C"

dbgrrc mirror sport 20 dport 21 e b
dbgrrc mirror sport 15 dport 21 e b
dbgrrc mirror sport 25 dport 21 e b