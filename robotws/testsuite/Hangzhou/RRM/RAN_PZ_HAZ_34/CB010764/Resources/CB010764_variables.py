from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'jack.zeng'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jack.zeng@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb_id = str(tl.gnbs[0].instance_id)
_global_bts_id = str(tl.gnbs[0].global_bts_id)
_enb_id_0 = str(tl.enbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_global_bts_id
_LNBTSname = 'LNBTS-'+_enb_id_0
_LTE_MRBTSname = _MRBTSname+'/LNBTS-'+_enb_id_0
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-1'
_NRCELL2name = _NRBTSname+'/NRCELL-2'
_NRCELL3name = _NRBTSname+'/NRCELL-3'
_NRBTSDUname = _NRBTSname+'/NRDU-1'
_NRBTSDUnameGRPgNB1cell = _NRBTSname+'/NRCELLGRP-0'
_NRBTSDUnameGRPgNB1cell2 = _NRBTSname+'/NRCELLGRP-1'
_NRRELLnamegnb1 = _NRCELL2name+'/NRREL-0'
_NRRELLnamegnb11 = _NRCELL2name+'/NRREL-1'
_NRDU = _NRBTSname+'/NRDU-1'
_LTEENB = _NRBTSname+'/LTEENB-0'
_LTECELL1name = _LTE_MRBTSname+'/LNCEL-1'
_LTECELL2name = _LTE_MRBTSname+'/LNCEL-2'
_NRRELL2NRREDRT = _NRCELL2name+'/NRREDRT-0'
_NRRELL1NRREDRT = _NRCELLname+'/NRREDRT-1'
_NRPUSCHHRLA_1 = _NRBTSname+'/NRPUSCHHRLA-1'
_NRPMRNL_1 = _NRBTSname+'/NRPMRNL-1'
_alSelection = _NRBTSname+'/BWP_PROFILE-54'
_BWP_PROFILE_54 = _alSelection+'/PDCCH-1'
_NRPDSCHHRLA_1 = _NRBTSname+'/NRPDSCHHRLA-1'
_NRPDSCHHRLA_2 = _NRBTSname+'/NRPDSCHHRLA-2'
_NRDRB10name = _NRBTSname+'/NRDRB-10'
_NRDRB12name = _NRBTSname+'/NRDRB-12'
_NRDRB15name = _NRBTSname+'/NRDRB-15'
_NRDRB16name = _NRBTSname+'/NRDRB-16'

_BWP_PROFILE_41 = _NRBTSname+'/BWP_PROFILE-41'
_BWP_PROFILE_42 = _NRBTSname+'/BWP_PROFILE-42'
_BWP_PROFILE_5 = _NRBTSname+'/BWP_PROFILE-5'
_BWP_PROFILE_054 = _NRBTSname+'/BWP_PROFILE-54'
_AMF1GNB1 = _NRBTSname+'/SERVEDAMF-1'
_CHANNEL_7 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7'
_CHANNEL_8 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8'
_CHANNEL_9 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-9'
_CHANNEL_10 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-10'
_CHANNEL_11 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-11'
_CHANNEL_12 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-12'
_CHANNEL_15 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-15'
_CHANNEL_16 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-2/CHANNEL-16'
_CABLINK_10 = _MRBTSname+'/EQM-1/HWTOP-1/CABLINK-10'
_FEATCADM_1 = _MRBTSname+'/MNL-1/MNLENT-1/FEATCADM-1'
_SMOD_EXT_1 = _MRBTSname+'/EQM-1/SMOD_EXT-1'
_CABLINK_5 = _MRBTSname+'/EQM-1/HWTOP-1/CABLINK-5'
_CHANNEL2_7 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7'
_CHANNEL2_8 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8'
_CHANNEL2_9 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-9'
_CHANNEL2_10 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-10'
_CHANNEL2_11 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-11'
_CHANNEL2_12 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-12'
_CHANNEL2_15 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-15'
_CHANNEL2_16 = _MRBTSname+'/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-16'

_NRPMCCP1 = _NRPMRNL_1+'/NRPMCCP-1'
PATH_TO_SCF = ''

# cases CB010764  TRUNK####
PARAM_CB010764_gnb1_B_2001_0 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats',  'PRACH with Preamble',
                'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value='barred', dist_name=_NRCELLname, parameter='cellBarred'),
]

