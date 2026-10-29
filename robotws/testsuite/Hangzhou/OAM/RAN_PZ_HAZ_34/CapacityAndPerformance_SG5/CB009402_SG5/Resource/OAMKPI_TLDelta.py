#!/usr/bin/env python3
# /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/7_5_UTE5G402T683/
__team__ = "I_NSB_MN_5GSC_5G_PZ_HZ_05_GMS"
__email__ = "I_NSB_MN_5GSC_5G_PZ_HZ_05@internal.nsn.com"

prefix_of_release = "SBTS_"
KPI = {
    "KPI14": {  # KPI#14-capacity_module_power_reset
        # KPI#11 Target = KPI#1a + Additional Gap 200s
        "KPI_MAX": 240 + 240,
        "KPI_AVG": 240,
        "reset_times": 2,
        "fail_loop_max": 2,
        'BBMOD_list': ['BBMOD-1 / BBMOD_R-4 (ABIO)', 'BBMOD-2 / BBMOD_R-5 (ABIQ)']
    },
    "KPI11": {  # KPI#11-remote_power_reset_downtime
        # KPI#11 Target = KPI#1a + Additional Gap 200s
        "KPI11_MAX": 240 + 240,
        "KPI11_AVG": 240,
        "reset_times": 2,
        "fail_loop_max": 2,
    },
    "RF_Scan": {
        "Composite_Rx_elapsed_time": 90,
        "Carrier_Rx_elapsed_time": 90,
        "retry_times": 2,
        "fail_loop_max": 1,
        "radio_loops": ['AEQE', 'AEQP1', 'AEQP2', 'AEQK'],
        "AEQE": {
            "CompositeRx": {
                'capture_type': 'Composite Rx(HBF0)',
                'radio': 'RMOD-1 (AEQE)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': 'NRCELL-1',
            },
            "CarrierRx": {
                'capture_type': 'Carrier Rx (FIR9)',
                'radio': 'RMOD-1 (AEQE)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': 'NRCELL-1',
            },
        },
        "AEQP1": {
            "CompositeRx": {
                'capture_type': 'Composite Rx(HBF0)',
                'radio': 'RMOD-2 (AEQP)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': None,
            },
            "CarrierRx": {
                'capture_type': 'Carrier Rx (FIR9)',
                'radio': 'RMOD-2 (AEQP)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': 'NRCELL-2',
            },
        },
        "AEQP2": {
            "CompositeRx": {
                'capture_type': 'Composite Rx(HBF0)',
                'radio': 'RMOD-3 (AEQP)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': None,
            },
            "CarrierRx": {
                'capture_type': 'Carrier Rx (FIR9)',
                'radio': 'RMOD-3 (AEQP)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': 'NRCELL-3',
            },
        },
        "AEQK": {
            "CompositeRx": {
                'capture_type': 'Composite Rx(HBF0)',
                'radio': 'RMOD-4 (AEQK)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': None,
            },
            "CarrierRx": {
                'capture_type': 'Carrier Rx (FIR9)',
                'radio': 'RMOD-4 (AEQK)',
                'antenna': 'PHYANT 1',
                'antenna_panel': 'PHYANT-1 Full Array',
                'local_cell': 'NRCELL-4',
            },
        },

    },
    'CELL_Switch_Duration': {'off': 90, 'on': 30,
                             "retry_times": 2,
                             "fail_loop_max": 1},
    'TRX_Switch_Duration': {'off': 90, 'on': 30,
                            "retry_times": 2,
                            "fail_loop_max": 1},
    'DeepSleep_Wakeup_Duration': {'KPI_MAX': 570, 'KPI_AVG': 570,
                                  "retry_times": 2,
                                  "fail_loop_max": 1}
}
# #################define search keyword for start time or end time in syslog############################
KEY_TIMESTART_KPI1a = "SiteResetPrepare::PerformReset"
kEY_TIMEEND_KPI1a = "All cells reached OnAirDone state"
KEY_TIMESTART_KPI5 = "from OnAirDone to Validated"
kEY_TIMEEND_KPI5 = "from Validated to OnAirDone"
KEY_TIMESTART_KPI16a = "\\[PlanActivateIndScenario\\] start scenario for"
kEY_TIMEEND_KPI16a = "AntennaCarrierDeactivationResp - OK"
KEY_TIMESTART_KPI16b = "\\[PlanActivateIndScenario\\] start scenario for"
kEY_TIMEEND_KPI16b = "AntennaCarrierActivationResp - OK"
KEY_TIMESTART_KPI17a = "Received BLOCK_IND with NR target"
kEY_TIMEEND_KPI17a = "AntennaCarrierDeactivationResp - OK"
KEY_TIMESTART_KPI17b = "Received UNBLOCK_IND with NR target"
kEY_TIMEEND_KPI17b = "AntennaCarrierActivationResp - OK"
KEY_TIMESTART_KPI51a = "from OnAirDone to Validated"
kEY_TIMEEND_KPI51a = "from Validated to OnAirDone"
KEY_TIMESTART_KPI10 = "from OnAirDone to Validated"
kEY_TIMEEND_KPI10 = "from Validated to OnAirDone"
KEY_TIMESTART_IP_connectivity_test = "Registering indication: /\x4dRBTS-1/RAT-1/URI-[[:digit:]]/SESSION-[[" \
                                     ":digit:]]+/PINGTEST_IND-[[:digit:]]"
KEY_TIMEEND_IP_connectivity_test = "PINGTEST_IND-[[:digit:]]+/PINGTEST_RESULT-[[:digit:]]+"
KEY_TIMESTART_SanityChecker = "Trigger start sanity check call"
KEY_TIMEEND_SanityChecker = "SanityCheckIndHandler\\] Successful result created"
KEY_TIMESTART_CellSwitchingOff = "Requesting to switch off cell"
KEY_TIMEEND_CellSwitchingOff = "from OnAirDone to Validated"
KEY_TIMESTART_CellSwitchingOn = "Requesting to switch on cell"
KEY_TIMEEND_CellSwitchingOn = "from Validated to OnAirDone"

KEY_TIMESTART_TRXSwitchingOff = "requesting to switch cell TX off"
KEY_TIMEEND_TRXSwitchingOff = "rgySavingState = REDUCEDENERGYSAVING"
KEY_TIMESTART_TRXSwitchingOn = "Requesting to switch on cell"
KEY_TIMEEND_TRXSwitchingOn = "rgySavingState = NOTENERGYSAVING"
KEY_TIMESTART_DeepSleepWakeUp = "UNBLOCK_IND-[[:digit:]]+ trying to commit"
KEY_TIMEEND_DeepSleepWakeUp = "from Validated to OnAirDone"
