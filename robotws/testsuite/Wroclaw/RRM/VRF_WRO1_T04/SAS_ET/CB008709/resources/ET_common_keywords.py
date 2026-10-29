"""
:copyright: Nokia Networks
:author: Damian Zak
:maintainer: Damian Zak
:contact: damian.zak@nokia.com, I_VRF_KRK_11@internal.nsn.com
:team: MN_RAN_RD_VRF_KRK_11
"""
import json

from time import time, sleep
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console_info
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts import (
    deregister_ue, detach_ue, start_data_traffic_in_egate, run_egate_cmd, start_rtp_traffic, setup_x2_link,
    attach_ue_and_establish_pdu_session, attach_ue_to_plmn_and_perform_sgnb_addition,
    register_ue, establish_pdu_session, check_ue_thput_stats, _parse_ue_stats, stop_data_traffic_in_egate
)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.attach import (
    configure_spid_for_ues)
from testsuite.Wroclaw.RRM.sim_resources.\
    Krk_regression.MN_RAN_L2.resources.Python.slice_scheduling.validate_target_share \
    import target_share_validation
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.counters import (
    collect_counters_values, create_counter_list)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters import (
    get_latest_values_for_specified_counters)
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import (
    perform_recomissioning_with_delta, wait_for_all_radio_modules_to_be_online
)


class DataVolumePer5qiValidationFail(Exception):
    pass


class TargetShareSumValidationFail(Exception):
    pass


def perform_5g_sa_attach(ue_ids=(), slices=(), cell=(), qosflows=(), vonr_support=False, pdus=()):
    """
    Performs 5G Standalone (SA) attach for the given UE(s) to the specified slice(s) and cell(s).

    Args:
        ue_ids (tuple or list): A tuple or list of UE IDs to perform the attach for.
        slices (tuple or list): A tuple or list of slice names to attach the UE(s) to.
        cell (tuple or list): A tuple or list of cell names to attach the UE(s) to.
        qosflows (tuple or list): A tuple or list of QoS flow IDs to activate for each UE.
        vonr_support (bool): Indicates whether Voice over NR (VoNR) support is enabled.
        pdus (tuple or list): A tuple or list of PDU sessions established by UEs.

    Returns:
        None

    Raises:
        None
    """
    ues_for_trf_type = ",".join(map(str, ue_ids)) if len(ue_ids) > 1 else ue_ids[0]
    if not isinstance(cell, (tuple, list)):
        cell = tuple((cell,) * len(ue_ids))
    if not pdus:
        pdus = tuple((1,) * len(ue_ids))
    if vonr_support:
        ues_for_vonr_support = f"{ue_ids[0]}-{ue_ids[-1]}"
        run_egate_cmd(f"ue_nr_capabilities id={ues_for_vonr_support} voice_over_nr=on:on:off")
    for index, ue in enumerate(ue_ids):
        if qosflows and qosflows[index]:
            run_egate_cmd(f"smf_param id=1 additional_qosflows_to_activate={','.join(map(str, qosflows[index]))}")
        if isinstance(pdus[index], int):
            attach_ue_and_establish_pdu_session(ue_id=ue, cell_id=cell[index], nwslice=slices[index], pdu=pdus[index])
        else:
            register_ue(ue_id=str(ue), cell_id=cell[index])
            for pdu, slice in zip(pdus[index], slices[index]):
                run_egate_cmd(f"set_pdu_param ue={ue} pdu={pdu} trf_type=internal")
                establish_pdu_session(ue_id=ue, pdu_id=pdu, nwslice=slice, gw_id=pdu)
        if qosflows and qosflows[index]:
            run_egate_cmd("smf_param id=1 reset")


def setup_x2_link_and_wait_for_mib_reception():
    egate = BuiltIn().get_library_instance("ta5g_egate")
    setup_x2_link()
    egate.wait_for_information_block_reception_for_given_cells(
        cells={2: [1, 2, 3, 4]}, infoblocktype="MasterInformationBlock-NR", timeout=120)


