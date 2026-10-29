# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_RU_NAME1 = "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/RMOD-1"
MR_BTS_RU_NAME2 = "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/RMOD-2"
MR_BTS_RU_NAME4 = "MRBTS-" + str(tl.gnbs[0].instance_id) + "/EQM-1/APEQM-1/RMOD-4"

ALARM_RU_NAME1 = (
    "[TL"
    + str(tl.gnbs[0].instance_id)
    + "] MRBTS-"
    + str(tl.gnbs[0].instance_id)
    + "/EQM-1/APEQM-1/RMOD-"
)

trunk_roll_list = [10, 1806, 4341, 4352, 4383]
white_list = [61524, 61649, 4654, 61652, 4592, 4681, 4655]
white_list_2919 = [61524, 4654, 61652, 4592, 4681, 2919, 4655, 61649]
white_list_2920 = [61524, 4654, 61652, 4592, 4681, 2920, 4655, 61649]
white_list_4680 = [61524, 4654, 61652, 4592, 4681, 2919, 2920, 4680, 4655, 61649]

alVoltHighThreshold_para1 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThreshold",
        value="116",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThreshold",
        value="116",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThreshold",
        value="116",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="update",
    ),
]
alVoltHighThreshold_para2 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThreshold",
        value="117",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThreshold",
        value="117",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThreshold",
        value="117",
        operation="update",
    ),
]
alVoltHighThreshold_para3 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThreshold",
        value="107",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThreshold",
        value="107",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThreshold",
        value="107",
        operation="update",
    ),
]
alVoltHighThreshold_para4 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThreshold",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThreshold",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThreshold",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="delete",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="delete",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="delete",
    ),
]

alVoltHighThresholdMinor_para1 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltHighThresholdMinor',
        value='88',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltHighThresholdMinor',
        value='88',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltHighThresholdMinor',
        value='88',
        operation='update'
    ),
]

alVoltHighThresholdMinor_para2 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltHighThresholdMinor',
        value='70',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltHighThresholdMinor',
        value='70',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltHighThresholdMinor',
        value='70',
        operation='update'
    ),
]

alVoltHighThresholdMinor_para3 = [
    dict(
         dist_name=MR_BTS_RU_NAME1,
         parameter='alVoltHighThresholdMinor',
         value='106',
         operation='update'
         ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltHighThresholdMinor',
        value='106',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltHighThresholdMinor',
        value='106',
        operation='update'
    ),
]

alVoltHighThresholdMinor_para4 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltHighThresholdMinor',
        value='0',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltHighThresholdMinor',
        value='0',
        operation='update'
    ),
]

recoover_para = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThreshold",
        value="107",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThreshold",
        value="107",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThresholdMinor",
        value="100",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThresholdMinor",
        value="100",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThreshold",
        value="-100",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThreshold",
        value="-100",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThresholdMinor",
        value="-90",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThresholdMinor",
        value="-90",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltUnstableThreshold",
        value="5",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltUnstableThreshold",
        value="5",
        operation="update",
    ),
]

alVoltLowThreshold_para1 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThreshold",
        value="-111",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThreshold",
        value="-111",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThreshold",
        value="-111",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="update",
    ),
]

alVoltLowThreshold_para2 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThreshold",
        value="-112",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThreshold",
        value="-112",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThreshold",
        value="-112",
        operation="update",
    ),
]

alVoltLowThreshold_para3 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThreshold",
        value="-100",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThreshold",
        value="-100",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThreshold",
        value="-100",
        operation="update",
    ),
]

alVoltLowThreshold_para4 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThreshold",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThreshold",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThreshold",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="delete",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="delete",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="delete",
    ),
]

alVoltUnstableThreshold_para1 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltUnstableThreshold",
        value="2",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltUnstableThreshold",
        value="2",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltUnstableThreshold",
        value="2",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltHighThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltLowThresholdMinor",
        value="0",
        operation="update",
    ),
]

alVoltUnstableThreshold_para2 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter="alVoltUnstableThreshold",
        value="1",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter="alVoltUnstableThreshold",
        value="1",
        operation="update",
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter="alVoltUnstableThreshold",
        value="1",
        operation="update",
    ),
]

alVoltLowThresholdMinor_para1 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltLowThresholdMinor',
        value='-88',
        operation='update'
         ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltLowThresholdMinor',
        value='-88',
        operation='update'
         ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltLowThresholdMinor',
        value='-88',
        operation='update'
    ),
]

alVoltLowThresholdMinor_para2 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltLowThresholdMinor',
        value='-70',
        operation='update'
         ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltLowThresholdMinor',
        value='-70',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltLowThresholdMinor',
        value='-70',
        operation='update'
    ),
]

alVoltLowThresholdMinor_para3 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltLowThresholdMinor',
        value='-99',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltLowThresholdMinor',
        value='-99',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltLowThresholdMinor',
        value='-99',
        operation='update'
    ),
]

alVoltLowThresholdMinor_para4 = [
    dict(
        dist_name=MR_BTS_RU_NAME1,
        parameter='alVoltLowThresholdMinor',
        value='0',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME2,
        parameter='alVoltLowThresholdMinor',
        value='0',
        operation='update'
    ),
    dict(
        dist_name=MR_BTS_RU_NAME4,
        parameter='alVoltLowThresholdMinor',
        value='0',
        operation='update'
    ),
]

keywords_list1 = ["TRBLCADM_A-1"]
