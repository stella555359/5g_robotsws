import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.gnbs[0].instance_id
nr_bts_id = tl.gnbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)


GET_FRAMESTRUCTURETYPE = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='Frame Structure Type',
        abbr='frameStructureType'
    )
]

GET_GUARDPERIODLENGTH = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='Guard Period length',
        abbr='guardPeriodLength'
    )
]

GET_LTETONRFRAMESHIFT = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='LTE to NR frame shift',
        abbr='lteToNrFrameShift'
    )
]

GET_ULDLDATASLOTRATIO = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='UL to DL logical data slot ratio',
        abbr='ulDlDataSlotRatio'
    )
]

GET_MANUALFRAMETIMINGADJUSTMENT = [
    dict(
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1',
        filter_param='Manual frame timing adjustment',
        abbr='manualFrameTimingAdjustment'
    )
]

GET_PRACHCONFIGURATIONINDEX = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='PRACH configuration index',
        abbr='prachConfigurationIndex'
    )
]

GET_ACTUL256QAM = [
    dict(
        dist_name=_NRBTSname + '/NRCELL-1',
        filter_param='Activate 256QAM in UL',
        abbr='actUl256Qam'
    )
]

SET_ACTULDFTSOFDM_TRUE = [
    dict(
        value='true',
        dist_name=_NRBTSname + '/NRCELL-1',
        parameter='actUlDftSOfdm'
    )
]

SET_ACTULDFTSOFDM_FALSE = [
    dict(
        value='false',
        dist_name=_NRBTSname + '/NRCELL-1',
        parameter='actUlDftSOfdm'
    )
]
