import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


CASE_INPUT_5GC002479 = {
    "ID": {
        "REFERENCE_CONFIGURATION_ID": "CNF_5G_T008",
    },
    "5GC002479_IA_15": {
        "UpdateByYAFT": "true",
    },
    "5GC002479_HA_KPI3": {
        "KPI3_AVG": "540",
        "KPI3_MAX": "648",
        "Power_reset_times": "10",
    },
    "5GC002479_HA_KPI1a": {
        "KPI1a_AVG": "540",
        "KPI1a_MAX": "648",
        "WebUI_reset_times": "10",
    },
    "5GC002479_HA_KPI51a": {
        "KPI51a_AVG": "480",
        "KPI51a_MAX": "576",
        "RF_reset_times": "10",
    },
    "5GC002479_HA_KPI4": {
        "KPI4_AVG": "2730",
        "KPI4_MAX": "2760",
        "SW_update_times": "1",
    },
    "5GC002479_HA_KPI17a": {
        "KPI17a_AVG": "5000",
        "KPI17a_MAX": "5000",
        "block_times": "2",
    },
    "5GC002479_HA_KPI17b": {
        "KPI17b_AVG": "5000",
        "KPI17b_MAX": "5000",
        "unblock_times": "2",
    },
    "5GC002479_HA_KPI2b": {
        "KPI2b_AVG": "5000",
        "KPI2b_MAX": "5000",
        "retrytimes": "1",
        "OriginalStream": "SBTS23R1_ENB_0000",
        "OriginalStreamSCF": "oriSCF.xml",
        "TargetStreamSCF": "oldSCF.xml",
    },
    "5GC002479_HA_KPI2c": {
        "KPI2c_AVG": "5000",
        "KPI2c_MAX": "5000",
        "retrytimes": "1",
        "TargetStreamSCF": "oldSCF.xml",
    },
    "5GC002479_HA_KPI2d": {
        "KPI2d_AVG": "5000",
        "KPI2d_MAX": "5000",
        "retrytimes": "1",
        "TargetStreamSCF": "oldSCF.xml",
    },
    "5GC002479_HA_KPI51a": {
        "KPI51a_AVG": "5000",
        "KPI51a_MAX": "5000",
        "reset_times": "2",
    },
    "5GC002479_HA_KPI1a": {
        "KPI1a_AVG": "5000",
        "KPI1a_MAX": "5000",
        "reset_times": "2",
    },
    "5GC002479_HA_KPI5": {
        "KPI5_AVG": "5000",
        "KPI5_MAX": "5000",
        "reset_times": "2",
    },
    "5GC002479_HA_KPI16a": {
        "KPI16a_AVG": "5000",
        "KPI16a_MAX": "5000",
        "lock_times": "1",
    },
    "5GC002479_HA_KPI10": {
        "KPI10_AVG": "5000",
        "KPI10_MAX": "5000",
        "retrytimes": "1",
    },
    "5GC002479_HA_KPI12": {
        "KPI12_AVG": "5000",
        "KPI12_MAX": "5000",
        "retrytimes": "1",
    },
}
OAM_KPI_TARGETS = {
    "kpi1a": 648,
    "kpi3": 648,
    # 'kpi51a': 576,
    "kpi4": 2760,
    "kpi17a": 5000,
    "kpi17b": 5000,
    "kpi2b": 5000,
    "kpi2c": 5000,
    "kpi2d": 5000,
    "kpi51a": 5000,
    "kpi1a": 5000,
    "kpi5": 5000,
    "kpi16a": 5000,
    "kpi10": 5000,
    "kpi12": 5000,
}
