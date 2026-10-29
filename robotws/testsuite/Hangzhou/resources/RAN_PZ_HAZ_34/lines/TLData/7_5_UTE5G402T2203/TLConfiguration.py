import os

__team__ = "MN 5G RAN I&V 4 Pz HZG SG1"
__email__ = "I_MN_5G_RAN_IV4_LINE_HZG_1@internal.nsn.com"


TL_BASE_SCF_NR = "SCF_SBTS00_NR_20MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz = "SCF_SBTS00_NR_2CC_40MHz_100MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz = "SCF_SBTS00_NR_2CC_20MHz_40MHz.xml"
TL_BASE_SCF_NR_2CC_20MHz_40MHz_Cell2 = "SCF_SBTS00_NR_2CC_20MHz_40MHz_Cell2.xml"
TL_BASE_SCF_NR_9218_A2_40MHz = "SCF_SBTS00_NR_1CC_9218_A2_40MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_100MHz_spacing0 = "TL_BASE_SCF_NR_2CC_40MHz_100MHz_spacing0.xml"
TL_BASE_SCF_NR_2CC_20MHz_20MHz = "SCF_SBTS00_NR_2CC_20MHz_20MHz.xml"
TL_BASE_SCF_NR_2CC_40MHz_40MHz = "SCF_SBTS00_NR_2CC_40MHz_40MHz.xml"

TL_BASE_SCF_LTE = "SCF_SBTS00_LTE.xml"

CASE_INPUT_5GC002479 = {
    'TLConfiguration': '1ASIB_3ABIL_TDD',
    '5GC002479_IA_15': {'UpdateByYAFT': 'true', },
    '5GC002479_HA_KPI3': {
                    'KPI3_AVG': '540',
                    'KPI3_MAX': '648',
                    'Power_reset_times': '30',
    },
    '5GC002479_HA_KPI1a': {
                    'KPI1a_AVG': '540',
                    'KPI1a_MAX': '648',
                    'WebUI_reset_times': '3',
    },
    '5GC002479_HA_KPI51': {
                    'KPI51_AVG': '480',
                    'KPI51_MAX': '576',
                    'KPI51_AVG_ADJ': '30',
                    'RF_reset_times': '30',
    },
    '5GC002479_IA_KPI4': {
                    'KPI4_AVG': '1560',
                    'KPI4_MAX': '1854',
    },
    '5GC002479_HA_KPI4': {
                    'SW_update_times': '3',
    },
}

CASE_INPUT_CB012475 = {
    'CB012475_SR_B_19_06': {
        'ru_index': 0,
    },

    'site_reset_times': '3',
    'site_reset_duration': '600',
    'SAS_IP': '10.57.159.64',
    'SAS_UserName': 'ute',
    'SAS_Password': 'iW_K#8.ute%A10h0m0ra',
}

CASE_INPUT_SISO = {
    "SISOCommon": {
        "cell_type": "nr",  # nr or lte
        "release": "SBTS23R2",  # release of software
    },
    # parameter of case "BS-RF__LTE_Transmitted_carrier_power_min_max_allowed_power"
    "Pmax": {"start": "23", "count": 2, "isCBRS": "true"},  # true or false

    # parameter of CBRS
    "CBSD": {
        "TS1": {
            "server": "10.71.218.130:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "TS2": {
            "server": "10.71.218.130:4438",
            "version": "version 1.2",
            "path": "/cygdrive/c/sasserver/",
        },
        "SAS_Sim": {
            "server": "10.101.60.109",
            "username": "ute",
            "password": "iW_K#8.ute%A10h0m0ra",
        },
    },
    # "ru_index": "1",
    # "ru_type": "AWPQZ",
    # "host_addr": "10.68.88.16",
    # "Ping from GNB container to RU_IP": "ping 172.16.73.128 -c 3600 -i 1",
    # "ru_product_code": "476086A.X21",
    # "ru_serial_number": "EB2201R0199",
}

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "ue_mode": "SA",
            "apn": "dxdata1",
            "iperf_port": "default",
            "multidrb_QoS_dest": None,
            "iperf_type": "via_app",
            "target_avg_percent": "0.8",
            "cell_index_list": ["1"],
            "dl": {"target_throughput": "5", "duration": "300"},
            "ul": {"target_throughput": "5", "duration": "300"},
            "detach_request": True,
            "power_reset": "true",
            "target_percent": "0.95",
            "check_tput_on_ue": "true",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            # "dt_name": "DT_1",
            "protocol": "udp",
            "connection_type": "app",
        },
        "ue_index_for_call": ["0"],
    },
}
