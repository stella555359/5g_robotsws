frame_structure_list_100MHz = ['1208_GP1_A1']
frame_structure_list_90MHz = ['1116_3ms_GP2_A6']
frame_structure_list_70MHz = ['1116_0ms_GP2_A7']
frame_structure_list_60MHz = ['1116_0ms_GP2_A7']
frame_structure_list_50MHz = ['1116_0ms_GP2_A7']
frame_structure_list_40MHz = ['1116_0ms_GP2_A7']
frame_structure_list_30MHz = ['1070_GP1_A3']


rate_for_stream = {
    '19B': 'peak',
    '20A': 'peak',
    '20B': 'peak',
    '21A': 'peak',
    'master': 'peak',
    'SBTS22R1': 'peak',
    'SBTS21B': 'peak'
}


ue_list_1 = [0]
ue_list_2 = [0, 1]

cell_list = [1, 2]

peak_info_1 = {
    '1': {
           'dl_exp': 1260.05,
           'dl_tp': '1500M',
           'ul_exp': 61.48,
           'ul_tp': '100M'
    }
}


peak_info_2 = {
    '1': {
           'dl_exp': 733,
           'dl_tp': '1000M',
           'ul_exp': 49,
           'ul_tp': '100M'
    },
    '2': {
           'dl_exp': 733,
           'dl_tp': '1000M',
           'ul_exp': 49,
           'ul_tp': '100M'
    }
}

peak_info_reduce = {
    '1': {
           'dl_exp': 30,
           'dl_tp': '30M',
           'ul_exp': 51,
           'ul_tp': '100M'
    }
}

peak_info_recovery = {
    1: {
           'dl_exp': 733,
           'dl_tp': '1000M',
           'ul_exp': 51,
           'ul_tp': '100M',
           'ue_index': 0
    }
}

peak_info_3 = {
    '1': {
           'dl_exp': 733,
           'dl_tp': '1000M',
           'ul_exp': 51,
           'ul_tp': '100M'
    },
    '2': {
           'dl_exp': 733,
           'dl_tp': '1000M',
           'ul_exp': 51,
           'ul_tp': '100M'
    }
}

tput_peak = {
    1: {
        'dl_exp': 733,
        'dl_tp': '1000M',
        'ul_exp': 51,
        'ul_tp': '100M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 733,
        'dl_tp': '1000M',
        'ul_exp': 51,
        'ul_tp': '100M',
        'ue_index': 1
    }
}

traffic_info_1 = {
    '1': {
           'dl_exp': 200,
           'dl_tp': '500M',
           'ul_exp': 10,
           'ul_tp': '50M'
    }
}

traffic_info_2 = {
    '1': {
           'dl_exp': 300,
           'dl_tp': '500M',
           'ul_exp': 20,
           'ul_tp': '50M'
    },
    '2': {
           'dl_exp': 300,
           'dl_tp': '500M',
           'ul_exp': 20,
           'ul_tp': '50M'
    }
}
