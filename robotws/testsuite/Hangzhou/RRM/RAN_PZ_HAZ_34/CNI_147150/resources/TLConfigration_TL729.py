import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRBTS = MRBTS + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
nrcellid = '0'
NRCELL_1 = NRBTS + '/NRCELL-' + nrcellid

TLCommonConfig = {
    "MultiUECFG": {
        "0": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "44416",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "1500Mbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "150Mbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap1nokiacom",
        },
        "1": {
            "detach_request": "true",
            "power_reset": "true",
            "ue_mode": "SA",
            "apn": "wap1nokiacom",
            "iperf_port": "44418",
            "multidrb_QoS_dest": None,
            "dl": {"target_throughput": "1400Mbits/sec", "duration": "3600"},
            "ul": {"target_throughput": "150Mbits/sec", "duration": "3600"},
            "target_percent": "0.8",
            "reset_sol": "none",
            "attach_mode": "5G_SA",
            "dt_name": "DT_8",
            "protocol": "udp",
            "connection_type": "app",
            "apn_address": "wap1nokiacom",
        },
        "ue_index_for_call": ["0"]
    },
}

Config_2UE = {"0": {"dl": {"target_throughput": "1400Mbits/sec", "duration": "600"},
                    "ul": {"target_throughput": "180Mbits/sec", "duration": "600"}},
              "1": {"dl": {"target_throughput": "1400Mbits/sec", "duration": "600"},
                    "ul": {"target_throughput": "180Mbits/sec", "duration": "600"}}, }

matrix_mapping_config = {
    "FREQ": "3500_1_ALL",
    "matrix_mapping": {
        1: {"Radio_D": {"horizontal": 0.49, "vertical": 3.9},
            "position_mapping": [("A1", 0, 0), ("A2", 0, 0), ("A3", 0, 1), ("A4", 0, 1), ("A5", 0, 2), ("A6", 0, 2),
                                 ("A7", 0, 3), ("A8", 0, 3), ("A9", 0, 4), ("A10", 0, 4), ("A11", 0, 5), ("A12", 0, 5),
                                 ("A13", 0, 6), ("A14", 0, 6), ("A15", 0, 7), ("A16", 0, 7), ("A17", 1, 0),
                                 ("A18", 1, 0), ("A19", 1, 1), ("A20", 1, 1), ("A21", 1, 2), ("A22", 1, 2),
                                 ("A23", 1, 3), ("A24", 1, 3), ("A25", 1, 4), ("A26", 1, 4), ("A27", 1, 5),
                                 ("A28", 1, 5), ("A29", 1, 6), ("A30", 1, 6), ("A31", 1, 7), ("A32", 1, 7)]},
        2: {"Radio_D": {"horizontal": 0.49, "vertical": 3.9},
            "position_mapping": [("A33", 0, 0), ("A34", 0, 0), ("A35", 0, 1), ("A36", 0, 1), ("A37", 0, 2),
                                 ("A38", 0, 2), ("A39", 0, 3), ("A40", 0, 3), ("A41", 0, 4), ("A42", 0, 4),
                                 ("A43", 0, 5), ("A44", 0, 5), ("A45", 0, 6), ("A46", 0, 6), ("A47", 0, 7),
                                 ("A48", 0, 7), ("A49", 1, 0), ("A50", 1, 0), ("A51", 1, 1), ("A52", 1, 1),
                                 ("A53", 1, 2), ("A54", 1, 2), ("A55", 1, 3), ("A56", 1, 3), ("A57", 1, 4),
                                 ("A58", 1, 4), ("A59", 1, 5), ("A60", 1, 5), ("A61", 1, 6), ("A62", 1, 6),
                                 ("A63", 1, 7), ("A64", 1, 7)]}
    },
    "UE_mapping_B_Port": {
        "All": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
        "UE0": [9, 10, 11, 12],
        "UE1": [1, 2, 3, 4],
        "UE2": [5, 6, 7, 8],
        "UE0_B12": [9, 10],
        "UE0_B34": [11, 12],
        "UE1_B12": [1, 2],
        "UE1_B34": [3, 4],
        "UE2_B12": [5, 6],
        "UE2_B34": [7, 8],
    }
}

