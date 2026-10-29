import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')


MR_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_CELL_NAME = MR_NR_NAME + '/NRCELL-1'
MR_NR_CELLGRP_NAME = MR_NR_NAME + '/NRCELLGRP-0'


Para_CB008072_Common = [
    dict(
        dist_name=MR_NR_NAME,
        p_name='actFdmScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_NAME,
        p_name='actFdmEnhancedScheduling',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='chBw',
        new_value='100MHz'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='nrCellType',
        new_value='4DL4UL'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='dlMimoMode',
        new_value='8x4 Closed Loop Spatial Multiplexing'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='cellTechnology',
        new_value='TDD'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='actBeamforming',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='beamSet/0/nrBtsBeamRefinementP2',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='periodicCsiAcquisition/0/csiReportPeriodicity',
        new_value='slots320'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='periodicCsiAcquisition/0/csirsNumberWithinReportPeriod_Set1',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='periodicCsiAcquisition/0/csirsPower',
        new_value='7'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='periodicCsiAcquisition/0/maxCsirsNumber',
        new_value='1'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='prachConfigurationIndex',
        new_value='98'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='pucchModeSelect',
        new_value='longPucch'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='dlQam256PowerBackoffSub6',
        new_value='3'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='dlDataDmrsFdm/0/actDlDataDmrsFdm',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='ulDataDmrsFdm/0/actUlDataDmrsFdm',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschAtSsbSlots',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='actPdschRmCsirsForTracking',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='ulPtrs/0/actUlPtrs',
        new_value='false'),
    dict(
        dist_name=MR_NR_CELL_NAME,
        p_name='actDl256Qam',
        new_value='true'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='scs',
        new_value='30 KHz'),
    dict(
        dist_name=MR_NR_CELLGRP_NAME,
        p_name='ssBurstSetPeriod',
        new_value='20')
]


def clear_dictionary(dict):
    dict.clear()
