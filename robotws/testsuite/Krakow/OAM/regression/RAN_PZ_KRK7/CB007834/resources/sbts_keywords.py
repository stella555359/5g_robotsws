
import os
import random
import time
from datetime import datetime

from robot.api import logger
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations, EnbDuOperations
from taf.rfrl.bts.devices.asir.dist_name_patterns import AsirDistNamePatterns
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, PmCounterOutputGetter
from taf.rfrl.bts.devices.exceptions import AsirOperationFailed
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.bts.commissioning import perform_full_commissioning_on_classical_gnb
from gnb_api_cli import GnbApiCli
from gnb_ssh import get_historical_alarm_list
from variables import *
import json
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from on_air_tl_preparation.testline_preparation import *

tl = get_builtin_value('tl')


def prepare_gnb_neighbour(scfs_path=False,
                          should_5G_neighbour_be_changed=True,
                          swconfig_from_path="commissionings/Krakow/swconfig/default_swconfig.txt",
                          upload_swconfig_to_neighbour=True,
                          increase_timeout_for_update_sw=False,
                          neighbour_incompatible_error_timer=False,
                          neighbour_increase_timeout_for_update_sw=False,
                          increase_time_for_checking_neighbour_bbmod=False,
                          increase_time_for_checking_neighbour_radios=False,
                          increase_time_for_checking_neighbour_cells=False,
                          scf_prefix_tag=None,
                          log_dir=None,
                          certificates=None,
                          raise_exception_when_setup_ru_console_fail=False):
    if log_dir is None:
        log_dir = os.path.join(get_builtin_value('OUTPUT DIR'), 'preparation')
    increase_timeout_for_update_sw = int(increase_timeout_for_update_sw) if increase_timeout_for_update_sw else 1800
    neighbour_increase_timeout_for_update_sw = int(neighbour_increase_timeout_for_update_sw) \
        if neighbour_increase_timeout_for_update_sw else 1800
    should_not_print_log_about_success = []

    main_bts, neighbour_enbs, neighbour_gnbs = get_neighbour_gnbs_and_enbs_info_defaults()
    if certificates:
        certificates_gnb, certificates_enb = group_certificates(certificates)
        certificates_gnb_main = certificates_gnb.pop(0)
    else:
        certificates_gnb, certificates_enb, certificates_gnb_main = None, None, None

    power_on_all_pdu_ports()

    if should_5G_neighbour_be_changed:
        prepare_5g_bts_neighbours(increase_time_for_checking_neighbour_bbmod,
                                  increase_time_for_checking_neighbour_cells,
                                  increase_time_for_checking_neighbour_radios, log_dir, neighbour_gnbs,
                                  neighbour_incompatible_error_timer, neighbour_increase_timeout_for_update_sw,
                                  scf_prefix_tag, scfs_path, should_not_print_log_about_success, swconfig_from_path,
                                  upload_swconfig_to_neighbour, certificates_gnb,
                                  raise_exception_when_setup_ru_console_fail)

    if not any(should_not_print_log_about_success):
        log_banner_to_console('"Power Stride and Ready to Ride!"\n'
                              '                     *    '
                              'https://www.youtube.com/watch?v=p0wT4uBitcY&ab_channel=Sherif\n'
                              '                     *    Testline prepared for testing')


def get_current_time():
    now = datetime.now()
    current_time = now.strftime("%Y-%m-%d %H:%M:%S")
    logger.info('Start time {}'.format(current_time))
    return current_time


def verify_alarm_appear_in_alarm_history(fault_id, start_time, log_exception=False):
    """
    Verify alarm appeared in alarm history
    :param fault_id: alarm fault id
    :param start_time: time which alarm appeared
    :param log_exception: log exception otherwise log info result
    :param log_exception: log exception otherwise log info result
    :return: None
    """
    alarm_list = get_historical_alarm_list()
    alarm_list_after_time = [alarm for alarm in alarm_list if alarm['time'] > start_time]
    logger.debug(alarm_list_after_time)
    if alarm_list_after_time:
        fault_id_list = [alarm['fault_id'] for alarm in alarm_list_after_time]
        if str(fault_id) not in fault_id_list:
            raise Exception('Fault {} not appear in history list {} after time{}'.format(fault_id,
                                                                                         alarm_list_after_time,
                                                                                         start_time))
        return
    if log_exception:
        raise Exception('There is no alarm in history alarms after time {}'.format(start_time))
    else:
        logger.info('There is no alarm in history alarms after time {}'.format(start_time))


