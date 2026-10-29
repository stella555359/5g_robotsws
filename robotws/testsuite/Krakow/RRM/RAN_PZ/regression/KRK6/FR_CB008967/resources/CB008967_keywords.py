import logging
import os
import re
import xml.etree.ElementTree as ET
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from ta5g_pm_counters import ta5g_pm_counters
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
from taf.rfrl.utilities.robot.parallel_runner import run_parallel_in_robot
from taf.rfrl.bts.devices.du.du_operations import GenericDuOperations

coam_admin = admin()
output_dir = BuiltIn().get_variable_value("${OUTPUTDIR}")


def get_rd_counters_file_path():
    """
    Checks output RD_BTS_counters directory in output directory for xml files and returns filepaths to the newest
    :return: filepath of the newest .xml file with RD counters
    """
    rd_counters_path = f'{output_dir}/RD_BTS_counters'
    logging.info(f"File list: {list(filter(lambda f: f.lower().endswith('.xml'), os.listdir(rd_counters_path)))}")
    filename = sorted(list(filter(lambda f: f.lower().endswith('.xml'), os.listdir(rd_counters_path))))[-1]
    file_path = f'{output_dir}/RD_BTS_counters/{filename}'
    assert os.path.exists(file_path), "RD counters file is not downloaded"
    logging.info(f"RD counters .xml: {file_path}")
    return file_path


def parse_temp_range_rd_counters():
    """
    Parses RD counters file
    :return: list of incremented RD counters
    """
    file_path = get_rd_counters_file_path()
    root = ET.parse(file_path).getroot()
    TEMP_RANGE_SAMPLES = []
    for element in root.iter():
        if 'TEMP_RANGE' in element.tag:
            TEMP_RANGE_SAMPLES.append(f'{element.tag}: {element.text}')
            if last_dn_tag:
                logging.info(f"{last_dn_tag}: {last_dn_text}")
            logging.info(f"{element.tag}: {element.text}")
            last_dn_tag, last_dn_text = '', ''
        if element.tag == 'DN':
            last_dn_tag, last_dn_text = element.tag, element.text
    incremented_counters = list(filter(lambda x: not x.endswith('0'), TEMP_RANGE_SAMPLES))
    return incremented_counters


def get_interval_from_rd_counters():
    """
    Parses RD counters file to get pm interval from collected samples number
    :return: pm interval based on collected samples
    """
    file_path = get_rd_counters_file_path()
    root = ET.parse(file_path).getroot()
    release = GenericDuOperations(bts_type='GNB').get_bts_sw_release_name()
    rmod_temp_counter_name = 'RMOD_TEMP_NORMAL_SAMPLES' if release in ["SBTS26R1", "SBTS26R2"] else \
        'NR_RMOD_TEMP_NORMAL_SAMPL'
    interval = []
    for element in root.iter():
        if rmod_temp_counter_name in element.tag:
            interval.append(f'{element.tag}: {element.text}')
            if last_dn_tag:
                logging.info(f"{last_dn_tag}: {last_dn_text}")
            logging.info(f"{element.tag}: {element.text}")
            last_dn_tag, last_dn_text = '', ''
        if element.tag == 'DN':
            last_dn_tag, last_dn_text = element.tag, element.text
    interval = list(filter(lambda x: x.endswith('300') or x.endswith('360'), interval))
    value = [x.split(' ')[1] for x in interval]
    logging.info(value)
    return int(max(value))/60


def check_temp_range_rd_counters(interval):
    """
    Verifies that RD counters are present for SMOD and both BBMODs and their values equal configured interval
    :param interval: value of configure reportingIntervalPm
    :return: none
    """
    incremented_counters = parse_temp_range_rd_counters()
    logging.info(f"Incremented counters: {incremented_counters}")
    assert ''.join(incremented_counters).count('SMOD') == 1, 'SMOD TEMPERATURE counters are not present'
    assert ''.join(incremented_counters).count('BBMOD') == 2, 'At least one BBMOD TEMPERATURE counter is not present'
    values = set([x.split(' ')[1] for x in incremented_counters])
    assert values == {interval}, "Counters' values are not equal to measurement interval"


def check_rmod_temp_range_rd_counters(rmod_no):
    """
    Verifies that RD counters are present for RMOD and their values equal configured interval
    :param rmod_no: number of RMODs in BTS
    :return: none
    """
    interval = int(get_interval_from_rd_counters())
    logging.info(interval)
    incremented_counters = parse_temp_range_rd_counters()
    logging.info(f"Incremented counters: {incremented_counters}")
    assert ''.join(incremented_counters).count('RMOD') == int(rmod_no), 'Not all RMOD TEMPERATURE counters are present'
    values = set([x.split(' ')[1] for x in incremented_counters])
    assert values == {str(interval)}, "Counters' values are not equal to measurement interval"


