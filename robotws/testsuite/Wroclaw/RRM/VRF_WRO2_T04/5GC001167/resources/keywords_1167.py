import re
import time
from collections import defaultdict, namedtuple
from taf.sbts.oam.coam.admin import admin as taf_admin
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from testsuite.Wroclaw.RRM.resources.etws_cmas.counters import wait_for_pm_counters_interval
from ca_variables import C_H
from operator import gt, ge, eq
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.counters import get_sum_of_n_last_pm_counters_values
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.python_functions import get_testline_name, get_scf_for_tag
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import get_parameter_value
from ca_variables import IP_VM_LTE
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.update_helpers import get_sw_version, download_sw_package
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.uuf.timeouts import Timeouts
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import set_preferred_cell as set_pref_cell


def get_scell_add_counter_values(counter_list=C_H, wait_for_interval=True, interval_m=5):
    def get_last_counter_value(counter_values):
        return counter_values[max(counter_values, key=int)]
    if wait_for_interval:
        wait_for_pm_counters_interval(interval_m=interval_m)
    counters_per_cell = defaultdict(dict)
    admin = taf_admin()
    admin.setup_admin()
    try:
        all_counters = admin.get_pm_counters(','.join(counter_list))
        cell_counters = all_counters.get('BTS').get('CELLS')
        if not cell_counters:
            cell_counters = all_counters.get('BTS').get(f'MRBTS-{mrbts_id}').get(f'NRBTS-{nrbts_id}')
        for cell, counters in cell_counters.items():
            logger.debug("Getting counters for cell: {}".format(cell))
            counters = {counter: values for d in counters.values() for counter, values in d.items()
                        if counter in counter_list}
            logger.debug("Cell counters: {}".format(counters))
            for counter, values in counters.items():
                logger.debug("counter: {}".format(counter))
                logger.debug("val: {}".format(values))
                counters_per_cell[cell][counter] = get_last_counter_value(values)
        logger.debug("CA_COUNTERS: {}".format(counters_per_cell))
    finally:
        admin.teardown_admin()
    return counters_per_cell


def scell_add_counter_incremented_successfully_for(cell_id,  counter, counter_dict='COUNTERS_H'):
    counter_incremented_successfully(counter, cell_id, counter_dict)


def counter_incremented_successfully(counter_id, cell_id, counter_dict='COUNTERS_L', operator='==', value=1):
    operators = {'>': gt, '>=': ge, '==': eq}
    assert operator in operators, 'Unexpected operator! Allowed: {}'.format(operators.keys())
    scell_counters = get_robot_variable("${{{counter_dict}}}".format(counter_dict=counter_dict))
    comp = operators[operator]
    counter_value = scell_counters["NRCELL-{}".format(cell_id)][counter_id]
    assert comp(counter_value, int(value)), \
        "Counter {} was not incremented after SCell addition".format(counter_id)


def reset_abil(abil_id=2):
    admin = taf_admin()
    admin.setup_admin()
    all_bbmods = admin.get_fbb_info()
    distname = [bbmod['id']['internal'] for bbmod in all_bbmods if 'BBMOD-{}'.format(abil_id)
                in bbmod['id']['configuration']][0]
    try:
        admin.reset_unit(distname, 'Warm', timeout=300)
    finally:
        admin.teardown_admin()


def verify_counter_value(counter_id, expected_value, cell_id=None, wait_for_interval=False):

    if wait_for_interval:
        wait_for_pm_counters_interval()
    value = get_sum_of_n_last_pm_counters_values([counter_id])[counter_id]
    if not cell_id:
        assert value == int(expected_value), '{} value is {} which is different than expected: {} '.format(
            counter_id, value, expected_value)
        return
    cell_value = get_counter_value_for_cell(counter_id, cell_id, wait_for_interval=False)
    err_msg = 'Wrong counter number on cell-{0}- expected {1}, got {2}'
    assert cell_value == int(expected_value), err_msg.format(cell_id, expected_value, cell_value)
    return


