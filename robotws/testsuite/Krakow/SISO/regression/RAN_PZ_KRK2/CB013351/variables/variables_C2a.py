c2a_tc14_setup_cells_tput = {
    "1": {
        "tput_dl": '700 Mbits/sec',
        "tput_ul": '83 Mbits/sec',
    },
    "2": {
        "tput_dl": '700 Mbits/sec',
        "tput_ul": '83 Mbits/sec',
    },
    "3": {
        "tput_dl": '700 Mbits/sec',
        "tput_ul": '83 Mbits/sec',
    },
    "4": {
        "tput_dl": '575 Mbits/sec',
        "tput_ul": '67 Mbits/sec',
    },
}

c2a_tc14_cells_tput = {
    "2": {
        "tput_dl": '700 Mbits/sec',
        "tput_ul": '83 Mbits/sec',
    },
    "4": {
        "tput_dl": '575 Mbits/sec',
        "tput_ul": '67 Mbits/sec',
    },
    "5": {
        "tput_dl": '1460 Mbits/sec',
        "tput_ul": '154 Mbits/sec',
    },
}

c2a_tc15_cells_tput = {
    "2": {
        "tput_dl": '700 Mbits/sec',
        "tput_ul": '83 Mbits/sec',
    },
    "4": {
        "tput_dl": '575 Mbits/sec',
        "tput_ul": '67 Mbits/sec',
    },
    "5": {
        "tput_dl": '1460 Mbits/sec',
        "tput_ul": '154 Mbits/sec',
    },
}


c2a_tc14_setup = [
    {
        "name": "block",
        "cell_id": "1"
    },
    {
        "name": "block",
        "cell_id": "2"
    },
    {
        "name": "block",
        "cell_id": "3"
    },
    {
        "name": "block",
        "cell_id": "4"
    },
    {
        "name": "unblock",
        "cell_id": "1"
    },
    {
        "name": "unblock",
        "cell_id": "2"
    },
    {
        "name": "unblock",
        "cell_id": "3"
    },
    {
        "name": "unblock",
        "cell_id": "4"
    },
]

c2a_tc15_setup = [
    {
        "name": "block",
        "cell_id": "2"
    },
    {
        "name": "block",
        "cell_id": "4"
    },
    {
        "name": "block",
        "cell_id": "5"
    },
    {
        "name": "unblock",
        "cell_id": "2"
    },
    {
        "name": "unblock",
        "cell_id": "4"
    },
    {
        "name": "unblock",
        "cell_id": "5"
    },
]

c2a_tc15 = [
    {
        "name": "block",
        "cell_id": "2"
    },
    {
        "name": "block",
        "cell_id": "5"
    },
    {
        "name": "unblock",
        "cell_id": "2"
    },
    {
        "name": "unblock",
        "cell_id": "5"
    },
]

c2a_tc15_alt = [
    {
        "name": "block",
        "cell_id": "2"
    },
    {
        "name": "block",
        "cell_id": "5"
    },
    {
        "name": "unblock",
        "cell_id": "5"
    },
    {
        "name": "unblock",
        "cell_id": "2"
    },
]