def check_asirmod_temp_range_rd_counters(interval, asirmod_no):
    """
    Verifies that RD counters are present for ASIRMOD and their values equal configured interval
    :param interval: value of configure reportingIntervalPm
    :param asirmod_no: number of ASIRMODs in BTS
    :return: none
    """
    incremented_counters = parse_temp_range_rd_counters()
    logging.info(f"Incremented counters: {incremented_counters}")
    assert ''.join(incremented_counters).count('ASIR') == int(asirmod_no), 'Not all ASIRMOD counters are present'
    values = set([x.split(' ')[1] for x in incremented_counters])
    assert values == {interval}, "Counters' values are not equal to measurement interval"


def log_full_rd_counters():
    """
    Logs full RD BTS counters for debugging purposes
    :return:
    """
    output_dir = BuiltIn().get_variable_value("${OUTPUTDIR}")
    filename = list(filter(lambda f: f.lower().endswith('.xml'), os.listdir(f'{output_dir}/RD_BTS_counters')))[0]
    tree = ET.parse(f'{output_dir}/RD_BTS_counters/{filename}')
    root = tree.getroot()
    for element in root.iter():
        print(f"{element.tag}: {element.text}")


def get_real_time_measurements_dict():
    """Retrieves real-time measurements from the COAM admin and returns them as a combined dictionary.

    :return: A dictionary containing all real-time measurements retrieved from the COAM admin.
    :rtype: dict
    """
    rt_meas_list = coam_admin.get_real_time_measurements()
    rt_meas_dict_combined = {}
    for dictionary in rt_meas_list:
        rt_meas_dict_combined.update(dictionary)
    logging.info(rt_meas_dict_combined)
    return rt_meas_dict_combined


def get_cabinet_fan_speed_real_time_measurements():
    """Retrieves the real-time fan speed measurement for cabinet R-1, fan R-2.
    :return: The real-time fan speed measurement for cabinet R-1, fan R-2.
    :rtype: int
    """
    rt_meas_dict = get_real_time_measurements_dict()
    logging.info(rt_meas_dict['FAN_SPEED/CABINET/CABINET_R-1/FAN_R-2'])
    return rt_meas_dict['FAN_SPEED/CABINET/CABINET_R-1/FAN_R-2']


def get_asirmods_fan_speed_real_time_measurements():
    """Retrieves real-time fan speed measurements for both APHG and APHA ASIRMODs.
    :return: A dictionary containing lists of fan speed measurements for APHG and APHA ASIRMODs.
    :rtype: dict
    """
    rt_meas_dict = get_real_time_measurements_dict()
    asirmods_dict = {'APHG': [], 'APHA': []}
    for asirmod, asirmod_id in zip(['APHG', 'APHA'], range(1, 3)):
        for fan in range(1, 5):
            fan_speed = rt_meas_dict[f'FAN_SPEED/ASIRMOD/ASIRMOD_R-{asirmod_id}/FAN_R-{fan}']
            logging.info(f"{asirmod} - FAN-{fan}: {fan_speed}")
            asirmods_dict[asirmod].append(fan_speed)
    return asirmods_dict


def check_that_asirmod_fan_speed_is_not_reported(rt_measurements):
    """Verifies that no fan speed measurements are reported for the APHG ASIRMOD.
    :param rt_measurements: A dictionary containing real-time measurements.
    :type rt_measurements: dict
    :raises AssertionError: If any fan speed value is not '-'.
    """
    fan1_rt = rt_measurements['FAN_SPEED/ASIRMOD/ASIRMOD_R-1/FAN_R-1']
    fan2_rt = rt_measurements['FAN_SPEED/ASIRMOD/ASIRMOD_R-1/FAN_R-2']
    fan3_rt = rt_measurements['FAN_SPEED/ASIRMOD/ASIRMOD_R-1/FAN_R-3']
    fan4_rt = rt_measurements['FAN_SPEED/ASIRMOD/ASIRMOD_R-1/FAN_R-4']
    assert fan1_rt == fan2_rt == fan3_rt == fan4_rt == '-', \
        "At least one APHG FAN speed reported its speed in real time measurements but it shouldn't"


