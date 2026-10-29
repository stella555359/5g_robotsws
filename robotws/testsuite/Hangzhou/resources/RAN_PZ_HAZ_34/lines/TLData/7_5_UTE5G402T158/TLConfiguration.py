import os

__team__ = "NSB MN RAN Pz 3 HAZ 2 SG"
__email__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02@internal.nsn.com"

TL_BASE_SCF = "TL_BASE_SCF_NR.xml"

cell_mapping = {53: 'NRCELL-1', 54: 'NRCELL-2', 158: 'LNCEL-0', 159: 'LNCEL-1'}

tput_define = {
    53: {
        'dl_exp': 1200,
        'dl_tp': '1500M',
        'ul_exp': 160,
        'ul_tp': '45M',
        'ue_index': 1,
        'cell_id': 174481
    },
    54: {
        'dl_exp': 1200,
        'dl_tp': '1500M',
        'ul_exp': 160,
        'ul_tp': '45M',
        'ue_index': 1,
        'cell_id': 174482
    },
    158: {
        'dl_exp': 80,
        'dl_tp': '100M',
        'ul_exp': 12,
        'ul_tp': '15M',
        'ue_index': 0,
        'cell_id': 2791680
    },
    159: {
        'dl_exp': 80,
        'dl_tp': '100M',
        'ul_exp': 12,
        'ul_tp': '15M',
        'ue_index': 0,
        'cell_id': 2791681
    },
}

ru_gain = {
    53: {
        'srs': 'NR10905.Rx1_1_17',
        'puxh': 'NR10905.Rx1_1_11',
        'prach': 'NR10905.Rx1_1_10'
    },
    54: {
        'srs': 'NR10905.Rx2_1_17',
        'puxh': 'NR10905.Rx2_1_11',
        'prach': 'NR10905.Rx2_1_10'
    },
    158: {
        'srs': 'L10905.Rx0_1_21',
        'puxh': 'L10905.Rx0_1_1',
        'prach': 'L10905.Rx0_1_17'
    },
    159: {
        'srs': 'L10905.Rx1_1_21',
        'puxh': 'L10905.Rx1_1_1',
        'prach': 'L10905.Rx1_1_17'
    },
}

l1_gain_exp = {
    53: {
        'srs': '12.000000',
        'puxh': '-18.000000',
        'prach': '-18.000000'
    },
    54: {
        'srs': '-18.000000',
        'puxh': '-18.000000',
        'prach': '-18.000000'
    },
    158: {
        'srs': '100',
        'puxh': '100',
        'prach': '1200'
    },
    159: {
        'srs': '100',
        'puxh': '100',
        'prach': '1200'
    },
}

ru_gain_exp = {
    53: {
        'srs': '1.200000',
        'puxh': '-16.851500',
        'prach': '-16.851500'
    },
    54: {
        'srs': '-1.800000',
        'puxh': '-13.841200',
        'prach': '-13.841200'
    },
    158: {
        'srs': '1.000000',
        'puxh': '1.000000',
        'prach': '12.000000'
    },
    159: {
        'srs': '1.000000',
        'puxh': '1.000000',
        'prach': '12.000000'
    },
}

ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 4687},
    {'faultId': 4654},
    {'faultId': 4655},
    {'faultId': 8150},
    {'faultId': 7307},
    {'faultId': 7311},
    {'faultId': 4293},
    {'faultId': 7304},
    {'faultId': 7305},
    {'faultId': 4420},
    {'faultId': 4298},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 7319},
    {'faultId': 7300},
    {'faultId': 8150},
    {'faultId': 6327},
    {'faultId': 10},
    {'faultId': 7313},
]

ALLOWED_HISTORY_FAULT.extend(ALLOWED_FAULT)
