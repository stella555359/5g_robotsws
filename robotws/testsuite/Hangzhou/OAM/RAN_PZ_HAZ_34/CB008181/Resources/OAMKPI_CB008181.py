import os

__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS@internal.nsn.com'

TestLineID = '7_5_UTE5G402T930'
prefix_of_release = 'SBTS_'
KPI = {
    'StreamPrefix': 'SBTS00_ENB_9999',
    'Stream_Version': 'SBTS22R3',
    'CB008181_IA': {
        'OriginalStream': {
              'SBTS00': 'SBTS22R3_ENB_0000',
              'SBTS22R3': 'SBTS22R2_ENB_0000',
              'SBTS22R2': 'SBTS22R1_ENB_0000',
        },
        'OriginalStreamSCF': 'OriginalStreamSCF.xml',
    },
    'CB008181_KPI2a': {
        'CNF_5G_3': {
            'KPI2a_AVG': '750',
            'KPI2a_MAX': '780',
         },
        'CNF_5G_18': {
            'KPI2a_AVG': '630',
            'KPI2a_MAX': '660',
        },
    },
    'CB008181_KPI2b': {
        'CNF_5G_3': {
            'KPI2b_AVG': '1050',
            'KPI2b_MAX': '1080',
        },
        'CNF_5G_18': {
            'KPI2b_AVG': '780',
            'KPI2b_MAX': '810',
        },
    },
    'CB008181_KPI2c': {
        'CNF_5G_3': {
            'KPI2c_AVG': '750',
            'KPI2c_MAX': '780',
        },
        'CNF_5G_18': {
            'KPI2c_AVG': '630',
            'KPI2c_MAX': '660',
        },
    },
    'CB008181_KPI2d': {
        'CNF_5G_3': {
            'KPI2d_AVG': '1050',
            'KPI2d_MAX': '1080',
        },
        'CNF_5G_18': {
            'KPI2d_AVG': '780',
            'KPI2d_MAX': '810',
        },
    },
    'CB008181_KPI54A': {
        'KPI54A_MAX': 240,
        'ru_reset_times': 30,
        'RF_reset_times_CDRT': 30,
        'fail_loop_max': 2,
    },
    'CB008181_KPI1a': {
        'CNF_5G_3': {
            'WebUI_reset_times': 30,
            'WebUI_reset_times_CDRT': 30,
            'KPI1a_AVG': 390,
            'KPI1a_MAX': 468,
        },
        'CNF_5G_18': {
            'WebUI_reset_times': 30,
            'WebUI_reset_times_CDRT': 30,
            'KPI1a_AVG': 390,
            'KPI1a_MAX': 468,
        },
    },
    'CB008181_KPI3': {
        'CNF_5G_3': {
            'Power_reset_times': 30,
            'Power_reset_times_CDRT': 30,
            'KPI3_AVG': '390',
            'KPI3_MAX': '468',
            'fail_loop_max': '3',
        },
        'CNF_5G_18': {
            'Power_reset_times': 30,
            'Power_reset_times_CDRT': 30,
            'KPI3_AVG': '390',
            'KPI3_MAX': '468',
            'fail_loop_max': '3',
        },
    },
    'CB008181_KPI16': {
        'KPI16a_MAX': 40,
        'KPI16b_MAX': 40,
        'lock_cell_times': 30,
        'lock_cell_times_CDRT': 30,
        'fail_times': 2,
    },
    'CB008181_KPI51a': {
        'RF_reset_times': 30,
        'RF_reset_times_CDRT': 30,
        'KPI51a_AVG': 240,
        'KPI51a_MAX': 240,
    },
    'CB008181_KPI17': {
         'cell_block_times': 30,
         'cell_block_times_CDRT': 30,
    },
    'CB008181_KPI5': {
        'BBMOD_reset_times': 30,
        'BBMOD_reset_times_CDRT': 30,
        'KPI5_AVG': 270,
        'KPI5_MAX': 270,
        'fail_loop_max': 2,
    },
}
