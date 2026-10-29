import os

__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS@internal.nsn.com'

prefix_of_release = 'SBTS_'
KPI_8962 = {
    'StreamPrefix': 'SBTS00_ENB_9999',
    'Stream_Version': 'SBTS23R2',
    'CB008962_IA': {
        'OriginalStream': {
              'SBTS00': 'SBTS25R3_ENB_9999',
              'SBTS25R2': 'SBTS25R2_ENB_0000',
              'SBTS25R1': 'SBTS25R1_ENB_0000',
              'SBTS24R3': 'SBTS24R3_ENB_0000',
              'SBTS24R2': 'SBTS24R2_ENB_0000',
              'SBTS24R1': 'SBTS24R1_ENB_0000',
              'SBTS23R4': 'SBTS23R4_ENB_0000',
              'SBTS23R3': 'SBTS23R3_ENB_0000',
              'SBTS23R2': 'SBTS23R2_ENB_0000',
              'SBTS23R1': 'SBTS23R1_ENB_0000',
        },
        'OriginalStreamSCF': 'OriginalStreamSCF.xml',
    },
    'CB008962_KPI2a': {
        'CNF_5G_3': {
            'KPI2a_AVG': '750',
            'KPI2a_MAX': '780',
         },
        'CNF_5G_18': {
            'KPI2a_AVG': '630',
            'KPI2a_MAX': '660',
        },
    },
    'CB008962_KPI2b': {
        'CNF_5G_3': {
            'KPI2b_AVG': '1050',
            'KPI2b_MAX': '1080',
        },
        'CNF_5G_18': {
            'KPI2b_AVG': '780',
            'KPI2b_MAX': '810',
        },
    },
    'CB008962_KPI2c': {
        'CNF_5G_3': {
            'KPI2c_AVG': '750',
            'KPI2c_MAX': '780',
        },
        'CNF_5G_18': {
            'KPI2c_AVG': '630',
            'KPI2c_MAX': '660',
        },
    },
    'CB008962_KPI2d': {
        'CNF_5G_3': {
            'KPI2d_AVG': '1050',
            'KPI2d_MAX': '1080',
        },
        'CNF_5G_18': {
            'KPI2d_AVG': '780',
            'KPI2d_MAX': '810',
        },
    },
    'CB008962_KPI54A': {
        'KPI54A_MAX': 330,
        'ru_reset_times': 30,
        'RF_reset_times_CDRT': 100,
        'fail_loop_max': 2,
    },
    'CB008962_KPI1a': {
        'CNF_5G_3': {
            'WebUI_reset_times': 30,
            'WebUI_reset_times_CDRT': 100,
            'KPI1a_AVG': 390,
            'KPI1a_MAX': 468,
        },
        'CNF_5G_18': {
            'WebUI_reset_times': 30,
            'WebUI_reset_times_CDRT': 100,
            'KPI1a_AVG': 390,
            'KPI1a_MAX': 468,
        },
    },
    'CB008962_KPI3': {
        'CNF_5G_3': {
            'Power_reset_times': 30,
            'Power_reset_times_CDRT': 100,
            'KPI3_AVG': '390',
            'KPI3_MAX': '468',
            'fail_loop_max': '3',
        },
        'CNF_5G_18': {
            'Power_reset_times': 30,
            'Power_reset_times_CDRT': 100,
            'KPI3_AVG': '390',
            'KPI3_MAX': '468',
            'fail_loop_max': '3',
        },
    },
    'CB008962_KPI51a': {
        'RF_reset_times': 30,
        'RF_reset_times_CDRT': 100,
        'KPI51a_AVG': 240,
        'KPI51a_MAX': 240,
    },
    'CB008962_KPI17': {
         'cell_block_times': 30,
         'cell_block_times_CDRT': 100,
    },
    'CB008962_KPI5': {
        'BBMOD_reset_times': 30,
        'BBMOD_reset_times_CDRT': 100,
        'KPI5_MAX': 270,
        'fail_loop_max': 2,
    },
    'KPI16': {
        'KPI16a': 40,
        'KPI16b': 40,
        'test_loops': 30,
        'test_loops_CDRT': 100,
        'fail_loops': 5,
    },
    'KPI12': {
        'CNF_5G_3': {
            'KPI12_AVG': 605,
            'KPI12_MAX': 635,
            'test_loops': 30,
            'test_loops_CDRT': 100,
            'fail_loops': 5,
        },
        'CNF_5G_18': {
            'KPI12_AVG': 665,
            'KPI12_MAX': 695,
            'test_loops': 30,
            'test_loops_CDRT': 100,
            'fail_loops': 5,
        },
    },
    'KPI11': {
        'CNF_5G_3': {
            'KPI11_AVG': 605,
            'KPI11_MAX': 635,
            'test_loops': 30,
            'test_loops_CDRT': 100,
            'fail_loops': 5,
        },
        'CNF_5G_18': {
            'KPI11_AVG': 665,
            'KPI11_MAX': 695,
            'test_loops': 30,
            'test_loops_CDRT': 100,
            'fail_loops': 5,
        },
    },
}
