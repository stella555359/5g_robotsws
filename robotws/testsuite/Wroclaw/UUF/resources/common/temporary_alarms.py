from taf.ul.alarms_watchdog import Alarm

BRANCH_RELEASE = "SBTS25R1"

cablink = Alarm(fault_id="1815")
LTE_radio_disabled = Alarm(fault_id="4530")
otdoa_prs_transmission_disabled = Alarm(fault_id="4389")
tr_layer_conn_lost = Alarm(fault_id="62003")
cell_problem_due_to_associated_X2 = Alarm(fault_id="7107")
radio_unit_reset_triggered_by_peer_BTS = Alarm(fault_id="4773")
tx_power = Alarm(fault_id="4700")
fid_4078 = Alarm(fault_id="4078")
RF_Module_unstable_link_synchronization = Alarm(fault_id="4764")

# DSS related
EN_DSS_De_activated_on_partner_side_4g = Alarm(fault_id="6134")
EN_DSS_De_activated_on_partner_side_5g = Alarm(fault_id="7513")
Max_EN_DSS_Counter_Value_reached = Alarm(fault_id="7509")

# 4+3 related
sm_connection_lost = Alarm(fault_id="4110")

# 4G/5G related
pps_reference_missing = Alarm(fault_id="1898")
no_usable_time_reference = Alarm(fault_id="4405")
pps_from_backplane = Alarm(fault_id="4385")

# FHS related
fhs_fid10_tl3881 = Alarm(fault_id="10", unit_path="[OBSAI_Croissant_NSA_SA] MRBTS-6034/EQM-1/APEQM-1/FHS-1")
fhs_fid10_tl3833 = Alarm(fault_id="10", unit_path="[OBSAI_Baguette] MRBTS-6034/EQM-1/APEQM-1/FHS-1")
fhs_fid10_tl2029 = Alarm(fault_id="10", unit_path="[gNB_6036] MRBTS-6034/EQM-1/APEQM-1/FHS-1")

# Expected alarm (Synchronization realignment in progress) when actSoftSyncErrorRecovery=True
fhs_obsai_fid4733 = Alarm(fault_id="4733")

