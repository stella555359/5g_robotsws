import re
import os
import glob
import subprocess
import time
from collections import Counter

from robot.libraries.DateTime import convert_time
from taf.analyzer.ttitrace_eventdecoder import TtitraceReader
from taf.collectors.l2stream3 import l2stream3
from taf.collectors.tcpdump import tcpdump
from taf.converters.eventdecoder import eventdecoder
from taf.hw.rf_attenuator import rf_attenuator
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.procedures.resources.python.config_operations import \
    ConfigOperations
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.TOL_TMO_DALLAS.resources.test_constants import *

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import \
    wait_for_next_pm_interval_and_get_counters
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession

bts = GnbCommissioning()
config = ConfigOperations()
tti_collector = l2stream3()
_attenuator = rf_attenuator()


def set_attach_cell_dn(cell):
    global ATTACH_CELL
    ATTACH_CELL = cell
    CELL_ADMINISTRATIVE_STATE_DELTA[0]["distName"] = ATTACH_CELL
    RETX_8662_DELTA[0]["distName"] = ATTACH_CELL


def deattenuate_attach_cell(attenuators, att_id=0):
    attenuator = attenuators[int(att_id)]
    logger.info(f"Initializing attenuator {attenuator.ip_addr}", also_to_console=True)
    _attenuator.setup_attenuator(attenuator, alias=ATTENUATOR_ALIAS)
    set_ports_attenuation(attenuator.attenuation_port_numbers, 90, attenuators, int(att_id))
    logger.info(f"Deattenuating cell {ATTACH_CELL} to {ATTACH_CELL_ATTENUATION}dB", also_to_console=True)
    set_ports_attenuation(CELL_ATTENUATION_PORTS[ATTACH_CELL], ATTACH_CELL_ATTENUATION, attenuators, int(att_id))


def set_ports_attenuation(ports, value, attenuators, att_id=0):
    attenuator = attenuators[int(att_id)]
    logger.debug(f"Initializing attenuator {attenuator.ip_addr}")
    _attenuator.setup_attenuator(attenuator, alias=ATTENUATOR_ALIAS)
    for port in ports:
        _attenuator.set_attenuation(port, int(value), confirm=True, attenuator_device=ATTENUATOR_ALIAS)


def clear_attenuation_on_cell(cell, attenuators):
    attenuator = attenuators[0]
    _attenuator.setup_attenuator(attenuator, alias=ATTENUATOR_ALIAS)
    logger.info(f"Clearing attenuation on cell to {ATTACH_CELL_ATTENUATION}dB", also_to_console=True)
    set_ports_attenuation(CELL_ATTENUATION_PORTS[cell], ATTACH_CELL_ATTENUATION)


def set_graceful_cell_shutdown_parameters():
    bts.perform_bts_delta_commissioning(delta=GRFL_SHUTDOWN_ON_DELTA, skip_parameter_relation_errors=False)


def set_8662_adaptive_retx_parameters(direction="dl"):
    adapt_retx_delta_to_direction(direction)
    bts.perform_bts_delta_commissioning(delta=RETX_8662_DELTA, skip_parameter_relation_errors=False)


def adapt_retx_delta_to_direction(direction):
    for parameter in RETX_8662_DELTA[0]["parameters"]:
        parameter["parameterName"] = (
            parameter["parameterName"].replace("Dl", direction.capitalize()).replace("Ul", direction.capitalize())
        )


def shutdown_cell(timeout=420):
    timeout = convert_time(timeout)
    CELL_ADMINISTRATIVE_STATE_DELTA[0]["parameters"][0]["value"] = "Shutting Down"
    cell = CELL_ADMINISTRATIVE_STATE_DELTA[0]["distName"].split("/")[-1]
    bts.perform_bts_delta_commissioning(delta=CELL_ADMINISTRATIVE_STATE_DELTA, skip_parameter_relation_errors=False)
    start_t = time.time()
    while time.time() - start_t < timeout:
        state = _get_cell_administrative_state(CELL_ADMINISTRATIVE_STATE_DELTA)
        if state == "Shutting Down":
            logger.info(f"{cell} shutdown in progress...", also_to_console=True)
        if state == "Locked":
            logger.info(f"{cell} shutdown completed. Cell is locked", also_to_console=True)
            return
    raise TimeoutError(f"{cell} shutdown not complted within {timeout}s")


def _get_cell_administrative_state(delta_params):
    try:
        config.connect("cell_administrative_state")
        value = config.get_parameter_value(
            dist_name=delta_params[0]["distName"], param_name=delta_params[0]["parameters"][0]["parameterName"]
        )
    finally:
        config.disconnect()
    return value


