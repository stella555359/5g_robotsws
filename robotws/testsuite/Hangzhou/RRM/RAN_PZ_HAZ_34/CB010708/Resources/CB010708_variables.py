import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# SCF parameters to modify
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_1_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_2_NAME = MR_NR_BTS_NAME + '/NRCELL-2'
MR_NR_CELL_3_NAME = MR_NR_BTS_NAME + '/NRCELL-3'
MR_NR_CELL_4_NAME = MR_NR_BTS_NAME + '/NRCELL-4'
MR_NR_CELL_5_NAME = MR_NR_BTS_NAME + '/NRCELL-5'
MR_NR_CELL_6_NAME = MR_NR_BTS_NAME + '/NRCELL-6'
LCELNR1_CHANNELGROUP1_DIR = MR_BTS_NAME + '/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1'


# Mos_TO_ADD_Channels_For_2T8R = [
#     dict(
#         class_name='com.nokia.srbts.mnl:CHANNEL',
#         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
#         version='MNL24R3_2412_100'),
#     dict(
#         class_name='com.nokia.srbts.mnl:CHANNEL',
#         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
#         version='MNL24R3_2412_100'),
#     dict(
#         class_name='com.nokia.srbts.mnl:CHANNEL',
#         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
#         version='MNL24R3_2412_100'),
#     dict(
#         class_name='com.nokia.srbts.mnl:CHANNEL',
#         dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
#         version='MNL24R3_2412_100')
# ]

