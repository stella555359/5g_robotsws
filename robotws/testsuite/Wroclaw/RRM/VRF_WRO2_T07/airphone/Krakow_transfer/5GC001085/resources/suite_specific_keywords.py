"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.file_management import *
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone import (
    collect_airphone_snapshot, log_airphone_build, modify_iphy_parameters, add_info_logging_to_ap_swconfig
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts import (
    start_wts_and_wait_for_ready_state,
    copy_egate_console_log_to_specified_dir,
    copy_wts_files_to_epcsim_dir_path,
    enable_debug_logging_in_wts_cfg,
    stop_wts_and_collect_its_logs,
    collect_sos_report_log,
    stop_wts_and_clear
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.aashell_management import (
    set_rad_parameter_via_aashell, get_rad_parameter_via_aashell
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.webem_alarms import (
    assert_no_new_major_or_critical_alarms_appeared,
    get_critical_or_major_alarms
)
import testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters as pm_counters
from ta5g_testline_management import ta5g_testline_management
from robot.errors import ExecutionFailed
from ta5g_testline_management import ta5g_testline_management
from ta5g_setups_and_teardowns import ta5g_setups_and_teardowns
from datetime import datetime
from robot.api import logger
from time import sleep, time
import requests
from zipfile import ZipFile
import shutil
from variables import *
import json
import subprocess
import re


class UnhandledVariableAssignmentForUnit(Exception):
    pass


def set_variables_based_on_deployment_and_release(feature):
    capacity_unit = get_capability_unit_name()
    if capacity_unit not in SUPPORTED_HARDWARES:
        logger_warning("{} is not supported for this feature's testsuite.".format(capacity_unit))
        capacity_unit = "ASIL"
    release = get_gnb_build_release(convert_to_trunk=True)
    delta_file = "DELTA_{}_{}.json".format(feature, capacity_unit)
    BuiltIn().set_suite_variable("${DELTA_FILE}", os.path.join(release, delta_file))
    BuiltIn().set_suite_variable("${UNIT_NAME}", capacity_unit)
    BuiltIn().set_suite_variable("${RELEASE}", release)
    BuiltIn().set_suite_variable("${FEATURE}", feature)
    min_xnlink_id = 0 if release == "SBTS22R3" else 1
    min_nradjgnb_id = 0 if release == "SBTS22R3" else 1
    BuiltIn().set_suite_variable("${MIN_XNLINK_ID}", min_xnlink_id)
    BuiltIn().set_suite_variable("${MIN_NRADJGNB_ID}", min_nradjgnb_id)
    BuiltIn().set_suite_variable("${FIRST_XNLINK_DIST_NAME}", XNLINK_DIST_NAME.format(min_xnlink_id))
    BuiltIn().set_suite_variable("${FIRST_NRADJGNB_DIST_NAME}", NRADJGNB_DIST_NAME.format(min_nradjgnb_id))


def get_test_prefix():
    tc_name = ta5g_interface_tools().get_robot_test_name()
    match = re.search(r'\w+(?P<feature>1085|7883)_(\w+_)?(?P<tc>\w+_\d+)_.*', tc_name)
    return "{}_{}".format(match.group("feature"), match.group("tc")) if match else tc_name


def set_variables_for_1085_a_tc20():
    if BuiltIn().get_variable_value("${UNIT_NAME}") == "ASOE":
        third, fourth = "5", "6"
        first_pci_fdd, second_pci_fdd = "55", "54"
    else:
        third, fourth = "3", "4"
        first_pci_fdd, second_pci_fdd = "53", "52"
    pass_1st_fdd_handover = INTRA_HO_SUCCESSFUL_EGATE_PRINT_TC20.format("20", third, fourth)
    pass_2nd_fdd_handover = INTRA_HO_SUCCESSFUL_EGATE_PRINT_TC20.format("20", fourth, third)
    BuiltIn().set_test_variable("${FIRST_FDD_HO_REGEX}", pass_1st_fdd_handover)
    BuiltIn().set_test_variable("${SECOND_FDD_HO_REGEX}", pass_2nd_fdd_handover)
    BuiltIn().set_test_variable("${FIRST_PCI_FDD}", first_pci_fdd)
    BuiltIn().set_test_variable("${SECOND_PCI_FDD}", second_pci_fdd)
    BuiltIn().set_test_variable("${THIRD_CELL_ID}", third)
    BuiltIn().set_test_variable("${FOURTH_CELL_ID}", fourth)


def configure_ransim_vm_interfaces():
    add_ip_addr_on_vm(ip_addr="10.0.3.151", interface="eth3")
    add_ip_addr_on_vm(ip_addr="10.0.3.153", interface="eth3")
    add_ip_addr_on_vm(ip_addr="192.168.6.252", interface="eth2")


def configure_second_ransim_vm_interfaces():
    add_ip_addr_on_vm(ip_addr="10.0.4.153", interface="eth3")
    add_ip_addr_on_vm(ip_addr="10.0.4.151", interface="eth3")
    add_ip_addr_on_vm(ip_addr="192.168.6.253", interface="eth2")


def configure_vm_interfaces_for_additional_ransim_cells():
    add_ip_addr_on_vm(ip_addr="192.168.6.253", interface="eth2")
    add_ip_addr_on_vm(ip_addr="192.168.6.254", interface="eth2")
    add_ip_addr_on_vm(ip_addr="192.168.6.255", interface="eth2")


def configure_second_amf_vm_interfaces():
    add_ip_addr_on_vm(ip_addr="10.0.2.20/24", interface="eth4")
    add_ip_addr_on_vm(ip_addr="10.0.1.200/24", interface="eth3")


def configure_ransim_xn_ipv4_v6_selection_tests_vm_interfaces():
    add_ip_addr_on_vm(ip_addr="fd94:e15d:8bda:aefc::1:22/64", interface="eth3")


def configure_control_plane_split_interfaces():
    add_ip_addr_on_vm(ip_addr="10.0.2.100/24", interface="eth4")


def ensure_gnb_files_flags_are_in_order():
    ensure_syslog_flags_existence_in_swconfig()
    ensure_cplane_flags_existence_in_swconfig()
    ensure_cp_runtime_ini_has_LoggingSeverity_set_on_trace()
    GnbSwconfigManager().log_swconfig_contents()


def configure_vm_interfaces_for_7883():
    configure_second_ransim_vm_interfaces()
    configure_second_amf_vm_interfaces()
    configure_ransim_xn_ipv4_v6_selection_tests_vm_interfaces()
    configure_control_plane_split_interfaces()


def log_units_builds():
    status, ret = BuiltIn().run_keyword_and_ignore_error("log_gnb_build")
    if status == "FAIL":
        logger_warning("log_gnb_build KW failed with exception {}".format(ret))
    status, ret = BuiltIn().run_keyword_and_ignore_error("log_airphone_build")
    if status == "FAIL":
        logger_warning("log_airphone_build KW failed with exception {}".format(ret))


def copy_wts_cfg_file_to_output_dir(wts_config_path=None, subdir="wts/"):
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    if not wts_config_path:
        wts_config_path = BuiltIn().get_variable_value("${WTS_CONFIG_PATH}")
    if not subdir.endswith('/'):
        subdir += '/'
    OperatingSystem().copy_file(source=wts_config_path, destination=os.path.join(output_dir, subdir))


def setup_radiohead_and_wts_and_wait_for_mibsib_wrapper(
        wts_config_path,
        sib1_reception_dict,
        skip_reset=False,
        max_retries=4,
        edaemon_port=30000,
        egate_timeout=720,
        reset_timeout=600
):
    ru_tries = mib_sib_tries = 0
    ru_tries_max = mib_sib_tries_max = max_retries
    ta5g_tshark = BuiltIn().get_library_instance('ta5g_tshark')
    while ru_tries < ru_tries_max and mib_sib_tries < mib_sib_tries_max:
        if ru_tries != 0 or mib_sib_tries != 0:
            logger_console_info("I will restart environment preparation")
        try:
            reset_units_and_wait_for_radio_head_online(skip_reset=skip_reset, timeout=reset_timeout)
            start_early_wts_pcap_collection()
            start_wts_and_wait_for_ready_state(
                wts_config_filename=wts_config_path,
                sib_reception_dict=sib1_reception_dict,
                edaemon_port=edaemon_port,
                timeout=egate_timeout
            )
        except RadioHeadTimeoutException:
            logger_warning("RadioHeadTimeoutException occurred")
            ru_tries += 1
        except (ValueError, ExecutionFailed) as e:
            logger_warning("MibSibAcquisitionFailed exception occurred")
            ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
            ta5g_egate_instance._ute_wtssim_instance.teardown_all_aliases_for_wts()
            ta5g_tshark.stop_tshark(alias=BuiltIn().get_variable_value("${ALIAS_TSHARK_WTS_EARLY}"))
            mib_sib_tries += 1
        else:
            break

        if skip_reset is True:
            if ru_tries > 0:
                raise RadioHeadTimeoutException("RadioHeadTimeoutException occurred")
            if mib_sib_tries > 0:
                raise MibSibAcquisitionFailed("MIB-SIB Acquisition failed")

        if ru_tries >= ru_tries_max:
            raise RadioHeadTimeoutException("RadioHeadTimeoutException occurred over {} times".format(ru_tries))
        elif mib_sib_tries >= mib_sib_tries_max:
            raise MibSibAcquisitionFailed("MIB-SIB Acquisition failed over {} retries".format(mib_sib_tries))


def wait_for_xnlink_status_available(
    check_tries_max=6,
    check_interval_sec=30
):
    check_tries = 0
    while check_tries < check_tries_max:
        if check_tries != 0:
            logger_console_info("I will recheck XnLink setup status")
        try:
            check_xnlink_status(status="available")
        except (KeyError, AssertionError) as e:
            logger_warning(repr(e))
            check_tries += 1
            sleep(check_interval_sec)
        else:
            break

    if check_tries >= check_tries_max:
        raise XnLinkStatusCheckFailed("XnLink status check failed over 3 minutes waiting")


def start_collecting_logs(prefix=""):
    log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    if not prefix:
        prefix = get_test_prefix()

    collect_scf_file(prefix="before", subdir=prefix, name=prefix)
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    ta5g_tshark = BuiltIn().get_library_instance('ta5g_tshark')
    ta5g_syslog.start_syslog_for_enb(logs_dirpath=log_dirpath + '/' + prefix,
                                     log_filename_prefix="syslog_gnb_{}_".format(prefix),
                                     alias=BuiltIn().get_variable_value("${SYSLOG_ALIAS}"))
    ta5g_tshark.start_tshark(alias=BuiltIn().get_variable_value("${ALIAS_TSHARK_WTS}"),
                             log_filename="tcpdump_WTS_" + prefix + ".pcap",
                             log_dirpath=os.path.join(log_dirpath, prefix),
                             capture_filter="sctp",
                             eth_interface='any')
    ta5g_tshark.start_tcpdump_on_remote_interface(log_filename_prefix="tcpdump_GNB_" + prefix,
                                                  log_dirpath=log_dirpath + "/" + prefix,
                                                  alias=BuiltIn().get_variable_value("${ALIAS_TCPDUMP_GNB}"))
    sleep(2)


def start_early_wts_pcap_collection():
    log_dirpath = ta5g_interface_tools().get_robot_output_dir()
    prefix = get_test_prefix()
    ta5g_tshark = BuiltIn().get_library_instance('ta5g_tshark')
    ta5g_tshark.start_tshark(alias=BuiltIn().get_variable_value("${ALIAS_TSHARK_WTS_EARLY}"),
                             log_filename="early_tcpdump_WTS_" + prefix + ".pcap",
                             log_dirpath=os.path.join(log_dirpath, prefix),
                             capture_filter="sctp",
                             eth_interface='any')


def teardown_collecting_logs():
    BuiltIn().run_keyword_if_test_failed("wait_for_OAM_config_update")
    ta5g_tshark = BuiltIn().get_library_instance('ta5g_tshark')
    ta5g_syslog = BuiltIn().get_library_instance('ta5g_syslog')
    ute_tshark = BuiltIn().get_library_instance('ute_tshark')
    ta5g_egate = BuiltIn().get_library_instance("ta5g_egate")
    ta5g_tshark.stop_tcpdump_on_remote_interface()
    ta5g_syslog.collect_syslog_results(alias=BuiltIn().get_variable_value("${SYSLOG_ALIAS}"))
    ta5g_syslog.teardown_all_aliases_for_syslog()
    ta5g_egate._ute_wtssim_instance.teardown_all_aliases_for_wts()
    ute_tshark.teardown_all_aliases_for_tshark()
    test_prefix = get_test_prefix()
    copy_egate_console_log_to_specified_dir(subdirectory=test_prefix, prefix=test_prefix)
    collect_scf_file(prefix="after", subdir=test_prefix, name=test_prefix)


def change_duration_of_periodic_removal_cycle(rdNeighRemovalEvaluationTime=3):
    rc, cp_cl_path = run_on_gnb(cmd="find /rom/swpool/ -name cp*cl*.txz")
    cp_cl_path = cp_cl_path.strip().split()[0]
    if cp_cl_path.startswith("/rom/swpool"):
        logger_console_info("CP_CL component path found: {}".format(cp_cl_path))
    else:
        logger_warning("CP_CL component path NOT FOUND, output from find cmd: ({})\n"
                       "Tests 1085-C_001 and 003 will probably fail due to this".format(cp_cl_path))
        return
    commands = (
        "cd /tmp; "
        "mkdir RNDPARAM; "
        "cd RNDPARAM; "
        "cp {} . ; "
        "tar xvf cp*cl*.txz ; "
        "cp opt/nokia/SS_CPLANE/etc/cp_cl.enb_conf.ini . ; "
        "sed -i -r 's/rdNeighRemovalEvaluationTime=([0-9]*)/rdNeighRemovalEvaluationTime={}/' cp_cl.enb_conf.ini ; "
        "knife update cp*cl*.txz cp_cl.enb_conf.ini ; "
        "cat cp_cl.enb_conf.ini | grep rdNeighRem ;".format(cp_cl_path, rdNeighRemovalEvaluationTime)
    )
    logger_console("Changing rdNeighRemovalEvaluationTime to 3")
    rc, output = run_on_gnb(cmd=commands)
    logger.info("{}".format(output))


def enable_knife_cmd_on_gnb():
    gnb_build = get_gnb_build(convert_to_trunk=True)
    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    url = "https://wft.int.net.nokia.com:8091/api/v1/build_deliverer.json"
    data = {
        "page": "",
        "items": "2000",
        "sorting_field": "deliverer_name",
        "sorting_direction": "ASC",
        "group_by": "",
        "group_by_processor": "",
        "columns": [
            "component|name",
            "sub_build",
            "delivered_build|repository_revision"
        ],
        "view_filters_attributes": {
            "0": {
                "column": "build.baseline",
                "operation": "eq",
                "value": [
                    gnb_build
                ]
            }
        },
        "access_key": "N2EGrfZEGZ6EgDIiUr5KScMboXCF45zRHRgJVasY"  # access key for Plinta Mateusz. Ask before reuse
    }
    headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
    wft_subbuilds = requests.post(url, data=json.dumps(data), headers=headers)
    logger.debug(wft_subbuilds.json())
    ps_version = None
    for elem in wft_subbuilds.json()['items']:
        if elem['component|name'] == "PS" and elem['sub_build']['deliverer_name'] == "PS":
            ps_version = elem['sub_build']['baseline']
            break

    if not ps_version:
        raise ValueError("PS version not found in WFT response JSON")
    filename = ps_version + ".zip"
    logger_console_info(filename)

    url = "http://ulsvpssci02.emea.nsn-net.net/PS_REL_YAFT_ZIPS/{}".format(filename)
    path = os.path.join(output_dir, filename)
    psfile = requests.get(url)
    open(path, 'wb').write(psfile.content)

    with ZipFile(path, 'r') as zipObj:
        list_of_file_names = zipObj.namelist()
        for fileName in list_of_file_names:
            if fileName.startswith(KNIFE_PATH_IN_PS_LOAD):
                logger_console_info(fileName)
                knife_path = zipObj.extract(fileName, path=output_dir)
                break

    if unit_type == "ASIL":
        typeoffct = "fctp"
        slot = 4
    elif unit_type == "ASOE":
        typeoffct = "asce"
        slot = 0
    else:
        raise UnhandledVariableAssignmentForUnit("Value of typeoffct is not implemented for unit {}".format(unit_type))

    LFS_addons_path = "/ffs/run/swpool/LFS/addons/{}/".format(typeoffct)
    upload_files_to_gnb(os.path.join(LFS_addons_path, "knife.tzst"), knife_path)
    commands = (
        "cd {}; "
        "crasign knife.tzst; "
        "ln -f -P knife.tzst /ffs/run/boardcfg/{}/A/mcu-{}/addons/knife.tzst; "
        "ln -f -P knife.tzst.p7 /ffs/run/boardcfg/{}/A/mcu-{}/addons/knife.tzst.p7; "
        "sync; "
        "cd /ffs/run; "
        "mkdir backup_hash; "
        "mv HashContainer* backup_hash/; "
        "sync; ".format(LFS_addons_path, slot, typeoffct, slot, typeoffct)
    )
    rc, output = run_on_gnb(cmd=commands)
    logger.info("{}".format(output))
    logger_console_info("Reboot gNB for knife cmd to be visible")
    run_on_gnb(cmd="system-module-reboot")
    logger_console("Waiting till testline LMP interfaces become pingable")
    ta5g_testline_management().wait_for_testline_icmp_echo_replies_and_ssh_services()


def change_duration_of_periodic_removal_cycle_manually(rdNeighRemovalEvaluationTime=3):
    rc, cp_cl_path = run_on_gnb(cmd="find /rom/swpool/ -name cp*cl*.txz")
    cp_cl_package_name = cp_cl_path.strip().split("/")[-1]
    cp_cl_package_old_name = "old_" + cp_cl_path.strip().split("/")[-1]
    cp_cl_path = cp_cl_path.strip().split()[0]
    if cp_cl_path.startswith("/rom/swpool"):
        logger_console_info("CP_CL component path found: {}".format(cp_cl_path))
    else:
        logger_warning("CP_CL component path NOT FOUND, output from find cmd: ({})\n"
                       "Tests 1085-C_001 and 003 will probably fail due to this".format(cp_cl_path))
        return
    commands = (
        "cd /rom/swpool/CPLANE-5G/sm6-snowfish/; "
        "mkdir RNDPARAM; "
        "cd RNDPARAM; "
        "cp {cp_cl_path} . ; "
        "mv ../{cp_cl_package_name} ../{cp_cl_package_old_name} ; "
        "tar xvf cp*cl*.txz ; "
        "sed -i -r "
        "'s/rdNeighRemovalEvaluationTime=([0-9]*)/rdNeighRemovalEvaluationTime={rdNeighRemovalEvaluationTime}/' "
        "opt/nokia/SS_CPLANE/etc/cp_cl.enb_conf.ini ; "
        "rm {cp_cl_package_name} ; "
        "tar -czvf {cp_cl_package_name} ./* ; "
        "mv {cp_cl_package_name} .. ; "
        "cd .. ; "
        "crasign {cp_cl_package_name} ; "
        "rm -r RNDPARAM/ ; "
        "cd /ffs/run/swpool ; "
        "chmod 755 install*.sh ; "
        "./install*.sh ; "
        "rm /ffs/run/HashContainer* ; ".format(cp_cl_path=cp_cl_path, cp_cl_package_name=cp_cl_package_name,
                                               cp_cl_package_old_name=cp_cl_package_old_name,
                                               rdNeighRemovalEvaluationTime=rdNeighRemovalEvaluationTime)
    )
    logger_console("Changing rdNeighRemovalEvaluationTime to {}".format(rdNeighRemovalEvaluationTime))
    rc, output = run_on_gnb(cmd=commands)
    logger.info("{}".format(output))


def activate_feature_flag():
    logger_console_info("Activate feature flag: actSaUeBasedAnrNr")
    update_parameter_value(parameter="actSaUeBasedAnrNr", value=True, dist_name="MRBTS-1/NRBTS-1")


def deactivate_feature_flag():
    logger_console_info("Deactivate feature flag: actSaUeBasedAnrNr")
    update_parameter_value(parameter="actSaUeBasedAnrNr", value=False, dist_name="MRBTS-1/NRBTS-1")


def get_feature_activation_parameter_value():
    return get_parameter_value_from_scf(dist_name="MRBTS-1/NRBTS-1", parameter="actSaUeBasedAnrNr")


def set_maxNumNrAnrMoiAllowed(value=1):
    logger_console_info("Set maxNumNrAnrMoiAllowed to {}".format(value))
    update_parameter_value(parameter="maxNumNrAnrMoiAllowed", value=value, dist_name="MRBTS-1/NRBTS-1")


def set_maxNumAnrNrrelAllowed(value=50):
    logger_console_info("Set maxNumAnrNrrelAllowed to {}".format(value))
    update_parameter_value(parameter="maxNumAnrNrrelAllowed", value=value, dist_name="MRBTS-1/NRBTS-1/NRANRPR-1")


def set_consecRecheckForNrNbRemoval(value=5):
    logger_console_info("Set consecRecheckForNrNbRemoval to {}".format(value))
    update_parameter_value(parameter="consecRecheckForNrNbRemoval", value=value, dist_name="MRBTS-1/NRBTS-1/NRANRPR-1")


def set_actAutoNrNbRemoval(value=True):
    logger_console_info("Set actAutoNrNbRemoval to {}".format(value))
    update_parameter_value(parameter="actAutoNrNbRemoval", value=value, dist_name="MRBTS-1/NRBTS-1/NRANR-1")


def set_actInterFreqHoSA(value=True):
    logger_console_info("Set actInterFreqHoSA to {}".format(value))
    update_parameter_value(parameter="actInterFreqHoSA", value=value, dist_name="MRBTS-1/NRBTS-1")


def set_idleTimeForNrNbRemoval(value=2):
    logger_console_info("Set idleTimeForNrNbRemoval to {}".format(value))
    update_parameter_value(parameter="idleTimeForNrNbRemoval", value=value, dist_name="MRBTS-1/NRBTS-1/NRANRPR-1")


def set_cellDepMode(value="SA"):
    release = get_gnb_build_release()
    if value == "SA+NSA" and release == "SBTS22R3":
        update_parameter_value(parameter="cellDepMode", value="both", dist_name="MRBTS-1/NRBTS-1/NRANRPR-1")
    else:
        update_parameter_value(parameter="cellDepMode", value=value, dist_name="MRBTS-1/NRBTS-1/NRANRPR-1")


def set_actNgcFlexSaMode(value=True):
    update_parameter_value(parameter="actNgcFlexSaMode", value=value, dist_name="MRBTS-1/NRBTS-1")


def delete_all_nrrels():
    nrrels = get_nrrel_list()
    if nrrels:
        for nrrel in nrrels:
            delete_object(dist_name=nrrel)


@handle_admin
def delete_all_XNLINKs(max_id="256", except_id="5", *args, **kwargs):
    min_xnlink_id = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    delta = [
        {
            "distName": "MRBTS-1/NRBTS-1/XNLINK-{}".format(i), "operation": "delete", "parameters":
            [
                {"parameterName": "cPlaneIpAddr", "value": "127.0.0.1", "operation": "update"},
                {"parameterName": "xnLinkId", "value": str(i), "operation": "update"}
            ]

        } for i in range(int(min_xnlink_id), int(max_id)+1) if i != int(except_id)
    ]
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(delta),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=600)


def get_amount_of_XNLINK_objects():
    xnlinks = get_xnlinks_list()
    return len(xnlinks)


def wait_for_OAM_config_update(sleep_time=60):
    logger_console("Waiting for OAM config update")
    sleep(sleep_time)


def wait_one_cycle_of_periodic_removal(sleep_time=None):
    if sleep_time is None:
        prc_duration = BuiltIn().get_variable_value("${PERIODIC_REMOVAL_CYCLE_DURATION}")
        sleep_time = prc_duration if prc_duration is not None else 3
    logger_console("Waiting one cycle of periodic removal")
    sleep(sleep_time*60)


def wait_for_next_periodic_removal_cycle(basetime=None, interval=None):
    if interval is None:
        interval = BuiltIn().get_variable_value("${PERIODIC_REMOVAL_CYCLE_DURATION}")
    now = int(time())
    time_to_wait = int(interval) * 60 - (now % int(basetime)) % (int(interval) * 60)
    next_pm_period = int(time_to_wait) + int(now)
    logger_console_info("Next removal cycle starting at {}".format(datetime.fromtimestamp(next_pm_period)))
    sleep(time_to_wait)


def wait_for_next_periodic_removal_cycle_and_OAM_update(basetime, interval=None):
    wait_for_next_periodic_removal_cycle(basetime, interval)
    wait_for_OAM_config_update()


def wait_for_first_counters_values_to_arrive(minutes=None):
    if minutes is None:
        minutes = BuiltIn().get_variable_value("${PM_PERIOD}")
    logger_console(
        "Waiting for one PM period ({}min) for first counter values to arrive".format(minutes)
    )
    pm_counters.wait_for_next_pm_period(int(minutes))
    pm_counters.wait_for_next_pm_period(int(minutes))


@handle_admin
def create_12288_NRADJNRCELL_objects(*args, **kwargs):
    parameters = [
        {"distName": "MRBTS-1/NRBTS-1/NRADJNRCELL-{}".format(i), "operation": "create", "parameters": [
            {"parameterName": "cellDepType", "value": "SA", "operation": "update"},
            {"parameterName": "fiveGsTac", "value": "0", "operation": "update"},
            {"parameterName": "gNbId", "value": "2", "operation": "update"},
            {"parameterName": "gNbIdLength", "value": "25", "operation": "update"},
            {"parameterName": "gnbPlmn", "value": [
                {"mcc": "311", "mnc": "489", "mncLength": "3"}
            ], "operation": "update"},
            {"parameterName": "lcrId", "value": "2", "operation": "update"},
            {"parameterName": "nrarfcn", "value": "636666", "operation": "update"},
            {"parameterName": "physCellId", "value": "60", "operation": "update"}
        ]}
        for i in range(1, 12289)]
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(parameters),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=1200)


@handle_admin
def delete_12288_NRADJNRCELL_objects(*args, **kwargs):
    parameters = [{"distName": "MRBTS-1/NRBTS-1/NRADJNRCELL-{}".format(i),
                   "operation": "delete", "parameters": []} for i in range(1, 12289)]
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(parameters),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=1200)


