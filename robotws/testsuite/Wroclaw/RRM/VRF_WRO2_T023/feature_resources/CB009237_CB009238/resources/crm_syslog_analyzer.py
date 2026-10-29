from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.matchers import SyslogMessageMatcher


def generate_filename_from_timestamp(timestamp):
    """
    This function generates filename from timestamp
    :param timestamp: timestamp
    :returns: string with timestamp
    """

    date_part, time_part = timestamp.split(' ')
    filename = f"{date_part.replace('.', '_')}__{time_part.replace(':', '_').replace('.', '_')}"
    return filename


def analyse_crm_logs(enb_id, enb_pci, gnb_id, gnb_pci, expected_nr_sharing_ratio, expected_lte_load, btslog):
    """
    This function analyze CRM logs
    :param enb_id: eNB id
    :param enb_pci: Lte cell id for analise.
    :param gnb_id: gNB id.
    :param gnb_pci: gNB cell id for analise.
    :param expected_nr_sharing_ratio: Expected NR sharing_ratio to compare.
    :param expected_lte_load: Expected LTE load to compare.
    :param btslog: path to lte syslog
    :returns: None
    """

    crm_logs = extract_crm_logs_from_syslog(enb_id, enb_pci, gnb_id, gnb_pci, btslog)
    crm_data = extract_data_from_all_crm_logs(crm_logs)
    sharing_ratios, lte_load = split_data(crm_data)
    logger.info(f'\n\n++++++++++++++++++++ CRM Analysis Results ++++++++++++++++++++', also_console=True)
    _analyse_sharing_ratio(sharing_ratios, float(expected_nr_sharing_ratio))
    _analyse_lte_load(lte_load, float(expected_lte_load))
    logger.info(f'\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n', also_console=True)


def split_data(crm_data):
    """
    This function checks sharing ratio data and LTE load data
    :param crm_data: mixed data
    :returns: tuple of lists with sharing ratio data and LTE load data
    """
    sharing_ratios = [(data[0], data[1]) for data in crm_data]
    lte_load = [data[2] for data in crm_data]
    return sharing_ratios, lte_load


def _analyse_sharing_ratio(sharing_ratios, expected_nr_sharing_ratio):
    """
    This function checks if NR PDCCH sharing ratio is greater than given
    and sum of NR and LTE sharing ratio is about 100%
    :param sharing_ratios: current sharing ratios
    :param expected_nr_sharing_ratio: Expected NR sharing ratio to compare.
    :returns: None
    """

    verify_sharing_ratios(sharing_ratios)
    avg_nr_ratio, avg_lte_ratio = calculate_avg_sharing_ratio(sharing_ratios)
    logger.info(f'NrRatio: {avg_nr_ratio:.2f}%', also_console=True)
    logger.info(f'LteRatio: {avg_lte_ratio:.2f}%', also_console=True)
    result = avg_nr_ratio > expected_nr_sharing_ratio
    if result:
        logger.info(f'NR sharing ratio {avg_nr_ratio:.2f}% '
                    f'is bigger than expected {expected_nr_sharing_ratio}% and is correct', also_console=True)
    else:
        logger.warn(f'NR sharing ratio {avg_nr_ratio:.2f}% '
                    f'is lower than expected {expected_nr_sharing_ratio}% and is not correct')


def extract_data_from_all_crm_logs(crm_logs):
    """
    This function parse crm log lines and extracts sharing ratio data and LTE load data
    :returns: list of tuples with extracted data
    """
    data = [extract_data_from_crm_log_line(crm_log) for crm_log in crm_logs
            if crm_log and extract_data_from_crm_log_line(crm_log)]
    clean_data = [x for x in data if x]
    return clean_data


