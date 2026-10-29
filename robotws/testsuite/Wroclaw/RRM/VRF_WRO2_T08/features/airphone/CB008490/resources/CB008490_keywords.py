import xml.etree.ElementTree as ET
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn
from ta5g_ue_measurements import ta5g_ue_measurements
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.sbts.oam.coam.admin import admin

from test_variables import xn_link_sn_alarms

_api = admin()
_meas = ta5g_ue_measurements()

QCID = {
    "SBTS00": {
        "CB008490_GA_B201_Activation_Of_Multiple_NR-DC-SN_And_NSA_Cells_Configured_At_gNB_Startup_And_"
        "Dynamically_Added_Multiple": "QC_44325",
        "CB008490_GB_101_Dynamic_Addition_Of_NR-DC-SN_Cells_After_Xn_Link_Establishment": "QC_44329",
        "CB008490-GG_B301_Dynamic_Addition_Of_NR-DC-SN_Cells_With_Multiple_Slices_And_Tas_Without_RAN_Sharing_"
        "Enabled": "QC_44330",
    },
    "SBTS26R1": {
        "CB008490_GA_B201_Activation_Of_Multiple_NR-DC-SN_And_NSA_Cells_Configured_At_gNB_Startup_And_"
        "Dynamically_Added_Multiple": "QC_258352",
        "CB008490_GB_101_Dynamic_Addition_Of_NR-DC-SN_Cells_After_Xn_Link_Establishment": "QC_258353",
        "CB008490-GG_B301_Dynamic_Addition_Of_NR-DC-SN_Cells_With_Multiple_Slices_And_Tas_Without_RAN_Sharing_"
        "Enabled": "QC_258355",
    }
}


def verify_snssai_operational_status(remote_host: str, which_dict: str) -> None:
    """Verify if SNSSAI status is set correctly
    :param: remote_host (str) - remote machine's IP
    :param: which_dict (str) - scf file path
    :raises: AssertionError - when SNSSAI state is incorrect
    """
    operational_states = {
        "before": {"enabled": [1, 2, 4, 5, 7, 8], "disabled": [3, 6]},
        "after": {"enabled": [1, 2, 4, 5], "disabled": [3, 6, 7, 8]}
    }
    try:
        _api.setup_admin(remote_host=remote_host)
        for snssai in _api.get_parameter_by_class("SNSSAI", ["operationalState"]):
            assert int(snssai['distName'][-1]) in \
                   operational_states[which_dict][snssai['parameters']['operationalState']]
    finally:
        _api.teardown_admin()


def get_testlines_ip() -> list[str]:
    """Get IP of testline's VMs
    :returns: (list[str]) - list with VM IPs
    """
    testline = BuiltIn().get_variable_value('${tl}')
    testline_ips = [test_pc.default_ssh_connection_details.addr for test_pc in testline.test_pcs]
    return testline_ips


def set_correct_trace_collector_ip_in_scf(*scfs: str) -> None:
    """Change trace collector IP in scf to VM IP
    :param: scfs (str) - scf file path
    """
    ips = get_testlines_ip()
    for i, scf in enumerate(scfs):
        ET.register_namespace('', "raml21.xsd")
        tree = ET.parse(scf)
        root = tree.getroot()
        tceip = root[0].find("./{raml21.xsd}managedObject[@class='com.nokia.srbts.mnl:TCE']/*[@name='tceIpAddress']")
        tceip.text = ips[i]
        tree.write(scf)


def get_active_alarms_from_node(mplane: str) -> list[dict]:
    """
    Retrieves active alarms from a given node.

    :param mplane: The mPlane address.
    :type mplane: str
    :return: A list of dictionaries representing the active alarms.
    :rtype: list[dict]
    """
    try:
        _api.setup_admin(bts_host=mplane)
        return _api.get_active_alarms(timeout=30)
    finally:
        _api.teardown_admin()


def verify_alarms(mplane: str, expected_alarms: list[tuple] = xn_link_sn_alarms) -> None:
    """
        Retrieves active alarms from a given node.

        :param mplane: The mPlane address.
        :type mplane: str
        :param expected_alarms: expected_alarms.
        :type expected_alarms: list[tuple]
        :return: A list of dictionaries representing the active alarms.
        :rtype: list[dict]
        """
    inactive_alarms = []
    active_alarms = get_active_alarms_from_node(mplane)
    for fault_id, object_distname in expected_alarms:
        alarm_found = False
        for alarm in active_alarms:
            if alarm.get("faultId") == int(fault_id):
                for alarm_object in alarm.get("alarmingObjectIds", []):
                    if alarm_object.get("configuration") == object_distname:
                        alarm_found = True
                        break
            if alarm_found:
                break
        if not alarm_found:
            inactive_alarms.append((fault_id, object_distname))
    assert not inactive_alarms, f"Inactive alarms: {inactive_alarms}\n"


def send_a4_measurement():
    try:
        _meas.send_ue_measurement_nr_event_A4_with_aligned_meas_id(ue_id=8, carrier_freq=2071387, phycell_id=52,
                                                                   nrsrp_nr=60)
    except Exception:
        _meas.send_ue_measurement_nr_event_A4_with_aligned_meas_id(ue_id=8, trigger_type='RSRQ', carrier_freq=2071387,
                                                                   phycell_id=52, nrsrp_nr=60)


def _get_branch(target_sw=None):
    """
    Determines the branch based on the software version.

    :param str target_sw: The target software version. If not provided, the current
        software version is retrieved using the `admin` module. Defaults to None.
    :return: The branch name.
    :rtype: str
    """
    if not target_sw:
        try:
            _api.setup_admin()
            sw_version = _api.get_sw_version()
        finally:
            _api.teardown_admin()
    else:
        sw_version = target_sw
    if any(trunk_indicator in sw_version for trunk_indicator in ["9999", "9990"]):
        return 'SBTS00'
    return sw_version.split("_")[0]


def set_test_id(target_sw=None):
    """
    Determines and sets the test ID based on the branch and test name.

    :param str target_sw: The target software version. If not provided, the current
        software version is retrieved using the `admin` module. Defaults to None.
    :return: The test ID if found, otherwise None.
    :rtype: str
    """
    branch = _get_branch(target_sw)
    test_id = QCID.get(branch).get(robot_var("TEST_NAME"))
    log_info_to_console(f"Selected Test id {test_id} for {robot_var('TEST_NAME')} and release {branch}")
    return test_id


def robot_var(variable_name, default_value=None):
    return BuiltIn().get_variable_value(f"${{{variable_name}}}", default_value)
