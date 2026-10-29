import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SCF parameters to modify
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_NAME2 = MR_NR_BTS_NAME + '/NRCELL-2'
MR_NR_CELLGRP_NAME = MR_NR_BTS_NAME + '/NRCELLGRP-0'

Mos_TO_ADD_Two_Channels = [
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7'),
    dict(
        class_name='com.nokia.srbts.mnl:CHANNEL',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8')
]

PARAMS_TO_MODIFY_Two_Channels = [
    dict(
        value='4DL4UL',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType'),
    dict(
        value='RX',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7',
         p_name='resourceDN'),
    dict(
        value='RX',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8',
         p_name='resourceDN')
]

PARAMS_TO_DELETE_DL_1PMI_UL_2SSB = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='csirsBeamMgmt'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='periodicCsiAcquisition')]

LIST_TO_ADD_DL_1PMI_UL_2SSB = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        list_name='periodicCsiAcquisition',
        elements=dict(
            csirsNumberWithinReportPeriod_Set1='1',
            csirsPower='10',
            csiReportPeriodicity='slots320',
            maxCsirsNumber='1'))
]

LIST_PARAMS_TO_MODIFY_DL_1PMI_UL_2SSB = [
    dict(dist_name=MR_NR_CELL_NAME, list_name='beamSet',
         elements=[dict(p_name='basicBeamSet', value='beamSet_3_1', index=0),
                   dict(p_name='nrBtsBeamRefinementP2', value='false', index=0)])
]

PARAMS_TO_MODIFY_DL_1PMI_UL_2SSB = [
    dict(
        value='RX',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-7',
         p_name='resourceDN'),
    dict(
        value='RX',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8',
        p_name='direction'),
    dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
         dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-8',
         p_name='resourceDN'),
    dict(
        value='4Rx',
        dist_name=MR_NR_CELL_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='actFdmScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='actCustomBsr',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        p_name='actFdmEnhancedScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='actBeamforming',
        value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='numberOfTransmittedSsBlocks',
        value='4 beams'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='ssBurstSetPeriod',
        value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        value='8x4 Closed Loop Spatial Multiplexing')
]