def unlock_cell_after_shutdown():
    CELL_ADMINISTRATIVE_STATE_DELTA[0]["parameters"][0]["value"] = "Unlocked"
    bts.perform_bts_delta_commissioning(delta=CELL_ADMINISTRATIVE_STATE_DELTA, skip_parameter_relation_errors=False)
    time.sleep(30)


def switch_on_power_saving():
    bts.perform_bts_delta_commissioning(delta=POWER_SAVING_DELTA, skip_parameter_relation_errors=False)


def wait_until_capacity_cells_switch_off(capacity_cells, timeout=360):
    expected_states = ["notEnergySaving", "switchingOff", "energySaving"]
    _wait_until_capacity_cells_energy_saving_state_change(expected_states, capacity_cells, timeout)


def wait_until_capacity_cells_switch_on(capacity_cells, timeout=360):
    expected_states = ["energySaving", "notEnergySaving"]
    _wait_until_capacity_cells_energy_saving_state_change(expected_states, capacity_cells, timeout)


def wait_until_capacity_cells_tx_switch_off(capacity_cells, timeout=360):
    expected_states = ["notEnergySaving", "reducedEnergySaving"]
    _wait_until_capacity_cells_energy_saving_state_change(expected_states, capacity_cells, timeout)


def wait_until_capacity_cells_tx_switch_on(capacity_cells, timeout=360):
    expected_states = ["reducedEnergySaving", "notEnergySaving"]
    _wait_until_capacity_cells_energy_saving_state_change(expected_states, capacity_cells, timeout)


def _wait_until_capacity_cells_energy_saving_state_change(expected_states, capacity_cells, timeout=360):
    timeout = convert_time(timeout)
    start_t = time.time()
    logger.info(
        f"Waiting for up to {timeout} for capacity cells to change state to {expected_states[-1]}", also_to_console=True
    )
    states = {cell: CellEnergySavingStateMachine(cell, expected_states) for cell in capacity_cells}
    while time.time() - start_t < timeout:
        for capacity_cell in capacity_cells:
            capacity_cell_energy_saving_state = _get_cell_energy_saving_state(capacity_cell)
            states[capacity_cell].process_state(capacity_cell_energy_saving_state)
        if all([machine.next_state == "stop" for machine in states.values()]):
            return
        time.sleep(5)
    raise TimeoutError(
        f"Capacity cells have not reached expected state ({' -> '.join(expected_states)})" f" in {timeout}s"
    )


class CellEnergySavingStateMachine:
    def __init__(self, cell, expected_states):
        self.cell = cell
        self.current_state = None
        self._expected_states = (state for state in expected_states + ["stop"])
        self.next_state = next(self._expected_states)

    def process_state(self, state):
        if state == self.next_state:
            logger.info(f"{self.cell} energy saving state changed to {state}", also_to_console=True)
            self.current_state = state
            self.next_state = next(self._expected_states)
        elif state != self.current_state:
            raise ValueError(
                f"Unexpected energy saving state change from " f"{self.current_state} to {state}) for cell {self.cell}"
            )


def _get_cell_energy_saving_state(cell_dn):
    try:
        config.connect("assert_energy_saving")
        value = config.get_parameter_value(
            dist_name=cell_dn, param_name=CELL_ENERGY_SAVING_STATE_DELTA[0]["parameters"][0]["parameterName"]
        )
    finally:
        config.disconnect()
    return value


def set_cell_switch_off_params_and_get_relevant_capacity_cells(method):
    nrpgrp = find_power_group_object_for_given_attach_cell()
    period_delta = _fill_power_saving_period_delta(nrpgrp)
    NRPGRP_DELTA[0]["distName"] = nrpgrp["dist_name"]
    _set_switch_off_method_in_delta(method)
    bts.perform_bts_delta_commissioning(delta=NRPGRP_DELTA, skip_parameter_relation_errors=False)
    bts.perform_object_recommissioning(
        dist_name=nrpgrp["dist_name"], parameter=period_delta, operation="update", skip_parameter_relation_errors=False
    )
    return nrpgrp


def suspend_lbps_current_period_after_test(nrpgrp):
    NRPGRP_DELTA[0]["distName"] = nrpgrp["dist_name"]
    period_delta = _fill_power_saving_period_delta(nrpgrp, "suspended")
    bts.perform_object_recommissioning(
        dist_name=nrpgrp["dist_name"], parameter=period_delta, operation="update", skip_parameter_relation_errors=False
    )
    time.sleep(30)


