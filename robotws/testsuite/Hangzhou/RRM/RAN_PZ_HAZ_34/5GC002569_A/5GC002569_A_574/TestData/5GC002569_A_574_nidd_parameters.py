from robot.libraries.BuiltIn import BuiltIn
import logging

tl = BuiltIn().get_variable_value('${tl}')
program = BuiltIn().get_variable_value('${PROGRAM}')

MR_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NR_NAME = MR_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'

SRC_LTE_NAME = 'LNBTS-' + str(tl.enbs[0].global_bts_id)
SRC_LTE_CELL_NAME = SRC_LTE_NAME + '/LNCEL-1'

TGT_LTE_NAME = 'LNBTS-' + str(tl.enbs[1].global_bts_id)
TGT_LTE_CELL_NAME = TGT_LTE_NAME + '/LNCEL-1'
REPORTING_INTERVAL = '5min'

# this part is about NIDD parameters modified by SCF commission.
MODIFY_SCF_CU = [
    dict(dist_name=NR_NAME, p_name='actInterMeNBMobility', value='true'),
    dict(dist_name=NR_NAME + '/NRPMRNL-1', p_name='miNrX2CC', value=REPORTING_INTERVAL),
    dict(dist_name=NR_NAME + '/NRPMRNL-1', p_name='miNrLteMobilityReport', value=REPORTING_INTERVAL),
]

# this part is about NIDD parameters modified via rest api.
CU_ONLINE_MODIFY = {
    NR_NAME: {'actInterMeNBMobility': 'true'},
    NR_NAME + '/NRPMRNL-1': {'miNrX2CC': REPORTING_INTERVAL,
                             'miNrLteMobilityReport': REPORTING_INTERVAL}
}

SRC_ENB_ONLINE_MODIFY_COMMON = [
    dict(dist_name=SRC_LTE_CELL_NAME, parameter='defaultLnRelGnbCellId', value='1'),
    dict(dist_name=SRC_LTE_NAME, parameter='actHoWoSnChg', value='intraEnbAndX2HoEnabled'),
    dict(dist_name=SRC_LTE_NAME, parameter='actSnChangeSnInit', value='true'),
    dict(dist_name=SRC_LTE_CELL_NAME, parameter='tac', value='20001'),
]

SRC_ENB_ONLINE_MODIFY_INTRA_FREQ = [
    dict(dist_name=SRC_LTE_CELL_NAME, parameter='a3Offset', value='20'),
    dict(dist_name=SRC_LTE_CELL_NAME, parameter='hysA3Offset', value='0'),
]

TGT_ENB_ONLINE_MODIFY_COMMON = [
    dict(dist_name=TGT_LTE_CELL_NAME, parameter='defaultLnRelGnbCellId', value='2'),
    dict(dist_name=TGT_LTE_NAME, parameter='actHoWoSnChg', value='intraEnbAndX2HoEnabled'),
    dict(dist_name=TGT_LTE_NAME, parameter='actSnChangeSnInit', value='true'),
    dict(dist_name=TGT_LTE_CELL_NAME, parameter='tac', value='20001'),
]

SRC_ENB_ONLINE_MODIFY = SRC_ENB_ONLINE_MODIFY_COMMON + SRC_ENB_ONLINE_MODIFY_INTRA_FREQ

TGT_ENB_ONLINE_MODIFY = TGT_ENB_ONLINE_MODIFY_COMMON

SRC_ENB_ONLINE_MODIFY_SGW_REL = [
    dict(dist_name=SRC_LTE_NAME, parameter='actERabModify', value='true'),
    dict(dist_name=SRC_LTE_CELL_NAME, parameter='tac', value='20000'),
]

TGT_ENB_ONLINE_MODIFY_SGW_REL = [
    dict(dist_name=TGT_LTE_NAME, parameter='actERabModify', value='true'),
    dict(dist_name=TGT_LTE_CELL_NAME, parameter='tac', value='6666'),
]
