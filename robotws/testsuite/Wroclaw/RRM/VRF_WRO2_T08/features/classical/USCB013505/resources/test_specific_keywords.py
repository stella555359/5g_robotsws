from taf.rfrl.utilities.logger.custom_logger import log_info_to_console, log_warn_to_console
import statistics
from taf.sbts.oam.coam.admin import admin
import re
import time
from datetime import datetime
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import wait_for_next_pm_interval_and_get_counters

api = admin()

tput_print_regex = re.compile(r"DL\s\|\s\{cc:\s0}\s\|\savgPHY.Kbps:\s\d{1,6}\s\|\sBLER.%:\s\d{1,2}\s\|\scrc#:\["
                              r"pass:\s\d{1,4};\sfail:\s\d{1,4};\siovFail:\s\d{1,4}]\s\|\savgTB.bytes:\s\d{1,7}\s"
                              r"\|\savgMCS\*10:\s\d{2,3}\s\|\savgRB:\s\d{1,4}\s\|\s")


def wait_until_counter_collection_time(start_minutes_before=5):
    """
    Waiting until new counter reporting interval starts.
    :param start_minutes_before: you can start the test case a few minutes before reporting interval.
    """
    log_info_to_console('waiting until time is right')
    rest = 5 - int(start_minutes_before)
    while True:
        time_now = datetime.now()
        if time_now.minute % 5 == rest and int(time_now.second) < 12:
            log_info_to_console('The time is right!!!')
            return
        else:
            time.sleep(5)


def _read_ue_log(qxdm_path: str) -> str:
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    return text


def _create_averages(values, step):
    for i in range(int((len(values) + step - 1)/step)):
        average_values = [int(x) for x in values][i*step:(i+1)*step]
        yield sum(average_values)/len(average_values)


def analyze_throughput_logs(qxdm_path: str) -> tuple[float, float, float]:
    """
    Analyzes UE log to find throughput, MCS and RB values and calculate their averages.
    :param qxdm_path: path to ue logs
    :return: throughput, MCS and RB average values in tuple
    """
    text = _read_ue_log(qxdm_path)
    tput_prints = tput_print_regex.findall(text)
    tput_values, mcs_values, rb_values = [], [], []
    for line in tput_prints:
        tput_values.append((re.search(r"avgPHY.Kbps:\s(\d{1,7})", line).group()).split(" ")[1])
        mcs_values.append((re.search(r"avgMCS\*10:\s(\d{2,3})", line).group()).split(" ")[1])
        rb_values.append((re.search(r"avgRB:\s(\d{1,4})", line).group()).split(" ")[1])
    averages = _create_averages(tput_values,  int(len(tput_values) / 10))
    log_info_to_console("Average throughput values in time:")
    for i in averages:
        log_info_to_console(f"{i} Kbps")
    log_info_to_console("----------------------------------------------------")
    log_info_to_console(f"Average throughput overall: {statistics.mean([int(x) for x in tput_values])} Kbps")
    log_info_to_console(f"Average MCS: {statistics.mean([int(x) for x in mcs_values]) / 10}")
    log_info_to_console(f"Average RB: {statistics.mean([int(x) for x in rb_values])}")
    return (statistics.mean([int(x) for x in tput_values]), statistics.mean([int(x) for x in mcs_values]) / 10,
            statistics.mean([int(x) for x in rb_values]))


def compare_a_b1_results(avg_tput_disabled, avg_mcs_disabled, avg_rb_disabled,
                         avg_tput_enabled, avg_mcs_enabled, avg_rb_enabled):
    """
    Compares average throughput, MCS and RB values before and after enabling the feature to check if
    enabling the feature had expected impact on these parameters.
    :param avg_tput_disabled: average throughput value before enabling the feature
    :param avg_mcs_disabled: average MCS value before enabling the feature
    :param avg_rb_disabled: average resource blocks granted before enabling the feature
    :param avg_tput_enabled: average throughput value after enabling the feature
    :param avg_mcs_enabled: average MCS value after enabling the feature
    :param avg_rb_enabled: average resource blocks granted after enabling the feature
    """
    assert int(avg_tput_enabled) > int(avg_tput_disabled), "Average throughput should be higher after enabling feature."
    assert int(avg_mcs_disabled) > int(avg_mcs_enabled), "Average MCS should be lower after enabling feature"
    assert int(avg_rb_enabled) > int(avg_rb_disabled), "Average RB should be higher after enabling feature"


def check_mcs(qxdm_path):
    """
    Checks if MCS values in UE log are 21 or less to make sure UE didn't cross the threshold to trigger the feature.
    :param qxdm_path: path to UE log
    """
    text = _read_ue_log(qxdm_path)
    tput_prints = tput_print_regex.findall(text)
    for line in tput_prints:
        mcs = int((re.search(r"avgMCS\*10:\s(\d{2,3})", line).group()).split(" ")[1])/10
        if mcs > 19:
            log_warn_to_console(f"Warning: Found MCS value {mcs}")
        assert mcs <= 21, f"MCS value {mcs} is too high, should be 21 or less."


def verify_b_b1_counters() -> None:
    """
    Checks if counters M55165C00041 and M55165C00042 have not been incremented during B_B1 TC
    """
    admin_alias = api.setup_admin(alias='admin_alias')
    counters = wait_for_next_pm_interval_and_get_counters(counter_ids=['M55165C00041', 'M55165C00042'],
                                                          admin_connection=admin_alias)
    api.teardown_admin(alias=admin_alias)
    paths = ['BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRUC/M55165C00041',
             'BTS/MRBTS-50825/NRBTS-50825/NRCELL-250/NRUC/M55165C00042']
    _check_counters(counters, paths)


def _check_counters(counters, paths):
    counter_values = {}
    for path in paths:
        counter_values[path.split('NRBTS-50825')[-1]] = str(counters[path][0]).split(' ')[-1].replace(')', '')
    for counter in counter_values.keys():
        log_info_to_console(msg=f'{counter} counter value: {counter_values[counter]}\n')
        assert int(counter_values[counter]) == 0, f'Counter {counter} has been incremented unexpectedly.'