@handle_admin
def create_256_NRREL_objects(*args, **kwargs):
    max_nrrels_id = BuiltIn().get_variable_value("${MAX_NRRELS_ID}")
    delta = [create_NRREL_object(id_=str(i), lcrId="3", return_only=True) for i in range(0, max_nrrels_id + 1)]
    logger_console_info("Creating 0 to 255 (sum of 256) fake NRRELs in SCF...")
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(delta),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=600)


def create_fake_256_nrrels():
    if len(get_nrrel_list()) == 0:
        create_256_NRREL_objects()
    else:
        delete_all_nrrels()
        create_256_NRREL_objects()


@handle_admin
def delete_256_NRREL_objects(*args, **kwargs):
    max_nrrels_id = BuiltIn().get_variable_value("${MAX_NRRELS_ID}")
    parameters = [{"distName": "MRBTS-1/NRBTS-1/NRCELL-1/NRREL-{}".format(i),
                   "operation": "delete", "parameters": []} for i in range(0, max_nrrels_id + 1)]
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(parameters),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=600)


@handle_admin
def create_NRADJNRCELL_object(id_="1", physCellId="49", gNbId="2", gNbIdLength="25", lcrId="1", cellDepType="SA",
                              mcc="311", mnc="489", mncLength="3", ssbFrequency="636576", nrarfcn="636666",
                              fiveGsTac="0", freqbandindicatornr=None, cellReservedForOperatorUse="notReserved",
                              return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRADJNRCELL-{}".format(id_), "operation": "create", "parameters":
            [
                {"parameterName": "cellDepType", "value": cellDepType, "operation": "update"},
                {"parameterName": "fiveGsTac", "value": fiveGsTac, "operation": "update"},
                {"parameterName": "gNbId", "value": gNbId, "operation": "update"},
                {"parameterName": "gNbIdLength", "value": gNbIdLength, "operation": "update"},
                {"parameterName": "gnbPlmn", "value": [
                    {"mcc": mcc, "mnc": mnc, "mncLength": mncLength}
                ], "operation": "update"},
                {"parameterName": "lcrId", "value": lcrId, "operation": "update"},
                {"parameterName": "nrarfcn", "value": nrarfcn, "operation": "update"},
                {"parameterName": "ssbFrequency", "value": ssbFrequency, "operation": "update"},
                {"parameterName": "physCellId", "value": physCellId, "operation": "update"},
                {"parameterName": "cellReservedForOperatorUse", "value": cellReservedForOperatorUse,
                 "operation": "update"},
            ]
    }
    if fiveGsTac is None:
        if delta["parameters"][1]["parameterName"] == "fiveGsTac":
            delta["parameters"].pop(1)
    if freqbandindicatornr:
        delta["parameters"].append({"parameterName": "freqBandIndicatorNR", "value": freqbandindicatornr,
                                    "operation": "update"})
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=600)