BeamConfigList = [
    'beamSet_4_L60_R60',
    'beamSet_2_L10_R10',
    'beamSet_2_L10_R30',
    'beamSet_2_L10_R45',
    'beamSet_2_L10_R60',
    'beamSet_2_L20_R20',
    'beamSet_2_L30_R30',
    'beamSet_2_L40_R45',
    'beamSet_2_L45_R45',
    'beamSet_2_L45_R60',
    'beamSet_2_L60_R60',
    'beamSet_4_L20_R50',
    'beamSet_4_L30_R40',
    'beamSet_4_L30_R45',
    'beamSet_4_L45_R45',
    'beamSet_4_L60_R10',
    'beamSet_6_L45_R45',
    'beamSet_6_L45_R50',
    'beamSet_6_L50_R50',
    'beamSet_6_L60_R60',
]

BeamConfigList2 = [
    'beamSet_2_L45_R45',
    'beamSet_2_L60_R60',
    'beamSet_4_L45_R45',
    'beamSet_4_L60_R60',
    'beamSet_6_L45_R45',
    'beamSet_6_L60_R60',
]

BeamConfigList3 = [
    'beamSet_1_L10_R10',
    # 'beamSet_1_L30_R20',
    # 'beamSet_1_L45_R45',
    # 'beamSet_1_L60_R60',
]

AngelsFor45And60 = {
    60: [(60, -1), (50, -5), (40, -7), (30, -9), (20, -1), (10, -5),
         (-10, -5), (-20, -1), (-30, -9), (-40, -7), (-50, -5), (-60, -1)],
    45: [(45, -1), (35, -5), (25, -7), (15, -9), (5, -1), (-5, -1), (-15, -9), (-25, -7), (-35, -5), (-45, -1)]
}

PARA_EIRP_False = [
    dict(dist_name=NRCELL_1, parameter='actEirpControl', value='false', operation='update'),
]