def get_pm_counters_values(counters, localmoid):
    """Retrieves PM counter values for specified counters and local MOID from the latest PM counters file.
    :param counters: A comma-separated string of PM counter names.
    :type counters: str
    :param localmoid: The local MOID for which to retrieve counter values.
    :type localmoid: str
    :return: A dictionary containing the values for the specified PM counters.
    :rtype: dict
    """
    pm_counters_file = ta5g_pm_counters().get_latest_unpacked_full_pm_counters_file()
    counters_list = counters.split(', ')
    counters_dict = {key: None for key in counters_list}
    for counter in counters_list:
        counter_value = ta5g_pm_counters().get_pm_counter_value(counter=counter,
                                                                localmoid=localmoid,
                                                                filepath=pm_counters_file)
        logging.info(f"{counter}: {counter_value}")
        counters_dict[counter] = counter_value
    print(counters_dict)
    return counters_dict


def get_asirmod_fan_speed_counters_values(asirmod_id):
    """Retrieves average fan speed PM counter values for a given ASIRMOD.
    :param asirmod_id: The ID of the ASIRMOD for which to retrieve fan speed values.
    :type asirmod_id: str or int
    :return: A list containing the average fan speed values for all four fans.
    :rtype: list
    """
    pm_counters_file = ta5g_pm_counters().get_latest_unpacked_full_pm_counters_file()
    avg_counters_per_fan = []
    for fan_id in range(1, 5):
        for counter in range(3):
            counter_value = ta5g_pm_counters().get_pm_counter_value(
                counter=f"M40032C{counter}",
                localmoid=f"PLMN-PLMN/MRBTS-77122/EQM-1/APEQM-1/ASIRMOD-{asirmod_id}/FAN-{fan_id}",
                filepath=pm_counters_file)
            if counter == 2:
                avg_counters_per_fan.append(counter_value[0])
            logging.info(f"M40032C{counter}: {counter_value}")
    logging.info(f"Avg counters for all Fans: {avg_counters_per_fan}")
    return avg_counters_per_fan


def get_cabinet_fan_speed_from_syslog():
    """Extracts the last reported cabinet fan speed from a syslog file.

    :return: The last reported cabinet fan speed.
    :rtype: int
    """
    filename = list(filter(lambda f: f.lower().startswith('syslog'), os.listdir(f'{output_dir}/')))[0]
    filepath = output_dir + '/' + filename
    fan_speed_list = []
    with open(filepath, 'r') as syslog:
        syslog_content = syslog.readlines()
    for line in syslog_content:
        match = re.search(r"Calculated measurement for \[EFanUnit_FsmFan2]:\s(\d+)", line)
        if match:
            fan_speed_list.append(match.group(1))
    logging.info(f"Fan speeds: {fan_speed_list}")
    last_fan_speed = int(float(fan_speed_list[-1]))
    logging.info(f"Last reported cabinet fan speed: {last_fan_speed}")
    return last_fan_speed


def compare_cabinet_fan_speeds_from_all_sources(pm_counters, fan_speed_rt_meas, fan_speed_syslog):
    """Compares cabinet fan speed values from PM counters, real-time measurements, and syslog.

    :param pm_counters: A dictionary containing PM counter values, including "M40031C2" for cabinet fan speed.
    :type pm_counters: dict
    :param fan_speed_rt_meas: The cabinet fan speed value obtained from real-time measurements.
    :type fan_speed_rt_meas: int
    :param fan_speed_syslog: The cabinet fan speed value obtained from the syslog file.
    :type fan_speed_syslog: int
    :raises AssertionError: If any fan speed value deviates significantly from the real-time measurement value.
    """
    logging.info(f"Fan speed - PM counters: {pm_counters}")
    logging.info(f"Fan speed - real time measurement: {fan_speed_rt_meas}")
    logging.info(f"Fan speed - syslog: {fan_speed_syslog}")
    avg_pm_counter = int(pm_counters["M40031C2"][-1])
    assert int(fan_speed_rt_meas) - 5 <= avg_pm_counter <= int(fan_speed_rt_meas) + 5, \
        f'M40031C2 avg cabinet fan speed ({avg_pm_counter}) is much different from ' \
        f'real time measurement ({fan_speed_rt_meas})'
    assert int(fan_speed_rt_meas) - 5 <= int(fan_speed_syslog) <= int(fan_speed_rt_meas) + 5, \
        f'Cabinet fan speed reported in syslog ({fan_speed_syslog} is different from ' \
        f'real time measurement ({fan_speed_rt_meas})'


