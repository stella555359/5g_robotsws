from pathlib import Path

from taf.collectors.tcpdump import tcpdump
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.procedures.resources.python.connections import (
    get_http_connection_credentials, get_ssh_connection_credentials)
from taf.sbts.oam.coam.admin import admin_interface_context
from taf.selenium.sbts import sbts
from taf.transport.ssh import ssh
from test_constants import *

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_verification.pcap_reader import \
    load_pcap
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import \
    wait_for_next_pm_interval_and_get_counters
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import \
    logger

admin = sbts()
bts = GnbCommissioning()
_tcpdump = tcpdump()
_attenuator = rf_attenuator()
_ssh = ssh()
ims2_remote_filepath = "/ffs/run/config/model_5.ims2"


def deattenuate_attach_cell(attenuators, cell=None):
    if cell is None:
        cell = ATTACH_CELL
    attenuator = attenuators[0]
    logger.info(f"Initializing attenuator {attenuator.ip_addr}", also_to_console=True)
    _attenuator.setup_attenuator(attenuator, alias=ATTENUATOR_ALIAS)
    set_ports_attenuation(attenuator.attenuation_port_numbers, 90)
    logger.info(f"Deattenuating cell {cell} to {ATTACH_CELL_ATTENUATION}dB", also_to_console=True)
    set_ports_attenuation(CELL_ATTENUATION_PORTS[cell], ATTACH_CELL_ATTENUATION)


def set_ports_attenuation(ports, value):
    for port in ports:
        _attenuator.set_attenuation(port, value, confirm=True, attenuator_device=ATTENUATOR_ALIAS)


def get_throughput_counters(reference_point=None):
    logger.info("Waiting for next PM counters interval...", also_to_console=True)
    return wait_for_next_pm_interval_and_get_counters(THROUGHPUT_COUNTERS, reference_point=reference_point)


def verify_throughput_counters(counters):
    for counter_dn, counter_values in counters.items():
        if ATTACH_CELL in counter_dn:
            sum_value = sum(value[1] for value in counter_values)
            assert sum_value > 0, f"Tput counter {counter_dn} should be > 0, got {sum_value}"


def check_5g21a_6761_rrm_009():
    http_creds = get_http_connection_credentials("GNB", bts_id=BTS_ID)
    with admin_interface_context(
        bts_host=http_creds["ip"],
        bts_port=http_creds["port"],
        username=http_creds["username"],
        password=http_creds["password"],
    ) as admin:
        cells = admin.get_cells_info()
    for cell in cells:
        if cell["globalCellId"] == CELL_30MHZ_GLOBAL_ID:
            assert cell["status"]["operationalState"] == "enabled", "Cell 30Mhz is not online!"
            return
    raise ValueError(f"Could not find cell with global ID = {CELL_30MHZ_GLOBAL_ID} (30MHz cell)")


def perform_commissioning_8930(value):
    FEATURE_8930_DELTA[0]["parameters"][0]["value"] = value
    bts.perform_bts_delta_commissioning(delta=FEATURE_8930_DELTA, skip_parameter_relation_errors=False)


def set_redirection_fallback():
    bts.perform_bts_delta_commissioning(delta=REDIR_FALLBACK_DELTA, skip_parameter_relation_errors=False)


def filter_old_counters(dict1, dict2):
    result = {}

    for key, inner_dict1 in dict1.items():
        if key in dict2:
            inner_result = {}
            for inner_key, list1 in inner_dict1.items():
                list2 = dict2[key].get(inner_key, [])
                match_length = sum(1 for a, b in zip(list1, list2) if a == b)
                inner_result[inner_key] = list2[match_length:]
            result[key] = inner_result

    return result


def check_last_n_values_higher_than_x(data_dict, n, x, dist_name):
    object_id = dist_name.split('-')[-1]

    for outer_key, outer_value in data_dict.items():
        for inner_key, value_list in outer_value.items():
            if object_id in inner_key:
                if len(value_list) < int(n):
                    check_length = len(value_list)
                else:
                    check_length = int(n)
                assert any(int(value) > int(x) for value in value_list[-check_length:]), "Counters not raised properly"
    return


def start_tcpdump(gnb_cu, alias="tcpdump_vc"):
    gnb_cu_ssh_config = {
        "host": gnb_cu.oam_ssh_connection_details.addr,
        "user": gnb_cu.oam_ssh_connection_details.username,
        "password": gnb_cu.oam_ssh_connection_details.password,
    }
    options = "-i any sctp port \\(36412 or 36422 or 38412 or 38422 or 38462 or 38472\\) -c 250000"
    _tcpdump.create_tcpdump_collector(name=alias, options=options, executor=gnb_cu_ssh_config)
    _tcpdump.setup_collectors(names=alias)
    _tcpdump.start_collectors(names=alias)
    _tcpdump.set_suite_alias(alias)
    logger.info("tcpdump started!", also_to_console=True)