def perform_5g_nsa_attach(ue_ids=(), spids=(), cell=(), bearer=(), plmn=()):
    bearer = ((2,) * len(ue_ids)) if not bearer else bearer
    cell = tuple((cell,) * len(ue_ids)) if not isinstance(cell, (tuple, list)) else cell
    plmn = tuple((plmn,) * len(ue_ids)) if not isinstance(plmn, (tuple, list)) else plmn
    configure_spid_for_ues(ue_ids, spid=list(spids))
    for index, ue in enumerate(ue_ids):
        attach_ue_to_plmn_and_perform_sgnb_addition(
            ue_id=ue, bearer=bearer[index], selected_plmn=plmn[index], serving_plmn=plmn[index], cell_id=cell[index])


def perform_sa_detach(ue_ids=()):
    for ue in ue_ids:
        deregister_ue(ue_id=ue, pass_regexp=r'Received UE Context Release Complete from GNB-\d+')


def perform_nsa_detach(ue_ids=()):
    for ue in ue_ids:
        detach_ue(ue_id=ue)


def start_sa_traffic(ue_ids=(), direction="ul", mbps=(), qfi=(), first_trf_id=(), pdu=()):
    """
    Start SA traffic for the specified UEs.

    Args:
        ue_ids (tuple): A tuple of UE IDs for which SA traffic needs to be started.
        direction (str): The direction of the traffic. Default is "ul" (uplink).
        mbps (tuple): A tuple of Mbps values representing the traffic rate for each UE.
        qfi (tuple): A tuple of QFI (QoS Flow Identifier) values for each UE. Default is an empty tuple.
        first_trf_id (tuple): A tuple of first traffic IDs for each UE. Default is an empty tuple.
        pdu (tuple): A tuple of PDU values for each UE. Default is an empty tuple.

    Returns:
        None
    """
    qfi = ((1,) * len(ue_ids)) if not qfi else qfi
    pdu = ((1,) * len(ue_ids)) if not pdu else pdu
    for index, ue in enumerate(ue_ids):
        logger_console_info(f"Start SA {direction.upper()} traffic for UE:{ue}")
        trf_instance_nr = mbps[index] // 175
        trf_value = mbps[index]
        trf_id = first_trf_id[index] if first_trf_id else 1
        while trf_instance_nr:
            start_data_traffic_in_egate(
                ue, direction, mbps=175, pdu=pdu[index], qfi=qfi[index], trf_id=trf_id, net_arch='sa')
            trf_value -= 175
            trf_instance_nr -= 1
            trf_id += 1
        if trf_value:
            start_data_traffic_in_egate(
                ue, direction, mbps=trf_value, pdu=pdu[index], qfi=qfi[index], trf_id=trf_id, net_arch='sa')


def start_nsa_traffic(ue_ids=(), direction="ul", mbps=(), bearer=(), first_trf_id=()):
    """
    Start NSA traffic for the specified UEs.

    Args:
        ue_ids (tuple): A tuple of UE IDs.
        direction (str): The direction of the traffic. Default is "ul" (uplink).
        mbps (tuple): A tuple of traffic rates in Mbps for each UE.
        bearer (tuple): A tuple of bearer values for each UE. If not provided, default value is (2,) * len(ue_ids).
        first_trf_id (tuple): A tuple of first traffic IDs for each UE. If not provided, default value is 1.

    Returns:
        None
    """
    bearer = ((2,) * len(ue_ids)) if not bearer else bearer
    for index, ue in enumerate(ue_ids):
        logger_console_info(f"Start NSA {direction.upper()} traffic for UE:{ue}")
        trf_instance_nr = mbps[index] // 175
        trf_value = mbps[index]
        trf_id = first_trf_id[index] if first_trf_id else 1
        while trf_instance_nr:
            start_data_traffic_in_egate(
                ue_id=ue, direction=direction, mbps=175, bearer=bearer[index], trf_id=trf_id, net_arch='nsa')
            trf_value -= 175
            trf_instance_nr -= 1
            trf_id += 1
        if trf_value:
            start_data_traffic_in_egate(
                ue_id=ue, direction=direction, mbps=trf_value, bearer=bearer[index], trf_id=trf_id, net_arch='nsa')


