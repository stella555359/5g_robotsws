import re
import json
import random
from robot.libraries.BuiltIn import BuiltIn
from time import sleep
from robot.api import logger
from taf.config.scf import scf
from taf.ul.alarms_watchdog import alarms_watchdog
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix, mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.color_log import write_line
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession, LOCALHOST, get_scf_from_nr
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.kpi import (get_parameter_value_from_scf)
from x2_variables import (
    X2_PM_COUNTERS,
    X2_PARAMETERS,
    ALLOWED_ALARMS,
    TESTED_ALARMS,
)

# multi rat
lnbts_id = nrbts_id

scf = scf()

watchdog = alarms_watchdog()


def prepare_scenarios_to_execute(**kwargs):
    scenario_list = []
    for key, value in kwargs.items():
        if value == "YES" and key != "X2_LINK_SHUTDOWN_NO_TRAFFIC":
            scenario_list.append(key)
    scenarios_to_execute = int(kwargs["iteration"]) * scenario_list
    random.shuffle(scenarios_to_execute)
    for key, value in kwargs.items():
        if value == "YES" and key == "X2_LINK_SHUTDOWN_NO_TRAFFIC":
            scenarios_to_execute.append(key)
    write_line(
        "\nThe following randomly sorted {} scenario/s (every one {} times) will be executed:".format(
            len(scenarios_to_execute), kwargs["iteration"]
        ),
        color="blue_bg",
    )
    n = 0
    for i in scenarios_to_execute:
        n += 1
        write_line("\t{}. {}".format(n, i), color="blue_bg")
    return scenarios_to_execute


def prepare_alarms():
    alarms = []
    write_line("\nALARMS allowed on gNB during whole test execution:", color="green")
    for id in ALLOWED_ALARMS:
        alarm = watchdog.create_alarm(
            alarm_id=ALLOWED_ALARMS[id]["alarm_id"],
            fault_id=ALLOWED_ALARMS[id]["fault_id"],
            fault_name=ALLOWED_ALARMS[id]["fault_name"],
        )
        alarms.append(alarm)
        write_line("  - {}".format(ALLOWED_ALARMS[id]["fault_name"]), color="green")
    return alarms


def create_scenario_alarms(alarms):
    scenario_alarms = []
    write_line("\nALARMS allowed on BTS during scenario execution:", color="green")
    for id in alarms:
        alarm = watchdog.create_alarm(
            alarm_id=TESTED_ALARMS[id]["alarm_id"],
            fault_id=TESTED_ALARMS[id]["fault_id"],
            fault_name=TESTED_ALARMS[id]["fault_name"],
        )
        scenario_alarms.append(alarm)
        write_line("  - {}".format(TESTED_ALARMS[id]["fault_name"]), color="green")
    return scenario_alarms


def get_x2_settings_from_scf():
    local_dir_path = BuiltIn().get_variable_value("${OUTPUT DIR}")
    scf_file = get_scf_from_nr(local_dir_path, 'scf.xml', runtime=True)
    logger.info("\n\nx2 parameter settings on gNB:", also_console=True)
    for p in X2_PARAMETERS:
        X2_PARAMETERS[p]["value"] = get_parameter_value_from_scf(
            path=scf_file,
            parameter_abbreviation=p,
            parameter_dist_name="{}".format(bts_prefix),
        )
        logger.info(
            "   {}: {} {} {}".format(
                p.ljust(25),
                X2_PARAMETERS[p]["value"].ljust(3),
                X2_PARAMETERS[p]["unit"].ljust(12),
                X2_PARAMETERS[p]["description"],
            ),
            also_console=True,
        )


def block_all_nr_cells(remote_host='127.0.0.1'):
    with AdminSession(remote_host=remote_host) as admin:
        admin.block_all_cells(rat='NR')
    logger.info("\n All NR cells are blocked", also_console=True)


