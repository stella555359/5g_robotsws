"""
:copyright: Nokia Networks
:authors:
    Paulina Jedras, paulina.jedras@nokia.com
:maintainers:
    Paulina Jedras, paulina.jedras@nokia.com
"""
import re
from copy import deepcopy
from pprint import pformat
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations as GnbBbu

csv_bip = csv_verifiers()
NOK_LINES_ALLOWED = 5  # percentage of allowed syslog lines with early/late messages
NOK_MESSAGES_ALLOWED = 1  # percentage of allowed early/late messages in single syslog line
OUTPUT_DIR = BuiltIn().get_variable_value("${OUTPUT_DIR}")
all_counters_syslog = OUTPUT_DIR+"/GNB_syslog/Filtered_syslog_all_counters_lines.log"
nok_counters_syslog = OUTPUT_DIR+"/GNB_syslog/Filtered_syslog_nok_counters_lines.log"
critical_counters_syslog = OUTPUT_DIR+"/GNB_syslog/Filtered_syslog_critical_counters_lines.log"
cells_dl = ['16385', '16386', '16387', '16388', '16389', '16390', '16391', '16392']
cells_ul = ['16385', '16386', '16387', '16388']

ALL_COUNTERS_PATTERNS_26R1 = \
    {'l1_dl_ok': r'INF/l1_application_rt.*nrDl DU Stats',
     'l1_ul_ok': r'INF/l1_application_rt.*nrUl Stats',
     'l1_dl_nok': r'WRN/l1_application_rt.*nrDl DU Stats',
     'l1_ul_nok': r'WRN/l1_application_rt.*nrUl Stats',
     'l2_ok': r'msg:0x(....)\s+totalCounter:(\d+)\s+outOfWindowCounter:0',
     'l2_nok': r'msg:0x(....)\s+totalCounter:(\d+)\s+outOfWindowCounter:([1-9]\d?)'
     }

ALL_COUNTERS_PATTERNS = \
    {'l1_dl_ok': r'INF/l1_application_rt.*nrDl DU Stats',
     'l1_ul_ok': r'INF/l1_application_rt.*nrUl Stats',
     'l1_dl_nok': r'WRN/l1_application_rt.*nrDl DU Stats',
     'l1_ul_nok': r'WRN/l1_application_rt.*nrUl Stats',
     'l2_dl_ok': r'TimingWindow nrDl Stats.*0xe126,(\d+),0\|0xe113,(\d+),0\|0xe200,(\d+),0',
     'l2_ul_ok': r'TimingWindow nrUl Stats.*0xe25e,(\d+),0\|0xe20b,(\d+),0',
     'l2_dl_nok': r'TimingWindow nrDl Stats.*0xe126,(\d+),([1-9]\d?)\|0xe113,(\d+),([1-9]\d?)\|0xe200,(\d+),([1-9]\d?)',
     'l2_ul_nok': r'TimingWindow nrUl Stats.*0xe25e,(\d+),([1-9]\d?)\|0xe20b,(\d+),([1-9]\d?)',
     'debug_log': r'L1L2TIMING.*currentBcn.*is not in the range'
     }


def verify_timestamps_in_bip(csv_path):
    """
    Verifies, that all messages in BIP have set field Timestamp
    :param csv_path: path to BIP csv file
    """
    csv_list = csv_bip.create_list_of_lists_from_csv(csv_path)
    timestamp_presence = csv_bip.get_column_values(csv_list, "swe.T")
    timestamp_values = csv_bip.get_column_values(csv_list, "swe.Timestamp")

    assert 0 not in timestamp_presence, f'At least one message in BIP has not set timestamp'
    assert 0 not in timestamp_values, f'At least one message in BIP has not correct timestamp'


def verify_early_late_l1l2_msgs_rate(syslog_path):
    release = _check_active_sw()
    if release == "SBTS26R1":
        verify_early_late_l1l2_msgs_rate_26r1(syslog_path)
    else:
        verify_early_late_l1l2_msgs_rate_other(syslog_path)