def stop_traffic(ue_ids=()):
    formatted_ues = ",".join(map(str, ue_ids)) if len(ue_ids) > 1 else ue_ids[0]
    run_egate_cmd(f"trf_data_stop ue={formatted_ues}")


def start_vonr_traffic(ue_ids=(), qfi=3, trf_amount=30, traffic_direction="ul"):
    """
    Start VONR traffic for the specified UE range.

    Args:
        ue_ids (tuple): UE IDs to start traffic for.
        qfi (int): The QFI (QoS Flow Identifier) value (default is 3).
        trf_amount (int): The amount of traffic to start for each UE (default is 30).
        traffic_direction (str): The traffic direction, either "ul" (uplink) or "dl" (downlink) (default is "ul").
    """
    for ue_id in ue_ids:
        logger_console_info(f"Start {trf_amount} {traffic_direction.upper()} VONR traffic for UE:{ue_id}")
        for trf_id in range(1, trf_amount + 1):
            start_rtp_traffic(ue_id, qfi=qfi, trf_id=trf_id, traffic_direction=traffic_direction, rtp_codec="g726_16")


def validate_target_shares(sas_delta, tputs=(), excessive_gbr_groups=(), margin=20, scale=1.0,
                           new_delta=False, k2=2, traffic_dir='ul', excessive_gbr=False, cell=None, rg_ids=(),
                           should_use_all_resources=True, check_prb_util_max=True, custom_expected_ts=None):
    """
    Validates Slice Aware Scheduler PM counters target shares based on the provided parameters.

    Args:
        sas_delta (dict): The SAS delta containing the necessary information regarding RG amount, min & max quotas
                          and RG profile group assigment
        tputs (tuple, optional): The target throughputs for each resource group. Defaults to ().
        excessive_gbr_groups (tuple, optional): The excessive GBR groups. Defaults to ().
        margin (int, optional): The margin value. Defaults to 5.
        scale (float, optional): The scale value. Defaults to 1.0.
        new_delta (bool, optional): Flag indicating whether it's a new delta. Defaults to False.
        k2 (int, optional): The K2 value. Defaults to 2.
        traffic_dir (str, optional): The traffic direction. Defaults to 'ul'.
        excessive_gbr (bool, optional): Flag indicating whether excessive GBR is enabled. Defaults to False.
        cell (int, optional): The cell number. Defaults to None.

    Raises:
        TargetShareSumValidationFail: If the target shares sum is less than 70%.

    Returns:
        dict: The validated target shares.
    """
    prb_used_paths = {}
    prb_avail_paths = {}
    prb_util_max_paths = {}
    sas_config_quotas = {}
    tc_name = BuiltIn().get_variable_value("${TEST_NAME}")
    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    suite_name = BuiltIn().get_variable_value("${SUITE_NAME}")
    prb_used_counter_number = "M55910C00003" if traffic_dir == 'ul' else "M55910C00001"
    prb_avail_counter_number = "M55308C10012" if traffic_dir == 'ul' else "M55308C10013"
    max_prb_util_counter_number = "M55910C00004" if traffic_dir == 'ul' else "M55910C00002"

    create_counter_list([prb_used_counter_number, max_prb_util_counter_number, prb_avail_counter_number])
    collect_counters_values(outputdir=f"{output_dir}/{suite_name}/{tc_name}")
    counters_list = BuiltIn().get_variable_value("${COUNTER_DIRECTORY_LIST}", [])
    path_to_json = f"{counters_list[-1]}/ALL_COUNTERS.json"

    if cell is not None:
        cell = int(cell)
        cell_rg_profile = sas_delta['RG_profile_grp'][cell][traffic_dir.upper()]
    sas_cell = list(sas_delta["RG_profile_grp"])[0] if cell is None else cell
    min_quotas = list(sas_delta["minQuotas"]) if cell is None else list(sas_delta["minQuotas"][cell_rg_profile])
    max_quotas = list(sas_delta["maxQuotas"]) if cell is None else list(sas_delta["maxQuotas"][cell_rg_profile])
    rg_amount = sas_delta["RG_amount"] if cell is None else len(min_quotas)
    tputs = ((100,) * rg_amount) if not tputs else tputs

    for rg in range(1, rg_amount + 1):
        if rg_ids and len(rg_ids) == rg_amount:
            rg_id = rg_ids[rg - 1]
        else:
            rg_id = rg
        prb_used_paths.update({str(rg): f"BTS/MRBTS-1/NRBTS-1/NRCELL-{sas_cell}/NRRESOURCEGROUP-{str(rg_id)}/NCUPNRG"})
        prb_avail_paths.update({str(rg): f"BTS/MRBTS-1/NRBTS-1/NRCELL-{sas_cell}/NCELA"})
        prb_util_max_paths.update(
            {str(rg): f"BTS/MRBTS-1/NRBTS-1/NRCELL-{sas_cell}/NRRESOURCEGROUP-{str(rg_id)}/NCUPNRG"})
        sas_config_quotas.update({f"min{rg}": str(min_quotas[rg - 1]),
                                  f"max{rg}": str(max_quotas[rg - 1])})
    prb_used = {prb_used_counter_number: prb_used_paths}
    prb_avail = {prb_avail_counter_number: prb_avail_paths}
    prb_util_max = {max_prb_util_counter_number: prb_util_max_paths} if check_prb_util_max else {}
    quotas = {'quotas': sas_config_quotas}
    technology = 'TDD' if 'TDD' in tc_name else 'FDD'
    target_shares = target_share_validation(path_to_json=path_to_json, quotas=quotas, prb_used=prb_used,
                                            prb_avail=prb_avail, prb_util_max=prb_util_max, tputs=list(tputs),
                                            margin=int(margin), scale=scale, new_delta=new_delta,
                                            traffic_dir=traffic_dir, technology=technology, k2=k2,
                                            excessive_gbr=excessive_gbr,
                                            excessive_gbr_groups=list(excessive_gbr_groups),
                                            custom_expected_ts=custom_expected_ts)
    if should_use_all_resources:
        if sum(list(target_shares[1].values())) > 70:
            logger_console_info("Target shares sum is greater than 70%. Validation successful.")
        else:
            raise TargetShareSumValidationFail(f"Target shares sum is less than 70%: {target_shares}")