def verify_validate_scf(scf_name, local_dir_path=None):
    """
    Verify SCF Validation
    :param scf_name: name of commissioning file
    :param local_dir_path: path to logs on VM
    :return: None
    """
    if not local_dir_path:
        local_dir_path = get_builtin_value("OUTPUT_DIR")
    logger.console("Check Scf Validation")
    scf_name_file = "{}.xml".format(scf_name)
    path_file = GnbApiCli().get_current_scf_file(local_dir_path, scf_name)
    validation_status = GnbApiCli().validate_scf_online(path_file)
    niddval = validation_status["requestMessage"]["niddValidationResult"]["status"]
    pldval = validation_status["requestMessage"]["pdlValidationResult"]["status"]
    try:
        assert niddval == "OK" and pldval == "OK", "Validation of scf status Failed"
        logger.console("Validation status successful")
    finally:
        os.system(f"rm -rf {os.path.join(local_dir_path, scf_name_file)}")


def prepare_random_nrcell_dist_name():
    """
    Get all list of cell and select one of them.
    :return: distname of NRCELL
    """
    mrbts_id = GnbApiCli().mrbts_id
    cell_info = GnbApiCli().get_cells_info()
    cell_ids = [cell['id']['configuration'].split('/')[-1].split('-')[-1] for cell in cell_info]
    random_cell_id = random.choice(cell_ids)
    return f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}/NRCELL-{random_cell_id}"


def prepare_gnsse_dist_name():
    """
    Prepares GNSSE object dist name
    :return: string
    """
    mrbts_id = GnbApiCli().mrbts_id
    return "MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1".format(mrbts_id)


def prepare_nr_dist_name():
    """
    Prepares NRBTS object dist name
    :return: string
    """
    mrbts_id = GnbApiCli().mrbts_id
    return f"MRBTS-{mrbts_id}/NRBTS-{mrbts_id}"


def prepare_lte_dist_name():
    """
    Prepares LNBTS object dist name
    :return: string
    """
    mrbts_id = GnbApiCli().mrbts_id
    return f"MRBTS-{mrbts_id}/LNBTS-{mrbts_id}"


def prepare_lte_dist_name_on_enb():
    """
    Prepares LNBTS object dist name
    :return: string
    """
    mrbts_id = GnbApiCli(mrbts_id=tl.gnbs[1].instance_id).mrbts_id
    logger.console(f"mrbts_id: {mrbts_id}")
    return f"MRBTS-{mrbts_id}/LNBTS-{mrbts_id}"


def parameter_recommissioning(dist_name, parameter, operation, value):
    GnbApiCli().parameter_recommissioning(dist_name=dist_name,
                                          parameter=parameter,
                                          operation=operation,
                                          value=value)


def determine_cell_type(nrcell_dist_name):
    """
    Get cell technology TDD of FDD.
    :param nrcell_dist_name: cell distname
    :return: cell technology
    """
    desired_nrcell_id = nrcell_dist_name.split('/')[-1].split('-')[-1]
    managed_nrcells = GnbApiCli().get_managed_objects('NRCELL_A')

    for managed_nrcell in managed_nrcells:
        id_from_managed_cell = managed_nrcell['distName'].split('/')[-1].split('-')[-1]

        if id_from_managed_cell == desired_nrcell_id:
            cell_technology = managed_nrcell["parameters"]["cellTechnology"]
            return cell_technology

    raise Exception(f"There are no NRCELL with provided dist_name: {nrcell_dist_name}!")