def verify_early_late_l1l2_msgs_rate_26r1(syslog_path):
    """
    Filter in syslog all lines containing L2PS and L1 counters for early/late messages
    Verifies, that number of lines with messages not in time range is less than max allowed
    Verifies, that number of messages not in time range in single line is less than max allowed

    L1 filtered lines
      l1_application_rt[...]nrDl DU Stats
      l1_application_rt[...]nrUl Stats
    L2 filtered lines
      nrCellId:<id>> msg:0x<id> totalCounter:<x> outOfWindowCounter:<y>
    """

    syslog_lines = _read_syslog(syslog_path)
    syslog_lines_with_counters, _ = _filter_lines(syslog_lines, ALL_COUNTERS_PATTERNS_26R1.values())
    _, l1_dl_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS_26R1['l1_dl_ok'])
    _, l1_ul_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS_26R1['l1_ul_ok'])
    _, l1_dl_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS_26R1['l1_dl_nok'])
    _, l1_ul_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS_26R1['l1_ul_nok'])
    _, l2_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS_26R1['l2_ok'])
    _, l2_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS_26R1['l2_nok'])
    all_lines = syslog_lines_with_counters
    nok_lines, critical_lines = [], []

    for line in syslog_lines_with_counters:
        if re.search(ALL_COUNTERS_PATTERNS_26R1['l1_dl_nok'], line):
            nok_lines.append(line)
            result = _is_l1_early_late_msg_rate_out_of_allowed_range(line)
            if result:
                critical_lines.append(line)
        elif re.search(ALL_COUNTERS_PATTERNS_26R1['l1_ul_nok'], line):
            nok_lines.append(line)
            result = _is_l1_early_late_msg_rate_out_of_allowed_range(line)
            if result:
                critical_lines.append(line)
        else:
            match = re.search(ALL_COUNTERS_PATTERNS_26R1['l2_nok'], line)
            if match:
                nok_lines.append(line)
                result = _is_l2_early_late_msg_rate_out_of_allowed_range_26r1(match)
                if result:
                    critical_lines.append(line)

    save_filtered_syslog_files(all_counters_syslog, all_lines)
    save_filtered_syslog_files(nok_counters_syslog, nok_lines)
    save_filtered_syslog_files(critical_counters_syslog, critical_lines)

    l1_nok_rate_dl = (l1_dl_nok / (l1_dl_ok + l1_dl_nok)) * 100
    l1_nok_rate_ul = (l1_ul_nok / (l1_ul_ok + l1_ul_nok)) * 100
    l2_nok_rate = (l2_nok / (l2_nok + l2_ok)) * 100

    logger.info(f'Percentage of early/late DL messages in L1: {l1_nok_rate_dl}%')
    logger.info(f'Percentage of early/late UL messages in L1: {l1_nok_rate_ul}%')
    logger.info(f'Percentage of early/late messages in L2: {l2_nok_rate}%')
    logger.info(f'All syslog lines with early/late/ok messages filtered: {all_counters_syslog}')
    logger.info(f'All syslog lines with at least 1 early/late messages filtered: {nok_counters_syslog}')
    logger.info(f'All syslog lines with early/late messages over '
                f'{NOK_MESSAGES_ALLOWED}% filtered: {critical_counters_syslog}')
    assert l1_dl_ok, f'100% of messages in L1 DL  is not in expected time range'
    assert l1_ul_ok, f'100% of messages in L1 UL is not in expected time range'
    assert l2_ok, f'100% of messages in L2 is not in expected time range'
    assert l1_nok_rate_dl < NOK_LINES_ALLOWED, \
        f'Total rate of early/late DL messages in L1 is too high: {l1_nok_rate_dl}% > {NOK_LINES_ALLOWED}%'
    assert l1_nok_rate_ul < NOK_LINES_ALLOWED, \
        f'Total rate of early/late UL messages in L1 is too high: {l1_nok_rate_ul}% > {NOK_LINES_ALLOWED}%'
    assert l2_nok_rate < NOK_LINES_ALLOWED, \
        f'Total rate of early/late messages in L2 is too high: {l2_nok_rate}% > {NOK_LINES_ALLOWED}%'
    assert critical_lines == [], \
        f'Rate of early/late messages in single line is over {NOK_MESSAGES_ALLOWED}%'


