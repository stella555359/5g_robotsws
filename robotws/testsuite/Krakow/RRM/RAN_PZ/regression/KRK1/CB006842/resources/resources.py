# -*- coding: utf-8 -*-
"""
Keywords for the feature CB006842.

:copyright: Nokia Networks
:author: MN_RAN_PZ_KRK_TAG
:contact: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
:maintainer: I_MN_RAN_PZ_KRK_TAG@internal.nsn.com
"""
import logging
from datetime import datetime
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter, PmCounterOutputGetter
from taf.rfrl.bts.devices.exceptions import AsirOperationFailed
from taf.rfrl.utilities.tl_config import get_bts_instance_id


def activate_energy_saving_feature():
    delta = [{
        'distName': 'ASI-1/HUBMOD-1',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'actLbEnergySaving',
            'value': 'true'}]}]
    gnb_asir = GnbAsirHubOperations()
    try:
        gnb_asir.perform_asir_recommissioning(delta)
    except AsirOperationFailed as e:
        error_msg = str(e)
        if 'delta loaded to editor does not contain updates' in error_msg:
            logging.warning('Unable to activate energy saving feature - feature already activated')
        else:
            raise e


def deactivate_energy_saving_feature():
    delta = [{
        'distName': 'ASI-1/HUBMOD-1',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'actLbEnergySaving',
            'value': 'false'}]}]
    gnb_asir = GnbAsirHubOperations()
    try:
        gnb_asir.perform_asir_recommissioning(delta)
    except AsirOperationFailed as e:
        error_msg = str(e)
        if 'delta loaded to editor does not contain updates' in error_msg:
            logging.warning('Unable to deactivate energy saving feature - feature already deactivated')
        else:
            raise e


def block_all_cells_connected_to_antenna(ant_id):
    gnb_asir = GnbAsirHubOperations()
    gnb_cell = GnbCellOperations()
    cells_connected_to_antenna_dist_names = gnb_asir.get_cell_dist_names_connected_to_antena(ant_id)
    logging.debug(f'distNames of cells connected to antenna: {cells_connected_to_antenna_dist_names}')
    asir_scf_path = gnb_asir.get_current_scf_file("/tmp/", "temp_asir_scf.xml")
    classes = gnb_asir.get_all_params_under_class_name(scf_file_path=asir_scf_path, class_name='com.nokia.asi:CELL')
    for class_item in classes:
        if class_item['dist_name'] in cells_connected_to_antenna_dist_names:
            cell_id = int(class_item['params']['targetLcrId'])
            logging.debug(f"CELL ID to block: {cell_id}")
            gnb_cell.block_cell(cell_id=cell_id)
            gnb_cell.verify_cell_is_blocked(cell_id=cell_id)


def unblock_all_cells_connected_to_antenna(ant_id):
    gnb_asir = GnbAsirHubOperations()
    gnb_cell = GnbCellOperations()
    cells_connected_to_antenna_dist_names = gnb_asir.get_cell_dist_names_connected_to_antena(ant_id)
    logging.debug(f'distNames of cells connected to antenna: {cells_connected_to_antenna_dist_names}')
    asir_scf_path = gnb_asir.get_current_scf_file("/tmp/", "temp_asir_scf.xml")
    classes = gnb_asir.get_all_params_under_class_name(scf_file_path=asir_scf_path, class_name='com.nokia.asi:CELL')
    for class_item in classes:
        if class_item['dist_name'] in cells_connected_to_antenna_dist_names:
            cell_id = int(class_item['params']['targetLcrId'])
            logging.debug(f"CELL ID to unblock: {cell_id}")
            gnb_cell.unblock_cell(cell_id=cell_id)
            gnb_cell.verify_cell_is_unblocked(cell_id=cell_id)


def activate_energy_consumption_measurements(interval):
    delta = [{
        'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'actPowerMeter',
            'value': 'true'}]},
        {
        'distName': 'MRBTS-{}/MNL-1/MNLENT-1/PMMNL-1',
        'operation': 'update',
        'parameters': [{
            'operation': 'update',
            'parameterName': 'mtSBTSASIRMODEnergyMonitoring',
            'value': interval},
            {
            'operation': 'update',
            'parameterName': 'mtSBTSRfmEnergyMonitoring',
            'value': interval},
            {
            'operation': 'update',
            'parameterName': 'mtSBTSSmEnergyMonitoring',
            'value': interval},
            {
            'operation': 'update',
            'parameterName': 'mtBtsEnergyMonitoring',
            'value': interval}]}
    ]

    gnb_scf = GnbCommissioning()
    gnb_scf.perform_bts_delta_commissioning(delta=delta)


def deactivate_energy_consumption_measurements():
    delta = [
        {
            'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
            'operation': 'update',
            'parameters': [
                {
                    'operation': 'update',
                    'parameterName': 'actPowerMeter',
                    'value': 'false'}]}]
    gnb_scf = GnbCommissioning()
    gnb_scf.perform_bts_delta_commissioning(delta=delta)