def change_channel_bandwidth(nrcell_dist_name, chBw_new_value):
    cell_technology = determine_cell_type(nrcell_dist_name=nrcell_dist_name)

    parameter_to_change = {
        "TDD": "chBw",
        "FDD": "chBw",
    }

    parameter = parameter_to_change[cell_technology]

    supported_chBw_values = {
        "TDD": ["20MHz", "30MHz", "40MHz", "50MHz", "60MHz", "70MHz", "80MHz", "90MHz", "100MHz"],
        "FDD": ["5MHz", "10MHz", "15MHz", "20MHz", "30MHz", "40MHz"],
    }

    value = chBw_new_value[cell_technology]

    if value not in supported_chBw_values[cell_technology]:
        raise Exception(f"Unsupported {value} value for {parameter}!"
                        f" Only supported values are: {supported_chBw_values[cell_technology]}")

    parameter_recommissioning(dist_name=nrcell_dist_name,
                              parameter=parameter,
                              value=value,
                              operation="update",)


def block_cells():
    GnbApiCli().block_cells()


def unblock_cells():
    GnbApiCli().unblock_cells()


def get_attach_counter(cell_id=None):
    """
    Calculate the attach counter value for the test using given counters.

    :return sum of all attach counters
    """
    cell_num = cell_id if cell_id is not None else GnbApiCli().get_cell_num()[0]
    counter = GnbPmCounter().get_counter(counter_attach_numerator)
    cell_counters = PmCounterOutputGetter(pm_counter_output=counter).get_cell_counters(cell_id=cell_num)
    attach_counter = cell_counters["NX2CC"][counter_attach_numerator]
    logger.debug('All counter {}'.format(attach_counter))
    total_sum = 0
    values = attach_counter.values()
    for i in values:
        total_sum += i
    return total_sum


def get_lte_cell_number():
    cell_ids = GnbApiCli(ip=tl.gnbs[0].oam_ip.v4.split("/")[0],
                         username=tl.gnbs[0].cu.oam_http_connection_details.username,
                         password=tl.gnbs[0].cu.oam_http_connection_details.password,
                         mrbts_id=tl.gnbs[0].instance_id).get_cell_num(cell_type='lte')
    random_cell_id = random.choice(cell_ids)
    return random_cell_id


def get_lte_cell_number_on_enb():
    cell_ids = GnbApiCli(ip=tl.gnbs[1].oam_ip.v4.split("/")[0],
                         username=tl.gnbs[0].cu.oam_http_connection_details.username,
                         password=tl.gnbs[0].cu.oam_http_connection_details.password,
                         mrbts_id=tl.gnbs[1].instance_id).get_cell_num(cell_type='lte')
    random_cell_id = random.choice(cell_ids)
    return random_cell_id


def gather_gnb_traffic_counter(sum_counters, divisor, timeout):
    """
    Calculate the throughput value for the test using given counters.
    Tput is measured in bit but time in milliseconds.

    :param sum_counters: iterable of counter IDs to sum up in the numerator
    :param divisor: time of tput duration
    :param timeout: timeout
    :return tput value in Mb/s
    """

    pm_counter_output = GnbApiCli().get_counters_info("BTS", timeout=timeout)
    bts_counters = PmCounterOutputGetter(pm_counter_output=pm_counter_output).get_bts_counters()
    mrbts = 'MRBTS-{}'.format(tl.gnbs[0].instance_id)
    nrbts = 'NRBTS-{}'.format(tl.gnbs[0].instance_id)
    gnb_pdcp_counters = bts_counters[nrbts]["PDCP1"] if nrbts in bts_counters else bts_counters[mrbts][nrbts]["PDCP1"]
    total_sum = 0.0
    for counter in sum_counters:
        total_sum += list(gnb_pdcp_counters[counter].values())[-1]
    if int(divisor) > 0:
        return 8 * total_sum / (1000 * int(divisor))
    else:
        raise ZeroDivisionError("Divisor (time) was zero for counter {}".format(divisor))