def validate_data_volume_per_5qi(qos_groups_expected_values={}, plmn_id=1):
    """
    Validates the data volume per 5QI (Quality of Service Identifier) for the specified QoS groups.

    Args:
        qos_groups_expected_values (dict): A dictionary containing the expected data volume values for each QoS group.
            The keys are the QoS group IDs, and the values can be either integers or strings.
            If the value is an integer, it represents the expected data volume in bytes.
            If the value is a string, it represents a condition that the data volume must satisfy (e.g., ">0").
        plmn_id (int):  PLMN ID = 1 refers to 311:489, 2 to 312:490

    Raises:
        DataVolumePer5qiValidationFail: If the validation fails for any QoS group, this exception is raised.
            The exception contains a list of failed counters.
    """
    failed_counters = []
    for qos_group_id, value in qos_groups_expected_values.items():
        try:
            counter = get_latest_values_for_specified_counters(
                counter_ids_list=[f"M55326C0300{qos_group_id}"],
                path_filters=f"MRBTS-1/NRBTS-1/MCC-{310 + plmn_id}/MNC-{488 + plmn_id}/NRASU")
            logger_console_info(counter)
            if isinstance(value, int):
                assert abs(counter[f"M55326C0300{qos_group_id}"] - value) <= (value * 5) / 100
            elif isinstance(value, str):
                assert counter[f"M55326C0300{qos_group_id}"] > 0
        except AssertionError:
            failed_counters.append(f"M55326C0300{qos_group_id} value: {counter[f'M55326C0300{qos_group_id}']}")

    if failed_counters:
        raise DataVolumePer5qiValidationFail(failed_counters)
    else:
        logger_console_info("Data volume per 5QI validation passed")


