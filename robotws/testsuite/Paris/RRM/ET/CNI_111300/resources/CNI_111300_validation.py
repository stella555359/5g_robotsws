"""
:author: Anna Bien
:maintainer: Anna Bien
:owner_email: anna.bien@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
:description: KPI and PM counters validation for CNI_111300
"""

import os
import csv

from collections import defaultdict
from testsuite.Paris.RRM.ET.resources_KRK.python.KPI_calculation import KpiCalculation
from testsuite.Paris.RRM.ET.resources_KRK.python.KPI_validation import get_sum_of_counter_list
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_info, logger_console_info, logger_warning, logger_debug
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_wts import (
    check_ue_thput_stats, run_egate_cmd, _parse_ue_stats
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import get_cells_info

from testsuite.Paris.RRM.ET.CNI_111300.resources.CNI_111300_resources import get_log_dir


class ValidationFailed(Exception):
    def __init__(self, *args, **kwargs):
        pass


def get_nr_70b_kpi_value():
    """
    Wait for next PM counters interval, download PM counters file and calculate KPI NR_70B value.
    Additionally print delay statistics.
    :return: (float)
    """

    kpi_calc_instance = KpiCalculation()
    kpi_calc_instance.set_counter_file_path(log_dir=get_log_dir())
    nr_70b = kpi_calc_instance.calculate_nr_70b_value()
    logger_console_info(f'NR_70B KPI value: {nr_70b}')
    log_delay_statistics(kpi_calc_instance.counter_file_path)
    return nr_70b


def log_delay_statistics(counter_file_path):
    """
    Collect values of counters ranges:
    DL RLC delay: M55310C05001-20
    DL RLC data IniTx PDUs transmitted by Low RLC: M55310C17001-20

    :param counter_file_path: (str) path to counters .xml report
    """

    rlc_delay_dict = defaultdict(int)
    pdu_count_dict = defaultdict(int)
    cells_info = get_cells_info()
    for cell in cells_info:
        cell_id = cell['globalCellId']
        rlc_delay = get_sum_of_counter_list(
            first_counter='M55310C05001', last_counter='M55310C05020',
            counters_path=f'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-{cell_id}', counter_file_path=counter_file_path
        )
        rlc_delay_dict[f'NRCELL-{cell_id}'] = int(rlc_delay)

        pdu_count = get_sum_of_counter_list(
            first_counter='M55310C17001', last_counter='M55310C17020',
            counters_path=f'PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-{cell_id}', counter_file_path=counter_file_path
        )
        pdu_count_dict[f'NRCELL-{cell_id}'] = int(pdu_count)

    logger_console_info(f'DL RLC delay stats: {rlc_delay_dict}')
    logger_console_info(f'DL RLC delay sum: {sum(rlc_delay_dict.values())}')
    logger_console_info(f'PDUs transmitted by Low RLC stats: {pdu_count_dict}')
    logger_console_info(f'PDUs transmitted by Low RLC sum: {sum(pdu_count_dict.values())}')


def compare_nr_70b_kpi_values(value_fr_enabled, value_fr_disabled, precision=10):
    """
    Validate if enabling CNI_111300 feature have an impact on average latency:
        - Average latency should not be better when feature is disabled.

    Compare 2 values of KPI NR_70B when feature was enabled and disabled.
    """

    try:
        assert value_fr_enabled <= value_fr_disabled + precision, \
            'Average latency when FR was enabled was too big comparing to case when FR was disabled'
    except AssertionError as kpi_failure:
        raise ValidationFailed(kpi_failure)
    logger_console_info('KPI validation has finished successfully!')


def verify_ethscaled_value_in_tti_traces(dcap_result_dir):
    """
    Validate if ethScaled value is calculated for Pcell and Scells in TTI trace csv files.
    Validation is done for TC6 and PhysCellIDs: 50, 51, 52, 53, 54, 55

    :param dcap_result_dir: (str) Path to unpacked DCAP results directory which includes TTI Traces parsed into .csv
    """

    csv_list = []
    for file_path in os.listdir(dcap_result_dir):
        if file_path.endswith('dl.csv'):
            csv_list.append((os.path.join(dcap_result_dir, file_path)))
    csv_list.sort()

    extracted_values = defaultdict(set)
    for csv_file in csv_list:
        logger_info(f'Checking file {csv_file}')
        with open(csv_file) as csvfile:
            reader = csv.reader(csvfile, delimiter=':', quotechar='|')
            for row in reader:
                try:
                    row_data = row[1].split(',')
                    fields = row_data[:int(len(row_data) / 2)]
                    values = row_data[int(len(row_data) / 2):]
                    if 'dlFlowControlData' in row[0]:
                        eth_index = fields.index('ethScaled')
                        cell_index = fields.index('physCellId')
                        extracted_values[values[cell_index]].add(values[eth_index])
                except IndexError:
                    continue
    logger_debug(f'ethScaled found: {extracted_values}')
    try:
        assert all(physcell in extracted_values.keys() for physcell in ['50', '51', '52', '53', '54', '55']), \
            'ethScaled not found for all configured cells'
    except AssertionError as error:
        raise ValidationFailed(error)
    logger_console_info(f'Found ethScaled values for all configured cells')


def verify_traffic(feature_enabled, ue_id='1-2', cells='0-7'):
    """
    Verify if DL UE traffic is correct
    :param feature_enabled: (bool) If set to True: Traffic should be split among PCell and Scells.
                                   If set to False: Traffic should remain only on PCell
    :param ue_id: (int, str) e.g. single UE '1' or range '0-1'
    :param cells: (str) e.g. single cell '1' or range '0-1'
    """

    def get_throughput_value(stats_result):
        try:
            if 'Kbps' in stats_result:
                pcell_tput = float(stats_result.split()[0]) * 0.000125
            else:
                pcell_tput = float(stats_result.split()[0])
        except ValueError:
            return 0
        return pcell_tput

    def validate_single_direction(egate_stats):
        logger_debug(egate_stats)
        scells_with_tput = []
        try:
            for cell_tput in egate_stats:
                if cell_tput['CellIndex'] == 'CellIndex-0':
                    assert get_throughput_value(cell_tput['Current']) > 0, f'UE{single_ue_id}: No traffic on PCell'
                elif feature_enabled:
                    if get_throughput_value(cell_tput['Current']) > 0:
                        scells_with_tput.append(cell_tput['CellIndex'])
                else:
                    assert get_throughput_value(cell_tput['Current']) < 1, f'UE{single_ue_id}: Excess traffic on SCell'
        except AssertionError as traffic_validation_failure:
            raise ValidationFailed(traffic_validation_failure)
        if feature_enabled and not scells_with_tput:
            raise ValidationFailed(f'UE{single_ue_id}: No traffic on SCells')
        logger_console_info(f'UE{single_ue_id}: Traffic correctly split among CCs')

    for single_ue_id in ue_id.split('-'):
        egate_stats_dl = check_ue_thput_stats(
            ues_ids=single_ue_id, scell=cells, type='pdsch', pass_regexp=f'NR PDSCH'
        )
        logger_info(egate_stats_dl)
        validate_single_direction(_parse_ue_stats(egate_stats_dl))

        egate_stats_ul = check_ue_thput_stats(
            ues_ids=ue_id.split('-'), scell=cells, type='pusch', pass_regexp=f'NR PUSCH'
        )
        logger_info(egate_stats_ul)
    logger_console_info('DL Traffic correctly split among CCs')


def compare_ue_throughput_values(value_dl_fr_enabled, value_dl_fr_disabled, value_ul_fr_enabled, value_ul_fr_disabled,
                                 tolerance=0.10):
    """
    Validate if enabling CNI_111300 feature have an impact on average latency:
        - UL and DL traffic should not be better when feature is disabled.

    Compare UL and DL throughput values when feature was enabled and disabled.
    """

    try:
        assert value_dl_fr_enabled + value_dl_fr_enabled * float(tolerance) >= value_dl_fr_disabled, \
            'DL traffic with CNI enabled is lower than with CNI disabled'
        assert value_ul_fr_enabled + value_ul_fr_enabled * float(tolerance) >= value_ul_fr_disabled, \
            'UL traffic with CNI enabled is lower than with CNI disabled'
    except AssertionError as throughput_failure:
        raise ValidationFailed(throughput_failure)
    logger_console_info('Throughput validation has finished successfully!')


def validate_if_dss_is_running():
    """
    Print 'Received DSS DL Qos Load Indication SequenceNumber... ' should be visible in egate_console.log.
    """

    run_egate_cmd(
        cmd='sim_state_disp',
        pass_regexp='Received DSS DL Qos Load Indication SequenceNumber=0',
        timeout=60
    )
    logger_console_info('DSS is up and running.')