def find_power_group_object_for_given_attach_cell():
    cell_id = ATTACH_CELL.rsplit("-", 1)[-1]
    nrpgrps = bts.get_all_params_under_class_name(class_name="com.nokia.srbts.nrbts:NRPGRP")
    for nrpgrp in nrpgrps:
        cell_list = nrpgrp["params"]["lbpsCellList"]
        for cell in cell_list:
            if cell["nrCellId"] == cell_id:
                return nrpgrp
    raise ValueError(f"No valid NRPGRP object found for cell {cell_id}")


def determine_capacity_cells(nrpgrp):
    common_cell_dn, attach_cell_id = ATTACH_CELL.rsplit("-", 1)
    return [
        common_cell_dn + "-" + cell["nrCellId"]
        for cell in nrpgrp["params"]["lbpsCellList"]
        if cell["nrCellId"] != attach_cell_id
    ]


def _fill_power_saving_period_delta(existing_nrpgrp, suspend="notSuspended"):
    time_struct = time.localtime(time.mktime(time.localtime()) + 160)
    day = time.strftime("%a", time_struct)
    period_list = existing_nrpgrp["params"]["lbpsPeriodList"]
    add_required = True
    for period in period_list:
        if period["lbpsDayOfWeek"] == day:
            _fill_current_period_params(period, time_struct, suspend)
            add_required = False
    if add_required:
        period = {}
        _fill_current_period_params(period, time_struct, suspend)
        period["lbpsDayOfWeek"] = day
        period_list.append(period)
    delta = {"operation": "update", "parameterName": "lbpsPeriodList", "value": period_list}
    return [delta]


def _fill_current_period_params(period, time_struct, suspend):
    period["lbpsDuration"] = 120
    period["lbpsStartTimeHour"] = time.strftime("%H", time_struct)
    period["lbpsStartTimeMinute"] = time.strftime("%M", time_struct)
    period["lbpsSuspended"] = suspend


def _set_switch_off_method_in_delta(method):
    for param in NRPGRP_DELTA[0]["parameters"]:
        if param["parameterName"] == "lbpsSOMethod":
            param["value"] = method


def get_cell_switch_off_counters(reference_point=None):
    logger.info("Waiting for next PM counters interval...", also_to_console=True)
    return wait_for_next_pm_interval_and_get_counters(CELL_SWITCH_OFF_COUNTERS, reference_point=reference_point)


def get_tx_switch_off_counters(reference_point=None):
    logger.info("Waiting for next PM counters interval...", also_to_console=True)
    return wait_for_next_pm_interval_and_get_counters(TX_SWITCH_OFF_COUNTERS, reference_point=reference_point)


def get_reserved_mcs_256qam_dl_counters(reference_point=None):
    logger.info("Waiting for next PM counters interval...", also_to_console=True)
    return wait_for_next_pm_interval_and_get_counters(RESERVED_MCS_256QAM_DL_COUNTERS, reference_point=reference_point)


def get_reserved_mcs_256qam_ul_counters(reference_point=None):
    logger.info("Waiting for next PM counters interval...", also_to_console=True)
    return wait_for_next_pm_interval_and_get_counters(RESERVED_MCS_256QAM_UL_COUNTERS,
                                                      reference_point=reference_point)


def analyze_cell_switch_off_counters(reference_point, capacity_cells, expected_switch_offs):
    counters_dict = get_cell_switch_off_counters(reference_point)
    counter_sums = _get_sums_of_power_saving_counters(counters_dict, reference_point, capacity_cells)
    for capacity_cell_dn in capacity_cells:
        cell_counter = counter_sums[capacity_cell_dn]
        assert cell_counter["M55601C00501"] > 0, (
            f"Counter M55601C00501 have not incremented for capacity " f"cell {capacity_cell_dn}"
        )
        assert cell_counter["M55601C00502"] == expected_switch_offs, (
            f"Counter M55601C00502 should count exactly {expected_switch_offs} cell switch offs "
            f"for capacity cell {capacity_cell_dn}, got {cell_counter['M55601C00502']} instead"
        )
    logger.info("Cell switch off counters OK", also_to_console=True)