def perform_webem_online_parameter_change(delta):
    delta_json = json.dumps(delta)
    logger_console_info("Performing online change...")
    perform_recomissioning_with_delta(delta_json)
    wait_for_all_radio_modules_to_be_online()


def check_ue_egate_stats(ues_ids, scell=None, type=None, should_be_zero=True):
    stats = check_ue_thput_stats(ues_ids, scell, type, pass_regexp='Throughput')
    ue_dict = _parse_ue_stats(stats)
    tput = float(ue_dict[0]['Current'].split(' ')[0])
    logger_console_info(f'tput: {tput}')
    logger_console_info(f'tput: {tput}')
    logger_console_info(f'tput: {tput}')
    if tput == 0 and should_be_zero:
        return True
    if tput != 0 and not should_be_zero:
        return True
    else:
        return False


def alternate_traffic_between_pdus(ue_id, tput, pdus=(), qfis=(), directions='both', tput_time=10, duration=600):
    def iterate_indefinitely(pdus, qfis):
        while True:
            for pdu, qfi in zip(pdus, qfis):
                yield pdu, qfi

    tput = int(tput)
    start_time = time()
    for pdu, qfi in iterate_indefinitely(pdus, qfis):
        if directions in ('ul', 'both'):
            start_sa_traffic(ue_ids=(ue_id,), mbps=(tput,), qfi=(qfi,), pdu=(pdu,))
        if directions in ('dl', 'both'):
            start_sa_traffic(ue_ids=(ue_id,), mbps=(tput,), qfi=(qfi,), pdu=(pdu,), direction='dl')
        logger_console_info(f'Running tput on pdu {pdu} and qfi {qfi} for {tput_time}s')
        sleep(tput_time)  # run tput for given time without interruptions
        if directions in ('ul', 'both'):
            assert check_ue_egate_stats(ue_id, type='pusch', should_be_zero=False), 'Pusch is zero'
            stop_data_traffic_in_egate(ue_id=ue_id, pdu=pdu, qfi=qfi, direction='ul')
        if directions in ('dl', 'both'):
            assert check_ue_egate_stats(ue_id, type='pdsch', should_be_zero=False), 'Pdsch is zero'
            stop_data_traffic_in_egate(ue_id=ue_id, pdu=pdu, qfi=qfi, direction='dl')
        _wait_for_traffic_to_stop(directions, ue_id)

        if time() - start_time > duration:
            break


def _wait_for_traffic_to_stop(directions, ue_id):
    for _ in range(5):  # 5 seconds for tput to stop, if tput is still present after that, it's an issue
        is_traffic_stopped = False
        if check_ue_egate_stats(ue_id, type='pusch', should_be_zero=True) and directions == 'ul':
            is_traffic_stopped = True
        elif check_ue_egate_stats(ue_id, type='pdsch', should_be_zero=True) and directions == 'dl':
            is_traffic_stopped = True
        elif check_ue_egate_stats(ue_id, type='pusch', should_be_zero=True) and \
                check_ue_egate_stats(ue_id, type='pdsch', should_be_zero=True):
            is_traffic_stopped = True
        if is_traffic_stopped:
            break
        sleep(1)  # wait for 1s before checking again
    else:
        raise ValueError('Tput not stopped after 5s')


def wait_to_avoid_catching_unwanted_initial_messages():
    sleep(5)