@handle_admin
def create_NRADJGNB_object(id_="1", administrativeState="Unlocked", gNbIdLength="22", gNodeBId="2", mcc="311",
                           mnc="489", mncLength="3", xnLinkRef=None, return_only=False,
                           *args, **kwargs):
    nrAdjGnbId = id_
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRADJGNB-{}".format(id_), "operation": "create", "parameters":
            [
                {"parameterName": "administrativeState", "value": administrativeState, "operation": "update"},
                {"parameterName": "gNbIdLength", "value": gNbIdLength, "operation": "update"},
                {"parameterName": "gNodeBId", "value": gNodeBId, "operation": "update"},
                {"parameterName": "gnbPlmn", "value":
                    [{"mcc": mcc, "mnc": mnc, "mncLength": mncLength}], "operation": "update"},
                {"parameterName": "nrAdjGnbId", "value": nrAdjGnbId, "operation": "update"}
            ]
    }
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R3":
        delta['parameters'].append({"parameterName": "gNodeBIdCtrl", "value": "oamControlled", "operation": "update"})
    if xnLinkRef is not None:
        delta['parameters'].append({"parameterName": "xnLinkRef", "value": str(xnLinkRef), "operation": "update"})

    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=600)


@handle_admin
def create_XNLINK_object(id_=None, cPlaneIpAddr="10.0.3.151", xnLinkId="0", return_only=False, *args, **kwargs):
    if id_ is None:
        id_ = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    xnLinkId = id_
    delta = {
        "distName": "MRBTS-1/NRBTS-1/XNLINK-{}".format(id_), "operation": "create", "parameters":
            [

                {"parameterName": "cPlaneIpAddr", "value": cPlaneIpAddr, "operation": "update"},
                {"parameterName": "xnLinkId", "value": xnLinkId, "operation": "update"}
            ]
    }
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R3":
        delta['parameters'].append({"parameterName": "cPlaneIpAddrCtrl", "value": "oamControlled",
                                    "operation": "update"})
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=600)


@handle_admin
def create_XNLINKs_objects(max_id="256", except_id="5", cPlaneIpAddr="127.0.0.1", return_only=False,
                           *args, **kwargs):
    min_xnlink_id = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    delta = [
        {
            "distName": "MRBTS-1/NRBTS-1/XNLINK-{}".format(i), "operation": "create", "parameters":
            [
                {"parameterName": "cPlaneIpAddr", "value": cPlaneIpAddr, "operation": "update"},
                {"parameterName": "xnLinkId", "value": str(i), "operation": "update"}
            ]
        } for i in range(int(min_xnlink_id), int(max_id)+1) if i != int(except_id)
    ]
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R3":
        for obj in delta:
            obj['parameters'].append({"parameterName": "cPlaneIpAddrCtrl", "value": "oamControlled",
                                      "operation": "update"})
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(delta),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=600)


@handle_admin
def create_NRADJGNB_default_object(return_only=False, *args, **kwargs):
    min_xnlink_id = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    min_nradjgnb_id = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRADJGNB-{}".format(min_nradjgnb_id),
        "operation": "create",
        "parameters": [
            {
                "parameterName": "administrativeState",
                "value": "Unlocked",
                "operation": "update"
            },
            {
                "parameterName": "gNbIdLength",
                "value": "25",
                "operation": "update"
            },
            {
                "parameterName": "gNodeBId",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "gnbPlmn",
                "value": [
                    {
                        "mcc": "311",
                        "mnc": "489",
                        "mncLength": "3"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "xnLinkRef",
                "value": "{}".format(min_xnlink_id),
                "operation": "update"
            }
        ]
    }
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R3":
        delta['parameters'].append({"parameterName": "gNodeBIdCtrl", "value": "oamControlled", "operation": "update"})
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=300)


@handle_admin
def create_NRREL_object(cell_id_="1", id_="1", gNbId="1", gNbIdLength="22", lcrId="2", removeNotAllowed="false",
                        mcc="311", mnc="489", mncLength="3", nrDcAllowed="false", handoverAllowedSARedCap="forbidden",
                        use_sCellAdditionMethod=True, return_only=False,
                        *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-{}/NRREL-{}".format(cell_id_, id_),
        "operation": "create",
        "parameters": [
            {"parameterName": "cellIndividualSsbRsrpOffset", "value": "0dB", "operation": "update"},
            {"parameterName": "cellIndividualSsbRsrqOffset", "value": "0dB", "operation": "update"},
            {"parameterName": "gNbId", "value": gNbId, "operation": "update"},
            {"parameterName": "gNbIdLength", "value": gNbIdLength, "operation": "update"},
            {"parameterName": "gnbPlmn", "value": [
                {"mcc": mcc, "mnc": mnc, "mncLength": mncLength}], "operation": "update"},
            {"parameterName": "lcrId", "value": lcrId, "operation": "update"},
            {"parameterName": "handoverAllowedSA", "value": "allowed", "operation": "update"},
            {"parameterName": "removeNotAllowed", "value": removeNotAllowed, "operation": "update"}]
    }
    if use_sCellAdditionMethod is True:
        delta['parameters'].append({"parameterName": "sCellAdditionMethod", "value": "blind", "operation": "update"})
    release = get_gnb_build_release()
    if release != "SBTS22R4" and release != "SBTS23R1":
        delta['parameters'].append({"parameterName": "handoverAllowedSARedCap", "value": handoverAllowedSARedCap,
                                    "operation": "update"})
    if release != "SBTS22R2" and release != "SBTS22R3":
        delta['parameters'].append({"parameterName": "nrDcAllowed", "value": nrDcAllowed, "operation": "update"})
    if release != "SBTS23R1" and release != "SBTS23R2":
        delta['parameters'].append({"parameterName": "isRplCellForPSCell", "value": "false", "operation": "update"})
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=300)