def stop_tcpdump(output_dir, alias="tcpdump_vc"):
    _tcpdump.stop_collectors(names=alias)
    _tcpdump.collect_collectors(names=alias, target_dir=output_dir)
    _tcpdump.teardown_collectors(names=alias)
    logger.info("tcpdump stopped", also_to_console=True)


def check_voice_redirection_in_pcap(pcap_path, output_file_path):
    fields = (
        "s1ap.E_RABSetupRequest_element",
        "s1ap.qCI",
        "ngap.PDUSessionResourceModifyRequest_element",
        "ngap.fiveQI",
        "ngap.PDUSessionResourceModifyResponse_element",
        "ngap.PDUSessionResourceReleaseCommand_element",
        "e1ap.BearerContextReleaseCommand_element",
        "nokiaf1ap.UEContextReleaseCommand_element",
        "ngap.UEContextReleaseCommand_element",
    )
    messages = (
        msg["_source"]["layers"]
        for msg in load_pcap(pcap_path, tshark_fields=fields, output_json_file=output_file_path)
    )
    checklist = {msg: False for msg in fields}
    for msg in messages:
        if "s1ap.E_RABSetupRequest_element" in msg:
            checklist["s1ap.E_RABSetupRequest_element"] = True
            if msg["s1ap.qCI"] == ["1"]:
                checklist["s1ap.qCI"] = True
        if "ngap.PDUSessionResourceModifyRequest_element" in msg:
            checklist["ngap.PDUSessionResourceModifyRequest_element"] = True
            if "ngap.fiveQI" in msg and msg["ngap.fiveQI"] == ["1"]:
                checklist["ngap.fiveQI"] = True
        if checklist["s1ap.qCI"] and checklist["ngap.fiveQI"]:
            break
    _fill_checklist(checklist, messages, "ngap.PDUSessionResourceModifyResponse_element")
    _fill_checklist(checklist, messages, "ngap.PDUSessionResourceReleaseCommand_element")
    _fill_checklist_parallel(
        checklist,
        messages,
        (
            "e1ap.BearerContextReleaseCommand_element",
            "ngap.UEContextReleaseCommand_element",
            "nokiaf1ap.UEContextReleaseCommand_element",
        ),
    )
    assert all(checklist.values()), f"Bad message flow; Checklist: {checklist}"


def _fill_checklist(checklist, messages, msg_name):
    for msg in messages:
        if msg_name in msg:
            checklist[msg_name] = True
            return


def _fill_checklist_parallel(checklist, messages, msg_names):
    for msg in messages:
        for msg_name in msg_names:
            if msg_name in msg:
                checklist[msg_name] = True
        if all(checklist[msg_name] for msg_name in msg_names):
            return


def backup_ims2(backup_dir="/tmp"):
    connection = _connect_to_bts_via_ssh()
    try:
        _ssh.send_command(f"cp {ims2_remote_filepath} {ims2_remote_filepath}.backup", connection=connection)
        _ssh.download_file(
            ims2_remote_filepath, Path(backup_dir) / ims2_remote_filepath.rsplit("/", 1)[-1], connection=connection
        )
    finally:
        _ssh.disconnect(connection)


def _run_cmd_on_bts(cmd):
    connection = _connect_to_bts_via_ssh()
    try:
        return _ssh.execute(cmd, connection=connection)
    finally:
        _ssh.disconnect(connection)


def _connect_to_bts_via_ssh():
    ssh_creds = get_ssh_connection_credentials(bts_id=BTS_ID, common_unit_id=CU_ID)
    alias = f"bts_{BTS_ID}_cu_{CU_ID}"
    _ssh.connect_to(
        hostname=ssh_creds["host"], username=ssh_creds["username"], password=ssh_creds["password"], alias=alias
    )
    return alias


def change_ims2_to_empty_file():
    logger.info(f"Truncating {ims2_remote_filepath} file", also_to_console=True)
    _run_cmd_on_bts(f"cat /dev/null > {ims2_remote_filepath}")


def remove_read_permissions_from_ims2():
    logger.info(f"Removing read permissions from {ims2_remote_filepath} file", also_to_console=True)
    _run_cmd_on_bts(f"chmod ugo-r {ims2_remote_filepath}")


def change_ims2_to_invalid_file():
    logger.info(f"Swapping {ims2_remote_filepath} file for a non-empty invalid file", also_to_console=True)
    _run_cmd_on_bts(f"ls -l /ffs/run/config > {ims2_remote_filepath}")


def remove_ims2():
    logger.info(f"Removing {ims2_remote_filepath} file", also_to_console=True)
    _run_cmd_on_bts(f"rm {ims2_remote_filepath}")


def restore_ims2():
    logger.info(f"Restoring {ims2_remote_filepath} file", also_to_console=True)
    _run_cmd_on_bts(f"cp {ims2_remote_filepath}.backup {ims2_remote_filepath}")
    _run_cmd_on_bts(f"chown $(stat -c %G:%G .) {ims2_remote_filepath}")
    _run_cmd_on_bts(f"chmod ugo+r {ims2_remote_filepath}")


