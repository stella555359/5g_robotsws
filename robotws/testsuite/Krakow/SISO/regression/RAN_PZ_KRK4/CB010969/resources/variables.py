import os

TRUNK = 'SBTS26R1'
COLLECT_LOGS_DURING_DATA_TRANSFER = False

bool_true = True
bool_false = False
int_8 = 8
int_300 = 300
int_500 = 500
int_600 = 600
int_900 = 900
int_1500 = 1500

called_cell = ["MRBTS-75180/NRBTS-75180/NRCELL-2"]
tput = {
    '1231749122': {
        'throughput': {
            'downlink': '550 Mbits/sec',
            'uplink': '100 Mbits/sec'
        },
        'info': '-',
        'deviation': '40%'
    }
}
logs_path = '/home/ute/logs/CB010969-B1/'
cell_to_attenuator_output = {
    1: [3, 4],
    2: [5, 6],
    11: [1, 2],
    12: [7, 8]
}
max_tput_for_cells = {
    1: {'DL': 220, 'UL': 229},
    2: {'DL': 228, 'UL': 229},
    11: {'DL': 188, 'UL': 68},
    12: {'DL': 188, 'UL': 68}
}

cells = [1, 2, 11, 12]

timeZone_param = [{'dist_name': 'MRBTS-75180/MNL-1', 'filter_param': 'Time zone', 'abbr': 'timeZone',
                   'new_value': '(GMT+1) Europe/Warsaw'}]

browser = 'Firefox'