@handle_admin
def create_NRPLMN_object(id_="1", mcc="1", mnc="1", mncLength="2", *args, **kwargs):
    parameters = [
        {
            "distName": "MRBTS-1/NRBTS-1/NRPLMN-{}".format(id_),
            "operation": "create",
            "parameters": [
                {"parameterName": "mcc", "value": mcc, "operation": "update"},
                {"parameterName": "mnc", "value": mnc, "operation": "update"},
                {"parameterName": "mncLength", "value": mncLength, "operation": "update"}
            ]
        }
    ]
    kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(parameters),
                                                       skip_parameter_relation_errors=True,
                                                       should_activate=True,
                                                       timeout=300)


@handle_admin
def create_NRHOIF_object(cell_id="1", id_="1", freqBandIndicatorNR="79", ifhoSsbScs="30 KHz", scs="30 KHz",
                         ssbFrequency="700000", return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-{}/NRHOIF-{}".format(cell_id, id_),
        "operation": "create",
        "parameters": [
            {
                "parameterName": "a1BasedPCellSwitchEnabled",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "a2BasedPCellSwitchEnabled",
                "value": "false",
                "operation": "update"
            },
            {
                "parameterName": "a3MeasEnabled",
                "value": "rsrp",
                "operation": "update"
            },
            {
                "parameterName": "a3MeasSsbRsrp",
                "value": [
                    {
                        "a3HysteresisSsbRsrp": "1",
                        "a3OffsetSsbRsrp": "5",
                        "a3TimeToTriggerSsbRsrp": "ms512"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "a3MeasSsbRsrq",
                "value": [
                    {
                        "a3HysteresisSsbRsrq": "15",
                        "a3OffsetSsbRsrq": "30",
                        "a3TimeToTriggerSsbRsrq": "ms320"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "a5MeasEnabled",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "a4MeasEnDcSteeringEnabled",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "a4MeasHigherPrioFreqEnabled",
                "value": "none",
                "operation": "update"
            },
            {
                "parameterName": "a4MeasSsbRsrp",
                "value": [
                    {
                        "a4HysteresisSsbRsrp": "0",
                        "a4ThresholdSsbRsrp": "34",
                        "a4TimeToTriggerSsbRsrp": "ms40"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "a4MeasSsbRsrq",
                "value": [
                    {
                        "a4HysteresisSsbRsrq": "0",
                        "a4ThresholdSsbRsrq": "49",
                        "a4TimeToTriggerSsbRsrq": "ms40"
                    }
                ],
                "operation": "update"
            },
            {
                "parameterName": "cellDepType",
                "value": "SA",
                "operation": "update"
            },
            {
                "parameterName": "freqBandIndicatorNR",
                "value": freqBandIndicatorNR,
                "operation": "update"
            },
            {
                "parameterName": "ifhoSsbScs",
                "value": ifhoSsbScs,
                "operation": "update"
            },
            {
                "parameterName": "ifhoSsbSmtcDuration",
                "value": "sf5",
                "operation": "update"
            },
            {
                "parameterName": "ifhoSsbSmtcPeriodicity",
                "value": "sf10",
                "operation": "update"
            },
            {
                "parameterName": "numberOfTransmittedSsBlocks",
                "value": "1 beam",
                "operation": "update"
            },
            {
                "parameterName": "scs",
                "value": scs,
                "operation": "update"
            },
            {
                "parameterName": "ssBurstSetPeriod",
                "value": "10",
                "operation": "update"
            },
            {
                "parameterName": "ssbFrequency",
                "value": ssbFrequency,
                "operation": "update"
            },
            {
                "parameterName": "a4MeasSCellAddEnabled",
                "value": "none",
                "operation": "update"
            }
        ]
    }
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R2" and release != "SBTS22R3":
        delta["parameters"].append({"parameterName": "a4MeasNrDcEnabled", "value": "none", "operation": "update"})

    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=300)


def create_fake_nrrel_and_nradjnrcell_objects_and_set_maxNumAnrNrrelAllowed_to_1():
    change_maxNumAnrNrrelAllowed = {
        "distName": "MRBTS-1/NRBTS-1/NRANRPR-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "maxNumAnrNrrelAllowed",
                "value": "1",
                "operation": "update"
            }
        ]
    }
    nrrel = create_NRREL_object(return_only=True, id_="1", gNbId="2005", gNbIdLength="22",
                                mcc="311", mnc="489", mncLength="3", lcrId="1")
    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    ssb_freq_value = "636576" if unit_type != "ASIK" else "633216"
    nradjnrcell = create_NRADJNRCELL_object(return_only=True, id_="1", gNbId="2005", gNbIdLength="22",
                                            mcc="311", mnc="489", mncLength="3", lcrId="1", nrarfcn="653332",
                                            physCellId="60", ssbFrequency=ssb_freq_value, freqbandindicatornr="78")
    delta = [change_maxNumAnrNrrelAllowed, nrrel, nradjnrcell]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def create_nranrpr_nrrel_and_nradjnrcell_objects_for_fdd_cells():
    nranrpr_delta = {
        "distName": "MRBTS-1/NRBTS-1/NRANRPR-2",
        "operation": "create",
        "parameters": [
            {
                "operation": "update",
                "parameterName": "anrThresRsrpNbCell",
                "value": "-90"
            },
            {
                "operation": "update",
                "parameterName": "anrThresholdSelector",
                "value": "RSRP"
            },
            {
                "operation": "update",
                "parameterName": "cellDepMode",
                "value": "SA"
            },
            {
                "operation": "update",
                "parameterName": "consecRecheckForNrNbRemoval",
                "value": "5"
            },
            {
                "operation": "update",
                "parameterName": "idleTimeForNrNbRemoval",
                "value": "72"
            },
            {
                "operation": "update",
                "parameterName": "maxNumAnrNrrelAllowed",
                "value": "1"
            },
            {
                "operation": "update",
                "parameterName": "ssbFrequency",
                "value": "126530"
            }
            ],
    }
    nradjnrcell = create_NRADJNRCELL_object(return_only=True, id_="2", gNbId="2005", gNbIdLength="22",
                                            mcc="311", mnc="489", mncLength="3", lcrId="2", nrarfcn="126900",
                                            physCellId="61", ssbFrequency="126530", freqbandindicatornr="71")
    nrrel = create_NRREL_object(return_only=True, cell_id_=BuiltIn().get_variable_value("${THIRD_CELL_ID}"),
                                id_="1", gNbId="2005", gNbIdLength="22",
                                mcc="311", mnc="489", mncLength="3", lcrId="2")
    delta = [nranrpr_delta, nradjnrcell, nrrel]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def create_inter_frequency_relation_to_band_66():
    nradjnrcell = create_NRADJNRCELL_object(return_only=True, id_="3", gNbId="2005", gNbIdLength="22",
                                            mcc="311", mnc="489", mncLength="3", lcrId="3", nrarfcn="425040",
                                            physCellId="62", ssbFrequency="425070", freqbandindicatornr="66")
    nrhoif = create_NRHOIF_object(cell_id=BuiltIn().get_variable_value("${FOURTH_CELL_ID}"), return_only=True, id_="1",
                                  freqBandIndicatorNR="66", ifhoSsbScs="15KHz",
                                  scs="15 KHz", ssbFrequency="425070")
    nrrel = create_NRREL_object(return_only=True, cell_id_=BuiltIn().get_variable_value("${FOURTH_CELL_ID}"),
                                id_="1", gNbId="2005", gNbIdLength="22",
                                mcc="311", mnc="489", mncLength="3", lcrId="3")
    delta = [nradjnrcell, nrhoif, nrrel]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


@handle_admin
def create_NRPLMNSET_object(id_=1, nrPlmnDNList=None, trackingAreaDN=None, cellReservedForOperatorUse="notReserved",
                            cellReservedForOperatorUseUacAutoMax="notReserved", return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-{}".format(id_),
        "operation": "create",
        "parameters": [{
            "parameterName": "nrPlmnDNList",
            "value": nrPlmnDNList,
            "operation": "update"
        }, {
            "parameterName": "trackingAreaDN",
            "value": trackingAreaDN,
            "operation": "update"
        }, {
            "parameterName": "cellReservedForOperatorUse",
            "value": cellReservedForOperatorUse,
            "operation": "update"
        }, {
            "parameterName": "cellReservedForOperatorUseUacAutoMax",
            "value": cellReservedForOperatorUseUacAutoMax,
            "operation": "update"
        }
        ]
    }
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def update_NRPLMNSET_object(id_=1, nrPlmnDNList=None, trackingAreaDN=None, return_only=False, cell=1, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-{}/NRPLMNSET_SA-{}".format(cell, id_),
        "operation": "update",
        "parameters": [{
            "parameterName": "nrPlmnDNList",
            "value": nrPlmnDNList,
            "operation": "update"
        }, {
            "parameterName": "trackingAreaDN",
            "value": trackingAreaDN,
            "operation": "update"
        }
        ]
    }
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def delete_NRPLMNSET_object(id_=1, return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1/NRPLMNSET_SA-{}".format(id_),
        "operation": "delete",
        "parameters": []
    }
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def create_ADJ_NRPLMNSET_object(id_=1, nrPlmnDNList=None, fiveGsTac="0", cellReservedForOperatorUse="notReserved",
                                return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRADJNRCELL-1/ADJ_NRPLMNSET_SA-{}".format(id_),
        "operation": "create",
        "parameters": [{
            "parameterName": "nrPlmnDNList",
            "value": nrPlmnDNList,
            "operation": "update"
        }, {
            "parameterName": "fiveGsTac",
            "value": fiveGsTac,
            "operation": "update"
        }, {
            "parameterName": "cellReservedForOperatorUse",
            "value": cellReservedForOperatorUse,
            "operation": "update"
        }
        ]
    }
    if return_only is True:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


def adjust_parameters_for_1085_B_TC026():
    nradjnrcell1 = create_NRADJNRCELL_object(return_only=True, id_="1", physCellId="401", gNbId="2", gNbIdLength="25",
                                             lcrId="2", cellDepType="SA", mcc="311", mnc="489", mncLength="3",
                                             ssbFrequency="425070", nrarfcn="347380", fiveGsTac="200",
                                             freqbandindicatornr="66")

    nradjnrcell2 = create_NRADJNRCELL_object(return_only=True, id_="2", physCellId="401", gNbId="2", gNbIdLength="25",
                                             lcrId="3", cellDepType="SA", mcc="311", mnc="489", mncLength="3",
                                             ssbFrequency="698784", nrarfcn="700000", fiveGsTac="200",
                                             freqbandindicatornr="79")

    nrrel1 = create_NRREL_object(return_only=True, id_="1", gNbId="2", gNbIdLength="25", lcrId="2",
                                 removeNotAllowed="false", mcc="311", mnc="489", mncLength="3",
                                 use_sCellAdditionMethod=True)

    nrrel2 = create_NRREL_object(return_only=True, id_="2", gNbId="2", gNbIdLength="25", lcrId="3",
                                 removeNotAllowed="false", mcc="311", mnc="489", mncLength="3",
                                 use_sCellAdditionMethod=True)

    nrhoif1 = create_NRHOIF_object(return_only=True, id_="1", freqBandIndicatorNR="66", ifhoSsbScs="15KHz",
                                   scs="15 KHz", ssbFrequency="425070")

    nrhoif2 = create_NRHOIF_object(return_only=True, id_="2", freqBandIndicatorNR="79", ifhoSsbScs="30 KHz",
                                   scs="30 KHz", ssbFrequency="698784")

    delta = [nradjnrcell1, nradjnrcell2, nrrel1, nrrel2, nrhoif1, nrhoif2]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def adjust_parameters_for_7883_TC026_TC27():
    nrcell_trackingArea_0 = delete_TRACKINGAREA_object(id_="0", return_only=True)
    nrcell_trackingArea_200 = create_TRACKINGAREA_object(id_="200", return_only=True)
    nrplmnset1 = update_NRPLMNSET_object(return_only=True, id_=1,
                                         trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                                         nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1", "MRBTS-1/NRBTS-1/NRPLMN-2"])
    nrplmnset1_cell2 = update_NRPLMNSET_object(return_only=True, id_=1, cell=2,
                                               trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                                               nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])
    nrcell_trackingAreaDN = update_NRCELL_trackingAreaDN_parameter(id_="200", return_only=True)
    delta = [nrcell_trackingArea_0, nrcell_trackingArea_200, nrplmnset1, nrplmnset1_cell2, nrcell_trackingAreaDN]

    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    if unit_type == "ASOE":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=8, tracking_area_id=200)
        delta.extend(nrplmnsets)
    elif unit_type == "ASIL":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=4, tracking_area_id=200)
        delta.extend(nrplmnsets)

    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def adjust_parameters_after_7883_TC026_TC27():
    nrcell_trackingArea_200 = delete_TRACKINGAREA_object(id_="200", return_only=True)
    nrcell_trackingArea_0 = create_TRACKINGAREA_object(id_="0", return_only=True)
    nrplmnset1 = update_NRPLMNSET_object(return_only=True, id_=1, trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-0",
                                         nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])
    nrplmnset1_cell2 = update_NRPLMNSET_object(return_only=True, id_=1, cell=2,
                                               trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-0",
                                               nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])
    nrcell_trackingAreaDN = update_NRCELL_trackingAreaDN_parameter(id_="0", return_only=True)
    delta = [nrcell_trackingArea_0, nrcell_trackingArea_200, nrplmnset1, nrplmnset1_cell2, nrcell_trackingAreaDN]

    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    if unit_type == "ASOE":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=8, tracking_area_id=0)
        delta.extend(nrplmnsets)
    elif unit_type == "ASIL":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=4, tracking_area_id=0)
        delta.extend(nrplmnsets)

    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell, last_cell, tracking_area_id):
    nrplmnsets = []
    for cell in range(fist_cell, last_cell + 1):
        nrplmnset = update_NRPLMNSET_object(return_only=True, id_=1, cell=cell,
                                            trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-{}".format(tracking_area_id),
                                            nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])
        nrplmnsets.append(nrplmnset)
    return nrplmnsets