def verify_counters_have_values(counters, interval, start_timestamp, stop_timestamp):
    interval_in_seconds = int(interval.strip('min'))
    counter_target_timestamp = start_timestamp - 60 * interval_in_seconds
    logging.debug(f'Target timestamp of all counters: {counter_target_timestamp}')
    gnb_counter = GnbPmCounter()
    counters_output = gnb_counter.get_counter(counter_ids=counters)
    counters_info = PmCounterOutputGetter().get_bts_counters(counters_output)
    logging.debug(f'COUNTERS INFO: {counters_info}')
    _all_counters = counters_info[f'MRBTS-{get_bts_instance_id()}']
    all_counters = _all_counters['EQM-1']['APEQM-1'] if 'EQM-1' in _all_counters.keys() else _all_counters
    logging.debug(f'Values of counters: {all_counters}')
    energy_monitoring_counters_values = {}
    for asirmod_name, asirmod_counters_values in all_counters.items():
        if 'ASIRMOD-' in asirmod_name:
            energy_monitoring_counters = asirmod_counters_values.get(
                    'SBTS_Energy_Consumption', asirmod_counters_values.get('SBTS_ASIRMOD_Energy_Monitoring'))
            if energy_monitoring_counters is None:
                raise ValueError(f'Counter for {asirmod_name} are not under any known key: '
                                 f'{asirmod_counters_values.keys()}')
        else:
            energy_monitoring_counters = asirmod_counters_values
            asirmod_name = 'ASIRMOD'
        energy_monitoring_counters_values[asirmod_name] = {}

        logging.debug(f'Energy monitoring counters: {energy_monitoring_counters}')
        for counter_name, counter_values in energy_monitoring_counters.items():
            for timestamp, value in counter_values.items():
                if counter_target_timestamp <= int(timestamp) <= stop_timestamp and value:
                    logging.info(f'Counter {counter_name} has a value: {value}')
                    energy_monitoring_counters_values[asirmod_name][counter_name] = (timestamp, value)
                    break
            else:
                raise ValueError(f"Counter {counter_name} hasn't got a value in given measurement period: "
                                 f"{datetime.fromtimestamp(start_timestamp)} - {datetime.fromtimestamp(stop_timestamp)}"
                                 f"and measurement time: {datetime.fromtimestamp(counter_target_timestamp)}")
    return energy_monitoring_counters_values


def get_counters_values_difference_between_asirmods(counters_values):
    difference = {}
    asirmods = list(counters_values.keys())

    for idx1, asirmod1 in enumerate(asirmods[:-1]):
        for asirmod2 in asirmods[idx1 + 1:]:
            logging.debug(f'Update diff for {asirmod1} and {asirmod2}')
            difference[(asirmod1, asirmod2)] = count_counters_diff(counters_values[asirmod1], counters_values[asirmod2])

    logging.info(f'Counters difference: {difference}')
    return difference


def count_counters_diff(counter1, counter2):
    counters_diff = {}
    for counter_name, counter_value in counter1.items():
        counters_diff[counter_name] = abs(counter_value[1] - counter2[counter_name][1])
    return counters_diff


def verify_counter_values_difference_between_asirmods(counters_values, counter_name, allowed_diff, asirmods=None):
    """
    This method calculates the difference in values for a given counter between pairs of ASIRMODs and ensures
    that the difference does not exceed the allowed threshold. If the difference exceeds the allowed range,
    an exception is raised.
    Args:
        counters_values (dict): A dictionary containing counter values for each ASIRMOD. The keys are ASIRMOD names,
                                and the values are dictionaries of counter names and their respective values.
        counter_name (str): The name of the counter to verify.
        allowed_diff (int): The maximum allowed difference between counter values.
        asirmods (list, optional): A list of ASIRMOD names to include in the comparison. If None, all ASIRMODs
                                    in `counters_values` are used.
    Raises:
        ValueError: If the specified counter is not found in the difference calculation or if the difference
                    exceeds the allowed threshold.
    """
    filtered_counters_values = (
        {k: v for k, v in counters_values.items() if k in asirmods}
        if asirmods
        else counters_values
    )
    counters_difference = get_counters_values_difference_between_asirmods(filtered_counters_values)
    for compared_asirmods_names, diff in counters_difference.items():
        if counter_name not in diff.keys():
            raise ValueError(f'No diff value for {compared_asirmods_names} and counter: {counter_name}')
        if int(diff[counter_name]) > int(allowed_diff):
            raise ValueError(f'The difference in counter {counter_name} values between the compared asirmod names '
                             f'is greater than allowed range: {diff[counter_name]} > {allowed_diff}')
        else:
            logging.info(f'The difference in counter {counter_name} values between the compared asirmod names '
                         f'is within allowed range: {diff[counter_name]} <= {allowed_diff}')
