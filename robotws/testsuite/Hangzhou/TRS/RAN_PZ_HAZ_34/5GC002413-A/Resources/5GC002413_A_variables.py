import os
from taf.config.testline.info import info
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
mr_bts_id = tl.enbs[0].instance_id
nr_bts_id = tl.enbs[0].global_bts_id
_MRBTSname = 'MRBTS-' + str(mr_bts_id)
_NRBTSname = _MRBTSname + '/NRBTS-' + str(nr_bts_id)
_NRBTS_ID = 'NRBTS-' + str(nr_bts_id)


PARAM_2413_ACCEPTEDCLOCKCLASS = [
    dict(
        value=['6'],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1',
        parameter='acceptedClockClass')
]

PARAM_2413_SYNCIN_2048 = [
    dict(
        value=[{'syncInputPrio': '1', 'syncInputType': '2.048MHz input'}],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        parameter='syncInputList')
]

PARAM_2413_RECOVER_ENV = [
    dict(
        value=[{'syncInputPrio': '1', 'syncInputType': '1pps/ToD from external GNSS receiver'}],
        dist_name=_MRBTSname + '/MNL-1/MNLENT-1/SYNC-1/CLOCK-1',
        parameter='syncInputList')
]