def unblock_all_nr_cells(remote_host='127.0.0.1'):
    with AdminSession(remote_host=remote_host) as admin:
        admin.unblock_all_cells(rat='NR')
    logger.info("\n All NR cells are unblocked", also_console=True)


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in X2_PM_COUNTERS:
        if isinstance(X2_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                X2_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${X2_PM_COUNTERS}", X2_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(X2_PM_COUNTERS[ne_abbr]["value"], dict):
            X2_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            X2_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${X2_PM_COUNTERS}", X2_PM_COUNTERS)


def increase_counters_based_on_msgs_in_pcap_file(serving_cell, pcap_file):
    for ne_abbr in X2_PM_COUNTERS:
        if X2_PM_COUNTERS[ne_abbr]["shark_filter"] is not None:
            count_message(pcap_file, ne_abbr, serving_cell)
    return X2_PM_COUNTERS


def count_message(pcap_file, ne_abbr, serving_cell):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=X2_PM_COUNTERS[ne_abbr]["shark_filter"],
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    msg_counter = 0
    if "multiplier" in X2_PM_COUNTERS[ne_abbr]:
        multiplier = X2_PM_COUNTERS[ne_abbr]["multiplier"]
    else:
        multiplier = 1
    while (
        filtered.find_next(
            pm(X2_PM_COUNTERS[ne_abbr]["shark_msg"], name_line_pattern="empty")
        )
        is not None
    ):
        msg_counter += 1 * multiplier
    if isinstance(X2_PM_COUNTERS[ne_abbr]["value"], dict):
        X2_PM_COUNTERS[ne_abbr]["value"][serving_cell] += msg_counter
    else:
        X2_PM_COUNTERS[ne_abbr]["value"] += msg_counter


def check_msg_occurrence(pcap_file, msg, shark_filter="x2ap"):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=shark_filter,
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    msg_counter = 0
    while (
        filtered.find_next(
            pm(msg, name_line_pattern="empty")
        )
        is not None
    ):
        msg_counter += 1
    return msg_counter


def change_x2_link_status(bts, action):
    if bts == "gNB":
        distname = "{}/LTEENB-{}".format(bts_prefix, get_lteenb_object_id())
        param = "x2LinkLock"
        vm_ip = LOCALHOST
    if bts == "eNB":
        distname = "MRBTS-{}/LNBTS-{}/LNADJGNB-1".format(mrbts_id, lnbts_id)
        param = "administrativeState"
        vm_ip = LOCALHOST
    with AdminSession(remote_host=vm_ip) as admin:
        admin.perform_parameter_recommissioning(
            dist_name=distname, parameter=param, operation="update", value=action
        )
    logger.info(" x2 link is {}".format(action.upper()), also_console=True)


def get_lteenb_object_id():
    with AdminApi() as web_api:
        x2_list = web_api.get_managed_objects(class_name="LTEENB_R", timeout=30)
    for i in range(len(x2_list)):
        if str(x2_list[i]["parameters"]["eNodeBId"]) == str(lnbts_id):
            return x2_list[i]["distName"][-1:]


def check_x2_link_status(enb_id):
    with AdminApi() as web_api:
        x2_list = web_api.get_managed_objects(class_name="LTEENB_R", timeout=30)
        for i in range(len(x2_list)):
            if x2_list[i]["parameters"]["eNodeBId"] == int(enb_id):
                return x2_list[i]["parameters"]["x2LinkStatus"]


def verify_x2_link_status(enb_id, expected_status):
    status = check_x2_link_status(enb_id)
    assert status == expected_status, "x2 link is not in status: {}".format(
        expected_status
    )


def check_sctp_shutdown_msg(pcap_file):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="sctp",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    sctp_shutdown = filtered.find_exactly(1, pm("SHUTDOWN_COMPLETE", name_line_pattern="empty"))
    assert sctp_shutdown, "sctp link not shutdown due to no traffic after timer reached"
    logger.info("\n sctp link shutdowned", also_console=True)


def check_if_sctp_link_close_due_to_no_cell(
    max_conf_upd_retries, conf_upd_resp_tmr, shutdown_no_cell_tmr
):
    if (int(max_conf_upd_retries) + 1) * int(conf_upd_resp_tmr) >= int(
        shutdown_no_cell_tmr
    ) * 60:
        return True


def check_if_counter_update_needed(
    counter, max_conf_upd_retries, conf_upd_resp_tmr, shutdown_no_cell_tmr
):
    if (int(max_conf_upd_retries) + 1) * int(conf_upd_resp_tmr) >= int(
        shutdown_no_cell_tmr
    ) * 60:
        increase_counters(counter)


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": "update",
            }
        ],
    }
    return parameter_delta


def set_allowed_enb_for_nsa_call(enb_id="40092"):
    with AdminApi() as web_api:
        cell_list = []
        delta_list = []
        cells_info = web_api.get_cells_info()
        for i in range(len(cells_info)):
            cell_list.append(cells_info[i]["globalCellId"])
        for cell in cell_list:
            distname = "{}/NRCELL-{}/NRRELLTE-1".format(bts_prefix, cell)
            delta_list.append(create_delta(distname, "eNodeBId", enb_id))
            delta = json.dumps(delta_list)
        web_api.perform_delta_recommissioning(delta_file=delta)


def manage_nrrellte_objects(file):
    with AdminApi() as web_api:
        web_api.perform_delta_recommissioning(delta_file=file)


def set_parameter_value(param, value):
    distname = "{}".format(bts_prefix)
    with AdminApi() as web_api:
        web_api.perform_parameter_recommissioning(
            dist_name=distname, parameter=param, operation="update", value=value
        )


def check_simulated_lteenb_instance_not_exists():
    with AdminApi() as web_api:
        x2_list = web_api.get_managed_objects(class_name="LTEENB_R", timeout=30)
    assert len(x2_list) == 1


def check_active_x2_links_number():
    with AdminApi() as web_api:
        x2_list = web_api.get_managed_objects(class_name="LTEENB_R", timeout=30)
    return len(x2_list)


def calculate_expected_tput(split_mode):
    if split_mode == "nrlte":
        return (
            tl.max_tput["dl"]["nr"] + tl.max_tput["dl"]["lte"],
            tl.max_tput["ul"]["nr"] + tl.max_tput["ul"]["lte"],
        )
    else:
        return tl.max_tput["dl"]["lte"] * 2, tl.max_tput["ul"]["lte"]
