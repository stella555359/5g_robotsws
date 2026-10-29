import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# #gnb###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].dus[0].instance_id)
GNB_RMOD_NAME = GNB_BTS_NAME + '/EQM-1/APEQM-1/RMOD-1'
GNB_FMCADM_NAME = GNB_BTS_NAME + '/MNL-1/MNLENT-1/FMCADM-1'

disableac_para = [dict(distName=GNB_FMCADM_NAME,
                       parameters=[{'parameterName': 'actRadioFanFailureEarlyNotif', 'value': 'false',
                                    'operation': 'update'}],
                       operation='update')]

disableop_para = [dict(distName=GNB_RMOD_NAME,
                       parameters=[{'parameterName': 'optionalFansInstalled', 'value': 'false',
                                    'operation': 'update'}],
                       operation='update')]

enableac_para = [dict(distName=GNB_FMCADM_NAME,
                      parameters=[{'parameterName': 'actRadioFanFailureEarlyNotif', 'value': 'true',
                                   'operation': 'update'}],
                      operation='update')]

enableop_para = [dict(distName=GNB_RMOD_NAME,
                      parameters=[{'parameterName': 'optionalFansInstalled', 'value': 'true',
                                   'operation': 'update'}],
                      operation='update')]