def verify_early_late_l1l2_msgs_rate_other(syslog_path):
    """
    Filter in syslog all lines containing L2PS and L1 counters for early/late messages
    Verifies, that number of lines with messages not in time range is less than max allowed
    Verifies, that number of messages not in time range in single line is less than max allowed

    L1 filtered lines
      l1_application_rt[...]nrDl DU Stats
      l1_application_rt[...]nrUl Stats
    L2 filtered lines
      nrCellId:<id>> msg:0x<id> totalCounter:<x> outOfWindowCounter:<y>
    """

    syslog_lines = _read_syslog(syslog_path)
    syslog_lines_with_counters, _ = _filter_lines(syslog_lines, ALL_COUNTERS_PATTERNS.values())
    _, l1_dl_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l1_dl_ok'])
    _, l1_ul_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l1_ul_ok'])
    _, l1_dl_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l1_dl_nok'])
    _, l1_ul_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l1_ul_nok'])
    _, l2_dl_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l2_dl_ok'])
    _, l2_ul_ok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l2_ul_ok'])
    _, l2_dl_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l2_dl_nok'])
    _, l2_ul_nok = _filter_lines(syslog_lines_with_counters, ALL_COUNTERS_PATTERNS['l2_ul_nok'])
    all_lines = syslog_lines_with_counters
    nok_lines, critical_lines = [], []

    for line in syslog_lines_with_counters:
        if re.search(ALL_COUNTERS_PATTERNS['debug_log'], line):
            nok_lines.append(line)
        if re.search(ALL_COUNTERS_PATTERNS['l1_dl_nok'], line):
            nok_lines.append(line)
            result = _is_l1_early_late_msg_rate_out_of_allowed_range(line)
            if result:
                critical_lines.append(line)
        elif re.search(ALL_COUNTERS_PATTERNS['l1_ul_nok'], line):
            nok_lines.append(line)
            result = _is_l1_early_late_msg_rate_out_of_allowed_range(line)
            if result:
                critical_lines.append(line)
        elif re.search(ALL_COUNTERS_PATTERNS['l2_dl_nok'], line):
            nok_lines.append(line)
            result = _is_l2_early_late_msg_rate_out_of_allowed_range(line)
            if result:
                critical_lines.append(line)
        elif re.search(ALL_COUNTERS_PATTERNS['l2_ul_nok'], line):
            nok_lines.append(line)
            result = _is_l2_early_late_msg_rate_out_of_allowed_range(line)
            if result:
                critical_lines.append(line)

    save_filtered_syslog_files(all_counters_syslog, all_lines)
    save_filtered_syslog_files(nok_counters_syslog, nok_lines)
    save_filtered_syslog_files(critical_counters_syslog, critical_lines)

    l1_nok_rate_dl = (l1_dl_nok / (l1_dl_ok + l1_dl_nok)) * 100
    l1_nok_rate_ul = (l1_ul_nok / (l1_ul_ok + l1_ul_nok)) * 100
    l2_nok_rate_dl = (l2_dl_nok / (l2_dl_nok + l2_dl_ok)) * 100
    l2_nok_rate_ul = (l2_ul_nok / (l2_ul_nok + l2_ul_ok)) * 100

    logger.info(f'Percentage of early/late DL messages in L1: {l1_nok_rate_dl}%')
    logger.info(f'Percentage of early/late UL messages in L1: {l1_nok_rate_ul}%')
    logger.info(f'Percentage of early/late DL messages in L2: {l2_nok_rate_dl}%')
    logger.info(f'Percentage of early/late UL messages in L2: {l2_nok_rate_ul}%')
    logger.info(f'All syslog lines with early/late/ok messages filtered: {all_counters_syslog}')
    logger.info(f'All syslog lines with at least 1 early/late messages filtered: {nok_counters_syslog}')
    logger.info(f'All syslog lines with early/late messages over '
                f'{NOK_MESSAGES_ALLOWED}% filtered: {critical_counters_syslog}')
    assert l1_dl_ok, f'100% of messages in L1 DL  is not in expected time range'
    assert l1_ul_ok, f'100% of messages in L1 UL is not in expected time range'
    assert l2_dl_ok, f'100% of messages in L2 DL  is not in expected time range'
    assert l2_ul_ok, f'100% of messages in L2 UL is not in expected time range'

    assert l1_nok_rate_dl < NOK_LINES_ALLOWED, \
        f'Total rate of early/late DL messages in L1 is too high: {l1_nok_rate_dl}% > {NOK_LINES_ALLOWED}%'
    assert l1_nok_rate_ul < NOK_LINES_ALLOWED, \
        f'Total rate of early/late UL messages in L1 is too high: {l1_nok_rate_ul}% > {NOK_LINES_ALLOWED}%'
    assert l2_nok_rate_dl < NOK_LINES_ALLOWED, \
        f'Total rate of early/late DL messages in L2 is too high: {l1_nok_rate_dl}% > {NOK_LINES_ALLOWED}%'
    assert l2_nok_rate_ul < NOK_LINES_ALLOWED, \
        f'Total rate of early/late UL messages in L2 is too high: {l1_nok_rate_ul}% > {NOK_LINES_ALLOWED}%'
    assert critical_lines == [], \
        f'Rate of early/late messages in single line is over {NOK_MESSAGES_ALLOWED}%'