PARAM_CB010764_gnb1_B_2001_1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRtwpMeasurement'),
    # dict(value='enabledWithoutPRACH_PUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
    # dict(value=['Scheduled PUSCH PRBs', 'PUCCH F2,F3,F4', 'PUCCH F1', 'PRACH with Preamble',
    #             'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounters'),
    # dict(value=['Scheduled PUSCH PRBs', 'Unscheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1',
    #             'PRACH with Preamble', 'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats',  'PRACH with Preamble',
                'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value='barred', dist_name=_NRCELLname, parameter='cellBarred'),
]

PARAM_CB010764_gnb1_B_2001_2 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    # dict(value=['Scheduled PUSCH PRBs', 'PUCCH F2,F3,F4', 'PUCCH F1'],
    #      dist_name=_NRPMCCP1, parameter='actNrUlRipCounters'),
    # dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1'],
    #      dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    # dict(value=['Other PUCCH formats', 'PUCCH F1'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter')
]

PARAM_CB010764_gnb1_B_2001_3 = [
    # dict(value='enabledWithoutPRACH', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
    # dict(value=['Scheduled PUSCH PRBs', 'PUCCH F2,F3,F4', 'PUCCH F1'],
    #      dist_name=_NRPMCCP1, parameter='actNrUlRipCounters'),
    # dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1'],
    #      dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    # dict(value=['Other PUCCH formats', 'PUCCH F1'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1'],
         dist_name=_NRPMCCP1, parameter='actNrUlRipCounter')
]

PARAM_CB010764_gnb1_B_2001_Recovery = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRtwpMeasurement'),
    # dict(value='enabledWithPRACH_PUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
    # dict(value=['Scheduled PUSCH PRBs', 'PUCCH F2,F3,F4', 'PUCCH F1', 'PRACH with Preamble',
    #             'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounters'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1', 'PRACH with Preamble',
                'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value='notBarred', dist_name=_NRCELLname, parameter='cellBarred'),
]

# PARAM_CB010764_gnb1_B_2001_1 = [
#     dict(value='false', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
#     dict(value='false', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
#     dict(value='false', dist_name=_NRBTSname, parameter='actRtwpMeasurement'),
#     dict(value='enabledWithoutPRACH_PUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
#     dict(value=['Scheduled PUSCH PRBs', 'PUCCH F2,F3,F4'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounters')
# ]
#
# PARAM_CB010764_gnb1_B_2001_2 = [
#     dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
#     dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst')
# ]
#
# PARAM_CB010764_gnb1_B_2001_3 = [
#     dict(value='enabledWithoutPRACH', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement')
# ]


PARAM_CB010764_gnb1_E_56001_1_cloud = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRtwpMeasurement'),
    dict(value='enabledWithoutPUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement')
]

PARAM_CB010764_gnb1_E_56001_1_cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='false', dist_name=_NRBTSname, parameter='actRtwpMeasurement'),
    dict(value='enabledWithoutPUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
    # dict(value=['Scheduled PUSCH PRBs', 'PUCCH F2,F3,F4'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounters')
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value='barred', dist_name=_NRCELLname, parameter='cellBarred'),
]

PARAM_CB010764_gnb1_E_56001_1_cell1_Recovery = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRBTSname, parameter='actRtwpMeasurement'),
    dict(value='enabledWithPRACH_PUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1', 'PRACH with Preamble',
                'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
    dict(value='notBarred', dist_name=_NRCELLname, parameter='cellBarred'),
]

PARAM_CB010764_gnb1_E_56001_2_cloud = [
    dict(value='enabledWithoutPRACH', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
]

counter_id_B_2001 = [
    'M55360C00015', 'M55360C00016', 'M55360C00017', 'M55360C00018', 'M55360C00019', 'M55360C00020'
]

counter_dic_path_B_2001 = [
    'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP',
    'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP'
]

counter_dic_path_B_2001_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP'
]