def analyze_tx_switch_off_counters(reference_point, capacity_cells, expected_tx_reductions):
    counters_dict = get_tx_switch_off_counters(reference_point)
    counter_sums = _get_sums_of_power_saving_counters(counters_dict, reference_point, capacity_cells)
    for capacity_cell_dn in capacity_cells:
        cell_counter = counter_sums[capacity_cell_dn]
        assert cell_counter["M55601C02002"] > 0, (
            f"Counter M55601C02002 have not incremented for capacity " f"cell {capacity_cell_dn}"
        )
        assert cell_counter["M55601C02001"] == expected_tx_reductions, (
            f"Counter M55601C02001 should count exactly {expected_tx_reductions} transitions to reduced TX "
            f"for capacity cell {capacity_cell_dn}, got {cell_counter['M55601C02001']} instead"
        )
    logger.info("TX switch off counters OK", also_to_console=True)


def analyze_reserved_mcs_dl_counters(reference_point, expected_mcs_counters):
    counters_dict = get_reserved_mcs_256qam_dl_counters(reference_point=reference_point)
    _analyze_reserved_mcs_counters(counters_dict, expected_mcs_counters)


def analyze_reserved_mcs_ul_counters(reference_point, expected_mcs_counters):
    counters_dict = get_reserved_mcs_256qam_ul_counters(reference_point=reference_point)
    _analyze_reserved_mcs_counters(counters_dict, expected_mcs_counters)


def _analyze_reserved_mcs_counters(counters_dict, expected_mcs_counters):
    counters_dict = {
        int(dn[-2:]): sum([v[1] for v in values]) for dn, values in counters_dict.items() if ATTACH_CELL in dn
    }
    logger.info(f"pm counters: {counters_dict}", also_to_console=True)
    logger.info(f"tti counters: {expected_mcs_counters}", also_to_console=True)
    for mcs, value in counters_dict.items():
        low_bound = expected_mcs_counters[mcs] * (1 - MCS_COUNTERS_ERROR_MARGIN)
        assert low_bound <= value, (
            f"Counter for MCS {mcs} ({value}) is lower"
            f" than number found in TTI ({expected_mcs_counters[mcs]})"
            f" (with allowed error = {MCS_COUNTERS_ERROR_MARGIN * 100}%)"
        )
    logger.info("Reserved MCS counters OK", also_to_console=True)


def _get_sums_of_power_saving_counters(counters_dict, reference_point, capacity_cells):
    counter_sums = {}
    for capacity_cell_dn in capacity_cells:
        counter_sums[capacity_cell_dn] = {}
        for counter_dn, counter_values in counters_dict.items():
            if capacity_cell_dn in counter_dn:
                counter_id = counter_dn.split("/")[-1]
                counter_sums[capacity_cell_dn][counter_id] = sum([value[1] for value in counter_values])
    return counter_sums


def start_tti_trace(test_pc, gnb, collector_alias="TTI"):
    testpc_ssh_config = {
        "host": test_pc.default_ssh_connection_details.addr,
        "user": test_pc.default_ssh_connection_details.username,
        "password": test_pc.default_ssh_connection_details.password,
    }
    interface_name = _identify_interface_with_ip(testpc_ssh_config["host"])
    options = f"-i {interface_name} port 5678"
    logger.info("Starting TTI tracing...", also_to_console=True)
    _tcpdump = tcpdump()
    tcpdump_alias = "tcpdump_tti"
    _tcpdump.create_tcpdump_collector(name=tcpdump_alias, options=options, executor=testpc_ssh_config)

    executor = {
        "host": gnb.dus[0].airscale.common_units[0].lmp_connection.addr,
        "user": gnb.cu.oam_http_connection_details.username,
        "password": gnb.cu.oam_http_connection_details.password,
        "port": 443,
    }
    l2_stream_config_1 = {"nr_cell_dns": [ATTACH_CELL]}
    l2_stream_configuration = [l2_stream_config_1]
    tti_collector.create_sbts_l2stream_collector(
        name=collector_alias,
        webservice=executor,
        destination_ip_addr=testpc_ssh_config["host"],
        collector=tcpdump_alias,
        l2_stream_configuration=l2_stream_configuration,
    )
    tti_collector.setup_collectors(names=collector_alias)
    tti_collector.start_collectors(names=collector_alias)
    tti_collector.set_suite_alias(collector_alias)
    logger.info("TTI streaming started!", also_to_console=True)


def _identify_interface_with_ip(ip):
    output = str(subprocess.run(["ip", "-o", "-4", "addr", "show"], capture_output=True).stdout, encoding="utf-8")
    ip = ip.replace(".", "\\.")
    interface_name = re.search(rf"^\d+:\s(\S+).*{ip}.*$", output, re.M)
    if interface_name is None:
        raise ValueError(f"could not find interface name for TTI streaming; ip output: {output}")
    return interface_name.group(1)


