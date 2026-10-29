import logging
import os
import re
from datetime import datetime
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning as GnbScf
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion

SGNB_ADDITION_MSG = r'.*?RadioAdmissionControlService.cpp:\d+.*?Received AdmissionReq for UE ueIdCu:\d+.*?with ' \
                    r'NsaSgnbAddition'
SGNB_RELEASE_REQUIRED_MSG = r'.*?RadioAdmissionControlService.cpp:\d+.*?Received ResourceReleaseReq for NSA UE ' \
                            r'ueIdCu:\d+'


def _get_timestamp_of_event_in_syslog(event_pattern, syslog):
    syslog_line_pattern = re.compile(event_pattern, re.IGNORECASE)
    found_pattern = False
    timestamp_pattern = re.compile(r'\s(\d\d:\d\d:\d\d)\.\d+\s')
    with open(syslog, 'r') as syslog_file:
        for line in syslog_file:
            if syslog_line_pattern.match(line):
                found_pattern = True
                logging.info('Pattern found in syslog: "{}"'.format(line))
                match_timestamp = re.search(timestamp_pattern, line)
                return match_timestamp
    if not found_pattern:
        raise ValueError('Not found pattern: "{}" in syslog: "{}"'.format(event_pattern, syslog))


def _get_timestamps_of_attach_msgs_occurrence(syslog_path):
    attach_msgs = [SGNB_ADDITION_MSG, SGNB_RELEASE_REQUIRED_MSG]
    attach_msgs_timestamps = []
    for msg in attach_msgs:
        attach_msg_timestamp = _get_timestamp_of_event_in_syslog(msg, syslog_path)
        attach_msgs_timestamps.append(attach_msg_timestamp.group(0).strip())
    return attach_msgs_timestamps


def change_ul_data_path_via_webem(nsadrb_parameters_list, bts_id=0, du_id=0, first_execution=True):
    sw_version = GnbDuOperations().get_bts_sw_version(bts_id=bts_id, du_id=du_id)
    logging.info("Actual SW release: {}".format(SbtsSwVersion(sw_version).release))
    if not SbtsSwVersion(sw_version) >= SbtsSwVersion('SBTS23R4_ENB_0000_000000_000000') and first_execution:
        nsadrb_parameters_list[0]["value"][0].pop("dlPreferredPath")
    gnb_scf = GnbScf()
    gnb_scf.perform_object_recommissioning(dist_name='MRBTS-{}/NRBTS-{}/NRDRB-6',
                                           parameter=nsadrb_parameters_list,
                                           operation='update',
                                           skip_parameter_relation_errors=True
                                           )


def clear_previous_syslog():
    syslog_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "moler",
                               get_builtin_value("TEST NAME").replace(" ", "_"), "moler.GNB0_DU0_SYSLOG.raw.log")
    if os.path.exists(syslog_path):
        os.truncate(syslog_path, 0)
        logging.info("Previous syslog file successfully deleted!")
    else:
        logging.info("Syslog not found!")


def compare_counter_to_calculated_syslog_value(counter, syslog_value):
    min_syslog_value = 0.9 * counter
    max_syslog_value = 1.1 * counter
    if not isinstance(syslog_value, int):
        raise TypeError("Calculated bearer duration calculated from syslog: {} should be integer!".format(syslog_value))
    if not min_syslog_value < syslog_value < max_syslog_value:
        raise ValueError("Counter value: {} differs significantly from bearer duration calculated from syslog: {}".
                         format(counter, syslog_value))
    else:
        logging.info("Success! Counter and syslog bearer duration match!")


def measure_attach_time():
    syslog_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "moler",
                               get_builtin_value("TEST NAME").replace(" ", "_"), "moler.GNB0_DU0_SYSLOG.raw.log")
    times = _get_timestamps_of_attach_msgs_occurrence(syslog_path)
    attach_time = datetime.strptime(times[0], "%H:%M:%S.%f")
    detach_time = datetime.strptime(times[1], "%H:%M:%S.%f")
    time_difference = detach_time - attach_time
    elapsed_time = int((time_difference.seconds * 1000) + (time_difference.microseconds / 1000))
    return elapsed_time