PARAMS_TO_MODIFY_For_72e = [
    # dict(
    #     value='RX',
    #     dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
    #     p_name='direction'),
    # dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
    #      dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-9',
    #      p_name='resourceDN'),
    # dict(
    #     value='RX',
    #     dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
    #     p_name='direction'),
    # dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
    #      dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-10',
    #      p_name='resourceDN'),
    # dict(
    #     value='RX',
    #     dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
    #     p_name='direction'),
    # dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
    #      dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-11',
    #      p_name='resourceDN'),
    # dict(
    #     value='RX',
    #     dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
    #     p_name='direction'),
    # dict(value=MR_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1/PHYANT-1',
    #      dist_name=LCELNR1_CHANNELGROUP1_DIR + '/CHANNEL-12',
    #      p_name='resourceDN'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxBeamforming'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxPucch'),
    dict(
        value='NRFDD_NRTDD',
        dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
        p_name='bbmodBoardConfigType'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='actEcpri72e'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16DL4UL',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType'),
    dict(
        value='16DL4UL',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType'),
    dict(
        value='16DL4UL',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType'),
    dict(
        value='16DL4UL',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType'),
    dict(
        value='16DL4UL',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType'),
    dict(
        value='16DL4UL',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='actPmiSinrUlMuMimo'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_2_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_3_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_4_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_5_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_6_NAME,
    #     p_name='numberOfRxPucch'),


    # dict(
    #     value='true',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='actEcpri72e'),
    # dict(
    #     value='true',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='actDlSrsBm'),
    # dict(
    #     value='6 beams',
    #     dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
    #     p_name='numberOfTransmittedSsBlocks'),
]

PARAMS_TO_MODIFY_Channels_For_2T8R = [
    dict(
        value='true',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actUlSrsBm'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actDlSrsBm'),
    dict(
        value='6 beams',
        dist_name=MR_NR_BTS_NAME + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks'),
]

PARAMS_TO_DELETE_TOPP_PARAMS = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        list_name='syncInputList')
]

LIST_TO_ADD_SYNC_SOURCE_FRAME = [
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        list_name='syncInputList',
        elements=dict(
            syncInputPrio='1',
            syncInputType='1pps/ToD from external GNSS receiver'))
]

LIST_PARAMS_TO_MODIFY_For_2T8R = [
    dict(dist_name=MR_NR_CELL_1_NAME, list_name='beamSet',
         elements=[dict(p_name='basicBeamSet', value='beamSet_6', index=0)])
]


PARAMS_TO_MODIFY_Channels_And_prachConfigurationIndex_For_2T4R_1070 = [
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='16Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxBeamforming'),
    dict(
        value='98',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='98',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='98',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='98',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='98',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='98',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_1_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_1_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_2_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_2_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_3_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_3_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_4_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_4_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_5_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_5_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_6_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_6_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='NRFDD_NRTDD',
        dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
        p_name='bbmodBoardConfigType'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='actEcpri72e'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType'),
]

PARAMS_TO_MODIFY_Channels_And_prachConfigurationIndex_For_2T4R_1070_SBTS00 = [
    # dict(
    #     value='8Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxPucch'),
    # dict(
    #     value='16Rx',
    #     dist_name=MR_NR_CELL_1_NAME,
    #     p_name='numberOfRxBeamforming'),
    dict(
        value='disabled',
        dist_name=MR_NR_BTS_NAME,
        p_name='actFlexibleBISlotDurationMode'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actIncUlPdcchCapacity'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='actIncUlPdcchCapacity'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='actIncUlPdcchCapacity'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='actIncUlPdcchCapacity'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='actIncUlPdcchCapacity'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='actIncUlPdcchCapacity'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='false',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='actPmiSinrUlMuMimo'),
    dict(
        value='202',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='202',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='202',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='202',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='202',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='202',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='prachConfigurationIndex'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_1_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_1_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_2_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_2_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_3_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_3_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_4_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_4_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_5_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_5_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_6_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern1Period'),
    dict(
        value='2.5ms',
        dist_name=MR_NR_CELL_6_NAME + '/NRRIM_PROFILE-1',
        p_name='rsPattern2Period'),
    dict(
        value='NRFDD_NRTDD',
        dist_name=MR_BTS_NAME + '/EQM-1/APEQM-1/CABINET-1/BBMOD-1',
        p_name='bbmodBoardConfigType'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='actEcpri72e'),
    dict(
        value='true',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='actEcpri72e'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='16Rx',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='numberOfRxBeamforming'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_1_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_2_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_3_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_4_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_5_NAME,
        p_name='nrCellType'),
    dict(
        value='4DL2UL',
        dist_name=MR_NR_CELL_6_NAME,
        p_name='nrCellType'),
]

PARAMS_TO_DELETE_TOPP_PARAMS_AND_11026 = [
    dict(dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1'),
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        list_name='syncInputList'),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        list_name='tddFrameStructure'),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        list_name='tddFrameStructure')
]

LIST_TO_ADD_SYNC_SOURCE_FRAME_1070 = [
    dict(
        dist_name=MR_BTS_NAME + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        list_name='syncInputList',
        elements=dict(
            syncInputPrio='1',
            syncInputType='1pps/ToD from external GNSS receiver')),
    dict(
        dist_name=MR_NR_CELL_1_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=MR_NR_CELL_2_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=MR_NR_CELL_3_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=MR_NR_CELL_4_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=MR_NR_CELL_5_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7')),
    dict(
        dist_name=MR_NR_CELL_6_NAME,
        list_name='tddFrameStructure',
        elements=dict(
            frameStructureType='semiStatic',
            guardPeriodLength='2Symbols',
            ulDlDataSlotRatio='3/7'))
]

LIST_PARAMS_TO_MODIFY_For_2T8R_AND_1070 = [
    dict(dist_name=MR_NR_CELL_1_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-67', index=1)]),
    dict(dist_name=MR_NR_CELL_2_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1)]),
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1)]),
    dict(dist_name=MR_NR_CELL_4_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1)]),
    dict(dist_name=MR_NR_CELL_6_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1)]),
]

LIST_PARAMS_TO_MODIFY_For_2T8R_AND_1070_SBTS00 = [
    dict(dist_name=MR_NR_CELL_1_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-67', index=1),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-10067', index=2)]),
    dict(dist_name=MR_NR_CELL_2_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-10067', index=2)]),
    dict(dist_name=MR_NR_CELL_3_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-10067', index=2)]),
    dict(dist_name=MR_NR_CELL_4_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME+'/BWP_PROFILE-10067', index=2)]),
    dict(dist_name=MR_NR_CELL_5_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-10067', index=2)]),
    dict(dist_name=MR_NR_CELL_6_NAME, list_name='cellBwpList',
         elements=[dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-6', index=0),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-67', index=1),
                   dict(p_name='bwpDN', value=MR_NR_BTS_NAME + '/BWP_PROFILE-10067', index=2)]),
]
