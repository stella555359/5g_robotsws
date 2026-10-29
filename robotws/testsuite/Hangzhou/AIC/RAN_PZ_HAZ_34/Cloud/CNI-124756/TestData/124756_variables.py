tput_20M_20M = {
    1: {"dl_exp": 50, "dl_tp": "500M", "ul_exp": 20, "ul_tp": "100M", "ue_index": 0},
    2: {"dl_exp": 50, "dl_tp": "500M", "ul_exp": 20, "ul_tp": "100M", "ue_index": 1},
}


tput_100M = {
    1: {"dl_exp": 500, "dl_tp": "1000M", "ul_exp": 100, "ul_tp": "300M", "ue_index": 0},
}


tput_40M_60M = {
    1: {"dl_exp": 550, "dl_tp": "1000M", "ul_exp": 60, "ul_tp": "300M", "ue_index": 0},
    2: {"dl_exp": 850, "dl_tp": "1000M", "ul_exp": 95, "ul_tp": "300M", "ue_index": 1},
}

tput_50M_100M = {
    1: {"dl_exp": 200, "dl_tp": "1000M", "ul_exp": 50, "ul_tp": "50M", "ue_index": 0},
    2: {"dl_exp": 200, "dl_tp": "1000M", "ul_exp": 50, "ul_tp": "300M", "ue_index": 1},
}

commands = [
    "/sbin/devmem 0xFB1902FC 32 0",
    "/sbin/devmem 0xFB19037c 32 0x1",
    "/sbin/devmem 0xFB190300 32 0",
    "/sbin/devmem 0xFB19037c 32 0x2",
    "/sbin/devmem 0xFB190304 32 0",
    "/sbin/devmem 0xFB19037c 32 0x4",
    "/sbin/devmem 0xFB190308 32 0",
    "/sbin/devmem 0xFB19037c 32 0x8",
    "/sbin/devmem 0xFB2102FC 32 0",
    "/sbin/devmem 0xFB21037c 32 0x1",
]