def verify_gnb_dl_counter(min_value, divisor, timeout=120):
    dl_counter_value = gather_gnb_traffic_counter(sum_counters_dl, divisor, timeout)
    logger.console('GNB DL Tput {} Mb/s'.format(dl_counter_value))
    assert int(dl_counter_value) >= int(min_value), 'Total value for DL should be higher then {} but is {}'.format(
        min_value, dl_counter_value)


def verify_gnb_ul_counter(min_value, divisor, timeout=120):
    ul_counter_value = gather_gnb_traffic_counter(sum_counters_ul, divisor, timeout)
    logger.console('GNB UL Tput {} Mb/s'.format(ul_counter_value))
    assert int(ul_counter_value) >= int(min_value), 'Total value for UL should be higher then {} but is {}'.format(
        min_value, ul_counter_value)


def gather_enb_traffic_counter(numerator_counter, divisor_counter, timeout):
    """
    Calculate the throughput value for the test using given counters.
    Tput is measured in bit but time in milliseconds.

    :param  numerator_counter  counter IDs to sum up in the numerator
    :param  divisor_counter    pm counter ID that is the divisor (time in ms)
    :return tput value in Mb/s
    """
    pm_counter_output = GnbApiCli(ip=tl.gnbs[1].oam_ip.v4.split('/')[0]).get_counters_info("BTS", timeout=timeout)
    result = PmCounterOutputGetter(pm_counter_output=pm_counter_output, bts_type='GNB').\
        get_cells_counters(cell_type='LTE', bts_id=1)
    total_tput = 0.0
    for cell in result.keys():
        if "LNCEL" not in cell:
            continue
        mnc = result[cell]["MCC-001_MNC-01"] if "MCC-001_MNC-01" in result[cell] else result[cell]['MCC-001']['MNC-01']
        if "LTE_Cell_Throughput" not in mnc:
            continue
        throughput_counters = mnc["LTE_Cell_Throughput"]
        numerator_value = list(throughput_counters[numerator_counter].values())[-1]
        divisor = list(throughput_counters[divisor_counter].values())[-1]
        logger.debug('numerator_value {} devisor {}'.format(numerator_value, divisor))
        if divisor and numerator_value:
            total_tput += (numerator_value / (1000 * divisor))
    return total_tput


def verify_enb_dl_counter(min_value, timeout=120):
    dl_counter_value = gather_enb_traffic_counter(counter_dl_enb_numerator, counter_dl_enb_divisor, timeout)
    logger.console('ENB DL Tput {} Mb/s'.format(dl_counter_value))
    assert int(dl_counter_value) >= int(min_value), 'Total value for DL should be higher then {} but is {}'.format(
        min_value, dl_counter_value)


def verify_enb_ul_counter(min_value, timeout=120):
    ul_counter_value = gather_enb_traffic_counter(counter_ul_enb_numerator, counter_ul_enb_divisor, timeout)
    logger.console('ENB UL Tput {} Mb/s'.format(ul_counter_value))
    assert int(ul_counter_value) >= int(min_value), 'Total value for UL should be higher then {} but is {}'.format(
        min_value, ul_counter_value)


def wait_for_next_pm_counter_period(interval, delay):
    """
    Waiting for the next period to collect pm counter

    :param  interval  time of the next period
    :param  delay     delay time
    :return None
    """
    GnbPmCounter().wait_for_next_pm_period(interval=interval, delay=int(delay))


def set_x2c_interface_signalling(interval):
    """
    Set interval for X2
    :param  interval  time of the next perdiod
    :return None
    """
    GnbApiCli().set_x2c_interface_signalling(interval)


def change_parameter_in_delta_plan_and_activate(dn, name, value):
    gnb_asir = GnbAsirHubOperations()
    delta_update = [{
        'distName': dn,
        'parameters': [{
            'operation': 'update',
            'parameterName': name,
            'value': value}]}]
    try:
        logger.info('Update Value')
        gnb_asir.perform_asir_recommissioning(delta_update)
    except Exception:
        try:
            logger.info('Create Value')
            delta = [{
                'distName': dn,
                'parameters': [{
                    'operation': 'create',
                    'parameterName': name,
                    'value': value}]}]
            gnb_asir.perform_asir_recommissioning(delta)
        except AsirOperationFailed:
            pass
    wait_for_asir_delta_activation()


