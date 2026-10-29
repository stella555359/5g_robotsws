# -*- coding: utf-8 -*-
"""
Keywords for GNB - FSP device.


:copyright: Nokia Networks
:author: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com
:maintainer: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com

"""

__author__ = "Tomasz Krol, Agnieszka Bylica, Adam Moszczynski"
__copyright__ = "Copyright (C) 2019, Nokia"
__email__ = (
    "tomasz.krol@nokia.com, agnieszka.bylica@nokia.com, adam.1.moszczynski@nokia.com"
)

import re
import time
import copy
import testsuite.Krakow.resources.Krakow_Resources_from_Nanjing.python.common as common
from moler.util.moler_test import MolerTest
from taf.ul.sc.gnb.airscale import AirScale
from taf.ul.sc.gnb.oam.rest import Rest
from taf.ul.sc.gnb.oam.selenium import Selenium
from taf.ul.sc.unix_functionality import UnixFunctionality
from taf.ul.sc.exceptions import MegazoneFunctionalityNotSupported
from testsuite.Krakow.resources.Krakow_Resources_from_Nanjing.python.exceptions import WrongRfStatus


@MolerTest.raise_background_exceptions(check_steps_end=True)
def verify_cpri_link_status(required_status, ip_addr=None):
    """
    Verify if CPRI link status is equal to given required status.

    :param required_status: Synced, Loss Of Signal, Loss Of Frame, Undefined
    :param ip_addr: IP address of gNB
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip

    MolerTest.info("Checking CPRI link status...")
    status = AirScale(autoconnect=True, oam_ip=ip_addr).get_cpri_link_status()

    if status == "0x00000010":
        status_name = "Synced"
    elif status == "0x00000003":
        status_name = "Loss Of Signal"
    elif status == "0x00000002":
        status_name = "Loss Of Frame"
    else:
        status_name = "Undefined"

    if status_name == required_status:
        MolerTest.info(
            "CPRI status is equal to required status {}".format(required_status)
        )
    else:
        MolerTest.error(
            "CPRI status is different from required status: {} != {}".format(
                status_name, required_status
            )
        )

    MolerTest.steps_end()


@MolerTest.raise_background_exceptions()
def check_if_container_is_up(name, ip_addr=None):
    """
    Check if the container is up.

    :param name: container name.
    :param ip_addr: IP address of gNB
    :return: Nothing.
    """
    if ip_addr is None:
        ip_addr = common.ip

    if AirScale(autoconnect=True, oam_ip=ip_addr).get_asir_container_status(name):
        MolerTest.info("Container {} is up.".format(name))
    else:
        MolerTest.error("Container {} is down.".format(name))


@MolerTest.raise_background_exceptions()
def wait_for_container_to_get_up(name, step=20.0, timeout=330.0, ip_addr=None):
    """
    Check if the container is up every step seconds until the container gets up or timeout time expires.

    :param name: container name.
    :param step: time in seconds between checks.
    :param timeout: max time function checks if the container is up.
    :param ip_addr: IP address of gNB
    :return: Nothing.
    """
    if ip_addr is None:
        ip_addr = common.ip

    start_time = time.time()

    while time.time() - start_time < timeout:
        if AirScale(autoconnect=True, oam_ip=ip_addr).get_asir_container_status(name):
            MolerTest.info("Container {} is up.".format(name))
            return
        MolerTest.sleep(step)
        MolerTest.info("Rechecking...")

    MolerTest.error("Container {} is down.".format(name))


@MolerTest.raise_background_exceptions()
def check_active_alarms_on_gnb(
    allowed_alarms=[], required_alarms=[], ip_addr=None
):
    """
    Check if there are active alarms not allowed on the AirScale.

    :param allowed_alarms: list of alarms (numbers) that do not cause error
    :param required_alarms: list of alarms (numbers) that have to be present
    :param ip_addr: IP address of gNB
    :return: nothing
    """

    if ip_addr is None:
        ip_addr = common.ip

    MolerTest.info("Checking active alarms on AirScale...")

    active_alarm_numbers = Rest(oam_ip=ip_addr).get_active_alarms_numbers()
    _allowed_alarms = copy.deepcopy(allowed_alarms)
    _allowed_alarms.extend(required_alarms)
    _allowed_alarms = list(set(_allowed_alarms))
    not_allowed_alarms = [
        alarm for alarm in active_alarm_numbers if alarm not in _allowed_alarms
    ]
    absent_required_alarms = [
        alarm for alarm in required_alarms if alarm not in active_alarm_numbers
    ]

    if absent_required_alarms:
        MolerTest.error(
            msg="Some required alarms are not on the AirScale: {}".format(
                ", ".join(map(str, absent_required_alarms))
            )
        )
    elif required_alarms:
        MolerTest.info(
            "All required alarms are on the AirScale: {}".format(
                ", ".join(map(str, required_alarms))
            )
        )

    if not_allowed_alarms:
        MolerTest.error(
            msg="There are not allowed alarms on the AirScale: {}".format(
                ", ".join(map(str, not_allowed_alarms))
            )
        )
    else:
        MolerTest.info(
            "No or only allowed alarms present: ".format(
                ", ".join(map(str, active_alarm_numbers))
            )
        )
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions()
def set_actasi_to_true_if_false(
    scf_dir="/tmp/",
    current_scf_name="Current_SCF.xml",
    container_name="0xe019",
    ip_addr=None,
):
    """
    Set actAsi parameter value to true if false

    :param scf_dir: path to current and modify scf file
    :param current_scf_name: name of current scf file
    :param container_name: actAsi container name
    :param ip_addr: IP address of gNB
    :return: nothing
    """
    if ip_addr is None:
        ip_addr = common.ip

    unix_local = UnixFunctionality(device_name="UnixLocal", autoconnect=True)
    unix_local.make_directory(path=scf_dir)
    airscale = AirScale(autoconnect=True, oam_ip=ip_addr)

    if not airscale.get_actasi_status(
        scf_dir=scf_dir, current_scf_name=current_scf_name
    ):
        MolerTest.info("Value of actAsi is False. Setting actAsi to True...")

        airscale.set_actasi_to_true(scf_dir, current_scf_name)
        Rest(oam_ip=ip_addr).reset_and_wait_for_site()
        wait_for_container_to_get_up(container_name)


def check_rf_status(raise_error=True, ip_addr=None):
    """
    Check Frm statuses: availabilityStatus, operationalState, proceduralStatus.

    :param raise_error: if True raise exception when rf status is wrong
    :param ip_addr: IP address of gNB
    :return: True if all statuses are correct, False otherwise
    """
    if ip_addr is None:
        ip_addr = common.ip

    frm_dict = Rest(oam_ip=ip_addr).get_radio_module_info(attribute="status")
    try:
        frm_dict["availabilityStatus"] = (
            "online"
            if "availabilityStatus" not in frm_dict
            or frm_dict["availabilityStatus"] == ""
            else frm_dict["availabilityStatus"].replace(" ", "").lower()
        )
        _verify_frm_status(frm_dict)
        return True
    except WrongRfStatus as exc:
        if not raise_error:
            MolerTest.info(str(exc))
            return False
        else:
            raise exc


def check_rf_availability_status(ip_addr=None):
    """
    Check if Frm availability is different than offline.

    :param ip_addr: IP address of gNB
    :return: nothing
    """
    if ip_addr is None:
        ip_addr = common.ip

    radio_status = Rest(oam_ip=ip_addr).get_radio_module_availability_status()
    if re.match(r"offline", radio_status, re.I):
        raise WrongRfStatus("Radio is offline")
    else:
        MolerTest.info("Radio is {}".format(radio_status))


def _verify_frm_status(frm_dict):
    _check_status(frm_dict, "availabilityStatus", "online")
    _check_status(frm_dict, "operationalState", "enabled")
    _check_status(frm_dict, "proceduralStatus", "configured")


def _check_status(status_dict, parameter, expected_status):
    try:
        status = status_dict[parameter]
        if re.match(expected_status, status, re.I):
            MolerTest.info("{} is {}".format(parameter, expected_status))
        else:
            raise WrongRfStatus(
                "{} is not {} but {}".format(parameter, expected_status, status)
            )
    except KeyError:
        raise WrongRfStatus("There is no such status as {}".format(parameter))


@MolerTest.raise_background_exceptions()
def compare_software_version_before_upgrade(planned_software, ip_addr=None):
    """
    Check that planed swupgrade version is different that actual

    :param ip_addr: IP address of gNB
    :return: nothing
    """

    if ip_addr is None:
        ip_addr = common.ip

    if Rest(oam_ip=ip_addr).get_sw_version() != planned_software:
        MolerTest.info("Planned software version is different that active")
    else:
        MolerTest.error("Planned software version is equal that active")


@MolerTest.raise_background_exceptions()
def compare_software_version_after_upgrade(planned_software, ip_addr=None):
    """
    Check that software version after swupgrade is equal like planed

    :param ip_addr: IP address of gNB
    :return: nothing
    """
    if ip_addr is None:
        ip_addr = common.ip

    if Rest(oam_ip=ip_addr).get_sw_version() == planned_software:
        MolerTest.info("Active version is equal planned version after sw upgrade")
    else:
        MolerTest.error("Active version is not equal planned version after sw upgrade")


def gnb_software_upgrade_via_webui(file_path, ip_addr=None):
    """
    Upgrade gNB software using webui.

    :param ip_addr: IP address of gNB
    :param file_path: path to file with software
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip

    s = Selenium()
    s.enable_virtual_display_via_selenium()
    s.login_via_selenium()
    try:
        s.disable_screen_lock_via_selenium()
    except MegazoneFunctionalityNotSupported:
        pass
    s.add_software_file_via_selenium(file_path)
    s.start_update_software_via_selenium()
    wait_for_reload_modal_appearance(timeout=1000)
    s.disable_virtual_display_via_selenium()


