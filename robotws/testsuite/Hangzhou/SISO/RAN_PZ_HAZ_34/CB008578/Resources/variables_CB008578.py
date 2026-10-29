tput_define_60_90 = {
    'common': {1: {
        'dl_exp': 876,
        'dl_tp': '1000M',
        'ul_exp': 66.5,
        'ul_tp': '100M',
        'ue_index': 0
    },
        2: {
            'dl_exp': 1305,
            'dl_tp': '1500M',
            'ul_exp': 105.5,
            'ul_tp': '150M',
            'ue_index': 1
        }, },
    'SBTS23R3': {1: {
        'dl_exp': 876,
        'dl_tp': '1000M',
        'ul_exp': 61.5,
        'ul_tp': '150M',
        'ue_index': 0
    },
        2: {
            'dl_exp': 1309,
            'dl_tp': '1500M',
            'ul_exp': 100.9,
            'ul_tp': '150M',
            'ue_index': 1
        }, }
}


RU_lock_unlock = {
    1: {
        'dl_exp': 585,
        'dl_tp': '800M',
        'ul_exp': 36.3,
        'ul_tp': '60M',
        'ue_index': 0
    },
}


Cell_lock_unlock = {
    1: {
        'dl_exp': 585,
        'dl_tp': '800M',
        'ul_exp': 36.3,
        'ul_tp': '60M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 585,
        'dl_tp': '800M',
        'ul_exp': 36.3,
        'ul_tp': '60M',
        'ue_index': 1
    },
}


frame_structure_list_100MHz_100MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '100',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '100',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_20MHz_20MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '20',
        'prach_index': ['192'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_60MHz_90MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP2_A6'],
        'band': '60',
        'prach_index': ['192'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP2_A6'],
        'band': '90',
        'prach_index': ['192'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]
