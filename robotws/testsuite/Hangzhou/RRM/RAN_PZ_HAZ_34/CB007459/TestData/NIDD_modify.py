from robot.libraries.BuiltIn import BuiltIn
import logging
tl = BuiltIn().get_variable_value('${tl}')
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'
LTE_NAME = 'LNBTS-' + str(tl.enbs[0].instance_id)
LTE_CELL_NAME = LTE_NAME + '/LNCELL-1'
DIST_RLRESUMEBACKOFFTMR = NR_CELL_NAME

MODIFY_SCF_DEAFULT = [
    dict(
        value='true',
        dist_name=NR_NAME,
        p_name='actSPID'),
    dict(
        value='false',
        dist_name=NR_NAME + '/NRCELL-1',
        p_name='actProactUlScheduling'),
    dict(
        value='6',
        dist_name=NR_NAME + '/NRCELL-1',
        p_name='ulSchedTimeInterval'),
]