def trigger_sanity_check_and_expect_fault(checkpoint_name):
    logger.info("Triggering sanity check - expecting fail...", also_to_console=True)
    response = _trigger_sanity_check()["requestMessage"]
    for checkpoint in response:
        if checkpoint["checkpointName"].lower() == checkpoint_name.lower():
            assert "fail" in checkpoint["checkStatus"].lower(), (
                f"Sanity check '{checkpoint['checkpointName']}' "
                f"should report failure, got "
                f"'{checkpoint['checkStatus']}'"
            )
    assert _is_fault_4681_raised_on_bts(), "Fault 4681 is not active on BTS!"


def trigger_sanity_check_and_expect_success(checkpoint_name):
    logger.info("Triggering sanity check - expecting success...", also_to_console=True)
    response = _trigger_sanity_check()["requestMessage"]
    for checkpoint in response:
        if checkpoint["checkpointName"].lower() == checkpoint_name.lower():
            assert "success" in checkpoint["checkStatus"].lower(), (
                f"Sanity check '{checkpoint['checkpointName']}' "
                f"should report success, got "
                f"'{checkpoint['checkStatus']}'"
            )
    assert not _is_fault_4681_raised_on_bts(), "Fault 4681 should not be raised on BTS!"


def _trigger_sanity_check():
    http_creds = get_http_connection_credentials("GNB", bts_id=BTS_ID)
    with admin_interface_context(
        bts_host=http_creds["ip"],
        bts_port=http_creds["port"],
        username=http_creds["username"],
        password=http_creds["password"],
    ) as admin:
        return admin.run_sanity_check()


def _is_fault_4681_raised_on_bts():
    http_creds = get_http_connection_credentials("GNB", bts_id=BTS_ID)
    with admin_interface_context(
        bts_host=http_creds["ip"],
        bts_port=http_creds["port"],
        username=http_creds["username"],
        password=http_creds["password"],
    ) as admin:
        for alarm in admin.get_active_alarms():
            if alarm["faultId"] == 4681:
                return True
    return False


def get_number_of_cpri_rmods():
    http_creds = get_http_connection_credentials("GNB", bts_id=BTS_ID)
    with admin_interface_context(
        bts_host=http_creds["ip"],
        bts_port=http_creds["port"],
        username=http_creds["username"],
        password=http_creds["password"],
    ) as admin:
        rmods = admin.get_parameters_for_all("RMOD")
        return len([rmod for rmod in rmods if "CPRI_RP" in rmod["l3Protocol"]])


def login_selenium(dl_dir):
    http_creds = get_http_connection_credentials("GNB", bts_id=BTS_ID)
    admin.login("https://192.168.255.129", http_creds["username"], http_creds["password"], download_dir=dl_dir)


def start_antl_monitoring(dl_dir):
    login_selenium(dl_dir)
    admin.select_antenna_lines_for_monitoring()
    admin.start_antenna_line_monitoring()


def stop_antl_monitoring():
    admin.stop_antenna_line_monitoring()
    file = admin.export_monitored_value_to_csv()
    admin.close_browser()
    return file


def analyze_antl_monitoring_file(cpri_rmod_number, antl_file):
    with open(antl_file) as f:
        for line in f:
            if line.strip().endswith("VSWR"):
                next(f)
                vswr = set()
                while line := next(f).strip():
                    vswr.add(line.split(",")[0])
                assert (
                    len(vswr) == cpri_rmod_number
                ), "Number of rmod with VSWR monitored is not equal to number of CPRI rmods!"
                logger.info("ANTL monitoring is correct.", also_to_console=True)
                return True
    raise ValueError("No VSWR section found in monitoring file!")


def set_cb005832_parameters():
    bts.perform_bts_delta_commissioning(delta=FEATURE_5832_DELTA, skip_parameter_relation_errors=False)


def change_sfp_state(state):
    SFP_DELTA[0]["parameters"][0]["value"] = state
    bts.perform_bts_delta_commissioning(delta=SFP_DELTA, skip_parameter_relation_errors=False)
    logger.info(f"SFP state changed to {state}", also_to_console=True)


def assert_fid_61009(should_be_visible):
    http_creds = get_http_connection_credentials("GNB", bts_id=BTS_ID)
    with admin_interface_context(
        bts_host=http_creds["ip"],
        bts_port=http_creds["port"],
        username=http_creds["username"],
        password=http_creds["password"],
    ) as admin:
        faults = admin.get_active_alarms()
    fids = [fault["faultId"] for fault in faults]
    is_visible = 61009 in fids
    assert (
        is_visible == should_be_visible
    ), f"Expected fault id 61009 to {'' if should_be_visible else 'not '}be active. Active FIDs: {fids}"
    logger.info(f"FID 61009 is {'' if is_visible else 'no longer '}active as expected", also_to_console=True)