PARA_EMF_False = [
    dict(dist_name=NRCELL_1, parameter='actEmfTestMode', value='false', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actPdcchSharingWithPdsch', value='true', operation='update'),
]

PARA_EMF_True = [
    dict(dist_name=NRCELL_1, parameter='actEmfTestMode', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actEirpControl', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actPdcchSharingWithPdsch', value='false', operation='update'),
]

PARA_SRS_False = [
    dict(dist_name=NRCELL_1, parameter='actDlSrsBm', value='false', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlSrsBm', value='false', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actDlMuMimoEnh', value='false', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlMuMimo', value='false', operation='update'),
    dict(dist_name=NRBTS, parameter='actTddCsiRsOpt', value='false', operation='update'),
]

PARA_SRS_True = [
    dict(dist_name=NRCELL_1, parameter='actDlSrsBm', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlSrsBm', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actDlMuMimoEnh', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlMuMimo', value='true', operation='update'),
    dict(dist_name=NRBTS, parameter='actTddCsiRsOpt', value='true', operation='update'),
]

CHANNELGROUP1 = f'{MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{nrcellid}/CHANNELGROUP-1'
CHANNELGROUP2 = f'{MRBTS}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{nrcellid}/CHANNELGROUP-2'

CHANNEL7 = f'{CHANNELGROUP1}/CHANNEL-7'
CHANNEL8 = f'{CHANNELGROUP1}/CHANNEL-8'
CHANNEL9 = f'{CHANNELGROUP1}/CHANNEL-9'
CHANNEL10 = f'{CHANNELGROUP1}/CHANNEL-10'
CHANNEL11 = f'{CHANNELGROUP1}/CHANNEL-11'
CHANNEL12 = f'{CHANNELGROUP1}/CHANNEL-12'

G2_CHANNEL1 = f'{CHANNELGROUP2}/CHANNEL-1'
G2_CHANNEL2 = f'{CHANNELGROUP2}/CHANNEL-2'
G2_CHANNEL3 = f'{CHANNELGROUP2}/CHANNEL-3'
G2_CHANNEL4 = f'{CHANNELGROUP2}/CHANNEL-4'
G2_CHANNEL5 = f'{CHANNELGROUP2}/CHANNEL-5'
G2_CHANNEL6 = f'{CHANNELGROUP2}/CHANNEL-6'
G2_CHANNEL7 = f'{CHANNELGROUP2}/CHANNEL-7'
G2_CHANNEL8 = f'{CHANNELGROUP2}/CHANNEL-8'

RMOD_DN = f'{MRBTS}/EQM-1/APEQM-1/RMOD-1/PHYANT-1'

IRC_8Rx_True = [
    dict(dist_name=NRCELL_1, parameter='numberOfRxBeamforming', value='8Rx', operation='update'),
    dict(dist_name=NRCELL_1, parameter='nrCellType', value='16DL8UL', operation='update'),
    dict(dist_name=CHANNEL7, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL7, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL7, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNEL8, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL8, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL8, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNEL9, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL9, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL9, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNEL10, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL10, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL10, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNEL11, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL11, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL11, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNEL12, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL12, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL12, parameter='resourceDN', value=RMOD_DN, operation='update'),
]

IRC_8Rx_False = [
    dict(dist_name=NRCELL_1, parameter='numberOfRxBeamforming', value='4Rx', operation='update'),
    dict(dist_name=NRCELL_1, parameter='nrCellType', value='16DL4UL', operation='update'),
    dict(dist_name=CHANNEL9, parameter='', value='', operation='delete_object'),
    dict(dist_name=CHANNEL10, parameter='', value='', operation='delete_object'),
    dict(dist_name=CHANNEL11, parameter='', value='', operation='delete_object'),
    dict(dist_name=CHANNEL12, parameter='', value='', operation='delete_object'),
]

PARA_Beamset1 = [
    dict(dist_name=NRCELL_1, parameter='numberOfRxBeamforming', value='2Rx', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlNrEcIdAoa', value='false', operation='update'),
    dict(dist_name=NRCELL_1, parameter='nrCellType', value='4DL2UL', operation='update'),
    dict(dist_name=CHANNEL7, parameter='', value='', operation='delete_object'),
    dict(dist_name=CHANNEL8, parameter='', value='', operation='delete_object'),
    dict(dist_name=CHANNELGROUP2, parameter='', value='', operation='delete_object'),
]

PARA_Not_Beamset1 = [
    dict(dist_name=NRCELL_1, parameter='numberOfRxBeamforming', value='4Rx', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlNrEcIdAoa', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='nrCellType', value='8DL8UL', operation='update'),
    dict(dist_name=CHANNEL7, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL7, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL7, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNEL8, parameter='', value='', operation='create_object'),
    dict(dist_name=CHANNEL8, parameter='direction', value='RX', operation='update'),
    dict(dist_name=CHANNEL8, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=CHANNELGROUP2, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL1, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL1, parameter='direction', value='TX', operation='update'),
    dict(dist_name=G2_CHANNEL1, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL2, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL2, parameter='direction', value='TX', operation='update'),
    dict(dist_name=G2_CHANNEL2, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL3, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL3, parameter='direction', value='TX', operation='update'),
    dict(dist_name=G2_CHANNEL3, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL4, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL4, parameter='direction', value='TX', operation='update'),
    dict(dist_name=G2_CHANNEL4, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL5, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL5, parameter='direction', value='RX', operation='update'),
    dict(dist_name=G2_CHANNEL5, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL6, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL6, parameter='direction', value='RX', operation='update'),
    dict(dist_name=G2_CHANNEL6, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL7, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL7, parameter='direction', value='RX', operation='update'),
    dict(dist_name=G2_CHANNEL7, parameter='resourceDN', value=RMOD_DN, operation='update'),
    dict(dist_name=G2_CHANNEL8, parameter='', value='', operation='create_object'),
    dict(dist_name=G2_CHANNEL8, parameter='direction', value='RX', operation='update'),
    dict(dist_name=G2_CHANNEL8, parameter='resourceDN', value=RMOD_DN, operation='update'),
]

PARA_PMI_True = [
    dict(dist_name=NRCELL_1, parameter='dlMimoMode', value='8x4 Closed Loop Spatial Multiplexing', operation='update'),
    dict(dist_name=NRCELL_1, parameter='periodicCsiAcquisition', value=[{'csiReportPeriodicity': 'slots320',
                                                                         'csirsNumberWithinReportPeriod_Set1': '2',
                                                                         'csirsPower': '17',
                                                                         'maxCsirsNumber': '4'}],
         operation='update'),
    dict(dist_name=NRBTS, parameter='actTddCsiRsOpt', value='true', operation='update'),
]

PARA_PMI_False = [
    dict(dist_name=NRCELL_1, parameter='dlMimoMode', value='4x4 or 4x2 Open Loop Spatial Multiplexing',
         operation='update'),
    dict(dist_name=NRCELL_1, parameter='periodicCsiAcquisition', value='', operation='delete'),
    dict(dist_name=NRBTS, parameter='actTddCsiRsOpt', value='false', operation='update'),
]

PARA_PMI_AND_SRS_True = [
    dict(dist_name=NRCELL_1, parameter='dlMimoMode', value='8x4 Closed Loop Spatial Multiplexing', operation='update'),
    dict(dist_name=NRCELL_1, parameter='periodicCsiAcquisition', value=[{'csiReportPeriodicity': 'slots320',
                                                                         'csirsNumberWithinReportPeriod_Set1': '2',
                                                                         'csirsPower': '17',
                                                                         'maxCsirsNumber': '4'}],
         operation='update'),
    dict(dist_name=NRBTS, parameter='actTddCsiRsOpt', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actDlSrsBm', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlSrsBm', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actDlMuMimoEnh', value='true', operation='update'),
    dict(dist_name=NRCELL_1, parameter='actUlMuMimo', value='true', operation='update'),
]

Structure_csirsBeamMgmt = [
    {'csirsBmMgmtDensity': 'density3',
     'csirsBmMgmtReIndex': '0',
     'csirsBmMgmtSubband': 'aboveSSPBCHBlock'}
]

PARA_csirsBeamMgmt = [
    dict(dist_name=NRCELL_1, parameter='csirsBeamMgmt', value=Structure_csirsBeamMgmt, operation='update'),
]

NRPGRP_0 = NRBTS + '/NRPGRP-0'

lbpsPeriod0 = [
    {'lbpsDayOfWeek': 'Mon',
     'lbpsDuration': '1',
     'lbpsStartTimeHour': '7',
     'lbpsStartTimeMinute': '0',
     'lbpsSuspended': 'notSuspended'}
]

PARA_PowerSving = [
    dict(dist_name=NRPGRP_0, parameter='lbpsPeriodList', value=lbpsPeriod0, operation='update'),
]

PARA_DlDynSwitch_False = [
    dict(dist_name=NRCELL_1, parameter='actDlDynSwitchAlloc', value='false', operation='update'),
]

case_B005_mcs_set = [{'mcs_port': 'UE0_B12', 'H_angle': -32, 'V_angle': -1},
                     {'mcs_port': 'UE0_B34', 'H_angle': -32, 'V_angle': -7},]

case_B009_mcs_set = [{'mcs_port': 'UE0_B12', 'H_angle': -45, 'V_angle': -1},
                     {'mcs_port': 'UE0_B34', 'H_angle': -45, 'V_angle': -7},
                     {'mcs_port': 'UE1_B12', 'H_angle': 35, 'V_angle': -1},
                     {'mcs_port': 'UE1_B34', 'H_angle': 35, 'V_angle': -7},]

case_B010_mcs_set = [{'mcs_port': 'UE0_B12', 'H_angle': 2, 'V_angle': -1},
                     {'mcs_port': 'UE0_B34', 'H_angle': 2, 'V_angle': -7},
                     {'mcs_port': 'UE1_B12', 'H_angle': 38, 'V_angle': -1},
                     {'mcs_port': 'UE1_B34', 'H_angle': 38, 'V_angle': -7},]

case_B010_mcs_set2 = [{'mcs_port': 'UE0_B12', 'H_angle': 18, 'V_angle': -1},
                      {'mcs_port': 'UE0_B34', 'H_angle': 18, 'V_angle': -7},
                      {'mcs_port': 'UE1_B12', 'H_angle': -14, 'V_angle': -1},
                      {'mcs_port': 'UE1_B34', 'H_angle': -14, 'V_angle': -7},]
