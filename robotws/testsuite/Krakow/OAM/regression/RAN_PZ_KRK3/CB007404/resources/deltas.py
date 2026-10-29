"""
:copyright: Nokia Networks
:author: Krzysztof Domino
:contact: krzysztof.domino@nokia.com
"""
from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")
mrbts = tl.gnbs[0].global_bts_id
nrbts = tl.gnbs[0].instance_id

delta_robustness_cell_grp =\
    [
        {'distName': "MRBTS-{}/NRBTS-{}/NRCELLGRP-0".format(mrbts, nrbts), 'operation': "update", 'parameters':
            [{'parameterName': "actProactUlScheduling", 'value': "true", 'operation': "update"},
             {'parameterName': "maxHarqMsg3Tx", 'value': "6", 'operation': "update"},
             {'parameterName': "maxUlHarqTx", 'value': "6", 'operation': "update"},
             {'parameterName': "ssBurstSetPeriod", 'value': "10", 'operation': "update"},
             {'parameterName': "ulSchedTimeInterval", 'value': "10", 'operation': "update"},
             {'parameterName': "maxDlHarqTx", 'value': "6", 'operation': "update"}]
         }
    ]
delta_robustness_cell =\
    [
        {'distName': "MRBTS-{}/NRBTS-{}/NRCELL-1".format(mrbts, nrbts), 'operation': "update", 'parameters':
            [
                {'parameterName': "pMax", 'value': "180", 'operation': "update"},
                {'parameterName': "ssPbchBlockPower", 'value': "10", 'operation': "update"}
            ]
         }
    ]
