import subprocess
import time
import logging
from taf.hw.optical_attenuator.client import client
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

admin_cli = admin()
att_client = client()
GNB_IP = BuiltIn().get_variable_value("${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}")
GNB_USERNAME = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_ssh_connection_details.username}")
GNB_PASSWORD = BuiltIn().get_variable_value("${tl.gnbs[0].cu.oam_ssh_connection_details.password}")

RPI_SSH = 'RPI'
RPI_PID = None
RPI_IP = BuiltIn().get_variable_value("${tl.attenuators.ip_addr}")

ALL_SFP_STATS = ('LCV', 'BER', 'BER24hr', 'RXOpticalPowerUW')
SFP_STATS = ('LCV', 'BER', 'BER24hr')

RMOD_FAULT_IDS = [1955, 1956]
BBMOD_FAULT_IDS = [4476]


def get_nrbts():
    """
    Used to retrieve NRBTS id from testline configuration
    :return: type: int
    """
    return BuiltIn().get_variable_value("${tl.gnbs[0].global_bts_id}")


def get_mrbts():
    """
    Used to retrieve MRBTS id from testline configuration
    :return: type: int
    """
    return BuiltIn().get_variable_value("${tl.gnbs[0].instance_id}")


def get_apeqm_threshold_structures(minor_value, major_value):
    """
    Returns dict with APEQM object structure for configuration purposes
    :param minor_value: berMinorAlarmThreshold, type: Union[str,int]
    :param major_value: berMajorAlarmThreshold, type: Union[str,int]
    :return: type: list
    """
    return [
        {
            "parameterName": "berMajorAlarmThreshold",
            "operation": "update",
            "value": major_value
        },
        {
            "parameterName": "berMinorAlarmThreshold",
            "operation": "update",
            "value": minor_value
        }
    ]


def set_ber_alarm_thresholds(berMinorAlarmThreshold=-13, berMajorAlarmThreshold=-12):
    """
    Sets berMinorAlarmThreshold and berMajorAlarmThreshold in gNB configuration
    :param berMinorAlarmThreshold: type: Union[str,int]
    :param berMajorAlarmThreshold: type: Union[str,int]
    :return: None
    """
    admin_cli.perform_object_recommissioning(dist_name='MRBTS-{}/EQM-1/APEQM-1'.format(get_mrbts()),
                                             parameter=get_apeqm_threshold_structures(berMinorAlarmThreshold,
                                                                                      berMajorAlarmThreshold),
                                             operation='update')


def set_nrpmrnl_parameter(parameter, value):
    """
    Sets parameter in NRPMRNL object
    :param parameter: which parameter to set, eg: reportingIntervalPm, type: str
    :param value: parameter value: type: str
    :return: None
    """
    admin_cli.perform_parameter_recommissioning(dist_name='MRBTS-{}/NRBTS-{}/NRPMRNL-1'.format(get_mrbts(),
                                                                                               get_nrbts()),
                                                parameter=parameter,
                                                operation='update',
                                                value=value,
                                                skip_parameter_relation_errors=True)


def get_last_sfp_rmod_counter_value(counter_id, pm_interval=5):
    """
    Returns last reported SFP RMOD related counter
    :param pm_interval: reportingIntervalPm set in gNB configuration, type: int
    :param counter_id: eg. M55603C00010, type: str
    :return: type: int
    """
    counter_dict = admin_cli.get_pm_counters(counter_id)['BTS']['SMOD']['SFP-1']['RMOD-1']['SFPRM'][counter_id]
    return counter_dict[get_last_epoch_timestamp(pm_interval)]


def get_last_sfp_smod_counter_value(counter_id, pm_interval=5):
    """
    Returns last reported SFP BDMOD related counter
    :param pm_interval: reportingIntervalPm set in gNB configuration, type: int
    :param counter_id: eg. M55603C00010, type: str
    :return: type: int
    """
    counter_dict = \
        admin_cli.get_pm_counters(counter_id)['BTS']['SMOD']['SFP-1']['CABINET-1']['BBMOD-1']['SFPBM'][counter_id]
    return counter_dict[get_last_epoch_timestamp(pm_interval)]