counter_dic_path_B_2001_cloud_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP'
]

counter_dic_path_B_2001_cell2 = [
    'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP',
    'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP'
]

counter_dic_path_B_2001_cell2_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP'
]

counter_id_B_2001_2 = [
    'M55360C01015', 'M55360C01016', 'M55360C01017', 'M55360C01018', 'M55360C01019', 'M55360C01020'
]

counter_id_B_3001 = [
    'M55360C00015', 'M55360C00016', 'M55360C00017', 'M55360C00018', 'M55360C00019', 'M55360C00020'
]

counter_id_B_3001_max = [
    'M55360C01015', 'M55360C01016', 'M55360C01017', 'M55360C01018', 'M55360C01019', 'M55360C01020'
]

# counter_id_B_3001_cloud = [
#     'M55360C00147', 'M55360C00148', 'M55360C00149', 'M55360C00150', 'M55360C00151', 'M55360C00152',
#     'M55360C00153', 'M55360C00154', 'M55360C00155', 'M55360C00156', 'M55360C00157', 'M55360C00158'
# ]
#
# counter_id_B_3001_cloud_max = [
#     'M55360C01147', 'M55360C01148', 'M55360C01149', 'M55360C01150', 'M55360C01151', 'M55360C01152',
#     'M55360C01153', 'M55360C01154', 'M55360C01155', 'M55360C01156', 'M55360C01157', 'M55360C01158'
# ]

# counter_id_B_3001_cloud = [
#     'M55360C00064', 'M55360C00065', 'M55360C00066', 'M55360C00067', 'M55360C00068', 'M55360C00069',
#     'M55360C00070', 'M55360C00071', 'M55360C00072', 'M55360C00073', 'M55360C00074', 'M55360C00075'
# ]
#
# counter_id_B_3001_cloud_max = [
#     'M55360C01064', 'M55360C01065', 'M55360C01066', 'M55360C01067', 'M55360C01068', 'M55360C01069',
#     'M55360C01070', 'M55360C01071', 'M55360C01072', 'M55360C01073', 'M55360C01074', 'M55360C01075'
# ]

counter_id_B_3001_cloud = [
    'M55360C00046', 'M55360C00047', 'M55360C00048', 'M55360C00049', 'M55360C00050', 'M55360C00051',
    'M55360C00052', 'M55360C00053', 'M55360C00054', 'M55360C00055', 'M55360C00056', 'M55360C00057'
]

counter_id_B_3001_cloud_max = [
    'M55360C01046', 'M55360C01047', 'M55360C01048', 'M55360C01049', 'M55360C01050', 'M55360C01051',
    'M55360C01052', 'M55360C01053', 'M55360C01054', 'M55360C01055', 'M55360C01056', 'M55360C01057'
]

# counter_id_B_E56002 = [
#     'M55360C00067', 'M55360C00068', 'M55360C00069', 'M55360C00070', 'M55360C00071', 'M55360C00072',
#     'M55360C00073', 'M55360C00074', 'M55360C00075', 'M55360C00076', 'M55360C00077', 'M55360C00078'
# ]

counter_id_B_E56002 = [
    'M55360C00036', 'M55360C00037', 'M55360C00038', 'M55360C00039', 'M55360C00040', 'M55360C00041',
    'M55360C00042', 'M55360C00043', 'M55360C00044', 'M55360C00045', 'M55360C00046', 'M55360C00047'
]

counter_dic_path_B_E56002 = [
    'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP',
    'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP',
    'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP', 'BTS/CELLS/NRCELL-2/NRRIP'
]

counter_dic_path_B_E56002_cell1 = [
    'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP',
    'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP',
    'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP', 'BTS/CELLS/NRCELL-1/NRRIP'
]

counter_dic_path_B_E56002_cell1_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP'
]

counter_dic_path_B_E56002_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-2/NRRIP'
]

counter_dic_path_B_E56002_trunk_cell1 = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP',
    'BTS/' + _NRBTSname + '/NRCELL-1/NRRIP'
]