def adjust_parameters_for_7883_TC012_TC023():
    nrplmnset1 = update_NRPLMNSET_object(return_only=True, id_=1, trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                                         nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1", "MRBTS-1/NRBTS-1/NRPLMN-2"])

    nrplmnset1_cell2 = update_NRPLMNSET_object(return_only=True, id_=1, cell=2,
                                               trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-200",
                                               nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])

    nrplmnset2 = create_NRPLMNSET_object(return_only=True, id_=2, trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-400",
                                         nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-4", "MRBTS-1/NRBTS-1/NRPLMN-5"])

    adj_nrplmnset1 = create_ADJ_NRPLMNSET_object(return_only=True, id_=1, fiveGsTac="0",
                                                 nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-2", "MRBTS-1/NRBTS-1/NRPLMN-3"])

    adj_nrplmnset2 = create_ADJ_NRPLMNSET_object(return_only=True, id_=2, fiveGsTac="100",
                                                 nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-5"])

    nrbts = adjust_NRBTS_parameters_values_for_7883_TC012_TC023(return_only=True)

    nrcell_trackingAreaDN = delete_NRCELL_trackingAreaDN_parameter(return_only=True)

    servedamf1 = update_SERVEDAMF_object(return_only=True, id_="1", amfIPAddress="10.0.1.1", ngTnlId="1",
                                         defaultAMF="true")

    servedamf2 = create_SERVEDAMF_object(return_only=True, id_="2", amfIPAddress="10.0.1.200", ngTnlId="2",
                                         defaultAMF="true")

    nrcell_trackingArea_0 = delete_TRACKINGAREA_object(id_="0", return_only=True)
    nrcell_trackingArea_200 = create_TRACKINGAREA_object(id_="200", return_only=True)

    delta = [servedamf1, servedamf2, nrbts, nrcell_trackingAreaDN, nrplmnset1, nrplmnset1_cell2,
             nrplmnset2, adj_nrplmnset1, adj_nrplmnset2, nrcell_trackingArea_0, nrcell_trackingArea_200]

    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    if unit_type == "ASOE":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=8, tracking_area_id=200)
        delta.extend(nrplmnsets)
    elif unit_type == "ASIL":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=4, tracking_area_id=200)
        delta.extend(nrplmnsets)

    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


@handle_admin
def update_NRBTS_xnCplane_values(xnCplane_mapping=None, return_only=False, *args, **kwargs):
    if xnCplane_mapping is None:
        xnCplane_mapping = {"ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"}
    delta = {
      "distName": "MRBTS-1/NRBTS-1",
      "operation": "update",
      "parameters": [
         {
            "parameterName": "xnCplane",
            "value": [xnCplane_mapping],
            "operation": "update"
         }
      ]
    }
    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def create_IPADDRESSV6_object(return_only=False, *args, **kwargs):
    delta = [{
            "distName": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1",
            "operation": "create",
            "parameters": [{
                    "parameterName": "ipAddressAllocationMethod",
                    "value": "MANUAL",
                    "operation": "update"
                }, {
                    "parameterName": "localIpAddr",
                    "value": "fd94:e15d:8bda:aefc::1:25",
                    "operation": "update"
                }, {
                    "parameterName": "localIpPrefixLength",
                    "value": "64",
                    "operation": "update"
                }
            ]
        }
    ]
    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps(delta),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def remove_IPADDRESSV6_object(return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1",
        "operation": "delete",
        "parameters": []
    }

    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


def remove_IPADDRESSV6_and_update_xnCplane_in_NRBTS_after_IP_version_selection_tests():
    ipaddressv6 = remove_IPADDRESSV6_object(return_only=True)
    xnCplane = update_NRBTS_xnCplane_values(return_only=True)
    delta = [ipaddressv6, xnCplane]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def adjust_parameters_after_7883_TC012_TC023():

    nrbts = adjust_NRBTS_parameters_after_7883_TC012_TC023(return_only=True)

    servedamf1 = update_SERVEDAMF_object(return_only=True, id_="1", amfIPAddress="10.0.1.1", defaultAMF="true")

    servedamf2 = delete_SERVEDAMF_object(return_only=True, id_="2")

    nrplmnset1 = update_NRPLMNSET_object(return_only=True, id_=1, trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-0",
                                         nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])

    nrplmnset1_cell2 = update_NRPLMNSET_object(return_only=True, id_=1, cell=2,
                                               trackingAreaDN="MRBTS-1/NRBTS-1/TRACKINGAREA-0",
                                               nrPlmnDNList=["MRBTS-1/NRBTS-1/NRPLMN-1"])

    nrcell_trackingArea_200 = delete_TRACKINGAREA_object(id_="200", return_only=True)
    nrcell_trackingArea_0 = create_TRACKINGAREA_object(id_="0", fiveGsTac="200", return_only=True)
    nrcell_trackingAreaDN = update_NRCELL_trackingAreaDN_parameter(id_="0", return_only=True)

    delta = [nrbts, servedamf1, servedamf2, nrplmnset1, nrplmnset1_cell2, nrcell_trackingArea_0,
             nrcell_trackingArea_200, nrplmnset1, nrcell_trackingAreaDN]

    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    if unit_type == "ASOE":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=8, tracking_area_id=0)
        delta.extend(nrplmnsets)
    elif unit_type == "ASIL":
        nrplmnsets = prepare_delta_for_NRPLMNSETs_from_cell_to_cell(fist_cell=3, last_cell=4, tracking_area_id=0)
        delta.extend(nrplmnsets)

    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


@handle_admin
def adjust_NRBTS_parameters_after_7883_TC012_TC023(return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [{
            "parameterName": "actNgcFlexSaMode",
            "value": "false",
            "operation": "update"
        }, {
            "parameterName": "actRanSharing",
            "value": "false",
            "operation": "update"
        }, {
            "parameterName": "actTrsSepaSARanSharing",
            "value": "false",
            "operation": "update"
        }, {
            "parameterName": "ngCplane",
            "value": [{
                    "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
                }
            ],
            "operation": "update"
        }, {
            "parameterName": "ngUplane",
            "value": [{
                    "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
                }
            ],
            "operation": "update"
        }, {
            "parameterName": "xnCplane",
            "value": [{
                    "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
                }
            ],
            "operation": "update"
        }, {
            "parameterName": "xnUplane",
            "value": [{
                    "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1"
                }
            ],
            "operation": "update"
        }]
    }

    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def adjust_NRBTS_parameters_values_for_7883_TC012_TC023(return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [{
                "parameterName": "ngCplane",
                "value": [{
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1",
                        "ngTnlId": "1"
                    }, {
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-2",
                        "ngTnlId": "2"
                    }
                ],
                "operation": "update"
            }, {
                "parameterName": "ngUplane",
                "value": [{
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-7",
                        "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1"
                    }, {
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-8",
                        "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-2"
                    }
                ],
                "operation": "update"
            }, {
                "parameterName": "xnCplane",
                "value": [{
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-3",
                        "xnTnlId": "1"
                    }, {
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-4",
                        "xnTnlId": "2"
                    }
                ],
                "operation": "update"
            }, {
                "parameterName": "xnUplane",
                "value": [{
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-5",
                        "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-1"
                    }, {
                        "ipV4AddressDN1": "MRBTS-1/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-6",
                        "nrPlmnDN": "MRBTS-1/NRBTS-1/NRPLMN-2"
                    }
                ],
                "operation": "update"
            }, {
                "parameterName": "actNgcFlexSaMode",
                "value": "true",
                "operation": "update"
            }, {
                "parameterName": "actRanSharing",
                "value": "true",
                "operation": "update"
            }, {
                "parameterName": "actTrsSepaSARanSharing",
                "value": "true",
                "operation": "update"
            }]
        }
    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def create_SERVEDAMF_object(id_="1", amfIPAddress="10.0.1.1", ngTnlId="1", defaultAMF="true",
                            administrativeState="Unlocked", return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-{}".format(id_), "operation": "create", "parameters": [
            {"parameterName": "amfIPAddress", "value": amfIPAddress, "operation": "update"},
            {"parameterName": "defaultAMF", "value": defaultAMF, "operation": "update"},
            {"parameterName": "administrativeState", "value": administrativeState, "operation": "update"},
            {"parameterName": "servedAmfId", "value": id_, "operation": "update"}
        ]
    }
    if ngTnlId:
        delta['parameters'].append({"parameterName": "ngTnlId", "value": ngTnlId, "operation": "update"})
    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def delete_SERVEDAMF_object(id_="1", return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-{}".format(id_), "operation": "delete", "parameters": []
    }
    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