@MolerTest.raise_background_exceptions()
def check_if_gnb_is_onair(dist_name=None, ip_addr=None):
    """
    Check if gNB operationalStatus is onAir.

    :param ip_addr: IP address of gNB
    :param dist_name: parameter group name where operationalState can be found
    :return: True if gNB is onAir, False otherwise
    """
    if ip_addr is None:
        ip_addr = common.ip

    import requests

    try:
        if not dist_name:
            oam_obj = Rest(oam_ip=ip_addr)
            dist_name = "MRBTS-{}/NRBTS-{}".format(oam_obj.mrbts_id, oam_obj.nrbts_id)

        operational_state = Rest(oam_ip=ip_addr).get_operational_state(dist_name)

        return re.match(r"onAir", operational_state, re.I)
    except requests.exceptions.ConnectTimeout as e:
        MolerTest.error(
            "There is an requests exception in check_if_gnb_is_onair: {}".format(
                repr(e)
            )
        )


@MolerTest.raise_background_exceptions()
def wait_for_onair(
    dist_name=None, timeout=930, interval=30, raise_error=True, ip_addr=None
):
    """
    Wait until gNB gets on air or timeout expire.

    :param dist_name: parameter group name where operationalState can be found
    :param timeout: time in seconds, after timeout expires an exception is raised
    :param interval: time between checks of operationalState
    :param raise_error: True if moler error should be raised when gNB is not onAir, False otherwise
    :param ip_addr: IP address of gNB
    :return: None
    """
    start_time = time.time()
    dif_time = time.time() - start_time
    MolerTest.info("timeout: {}".format(timeout))

    while int(dif_time) <= int(timeout):
        dif_time = time.time() - start_time
        MolerTest.info("time.time(): {}".format(time.time()))
        MolerTest.info("dif time: {}".format(int(dif_time)))
        if int(dif_time) > int(timeout):
            MolerTest.info("check timeout, break")
            break
        if check_if_gnb_is_onair(dist_name):
            MolerTest.info("gNB is on air")
            return True
        else:
            MolerTest.sleep(interval)

    if raise_error:
        MolerTest.error("gNB is not on air")
    return False