def compare_asirmod_fan_speed_counters_with_syslog_prints(counters_aphg, counters_apha, med_fanspeed, fanspeed_rpm):
    """Compares ASIRMOD fan speed PM counters with syslog prints.

    :param counters_aphg: A list of PM counter values for the APHG ASIRMOD.
    :type counters_aphg: list
    :param counters_apha: A list of PM counter values for the APHA ASIRMOD.
    :type counters_apha: list
    :param med_fanspeed: A dictionary containing fan speed values from syslog prints for both ASIRMODs.
    :type med_fanspeed: dict
    :param fanspeed_rpm: A dictionary containing fan speed RPM values for both ASIRMODs.
    :type fanspeed_rpm: dict
    :raises AssertionError: If any PM counter value deviates significantly from the syslog print or RPM value.
    """
    for counters, asirmod in zip([counters_aphg, counters_apha], ['APHG', 'APHA']):
        logging.info(f">> {asirmod}:\n")
        for fan in range(4):
            rpm_percentage = 100 * int(fanspeed_rpm[asirmod][fan]) / 16000
            logging.info(f"FAN-{fan + 1}:\n Counter: {counters[fan]}\n Syslog: "
                         f"{med_fanspeed[asirmod][fan]}\n RPM: {fanspeed_rpm[asirmod][fan]} ({rpm_percentage:.2f}%)")
            assert int(med_fanspeed[asirmod][fan]) - 5 <= int(counters[fan]) <= int(med_fanspeed[asirmod][fan]) + 5, \
                f"FAN-{fan + 1} PM Counter ({counters[fan]}) not matches syslog print {med_fanspeed[asirmod][fan]}"
            assert rpm_percentage - 5 <= int(counters[fan]) <= rpm_percentage + 5, \
                f"FAN-{fan + 1} PM Counter ({counters[fan]}) not matches rpm syslog print {rpm_percentage}"


def compare_asirmod_fan_speed_measurements_with_syslog_prints(rt_meas, med_fanspeed, fanspeed_rpm):
    """Compares ASIRMOD fan speed measurements with syslog prints.

    :param rt_meas: A dictionary containing real-time fan speed measurements for both ASIRMODs.
    :type rt_meas: dict
    :param med_fanspeed: A dictionary containing fan speed values from syslog prints for both ASIRMODs.
    :type med_fanspeed: dict
    :param fanspeed_rpm: A dictionary containing fan speed RPM values for both ASIRMODs.
    :type fanspeed_rpm: dict
    :raises AssertionError: If any real-time measurement value deviates significantly from the syslog print
    or RPM value."""
    for asirmod in ['APHG', 'APHA']:
        logging.info(f">> {asirmod}:\n")
        for fan in range(4):
            rpm_percentage = 100 * int(fanspeed_rpm[asirmod][fan]) / 16000
            logging.info(f"FAN-{fan + 1}:\n Counter: {rt_meas[asirmod][fan]}\n Syslog: "
                         f"{med_fanspeed[asirmod][fan]}\n RPM: {fanspeed_rpm[asirmod][fan]} ({rpm_percentage:.2f}%)")

            assert int(med_fanspeed[asirmod][fan]) - 4 <= int(rt_meas[asirmod][fan]) <= \
                   int(med_fanspeed[asirmod][fan]) + 4, f"FAN-{fan + 1} Fan speed measurement " \
                                                        f"({rt_meas[asirmod][fan]}) not matches syslog print " \
                                                        f"{med_fanspeed[asirmod][fan]}"
            assert rpm_percentage - 4 <= int(rt_meas[asirmod][fan]) <= rpm_percentage + 4, \
                f"FAN-{fan + 1} Fan speed measurement ({rt_meas[asirmod][fan]}) not matches rpm syslog print " \
                f"{rpm_percentage}"


def check_that_lss_snapshot_has_been_collected():
    """Check if snapshot is collected to the home directory.
    """
    from pathlib import Path
    home_dir = '/home/ute/'
    snapshot_dir = list(filter(lambda f: f.startswith('Snapshot'), os.listdir(home_dir)))
    assert snapshot_dir, "LSS snapshot is not collected"
    assert len(snapshot_dir) == 1, f"More than one LSS snapshot is collected to {home_dir}: {snapshot_dir}"
    snapshot_name = snapshot_dir[0]
    snapshot_path = Path(home_dir + snapshot_name)
    snapshot_files = [f for f in snapshot_path.iterdir() if f.is_file()]
    assert snapshot_files, f"Snapshot is empty"
    logging.info(f"Snapshot file path: {home_dir + snapshot_name}")


def delete_all_existing_lss_snapshots():
    os.system('rm -rf /home/ute/Snapshot*')


def get_vm_password():
    """Get vm password for ute user.

       :return: Password for ute user account.
       :rtype: str
    """
    os.system('sudo cat /etc/ute/vncpasswd > tmp')
    password = open('tmp', 'r').read()
    return password