@handle_admin
def update_SERVEDAMF_object(id_="1", amfIPAddress="10.0.1.1", ngTnlId=None, defaultAMF="true", return_only=False,
                            administrativeState=None, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/SERVEDAMF-{}".format(id_), "operation": "update", "parameters": [
            {"parameterName": "amfIPAddress", "value": amfIPAddress, "operation": "update"},
            {"parameterName": "defaultAMF", "value": defaultAMF, "operation": "update"},
        ]
    }
    if ngTnlId:
        delta['parameters'].append({"parameterName": "ngTnlId", "value": ngTnlId, "operation": "update"})
    else:
        delta['parameters'].append({"parameterName": "ngTnlId", "value": "", "operation": "delete"})
    if administrativeState:
        delta['parameters'].append(
            {"parameterName": "administrativeState", "value": administrativeState, "operation": "update"})
    if return_only:
        return delta
    else:
        kwargs["connection"].perform_delta_recommissioning(delta_file=json.dumps([delta]),
                                                           skip_parameter_relation_errors=True,
                                                           should_activate=True,
                                                           timeout=180)


def create_NRRELs_and_NRADJNRCELLs_for_C003():
    nrrel1 = create_NRREL_object(return_only=True, id_="1", gNbId="1", gNbIdLength="22", lcrId="2",
                                 use_sCellAdditionMethod=False)
    nrrel2 = create_NRREL_object(return_only=True, id_="2", gNbId="2", gNbIdLength="22", lcrId="2",
                                 removeNotAllowed="true", use_sCellAdditionMethod=False)
    nrrel3 = create_NRREL_object(return_only=True, id_="3", gNbId="2", gNbIdLength="22", lcrId="3",
                                 use_sCellAdditionMethod=False)
    nrrel4 = create_NRREL_object(return_only=True, id_="4", gNbId="2", gNbIdLength="22", lcrId="4",
                                 use_sCellAdditionMethod=True)

    nradjnrcell1 = create_NRADJNRCELL_object(return_only=True, id_="1", gNbId="2", gNbIdLength="22",
                                             lcrId="2", nrarfcn="640000", physCellId="71", cellDepType="SA")
    nradjnrcell2 = create_NRADJNRCELL_object(return_only=True, id_="2", gNbId="2", gNbIdLength="22",
                                             lcrId="3", nrarfcn="700000", ssbFrequency="700000", physCellId="70",
                                             cellDepType="SA")
    nradjnrcell3 = create_NRADJNRCELL_object(return_only=True, id_="3", gNbId="2", gNbIdLength="22",
                                             lcrId="4", nrarfcn="636666", ssbFrequency="636576", physCellId="69",
                                             cellDepType="SA")

    delta = [nrrel1, nrrel2, nradjnrcell1, nrrel3, nradjnrcell2, nrrel4, nradjnrcell3]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def reboot_ap():
    logger_console("Reboot AP using 'system-module-reboot' command")
    sshpass_cmd = 'sshpass -p "oZPS0POrRieRtu" ssh -o StrictHostKeyChecking=no  -o GlobalKnownHostsFile=/dev/null/ '\
                  '-o UserKnownHostsFile=/dev/null -q toor4nsn@192.168.200.1  \'system-module-reboot\''
    subprocess.Popen(sshpass_cmd, shell=True, stdout=subprocess.PIPE)
    sleep(10)
    logger_console("Killing hanging sshpass processes")
    OperatingSystem().run("pkill sshpass")


def delete_xnlink_nradjgnb_and_update_servedamf1_and_create_servedamf2(amf1_administrative_state="Locked"):
    min_nradjgnb_id = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    xnlink = delete_XNLINK_object(return_only=True)
    nradjgnb = delete_NRADJGNB_object(id_=min_nradjgnb_id+1, return_only=True)

    servedamf1 = update_SERVEDAMF_object(return_only=True, id_="1", amfIPAddress="66.66.66.66", defaultAMF="true",
                                         administrativeState=amf1_administrative_state)

    servedamf2 = create_SERVEDAMF_object(return_only=True, id_="2", amfIPAddress="10.0.1.1", amfIPAddressTTL="5",
                                         defaultAMF="true", administrativeState="Unlocked", ngTnlId=None)

    delta = [xnlink, nradjgnb, servedamf1, servedamf2]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def prepare_scf_for_customer_amf_tests():
    min_xnlink_id = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    min_nradjgnb_id = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    nrrel = create_NRREL_object(id_="1", gNbId="2", gNbIdLength="22", lcrId="1", use_sCellAdditionMethod=False,
                                return_only=True)
    nradjnrcell = create_NRADJNRCELL_object(id_="1", gNbId="2", gNbIdLength="22", physCellId="49", return_only=True)
    xnlink = create_XNLINK_object(id_=str(min_xnlink_id), return_only=True)
    nradjgnb = create_NRADJGNB_object(id_=min_nradjgnb_id+1, xnLinkRef=str(min_xnlink_id), return_only=True)
    ngc_flex_param = {
        "distName": "MRBTS-1/NRBTS-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "actNgcFlexSaMode",
                "value": "true",
                "operation": "update"
            }
        ]
    }
    long_pucch_cell2 = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "pucchModeSelect",
                "value": "longPucch",
                "operation": "update"
            }
        ]
    }
    tac_cell2 = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-2/NRPLMNSET_SA-1",
        "operation": "update",
        "parameters": [
            {
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-0",
                "operation": "update"
            }
        ]
    }
    delta = [nrrel, nradjnrcell, xnlink, nradjgnb, ngc_flex_param, long_pucch_cell2, tac_cell2]
    perform_recomissioning_with_delta(path_to_delta=json.dumps(delta))


def create_second_ANR_profile_object():
    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRANRPR-2",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "anrThresRsrpNbCell",
                "value": "-40",
                "operation": "update"
            },
            {
                "parameterName": "cellDepMode",
                "value": "SA",
                "operation": "update"
            },
            {
                "parameterName": "consecRecheckForNrNbRemoval",
                "value": "1",
                "operation": "update"
            },
            {
                "parameterName": "idleTimeForNrNbRemoval",
                "value": "2",
                "operation": "update"
            },
            {
                "parameterName": "maxNumAnrNrrelAllowed",
                "value": "50",
                "operation": "update"
            },
        ]
    }
    ssb_freq_value = "636576" if unit_type != "ASIK" else "633216"
    delta['parameters'].append({"parameterName": "ssbFrequency", "value": ssb_freq_value, "operation": "update"})
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R1" and release != "SBTS21B":
        delta['parameters'].append({"parameterName": "anrThresholdSelector", "value": "RSRP", "operation": "update"})
    perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


def create_default_ANR_profile_object():
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRANRPR-1",
        "operation": "create",
        "parameters": [
            {
                "parameterName": "anrThresRsrpNbCell",
                "value": "-90",
                "operation": "update"
            },
            {
                "parameterName": "cellDepMode",
                "value": "SA",
                "operation": "update"
            },
            {
                "parameterName": "consecRecheckForNrNbRemoval",
                "value": "5",
                "operation": "update"
            },
            {
                "parameterName": "idleTimeForNrNbRemoval",
                "value": "72",
                "operation": "update"
            },
            {
                "parameterName": "maxNumAnrNrrelAllowed",
                "value": "50",
                "operation": "update"
            }
        ]
    }
    release = BuiltIn().get_variable_value("${RELEASE}")
    if release != "SBTS22R1" and release != "SBTS21B":
        delta['parameters'].append({"parameterName": "anrThresholdSelector", "value": "RSRP", "operation": "update"})
    perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def create_TRACKINGAREA_object(id_="200", fiveGsTac="0", return_only=False,  *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/TRACKINGAREA-{}".format(id_),
        "operation": "create",
        "parameters": [{
                "parameterName": "fiveGsTac",
                "value": fiveGsTac,
                "operation": "update"
            }, {
                "parameterName": "snssaiList",
                "value": [{
                        "snssaiDN": "MRBTS-1/NRBTS-1/SNSSAI-1"
                    }
                ],
                "operation": "update"
            }, {
                "parameterName": "trackingAreaId",
                "value": id_,
                "operation": "update"
            }
        ]
    }
    if return_only:
        return delta
    else:
        perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def delete_TRACKINGAREA_object(id_="0",  return_only=False,  *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/TRACKINGAREA-{}".format(id_),
        "operation": "delete",
        "parameters": []
    }
    if return_only:
        return delta
    else:
        perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def delete_XNLINK_object(id_=None,  return_only=False,  *args, **kwargs):
    if id_ is None:
        id_ = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    delta = {
        "distName": "MRBTS-1/NRBTS-1/XNLINK-{}".format(id_),
        "operation": "delete",
        "parameters": []
    }
    if return_only:
        return delta
    else:
        perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def delete_NRADJGNB_object(id_=None, return_only=False, *args, **kwargs):
    if id_ is None:
        id_ = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRADJGNB-{}".format(id_),
        "operation": "delete",
        "parameters": []
    }
    if return_only:
        return delta
    else:
        perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def update_NRCELL_trackingAreaDN_parameter(id_="200", return_only=False,  *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [{
                "parameterName": "trackingAreaDN",
                "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-{}".format(id_),
                "operation": "update"
            }
        ]
    }
    if return_only:
        return delta
    else:
        perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def delete_NRCELL_trackingAreaDN_parameter(id_="200", return_only=False, *args, **kwargs):
    delta = {
        "distName": "MRBTS-1/NRBTS-1/NRCELL-1",
        "operation": "update",
        "parameters": [{
            "parameterName": "trackingAreaDN",
            "value": "MRBTS-1/NRBTS-1/TRACKINGAREA-{}".format(id_),
            "operation": "delete"
        }]
    }
    if return_only:
        return delta
    else:
        perform_recomissioning_with_delta(path_to_delta=json.dumps([delta]))


@handle_admin
def delete_NRADJNRCELL_fiveGsTac(*args, **kwargs):
    parameters = [{"parameterName": "fiveGsTac", "value": "", "operation": "delete"}]
    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1/NRADJNRCELL-1",
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=60,
                                                        operation="update")


@handle_admin
def delete_gnbIdLengthConfig(*args, **kwargs):
    parameters = [{"parameterName": "gNbIdLengthConfig", "value": "", "operation": "delete"}]
    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1/NRANR-1",
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=60,
                                                        operation="update")


@handle_admin
def set_gnbIdLengthConfig(value=None, *args, **kwargs):
    if value is None:
        value = GNB_ID_LENGTH_CONFIG_DEFAULT
    parameters = [{"parameterName": "gNbIdLengthConfig", "value": value, "operation": "update"}]
    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1/NRANR-1",
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=300,
                                                        operation="update")


def update_gnbIdLengthConfig(second_structure):
    set_gnbIdLengthConfig(value=[GNB_ID_LENGTH_CONFIG_1ST_STRUCTURE, second_structure])


@handle_admin
def set_NRBTS_ngSetupRespTmr(value="0", *args, **kwargs):
    parameters = [{"parameterName": "ngSetupRespTmr", "value": value, "operation": "update"}]
    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1",
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=300,
                                                        operation="update")


@handle_admin
def set_NRBTS_actConflictConfiguration(value="true", *args, **kwargs):
    parameters = [{"parameterName": "actConflictConfiguration", "value": value, "operation": "update"}]
    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1",
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=300,
                                                        operation="update")


@handle_admin
def set_NRBTS_SNSSAI_administrativeState(value="Unlocked", *args, **kwargs):
    parameters = [{"parameterName": "administrativeState", "value": value, "operation": "update"}]
    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1/SNSSAI-1",
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=300,
                                                        operation="update")


def ensure_gNbIdLengthConfig_values_are_set_to_default():
    values_in_scf = load_scf_from_site_and_get_taf_scf_instance().get_all_values_from_scf_by_pattern(
        dist_name="MRBTS-1/NRBTS-1/NRANR-1",
        list_name="gNbIdLengthConfig")
    default_values = ['30', '100001', '100000', '1', '25', '2']
    if values_in_scf == default_values:
        logger_console("gNbIdLengthConfig has default values")
    else:
        set_gnbIdLengthConfig()


