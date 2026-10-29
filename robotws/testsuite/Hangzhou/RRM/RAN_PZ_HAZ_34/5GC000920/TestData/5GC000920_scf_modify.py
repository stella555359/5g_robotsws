from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

# Modify value for 5GC000920_131
SCF_MODIFY_VALUE_CASE_131 = [
    dict(
        value='true',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='beamSet_2',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name="beamSet",
        p_name='basicBeamSet'),
    dict(
        value='2 beams',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks')
]

SCF_MODIFY_VALUE_CASE_140 = [
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='beamSet_1',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name="beamSet",
        p_name='basicBeamSet'),
    dict(
        value='1 beam',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode')
]

MODIFY_BEAMFORMING_PARAMETERS_VIA_API_131 = [
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='actBeamforming'),
    dict(
        value=[dict(basicBeamSet='beamSet_1', leftEdgeAngle='60',
                    nrBtsBeamRefinementP2='false', rightEdgeAngle='60')],
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        parameter='beamSet'),
    dict(
        value='1 beam',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        parameter='numberOfTransmittedSsBlocks')
]

MODIFY_ADMINISTRATIVESTATE_PARAMETER_TO_LOCKED_VIA_API_140 = [
    dict(
        value='locked',
        dist_name='LNBTS-' + str(tl.gnbs[0].instance_id) + '/LNADJGNB-1',
        parameter='administrativeState')
]

MODIFY_ADMINISTRATIVESTATE_PARAMETER_TO_UNLOCKED_VIA_API_140 = [
    dict(
        value='unlocked',
        dist_name='LNBTS-' + str(tl.gnbs[0].instance_id) + '/LNADJGNB-1',
        parameter='administrativeState')
]

SCF_MODIFY_VALUE_CASE_141 = [
    dict(
        value='tdLte',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='frameStructureType'),
    dict(
        value='4Symbols',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='guardPeriodLength'),
    dict(
        value='3ms',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='lteToNrFrameShift'),
    dict(
        value='tdLteConfig2',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='tdLteUlDlConfig'),
    dict(
        value='2/8',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ulDlDataSlotRatio'),
    dict(
        value='20',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='ssBurstSetPeriod'),
    dict(
        value='20ms',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='csirsTrackingPeriod'),
    dict(
        value='30 KHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='ssbScs'),
    dict(
        value='30 KHz',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='scs'),
    dict(
        value='160',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='prachConfigurationIndex'),
    dict(
        value='4x4 or 4x2 Open Loop Spatial Multiplexing',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dlMimoMode'),
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME,
        p_name='actCarrierAggregation'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actBeamforming'),
    dict(
        value='true',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actDl256Qam'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actDlMuMimo'),
    dict(
        value='false',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='actUlMuMimo'),
    dict(
        value='beamSet_1',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        list_name="beamSet",
        p_name='basicBeamSet'),
    dict(
        value='1 beam',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELLGRP-0',
        p_name='numberOfTransmittedSsBlocks'),
    dict(
        value='23',
        dist_name='NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-1',
        p_name='dllaIniMcs')
]