def _analyse_lte_load(lte_load, expected_lte_load):
    """
    This function checks if LTE load is about expected LTE load.
    :param lte_load: list of LTE loads
    :param expected_lte_load: LTE load to compare.
    :returns: None
    """
    precision = 20
    avg_lte_load = calculate_avg_lte_load(lte_load)
    logger.info(f'LTE load: {avg_lte_load:.2f}%', also_console=True)
    result = abs(avg_lte_load - expected_lte_load) < precision
    if result:
        logger.info(f'LTE load {avg_lte_load:.2f}% '
                    f'is about {expected_lte_load:.2f}% with precision {precision} and is correct', also_console=True)
    else:
        logger.warn(f'LTE load {avg_lte_load:.2f}% '
                    f'is not close to {expected_lte_load:.2f}% with precision {precision}% and is not correct')


def calculate_avg_lte_load(lte_load):
    """
    This function calculates average lte load.
    :param lte_load:  list of lte loads
    :returns: average NR ratio and average LTE ratio
    """

    return sum(lte_load) / len(lte_load)


def extract_crm_logs_from_syslog(enb_id, enb_pci, gnb_id, gnb_pci, btslog):
    """
    This function filters syslog for crm log lines
    :param enb_id: eNB id
    :param enb_pci: lte cell id for analise
    :param gnb_id: gNB id
    :param gnb_pci: gNB cell id for analise
    :param btslog: path to lte syslog file
    :returns: lines that match pattern
    """

    with LogHelper() as lh:
        syslog = lh.add_syslog(btslog)
        enb_id_hex = _string_int_to_hex(enb_id)
        enb_pci_hex = _string_int_to_hex(enb_pci)
        gnb_id_hex = _string_int_to_hex(gnb_id)
        gnb_pci_hex = _string_int_to_hex(gnb_pci)
        crm_sharing_ratio_prints = syslog.find_all(
            SyslogMessageMatcher(f'*CRMexe*CRM?e{enb_id_hex}c{enb_pci_hex}g{gnb_id_hex}c{gnb_pci_hex}?CrmDlStatus*'))
        assert crm_sharing_ratio_prints, 'No sign of CRM logs in Syslog.'
        return crm_sharing_ratio_prints


def _string_int_to_hex(value):
    """
    This function converts string that represents int to hex
    :param value: string value
    :returns: hex value
    """

    return format(int(value), 'X')


def extract_data_from_crm_log_line(crm_log):
    """
    This function extracts NR and LTE sharing ratio from crm log line
    :param crm_log:  line of crm log
    :returns: tuple of nr_ratio, lte_ratio and lte_load
    """

    crm_log = crm_log.split('CrmDlStatus:')[-1].strip().split(' ')
    lte_ratio = crm_log[0].split(':')[1]
    nr_ratio = crm_log[1].split(':')[1]
    lte_load = crm_log[4].split(':')[1]

    try:
        lte_ratio = float(lte_ratio)
        nr_ratio = float(nr_ratio)
        lte_load = float(lte_load)
    except ValueError:
        return None

    return nr_ratio, lte_ratio, lte_load


def verify_sharing_ratios(sharing_ratios):
    """
    This function checks if all sharing ratios have correct values.
    :param sharing_ratios:  list of tuples of NR ratio and LTE ratio
    :returns: None
    """
    result = all(is_correct_sharing_ratio_pair(lte_ratio, nr_ratio) for nr_ratio, lte_ratio in sharing_ratios)
    if not result:
        logger.warn('LteRatio and NrRatio do not sum up to 100.')


def is_correct_sharing_ratio_pair(lte_ratio, nr_ratio):
    """
    This function checks if sharing ratios have correct values. Sum is about 100% with predefined precision
    :param lte_ratio:  LTE sharing ratio
    :param nr_ratio:  NR sharing ratio
    :returns: boolean of comparison result
    """

    precision = 0.1
    return abs(100 - lte_ratio - nr_ratio) < precision


def calculate_avg_sharing_ratio(sharing_ratios):
    """
    This function calculates average sharing ratio.
    :param sharing_ratios:  list of tuples of nr_ratio and lte_ratio
    :returns: tuple of average NR ratio and average LTE ratio
    """

    return [sum(x) / len(x) for x in zip(*sharing_ratios)]
