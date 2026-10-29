from statistics import stdev
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
import os
from taf.sbts.oam.coam.admin import admin
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.common_keywords.file_utils import file_reader

api = admin()


def confirm_feature_not_affecting_throughputs(disabled_80dbm: str, disabled_90dbm: str, disabled_100dbm: str,
                                              enabled_80dbm: str, enabled_90dbm: str, enabled_100dbm: str) -> None:
    """
    :param disabled_80dbm: DL throughput statistics for -80dbm signal with feature disabled
    :param disabled_90dbm: DL throughput statistics for -90dbm signal with feature disabled
    :param disabled_100dbm: DL throughput statistics for -100dbm signal with feature disabled
    :param enabled_80dbm: DL throughput statistics for -80dbm signal with feature enabled
    :param enabled_90dbm: DL throughput statistics for -90dbm signal with feature enabled
    :param enabled_100dbm: DL throughput statistics for -100dbm signal with feature enabled

    checks if enabling feature doesn't affect average throughput nor its deviation on 3 different signal strengths
    """
    average_80dbm_disabled, dev_80dbm_disabled = _check_throughput(disabled_80dbm, '80', 'disabled')
    average_90dbm_disabled, dev_90dbm_disabled = _check_throughput(disabled_90dbm, '90', 'disabled')
    average_100dbm_disabled, dev_100dbm_disabled = _check_throughput(disabled_100dbm, '100', 'disabled')

    average_80dbm_enabled, dev_80dbm_enabled = _check_throughput(enabled_80dbm, '80', 'enabled')
    average_90dbm_enabled, dev_90dbm_enabled = _check_throughput(enabled_90dbm, '90', 'enabled')
    average_100dbm_enabled, dev_100dbm_enabled = _check_throughput(enabled_100dbm, '100', 'enabled')

    assert average_80dbm_disabled*0.95 < average_80dbm_enabled < average_80dbm_disabled*1.05, \
        'Throughput on -80dbm signal strength has changed too much after  enabling thefeature'
    assert abs(dev_80dbm_disabled - dev_80dbm_enabled) < 4, 'Deviation changed too much after enabling the feature'
    assert average_90dbm_disabled * 0.95 < average_90dbm_enabled < average_90dbm_disabled * 1.05, \
        'Throughput on -90dbm signal strength has changed too much after  enabling thefeature'
    assert abs(dev_90dbm_disabled - dev_90dbm_enabled) < 5, 'Deviation changed too much after enabling the feature'
    assert average_100dbm_disabled * 0.95 < average_100dbm_enabled < average_100dbm_disabled * 1.05, \
        'Throughput on -100dbm signal strength has changed too much after  enabling thefeature'
    assert abs(dev_100dbm_disabled - dev_100dbm_enabled) < 6, 'Deviation changed too much after enabling the feature'


def _check_throughput(tput_values: str, signal: str, feature: str) -> tuple[float, float]:
    tput_avg = (round(float(tput_values.split(',')[0])/1000000, 2))
    deviation = round(stdev(map(int, tput_values.split(';')[1].split(",")))/1000000, 2)
    relative_deviation = round((deviation/tput_avg) * 100, 2)
    log_info_to_console(msg=f'Average throughput on -{signal}dbm signal strength with feature {feature}: {tput_avg}'
                            f'Mbps with {deviation}Mb deviation({relative_deviation}%)')
    return tput_avg, relative_deviation


def check_for_syslog_print_during_feature_activation(syslog_dir: str) -> None:
    """
    :param syslog_dir: syslog files directory path

    Checks for prints stating that actLaEnhanceEfficiencyLatency was recommissioned to value 'DL'.
    """
    needed_prints = ['reconfiguring param: actLaEnhanceEfficiencyLatency',
                     '"actLaEnhanceEfficiencyLatency":', '"DL_ONLY"']
    lines = []
    for filename in sorted(os.listdir(syslog_dir)):
        filepath = os.path.join(syslog_dir, filename)
        for line in file_reader(filepath):
            if any(log in line for log in needed_prints):
                lines.append(line)
    log_info_to_console(msg='\nSyslog prints found: ')
    for line in lines:
        log_info_to_console(msg=line)
    for needed_print in needed_prints:
        assert needed_print in str(lines), f'no \'{needed_print}\' print found'


def confirm_uplink_througput_gain_after_enabling_feature(tputs_disabled: list, tputs_enabled: list) -> None:
    """
    :param tputs_disabled: List of UL throughput values across -75dBm to -120dBm signal strength span
    when feature was disabled
    :param tputs_enabled: List of UL throughput values across -75dBm to -120dBm signal strength span
    when feature was enabled

    Checks if enabling feature brings a maximum of 4% throughput gain and doesn't affect its deviation.
    """
    disabled_avgs, disabled_deviations = _check_throughputs(tputs_disabled, 'disabled')
    enabled_avgs, enabled_deviations = _check_throughputs(tputs_enabled, 'enabled')
    disabled_sum = sum(disabled_avgs)
    enabled_sum = sum(enabled_avgs)
    gain = (enabled_sum - disabled_sum)*100 / disabled_sum
    log_info_to_console(msg=f'Overall throughput gain after enabling feature: {gain}%')
    assert disabled_sum < enabled_sum, f'No throughput gain registered after enabling the feature. (gain: {gain}%)'
    assert gain < 4, f'Throughput gain bigger than expected after enabling the feature. (gain: {gain}%)'
    _check_deviations(disabled_deviations[:-4])
    _check_deviations(enabled_deviations[:-4])


def _check_throughputs(tputs, feature):
    starting_signal_strength = 75
    avgs = []
    deviations = []
    for tput_values in tputs:
        avg_tput, dev = _check_throughput(tput_values, str(starting_signal_strength), feature)
        starting_signal_strength = starting_signal_strength + 5
        avgs.append(avg_tput)
        deviations.append(dev)
    return avgs, deviations


def _check_deviations(deviations):
    starting_dev = 5
    for deviation in deviations:
        assert deviation < starting_dev, f'Deviation too high ({deviation}%)'
        starting_dev = starting_dev + 0.5