@handle_admin
def change_NRADJGNB_parameters(change_gNodeBId=False, change_plmn=False, id_=None, *args, **kwargs):
    if id_ is None:
        id_ = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    if not change_gNodeBId and not change_plmn:
        logger_console("Didn't have to change NRADJGNB parameters")
        return
    parameters = []
    if change_gNodeBId is True:
        parameters.append({"parameterName": "gNodeBId", "value": "1", "operation": "update"})
    if change_plmn is True:
        parameters.append({
            "parameterName": "gnbPlmn",
            "value": [
                {
                    "mcc": "1",
                    "mnc": "1",
                    "mncLength": "2"
                }
            ],
            "operation": "update"
        })

    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1/NRADJGNB-{}".format(id_),
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=60,
                                                        operation="update")


@handle_admin
def set_default_values_for_NRADJGNB_parameters(id_=None, *args, **kwargs):
    if id_ is None:
        id_ = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    parameters = [
        {"parameterName": "gNodeBId", "value": "2", "operation": "update"},
        {
            "parameterName": "gnbPlmn",
            "value": [
                {
                    "mcc": "311",
                    "mnc": "489",
                    "mncLength": "3"
                }
            ],
            "operation": "update"
        }]

    kwargs["connection"].perform_object_recommissioning(parameter=parameters,
                                                        dist_name="MRBTS-1/NRBTS-1/NRADJGNB-{}".format(id_),
                                                        skip_parameter_relation_errors=True,
                                                        should_activate=True,
                                                        timeout=60,
                                                        operation="update")


def assert_feature_flag_activated():
    feature_param_value = get_feature_activation_parameter_value()
    assert feature_param_value == "True", "Feature flag is not activated, whereas it should be by now"
    logger_console_info("Feature flag actSaUeBasedAnrNr is activated")


def assert_feature_flag_deactivated():
    feature_param_value = get_feature_activation_parameter_value()
    assert feature_param_value == "False", "Feature flag is activated, whereas it should not be by now"
    logger_console_info("Feature flag actSaUeBasedAnrNr is deactivated")


def assert_rdNeighRemovalEvaluationTime(value=3):
    unit_type = BuiltIn().get_variable_value("${UNIT_NAME}")
    cmd = "cat /tmp/node_CPCL00/opt/nokia/SS_CPLANE/etc/cp_cl.enb_conf.ini | grep rdNeighRem"
    rc, output = run_on_gnb(cmd)
    real_value = int(output.split('=')[1])
    msg = "rdNeighRemovalEvaluationTime: value != {}; value = {}".format(value, real_value)
    assert real_value == int(value), msg


def assert_last_nrrel_did_not_change():
    last_nrrel_dist_name = BuiltIn().get_variable_value("${LAST_NRREL_DIST_NAME}")
    nrrel_lcrId = get_parameter_value_from_scf(dist_name=last_nrrel_dist_name, parameter="lcrId")
    assert nrrel_lcrId != 2
    logger_console_info("{} did not change during the procedure. This is the expected behaviour".format(
        last_nrrel_dist_name))


def assert_nradjnrcell_pci_value_is(nradjnrcell_id=1, pci_value=49):
    dist_name = "MRBTS-1/NRBTS-1/NRADJNRCELL-{}".format(nradjnrcell_id)
    assert_parameter_value(dist_name=dist_name, parameter="physCellId", value=pci_value)
    logger_console_info("{}: physCellId = {}. This is the expected behaviour".format(dist_name, pci_value))


def assert_xnLinkRef_value_is(nradjgnb_id=1, xnlinkref_value=None):
    if xnlinkref_value is None:
        xnlinkref_value = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    dist_name = "MRBTS-1/NRBTS-1/NRADJGNB-{}".format(nradjgnb_id)
    assert_parameter_value(dist_name=dist_name, parameter="xnLinkRef", value=str(xnlinkref_value))
    logger_console_info("{}: xnLinkRef = {}. This is the expected behaviour".format(dist_name, xnlinkref_value))


def assert_no_nrrel_in_scf():
    nrrels = get_nrrel_list()
    assert len(nrrels) == 0, "There are more than 0 NRRELs in SCF"
    logger_console_info("No NRREL present at any cell configuration")


def assert_existance_of_more_than_n_nrrels_in_scf(n=0):
    nrrels = get_nrrel_list()
    assert len(nrrels) > n, "There are <= {} (less or equal to {}) NRRELs in SCF".format(n, n)
    logger_console_info("There are more than {} NRRELs in SCF:".format(n))
    for nrrel in nrrels:
        logger_console_info("\t{}".format(nrrel))


def assert_existance_of_n_nrrels_in_scf(n=0):
    nrrels = get_nrrel_list()
    assert len(nrrels) == int(n), "There are {} NRRELs in SCF, expected number was: {}".format(len(nrrels), n)
    logger_console_info("There are exactly {} NRRELs in SCF:".format(n))
    for nrrel in nrrels:
        logger_console_info("\t{}".format(nrrel))


def assert_absence_of_unneeded_xnlink_objects(except_nr=None, min_nr_of_instances=None, max_nr_of_instances=256):
    if min_nr_of_instances is None:
        min_nr_of_instances = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    if except_nr is not None:
        list_of_possible_objects = ["MRBTS-1/NRBTS-1/XNLINK-{}".format(nr) for nr in
                                    range(min_nr_of_instances, max_nr_of_instances+1) if nr != int(except_nr)]
    else:
        list_of_possible_objects = ["MRBTS-1/NRBTS-1/XNLINK-{}".format(nr) for nr in
                                    range(min_nr_of_instances, max_nr_of_instances+1)]
    assert_existence_of_objects_in_scf(list_of_absent_objects=list_of_possible_objects)


def assert_absence_of_unneeded_nradjgnb_objects(except_nr=None, min_nr_of_instances=None, max_nr_of_instances=256):
    if min_nr_of_instances is None:
        min_nr_of_instances = BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}")
    if except_nr is not None:
        list_of_possible_objects = ["MRBTS-1/NRBTS-1/NRADJGNB-{}".format(nr) for nr in
                                    range(min_nr_of_instances, max_nr_of_instances+1) if nr != int(except_nr)]
    else:
        list_of_possible_objects = ["MRBTS-1/NRBTS-1/NRADJGNB-{}".format(nr) for nr in
                                    range(min_nr_of_instances, max_nr_of_instances+1)]
    assert_existence_of_objects_in_scf(list_of_absent_objects=list_of_possible_objects)


def assert_values_of_parameters_in_managed_object(dist_name, desired_values_of_parameters):
    values_in_scf = get_values_of_parameters_from_scf(dist_name=dist_name,
                                                      parameter_list=desired_values_of_parameters)
    assertion_error_msg = ("Values in SCF do not match with the expected ones in object: {}\n"
                           "Expected values: {}\nSCF values: {}".format(dist_name,
                                                                        desired_values_of_parameters,
                                                                        values_in_scf))
    assert desired_values_of_parameters == values_in_scf, assertion_error_msg


def assert_pcis_in_all_NRAJDNRCELLs():
    values_in_scf = load_scf_from_site_and_get_taf_scf_instance().get_all_values_from_scf_by_pattern(
        dist_name=r'MRBTS-1/NRBTS-1/NRADJNRCELL-.*',
        p_name="physCellId")
    pcis_set = set(values_in_scf)
    assert len(pcis_set) == 1, "In SCF there are different PCI values for NRADJNRCELLs objects: {}".format(pcis_set)
    assert '60' in pcis_set


def assert_values_of_NRREL_object(dist_name=None, id_=None, gNbId="2", gNbIdLength="25", lcrId="1",
                                  mcc="311", mnc="489", mncLength="3", check_removeNotAllowed=False):
    if dist_name is None:
        if id_ is None:
            dist_name = NRREL_DIST_NAME.format("1")
        else:
            dist_name = NRREL_DIST_NAME.format(id_)
    desired_values_of_parameters = [
        {"parameter": "gNbId", "value": gNbId},
        {"parameter": "gNbIdLength", "value": gNbIdLength},
        {"parameter": "lcrId", "value": lcrId},
        {"list_name": "gnbPlmn", "parameter": "mcc", "value": mcc},
        {"list_name": "gnbPlmn", "parameter": "mnc", "value": mnc},
        {"list_name": "gnbPlmn", "parameter": "mncLength", "value": mncLength}
    ]
    if check_removeNotAllowed:
        desired_values_of_parameters.append({"parameter": "removeNotAllowed",  "value": "False"})
    assert_values_of_parameters_in_managed_object(dist_name, desired_values_of_parameters)
    logger_console_info("{}: values in SCF are correct.".format(dist_name))


def assert_values_of_NRADJNRCELL_object(dist_name=None, id_=None, gNbId="2", gNbIdLength="25", lcrId="1",
                                        cellDepType="SA", physCellId="49", mcc="311", mnc="489", mncLength="3",
                                        fiveGsTac=None, ssbFrequency=None):
    if dist_name is None:
        if id_ is None:
            dist_name = NRADJNRCELL_DIST_NAME.format("1")
        else:
            dist_name = NRADJNRCELL_DIST_NAME.format(id_)
    desired_values_of_parameters = [
        {"parameter": "gNbId", "value": gNbId},
        {"parameter": "gNbIdLength", "value": gNbIdLength},
        {"parameter": "lcrId", "value": lcrId},
        {"parameter": "physCellId", "value": physCellId},
        {"list_name": "gnbPlmn", "parameter": "mcc", "value": mcc},
        {"list_name": "gnbPlmn", "parameter": "mnc", "value": mnc},
        {"list_name": "gnbPlmn", "parameter": "mncLength", "value": mncLength}
    ]
    if cellDepType is not None:
        desired_values_of_parameters.append({"parameter": "cellDepType", "value": cellDepType})
    if fiveGsTac is not None:
        desired_values_of_parameters.append({"parameter": "fiveGsTac", "value": fiveGsTac})
    if ssbFrequency is not None:
        desired_values_of_parameters.append({"parameter": "ssbFrequency", "value": ssbFrequency})

    assert_values_of_parameters_in_managed_object(dist_name, desired_values_of_parameters)
    logger_console_info("{}: values in SCF are correct.".format(dist_name))


def assert_values_of_ADJ_NRPLMNSET_SA_object(adj_nr_plmn_set_id="1", nradjnrcell_id="12288", fiveGsTac="0",
                                             nrPlmnDNList=None):
    dist_name = "MRBTS-1/NRBTS-1/NRADJNRCELL-{}/ADJ_NRPLMNSET_SA-{}".format(nradjnrcell_id, adj_nr_plmn_set_id)
    if nrPlmnDNList is None:
        nrPlmnDNList = ["MRBTS-1/NRBTS-1/NRPLMN-1"]

    desired_values_of_parameters = [{"parameter": "fiveGsTac", "value": fiveGsTac}]
    for idx, value in enumerate(nrPlmnDNList):
        desired_values_of_parameters.append({"list_name": "nrPlmnDNList", "value": value, "index": idx})

    assert_values_of_parameters_in_managed_object(dist_name, desired_values_of_parameters)
    nrPlmnDNList_from_scf = load_scf_from_site_and_get_taf_scf_instance().get_all_values_from_scf(
        dist_name=dist_name,
        p_name=None,
        list_name="nrPlmnDNList"
    )
    assert_error_msg = "nrPlmnDNList length is not correct: {}".format(len(nrPlmnDNList_from_scf))
    assert len(nrPlmnDNList) == len(nrPlmnDNList_from_scf), assert_error_msg
    logger_console_info("{}: values in SCF are correct.".format(dist_name))