def get_antennas_dist_name(ant_id=0):
    """
    Get specific antenna dist_name
    :param int ant_id: Antenna id - related to Test Line configuration, default: 1
    :return: None
    """
    gnb_asir = GnbAsirHubOperations()
    gnb_asir.connect()
    dist_names = gnb_asir._get_all_dist_names(AsirDistNamePatterns.re_antmod_dist_name.format(r'\d+'))
    gnb_asir.disconnect()
    return dist_names[ant_id]


def disable_ethernet_port_security():
    GnbApiCli().disable_ethernet_port_secutity()


def get_wem_cell_id_of_ant(ant_id=1):
    """
    Finds WEM id of cell connected to given ANTMOD
    :param int ant_id: id of ANTMOD
    :return list cells_ids: cells ids from WEM
    """
    gnb_asir = GnbAsirHubOperations()
    antmods_and_cells = gnb_asir.get_all_cells_with_antenna_mapping()
    cells_uids = []
    for ele in antmods_and_cells:
        for ant in ele['antennas']:
            if ant['id'] == ant_id:
                cells_uids.append(ele['uid'])

    mrbts_id = GenericBts().get_global_bts_id()
    info = gnb_asir.get_site_logical_info()
    cells_ids = []
    for ele in info:
        if ele['description'] and ele['uid'] in cells_uids and 'BTS{}'.format(mrbts_id) in ele['description']['label']:
            cells_ids.append(int(ele['description']['label'].split(".")[1]))
    return cells_ids


def loading_commissioning_for_release(sw_package, release_list):
    """
    Loading commissioning with special flags for related releases
    :param sw_package: software version for gNB in str format, eg: 'SBTS00_ENB_9999_210318_000011'
    :param release_list: list of release for which commissioning commisionig is needed, eg: ['SBTS00']
    :return:
    """
    du = GnbDuOperations()
    for release in release_list:
        if release in sw_package:
            perform_full_commissioning_on_classical_gnb()
            time.sleep(300)
            du.wait_for_site_to_be_onair(timeout=900, interval=10)


def is_fault_7107_supported(sw_package):
    """
    Checks if given build supports fault 7107 (CB007582)
    :param sw_package: software version for gNB in str format, eg: 'SBTS00_ENB_9999_210318_000011'
    :return: None
    """
    return not any([sw_package.startswith(release) for release in pre_CB007582_releases])


def get_gNbCuType():
    parameter = 'gNbCuType'
    comissioning = GnbCommissioning()
    all_params = comissioning.get_all_params_under_class_name(class_name='com.nokia.srbts.nrbts:NRBTS')
    return all_params[0]['params'][parameter]


def get_expected_cell_statuses_after_x2_link_lock():
    """
    Cell data for NSA deployment:
    """
    cell_data = {
        'availability_status_x2_locked': 'failed',
        'op_state_x2_locked': 'disabled',
        'usage_state_x2_locked': 'idle',
        'procedural_status_x2_locked': 'not initialized',
    }

    found_parameter = get_gNbCuType()

    if found_parameter == 'SA+NSA':
        cell_data.update({
            'availability_status_x2_locked': 'degraded',
            'op_state_x2_locked': 'enabled',
            'usage_state_x2_locked': 'active',
            'procedural_status_x2_locked': 'configured',
            })
    return cell_data


def get_expected_cell_availability_status_after_x2_lock(sw_package):
    """
    Provides expected cell availability status when X2 link is locked
    :param sw_package: software version for gNB in str format, eg: 'SBTS00_ENB_9999_210318_000011'
    :return: String
    """
    if is_fault_7107_supported(sw_package):
        return 'failed'
    return 'offline'


def get_expected_cell_procedural_status_after_x2_lock(sw_package):
    """
    Provides expected cell procedural status when X2 link is locked
    :param sw_package: software version for gNB in str format, eg: 'SBTS00_ENB_9999_210318_000011'
    :return: String
    """
    if is_fault_7107_supported(sw_package):
        return 'not initialized'
    return 'configured'


