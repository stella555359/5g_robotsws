tput_20M_20M = {
    1: {"dl_exp": 253, "dl_tp": "350M", "ul_exp": 29, "ul_tp": "80M", "ue_index": 0},
    2: {"dl_exp": 253, "dl_tp": "350M", "ul_exp": 29, "ul_tp": "80M", "ue_index": 1},
}


tput_100M = {
    1: {"dl_exp": 600, "dl_tp": "800M", "ul_exp": 100, "ul_tp": "150M", "ue_index": 0},
}


tput_40M_60M = {
    1: {"dl_exp": 535, "dl_tp": "700M", "ul_exp": 67, "ul_tp": "100M", "ue_index": 0},
    2: {"dl_exp": 820, "dl_tp": "1000M", "ul_exp": 99, "ul_tp": "150M", "ue_index": 1},
}

tput_50M_100M = {
    1: {"dl_exp": 669, "dl_tp": "800M", "ul_exp": 81, "ul_tp": "100M", "ue_index": 0},
    2: {"dl_exp": 600, "dl_tp": "1000M", "ul_exp": 186, "ul_tp": "250M", "ue_index": 1},
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