tl_specific_variables = {
    "1_16_UTESRAN2073": {
        "HW_TO_ONAIR_TIME": 1200,
    },
    "1_16_UTESRAN2104": {
        "HW_TO_ONAIR_TIME": 1200,
    },
    "1_16_UTESRAN2119": {
        "HW_TO_ONAIR_TIME": 1200,
    },
    "1_16_UTESRAN3881": {
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            fhs_fid10_tl3881,  # wynika to z PR788918
            fhs_obsai_fid4733,  # NIDD
        ]
    },
    "1_16_UTESRAN3833": {
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            fhs_fid10_tl3833,  # wynika to z PR788918
            fhs_obsai_fid4733,  # NIDD
        ]
    },
    "1_16_UTESRAN2029": {
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            fhs_fid10_tl2029,  # wynika to z PR788918
            fhs_obsai_fid4733,  # NIDD
        ]
    },
    "1_16_UTESRAN3801": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            cablink,  # spodziewany ale nie wiem dlaczego, dodawane od dawien dawna
            pps_from_backplane,  # spodziewany ale nie wiem dlaczego, dodawane od dawien dawna
            LTE_radio_disabled,  # spodziewany ale nie wiem dlaczego, dodawane od dawien dawna
            no_usable_time_reference,  # spodziewany ale nie wiem dlaczego, dodawane od dawien dawna
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            cablink,  # spodziewany ale nie wiem dlaczego, dodawane od dawien dawna
            pps_from_backplane,  # alarm pojawia sie przy upgrejdach strony LTE ktora jest masterem synchronizacji
            LTE_radio_disabled,  # spodziewany ale nie wiem dlaczego, dodawane od dawien dawna
        ]
    },
    "1_16_UTESRAN3735": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            sm_connection_lost  # spodziewany, powstaje w wyniku potrzeby rekonfiguracji portu, czego konsekwecja jest
                                # tymczasowe rozlaczenie lacza
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_reference_missing,    # alarm pojawia sie przy upgrejdach strony LTE ktora jest masterem synchronizacji
            no_usable_time_reference  # alarm pojawia sie przy upgrejdach strony LTE ktora jest masterem synchronizacji
        ]
    },
    "1_16_UTESRAN2172": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            sm_connection_lost  # spodziewany, powstaje w wyniku potrzeby rekonfiguracji portu, czego konsekwecja jest
                                # tymczasowe rozlaczenie lacza
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_reference_missing,    # alarm pojawia sie przy upgrejdach strony LTE ktora jest masterem synchronizacji
            no_usable_time_reference  # alarm pojawia sie przy upgrejdach strony LTE ktora jest masterem synchronizacji
        ]
    },
    "1_16_UTESRAN3760": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            tr_layer_conn_lost,  # tl z DSS, spodziewane przy resecie drugiego noda
            EN_DSS_De_activated_on_partner_side_4g,  # tl z DSS
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
            pps_from_backplane,  # spodziewane, node5G jest masterem synchronizacji
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            tr_layer_conn_lost,    # tl z DSS, spodziewane przy resecie drugiego noda
            EN_DSS_De_activated_on_partner_side_5g,  # DSS related
            Max_EN_DSS_Counter_Value_reached  # DSS related
        ]
    },
    "1_16_UTESRAN3763": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            tr_layer_conn_lost,  # tl z DSS, spodziewane przy resecie drugiego noda
            EN_DSS_De_activated_on_partner_side_4g,  # tl z DSS
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            tr_layer_conn_lost,    # tl z DSS, spodziewane przy resecie drugiego noda
            EN_DSS_De_activated_on_partner_side_5g,  # DSS related
            Max_EN_DSS_Counter_Value_reached  # DSS related
        ]
    },
    "1_16_UTESRAN3765": {  # dodane na szybko dla Seby na sobotnie stabi, do weryfikacji co sie pojawia na tej tl
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            tr_layer_conn_lost,
            EN_DSS_De_activated_on_partner_side_4g,
            radio_unit_reset_triggered_by_peer_BTS,
            otdoa_prs_transmission_disabled,           # chwilowo dodane, poprawic scf
            pps_from_backplane,
            no_usable_time_reference,
            pps_reference_missing
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            tr_layer_conn_lost,
            EN_DSS_De_activated_on_partner_side_5g,
            Max_EN_DSS_Counter_Value_reached,
            pps_reference_missing,
            no_usable_time_reference,
            pps_from_backplane,
        ]
    },
    "1_16_UTESRAN3000": {  # dodane na szybko dla Seby na sobotnie stabi, do weryfikacji co sie pojawia na tej tl
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            otdoa_prs_transmission_disabled,  # chwilowo dodane, poprawic scf
        ],
    },
    "1_16_UTESRAN2034": {  # dodane na szybko dla Seby na sobotnie stabi, do weryfikacji co sie pojawia na tej tl
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            tr_layer_conn_lost,
            EN_DSS_De_activated_on_partner_side_4g,
            radio_unit_reset_triggered_by_peer_BTS,
            pps_from_backplane,
            no_usable_time_reference,
            pps_reference_missing
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            tr_layer_conn_lost,
            EN_DSS_De_activated_on_partner_side_5g,
            Max_EN_DSS_Counter_Value_reached,
            pps_reference_missing,
            no_usable_time_reference,
            pps_from_backplane,
            RF_Module_unstable_link_synchronization,
        ]
    },
    "1_16_UTESRAN2045": {  # dodane na szybko dla Seby na sobotnie stabi, do weryfikacji co sie pojawia na tej tl
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            pps_from_backplane,
            pps_reference_missing
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_reference_missing,
            pps_from_backplane,
        ]
    },
    "1_16_UTESRAN2041": {
        "HW_TO_ONAIR_TIME": 900,
    },
    "1_16_UTESRAN2095": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            tr_layer_conn_lost,  # tl z DSS, spodziewane przy resecie drugiego noda
            EN_DSS_De_activated_on_partner_side_4g,  # tl z DSS
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
            pps_from_backplane,  # spodziewane, node5G jest masterem synchronizacji
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            tr_layer_conn_lost,    # tl z DSS, spodziewane przy resecie drugiego noda
            EN_DSS_De_activated_on_partner_side_5g,  # DSS related
            Max_EN_DSS_Counter_Value_reached  # DSS related
        ],
    },
    "1_16_UTESRAN2039": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ]
    },
    "1_16_UTESRAN3600": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
    },
    "1_16_UTESRAN3606": {
        "HW_TO_ONAIR_TIME": 1200,  # skopiowane z suity CRT dla bucket 2_5
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
    },
    "1_16_UTESRAN2038": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            LTE_radio_disabled,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
        ],
    },
    "1_16_UTESRAN3215": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            LTE_radio_disabled,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
        ],
    },
    "1_16_UTESRAN3216": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            LTE_radio_disabled,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
        ],
    },
    "1_16_UTESRAN2051": {
        "HW_TO_ONAIR_TIME": 1000,  # skopiowane z suity CRT dla bucket 2_5
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            no_usable_time_reference,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
            pps_from_backplane,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
    },
    "1_16_UTESRAN2147": {
        "HW_TO_ONAIR_TIME": 1000,  # skopiowane z suity CRT dla bucket 2_5
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            no_usable_time_reference,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
            pps_from_backplane,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
    },
    "1_16_UTESRAN3617": {
        "HW_TO_ONAIR_TIME": 1000,  # skopiowane z suity CRT dla bucket 2_5
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            no_usable_time_reference,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
            pps_from_backplane,  # alarm pojawia sie przy upgrejdach strony 5G ktora jest masterem synchronizacji
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
    },
    "1_16_UTESRAN3230": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            cablink,  # skopiowane z suity CRT dla bucket 3_1
        ],
    },
    "1_16_UTESRAN3234": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            cablink,  # skopiowane z suity CRT dla bucket 3_1
        ],
    },
    "1_16_UTESRAN3236": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            cablink,  # skopiowane z suity CRT dla bucket 3_1
        ],
    },
    "1_16_UTESRAN3238": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            cablink,  # skopiowane z suity CRT dla bucket 3_1
        ],
    },
    "1_16_UTESRAN2089": {
        "HW_TO_ONAIR_TIME": 1020,  # skopiowane z suity CRT dla bucket 8_1
    },
    "1_16_UTESRAN2113": {
        "HW_TO_ONAIR_TIME": 1020,  # skopiowane z suity CRT dla bucket 8_1
    },
    "1_16_UTESRAN2018": {
        "HW_TO_ONAIR_TIME": 1020,  # skopiowane z suity CRT dla bucket 8_2
    },
    "1_16_UTESRAN2198": {
        "HW_TO_ONAIR_TIME": 1020,  # skopiowane z suity CRT dla bucket 8_3
    },
    "1_16_UTESRAN2046": {
        "HW_TO_ONAIR_TIME": 1020,  # skopiowane z suity CRT dla bucket 8_5
    },
    "1_16_UTESRAN2201": {
        "HW_TO_ONAIR_TIME": 960,  # temporary
    },
    "1_16_UTESRAN2203": {
        "HW_TO_ONAIR_TIME": 960,
    },
    "1_16_UTESRAN2205": {
        "HW_TO_ONAIR_TIME": 960,
    },
    "1_16_UTESRAN2091": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_from_backplane,  # LTE jest masterem synchronizacji
        ],
    },
    "1_16_UTESRAN2092": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_from_backplane,  # LTE jest masterem synchronizacji
        ],
    },
    "1_16_UTESRAN2093": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
            cell_problem_due_to_associated_X2,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_from_backplane,  # LTE jest masterem synchronizacji
        ],
    },
    "1_16_UTESRAN2096": {
        "TEMPORARY_ALLOWED_FAULTS_4G": [
            radio_unit_reset_triggered_by_peer_BTS,  # node 5G jest masterem i resetuje radia po upgrejdach/resetach
            cablink,  # synchro po stronie 5G
        ],
        "TEMPORARY_ALLOWED_FAULTS_5G": [
            pps_from_backplane,  # LTE jest masterem synchronizacji
        ],
    },
}
# UPGRADE_BRANCH
# RESET_BRANCH
# NETACT_BRANCH
tl_qc_id = {
    "bucket_1_1": {
        "hosts": ["1_16_UTESRAN3845", "1_16_UTESRAN3885", "1_16_UTESRAN3850"],
        "UPGRADE_SBTS00": "43303",
        "RESET_SBTS00": "43304",
        "UPGRADE_SBTS24R3": "843389",
        "RESET_SBTS24R3": "843390",
        "UPGRADE_BRANCH": "96367",
        "RESET_BRANCH": "96366",
    },
    "bucket_1_2": {
        "hosts": ["1_16_UTESRAN3222", "1_16_UTESRAN3208", "1_16_UTESRAN3209"],
        "UPGRADE_SBTS00": "43305",
        "RESET_SBTS00": "43306",
        "UPGRADE_SBTS24R3": "843391",
        "RESET_SBTS24R3": "843392",
        "UPGRADE_BRANCH": "96369",
        "RESET_BRANCH": "96368",
    },
    "bucket_1_3": {
        "hosts": ["1_16_UTESRAN2201", "1_16_UTESRAN2203", "1_16_UTESRAN2205"],
        "UPGRADE_SBTS00": "43308",
        "RESET_SBTS00": "43307",
        "UPGRADE_SBTS24R3": "843394",
        "RESET_SBTS24R3": "843393",
        "UPGRADE_BRANCH": "96371",
        "RESET_BRANCH": "96370",
    },
    "bucket_2_1": {
        "hosts": ["1_16_UTESRAN2039", "1_16_UTESRAN3600", "1_16_UTESRAN3606"],
        "UPGRADE_SBTS00": "43319",
        "RESET_SBTS00": "43320",
        "UPGRADE_SBTS24R3": "843405",
        "RESET_SBTS24R3": "843406",
        "UPGRADE_BRANCH": "96383",
        "RESET_BRANCH": "96382",
    },
    "bucket_2_2": {
        "hosts": ["1_16_UTESRAN3881", "1_16_UTESRAN3833", "1_16_UTESRAN2029"],
        "UPGRADE_SBTS00": "43321",
        "RESET_SBTS00": "43322",
        "UPGRADE_SBTS24R3": "843407",
        "RESET_SBTS24R3": "843408",
        "UPGRADE_BRANCH": "96385",
        "RESET_BRANCH": "96384",
    },
    "bucket_2_3": {
        "hosts": ["1_16_UTESRAN2038", "1_16_UTESRAN3215", "1_16_UTESRAN3216"],
        "UPGRADE_SBTS00": "43324",
        "RESET_SBTS00": "43323",
        "UPGRADE_SBTS24R3": "843410",
        "RESET_SBTS24R3": "843409",
        "UPGRADE_BRANCH": "96387",
        "RESET_BRANCH": "96386",
    },
    "bucket_2_4": {
        "hosts": ["1_16_UTESRAN3223", "1_16_UTESRAN3225", "1_16_UTESRAN3227"],
        "UPGRADE_SBTS00": "43318",
        "RESET_SBTS00": "43317",
        "UPGRADE_SBTS24R3": "843404",
        "RESET_SBTS24R3": "843403",
        "UPGRADE_BRANCH": "96381",
        "RESET_BRANCH": "96380",
    },
    "bucket_2_5": {
        "hosts": ["1_16_UTESRAN2051", "1_16_UTESRAN2147", "1_16_UTESRAN3617"],
        "UPGRADE_SBTS00": "43333",
        "RESET_SBTS00": "43334",
        "UPGRADE_SBTS24R3": "843419",
        "RESET_SBTS24R3": "843420",
        "UPGRADE_BRANCH": "96397",
        "RESET_BRANCH": "96396",
    },
    "bucket_3_1": {
        "hosts": ["1_16_UTESRAN3230", "1_16_UTESRAN3234", "1_16_UTESRAN3236", "1_16_UTESRAN3238"],
        "UPGRADE_SBTS00": "43325",
        "RESET_SBTS00": "43326",
        "UPGRADE_SBTS24R3": "843411",
        "RESET_SBTS24R3": "843412",
        "UPGRADE_BRANCH": "96389",
        "RESET_BRANCH": "96388",
    },
    "bucket_3_2": {
        "hosts": ["1_16_UTESRAN3787", "1_16_UTESRAN3789", "1_16_UTESRAN3791"],
        "UPGRADE_SBTS00": "43330",
        "RESET_SBTS00": "43329",
        "UPGRADE_SBTS24R3": "843416",
        "RESET_SBTS24R3": "843415",
        "UPGRADE_BRANCH": "96393",
        "RESET_BRANCH": "96392",
    },
    "bucket_3_3": {
        "hosts": ["1_16_UTESRAN2065", "1_16_UTESRAN2066", "1_16_UTESRAN2067"],
        "UPGRADE_SBTS00": "43328",
        "RESET_SBTS00": "43327",
        "UPGRADE_SBTS24R3": "843414",
        "RESET_SBTS24R3": "843413",
        "UPGRADE_BRANCH": "96390",
        "RESET_BRANCH": "96391",
    },
    "bucket_3_4": {
        "hosts": ["1_16_UTESRAN2194", "1_16_UTESRAN2196", "1_16_UTESRAN3641"],
        "UPGRADE_SBTS00": "43331",
        "RESET_SBTS00": "43332",
        "UPGRADE_SBTS24R3": "843417",
        "RESET_SBTS24R3": "843418",
        "UPGRADE_BRANCH": "96395",
        "RESET_BRANCH": "96394",
    },
    "bucket_4_1": {
        "hosts": ["1_16_UTESRAN3212", "1_16_UTESRAN3213", "1_16_UTESRAN3214"],
        "UPGRADE_SBTS00": "42610",
        "RESET_SBTS00": "42611",
        "UPGRADE_SBTS24R3": "855768",
        "RESET_SBTS24R3": "855769",
        "UPGRADE_BRANCH": "95707",
        "RESET_BRANCH": "95706",
    },
    "bucket_4_2": {
        "hosts": ["1_16_UTESRAN2057", "1_16_UTESRAN2097", "1_16_UTESRAN2107"],
        "UPGRADE_SBTS00": "42613",
        "RESET_SBTS00": "42612",
        "UPGRADE_SBTS24R3": "855771",
        "RESET_SBTS24R3": "855770",
        "UPGRADE_BRANCH": "95708",
        "RESET_BRANCH": "95709",
    },
    "bucket_5_1": {
        "hosts": ["1_16_UTESRAN3754", "1_16_UTESRAN3742", "1_16_UTESRAN3689"],
        "UPGRADE_SBTS00": "42608",
        "RESET_SBTS00": "42609",
        "UPGRADE_SBTS24R3": "855766",
        "RESET_SBTS24R3": "855767",
        "UPGRADE_BRANCH": "95704",
        "RESET_BRANCH": "95705",
    },
    "bucket_6_1": {
        "hosts": ["1_16_UTESRAN3202"],
        "UPGRADE_SBTS00": "43309",
        "RESET_SBTS00": "43310",
        "UPGRADE_SBTS24R3": "843395",
        "RESET_SBTS24R3": "843396",
        "UPGRADE_BRANCH": "96373",
        "RESET_BRANCH": "96372",
    },
    "bucket_6_2": {
        "hosts": ["1_16_UTESRAN3607"],
        "UPGRADE_SBTS00": "43311",
        "RESET_SBTS00": "43312",
        "UPGRADE_SBTS24R3": "843397",
        "RESET_SBTS24R3": "843398",
        "UPGRADE_BRANCH": "96375",
        "RESET_BRANCH": "96374",
    },
    "bucket_6_3": {
        "hosts": ["1_16_UTESRAN3206"],
        "UPGRADE_SBTS00": "43313",
        "RESET_SBTS00": "43314",
        "UPGRADE_SBTS24R3": "843399",
        "RESET_SBTS24R3": "843400",
        "UPGRADE_BRANCH": "96377",
        "RESET_BRANCH": "96376",
    },
    "bucket_6_4": {
        "hosts": ["1_16_UTESRAN2016", "1_16_UTESRAN2094"],
        "UPGRADE_SBTS00": "43315",
        "RESET_SBTS00": "43316",
        "UPGRADE_SBTS24R3": "843401",
        "RESET_SBTS24R3": "843402",
        "UPGRADE_BRANCH": "96379",
        "RESET_BRANCH": "96378",
    },
    "bucket_7_1": {
        "hosts": ["1_16_UTESRAN2073", "1_16_UTESRAN2104", "1_16_UTESRAN2119"],
        "UPGRADE_SBTS00": "43349",
        "RESET_SBTS00": "43348",
        "UPGRADE_SBTS24R3": "843435",
        "RESET_SBTS24R3": "843434",
        "UPGRADE_BRANCH": "96412",
        "RESET_BRANCH": "96411",
    },
    "bucket_7_2": {
        "hosts": ["1_16_UTESRAN2050", "1_16_UTESRAN2081", "1_16_UTESRAN2100"],
        "UPGRADE_SBTS00": "43351",
        "RESET_SBTS00": "43350",
        "UPGRADE_SBTS24R3": "843437",
        "RESET_SBTS24R3": "843436",
        "UPGRADE_BRANCH": "96414",
        "RESET_BRANCH": "96413",
    },
    "bucket_8_1": {
        "hosts": ["1_16_UTESRAN2089", "1_16_UTESRAN2113"],
        "UPGRADE_SBTS00": "43337",
        "RESET_SBTS00": "43338",
        "NETACT_SBTS00": "43339",
        "UPGRADE_SBTS24R3": "843423",
        "RESET_SBTS24R3": "843424",
        "NETACT_SBTS24R3": "843425",
        "UPGRADE_BRANCH": "96401",
        "RESET_BRANCH": "96400",
        "NETACT_BRANCH": "96401",
    },
    "bucket_8_2": {
        "hosts": ["1_16_UTESRAN2018"],
        "UPGRADE_SBTS00": "43341",
        "RESET_SBTS00": "43340",
        "UPGRADE_SBTS24R3": "843427",
        "RESET_SBTS24R3": "843426",
        "UPGRADE_BRANCH": "96404",
        "RESET_BRANCH": "96403",
    },
    "bucket_8_3": {
        "hosts": ["1_16_UTESRAN2198"],
        "UPGRADE_SBTS00": "43343",
        "RESET_SBTS00": "43342",
        "UPGRADE_SBTS24R3": "843429",
        "RESET_SBTS24R3": "843428",
        "UPGRADE_BRANCH": "96406",
        "RESET_BRANCH": "96405",
    },
    "bucket_8_4": {
        "hosts": ["1_16_UTESRAN2083"],
        "UPGRADE_SBTS00": "43345",
        "RESET_SBTS00": "43344",
        "UPGRADE_SBTS24R3": "843431",
        "RESET_SBTS24R3": "843430",
        "UPGRADE_BRANCH": "96408",
        "RESET_BRANCH": "96407",
    },
    "bucket_8_5": {
        "hosts": ["1_16_UTESRAN2046"],
        "UPGRADE_SBTS00": "43347",
        "RESET_SBTS00": "43346",
        "UPGRADE_SBTS24R3": "843433",
        "RESET_SBTS24R3": "843432",
        "UPGRADE_BRANCH": "96410",
        "RESET_BRANCH": "96409",
    },
    "bucket_8_6": {
        "hosts": ["1_16_UTESRAN2091", "1_16_UTESRAN2092", "1_16_UTESRAN2093", "1_16_UTESRAN2096"],
        "UPGRADE_SBTS00": "43335",
        "RESET_SBTS00": "43336",
        "UPGRADE_SBTS24R3": "843421",
        "RESET_SBTS24R3": "843422",
        "UPGRADE_BRANCH": "96399",
        "RESET_BRANCH": "96398",
    },
    "bucket_8_7": {
        "hosts": ["1_16_UTESRAN2069"],
        "UPGRADE_SBTS00": "98888",
        "RESET_SBTS00": "98889",
        "UPGRADE_SBTS24R3": "861970",
        "RESET_SBTS24R3": "861971",
        "UPGRADE_BRANCH": "98886",
        "RESET_BRANCH": "98887",
    },
    "bucket_9_1": {
        "hosts": ["1_16_UTESRAN2040", "1_16_UTESRAN2117"],
        "UPGRADE_SBTS00": "43352",
        "RESET_SBTS00": "43353",
        "UPGRADE_SBTS24R3": "843438",
        "RESET_SBTS24R3": "843439",
        "UPGRADE_BRANCH": "96416",
        "RESET_BRANCH": "96415",
    },
}