def stop_tti_trace(output_dir, collector_alias="TTI"):
    tti_collector.stop_collectors(names=collector_alias)
    tti_collector.collect_collectors(names=collector_alias, target_dir=output_dir)
    tti_collector.teardown_collectors(names=collector_alias)
    logger.info("TTI tracing stopped", also_to_console=True)


def convert_pcap_tti_to_json(pcap_path, output_file_path):
    ed = eventdecoder()
    ed.create_eventdecoder_converter(
        name="converter", input_file_path=pcap_path, output_file_format="json", output_file_path=output_file_path
    )
    ed.convert(name="converter")
    return f"{output_file_path}.json"


def analyze_rescheduling_mcs_in_tti_trace(pcap_path, output_file_path, direction="dl"):
    convert_pcap_tti_to_json(pcap_path, output_file_path)
    direction = direction.lower()
    retx_mcs = Counter()
    with open(f"{output_file_path}.json", "rb") as file_obj:
        for event in TtitraceReader(file_obj=file_obj):
            if event.type == f"{direction}FdSchedData":
                mcs = event.data[f"rrm{direction.capitalize()}UsedMcs"]
                txnum = event.data["txNumber"]
                if txnum > 1:
                    retx_mcs[mcs] += 1
    logger.info(
        f"Found {direction.upper()} retransmissions (txNumber > 1)  mcs range =  {retx_mcs}", also_to_console=True
    )
    assert retx_mcs[29] > 0, f"Reserved mcs 29 should appear at least once in TTI! Found mcs'es = {retx_mcs}"
    assert retx_mcs[30] > 0, f"Reserved mcs 30 should appear at least once in TTI! Found mcs'es = {retx_mcs}"
    assert retx_mcs[31] > 0, f"Reserved mcs 31 should appear at least once in TTI! Found mcs'es = {retx_mcs}"
    return retx_mcs


def sweep_attenuation_several_times(n_times=3, step=2, t_interval=2, attenuators=None,
                                    att_start=ATTACH_CELL_ATTENUATION,
                                    att_end=ATTACH_CELL_ATTENUATION_MAX):
    attenuation_range = list(range(att_start, att_end, step))
    for i, n in enumerate(range(int(n_times))):
        logger.info(f"Starting attenuation sweep {i + 1}/{n_times}", also_to_console=True)
        for attenuation in attenuation_range:
            set_ports_attenuation(CELL_ATTENUATION_PORTS[ATTACH_CELL], attenuation, attenuators)
            time.sleep(int(t_interval))
        logger.info(f"Starting reverse attenuation sweep {i + 1}/{n_times}", also_to_console=True)
        for attenuation in reversed(attenuation_range):
            set_ports_attenuation(CELL_ATTENUATION_PORTS[ATTACH_CELL], attenuation, attenuators)
            time.sleep(int(t_interval))


def verify_ald_retu_status(ald_id, retu_id=1):
    err_msg = '{object} {status} is not as expected {expected}!'
    with AdminSession() as admin:
        ald = admin.get_parameters(f'/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/ALD_L-{ald_id}')
        retu = admin.get_parameters(f'/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/ALD_L-{ald_id}/RETU_L-{retu_id}')
    assert ald['stateInfo']['operationalState'] == 'Enabled', \
        err_msg.format(object=f'ALD-{ald_id}', status='operationalState', expected='Enabled')
    assert ald['stateInfo']['availabilityStatus'] == 'Online', \
        err_msg.format(object=f'ALD-{ald_id}', status='availabilityStatus', expected='Online')

    assert retu['stateInfo']['operationalState'] == 'Enabled', \
        err_msg.format(object=f'RETU-{retu_id}', status='operationalState', expected='Enabled')
    assert retu['stateInfo']['availabilityStatus'] == 'Online', \
        err_msg.format(object=f'RETU-{retu_id}', status='availabilityStatus', expected='Online')
    assert retu['stateInfo']['calibrationStatus'] == 'Calibrated', \
        err_msg.format(object=f'RETU-{retu_id}', status='calibrationStatus', expected='Calibrated')


def delete_snapshot_from_passed_test(base_dir):
    passed_snapshots = glob.glob(os.path.join(f"{base_dir}/**/*passed*/**", "Snapshot*"), recursive=True)
    logger.info(passed_snapshots)
    for f in passed_snapshots:
        logger.debug(f)
        os.remove(f)