def get_last_epoch_timestamp(period):
    """
    Retrieve latest timestamp in epoch format
    :param period: in minutes, reportingIntervalPm from gNB configuration, type: int
    :return: type: str
    """
    current_timestamp = time.time()
    return str(int(current_timestamp / (int(period) * 60)) * (int(period) * 60) - (int(period) * 60))


def wait_till_end_of_counter_retrieval_interval(pm_interval=5):
    """
    Waits till the end of current PM retrieval interval
    :param pm_interval: reportingIntervalPm from gNB configuration, type: int
    :return: None
    """
    guard_time = 60
    last_epoch = int(get_last_epoch_timestamp(pm_interval))
    to_wait = (last_epoch + 2 * (60 * pm_interval)) - time.time()
    time.sleep(to_wait + guard_time)


def get_latest_raw_pm_file_from_bts():
    """
    Downloads latest raw PM counter file from gNB and stores it in /tmp dir
    :return: path to PM counter file, type: str
    """
    bts_ssh = ssh()
    bts_ssh.connect_to(GNB_IP, GNB_USERNAME, GNB_PASSWORD)
    files_list = bts_ssh.execute('ls /tmp/ | grep PM\\.BTS.*raw\\.gz')
    file_name = files_list.split()[-1]
    file_path = '/tmp/{}'.format(file_name)
    bts_ssh.download_file(file_path, file_path)
    subprocess.Popen(['gunzip', '-d', file_path, '-f'], stdout=subprocess.PIPE).wait()
    return file_path.strip('.gz')


def verify_if_raw_pm_counter_file_contains_counter(file_path, counter_id, occurrences=2):
    """
    Verify counter_id presence in given raw PM file
    :param file_path: path to PM file to be verified, type: str
    :param counter_id: type: str
    :param occurrences: counter_id string occurrence number in file, type: str
    :return: None
    """
    with open(file_path) as counter_file:
        as_str = counter_file.read()
        counter_occurrences = as_str.count(str(counter_id))
        assert counter_occurrences == int(occurrences), \
            "Counter id {} found in file {} times (expected: {})".format(counter_id, counter_occurrences, occurrences)


def float_range(start, stop, step):
    """
    Creates range of float values in list
    :param start: start value of range, type: float
    :param stop: end value of range, type: float
    :param step: step value, type: float
    :return: type: list
    """
    n = int(round((stop - start) / float(step)))
    if n > 1:
        return [start + step * i for i in range(n + 1)]
    elif n == 1:
        return [start]
    else:
        return []


def increase_attenuation_until_alarm_occurs(fault_id, alarm_id, start_att=None, end_att=None, step_att=0.2):
    """
    Increase attenuation in given range and check if specific alarm was raised
    In case attenuation start is not given it is calculated based on RxOpticalPower
    :param fault_id: expected faultId, type: Union[str,int,float]
    :param alarm_id: expected alarmId, type: Union[str,int,float]
    :param start_att: start value for attenuation range, type: float
    :param end_att: end value for attenuation range, type: float
    :param step_att: step size value for attenuation range, type: float
    :return: None
    """
    alarm_found = False
    if start_att is None:
        hw = get_rmod_dist() if int(fault_id) in RMOD_FAULT_IDS else get_bbmod_dist()
        start_att, end_att = get_att_range_based_on_rx_power(hw)
    for attenuation in float_range(float(start_att), float(end_att), float(step_att)):
        set_attenuation(attenuation)
        alarm_found = wait_for_alarm(fault_id, alarm_id)
        if alarm_found:
            logging.info("Alarm occurred at {}dB attenuation".format(attenuation))
            break

    assert alarm_found, "Expected alarm {} with faultId {} not raised after attenuation " \
                        "in range ({};{})".format(alarm_id, fault_id, start_att, end_att)


def _is_alarm_in_list(fault_id, alarm_id, alarm_list):
    """
    Checks if specified fault_id and alarm_id entry is present in alarms list
    :param fault_id: faultId expected in list, type: int
    :param alarm_id: alarmId expected in list, type: int
    :param alarm_list: alarm list which can be retrieved using admin api, type: list
    :return: type: bool
    """
    for alarm_def in alarm_list:
        if alarm_def.get('faultId') == int(fault_id) and alarm_def.get('alarmId') == int(alarm_id):
            return True
    return False


