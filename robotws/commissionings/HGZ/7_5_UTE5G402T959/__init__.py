__maintainer__ = 'Lin jiangjing'
__team__ = '5G_PZ_HZ_8_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'ue_ul_layer': 2,
}

ue_mapping_2 = {
    'ue_index': 1,  # ue index in TL
    'ue_ul_layer': 2,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
    }
]


pa_info = [
    {
        'scf_name': '*',  # * means all scf common
        'cells_pa_ports': {
                1: [213, 246],
                3: [197, 230],
                4: [199, 232],
                401: [21, 54],
                402: [21, 54],
                403: [5, 38],
                404: [5, 38],
                405: [7, 40],
                406: [7, 40],
            }
    },
    {
        'scf_name': 'SCF_SBTS00_11050.xml',  # * means all scf common
        'cells_pa_ports': {
                1: [213, 246],
                3: [197, 230],
                4: [199, 232],
                401: [21, 54],
                402: [21, 54],
                403: [5, 38],
                404: [5, 38],
                405: [7, 40],
                406: [7, 40],
            }
    },
    {
        'scf_name': 'SCF_SBTS00_config8953_7.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [149, 182],
            2: [149, 182],
            3: [215, 248],
            4: [215, 248],
            11: [21, 54],
            12: [21, 54],
            13: [23, 56],
            14: [23, 56],
            15: [1, 34],
            16: [1, 34],
        }
    },
    {
        'scf_name': 'SCF_SBTS24R1_config8953_7.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [149, 182],
            2: [149, 182],
            3: [215, 248],
            4: [215, 248],
            11: [21, 54],
            12: [21, 54],
            13: [23, 56],
            14: [23, 56],
            15: [1, 34],
            16: [1, 34],
        }
    },
]
