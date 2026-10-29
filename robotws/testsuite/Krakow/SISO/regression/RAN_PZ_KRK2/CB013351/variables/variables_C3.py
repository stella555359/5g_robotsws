c3_tc17_cells_tput = {
    "2": {
        "tput_dl": '1280 Mbits/sec',
        "tput_ul": '185 Mbits/sec',
    },
    "12": {
        "tput_dl": '1100 Mbits/sec',
        "tput_ul": '160 Mbits/sec',
    },
    "22": {
        "tput_dl": '425 Mbits/sec',
        "tput_ul": '53 Mbits/sec',
    },
    "32": {
        "tput_dl": '270 Mbits/sec',
        "tput_ul": '32 Mbits/sec',
    },
}

c3_setup = [
    {
        "name": "block",
        "cell_id": "2"
    },
    {
        "name": "block",
        "cell_id": "12"
    },
    {
        "name": "block",
        "cell_id": "22"
    },
    {
        "name": "block",
        "cell_id": "32"
    },
    {
        "name": "unblock",
        "cell_id": "2"
    },
    {
        "name": "unblock",
        "cell_id": "12"
    },
    {
        "name": "unblock",
        "cell_id": "22"
    },
    {
        "name": "unblock",
        "cell_id": "32"
    },
]

c3_tc17 = [
    {
        "name": "block",
        "cell_id": "2"
    },
    {
        "name": "block",
        "cell_id": "22"
    },
    {
        "name": "block",
        "cell_id": "32"
    },
    {
        "name": "unblock",
        "cell_id": "22"
    },
    {
        "name": "unblock",
        "cell_id": "32"
    },
    {
        "name": "unblock",
        "cell_id": "2"
    },
]

additional_allowed_alarms = [
    {'alarm_id': 61675, 'fault_id': 61675, 'fault_name': 'WiFi Configuration Issue',
     'severity': 'Minor'}
]