def get_online_parameters_delta():
    instance_id = tl.gnbs[0].instance_id
    cell_id = get_lte_cell_number()
    ONLINE_PARAMETERS = [
        {
            "distName": "MRBTS-{0}/LNBTS-{0}".format(instance_id, cell_id),
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actPCMDReport",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]
    return json.dumps(ONLINE_PARAMETERS)


def get_online_parameters_delta_on_enb():
    instance_id = tl.gnbs[1].instance_id
    cell_id = get_lte_cell_number_on_enb()
    ONLINE_PARAMETERS = [
        {
            "distName": "MRBTS-{0}/LNBTS-{0}".format(instance_id, cell_id),
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actPCMDReport",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]
    return json.dumps(ONLINE_PARAMETERS)


def get_site_reset_delta():
    instance_id = tl.gnbs[0].instance_id
    SITE_RESET = [
        {
            "distName": "MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1".format(instance_id),
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "totalDelayFromSHM",
                    "value": "20",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(SITE_RESET)


def get_site_reset_delta_on_enb():
    instance_id = tl.gnbs[1].instance_id
    SITE_RESET = [
        {
            "distName": "MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1".format(instance_id),
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "totalDelayFromSHM",
                    "value": "20",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(SITE_RESET)


def wait_for_asir_delta_activation(wait_time=30):
    """
    Sleep for some time until after asir delta is activated.
    Please choose wait_time wisely
    :return: None
    """
    time.sleep(wait_time)


def get_nr_rat_reset_delta():
    distname = prepare_nr_dist_name()
    RAT_RESET = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "actBeamControlImprovement2",
                    "value": "true",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(RAT_RESET)


def get_LTE_rat_reset_delta():
    distname = prepare_lte_dist_name()
    RAT_RESET = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "cPlaneDscp",
                    "value": "46",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(RAT_RESET)


def get_LTE_rat_reset_delta_on_enb():
    distname = prepare_lte_dist_name_on_enb()
    RAT_RESET = [
        {
            "distName": distname,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "cPlaneDscp",
                    "value": "46",
                    "operation": "update"
                }
            ]
        }
    ]

    return json.dumps(RAT_RESET)


def reverse_parameters_to_default_values(dist_name, param_name, default_param_value):
    asir = GnbAsirHubOperations()
    scf_file_path = asir.get_current_scf_file(local_dir_path="/tmp")
    asi_antmod_params = asir.get_all_params_under_class_name(scf_file_path, class_name="com.nokia.asi:ANTMOD")

    if param_name == 'asiId':
        actual_value = asi_antmod_params[0]['dist_name'].split('/')[0].split('-')[1]
    else:
        actual_value = asi_antmod_params[0]['params'][param_name]

    if actual_value != default_param_value:
        logger.console("Restoring {} parameter".format(param_name))
        change_parameter_in_delta_plan_and_activate(dist_name, param_name, default_param_value)


def wait_for_time_window():
    time_windows = [
        (1, 8),
        (16, 23),
        (31, 38),
        (46, 53)
    ]

    while True:
        current_dt = datetime.now()
        current_minute = current_dt.minute

        is_in_window = False
        for start_minute, end_minute in time_windows:
            if start_minute <= current_minute <= end_minute:
                is_in_window = True
                break

        if is_in_window:
            logger.console(f"[{current_dt.strftime('%H:%M:%S')}] Current time is within the time window.")
            break

        for start_minute, _ in time_windows:
            if current_minute < start_minute:
                wait_time_in_minutes = start_minute - current_minute
                logger.console(f"[{current_dt.strftime('%H:%M:%S')}] Waiting {wait_time_in_minutes} minutes")
                break

        if current_minute > time_windows[-1][-1]:
            wait_time_in_minutes = 60 + time_windows[0][0] - current_minute
            logger.console(f"[{current_dt.strftime('%H:%M:%S')}] Waiting {wait_time_in_minutes} minutes")

        time.sleep(60 * wait_time_in_minutes)
