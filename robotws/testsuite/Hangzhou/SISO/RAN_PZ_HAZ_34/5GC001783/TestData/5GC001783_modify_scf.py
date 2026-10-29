from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

SCF_MODIFY_1783_COMMON = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRDU-1',
        list_name='refNrCellGroup'),
    dict(
        value='633356',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='nrarfcn'),
    dict(
        value='1',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='gscn'),
    dict(
        value='78',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='freqBandIndicatorNR'),
    dict(
        value='10',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='type0CoresetConfigurationIndex'),
    dict(
        value='13',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='zeroCorrelationZoneConfig'),
    dict(
        value='260',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='pMax'),
    dict(
        value='true',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actDl256Qam'),
    dict(
        value='98',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='prachConfigurationIndex'),
    dict(
        value='20ms',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='csirsTrackingPeriod'),
    dict(
        value='20',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='ssBurstSetPeriod'),
    dict(
        value='Automatic',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlDMRSAdditionalPosition'),
    dict(
        value='Automatic',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulDMRSAdditionalPosition')
]

SCF_MODIFY_100M = [
    dict(
        value='100MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw')
]

SCF_MODIFY_SEMISTATIC_FRAME = [
    dict(
        value='semiStatic',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='frameStructureType'),
    dict(
        value='2Symbols',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='guardPeriodLength'),
    dict(
        value='3/7',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulDlDataSlotRatio')
]

SCF_MODIFY_60M = [
    dict(
        value='60MHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='chBw')
]

SCF_MODIFY_TDLTE_FRAME = [
    dict(
        value='tdLte',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='guardPeriodLength'),
    dict(
        value='2/8',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='3ms',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='lteToNrFrameShift'),
    dict(
        value='tdLteConfig2',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='tdLteUlDlConfig')
]

SCF_MODIFY_2x2 = [
    dict(
        value='2DL2UL',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='nrCellType'),
    dict(
        value='2x2 Closed Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulMimoMode'),
    dict(
        value='true',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='beamSet_1',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='basicBeamSet'),
    dict(
        value='60',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='leftEdgeAngle'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='60',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='rightEdgeAngle'),
    dict(
        value='1 beam',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks')
]

SCF_MODIFY_4x4 = [
    dict(
        value='4DL2UL',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='nrCellType'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='Closed loop Spatial Multiplexing (2x2)',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulMimoMode'),
    dict(
        value='true',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='basicBeamSet'),
    dict(
        value='60',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='leftEdgeAngle'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='nrBtsBeamRefinementP2'),
    dict(
        value='60',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name='beamSet',
        p_name='rightEdgeAngle'),
    dict(
        value='2 beams',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks')
]

SCF_MODIFY_INI_MCS = [
    dict(
        value='27',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='27',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs')
]

SCF_MODIFY_1783_60M_2X2 = SCF_MODIFY_1783_COMMON + SCF_MODIFY_60M + SCF_MODIFY_2x2 + SCF_MODIFY_INI_MCS

SCF_MODIFY_1783_60M_4X4 = SCF_MODIFY_1783_COMMON + SCF_MODIFY_60M + SCF_MODIFY_4x4 + SCF_MODIFY_INI_MCS

SCF_MODIFY_1783_100M_2X2 = SCF_MODIFY_1783_COMMON + SCF_MODIFY_100M + SCF_MODIFY_2x2


# [obsolete] 256QAM is enabled for all case
SCF_MODIFY_VALUE_CASE_041 = [
    dict(
        value='22',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='22',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs'),
    dict(
        value='true',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actDl256Qam')
]

# [obsolete] Modify value for 5GC001783_047
SCF_MODIFY_VALUE_CASE_047 = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs')
]

# [obsolete] Modify value for 5GC001783_048
SCF_MODIFY_VALUE_CASE_048 = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs')
]

# [obsolete] Modify value for 5GC001783_051
SCF_MODIFY_VALUE_CASE_051 = [
    dict(
        value='11',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='11',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs')
]

# [obsolete] Modify value for 5GC001783_052
SCF_MODIFY_VALUE_CASE_052 = [
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ullaIniMcs'),
    dict(
        value='0',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs')
]