def _read_syslog(syslog_path):
    with open(syslog_path, 'r') as syslog:
        syslog_lines = syslog.readlines()
    return syslog_lines


def _filter_lines(syslog_lines, patterns):
    if isinstance(patterns, str):
        patterns = [patterns]
    filtered_lines = [line for line in syslog_lines if any(re.search(pattern, line) for pattern in patterns)]
    return filtered_lines, len(filtered_lines)


def _is_l1_early_late_msg_rate_out_of_allowed_range(line):
    l1_group_stats = line.split(": ")[-1].split("|")
    for group in l1_group_stats:
        stats = group.split(",")
        ok = int(stats[0])
        early = int(stats[1])
        late = int(stats[2])
        other_error = int(stats[3])
        nok = early + late + other_error
        total = nok + ok
        if nok:
            nok_rate = (nok / total) * 100
            if nok_rate > NOK_MESSAGES_ALLOWED:
                return True
    return False


def _is_l2_early_late_msg_rate_out_of_allowed_range_26r1(match):
    total_counter = int(match.group(2))
    out_of_window_counter = int(match.group(3))
    single_interval_nok_rate = (out_of_window_counter / total_counter) * 100
    if single_interval_nok_rate > NOK_MESSAGES_ALLOWED:
        return True
    return False


def _is_l2_early_late_msg_rate_out_of_allowed_range(line):
    l2_group_stats = line.split(": ")[-1].split("|")
    for group in l2_group_stats:
        stats = group.split(",")
        ok = int(stats[1])
        nok = int(stats[2])
        if nok:
            nok_rate = (nok / ok) * 100
            if nok_rate > NOK_MESSAGES_ALLOWED:
                return True
    return False


def save_filtered_syslog_files(file_path, lines):
    with open(file_path, "w") as f:
        for line in lines:
            f.write(f"{line}\n")


def verify_l2ps_counters_printed_for_each_cell(syslog_path, intervals):
    release = _check_active_sw()
    if release == "SBTS26R1":
        verify_l2ps_counters_printed_for_each_cell_26r1(syslog_path, intervals)
    else:
        verify_l2ps_counters_printed_for_each_cell_other(syslog_path, intervals)


