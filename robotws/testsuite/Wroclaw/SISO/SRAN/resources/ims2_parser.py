"""
:modified:08.01.2024

:author: Daniel Bartkowiak
:maintainer: Daniel Bartkowiak
:contact: daniel.bartkowiak@nokia.com

Library provides few functions to filter out information from ims2 log.
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
    Finds reset event in provided ims2 log.

    Args:
        file_path (str): path to ims2 log.

    Returns:
        int: Number of resets found in ims2 log.
    """
    count = 0
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ResetLogEntry):
            count += 1
    return count


@keyword(name='Find Parameter Change')
def find_parameter_change(file_path, dist_name, parameter, value=None, times=None):
    """
    KW Find Parameter Change can be used only in case of state management parameters
    or other parameters directly under "dist_name".
    If "value" not provided KW checks any change under "parameter" - "times" is not used
    If "value" provided, "times" can be used to check number of "value" occurrences
    Regex patterns can be used in "value"
    "times" set by default executes checking if "value" found at least one time

    ***NOTE*** Nested "parameter" is not supported
    ***NOTE*** availabilityStatus gets "-" when object is On Air

    Args:
        file_path (str): path to ims2 log.
        dist_name (str): IM object
        parameter (str): parameter name
        value     (str, optional): value to find, default is None
        times	  (int, optional): number of occurrence, default is None

    Example:
    Find Parameter Change  /home/ute/Downloads/test.ims2  ${ims_object_path}  availabilityStatus
    Find Parameter Change  /home/ute/Downloads/test.ims2  ${ims_object_path}  proceduralState  Regex"Resetting"  1

    """
    paramList = []
    if value:
        value = value.replace('Regex"', '').split('"')[0]
    for log_entry in Ims2LogReader.from_file(file_path=file_path, decode_special_characters=True):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for obj_name, val in log_entry.updates.items():
                if dist_name == obj_name and ("stateInfo" in val.keys()):
                    if parameter == "availabilityStatus" and parameter not in val['stateInfo'].keys():
                        paramList.append("-")
                    else:
                        paramList.append(val["stateInfo"][parameter])
                elif dist_name == obj_name and ("stateInfo" not in val.keys()):
                    if parameter == "availabilityStatus" and parameter not in val.keys():
                        paramList.append("-")
                    else:
                        paramList.append(val[parameter])
    filtered_list = [item for index, item in enumerate(paramList[1:]) if item != paramList[index]]
    filtered_list.insert(0, paramList[0])
    print("Raw {param} history from ims: {list}".format(param=parameter, list=paramList))
    print("Raw {param} history from ims with filtered out adjacent duplicates: {filter}".format(param=parameter,
                                                                                                filter=filtered_list))
    print("Regex pattern to search: {reg}".format(reg=value))
    if (value is None) and (filtered_list.count(filtered_list[0]) == len(filtered_list)):
        raise Exception("No change found in {param}".format(param=parameter))
    if value is not None:
        repetition = len(re.findall(value, '|'.join(filtered_list)))
        if times is not None:
            if repetition != int(times):
                raise Exception("{param} changed {rep} times".format(param=parameter, rep=repetition))
        else:
            if repetition == 0:
                raise Exception("{v} not found in {param}".format(v=value, param=parameter))


@keyword(name='Find Parameter Transition')
def find_parameter_transition(file_path, dist_name, parameter, transition, times=None):
    """
    KW can be used only in case of state management parameters or other parameters directly under "dist_name".
    Regex patterns can be used in "transition"
    Transition syntax is "enabled->disabled" and means that transition between two adjacent values is searched.
    "times" by default is checking if "transition" found at least one time

    ***NOTE*** Nested "parameter" is not supported
    ***NOTE*** availabilityStatus gets "-" when object is On Air

    Args:
        file_path (str): path to ims2 log.
        dist_name (str): IM object
        parameter (str): parameter name
        transition (str): transition pattern
        times	  (int, optional): number of occurrence, default is None

    Example:
    Find Parameter Transition  /home/ute/Arch/tmp.ims2  ${ims_object_path}  availabilityStatus  Regex"-->off.*?line"
    Find Parameter Transition  /home/ute/Downloads/test.ims2  ${ims_object_path}  operationalState  enabled->disabled

    """
    paramList = []
    transition = transition.replace('Regex"', '').split('"')[0]
    for log_entry in Ims2LogReader.from_file(file_path=file_path):
        if isinstance(log_entry, Ims2ChangesetLogEntry):
            for obj_name, val in log_entry.updates.items():
                if dist_name == obj_name and ("stateInfo" in val.keys()):
                    if parameter == "availabilityStatus" and parameter not in val['stateInfo'].keys():
                        paramList.append("-")
                    else:
                        paramList.append(val["stateInfo"][parameter])
                elif dist_name == obj_name and ("stateInfo" not in val.keys()):
                    if parameter == "availabilityStatus" and parameter not in val.keys():
                        paramList.append("-")
                    else:
                        paramList.append(val[parameter])
    print("Raw {param} history from ims: {list}".format(param=parameter, list=['->'.join(paramList)]))
    print("Regex pattern to search: {reg}".format(reg=transition))
    transition_count = len(re.findall(transition, '->'.join(paramList)))
    if times is not None:
        if transition_count != int(times):
            raise Exception("Transition {t} found {rep} times".format(t=transition, rep=transition_count))
    else:
        if transition_count == 0:
            raise Exception("Transition {t} not found in {param}".format(t=transition, param=parameter))

# Block for dev testing:
# ims_path='/home/ute/Downloads/reset_lte.ims2'
# ims_path='/home/ute/Downloads/reset_lte_no_cni.ims2'
# dist_name='/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1306/LNCEL_R-29606'
# find_parameter_change(ims_path, dist_name, "availabilityStatus")
# find_parameter_change(ims_path, dist_name, "OP", "Active")