# counter_id_B_E56002_2 = [
#     'M55360C01067', 'M55360C01068', 'M55360C01069', 'M55360C01070', 'M55360C01071', 'M55360C01072',
#     'M55360C01073', 'M55360C01074', 'M55360C01075', 'M55360C01076', 'M55360C01077', 'M55360C01078',
# ]

counter_id_B_E56002_2 = [
    'M55360C01036', 'M55360C01037', 'M55360C01038', 'M55360C01039', 'M55360C01040', 'M55360C01041',
    'M55360C01042', 'M55360C01043', 'M55360C01044', 'M55360C01045', 'M55360C01046', 'M55360C01047',
]


PARAM_CB010764_gnb1_C_4001_1_Cell1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='8x4 Closed Loop Spatial Multiplexing', dist_name=_NRCELLname, parameter='dlMimoMode'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality')
]

PARAM_CB010764_gnb1_C_4001_2_Cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_C_4001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='8x4 Closed Loop Spatial Multiplexing', dist_name=_NRCELL2name, parameter='dlMimoMode'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality')
]

PARAM_CB010764_gnb1_C_4001_2_Cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_C_5002_1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlOpenLoopPwrCtrl'),
    dict(value='-96', dist_name=_NRCELL2name, parameter='p0NominalPusch'),
    dict(value='-96', dist_name=_NRCELL2name, parameter='p0NominalSrs'),
    dict(value='-al1', dist_name=_NRCELL2name, parameter='alpha'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality')
]

PARAM_CB010764_gnb1_C_10001_1_Cell3 = [
    dict(value='false', dist_name=_NRCELL3name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL3name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcs'),
]

PARAM_CB010764_gnb1_C_10001_2_Cell3 = [
    dict(value='true', dist_name=_NRCELL3name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_C_10001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
]

PARAM_CB010764_gnb1_C_10001_2_Cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_D_14001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_14001_1_Cell1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_14001_2_Cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_D_14001_2_Cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_E_11001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_E_11001_1_Cell1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_18001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs')
]

PARAM_CB010764_gnb1_D_18001_2_Cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_D_18001_1_Cell1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs')
]

PARAM_CB010764_gnb1_D_18001_2_Cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_C_7001_1_Cell3 = [
    dict(value='false', dist_name=_NRCELL3name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL3name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAdaptiveReTxResMcs'),
]

PARAM_CB010764_gnb1_C_7001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
]

PARAM_CB010764_gnb1_C_7001_2_Cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_C_7001_2_Cell3 = [
    dict(value='true', dist_name=_NRCELL3name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_C_5001_2_Cell3 = [
    dict(value='false', dist_name=_NRCELL3name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL3name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL3name, parameter='actUlDftSOfdm')
]

PARAM_CB010764_gnb1_C_5002_2_Cell3 = [
    dict(value='true', dist_name=_NRCELL3name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_E_9001_1_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELL2name, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actUlDftSOfdm')
]

PARAM_CB010764_gnb1_E_9001_2_Cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_E_9001_1_Cell1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAperCsi'),
    dict(value='5min', dist_name=_NRPMRNL_1, parameter='miNrUlSignalQuality'),
    # dict(value='false', dist_name=_NRCELLname, parameter='actProactUlScheduling'),
    dict(value='true', dist_name=_NRCELLname, parameter='actAdaptiveReTxResMcs'),
    dict(value='true', dist_name=_NRCELLname, parameter='actUlDftSOfdm')
]

PARAM_CB010764_gnb1_E_9001_2_Cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPuschACSIPart2ThrAdj')
]

PARAM_CB010764_gnb1_A_1001_1 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_A_1001_1_cloud = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='locked', dist_name=_LTECELL2name, parameter='administrativeState'),
    dict(value='1', dist_name=_LTECELL1name, parameter='defaultLnRelGnbCellId')
]

PARAM_CB010764_gnb1_E_1001_1_cloud = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELL2name, parameter='srPeriodicity'),
]

