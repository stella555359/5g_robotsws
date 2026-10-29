__maintainer__ = 'Zhong Tingting'
__team__ = '5G_PZ_HZ_4_SG'
__email__ = 'tingting.zhong@nokia-sbell.com'

__all__ = ['mappings']

ue_mapping_1 = {
    'ue_index': 0,  # ue index in TL
    'ue_ul_layer': 1,
}

mappings = [
    {
        'scf_name': '*',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1]
    }
]

pa_info = [
    {
        'scf_name': '*',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [17, 50, 83, 116],

        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
        },
    },
    {
        'scf_name': 'SCF_SBTS00_NR_LTE_50_40.xml',  # * means all scf common
        'cells_pa_ports': {
                1: [1, 34, 67, 100],
                2: [9, 42, 75, 108],
                3: [13, 46, 79, 112],
                401: [133, 166, 199, 232],
                402: [133, 166, 199, 232],
                403: [137, 170, 203, 236],
                404: [137, 170, 203, 236],
                405: [141, 174, 207, 240],
                406: [141, 174, 207, 240],
            },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
            401: 0,
            402: 0,
            403: 0,
            404: 0,
            405: 0,
            406: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS00_8392.xml',  # * means all scf common
        'cells_pa_ports': {
            3: [17, 50, 83, 116],
        },
        'cells_pa_values': {
            3: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS25R2_NR_LTE_50_40.xml',  # * means all scf common
        'cells_pa_ports': {
                1: [1, 34, 67, 100],
                2: [9, 42, 75, 108],
                3: [13, 46, 79, 112],
                401: [133, 166, 199, 232],
                402: [133, 166, 199, 232],
                403: [137, 170, 203, 236],
                404: [137, 170, 203, 236],
                405: [141, 174, 207, 240],
                406: [141, 174, 207, 240],
            },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
            401: 0,
            402: 0,
            403: 0,
            404: 0,
            405: 0,
            406: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS25R2_8392.xml',  # * means all scf common
        'cells_pa_ports': {
            3: [17, 50, 83, 116],
        },
        'cells_pa_values': {
            3: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS25R1_NR_LTE_50_40.xml',  # * means all scf common
        'cells_pa_ports': {
                1: [1, 34, 67, 100],
                2: [9, 42, 75, 108],
                3: [13, 46, 79, 112],
                401: [133, 166, 199, 232],
                402: [133, 166, 199, 232],
                403: [137, 170, 203, 236],
                404: [137, 170, 203, 236],
                405: [141, 174, 207, 240],
                406: [141, 174, 207, 240],
            },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
            401: 0,
            402: 0,
            403: 0,
            404: 0,
            405: 0,
            406: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS24R3_NR_LTE_50_40.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [13, 46, 79, 112],
            401: [133, 166, 199, 232],
            402: [133, 166, 199, 232],
            403: [137, 170, 203, 236],
            404: [137, 170, 203, 236],
            405: [141, 174, 207, 240],
            406: [141, 174, 207, 240],
        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
            401: 0,
            402: 0,
            403: 0,
            404: 0,
            405: 0,
            406: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS24R2_NR_LTE_50_40.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [13, 46, 79, 112],
            401: [133, 166, 199, 232],
            403: [137, 170, 203, 236],
            404: [137, 170, 203, 236],
            405: [141, 174, 207, 240],
            406: [141, 174, 207, 240],
        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
            401: 0,
            403: 0,
            404: 0,
            405: 0,
            406: 0,
        }
    },
    {
        'scf_name': 'SCF_SBTS00_PureNR_80_60_30.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [17, 50, 83, 116],

        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
        },
    },
    {
        'scf_name': 'SCF_SBTS25R2_PureNR_80_60_30.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [17, 50, 83, 116],

        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
        },
    },
    {
        'scf_name': 'SCF_SBTS25R1_PureNR_80_60_30.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [17, 50, 83, 116],

        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
        },
    },
    {
        'scf_name': 'SCF_SBTS24R3_PureNR_80_60_30.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [17, 50, 83, 116],

        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
        },
    },
    {
        'scf_name': 'SCF_SBTS24R2_PureNR_80_60_30.xml',  # * means all scf common
        'cells_pa_ports': {
            1: [1, 34, 67, 100],
            2: [9, 42, 75, 108],
            3: [17, 50, 83, 116],

        },
        'cells_pa_values': {
            1: 0,
            2: 0,
            3: 0,
        },
    },
]