@MolerTest.raise_background_exceptions()
def check_only_one_reset_occurred(ip_addr=None):
    """
    Check if only one reset occurred and it was caused by BTS Element Manager.

    :param ip_addr: IP address of gNB
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip

    airscale = AirScale(autoconnect=True, oam_ip=ip_addr)
    reset_reason = airscale.get_reset_reason()
    if "WARM (software): 0x00000001" not in reset_reason:
        MolerTest.error("Reset was not caused by BTS Element Manager")
    else:
        MolerTest.info("Reset was caused by BTS Element Manager")

    reset_counter = airscale.get_reset_counter()
    if reset_counter != 1:
        MolerTest.error("More than one reset occurred: {}".format(reset_counter))
    else:
        MolerTest.info("Only one reset occurred")


@MolerTest.raise_background_exceptions()
def check_only_one_reset_occurred_by_coam(ip_addr=None):
    """
    Check if only one reset occurred and it was caused by BTS Element Manager.
    Method modified due to release changes.

    :param ip_addr: IP address of gNB
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip

    airscale = AirScale(autoconnect=True, oam_ip=ip_addr)
    reset_reason = airscale.get_reset_reason()
    if "WARM (software and specific): 0x01000001" not in reset_reason:
        MolerTest.error("Reset was not caused by BTS Element Manager")
    else:
        MolerTest.info("Reset was caused by BTS Element Manager")

    reset_counter = airscale.get_reset_counter()
    if reset_counter != 1:
        MolerTest.error("More than one reset occurred: {}".format(reset_counter))
    else:
        MolerTest.info("Only one reset occurred")