def assert_values_of_ADJ_NRPLMNSET_NSA_object(adj_nr_plmn_set_id="1", nradjnrcell_id="12288", nrPlmnDNList=None):
    dist_name = "MRBTS-1/NRBTS-1/NRADJNRCELL-{}/ADJ_NRPLMNSET_NSA-{}".format(nradjnrcell_id, adj_nr_plmn_set_id)
    if nrPlmnDNList is None:
        nrPlmnDNList = ["MRBTS-1/NRBTS-1/NRPLMN-1"]

    nrPlmnDNList_from_scf = load_scf_from_site_and_get_taf_scf_instance().get_all_values_from_scf(
        dist_name=dist_name,
        p_name=None,
        list_name="nrPlmnDNList"
    )
    assert nrPlmnDNList == nrPlmnDNList_from_scf, "nrPlmnDNList is not as expected: {}".format(nrPlmnDNList_from_scf)
    logger_console_info("{}: values in SCF are correct.".format(dist_name))


def assert_values_of_XNLINK_object(id_=None, cPlaneIpAddr="10.0.3.151", xnTnlId=None):
    if id_ is None:
        id_ = BuiltIn().get_variable_value("${MIN_XNLINK_ID}")
    dist_name = XNLINK_DIST_NAME.format(id_)
    if xnTnlId is None:
        desired_values_of_parameters = [
            {"parameter": "cPlaneIpAddr", "value": cPlaneIpAddr}
        ]
    else:
        desired_values_of_parameters = [
            {"parameter": "cPlaneIpAddr", "value": cPlaneIpAddr},
            {"parameter": "xnTnlId", "value": xnTnlId}
        ]
    assert_values_of_parameters_in_managed_object(dist_name, desired_values_of_parameters)
    logger_console_info("{}: values in SCF are correct.".format(dist_name))


def assert_values_of_NRADJGNB_object(id_=None, administrativeState="Unlocked", gNbIdLenght="22",
                                     gNodeBId="2", xnLinkRef=None, mcc="311", mnc="489", mncLength="3"):
    if xnLinkRef is None:
        xnLinkRef = str(BuiltIn().get_variable_value("${MIN_XNLINK_ID}"))
    if id_ is None:
        id_ = str(BuiltIn().get_variable_value("${MIN_NRADJGNB_ID}"))
    dist_name = NRADJGNB_DIST_NAME.format(id_)
    desired_values_of_parameters = [
        {"parameter": "administrativeState", "value": administrativeState},
        {"parameter": "gNbIdLength", "value": gNbIdLenght},
        {"parameter": "gNodeBId", "value": gNodeBId},
        {"parameter": "xnLinkRef", "value": str(xnLinkRef)},
        {"list_name": "gnbPlmn", "parameter": "mcc", "value": mcc},
        {"list_name": "gnbPlmn", "parameter": "mnc", "value": mnc},
        {"list_name": "gnbPlmn", "parameter": "mncLength", "value": mncLength}
    ]
    assert_values_of_parameters_in_managed_object(dist_name, desired_values_of_parameters)
    logger_console_info("{}: values in SCF are correct.".format(dist_name))


def assert_values_in_NRREL_and_NRADJNRCELL(nrrel_id=None, nradjnrcell_id="12288", gNbId="2", gNbIdLength="25",
                                           lcrId="1", cellDepType="SA", physCellId="49",
                                           mcc="311", mnc="489", mncLength="3", ssbFrequency=None):
    if nrrel_id is None:
        nrrel_dist_name = BuiltIn().get_variable_value("${LAST_NRREL_DIST_NAME}")
    else:
        nrrel_dist_name = NRREL_DIST_NAME.format(nrrel_id)
    assert_existence_of_an_object(NRADJNRCELL_DIST_NAME.format(nradjnrcell_id))
    assert_existence_of_an_object(nrrel_dist_name)
    assert_values_of_NRADJNRCELL_object(dist_name=NRADJNRCELL_DIST_NAME.format(nradjnrcell_id), gNbId=gNbId,
                                        gNbIdLength=gNbIdLength, lcrId=lcrId, cellDepType=cellDepType,
                                        physCellId=physCellId, mcc=mcc, mnc=mnc, mncLength=mncLength,
                                        ssbFrequency=ssbFrequency)
    assert_values_of_NRREL_object(dist_name=nrrel_dist_name, gNbId=gNbId, gNbIdLength=gNbIdLength, lcrId=lcrId,
                                  mcc=mcc, mnc=mnc, mncLength=mncLength)


def assert_amount_of_XNLINKS_objects(expected_amount=0):
    current_amount = get_amount_of_XNLINK_objects()
    msg = "New XNLINK object added, it was not expected"
    assert current_amount == expected_amount, msg
    logger_console_info("No new XNLINK object added as expected")


def check_counter_STA_UNAVAIL_NRREL_HO_FAILS(cell_id=1):
    period, value = pm_counters.get_latest_counter_value(counter_id="M55147C00022", nr_cell_id=cell_id)
    logger_console("Counter STA_UNAVAIL_NRREL_HO_FAILS: period={}, value={}".format(period, value))
    return value


def check_counter_TOT_INTRA_FREQ_HO_DECISION_A3S(cell_id=1):
    period, value = pm_counters.get_latest_counter_value(counter_id="M55147C00001", nr_cell_id=cell_id)
    logger_console("Counter TOT_INTRA_FREQ_HO_DECISION_A3S: period={}, value={}".format(period, value))
    return value


def check_if_counter_incremented(counter_name, counter_id, cell_id=1, prev_value=0, skip_waiting=False):
    pm_period = BuiltIn().get_variable_value("${PM_PERIOD}")
    logger_console("Waiting for next PM period ({} min)".format(pm_period))
    if not skip_waiting:
        pm_counters.wait_for_next_pm_period(pm_period)
    pm_counters.verify_if_counter_is_incremented_correctly(counter_id=counter_id,
                                                           nr_cell_id=cell_id,
                                                           expected_value=prev_value + 1)
    logger_console("Counter {} incremented correctly".format(counter_name))


def check_if_counter_STA_UNAVAIL_NRREL_HO_FAILS_incremented(cell_id=1, prev_value=0):
    check_if_counter_incremented(counter_name="STA_UNAVAIL_NRREL_HO_FAILS", counter_id="M55147C00022",
                                 cell_id=cell_id, prev_value=prev_value)


def check_if_counter_TOT_INTRA_FREQ_HO_DECISION_A3S_incremented(cell_id=1, prev_value=0):
    check_if_counter_incremented(counter_name="TOT_INTRA_FREQ_HO_DECISION_A3S", counter_id="M55147C00001",
                                 cell_id=cell_id, prev_value=prev_value)


def wait_after_sending_measurement(time_sec=60):
    sleep(time_sec)


def prepare_environment_HO(wts_config_filename=None, sib1_reception_dict=None):
    if sib1_reception_dict is None:
        sib1_reception_dict = CELLS_1XSIM_2XREAL
    delete_localhost_ssh_key_from_known_hosts()
    configure_ransim_vm_interfaces()
    ta5g_testline_management().wait_for_testline_icmp_echo_replies_and_ssh_services()
    ensure_gnb_files_flags_are_in_order()
    log_gnb_build()
    log_airphone_build()
    copy_wts_files_to_epcsim_dir_path(wts_config_filename=wts_config_filename)
    ru_tries = mib_sib_tries = 0
    while ru_tries < 2 and mib_sib_tries < 2:
        try:
            reset_units_and_wait_for_radio_head_online()
            start_collecting_logs()
            # ta5g_setups_and_teardowns().start_default_logging()
            start_wts_and_wait_for_ready_state(
                wts_config_filename=wts_config_filename,
                sib_reception_dict=sib1_reception_dict,
                edaemon_port=30000,
                timeout=720
            )
        except RadioHeadTimeoutException:
            logger_console_info("RadioHeadTimeoutException occurred,  I will restart environment preparation")
            ru_tries += 1
        except (ValueError, ExecutionFailed) as e:
            logger_console_info("Exception occured: {}".format(e))
            logger_console_info("MIB-SIBs did not arrive, I will restart environment preparation")
            ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
            ta5g_egate_instance._ute_wtssim_instance.teardown_all_aliases_for_wts()
            mib_sib_tries += 1
        else:
            break

        if ru_tries >= 2 or mib_sib_tries >= 2:
            raise Exception("Failed preparing environment: RU preparation retries: {}, MIB-SIBs retries: {}".format(
                ru_tries, mib_sib_tries))


def verify_VOnIncomingConnect_prints_existence():
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    print_unexpected = r"Unexpected VOnIncomingConnect"
    try:
        exist_unexpected = ta5g_egate_instance.verify_the_number_of_prints(
            expected_pattern=print_unexpected, filename="/opt/iphy/latest/egate_console.log")
        if exist_unexpected:
            logger_console_info("Expected print was found: {}".format(print_unexpected))
    except ValueError:
        logger_console_info("Expected print does not exist: {}".format(print_unexpected))

    print_releasing = r"Releasing pLink in VOnIncomingConnect"
    try:
        exist_releasing = ta5g_egate_instance.verify_the_number_of_prints(
            expected_pattern=print_releasing,
            filename="/opt/iphy/latest/egate_console.log")
        if exist_releasing:
            logger_console_info("Expected print was found: {}".format(print_releasing))
    except ValueError:
        logger_console_info("Expected print does not exist: {}".format(print_releasing))


def send_A1_measurement_report_for_UE(ue_id=1, pass_regexp=None, fail_regexp=None,
                                      meas_id=2, srsrp_nr=70, sleep_sec=3, wait_after=True, rs_type="ssb"):
    # pass_regexp, fail_regexp = _prepare_validation_of_measurement_reports(ue_id, should_perform_ho,
    #                                                                       pass_regexp, fail_regexp, ho_type)
    ta5g_egate_instance = BuiltIn().get_library_instance('ta5g_egate')
    ta5g_egate_instance._ute_wtssim_instance.execute_egate_command(
        'ue_measurement_send_nr id={} meas_id={} event=A1 rs_type={} '
        'srsrp_nr={}'.format(ue_id, meas_id, rs_type, srsrp_nr))
    # if pass_regexp or should_perform_ho:
    #     logger.info(pass_regexp, also_console=True)
    # elif not should_perform_ho:
    #     logger.info("UE{}: did not perform handover - this was expected".format(ue_id), also_console=True)
    # if wait_after:
    #     sleep(int(sleep_sec))


def change_gscn_in_iphy(gscn_value, cell_id):
    parameters_to_modify = {
        'CPRI-Config/CPRI-RP1-RE_List/RE[{}]/hardware/vcellList/vcell/GSCN'.format(cell_id): gscn_value
    }
    if gscn_value:
        modify_iphy_parameters(
            params_dict=parameters_to_modify,
            logs_dir='/tmp',
            iphy_prefix='new'
        )
        logger.info('IPHY file modified successfully', also_console=True)


def change_duration_of_periodic_removal_cycle_via_aashell(value=60, permanent=True):
    logger.info('Changing rdNeighRemovalEvaluationTime R&D parameter value to {} min'.format(value), also_console=True)
    set_rad_parameter_via_aashell('0x890062', value, permanent=permanent)
    sleep(2)


def assert_rdNeighRemovalEvaluationTimevia_aashell(value):
    real_value = get_rad_parameter_via_aashell(rad_param='0x890062')
    msg = "rdNeighRemovalEvaluationTime: value != {}; value = {}".format(value, real_value)
    assert real_value == str(hex(value)), msg
