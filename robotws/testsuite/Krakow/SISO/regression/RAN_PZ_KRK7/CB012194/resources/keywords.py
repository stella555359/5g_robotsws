import json
import time
from typing import Iterator, Optional, Union  # noqa: F401

from robot.libraries.BuiltIn import logger
from pprint import pformat  # noqa: F401
from ute_common_abstract_core.message import KeyFindingDict, NotFoundKey
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools import keywords


def dict_pass(in_dict):
    logger.debug(f"\n{in_dict=}")
    out = list(dict({'distName': dist_name, 'operation': 'update',
                     'parameters': [json.loads("{"+in_dict[dist_name]+"}")]}) for dist_name in in_dict)
    logger.debug(f"{out=}")
    return out


def change_multiple_parameters(timeout=300, max_attempts: int = 3, ** kwargs):
    """
    Robot usage:
    Change multiple parameters
    ...    MRBTS-${btsid}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1="parameterName": "xxxx", "value": "false", "operation": "update"
    ...    MRBTS-${btsid}/LNBTS-${btsid}="parameterName": "actExtN77Support", "value": "false", "operation": "update"
    ...    MRBTS-${btsid}/LNBTS-${btsid}/LNCEL-11="parameterName": "yyyyy", "value": "30", "operation": "update"
    """
    # timeout = 300
    params = dict_pass(kwargs)
    delta_file = json.dumps(params)
    logger.info(f"Delta json: {delta_file}")
    with keywords.use_admin_connection() as connection:
        attempt = 1
        err = None
        while attempt <= max_attempts:
            try:
                result = connection.perform_delta_recommissioning(
                    delta_file=delta_file,
                    timeout=timeout
                )
                logger.debug(f"Result of perform_delta_recommissioning {result}")
                break
            except AdminApiProcedureFailureException as err:
                if 'CPlane is busy' in repr(err):
                    logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                    logger.debug(repr(err))
                    time.sleep(20)
                    attempt += 1
                    continue
                raise err
        else:
            raise err
        logger.debug(f"Result of perform_delta_recommissioning {result}")


def check_bts_status():
    with keywords.use_admin_connection() as connection:
        logger.info(f'{connection.get_bts_info()=}')
        logger.info(f'{connection.get_cells_info(cell_type="lte")=}')
        logger.info(f'{connection.get_cells_info(cell_type="nr")=}')


def perform_parameter_recommissioning_and_verify_result(
    dist_name: str,
    parameter: str,
    operation: str,
    value: Union[str, list],
    result_key: str,
    result_val: str,
    skip_parameter_relation_errors: bool = False,
    should_activate: bool = True,
    timeout: int = 300,
    max_attempts: int = 3
):
    """Wrapper for AdminConnection `perform_parameter_recommissioning`

    Args:
        dist_name (str): Object dist name ie. "MRBTS-1/LNBTS-1/LNMME-0"
        parameter (str): Parameter name i.e. "ipAddrPrim"
        operation (str): Parameter operation (update or delete)
        value (Union[str, int]): Parameter value ie. "10.0.1.99" or [{"eea1":0, "eea0":1, "eea3":8, "eea2":0}]
        result_key (str): key in result of perform_parameter_recommissioning being verified, i.e. "resetCoverage"
        result_val (str): value of key, i.e. "['None']" or "['LteRat']" ot "['NrRat']" or "['Site']",
        skip_parameter_relation_errors (bool, optional): Skip parameter relation errors. Defaults to False.
        should_activate (bool, optional): Should automatically activate plan. Defaults to True.
        timeout (int, optional): Time to wait for positive procedure result. Defaults to 300.

        :raises taf.sbts.oam.coam.admin.legacy.exceptions.AdminApiProcedureFailureException: Will be raised if
            recommissioning fails
    """
    with keywords.use_admin_connection() as connection:
        attempt = 1
        err = None
        while attempt <= max_attempts:
            try:
                result = connection.perform_parameter_recommissioning(
                    dist_name=dist_name,
                    parameter=parameter,
                    operation=operation,
                    value=value,
                    skip_parameter_relation_errors=skip_parameter_relation_errors,
                    should_activate=should_activate,
                    timeout=timeout
                )
                logger.debug(f"Result of perform_parameter_recommissioning {result}")
                break
            except AdminApiProcedureFailureException as err:
                if 'CPlane is busy' in repr(err):
                    logger.warn(f"Attempt number {attempt} failed because 'CPlane is busy'. Wait 20s and try again...")
                    logger.debug(repr(err))
                    time.sleep(20)
                    attempt += 1
                    continue
                raise err
        else:
            raise err
    actual_value = str(KeyFindingDict.get_value_by_unique_key(result, result_key))
    logger.info(f"Required value ({result_val}) of {result_key} is ({actual_value})")
    if actual_value != result_val:
        raise ValueError(f"Actual value ({actual_value}) of {result_key} is not as expected ({result_val})")


def prepare_parameters_delta(distname: str, parameter: str, value: str, operation="update", delta=None, json_out=False):
    """
    """
    if not delta:
        delta = []
    delta.append(
        {
            "distName": distname,
            "operation": operation,
            "parameters": [
                {
                    "parameterName": parameter,
                    "value": value,
                    "operation": operation
                }
            ]
        }
    )
    if json_out:
        delta = json.dumps(delta)
    return delta


def log_alarms(also_console=False):
    with keywords.use_admin_connection() as connection:
        alarms = connection.get_active_alarms()
    logger.write(pformat(alarms), level='DEBUG')
    logger.info("Alarm brief", also_console=also_console)
    for alarm in alarms:
        logger.info(f"*AlarmId: {alarm['alarmId']}; alarmName: {alarm['alarmName']}\n"
                    + f" |-FaultId: {alarm['additionalFaultID']}; faultName: {alarm['faultName']}\n"
                    + f" |-Object: {alarm['alarmingObjectIds'][0]['configuration']}",
                      also_console=also_console)