@MolerTest.raise_background_exceptions()
def unlocked_cells_status_verification(cell_number=1, ip_addr=None):
    """
    Check cell status is unlocked.

    :param cell_number: the cell id, num 1 to 8 can be used, default set to 1.
    :param ip_addr: IP address of gNB
    :return: Nothing. Raise moler error.
    """
    if ip_addr is None:
        ip_addr = common.ip

    cell_status = Rest(oam_ip=ip_addr).get_cell_specific_info(cell_number=cell_number)
    if "status" in cell_status:
        cell_status = cell_status["status"]
        cell_status["availabilityStatus"] = (
            "online"
            if "availabilityStatus" not in cell_status
            or cell_status["availabilityStatus"] == ""
            else cell_status["availabilityStatus"].replace(" ", "").lower()
        )

    if (
        not re.match(r"online", cell_status["availabilityStatus"], re.I)
        or not re.match(r"enabled", cell_status["operationalState"], re.I)
        or not re.match(r"configured", cell_status["proceduralStatus"], re.I)
        or not re.match(r"unlocked", cell_status["administrativeState"], re.I)
    ):
        MolerTest.error("Cells states is not as expected. '{}'".format(cell_status))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions()
def unlocked_cells_status_verification_sbts(cell_number=1, ip_addr=None):
    """
    Check cell status is unlocked.

    :param cell_number: the cell id, num 1 to 8 can be used, default set to 1.
    :param ip_addr: IP address of gNB
    :return: Nothing. Raise moler error.
    """
    if ip_addr is None:
        ip_addr = common.ip

    cell_status = Rest(oam_ip=ip_addr).get_cell_specific_info(cell_number=cell_number)
    if "status" in cell_status:
        cell_status = cell_status["status"]
        cell_status["availabilityStatus"] = (
            "online"
            if "availabilityStatus" not in cell_status
            or cell_status["availabilityStatus"] == ""
            else cell_status["availabilityStatus"].replace(" ", "").lower()
        )

    if (
        not re.match(r"online", cell_status["availabilityStatus"], re.I)
        or not re.match(r"enabled", cell_status["operationalState"], re.I)
        or not re.match(r"configured", cell_status["proceduralStatus"], re.I)
        or not re.match(r"Unblocked", cell_status["blockingState"], re.I)
    ):
        MolerTest.error("Cells states is not as expected. '{}'".format(cell_status))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def locked_cells_status_verification(cell_number=1, ip_addr=None):
    """
    Check cell status is locked.

    :param cell_number: the cell id, num 1 to 8 can be used, default set to 1.
    :param ip_addr: IP address of gNB
    :return: Nothing. Raise moler error.
    """
    if ip_addr is None:
        ip_addr = common.ip

    cell_status = Rest(oam_ip=ip_addr).get_cell_specific_info(cell_number=cell_number)
    if "status" in cell_status:
        cell_status = cell_status["status"]
        cell_status["availabilityStatus"] = (
            "online"
            if "availabilityStatus" not in cell_status
            or cell_status["availabilityStatus"] == ""
            else cell_status["availabilityStatus"].replace(" ", "").lower()
        )
    if (
        not re.match(r"offline", cell_status["availabilityStatus"], re.I)
        or not re.match(r"disabled", cell_status["operationalState"], re.I)
        or not re.match(
            r"initialization(\s)*Required", cell_status["proceduralStatus"], re.I
        )
        or not re.match(r"locked", cell_status["administrativeState"], re.I)
    ):
        MolerTest.error("Cells states is not as expected. '{}'".format(cell_status))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def locked_cells_status_verification_sbts(cell_number=1, ip_addr=None):
    """
    Check cell status is locked.

    :param cell_number: the cell id, num 1 to 8 can be used, default set to 1.
    :param ip_addr: IP address of gNB
    :return: Nothing. Raise moler error.
    """
    if ip_addr is None:
        ip_addr = common.ip

    cell_status = Rest(oam_ip=ip_addr).get_cell_specific_info(cell_number=cell_number)
    if "status" in cell_status:
        cell_status = cell_status["status"]
        cell_status["availabilityStatus"] = (
            "online"
            if "availabilityStatus" not in cell_status
            or cell_status["availabilityStatus"] == ""
            else cell_status["availabilityStatus"].replace(" ", "").lower()
        )
    if (
        not re.match(r"offline", cell_status["availabilityStatus"], re.I)
        or not re.match(r"disabled", cell_status["operationalState"], re.I)
        or not re.match(r"configured", cell_status["proceduralStatus"], re.I)
        or not re.match(r"blocked", cell_status["blockingState"], re.I)
    ):
        MolerTest.error("Cells states is not as expected. '{}'".format(cell_status))
    MolerTest.steps_end()


