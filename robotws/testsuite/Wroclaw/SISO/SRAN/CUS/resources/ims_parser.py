"""
:modified:04.07.2022

:author: Daniel Bartkowiak
:maintainer: Daniel Bartkowiak
:contact: daniel.bartkowiak@nokia.com
"""

from robot.api.deco import keyword
from robot.api import logger
from taf.analyzer.ims2 import Ims2ChangesetLogEntry, Ims2LogReader, Ims2ResetLogEntry
import re
import warnings

warnings.filterwarnings(action="ignore", message="unclosed")

ROBOT_AUTO_KEYWORDS = False


@keyword(name='Find Reset')
def find_reset(file_path):
    """
    Find Reset

    | **Author:** daniel.bartkowiak@nokia.com
    | **Maintainers:** daniel.bartkowiak@nokia.com


    | **Full description:**

    KW finds reset event in provided ims2 log

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | file_path        | Yes  | path to ims2 log                      |
    +------------------+------+---------------------------------------+

    **Example:**

    .. code-block:: robotframework

    ${count}=  Find Reset  /home/ute/Downloads/test.ims2

    | **Return value:**
    | Integer with number of resets
    """
    count = 0
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ResetLogEntry):
            count += 1
    return count


@keyword(name='Find Parameter Change')
def find_parameter_change(file_path, dist_name, parameter, value=None, times=None):
    """
    Find Parameter Change

    | **Author:** daniel.bartkowiak@nokia.com
    | **Maintainers:** daniel.bartkowiak@nokia.com


    | **Full description:**

    KW can be used only in case of state management parmeters or other parameters directly under "dist_name".
    If "value" not provided KW checks any change under "parameter" - "times" is not used
    If "value" provided, "times" can be used to check number of "value" occurences
    Regex patterns can be used in "value"

    ***NOTE*** Nested "parameter" is not supported
    ***NOTE*** For simplicity "empty" availabilityStatus have to be declared as "online"

    **Input Parameters:**

    +------------------+------+---------------------------------------+
    | Input Parameters | Man. | Description                           |
    +==================+======+=======================================+
    | file_path        | Yes  | path to ims2 log                      |
    +------------------+------+---------------------------------------+
    | dist_name        | Yes  | IM object                             |
    +------------------+------+---------------------------------------+
    | parameter        | Yes  | parameter name                        |
    +------------------+------+---------------------------------------+
    | value            | No   | value to find                         |
    +------------------+------+---------------------------------------+
    | times            | No   | number of occurence                   |
    +------------------+------+---------------------------------------+

    **Example:**
    .. code-block:: robotframework

    Find Parameter Change  /home/ute/Downloads/test.ims2  ${ims_object_path}  availabilityStatus
    Find Parameter Change  /home/ute/Downloads/test.ims2  ${ims_object_path}  proceduralState  Regex"Resetting"  1

    | **Return value:**
    | N/A
    """
    paramList = []
    if value:
        value = value.replace('Regex"', '').split('"')[0]
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for obj_name, val in log_entry.updates.items():
                if dist_name == obj_name and ("stateInfo" in val.keys()):
                    if parameter == "availabilityStatus" and parameter not in val['stateInfo'].keys():
                        paramList.append("Online")
                    else:
                        paramList.append(val["stateInfo"][parameter])
                elif dist_name == obj_name and ("stateInfo" not in val.keys()):
                    if parameter == "availabilityStatus" and parameter not in val.keys():
                        paramList.append("Online")
                    else:
                        paramList.append(val[parameter])
    if (value is None) and (paramList.count(paramList[0]) == len(paramList)):
        raise Exception("No change found in {param}".format(param=parameter))
    if value is not None:
        repetition = len(re.findall(value, '|'.join(paramList)))
        if times is not None:
            if repetition != int(times):
                raise Exception("{param} changed {rep} times".format(param=parameter, rep=repetition))
        else:
            if repetition == 0:
                raise Exception("{v} not found in {param}".format(v=value, param=parameter))

# Block for dev testing:
# ims_path='/home/ute/Downloads/reset_lte.ims2'
# ims_path='/home/ute/Downloads/reset_lte_no_cni.ims2'
# dist_name='/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1306/LNCEL_R-29606'
# find_parameter_change(ims_path, dist_name, "availabilityStatus")
# find_parameter_change(ims_path, dist_name, "OP", "Active")
