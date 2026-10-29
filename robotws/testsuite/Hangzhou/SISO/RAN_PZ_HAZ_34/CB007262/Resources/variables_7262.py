frame_structure_list_100MHz = ['1208_GP1_A1']
frame_structure_list_90MHz = ['1116_3ms_GP1_A5']
frame_structure_list_70MHz = ['1116_0ms_GP2_A7']
frame_structure_list_60MHz = ['1116_0ms_GP2_A7']
frame_structure_list_50MHz = ['1116_0ms_GP2_A7']
frame_structure_list_40MHz = ['1116_0ms_GP2_A7']
frame_structure_list_30MHz = ['1070_GP1_A3']
frame_structure_list_20MHz = ['1116_0ms_GP2_A7']

rate_for_stream = {
    '19B': 'peak',
    '20A': 'peak',
    '20B': 'peak',
    '21A': 'peak',
    'master': 'peak',
    'SBTS22R1': 'peak',
    'SBTS21B': 'peak'
}

ue_list = [0, 1]
cell_list = [1, 2]

cell_and_peak_info_TDD_FDD = {
    '1': {
           'dl_exp': 1100,
           'dl_tp': '1500M',
           'duration': 600,
           'expect_rate': 0.95,
           'peak_dl_tp': '1100M',
           'peak_ul_tp': '60M',
           'ul_exp': 60,
           'ul_tp': '80M'
    },
    '2': {
           'dl_exp': 300,
           'dl_tp': '600M',
           'duration': 600,
           'expect_rate': 0.95,
           'peak_dl_tp': '300M',
           'peak_ul_tp': '20M',
           'ul_exp': 20,
           'ul_tp': '80M'
    }
}

tput = {
    1: {
        'dl_exp': 1450,
        'dl_tp': '1500M',
        'ul_exp': 218,
        'ul_tp': '300M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 218,
        'dl_tp': '300M',
        'ul_exp': 74,
        'ul_tp': '100M',
        'ue_index': 1
    },
}

tput_1635_peak = {
    1: {
        'dl_exp': 733,
        'dl_tp': '1000M',
        'ul_exp': 50,
        'ul_tp': '150M',
        'ue_index': 0
    },
}