@MolerTest.raise_background_exceptions()
def kill_process_on_AsiController(ps_name, ip_addr=None):
    """
    Execute kill on specific linux process
    :param ps_name: string with name of the process
    :param ip_addr: IP address of gNB
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip

    gnb = AirScale(autoconnect=True, oam_ip=ip_addr)
    gnb.device.goto_state("LXC")
    ps = gnb.device.get_cmd(cmd_name="ps", cmd_params={"options": "-ef"})
    proc = ps()
    pid = None
    for process in proc:
        if process["CMD"] == ps_name:
            pid = process["PID"]
            break
    if pid is None:
        MolerTest.error("No such process")
    killer = gnb.device.get_cmd(cmd_name="kill", cmd_params={"pid": "{}".format(pid)})
    killer()


@MolerTest.raise_background_exceptions()
def parse_alarms_on_gnb(ip_addr=None):
    """
    Parse gnb active alarms.

    :param ip_addr: IP address of gNB
    :return: list of critical_alarms, major_alarms, minor_alarms, gnb_alarms.
    """
    if ip_addr is None:
        ip_addr = common.ip

    MolerTest.info("Checking active alarms on AirScale...")
    active_alarms = Rest(oam_ip=ip_addr).get_active_alarms_list()
    critical_alarms = []
    major_alarms = []
    minor_alarms = []

    if "severity" in active_alarms[0].keys():
        _get_gnb_alarms_severity_coam(
            active_alarms, critical_alarms, major_alarms, minor_alarms
        )
    else:
        _get_gnb_alarms_severity_megazone(
            active_alarms, critical_alarms, major_alarms, minor_alarms
        )

    gnb_alarms = critical_alarms + major_alarms + minor_alarms
    return critical_alarms, major_alarms, minor_alarms, gnb_alarms


def _get_gnb_alarms_severity_coam(
    alarms_list, critical_alarms, major_alarms, minor_alarms
):
    for alarm in alarms_list:
        if "Critical" in alarm["severity"]:
            critical_alarms.append("{} {}".format(alarm["faultId"], alarm["faultName"]))
        if "Major" in alarm["severity"]:
            major_alarms.append("{} {}".format(alarm["faultId"], alarm["faultName"]))
        if "Minor" in alarm["severity"]:
            minor_alarms.append("{} {}".format(alarm["faultId"], alarm["faultName"]))


def _get_gnb_alarms_severity_megazone(
    alarms_list, critical_alarms, major_alarms, minor_alarms
):
    for alarm in alarms_list:
        if "critical" in alarm["perceivedSeverity"]:
            critical_alarms.append(alarm["additionalText1"])
        if "major" in alarm["perceivedSeverity"]:
            major_alarms.append(alarm["additionalText1"])
        if "minor" in alarm["perceivedSeverity"]:
            minor_alarms.append(alarm["additionalText1"])


@MolerTest.raise_background_exceptions()
def check_all_cells_status(expected_status, ip_addr=None):
    """
    Check if all available calls are online.

    :param ip_addr: IP address of gNB
    :param expected_status: status that all cells should have
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip

    re_status = re.compile(r"{}".format(expected_status), re.I)
    cells_status = Rest(oam_ip=ip_addr).get_cell_status()
    if all([re_status.match(status) for status in cells_status]):
        MolerTest.info("All cells are {}".format(expected_status))
    else:
        MolerTest.error("Not all cells are {}".format(expected_status))