PARAM_CB010764_gnb1_D_2001_1_cloud = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX'),
    dict(value='pi2bpsk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot08', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_4001_1_cloud = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot25', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELL2name, parameter='srPeriodicity'),
    dict(value=_NRBTSname+'/NRULCLPC_PROFILE-0', dist_name=_NRCELL2name, parameter='nrUlClpcProfileDN'),
    dict(value='pucchPuschSrs', dist_name=_NRCELL2name, parameter='actUlClosedLoopPwrCtrl'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_4001_1_cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot25', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELLname, parameter='srPeriodicity'),
    dict(value=_NRBTSname+'/NRULCLPC_PROFILE-0', dist_name=_NRCELLname, parameter='nrUlClpcProfileDN'),
    dict(value='pucchPuschSrs', dist_name=_NRCELLname, parameter='actUlClosedLoopPwrCtrl'),
    dict(value='Locked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_2001_2 = [
    dict(value='Unlocked', dist_name=_AMF1GNB1, parameter='administrativeState')
]

PARAM_CB010764_gnb1_D_2001_3 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX')
]

PARAM_CB010764_gnb1_D_2001_3_cell1 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPucchF3EnhanceDTX')
]

PARAM_CB010764_gnb1_D_3001_1_cell1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPucchF3EnhanceDTX'),
    dict(value='pi2bpsk', dist_name=_NRCELLname, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot08', dist_name=_NRCELLname, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELLname, parameter='srPeriodicity')
]

PARAM_CB010764_gnb1_D_3001_1_cloud = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX'),
    dict(value='pi2bpsk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot08', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELL2name, parameter='srPeriodicity')
]

PARAM_CB010764_gnb1_A_3006_1_cloud = [
    dict(value='true', dist_name=_NRCELL3name, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELL3name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELL3name, parameter='pucchF3MaxCodeRate'),
    dict(value='2x2 Open Loop Spatial Multiplexing', dist_name=_NRCELL3name, parameter='dlMimoMode')
]

PARAM_CB010764_gnb1_A_3006_1_cell2 = [
    dict(value='true', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, parameter='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, parameter='pucchF3MaxCodeRate'),
    dict(value='2x2 Open Loop Spatial Multiplexing', dist_name=_NRCELL2name, parameter='dlMimoMode')
]

PARAM_CB010764_gnb1_A_1001_2 = [
    dict(value='Unlocked', dist_name=_AMF1GNB1, parameter='administrativeState'),
    dict(value='unlocked', dist_name=_LTECELL2name, parameter='administrativeState'),
    dict(value='2', dist_name=_LTECELL1name, parameter='defaultLnRelGnbCellId')
]

PARAM_CB010764_gnb1_A_3006_3_cloud = [
    dict(value='false', dist_name=_NRCELL3name, parameter='actPucchF3EnhanceDTX')
]

PARAM_CB010764_gnb1_A_1001_3_Cell2 = [
    dict(value='false', dist_name=_NRCELL2name, parameter='actPucchF3EnhanceDTX')
]

PARAM_CB010764_gnb1_A_1001_3 = [
    dict(value='false', dist_name=_NRCELLname, parameter='actPucchF3EnhanceDTX')
]

counter_id_A_1001 = [
    'M55303C17001', 'M55303C18001'
]

counter_dic_path_A_1001 = [
    'BTS/CELLS/NRCELL-1/NULSQ', 'BTS/CELLS/NRCELL-1/NULSQ'
]

counter_dic_path_A_1001_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NULSQ',
    'BTS/' + _NRBTSname + '/NRCELL-1/NULSQ'
]

counter_dic_path_A_1001_cell2 = [
    'BTS/CELLS/NRCELL-2/NULSQ', 'BTS/CELLS/NRCELL-2/NULSQ'
]

counter_dic_path_A_1001_cell2_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-2/NULSQ',
    'BTS/' + _NRBTSname + '/NRCELL-2/NULSQ'
]

counter_dic_path_D_2001 = [
    'BTS/CELLS/NRCELL-2/NULSQ', 'BTS/CELLS/NRCELL-2/NULSQ'
]

counter_dic_path_D_2001_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-2/NULSQ',
    'BTS/' + _NRBTSname + '/NRCELL-2/NULSQ'
]

