c1a_tc3_setup_cells_tput_nr = {
    "11": {
        "tput_dl": '1487',
        "tput_ul": '220',
    },
    "22": {
        "tput_dl": '1300',
        "tput_ul": '168',
    },
    "33": {
        "tput_dl": '1487',
        "tput_ul": '220',
    },
}

c1a_tc3_cells_tput_nr = {
    "11": {
        "tput_dl": '1487',
        "tput_ul": '220',
    },
    "33": {
        "tput_dl": '1487',
        "tput_ul": '220',
    },
    "55": {
        "tput_dl": '1487',
        "tput_ul": '220',
    },
}

c1a_tc3_cells_tput_lte = {
    "12": {
        "tput_dl": "135 Mbits/sec",
        "tput_ul": "16 Mbits/sec",
    },
}

c1a_tc3_setup = [
    {
        "name": "block",
        "cell_id": "11"
    },
    {
        "name": "block",
        "cell_id": "22"
    },
    {
        "name": "block",
        "cell_id": "33"
    },
    {
        "name": "block",
        "cell_id": "12"
    },
    {
        "name": "unblock",
        "cell_id": "11"
    },
    {
        "name": "unblock",
        "cell_id": "22"
    },
    {
        "name": "unblock",
        "cell_id": "33"
    },
    {
        "name": "unblock",
        "cell_id": "12"
    },
]
