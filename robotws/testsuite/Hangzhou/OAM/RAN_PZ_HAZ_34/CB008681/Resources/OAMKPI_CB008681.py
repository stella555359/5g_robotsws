import os

__team__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS'
__email__ = 'I_NSB_MN_5GSC_MMW_SC_PZ_HZ_03_GMS@internal.nsn.com'

prefix_of_release = 'SBTS_'
KPI_8681 = {
    'StreamPrefix': 'SBTS00_ENB_9999',
    'Stream_Version': 'SBTS23R1',
    'CB008457_IA': {
        'OriginalStream': {
            'SBTS00': 'SBTS23R1_ENB_9999',
            'SBTS23R1': 'SBTS22R4_ENB_0000',
            'SBTS22R4': 'SBTS23R1_ENB_0000',
        },
        'OriginalStreamSCF': 'OriginalStreamSCF.xml',
    },
    'CB008457_KPI2a': {
        'CNF_5G_3': {
            'KPI2a_AVG': '750',
            'KPI2a_MAX': '780',
        },
        'CNF_5G_18': {
            'KPI2a_AVG': '630',
            'KPI2a_MAX': '660',
        },
    },
    'CB008457_KPI2b': {
        'CNF_5G_3': {
            'KPI2b_AVG': '1050',
            'KPI2b_MAX': '1080',
        },
        'CNF_5G_18': {
            'KPI2b_AVG': '780',
            'KPI2b_MAX': '810',
        },
    },
    'CB008457_KPI2c': {
        'CNF_5G_3': {
            'KPI2c_AVG': '750',
            'KPI2c_MAX': '780',
        },
        'CNF_5G_18': {
            'KPI2c_AVG': '630',
            'KPI2c_MAX': '660',
        },
    },
    'CB008457_KPI2d': {
        'CNF_5G_3': {
            'KPI2d_AVG': '1050',
            'KPI2d_MAX': '1080',
        },
        'CNF_5G_18': {
            'KPI2d_AVG': '780',
            'KPI2d_MAX': '810',
        },
    },
    'CB008457_KPI54A': {
        'KPI54A_MAX': 330,
        'ru_reset_times': 30,
        'RF_reset_times_CDRT': 100,
        'fail_loop_max': 2,
    },
    'CB008457_KPI1a': {
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
    'CB008457_KPI3': {
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
    'CB008457_KPI16': {
        'KPI16a_MAX': 40,
        'KPI16b_MAX': 40,
        'lock_cell_times': 30,
        'lock_cell_times_CDRT': 100,
        'fail_times': 2,
    },
    'CB008457_KPI51a': {
        'RF_reset_times': 30,
        'RF_reset_times_CDRT': 100,
        'KPI51a_AVG': 330,
        'KPI51a_MAX': 330,
    },
    'CB008457_KPI17': {
        'cell_block_times': 30,
        'cell_block_times_CDRT': 100,
    },
    'CB008457_KPI5': {
        'BBMOD_reset_times': 30,
        'BBMOD_reset_times_CDRT': 100,
        'KPI5_AVG': 270,
        'KPI5_MAX': 270,
        'fail_loop_max': 2,
    },
}

OAM_KPI_TARGETS = {
    'kpi1a': 468,
    'kpi3': 468,
    'kpi17a': 50,
    'kpi17b': 50,
    'kpi51a': 330,
}
