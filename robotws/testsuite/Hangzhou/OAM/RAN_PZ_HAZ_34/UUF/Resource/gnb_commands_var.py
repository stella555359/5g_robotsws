LIST__tcpdump_enable_commands = [
    "cd /ffs/run/config/toor4nsn/",
    "./loner_mirroring_v2.sh",
    "fpga_rw wa 0xDF1E02B8 0x2328",
    "fpga_rw wa 0xDF1E12B8 0x2328",
    "fpga_rw wa 0xDF1E00B0 0x2328",
    "fpga_rw wa 0xDF1E10B0 0x2328"
]

LIST___tcpdump_network_commands = [
    "dbgrrc mirror sport 22 dport 2 e b"
]
