__maintainer__ = 'Dandan Fang'
__team__ = 'I_NSB_MN_RAN_RD_VRF_HAZ3_01_S3 '
__email__ = 'dandan.fang@nokia-sbell.com'

__all__ = ['RU_CELLS_INFO', 'INIT_PA']

# Initial PA values for RUs, format should be as bellow:
# { GNB_index1: [PA_RU1, PA_RU2, PA_RU3], GNB_index2: [PA_RU1, PA_RU2] }
# GNB index and RU sequence should align with testline config file
INIT_PA = {0: [0, 0, 0]}

# tdlte
AVQD_Cell = {
    101: {
            'exp_dl_indiv': '1159.58',
            'exp_ul_indiv': '196.67',
            'chBW': '90M',
    },
    102: {
            'exp_dl_indiv': '897.29',
            'exp_ul_indiv': '118.77',
            'chBW': '70M',
    },
    103: {
            'exp_dl_indiv': '240.42',
            'exp_ul_indiv': '35.92',
            'chBW': '20M',
    },
    104: {
            'exp_dl_indiv': '264.18',
            'exp_ul_indiv': '34.32',
            'chBW': '20M',
    }
}

# 13394 100Mhz + 60Mhz + 20Mhz + 20Mhz   Semitic
# 12532 100Mhz + 60Mhz Semitic
AVQA_Cell = {
    201: {
            'exp_dl_indiv': '1085.18',
            'exp_ul_indiv': '216.52',
            'chBW': '100M',
    },
    202: {
            'exp_dl_indiv': '633.41',
            'exp_ul_indiv': '179.40',
            'chBW': '60M',
    },
    203: {
            'exp_dl_indiv': '193.08',
            'exp_ul_indiv': '48.85',
            'chBW': '20M',
    },
    204: {
            'exp_dl_indiv': '192.94',
            'exp_ul_indiv': '58.79',
            'chBW': '20M',
    }
}

#  Max Capacility as 200Mhz, 50+50+50+50
AVQF_Cell = {
    301: {
            'exp_dl_indiv': '695.28',
            'exp_ul_indiv': '84.45',
            'chBW': '50M',
    },
    302: {
            'exp_dl_indiv': '695.28',
            'exp_ul_indiv': '92.24',
            'chBW': '50M',
    },
    303: {
            'exp_dl_indiv': '695.78',
            'exp_ul_indiv': '98.59',
            'chBW': '50M',
    },
    304: {
            'exp_dl_indiv': '698.48',
            'exp_ul_indiv': '91.82',
            'chBW': '50M',
    }
}

RU_CELLS_INFO = {'AVQD': AVQD_Cell, 'AVQA': AVQA_Cell, 'AVQF': AVQF_Cell}
