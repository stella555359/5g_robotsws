"""
Deltas to handle tests for configuration features.
author: Magda Chrostek
email: magda.chrostek@nokia.com
"""

from taf.rfrl.utilities.robot.general import get_builtin_value

tl = get_builtin_value(param_name="tl")
mrbts = tl.gnbs[0].global_bts_id
nrbts = tl.gnbs[0].instance_id

delta_lte4_prachConfig = \
    [
        {'distName': "MRBTS-{}/LNBTS-{}/LNCEL-4/LNCEL_FDD-0".format(mrbts, nrbts), 'operation': "update", 'parameters':
            [{'parameterName': "prachConfIndex", 'value': "19", 'operation': "update"},
             ]
         }
    ]

delta_lte4_prachConfig_backup = \
    [
        {'distName': "MRBTS-{}/LNBTS-{}/LNCEL-4/LNCEL_FDD-0".format(mrbts, nrbts), 'operation': "update", 'parameters':
            [{'parameterName': "prachConfIndex", 'value': "3", 'operation': "update"},
             ]
         }
    ]


delta_lte14_prachConfig = \
    [
        {'distName': "MRBTS-{}/LNBTS-{}/LNCEL-14/LNCEL_FDD-0".format(mrbts, nrbts), 'operation': "update", 'parameters':
            [{'parameterName': "prachConfIndex", 'value': "19", 'operation': "update"},
             ]
         }
    ]

delta_lte14_prachConfig_backup = \
    [
        {'distName': "MRBTS-{}/LNBTS-{}/LNCEL-14/LNCEL_FDD-0".format(mrbts, nrbts), 'operation': "update", 'parameters':
            [{'parameterName': "prachConfIndex", 'value': "3", 'operation': "update"},
             ]
         }
    ]