def get_counter_value_for_cell(counter_id, cell_id=None, wait_for_interval=False, additional_key=None):
    if additional_key:
        additional_key = [additional_key]
    if wait_for_interval:
        wait_for_pm_counters_interval()
    value = get_sum_of_n_last_pm_counters_values([counter_id],
                                                 n=1,
                                                 additional_dict_keys=additional_key)[counter_id]
    if additional_key:
        return value[additional_key[0]]
    if not cell_id:
        return value
    return value[f"NRCELL-{cell_id}"]


def prepare_lte_configuration(configuration, ip_vm=IP_VM_LTE):
    short_name, full_name = get_testline_name()
    path = get_scf_for_tag(short_name, configuration)
    with AdminSession(remote_host=ip_vm) as admin:
        admin.perform_commissioning(scf_file=path, timeout=600)
        wait_for_bbmods(admin_obj=admin)
        wait_for_radios(admin_obj=admin)
        time.sleep(60)
        alarms = admin.get_active_alarms()
        logger.info(alarms, also_console=True)
    incompatible = [alarm for alarm in alarms if alarm['faultId'] == 23]
    logger.info(incompatible, also_console=True)
    if incompatible:
        sw_version = get_sw_version()
        sw_path = download_sw_package(sw_version)
        with AdminSession(remote_host=ip_vm) as admin:
            admin.update_software(sw_package=sw_path, timeout=Timeouts.sw_update)
            wait_for_radios(admin_obj=admin)


@wait_until_function_succeeds(retry_time_in_seconds=1500, retry_interval_in_seconds=10)
def wait_for_radios(admin_obj):
    radios = admin_obj.get_frm()
    logger.info([radio['status'].get('availabilityStatus') for radio in radios], also_console=True)
    assert radios and all([radio['status'].get('availabilityStatus') in ['off line', '-'] for radio in radios])


@wait_until_function_succeeds(retry_time_in_seconds=1500, retry_interval_in_seconds=10)
def wait_for_bbmods(admin_obj):
    bbmods = admin_obj.get_detected_hw_info()['basebandModules']
    logger.info(bbmods, also_console=True)
    assert bbmods and all(bbmod['status'].get('availabilityStatus') in ['Online', None] for bbmod in bbmods)


def get_tput_info(ue, dt_name=None, info_type='max'):
    """
    :param ue: ue alias
    :param dt_name: data transfer name
    :param info_type: max, avg, min
    """
    TputStats = namedtuple('TputStats', 'avg min max')
    if not dt_name:
        dt_name = 'DT_{}_default'.format(ue)

    def extract_avg_min_max(stats_string):
        return stats_string.split(';')[0]

    ute_ue_lib = BuiltIn().get_library_instance('ute_ue')
    stats = ute_ue_lib.get_data_transfer_statistics(dt_name)
    logger.info("Checking {} tput for UE: {}...".format(info_type, ue), also_console=True)
    tput_stats = [int(float(tput))/1000000 for tput in extract_avg_min_max(stats).split(',')]
    tput_stats = TputStats(*tput_stats)
    logger.info("Tput stats: avg: {}, min: {}, max: {}".format(tput_stats.avg, tput_stats.min, tput_stats.max))
    return getattr(tput_stats, info_type)


def verify_if_max_throughput_reached(ue, expected_tput=None, dt_name=None, threshold=0.035):
    if not expected_tput:
        expected_tput = get_robot_variable('${expected_dl_tput_' + ue + '}')
    expected_tput = int(re.split('m|M', expected_tput)[0])
    max_tput = int(get_tput_info(ue, dt_name, 'max'))
    assert abs(expected_tput - max_tput) < expected_tput * threshold, \
        'Max throughput for UE: {} not reached! ' \
        'Current tput: {} Mbits/s, expected: {} Mbits/s'.format(ue, max_tput, expected_tput)


def restore_preferred_cell():
    set_pref_cell(cell_id=1)


def verify_scell_operational_existence(cell, nrrel):
    cell_rel_dist = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(mrbts_id, nrbts_id, cell, nrrel)
    try:
        return get_parameter_value(cell_rel_dist, 'sCellOperationalMode', remove_scf=False)
    except KeyError:
        return ""
