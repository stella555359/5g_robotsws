import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# #gnb###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].dus[0].global_bts_id)
GNB_CELL_NAME = GNB_NR_BTS_NAME + '/NRCELL-'
GNB_NRDRB_NAME = GNB_NR_BTS_NAME + '/NRDRB-'
GNB_APEQM_NAME = GNB_BTS_NAME + '/EQM-1/APEQM-1'

SFP_Operator_Mode_True = [dict(distName=GNB_APEQM_NAME, parameters=[{'parameterName': 'sfpOperatorMode',
                                                                     'value': 'true', 'operation': 'update'}],
                               operation='update')]

SFP_Operator_Mode_False = [dict(distName=GNB_APEQM_NAME, parameters=[{'parameterName': 'sfpOperatorMode',
                                                                     'value': 'false', 'operation': 'update'}],
                                operation='update')]