def wait_for_alarm(fault_id, alarm_id, timeout=135, poll_interval=5):
    """
    Waits until given alarm is raised or timeout occurs
    :param fault_id: awaited faultId, type: int
    :param alarm_id: awaited alarmId, type: int
    :param timeout: time after which waiting will stop, type: int
    :param poll_interval: time intervals for checking if alarm is present, type: int
    :return: type: bool
    """
    start = time.time()
    while True:
        alarms_list = admin_cli.get_active_alarms()
        if time.time() - start > timeout:
            return False
        if _is_alarm_in_list(fault_id, alarm_id, alarms_list):
            return True
        time.sleep(poll_interval)


def verify_that_alarm_is_not_present_in_active_alarms(fault_id, alarm_id):
    """
    Verifies if specified alarmId faultId pair is present in active alarms set
    :param fault_id: faultId expected not to appear in activate alarms, type: int
    :param alarm_id: alarmId expected not to appear in activate alarms, type: int
    :return: None
    """
    assert _is_alarm_in_list(fault_id, alarm_id, admin_cli.get_active_alarms()) is False, \
        "Alarm {} with faultId {} is visible.".format(alarm_id, fault_id)


def check_if_none_of_ber_related_alarms_is_present():
    """
    Checks if faults 4476, 1955 are not visible in WebEM
    :return: type: bool
    """
    ber_faults = [(4476, 7115), (4476, 7116), (1956, 7116), (1955, 7116)]
    current_alarms = admin_cli.get_active_alarms()
    ber_fault_states = (_is_alarm_in_list(f_id, a_id, current_alarms) for f_id, a_id in ber_faults)
    return all(alarm_state is False for alarm_state in ber_fault_states)


def setup_attenuator_server():
    """
    Setup attenuator server on raspberry pi
    :return: None
    """
    raspberry_ssh = ssh()
    raspberry_ssh.connect_to(hostname=RPI_IP, username='pi', password='raspberry', alias=RPI_SSH)
    output = raspberry_ssh.execute(command='python3 .local/bin/optical-attenuator-server start '
                                           '--logs_path /home/pi/server.log & echo $!', connection=RPI_SSH)
    global RPI_PID
    RPI_PID = output.strip()


def teardown_attenuator_server():
    """
    Teardown attenuator server on raspberry pi
    :return: None
    """
    raspberry_ssh = ssh()
    raspberry_ssh.execute(command='kill {}'.format(RPI_PID), connection=RPI_SSH)


def setup_attenuator_client(location):
    """
    Setup attenuation client which can be used to set attenuation
    :param location: 1.1-4/1
    :return: None
    """
    att_client.setup_attenuator(server_ip=RPI_IP, vendor='kingfisher', location=location)


def set_attenuation(value, port=1):
    """
    Applies given attenuation
    :param value: attenuation value to be applied in dB, type: Union[str,int,float]
    :param port: attenuator port, currently only 1 is supported, type: int
    :return: None
    """
    logging.warn("Setting attenuation: {}".format(value))
    att_client.set_attenuation(attenuator_port=port, attenuation_value=value)


def get_all_sfp_statistics():
    """
    Creates dict with values of sfp monitoring statistics like BER, LCV, BER24hr
    eg. {(u'RMOD_R-1', u'BBMOD_R-1'): {'LCV': {u'BBMOD_R-1': 0, u'RMOD_R-1': 0},
    'BER': {u'BBMOD_R-1': 0, u'RMOD_R-1': 0}, 'BER24hr': {u'BBMOD_R-1': 0, u'RMOD_R-1': 0}}}
    :return: type: dict
    """
    sfp = admin_cli.get_sfp_links()
    connected_sfps = sfp.get('connected')
    lcv_ber_dict = {}
    for connected_sfp in connected_sfps:
        measurements = connected_sfp.get('data').get('measurements')
        readable = {}
        src, dst = _get_src_and_dst(connected_sfp)
        for key in ALL_SFP_STATS:
            cm = measurements[key]
            readable[key] = {src: cm.get(u'source'), dst: cm.get(u'destination')}
        lcv_ber_dict[(src, dst)] = readable
    return lcv_ber_dict