def verify_l2ps_counters_printed_for_each_cell_26r1(syslog_path, intervals):
    """
    Verifies, that in each 10s interval L2PS counts number of messages for each cell separately
    :param syslog_path: path to syslog file
    :param intervals: number of expected 10s intervals with L2PS counters
    """
    intervals = int(intervals)
    with open(syslog_path, 'r') as file:
        lines = file.readlines()
    pattern = r"nrCellId:(\d+)\s+msg:0x(....)\s+totalCounter:(\d+)\s+outOfWindowCounter:(\d+)"

    pdcchsendreq_e113 = {key: deepcopy([]) for key in cells_dl}
    pdschpayloadtbsendreq_e126 = {key: deepcopy([]) for key in cells_dl}
    puschreceiverespharqu_e20b = {key: deepcopy([]) for key in cells_ul}

    for line in lines:
        match = re.search(pattern, line)
        if match:
            cellid = match.group(1)
            msgid = match.group(2)
            total_counter = int(match.group(3))
            if msgid == "e113":
                pdcchsendreq_e113[cellid].append(total_counter)
            if msgid == "e126":
                pdschpayloadtbsendreq_e126[cellid].append(total_counter)
            if msgid == "e20b":
                puschreceiverespharqu_e20b[cellid].append(total_counter)

    logger.info(f'0xe113 counter for each cell for all intervals:\n {pformat(pdcchsendreq_e113)}')
    logger.info(f'0xe20b counter for each cell for all intervals:\n {pformat(puschreceiverespharqu_e20b)}')
    logger.info(f'0xe126 counter for each cell for all intervals:\n {pformat(pdschpayloadtbsendreq_e126)}')

    num_of_cells_with_const_traffic = sum(1 for value in pdcchsendreq_e113.values() if len(value) >= intervals)
    assert num_of_cells_with_const_traffic > 5, \
        (f'0xe113 counter missing in all intervals for at least three SCells, need to check if really there is no '
         f'traffic on these cells and increase traffic load, if needed')
    assert all(len(value) >= intervals for value in puschreceiverespharqu_e20b.values()), \
        f'0xe20b counter missing for at least one interval for at least one cell'
    # 0xe126 counter may be missing in L2PS syslog, as this message with payload is sent from L2-LO to L1 directly
    # From L2-PS to L1 this message is sent only for control purpose


def verify_l2ps_counters_printed_for_each_cell_other(syslog_path, intervals):
    """
    Verifies, that in each 10s interval L2PS counts number of messages for each cell separately
    :param syslog_path: path to syslog file
    :param intervals: number of expected 10s intervals with L2PS counters
    """
    intervals = int(intervals)
    with open(syslog_path, 'r') as file:
        lines = file.readlines()
    pattern_dl = r"TimingWindow nrDl Stats<(\d+)>: 0xe126,(\d+),(\d+)\|0xe113,(\d+),(\d+)\|0xe200,(\d+),(\d+)"
    pattern_ul = r"TimingWindow nrUl Stats<(\d+)>: 0xe25e,(\d+),(\d+)\|0xe20b,(\d+),(\d+)"

    pdcchsendreq_e113 = {key: deepcopy([]) for key in cells_dl}
    pdschpayloadtbsendreq_e126 = {key: deepcopy([]) for key in cells_dl}
    puschreceiverespharqu_e20b = {key: deepcopy([]) for key in cells_ul}

    for line in lines:
        match = re.search(pattern_dl, line)
        if match:
            cellid = match.group(1)
            pdschpayloadtbsendreq_e126[cellid].append(int(match.group(2)))
            pdcchsendreq_e113[cellid].append(int(match.group(4)))
            continue
        match = re.search(pattern_ul, line)
        if match:
            cellid = match.group(1)
            if cellid in cells_ul:
                puschreceiverespharqu_e20b[cellid].append(int(match.group(4)))

    logger.info(f'0xe113 counter for each cell for all intervals:\n {pformat(pdcchsendreq_e113)}')
    logger.info(f'0xe20b counter for each cell for all intervals:\n {pformat(puschreceiverespharqu_e20b)}')
    logger.info(f'0xe126 counter for each cell for all intervals:\n {pformat(pdschpayloadtbsendreq_e126)}')

    num_of_cells_with_const_traffic = sum(1 for value in pdcchsendreq_e113.values() if len(value) >= intervals)
    assert num_of_cells_with_const_traffic > 5, \
        (f'0xe113 counter missing in all intervals for at least three SCells, need to check if really there is no '
         f'traffic on these cells and increase traffic load, if needed')
    assert all(len(value) >= intervals for value in puschreceiverespharqu_e20b.values()), \
        f'0xe20b counter missing for at least one interval for at least one cell'
    # 0xe126 counter may be missing in L2PS syslog, as this message with payload is sent from L2-LO to L1 directly
    # From L2-PS to L1 this message is sent only for control purpose


def _check_active_sw():
    bbu = GnbBbu()
    active_sw = bbu.get_bts_sw_release_name()
    return active_sw