PARAMS_TO_DELETE_4RX_1S2CC = [
    dict(dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-2'),
    dict(dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-2/PHYANT-1'),
    dict(dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-2/RSL-1'),
    dict(dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-4'),
    dict(dist_name=MR_BTS_NAME + '/EQM-1/HWTOP-1/CABLINK-5'),
    dict(dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2'),
    dict(dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-2/VLANIF-1'),
    dict(dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2'),
    dict(dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-4'),
    dict(dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-4/VLANIF-1'),
    dict(dist_name=MR_BTS_NAME + '/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-4'),
    dict(
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        list_name='rModDNList'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-2',
        list_name='targetDNList')]

LIST_TO_ADD_4RX_1S2CC = [
    dict(
        dist_name=MR_NR_BTS_NAME + '/NRCELL-2',
        list_name='rModDNList',
        elements=[MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1']),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-2',
        list_name='targetDNList',
        elements=[MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1'])
]

PARAMS_TO_MODIFY_4RX_1S2CC = [
    dict(
        value='260',
        dist_name=MR_NR_CELL_NAME,
        p_name='pMax'),
    dict(
        value='260',
        dist_name=MR_NR_CELL_NAME2,
        p_name='pMax'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='ssPbchBlockPower'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME2,
        p_name='ssPbchBlockPower'),
    dict(
        value='636672',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrarfcn'),
    dict(
        value='630048',
        dist_name=MR_NR_CELL_NAME2,
        p_name='nrarfcn'),
    dict(
        value='7881',
        dist_name=MR_NR_CELL_NAME,
        p_name='gscn'),
    dict(
        value='7812',
        dist_name=MR_NR_CELL_NAME2,
        p_name='gscn'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8',
        p_name='resourceDN')
]

PARAMS_TO_MODIFY_4RX_1S2CC_Trunk = [
    dict(
        value='260',
        dist_name=MR_NR_CELL_NAME,
        p_name='pMax'),
    dict(
        value='260',
        dist_name=MR_NR_CELL_NAME2,
        p_name='pMax'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME,
        p_name='ssPbchBlockPower'),
    dict(
        value='0',
        dist_name=MR_NR_CELL_NAME2,
        p_name='ssPbchBlockPower'),
    dict(
        value='636672',
        dist_name=MR_NR_CELL_NAME,
        p_name='nrarfcn'),
    dict(
        value='630048',
        dist_name=MR_NR_CELL_NAME2,
        p_name='nrarfcn'),
    dict(
        value='7881',
        dist_name=MR_NR_CELL_NAME,
        p_name='gscnOrSsPbchArfcn'),
    dict(
        value='7812',
        dist_name=MR_NR_CELL_NAME2,
        p_name='gscnOrSsPbchArfcn'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-1',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-2',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-3',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-4',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-5',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-6',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-7',
        p_name='resourceDN'),
    dict(
        value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2/CHANNELGROUP-1/CHANNEL-8',
        p_name='resourceDN')
]

MODIFY_PARA_Refine_Disable_2SSB = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='numberOfRxBeamforming',
        value='4Rx'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmEnhancedScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'basicBeamSet': 'beamSet_3_1'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'nrBtsBeamRefinementP2': 'false'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actBeamforming',
        value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='numberOfTransmittedSsBlocks',
        value='4 beams'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='ssBurstSetPeriod',
        value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='dlMimoMode',
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_Refine_Enable_2Refine = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='numberOfRxBeamforming',
        value='4Rx'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmEnhancedScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'basicBeamSet': 'beamSet_3_1'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'nrBtsBeamRefinementP2': 'true'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actPdschAtSsbSlots',
        value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actBeamforming',
        value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='numberOfTransmittedSsBlocks',
        value='4 beams'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='ssBurstSetPeriod',
        value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='dlMimoMode',
        value='4x4 or 4x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_DL_1Refine_UL_2Refine = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='numberOfRxBeamforming',
        value='4Rx'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmEnhancedScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'basicBeamSet': 'beamSet_3_1'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'nrBtsBeamRefinementP2': 'true'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actPdschAtSsbSlots',
        value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actBeamforming',
        value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='numberOfTransmittedSsBlocks',
        value='4 beams'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='ssBurstSetPeriod',
        value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='dlMimoMode',
        value='2x2 Closed Loop Spatial Multiplexing')
]

MODIFY_PARA_DL_1PMI_UL_2SSB = [
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='numberOfRxBeamforming',
        value='4Rx'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actCustomBsr',
        value='true'),
    dict(
        dist_name=MR_NR_BTS_NAME,
        parameter='actFdmEnhancedScheduling',
        value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'basicBeamSet': 'beamSet_3_1'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='beamSet',
        value=[{'nrBtsBeamRefinementP2': 'false'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='periodicCsiAcquisition',
        value=[{'maxCsirsNumber': '1',
                'csirsPower': '10'}]),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='actBeamforming',
        value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='numberOfTransmittedSsBlocks',
        value='4 beams'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        parameter='ssBurstSetPeriod',
        value='20'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='nrCellType',
        value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        parameter='dlMimoMode',
        value='8x4 Closed Loop Spatial Multiplexing')
]

# ------------ CPRT Log level ------------------
# 0x10041=5 # AaSysLogOutputMode [0=none; 1=all; 2=udp; 3=sic; 4=standard output; 5=local; 6=remote]
# 0x420000=1
# 0x590072=1 #CP-RT log level (default 1 in 19B, 2 in 20A)
# 0x41001b=1 #CP-NRT log level
SWCONFIG_AASYSLOG = [
    '0x10041=5',
    '0x420000=1',
    '0x590072=1',
    '0x41001b=1'
]