counter_dic_path_D_2001_cell1 = [
    'BTS/CELLS/NRCELL-1/NULSQ', 'BTS/CELLS/NRCELL-1/NULSQ'
]

counter_dic_path_D_2001_cell1_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-1/NULSQ',
    'BTS/' + _NRBTSname + '/NRCELL-1/NULSQ'
]

counter_dic_path_A_3006 = [
    'BTS/CELLS/NRCELL-3/NULSQ', 'BTS/CELLS/NRCELL-3/NULSQ'
]

counter_dic_path_A_3006_trunk = [
    'BTS/' + _NRBTSname + '/NRCELL-3/NULSQ',
    'BTS/' + _NRBTSname + '/NRCELL-3/NULSQ'
]

PARAM_CB010764_gnb1_B_3001_1 = [
    dict(value='true', dist_name=_NRCELLname, parameter='actPrachNoPreambleNoisePwrEst'),
    dict(value='true', dist_name=_NRCELL2name, parameter='actPrachNoPreambleNoisePwrEst'),
    # dict(value='enabledWithoutPUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement'),
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PRACH with Preamble',
                'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter'),
]

CB010764_E_ParamterToModify = [
    dict(value='true', dist_name=_NRCELL2name, p_name='actPucchF3EnhanceDTX'),
    dict(value='qpsk_4psk', dist_name=_NRCELL2name, p_name='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELL2name, p_name='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELL2name, p_name='srPeriodicity'),
    dict(value='8Rx', dist_name=_NRCELL2name, p_name='numberOfRxBeamforming'),
    dict(value='8Rx', dist_name=_NRCELL2name, p_name='numberOfRxPucch'),
    dict(value='RX', dist_name=_CHANNEL_7, p_name='direction'),
    dict(value=_MRBTSname+'/EQM-1/APEQM-1/RMOD-4/PHYANT-1', dist_name=_CHANNEL_7, p_name='resourceDN'),
    dict(value='RX', dist_name=_CHANNEL_8, p_name='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-4/PHYANT-1', dist_name=_CHANNEL_8, p_name='resourceDN'),
    dict(value='RX', dist_name=_CHANNEL_9, p_name='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-4/PHYANT-1', dist_name=_CHANNEL_9, p_name='resourceDN'),
    dict(value='RX', dist_name=_CHANNEL_10, p_name='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-4/PHYANT-1', dist_name=_CHANNEL_10, p_name='resourceDN'),
    dict(value='false', dist_name=_FEATCADM_1, p_name='rfSharingEnabled')
]

CB010764_E_ParamterToDelete = [
    dict(dist_name=_CHANNEL_11),
    dict(dist_name=_CHANNEL_12),
    dict(dist_name=_CHANNEL_15),
    dict(dist_name=_CHANNEL_16),
    dict(dist_name=_CABLINK_10)
]

CB010764_E_MOsToAdd = [
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL_7, version="MNL24R1_2321_100"),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL_8, version="MNL24R1_2321_100"),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL_9, version="MNL24R1_2321_100"),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL_10, version="MNL24R1_2321_100")
]


