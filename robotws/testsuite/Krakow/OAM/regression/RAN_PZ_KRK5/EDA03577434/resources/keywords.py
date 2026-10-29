# from testsuite.Krakow.OAM.regression.RAN_PZ_KRK7.resources import keywords
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from robot.libraries.BuiltIn import BuiltIn, logger
from typing import Iterator, Optional
from taf.sbts.oam.coam.admin.facade import AdminConnection
from contextlib import contextmanager
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.bts.devices.du.cell_operations import GenericCellOperations


def change_alarm_trigger_flag(value: str):
    mrbts_id = get_mrbts_id()
    inUse_param_dist_name = f"MRBTS-{mrbts_id}/EQM-1/APEQM-1/CABINET-1/SMOD-1/EAC_IN-1"
    with use_admin_connection() as connection:
        eac_in_objects = connection.get_managed_objects("EAC_IN_A", timeout=30)
        if eac_in_objects:
            inUse_param_value = eac_in_objects[0]['parameters']['inUse']
            if inUse_param_value != value:
                connection.perform_parameter_recommissioning(dist_name=inUse_param_dist_name,
                                                             parameter="inUse",
                                                             operation="update",
                                                             value=value)
        else:
            _create_smod_eac_in_object(connection, value, inUse_param_dist_name)


def get_mrbts_id() -> int:
    """Returns global_bts_id fetched from __init__.py file.

    :return int:
    """
    bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[0]
    return bts_instance.global_bts_id


@contextmanager
def use_admin_connection() -> Iterator[AdminConnection]:
    """Context manager for automatically connecting and disconnecting via AdminConnection.

    :return AdminConnection:
    :yield Iterator[AdminConnection]:
    """
    bts_instance = BuiltIn().get_variable_value("${{{}}}".format("tl"), None).gnbs[0]
    bts_host = bts_instance.oam_ip.v4.split("/")[0]
    api = admin()
    try:
        connection = api.connect_to(bts_host=bts_host)
        yield connection
    finally:
        api.teardown_admin(connection=connection)  # TODO: check recommended way of closing connection


def _create_smod_eac_in_object(connection, inUse_value: str, dist_name: str):
    parameters = [
        {
            "parameterName": "cancelDelay",
            "operation": "update",
            "value": 0
        },
        {
            "parameterName": "descr",
            "operation": "update",
            "value": "Critical alarm for SMOD object"
        },
        {
            "parameterName": "eacInId",
            "operation": "update",
            "value": 1
        },
        {
            "parameterName": "inUse",
            "operation": "update",
            "value": inUse_value
        },
        {
            "parameterName": "polarity",
            "operation": "update",
            "value": "Normally_closed"
        },
        {
            "parameterName": "portId",
            "operation": "update",
            "value": 11
        },
        {
            "parameterName": "severity",
            "operation": "update",
            "value": "Critical"
        },
        {
            "parameterName": "startDelay",
            "operation": "update",
            "value": 0
        }
    ]
    connection.perform_object_recommissioning(dist_name=dist_name,
                                              parameter=parameters,
                                              operation="create")


def check_critical_alarm(faul_id: int, fault_name: str):
    with use_admin_connection() as connection:
        critical_alarm_list = connection.get_active_alarms(severity="critical")
        critical_alarm = [alarm for alarm in critical_alarm_list if alarm['faultId'] == faul_id and
                          alarm['faultName'] == fault_name]
        if not critical_alarm:
            raise Exception(f"There is no \"{fault_name}\" alarm")


def check_if_site_is_onair():
    GnbDuOperations().wait_for_site_to_be_onair(interval=20)
    GenericCellOperations().wait_for_all_cells_to_be_onair()


def perform_multiple_rest_and_check_critical_alarm(amount: int, faul_id: int, fault_name: str):
    for n in range(amount):
        with use_admin_connection() as connection:
            connection.reset_site()
        check_if_site_is_onair()
        check_critical_alarm(faul_id, fault_name)
        logger.console(f"Reset: {n + 1}")