def _get_src_and_dst(sfp_desc):
    """
    Retrieves source and destination names (RMOD-1/BBMOD-1) from SFP monitoring data
    :param sfp_desc: SFP statistics retrieved by admin api, type: dict
    :return: type: tuple
    """
    cablink_parent = sfp_desc['parent']
    src = cablink_parent['source']['distName'].split('/')[-1]
    dst = cablink_parent['destination']['distName'].split('/')[-1]
    return src, dst


def get_sfp_statistic(source, destination, statistic):
    """
    Returns given statistic for source-destination pair
    :param source: eg RMOD_R-1, type: str
    :param destination: eg BBMOD_R-1, type: str
    :param statistic: BER/LCV/BER24hr, type: str
    :return: type: list
    """
    return get_all_sfp_statistics()[(source, destination)][statistic]


def check_if_sfp_ber_lcv_are_cleared(source, destination):
    """
    Checks if all BER/LCV related statistics for given SFP pair are 0
    :param source: eg RMOD_R-1, type: str
    :param destination: eg BBMOD_R-1, type: str
    :return: type: bool
    """
    stats = get_all_sfp_statistics()[(source, destination)]
    for stat in SFP_STATS:
        current_stats = stats[stat][source]
        current_stats.extend(stats[stat][destination])
        if not all(value == 0 for value in current_stats):
            return False
    return True


def increase_attenuation_until_sfp_statistics_are_updated(hw, start_att=None, end_att=None, step_att=0.25, wait=70):
    """
    Increase attenuation in given range and check if SFP stats were updated
    :param wait: how long to wait, in seconds, for stat update, type: int
    :param hw: RMOD_R-1/BBMOD_R-1, type: str
    :param start_att: start value for attenuation range, type: float
    :param end_att: end value for attenuation range, type: float
    :param step_att: step size value for attenuation range, type: float
    :return: None
    """
    stat_updated = False
    if start_att is None:
        start_att, end_att = get_att_range_based_on_rx_power(hw)
    for attenuation in float_range(float(start_att), float(end_att), float(step_att)):
        set_attenuation(attenuation)
        time.sleep(wait)
        statistics = [get_sfp_statistic(get_rmod_dist(), get_bbmod_dist(), stat) for stat in SFP_STATS]
        logging.info(statistics)
        stat_updated = all([float(stat[hw][0]) > 0 for stat in statistics])
        if stat_updated:
            break

    assert stat_updated, "SFP statistics ({}) not updated".format(SFP_STATS)


def get_att_range_based_on_rx_power(hw):
    """
    Calculates start and end values of attenuation based on rx power
    :param hw: RMOD_R-1/BBMOD_R-1, type: str
    :return: start and end attenuation, type: tuple
    """
    rx_pwr = get_all_sfp_statistics()[list(get_all_sfp_statistics())[0]].get('RXOpticalPowerUW')[hw][0]
    start_att = round(0.03 * rx_pwr + 4.5, 1)
    end_att = round(start_att + 3.5, 1)
    logging.warn('Using auto generated start and end attenuation values (start={}dB, end={}dB) at starting RX power '
                 'level {}uW'.format(start_att, end_att, rx_pwr))
    return start_att, end_att


def get_rmod_dist():
    """
    Returns currently used RMOD_R-X dist
    NOTE: method assumes that there is only one RMOD/BBMOD used in testline
    """
    rmod_dist = [dist for dist in list(get_all_sfp_statistics())[0] if 'RMOD' in dist]
    return rmod_dist[0]


def get_bbmod_dist():
    """
    Returns currently used BBMOD_R-X dist
    NOTE: method assumes that there is only one RMOD/BBMOD used in testline
    """
    bbmod_dist = [dist for dist in list(get_all_sfp_statistics())[0] if 'BBMOD' in dist]
    return bbmod_dist[0]