CB010764_E_ParamterToModify_classical = [
    dict(value='true', dist_name=_NRCELLname, p_name='actPucchF3EnhanceDTX'),
    dict(value='false', dist_name=_NRBTSname, p_name='actCuOvlProt'),
    dict(value='false', dist_name=_NRBTSname, p_name='actDuOvlProt'),
    dict(value='true', dist_name=_NRBTSname, p_name='actMeasBasedSCellAddition'),
    dict(value='SR_and_DRX', dist_name=_NRCELLname, p_name='actFlexGapOffset'),
    dict(value='SR_and_DRX', dist_name=_NRCELL2name, p_name='actFlexGapOffset'),
    dict(value='qpsk_4psk', dist_name=_NRCELLname, p_name='pucchF3ModulationScheme'),
    dict(value='zeroDot15', dist_name=_NRCELLname, p_name='pucchF3MaxCodeRate'),
    dict(value='slots160', dist_name=_NRCELLname, p_name='srPeriodicity'),
    dict(value='slots80', dist_name=_NRCELL2name, p_name='srPeriodicity'),
    dict(value='8Rx', dist_name=_NRCELLname, p_name='numberOfRxBeamforming'),
    dict(value='8Rx', dist_name=_NRCELLname, p_name='numberOfRxPucch'),
    dict(value='RX', dist_name=_CHANNEL2_7, p_name='direction'),
    dict(value=_MRBTSname+'/EQM-1/APEQM-1/RMOD-1/PHYANT-1', dist_name=_CHANNEL2_7, p_name='resourceDN'),
    dict(value='RX', dist_name=_CHANNEL2_8, p_name='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1', dist_name=_CHANNEL2_8, p_name='resourceDN'),
    dict(value='RX', dist_name=_CHANNEL2_9, p_name='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1', dist_name=_CHANNEL2_9, p_name='resourceDN'),
    dict(value='RX', dist_name=_CHANNEL2_10, p_name='direction'),
    dict(value=_MRBTSname + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1', dist_name=_CHANNEL2_10, p_name='resourceDN'),
    dict(value='false', dist_name=_FEATCADM_1, p_name='rfSharingEnabled')
]

CB010764_A_ParamterToModify_classical = [
    dict(value='false', dist_name=_NRBTSname, p_name='actCuOvlProt'),
    dict(value='false', dist_name=_NRBTSname, p_name='actDuOvlProt'),
    dict(value='true', dist_name=_NRBTSname, p_name='actGeneralConnectivityBronze'),
    dict(value='true', dist_name=_NRBTSname, p_name='actGeneralConnectivityGold'),
    dict(value='true', dist_name=_NRBTSname, p_name='actGeneralConnectivityBronze'),
    dict(value='true', dist_name=_NRBTSname, p_name='actMeasBasedSCellAddition'),
    dict(value='SR_and_DRX', dist_name=_NRCELLname, p_name='actFlexGapOffset'),
    dict(value='SR_and_DRX', dist_name=_NRCELL2name, p_name='actFlexGapOffset'),
    dict(value='slots80', dist_name=_NRCELL2name, p_name='srPeriodicity')
]

CB010764_E_ParamterToDelete_classical = [
    dict(dist_name=_CHANNEL2_11),
    dict(dist_name=_CHANNEL2_12),
    dict(dist_name=_CHANNEL2_15),
    dict(dist_name=_CHANNEL2_16),
    dict(dist_name=_SMOD_EXT_1),
    dict(dist_name=_CABLINK_5),
    dict(dist_name=_MRBTSname+'/MNL-1', p_name='fronthaulIpPool'),
    dict(dist_name=_MRBTSname+'/EQM-1/APEQM-1/RMOD-1', p_name='radioMasterDN')
]

CB010764_E_MOsToAdd_classical = [
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL2_7, version="MNL24R1_2321_100"),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL2_8, version="MNL24R1_2321_100"),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL2_9, version="MNL24R1_2321_100"),
    dict(class_name='com.nokia.srbts.mnl:CHANNEL', dist_name=_CHANNEL2_10, version="MNL24R1_2321_100")
]

CB010764_E_LIST_PARAMETERS_TO_MODIFY_GNB1 = [
    dict(dist_name=_NRBTSname, list_name='actMeasBasedSCellAdditionSa',
         elements=[dict(p_name='', value='A1-based', index=0)
                   ])
]

CB010764_E_LIST_PARAMETERS_TO_MODIFY_GNB1_disabled = [
    dict(dist_name=_NRBTSname, list_name='actMeasBasedSCellAdditionSa',
         elements=[dict(p_name='', value='disabled', index=0)
                   ])
]

PARAM_CB010764_gnb1_B_3001_2 = [
    # dict(value='enabledWithPRACH_PUCCH_F1', dist_name=_NRBTSname, parameter='actNrUlRipMeasurement')
    dict(value=['Scheduled PUSCH PRBs', 'Other PUCCH formats', 'PUCCH F1', 'PRACH with Preamble',
                'PRACH without Preamble'], dist_name=_NRPMCCP1, parameter='actNrUlRipCounter')
]
