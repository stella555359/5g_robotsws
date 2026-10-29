# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

CFG_DIR = os.path.dirname(os.path.abspath(__file__))
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_CELL_NAME_2 = MR_NR_BTS_NAME + '/NRCELL-2'
MR_NR_CELL_NAME_3 = MR_NR_BTS_NAME + '/NRCELL-3'
MR_NR_CELL_NAME_4 = MR_NR_BTS_NAME + '/NRCELL-4'
MR_NR_CELL_NAME_5 = MR_NR_BTS_NAME + '/NRCELL-5'
MR_NR_CELL_NAME_6 = MR_NR_BTS_NAME + '/NRCELL-6'
MR_NR_CELL_NAME_7 = MR_NR_BTS_NAME + '/NRCELL-7'
MR_NR_CELL_NAME_8 = MR_NR_BTS_NAME + '/NRCELL-8'
MODIFY_SCF_1 = [
    # 1116 frame structure
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME,
        p_name='actA2SgnbRelease'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME,
        p_name='a2MeasReleaseEnabled'),
]
MODIFY_SCF_2 = [
    # 1116 frame structure
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actA2SgnbRelease'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_2,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_3,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_4,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_5,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_6,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_7,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME_8,
        p_name='a2MeasReleaseEnabled'),
]
MODIFY_SCF_3 = [
    # 1116 frame structure
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actA2SgnbRelease'),
    dict(
        value='false',
        dist_name=MR_NR_BTS_NAME,
        p_name='srb3SupportEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='120',
        dist_name=MR_NR_CELL_NAME,
        list_name='a2MeasReleaseSsbRsrp',
        p_name='a2ThresholdReleaseSsbRsrp'),
]
MODIFY_SCF_4 = [
    # 1116 frame structure
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='actA2SgnbRelease'),
    dict(
        value='true',
        dist_name=MR_NR_BTS_NAME,
        p_name='srb3SupportEnabled'),
    dict(
        value='rsrp',
        dist_name=MR_NR_CELL_NAME,
        p_name='a2MeasReleaseEnabled'),
    dict(
        value='120',
        dist_name=MR_NR_CELL_NAME,
        list_name='a2MeasReleaseSsbRsrp',
        p_name='a2ThresholdReleaseSsbRsrp'),
]
a2MeasReleaseSsbRsrp_0 = {
    'a2HysteresisReleaseSsbRsrp': 4,
    'a2ThresholdReleaseSsbRsrp': 70,
    'a2TimeToTriggerReleaseSsbRsrp': 'ms512',
}
a2MeasReleaseSsbRsrp_1 = {
    'a2HysteresisReleaseSsbRsrp': 3,
    'a2ThresholdReleaseSsbRsrp': 69,
    'a2TimeToTriggerReleaseSsbRsrp': 'ms256',
}
a2MeasReleaseSsbRsrq_0 = {
    'a2HysteresisReleaseSsbRsrq': 4,
    'a2ThresholdReleaseSsbRsrq': 70,
    'a2TimeToTriggerReleaseSsbRsrq': 'ms512',
}
a2MeasReleaseSsbRsrq_1 = {
    'a2HysteresisReleaseSsbRsrq': 5,
    'a2ThresholdReleaseSsbRsrq': 68,
    'a2TimeToTriggerReleaseSsbRsrq': 'ms480',
}
