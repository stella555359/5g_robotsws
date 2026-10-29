# TPUT
TPUT_EXP = {
    'ul_exp_Pcell': 17,
    'dl_exp_Pcell': 270,
    'dl_exp_Scell': 260,
}

A7_TPUT = {
    'ul_send': '50M',
    'dl_send': '400M',
    'ul_exp_tp': 27.8,
    'dl_exp_tp': 153,
    'ul_send6': '50M',
    'dl_send6': '300M',
    'ul_exp_tp6': 27.8,
    'dl_exp_tp6': 153
}

B6_TPUT = {
    'ul_send': '50M',
    'dl_send': '400M',
    'ul_exp_tp': 21,
    'dl_exp_tp': 241,
    'ul_send2': '50M',
    'dl_send2': '500M',
    'ul_exp_tp2': 21,
    'dl_exp_tp2': 241,
    'ul_send5': '50M',
    'dl_send5': '400M',
    'ul_exp_tp5': 21,
    'dl_exp_tp5': 235,
    'ul_send6': '50M',
    'dl_send6': '500M',
    'ul_exp_tp6': 21,
    'dl_exp_tp6': 235
}
# General_SiSo_E2E_system_setup_with_data_transfer
Exp_Len = '5m'

frame_structure_list_20MHz_20MHz = [
    {
        'cellid': 1,
        'frame': ['1208_GP1_A1'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1208_GP1_A1'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 3,
        'frame': ['1208_GP1_A1'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 4,
        'frame': ['1208_GP1_A1'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 5,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 6,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': 'single beam',
        'dl_ul_layer': '2DL2UL',
        'dl_modulation': 'dl_256QAM'
    }
]

rate_for_stream = {
    '21A': 'peak',
    '20B': 'peak',
    '21B': 'peak',
    'SBTS21B': 'peak',
    'SBTS22R1': 'peak',
    'SBTS22R3': 'peak',
    'master': 'peak'
}

tput_80M = {
    1: {
        'dl_exp': 1154,
        'dl_tp': '1200M',
        'ul_exp': 78,
        'ul_tp': '100M',
        'ue_index': 0
    },
}