def wait_for_reload_modal_appearance(timeout=900, ip_addr=None):
    """
    Wait for reload modal appearance and continue after or sleep for timeout seconds(for megazone_client).

    :param ip_addr: IP address of gNB
    :param timeout: time in seconds
    :return: None
    """
    try:
        Selenium().continue_after_reload_modal_appear_via_selenium(timeout=timeout)
    except MegazoneFunctionalityNotSupported:
        MolerTest.sleep(timeout)


@MolerTest.raise_background_exceptions()
def get_bts_name(ip_addr=None):
    """
    Get current btsName parameter value.
    :param ip_addr: IP address of gNB
    :return: btsName value
    """
    if ip_addr is None:
        ip_addr = common.ip
    current_scf_content = Rest(oam_ip=ip_addr).get_commissioning_file_content()
    match_object = re.search(r'<p name="btsName">(.+)</p>', current_scf_content)
    return match_object.group(1)


@MolerTest.raise_background_exceptions()
def modify_bts_name(new_value="ASIR1", ip_addr=None):
    """
    Modify btsName parameter

    :param ip_addr: IP address of gNB
    :param new_value: new value of btsName
    :return: value before modification
    """
    if ip_addr is None:
        ip_addr = common.ip

    rest_obj = Rest(oam_ip=ip_addr)
    dist_name = "MRBTS-{}".format(rest_obj.mrbts_id)
    current_value = get_bts_name()

    if current_value == new_value:
        MolerTest.error("btsName current value is equal to new value")

    rest_obj.modify_parameter_on_bts(
        dist_name=dist_name,
        param_name="btsName",
        operation="update",
        param_value=new_value,
    )

    modified_value = get_bts_name()
    if modified_value == new_value:
        MolerTest.info("Successfully changed btsName to {}".format(modified_value))
        return current_value
    else:
        MolerTest.error(
            "Failed to change btsName to {}, value after modification is {}".format(
                new_value, modified_value
            )
        )


@MolerTest.raise_background_exceptions()
def waiting_for_site_response(rerun=40, ip_addr=None):
    """
    Wait for ssh
    :param ip_addr: IP address of gNB
    :param rerun: int, number of reruns
    :return: None
    """
    if ip_addr is None:
        ip_addr = common.ip
    gnb = AirScale(autoconnect=False, oam_ip=ip_addr)
    gnb.connect()
    gnb.device.goto_state("PROXY_PC")
    gnb.device.goto_state("FCT", rerun=rerun)
