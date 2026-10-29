"""
Delta file for test case FR_CB008661.

:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

from taf.rfrl.utilities.robot.general import get_builtin_value


_tl = get_builtin_value(param_name="tl")
_CELL_PATH = f'MRBTS-{_tl.gnbs[0].instance_id}/NRBTS-{_tl.gnbs[0].instance_id}/NRCELL-1'

DELTA_RESET = [{"distName": _CELL_PATH,
                "operation": "update",
                "parameters": [{"parameterName": "ssPbchBlockPower",
                                "value": "-11",
                                "operation": "update"}]}]

DELTA_TEARDOWN = [{"distName": _CELL_PATH,
                   "operation": "update",
                   "parameters": [{"parameterName": "ssPbchBlockPower",
                                   "value": "-40",
                                   "operation": "update"}]}]
