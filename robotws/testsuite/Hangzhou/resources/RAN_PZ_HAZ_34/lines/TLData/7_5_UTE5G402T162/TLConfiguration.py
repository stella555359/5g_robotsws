import os

__team__ = "NSB MN RAN Pz 3 HAZ 2 SG"
__email__ = "I_NSB_MN_5GSC_MMW_SC_PZ_HZ_02@internal.nsn.com"

TL_BASE_SCF_NR = "TL_BASE_SCF_NR.xml"
casescf = "TL_BASE_SCF_NR.xml"
casescf_2cc_20m = "TL_BASE_SCF_NR_2cc_20MHz.xml"
casescf_2cc_100m = "TL_BASE_SCF_NR_2cc_100MHz.xml"
Case_SCF_Path = "TL_BASE_SCF_NR.xml"

TL_BASE_SCF_LTE_10M = "SCF_SBTS00_10M_LTE.xml"
TL_BASE_SCF_10M = "SCF_SBTS00_10M_LTE.xml"
TL_BASE_SCF_NR_10M = "SCF_SBTS00_NR_10M.xml"

tput_define = {
    0: {
        'dl_exp': 1415,
        'dl_tp': '1500M',
        'ul_exp': 215,
        'ul_tp': '300M',
        'ue_index': 0
    },
    16: {
        'dl_exp': 99,
        'dl_tp': '120M',
        'ul_exp': 44,
        'ul_tp': '100M',
        'ue_index': 0
    },
    1: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 10,
        'ul_tp': '40000',
        'ue_index': 0
    },
    17: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 10,
        'ul_tp': '40000',
        'ue_index': 0
    },
    2: {
        'dl_exp': 600,
        'dl_tp': '1550M',
        'ul_exp': 100,
        'ul_tp': '230M',
        'ue_index': 0
    },
    18: {
        'dl_exp': 50,
        'dl_tp': '1650M',
        'ul_exp': 44,
        'ul_tp': '100M',
        'ue_index': 0
    },
}

tput_define_HO = {
    0: {
        'dl_exp': 200,
        'dl_tp': '300M',
        'ul_exp': 50,
        'ul_tp': '100M',
        'ue_index': 0
    },
    16: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 20,
        'ul_tp': '100M',
        'ue_index': 0
    },
    1: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 10,
        'ul_tp': '40000',
        'ue_index': 0
    },
    17: {
        'dl_exp': 50,
        'dl_tp': '100M',
        'ul_exp': 10,
        'ul_tp': '40000',
        'ue_index': 0
    },
    2: {
        'dl_exp': 600,
        'dl_tp': '1550M',
        'ul_exp': 100,
        'ul_tp': '230M',
        'ue_index': 0
    },
    18: {
        'dl_exp': 50,
        'dl_tp': '1650M',
        'ul_exp': 20,
        'ul_tp': '100M',
        'ue_index': 0
    },
}
tput_define_Scell = {
    1: {
        'dl_exp': 5,
        'dl_tp': '10M',
        'ul_exp': 0,
        'ul_tp': '10000',
        'ue_index': 0
    },
    2: {
        'dl_exp': 600,
        'dl_tp': '1550M',
        'ul_exp': 0,
        'ul_tp': '230M',
        'ue_index': 0
    },
    3: {
        'dl_exp': 600,
        'dl_tp': '1550M',
        'ul_exp': 0,
        'ul_tp': '230M',
        'ue_index': 0
    },
    17: {
        'dl_exp': 5,
        'dl_tp': '10M',
        'ul_exp': 0,
        'ul_tp': '10000',
        'ue_index': 0
    },
}

# GBR Case
GBRTLCommonConfig = {
        "0": {
            "target_avg_percent_ul": "0.35",
            "target_avg_percent_dl": "0.9",
            "target_min_percent": "0.9",
            "dl": "300",
            "ul": "0",
            "iperf_port": "51126",
        },
        "1": {
            "target_avg_percent_ul": "0.9",
            "target_avg_percent_dl": "1",
            "target_min_percent": "0.9",
            "dl": "15",
            "ul": "0",
            "iperf_port": "51125",
        },
}

# preemption case
preemTLCommonConfig = {
        "0": {
            "dl": "0",
            "ul": "0",
        },
        "1": {
            "dl": "0",
            "ul": "0",
        },
        "ue_index_for_call": ["1", "0"],
}

SCHEDULING_ON = {
        "0": {
            "target_avg_percent_dl": "0.23",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.17",
            "dl": "300",
            "ul": "200",
        },
        "1": {
            "target_avg_percent_dl": "0.72",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.35",
            "dl": "300",
            "ul": "200",
        },
}

NSA_Before = {
        "0": {
            "target_avg_percent_dl": "0.45",
            "target_min_percent": "0.7",
            "target_avg_percent_ul": "0.24",
            "iperf_port": "5412",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
        "1": {
            "target_avg_percent_dl": "0.45",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.24",
            "iperf_port": "5412",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
}

NSA_After = {
        "0": {
            "target_avg_percent_dl": "0.22",
            "target_min_percent": "0.7",
            "target_avg_percent_ul": "0.2",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
        "1": {
            "target_avg_percent_dl": "0.66",
            "target_min_percent": "0.5",
            "target_avg_percent_ul": "0.3",
            "ue_mode": "5G_NSA",
            "apn": "dxmdrb1101",
            "dl": "300",
            "ul": "200",
        },
}

GBR_exceed_GFBR_data = {
    "1": {
        "target_avg_percent_dl": "0.5",
        "dl": "40",
    }
}

GBR_VONR_data = {
    "1": {
        "target_avg_percent_dl": "1",
        "dl": "0.003",
    }
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
