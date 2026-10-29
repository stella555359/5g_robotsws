frame_structure_list_50MHz_50MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '50',
        'prach_index': ['192'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '50',
        'prach_index': ['192'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL8UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_30MHz_40MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '30',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
    },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '40',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '8DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]

tput_define_50_50 = {
    1: {
        'dl_exp': 741.5,
        'dl_tp': '1000M',
        'ul_exp': 53.8,
        'ul_tp': '100M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 741.5,
        'dl_tp': '1000M',
        'ul_exp': 53.8,
        'ul_tp': '100M',
        'ue_index': 1
    }
}

tput_define_30_40 = {
    'common': {1: {
        'dl_exp': 434,
        'dl_tp': '800M',
        'ul_exp': 29.98,
        'ul_tp': '60M',
        'ue_index': 0
    },
        2: {
            'dl_exp': 600,
            'dl_tp': '1000M',
            'ul_exp': 41.5,
            'ul_tp': '80M',
            'ue_index': 1
        }, },
    'SBTS23R3': {1: {
        'dl_exp': 434,
        'dl_tp': '800M',
        'ul_exp': 29.2,
        'ul_tp': '60M',
        'ue_index': 0
    },
        2: {
            'dl_exp': 600,
            'dl_tp': '1000M',
            'ul_exp': 39.9,
            'ul_tp': '80M',
            'ue_index': 1
        }, }
}

tput_define_100 = {
    'common': {1: {
        'dl_exp': 1557.6,
        'dl_tp': '1800M',
        'ul_exp': 118.9,
        'ul_tp': '150M',
        'ue_index': 0
    }, },
    'SBTS23R3': {1: {
        'dl_exp': 1557.6,
        'dl_tp': '1800M',
        'ul_exp': 115.9,
        'ul_tp': '150M',
        'ue_index': 0
    }, }
}


RU_lock_unlock = {
    1: {
        'dl_exp': 1557.6,
        'dl_tp': '1800M',
        'ul_exp': 118.9,
        'ul_tp': '150M',
        'ue_index': 0
    },
}


Cell_lock_unlock = {
    1: {
        'dl_exp': 741.5,
        'dl_tp': '1000M',
        'ul_exp': 53.8,
        'ul_tp': '100M',
        'ue_index': 0
    },
    2: {
        'dl_exp': 741.5,
        'dl_tp': '1000M',
        'ul_exp': 53.8,
        'ul_tp': '100M',
        'ue_index': 1
    },
}
