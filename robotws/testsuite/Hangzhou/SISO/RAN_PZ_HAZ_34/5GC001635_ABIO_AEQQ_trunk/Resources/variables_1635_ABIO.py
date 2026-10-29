frame_structure_list_70MHz_30MHz = [
    {
        'cellid': 1,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '70',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL2UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1116_3ms_GP1_A5'],
        'band': '30',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL2UL',
        'dl_modulation': 'dl_256QAM'
    }
]

frame_structure_list_50MHz_40MHz = [
    {
        'cellid': 1,
        'frame': ['1208_GP1_A1'],
        'band': '50',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
     },
    {
        'cellid': 2,
        'frame': ['1208_GP1_A1'],
        'band': '40',
        'prach_index': ['98'],
        'beamset': '2 beams',
        'dl_ul_layer': '4DL4UL',
        'dl_modulation': 'dl_256QAM'
    }
]

peak_info_reduce = {
    1: {
        'dl_exp': 100,
        'dl_tp': '100M',
        'ul_exp': 60,
        'ul_tp': '100M',
        'ue_index': 0
    }
}

peak_info = {
    1: {
        'dl_exp': 870,
        'dl_tp': '1000M',
        'ul_exp': 60,
        'ul_tp': '100M',
        'ue_index': 0
    }
}
