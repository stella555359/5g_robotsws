import os
import re
import subprocess
import time
import zipfile
from datetime import datetime, timedelta

from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from ute_tshark.interface import ute_tshark

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap import dcap, extract_logs
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.dcap.webemil_parser import decode_emil_and_save_as_json
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.pm_counters import wait_for_next_pm_interval_and_get_counters
from testsuite.Wroclaw.RRM.resources.log.log import blog

ute_tshark = ute_tshark()
api = admin()
_ssh = ssh()
_builtin = BuiltIn()
tl = _builtin.get_variable_value("${tl}")
ue = tl.ues[0]
DCAP_PROFILE = {
                'gnb_custom_profile':  ["cp_5g"],
                'bts_custom_profile':  ['scf', 'ipCapture', ],
                'bip_mirroring_time':  0,
                'wait_for_activation': True}

# QXDM LOGS PATTERNS

a4_pattern = \
    re.compile(r'reportConfigId (\d+),\s(?s:.{50,500})a4-Threshold rsr[qp] : (\d+),\s+reportOnLeave .*?\s+hysteresis '
               r'(\d+(?:.\d+)?),\s+timeToTrigger (.*?),\s')
ssb_freq_pattern = re.compile(r'measObjectId\s\d{1,2}(?s:.{30,100})ssbFrequency\s\d{5,8}')
timestamp_pattern = re.compile(r'(\d+:\d+:\d+.\d+).*DL_DCCH / RRCReconfiguration')
timestamp_pattern_meas_report = re.compile(r'(\d+:\d+:\d+.\d+).*UL_DCCH / MeasurementReport')
meas_id_remove_pattern = \
    re.compile(r'(measIdToRemoveList\s+\{\s+(?:\d+,?\s+)+)},')
meas_id_add_pattern = \
    re.compile(r'(measIdToAddModList\s+\{\s+(?:\{\s+measId \d+,\s+measObjectId \d+,\s+reportConfigId \d+\s+},?\s+)+)')
measurement_report_pattern = \
    re.compile(r'(message\sc1\s:\smeasurementReport\s(?s:.{100,300})measResultServingCell\s(?s:.{1,50})physCellId\s\d'
               r'{1,3},\s(?s:.{500,1000})measResultNeighCells\smeasResultListNR\s:\s'
               r'(?s:.{50,100})physCellId\s\d{1,3},)')

# PCAP PATTERNS

arrival_time_pattern = re.compile(r'Arrival Time: .{1,3}\s{1,2}\d{1,2}, \d{4} (\d+:\d+:\d+.\d+) CE[ST]')
meas_object_ids_add_pattern = re.compile(r'measObjectToAddModList:(?s:.{1,12000})reportConfigToAddModList')
meas_object_ids_remove_pattern = re.compile(r'measObjectToRemoveList:(?s:.{1,2000})measObjectToAddModList')
report_config_ids_add_pattern = re.compile(r'reportConfigToAddModList:(?s:.{1,30000})measIdToAddModList')
report_config_ids_remove_pattern = re.compile(r'reportConfigToRemoveList:(?s:.{1,3000})reportConfigToAddModList')

# EXPECTED DICTS

measurement_vals_1 = [{'Threshold': '60', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '61', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '66', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '62', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '68', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '55', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'}]

ssb_frequencies_1 = {'2': '430090',  '3': '523470', '4': '521550', '5': '522990', '6': '390970'}

measurement_vals_2 = [{'Threshold': '60', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '102', 'Hysteresis': '0', 'TimeToTrigger': 'ms40'},
                      {'Threshold': '113', 'Hysteresis': '1', 'TimeToTrigger': 'ms64'}]

ssb_frequencies_2 = {'7': '430090'}

time_format = '%H:%M:%S.%f'


def setup_dcap():
    blog("Connecting to DCAP")
    if not _is_dcap_controller_started():
        start_dcap_controller()
    dcap.connect_to(host="localhost", port='9443', user=None, passwd=None)
    current_traces = dcap._api.get_all_trace_info(connection="dcap_collector")
    for trace in current_traces:
        if trace.get("status") == "running" and trace.get("status_details") == "":
            dcap.stop_trace(trace.get("id"))


def dcap_teardown():
    dcap.teardown()


def check_if_newer_than_25r1(sw):
    branch = float(".".join((sw.replace("SBTS", "").split("_")[0]).split("R")))
    return True if branch > 25.1 else False


def _is_dcap_controller_started():
    blog("Checking DCAP Controller status")
    health_check_status = subprocess.run(["utf_lab-controller", "status"], stdout=subprocess.PIPE,
                                         stderr=subprocess.PIPE)
    blog(f"DCAP Controller status: {health_check_status.stdout.decode('utf-8')}\n"
         f" {health_check_status.stderr.decode('utf-8')}")
    if health_check_status.returncode == 0:
        return True


def start_dcap_controller():
    blog("Dcap controller starting")
    start_status = subprocess.run(["utf_lab-controller", "start"], stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE)
    blog(f"DCAP Controller start status: {start_status.stdout.decode('utf-8')}\n"
         f" {start_status.stderr.decode('utf-8')}")
    if start_status.returncode == 0:
        blog("All DCAP containers started successfully. ")
        dcap_checks_attempts = 3
        for _ in range(dcap_checks_attempts):
            if _is_dcap_controller_started():
                blog("DCAP health check passed.")
                return
            time.sleep(10)
        blog("DCAP containers failed.")
        raise Exception("Starting Dcap Failed!")


def dcap_start_new_trace():
    return dcap.start_new_trace(mplane="10.44.224.6", log_profile=DCAP_PROFILE, force=True, skip_pre_check=True)


def dcap_stop_trace_and_download_logs(trace_id, output_dir):
    blog("Stopping DCAP trace")
    dcap.stop_trace(trace=trace_id)
    blog("Downloading DCAP trace")
    trace_file = dcap.download_logs(trace=trace_id, target_dir=output_dir)
    blog(f"Extracting DCAP trace to {output_dir}")
    extract_logs(trace_file)


def prepare_emil_logs_as_json(dir):
    zip_files = [file for file in os.listdir(dir) if file.endswith('.zip')]
    for zip_file in zip_files:
        with zipfile.ZipFile(os.path.join(dir, zip_file)) as file:
            for zip_info in file.infolist():
                if zip_info.is_dir():
                    continue
                zip_info.filename = os.path.basename(zip_info.filename)
                if zip_info.filename.endswith('.5gm'):
                    file.extract(zip_info, dir)
    return decode_emil_and_save_as_json(dir, "10.44.149.96", "9443")


def return_emil_msgs_from_certain_period(msgs, start, stop):
    return [msg for msg in msgs if
            datetime.strptime(stop, time_format) >
            datetime.strptime(msg['Time'][11:19], '%H:%M:%S') + timedelta(hours=1) >
            datetime.strptime(start, time_format)]


def find_measurement_reports_in_emil_logs(msgs):
    meas_reports = []
    for msg in msgs:
        if 'User_data' in str(msg):
            if 'measurementReport' in msg['User_data']:
                meas_reports.append(msg)
    return meas_reports


def find_measurement_reports_from_specific_cell_in_emil_logs(msgs, physcellid):
    meas_reports = []
    for msg in msgs:
        if (msg.get('JsonContent', {}).get('UL-DCCH-Message', {}).get('message', {}).get('c1', {})
                .get('measurementReport', {}).get('criticalExtensions', {}).get('measurementReport', {})
                .get('measResults', {}).get('measResultNeighCells', {}).get('measResultListNR')):
            for cell in msg['JsonContent']['UL-DCCH-Message']['message']['c1']['measurementReport'][
                        'criticalExtensions']['measurementReport']['measResults']['measResultNeighCells'][
                        'measResultListNR']:
                blog('cell:', cell)
                if str(cell['physCellId']) == str(physcellid):
                    meas_reports.append(msg)
    return meas_reports


def find_private_messages_in_emil_logs(msgs):
    private_messages = []
    for msg in msgs:
        if 'User_data' in str(msg):
            if msg['User_data'] == 'BufferMonitoring: activate_dl':
                private_messages.append(msg)
    return private_messages


def return_measurement_reports_adjusted_timestamps_from_emil_logs(msgs):
    return [(datetime.strptime(msg['Time'][11:-3], time_format) + timedelta(hours=2)) for msg in msgs]


def find_a4_parameters(qxdm_path):
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    result = list(a4_pattern.finditer(text))
    timestamps = [get_timestamp_based_on_result(text, result, msg_nr, timestamp_pattern)
                  for msg_nr, _ in enumerate(result)]
    result = [match.groups() for match in result]
    return result, timestamps


def check_ssb_frequencies(qxdm_path, test_phase):
    expected_ssb_frequencies = ssb_frequencies_1 if int(test_phase) == 1 else ssb_frequencies_2
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    result = list(ssb_freq_pattern.findall(text))
    ssb_freqs = {}
    for obj in result:
        if int(obj.split()[1].replace(',', '')) > 1:
            ssb_freqs[obj.split()[1].replace(',', '')] = obj.split()[-1]
    blog('reported ssb frequencies:', ssb_freqs)
    blog('expected ssb frequencies:', expected_ssb_frequencies)
    assert ssb_freqs == expected_ssb_frequencies


def find_meas_id_removes(qxdm_path):
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    result = list(meas_id_remove_pattern.finditer(text))
    timestamps = [get_timestamp_based_on_result(text, result, msg_nr, timestamp_pattern)
                  for msg_nr, _ in enumerate(result)]
    result = [match.groups() for match in result]
    return result, timestamps


def find_meas_id_adds(qxdm_path):
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    result = list(meas_id_add_pattern.finditer(text))
    timestamps = [get_timestamp_based_on_result(text, result, msg_nr, timestamp_pattern)
                  for msg_nr, _ in enumerate(result)]
    result = [match.groups() for match in result]
    return result, timestamps


def get_timestamp_based_on_result(text, result, msg_nr, pattern):
    if result:
        timestamp = pattern.search('\n'.join(reversed(text[:result[msg_nr].start(0)].splitlines()))).group(1)
    else:
        raise ValueError("No matching pattern in qxdm logs")
    return timestamp


def find_and_parse_measurement_reports(qxdm_path):
    with open(qxdm_path, 'r', errors='ignore') as f:
        text = f.read()
    result = list(measurement_report_pattern.finditer(text))
    timestamps = [get_timestamp_based_on_result(text, result, msg_nr, timestamp_pattern_meas_report)
                  for msg_nr, _ in enumerate(result)]
    result = [match.groups() for match in result]
    physcellids = meas_report_parser(result)
    return physcellids, timestamps


def meas_report_parser(results):
    physcellids = []
    for msg in results:
        cells = (re.compile(r'physCellId\s\d{1,3}').findall(msg[0]))
        physcellids.append([x.replace('physCellId ', '') for x in cells])
    return physcellids


def check_proper_cells_in_meas_reports(qxdm_path, test_phase=1):
    test_phase = int(test_phase)
    physcellids, timestamps = find_and_parse_measurement_reports(qxdm_path=qxdm_path)
    blog(physcellids)
    assert len(physcellids) > 0, "no cell sets found"
    for idx in range(len(physcellids) - 1):
        if test_phase == 1:
            assert physcellids[idx] == ['190', '196']
        else:
            assert (physcellids[idx] == ['190', '196'] and physcellids[idx + 1] == ['190', '193']) or \
                   (physcellids[idx] == ['190', '193'] and physcellids[idx + 1] == ['190', '196'])


def add_parser(qxdm_add_results):
    measid_pattern = re.compile(r'measId\s\d{1,2}')
    reportconfid_pattern = re.compile(r'reportConfigId\s\d{1,2}')
    reported_measids = []
    reported_reportconfigids = []
    for obj in qxdm_add_results:
        message_measids = []
        measids = list(measid_pattern.findall(obj[0]))
        for measid in measids:
            dic = {str(measid).split(' ')[0]: str(measid).split(' ')[1]}
            message_measids.append(dic)
        reported_measids.append(message_measids)
    for obj in qxdm_add_results:
        message_reportconfigids = []
        reportconfigids = list(reportconfid_pattern.findall(obj[0]))
        for reportconfigid in reportconfigids:
            dic = {str(reportconfigid).split(' ')[0]: str(reportconfigid).split(' ')[1]}
            message_reportconfigids.append(dic)
        reported_reportconfigids.append(message_reportconfigids)
    return reported_measids, reported_reportconfigids


def remove_parser(qxdm_remove_results):
    id_pattern = re.compile(r'\d{1,2}')
    reported_ids = []
    for msg in qxdm_remove_results:
        ids = list(id_pattern.findall(msg[0]))
        reported_ids.append(ids)
    return reported_ids


def remove_first_remove_message_if_needed(add_timestamps, remove_timestamps, remove_results):
    if round((datetime.strptime(remove_timestamps[0], time_format) -
              datetime.strptime(add_timestamps[0], time_format)).total_seconds()) < 0:
        blog('removing first remove msg')
        remove_results = remove_results[1:]
        remove_timestamps = remove_timestamps[1:]
    return remove_results, remove_timestamps


def find_starting_index(logs, expected_number_of_ids):
    for i in range(0, len(logs)):
        if len(logs[i]) == int(expected_number_of_ids):
            return i
        else:
            pass
    raise ValueError("No message with expected number of measurement ID's")


def check_adds_and_removes(qxdm_add_results, qxdm_add_timestamps, qxdm_remove_results, qxdm_remove_timestamps,
                           expected_number_of_ids, number_of_messages_to_check, check_number_of_messeges=False,
                           expected_number_of_messages=0):
    add_results, add_reportconfigids = add_parser(qxdm_add_results)
    remove_results = remove_parser(qxdm_remove_results)
    remove_results, remove_timestamps = remove_first_remove_message_if_needed(qxdm_add_timestamps,
                                                                              qxdm_remove_timestamps, remove_results)
    if round((datetime.strptime(qxdm_add_timestamps[1], time_format) -
              datetime.strptime(qxdm_add_timestamps[0], time_format)).total_seconds()) < 2:
        add_results = add_results[1:]
    adds_starting_index = find_starting_index(add_results, expected_number_of_ids)
    blog('adds starting index:', adds_starting_index)
    removes_starting_index = find_starting_index(remove_results, expected_number_of_ids)
    blog('removes starting index:', removes_starting_index)
    blog(adds_starting_index)
    blog(removes_starting_index)
    assert adds_starting_index == removes_starting_index
    for i in range(adds_starting_index, adds_starting_index + int(number_of_messages_to_check)):
        add_measids = []
        for j in range(0, len(add_results[i])):
            add_measids.append(list(add_results[i][j].values())[0])
        for measid in remove_results[i]:
            assert measid in add_measids
    if check_number_of_messeges:
        assert len(add_results) == int(expected_number_of_messages), \
            f'unexpected amount of add messages - {len(add_results)}'
        assert len(remove_results) == int(expected_number_of_messages), \
            f'unexpected amount of remove messages - {len(remove_results)}'


def get_reportconfigids(qxdm_log_results):
    reportconfigids = []
    for measurement in qxdm_log_results[0]:
        reportconfigids.append(measurement[0])
    return reportconfigids


def check_measurement_values(meas_vals, results):
    measurement_values = measurement_vals_1 if meas_vals == 'measurement_vals_1' else measurement_vals_2
    result_measurement_values = []
    for measurement in results:
        result_measurement_values.append({"Threshold": measurement[1],
                                          "Hysteresis": measurement[2],
                                          "TimeToTrigger": measurement[3]})
    blog('expected values:', measurement_values)
    blog('found values:', result_measurement_values)

    assert measurement_values == result_measurement_values


def check_timings(add_timestamps, remove_timestamps, time_after_add=4, time_after_remove=6, max_retries=5):
    if round((datetime.strptime(remove_timestamps[0], time_format) -
              datetime.strptime(add_timestamps[0], time_format)).total_seconds()) < 0:
        remove_timestamps.remove(remove_timestamps[0])
    if round((datetime.strptime(add_timestamps[1], time_format) -
              datetime.strptime(add_timestamps[0], time_format)).total_seconds()) < 2:
        add_timestamps.remove(add_timestamps[0])
    for i in range(0, max_retries):
        blog(f'checking add: {str(datetime.strptime(add_timestamps[i], time_format))}, \
             and remove: {str(datetime.strptime(remove_timestamps[i], time_format))}')
        waited_after_add = round((datetime.strptime(remove_timestamps[i], time_format) -
                                  datetime.strptime(add_timestamps[i], time_format)).total_seconds())
        blog(f'waited after add: {str(waited_after_add)}s')
        assert waited_after_add == time_after_add
        waited_after_remove = round((datetime.strptime(add_timestamps[i + 1], time_format) -
                                     datetime.strptime(remove_timestamps[i], time_format)).total_seconds())
        blog(f'waited after remove: {str(waited_after_remove)}s')
        assert waited_after_remove == time_after_remove


def verify_f1ap_messages_and_assert_timing_with_ue_logs(emil_msgs, packets_expected=True):
    private_messages = find_private_messages_in_emil_logs(emil_msgs)
    if packets_expected:
        measurement_reports = find_measurement_reports_in_emil_logs(emil_msgs)
        cell193_meas_reports = find_measurement_reports_from_specific_cell_in_emil_logs(measurement_reports, '193')
        assert len(private_messages) > 0, 'No F1AP PrivateMessage packets found'
        private_msgs_timestamps = return_measurement_reports_adjusted_timestamps_from_emil_logs(private_messages)
        cell193_meas_reports_timestamps = \
            return_measurement_reports_adjusted_timestamps_from_emil_logs(cell193_meas_reports)
        blog('privateMessages:', str(private_msgs_timestamps))
        blog('measurementReports:', str(cell193_meas_reports_timestamps))
        for idx in range(1, len(private_msgs_timestamps)):
            blog((private_msgs_timestamps[idx] - private_msgs_timestamps[idx - 1]).total_seconds() * 1000)
            assert 13500 < (private_msgs_timestamps[idx] - private_msgs_timestamps[idx - 1])\
                .total_seconds() * 1000 < 14500
        if abs((cell193_meas_reports_timestamps[0] - private_msgs_timestamps[0]).total_seconds()) * 1000 > 1500:
            blog('Removing first private message as it was from previous period')
            private_msgs_timestamps.remove(private_msgs_timestamps[0])
        blog('time diffs between measurementReports and their corresponding private Messages [ms]:')
        for idx in range(0, len(private_msgs_timestamps)):
            blog((private_msgs_timestamps[idx] - cell193_meas_reports_timestamps[idx]).total_seconds() * 1000)
            assert abs((private_msgs_timestamps[idx] - cell193_meas_reports_timestamps[idx]).total_seconds() * 1000) \
                   < 1700
    else:
        assert len(private_messages) == 0, \
            '{} F1AP PrivateMessage packets found, expected 0'.format(len(private_messages))


def find_attach_and_rrcreconfig_messages(pcap_path):
    pcap_filter = 'nr-rrc.eventId == 3'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.read_pcap(packet_filter=pcap_filter, pcap_file_path=pcap_path, alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    return packets


def find_pcap_messages_timestamps(messages):
    return list(arrival_time_pattern.findall(messages))


def find_tc11_handover_messages(pcap_path):
    pcap_filter = 'nr-rrc.physCellId == 190 && nr-rrc.physCellId == 193'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.read_pcap(packet_filter=pcap_filter, pcap_file_path=pcap_path, alias=pcap_alias)

    ute_tshark.teardown_tshark(alias=pcap_alias)
    return packets


def find_and_verify_tc21_handover_messages(pcap_path):
    pcap_filter = "s1ap || ngap"
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.read_pcap(packet_filter=pcap_filter, pcap_file_path=pcap_path, alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert 'radioNetwork: time-critical-handover (17)' in packets, 'Haven\'t found HandoverRequired message in S1AP'
    assert '(HandoverRequest)' in packets, 'Haven\'t found HandoverRequest message in NGAP'
    assert 'HandoverCommand' in packets, 'Haven\'t found HandoverCommand message in S1AP'
    assert '(HandoverNotify)' in packets, 'Haven\'t found HandoverNotify message in NGAP'
    assert ('UEContextReleaseCommand' in packets) and ('radioNetwork: successful-handover (2)' in packets), \
        'Haven\'t found UEContextReleaseCommand (Successful handover notification) message in S1AP'


def find_successful_handover_message_and_return_timestamp(pcap_path):
    pcap_filter = "s1ap.radioNetwork == 2"
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.read_pcap(packet_filter=pcap_filter, pcap_file_path=pcap_path, alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    msg_timestamp = find_pcap_messages_timestamps(packets)
    assert len(msg_timestamp) == 1, "found more than one successful handover message"
    return msg_timestamp[0]


def find_drx_reconfig_messages(pcap_path):
    pcap_filter = "nokiaf1ap.longDRXCycleLength == 9"
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    packets = ute_tshark.read_pcap(packet_filter=pcap_filter, pcap_file_path=pcap_path, alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    return packets


def find_drx_setups_and_releases(pcap_path):
    pcap_filter_setup = "nr-rrc.drx_Config == 1"
    pcap_filter_release = "nr-rrc.drx_Config == 0"
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    setup_packets = ute_tshark.read_pcap(packet_filter=pcap_filter_setup,
                                         pcap_file_path=pcap_path,
                                         alias=pcap_alias)
    release_packets = ute_tshark.read_pcap(packet_filter=pcap_filter_release,
                                           pcap_file_path=pcap_path,
                                           alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    return setup_packets, release_packets


def assert_a4_timer_and_drx_setups_proper_procedure(rrc_reconfigs_timestamps,
                                                    drx_reconfigs_timestamps,
                                                    drx_setup_timestamps,
                                                    drx_release_timestamps):
    drx_setup_timestamps = drx_setup_timestamps[::2]
    drx_release_timestamps = drx_release_timestamps[::2]
    if round((datetime.strptime(rrc_reconfigs_timestamps[1][:len(rrc_reconfigs_timestamps[1]) - 6], time_format) -
       datetime.strptime(rrc_reconfigs_timestamps[0][:len(rrc_reconfigs_timestamps[0]) - 6],
                         time_format)).total_seconds()) < 2:
        del rrc_reconfigs_timestamps[1]
    if round((datetime.strptime(drx_setup_timestamps[1][:len(drx_setup_timestamps[1]) - 6], time_format) -
       datetime.strptime(drx_setup_timestamps[0][:len(drx_setup_timestamps[0]) - 6], time_format)).total_seconds()) < 2:
        del drx_setup_timestamps[1]
    blog(drx_setup_timestamps)
    for idx in range(len(rrc_reconfigs_timestamps) - 1):
        rrc_reconfigs_timestamp = rrc_reconfigs_timestamps[idx]
        drx_setup_timestamp = drx_setup_timestamps[idx]
        drx_reconfigs_timestamp = drx_reconfigs_timestamps[idx]
        next_rrc_reconfigs_timestamp = rrc_reconfigs_timestamps[idx + 1]
        if idx == 0:
            blog('asserting:',
                 str(datetime.strptime(rrc_reconfigs_timestamp[:len(rrc_reconfigs_timestamp) - 6], time_format)), ' < ',
                 str(datetime.strptime(drx_reconfigs_timestamp[:len(drx_reconfigs_timestamp) - 6], time_format)), ' <=',
                 str(datetime.strptime(drx_setup_timestamp[:len(drx_setup_timestamp) - 6], time_format)), ' < ',
                 str(datetime.strptime(next_rrc_reconfigs_timestamp[:len(next_rrc_reconfigs_timestamp) - 6],
                                       time_format)
                     )
                 )
            assert datetime.strptime(rrc_reconfigs_timestamp[:len(rrc_reconfigs_timestamp) - 6], time_format) < \
                datetime.strptime(drx_reconfigs_timestamp[:len(drx_reconfigs_timestamp) - 6], time_format) <= \
                datetime.strptime(drx_setup_timestamp[:len(drx_setup_timestamp) - 6], time_format) < \
                datetime.strptime(next_rrc_reconfigs_timestamp[:len(next_rrc_reconfigs_timestamp) - 6], time_format)
        else:
            drx_release_timestamp = drx_release_timestamps[idx - 1]
            blog('asserting:',
                 str(datetime.strptime(rrc_reconfigs_timestamp[:len(rrc_reconfigs_timestamp) - 6], time_format)), ' < ',
                 str(datetime.strptime(drx_release_timestamp[:len(drx_release_timestamp) - 6], time_format)), ' < ',
                 str(datetime.strptime(drx_reconfigs_timestamp[:len(drx_reconfigs_timestamp) - 6], time_format)), ' <=',
                 str(datetime.strptime(drx_setup_timestamp[:len(drx_setup_timestamp) - 6], time_format)), ' < ',
                 str(datetime.strptime(next_rrc_reconfigs_timestamp[:len(next_rrc_reconfigs_timestamp) - 6],
                                       time_format)
                     )
                 )
            assert datetime.strptime(rrc_reconfigs_timestamp[:len(rrc_reconfigs_timestamp) - 6], time_format) < \
                datetime.strptime(drx_release_timestamp[:len(drx_release_timestamp) - 6], time_format) < \
                datetime.strptime(drx_reconfigs_timestamp[:len(drx_reconfigs_timestamp) - 6], time_format) <= \
                datetime.strptime(drx_setup_timestamp[:len(drx_setup_timestamp) - 6], time_format) < \
                datetime.strptime(next_rrc_reconfigs_timestamp[:len(next_rrc_reconfigs_timestamp) - 6], time_format)


def assert_all_rrc_reconfigs_and_drx_messages_after_handover_to_cell_190(rrc_reconfigs_timestamps,
                                                                         drx_reconfigs_timestamps,
                                                                         successful_ho_msg_timestamp):
    handover_time = datetime.strptime(successful_ho_msg_timestamp[:len(successful_ho_msg_timestamp) - 6], time_format)
    for message in rrc_reconfigs_timestamps:
        assert datetime.strptime(message[:len(message) - 6], time_format) > handover_time
    for message in drx_reconfigs_timestamps:
        assert datetime.strptime(message[:len(message) - 6], time_format) > handover_time


def assert_no_rrc_reconfigs_after_handover_to_cell_193(rrc_reconfigs_timestamps, time_in_cell_193):
    cell_193_start = datetime.strptime(time_in_cell_193[0][:len(time_in_cell_193[0]) - 6], time_format)
    cell_193_end = datetime.strptime(time_in_cell_193[1][:len(time_in_cell_193[1]) - 6], time_format)
    for message in rrc_reconfigs_timestamps:
        assert not (cell_193_start < datetime.strptime(message[:len(message) - 6], time_format) < cell_193_end)


def find_meas_and_reportconfig_ids(attach_message, handover_message):
    meas_object_ids_adds_raw = re.findall(re.compile(r'measObjectId: \d{1,2}(?s:.{1,300})ssbFrequency: \d{5,7}'),
                                          re.findall(meas_object_ids_add_pattern, attach_message)[0])
    meas_object_ids_adds = []
    for meas_object in meas_object_ids_adds_raw:
        meas_object_ids_adds.append(meas_object.split(" ")[1].replace('\n', '') + ',' + meas_object.split(" ")[-1])

    report_config_ids_adds_raw = re.findall(re.compile(r'reportConfigId:\s\d{1,2}'),
                                            re.findall(report_config_ids_add_pattern, attach_message)[0])
    report_config_ids_adds = []
    for report_config in report_config_ids_adds_raw:
        report_config_ids_adds.append(report_config.split(" ")[-1])

    meas_object_ids_removes_raw = re.findall(re.compile(r'MeasObjectId: \d{1,2}'),
                                             re.findall(meas_object_ids_remove_pattern, handover_message)[0])
    meas_object_ids_removes = []
    for meas_object in meas_object_ids_removes_raw:
        meas_object_ids_removes.append(meas_object.split(" ")[-1])

    report_config_ids_removes_raw = re.findall(re.compile(r'ReportConfigId: \d{1,2}'),
                                               re.findall(report_config_ids_remove_pattern, handover_message)[0])
    report_config_ids_removes = []
    for report_config in report_config_ids_removes_raw:
        report_config_ids_removes.append(report_config.split(" ")[-1])

    blog('meas object ids added and their ssb frequencies:', meas_object_ids_adds)
    blog('report config ids added', report_config_ids_adds)
    blog('meas object ids removed:', meas_object_ids_removes)
    blog('report config ids removed:', report_config_ids_removes)
    return meas_object_ids_adds, meas_object_ids_removes, report_config_ids_adds, report_config_ids_removes


def analyze_meas_ids_and_report_config_ids_adds_and_removes(meas_object_ids_adds, meas_object_ids_removes,
                                                            report_config_ids_adds, report_config_ids_removes):
    for meas_id in meas_object_ids_adds:
        if meas_id.split(",")[1] == '430090':
            pass
        else:
            assert meas_id.split(",")[0] in meas_object_ids_removes, \
                'measObjectId {} with ssbFrequency relation of {} ' \
                'not removed in Handover message'.format(meas_id.split(',')[0], meas_id.split(',')[1])
    for report_config in report_config_ids_adds[2:]:
        assert report_config in report_config_ids_removes, \
            'reportConfigId {} not removed in Handover message'.format(report_config)


def wait_until_counter_collection_time(start_minutes_before=5):
    blog('waiting until time is right')
    rest = 5 - int(start_minutes_before)
    while True:
        time_now = datetime.now()
        if time_now.minute % 5 == rest and int(time_now.second) < 12:
            blog('The time is right!!!')
            return
        else:
            time.sleep(5)


def verify_m55118c00030_counter(expected_counter_value, cell):
    admin_alias = api.setup_admin(alias='admin_alias')
    counters = wait_for_next_pm_interval_and_get_counters(counter_ids=['M55118C00030'], admin_connection=admin_alias)
    api.teardown_admin(alias=admin_alias)
    counter = str(counters['BTS/MRBTS-50819/NRBTS-50819/NRCELL-{}/NCAC/M55118C00030'.format(cell)][0]).split(' ')[-1]\
        .replace(')', '')
    blog(f'counter value: {counter} (expected {expected_counter_value} +/- 1)')
    assert int(expected_counter_value) - 1 <= int(counter) <= int(expected_counter_value) + 1


def check_handover_cell_bands_and_return_handover_timestamp(pcap_path):
    pcap_filter_band_25 = "nr-rrc.FreqBandIndicatorNR == 25"
    pcap_filter_band_2 = "nr-rrc.FreqBandIndicatorNR == 2"
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    number_of_packets_25 = ute_tshark.get_packets_count(packet_filter=pcap_filter_band_25,
                                                        pcap_file_path=pcap_path,
                                                        alias=pcap_alias)
    packets_25 = ute_tshark.read_pcap(packet_filter=pcap_filter_band_25,
                                      pcap_file_path=pcap_path,
                                      alias=pcap_alias)
    number_of_packets_2 = ute_tshark.get_packets_count(packet_filter=pcap_filter_band_2,
                                                       pcap_file_path=pcap_path,
                                                       alias=pcap_alias)
    assert number_of_packets_25 > 0, "haven't found any message with band indicator == 25"
    assert number_of_packets_2 == 0, "There was an unexpected cell reporting with band indicator == 2"
    packets_25_timestamps = find_pcap_messages_timestamps(messages=packets_25)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    return packets_25_timestamps[0]


def assert_all_a4_rrcreconfigs_are_after_handover(handover_msg_timestamp, rrcreconfig_msgs_timestamps):
    for timestamp in rrcreconfig_msgs_timestamps:
        assert datetime.strptime(timestamp[:len(timestamp) - 6], time_format) > \
               datetime.strptime(handover_msg_timestamp[:len(handover_msg_timestamp) - 6], time_format)


def assert_6_eventa4s_in_rrcreconfig(pcap_path):
    eventa4_filter = 'nr-rrc.eventId == 3 && nr-rrc.eventId != 2'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    a4_packet = ute_tshark.read_pcap(packet_filter=eventa4_filter,
                                     pcap_file_path=pcap_path,
                                     alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    reportconfigids = list(re.compile(r'reportConfigToAddModList(?s:.{1,23000})measIdToAddModList').findall(a4_packet))
    eventa4s = list(re.compile(r'eventA4\s\(3\)').findall(reportconfigids[0]))
    assert len(eventa4s) == 6, 'found {} eventA4\'s configured (expected 6)'.format(len(eventa4s))


def assert_both_cells_in_measreport_and_proper_time(pcap_path, first_attenuation, second_attenuation):
    pcap_filter = 'nr-rrc.measResultNeighCells == 0 &&  nr-rrc.physCellId == 193 &&  nr-rrc.physCellId == 195'
    measresultneighcells_filter = \
        re.compile(r'measResultListNR:\s2\sitems(?s:.{1,300})physCellId:\s19[3,5](?s:.{1,2500})physCellId:\s19[3,5]')
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    meas_report = ute_tshark.read_pcap(packet_filter=pcap_filter,
                                       pcap_file_path=pcap_path,
                                       alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    meas_report_timestamp = find_pcap_messages_timestamps(meas_report)
    blog('asserting:', str(datetime.strptime(first_attenuation, time_format)), ' < ',
         str(datetime.strptime(meas_report_timestamp[0][:len(meas_report_timestamp) - 6], time_format)), ' < ',
         str(datetime.strptime(second_attenuation, time_format)))
    assert datetime.strptime(first_attenuation, time_format) < \
           datetime.strptime(meas_report_timestamp[0][:len(meas_report_timestamp) - 6], time_format) < \
           datetime.strptime(second_attenuation, time_format)
    measresultneighcells = list(measresultneighcells_filter.findall(meas_report))
    assert len(measresultneighcells) > 0, \
        'Haven\'t found measReport containing both cells in a single measResultNeighCells'


def assert_proper_cell_measurement_reports_and_buffer_messages(pcap_path):
    eventa6_filter = re.compile(r'measObjectToAddModList:\s1\sitem(?s:.{1,8000})masterCellGroup')
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    meas_rep_195_count = \
        ute_tshark.get_packets_count(packet_filter='nr-rrc.measResultNeighCells == 0 && nr-rrc.physCellId == 195',
                                     pcap_file_path=pcap_path,
                                     alias=pcap_alias)
    meas_rep_195_msgs = \
        ute_tshark.read_pcap(packet_filter='nr-rrc.measResultNeighCells == 0 && nr-rrc.physCellId == 195',
                             pcap_file_path=pcap_path,
                             alias=pcap_alias)
    meas_rep_193_msgs = \
        ute_tshark.read_pcap(packet_filter='nr-rrc.measResultNeighCells == 0 && nr-rrc.physCellId == 193',
                             pcap_file_path=pcap_path,
                             alias=pcap_alias)
    buffer_monitoring_count = ute_tshark.get_packets_count(packet_filter='nokiaf1ap.'
                                                                         'BufferMonitoringNotification_element',
                                                           pcap_file_path=pcap_path,
                                                           alias=pcap_alias)
    buffer_criterion_count = ute_tshark.get_packets_count(packet_filter='nokiaf1ap.BufferCriterionNotification_element',
                                                          pcap_file_path=pcap_path,
                                                          alias=pcap_alias)
    eventa6_message = ute_tshark.read_pcap(packet_filter='nr-rrc.eventId == 5',
                                           pcap_file_path=pcap_path,
                                           alias=pcap_alias)
    eventa5_messages = ute_tshark.read_pcap(packet_filter='nr-rrc.eventId == 4',
                                            pcap_file_path=pcap_path,
                                            alias=pcap_alias)
    eventa4_messages = ute_tshark.read_pcap(packet_filter='nr-rrc.eventId == 3',
                                            pcap_file_path=pcap_path,
                                            alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    eventa6_info = eventa6_filter.findall(eventa6_message)
    eventa6_meas_object_ids = list(re.compile(r'measObjectId:\s\d{1,2}').findall(eventa6_info[0]))
    assert len(eventa6_meas_object_ids) == 2 and eventa6_meas_object_ids[0] == eventa6_meas_object_ids[1], \
        'MeasIds in eventA6 message don\'t match'
    eventa6_reportconfig_ids = list(re.compile(r'reportConfigId:\s\d{1,2}').findall(eventa6_info[0]))
    assert len(eventa6_reportconfig_ids) == 2 and eventa6_reportconfig_ids[0] == eventa6_reportconfig_ids[1], \
        'ReportConfigIds in eventA6 message don\'t match'
    eventa6_meas_id = list(re.compile(r'measId:\s\d{1,2}').findall(eventa6_info[0]))
    assert len(eventa6_meas_id) == 1, 'Found more than one measId in eventA6 message'
    assert meas_rep_195_count > 0, 'Haven\'t found any measurement report concerning cell 195 in second pcap'
    meas_rep_195_timestamps = find_pcap_messages_timestamps(meas_rep_195_msgs)
    meas_rep_193_timestamps = find_pcap_messages_timestamps(meas_rep_193_msgs)
    for message in meas_rep_193_timestamps:
        assert datetime.strptime(message[:len(message) - 6], time_format) <= \
               datetime.strptime(meas_rep_195_timestamps[-1][:len(meas_rep_195_timestamps[-1]) - 6], time_format), \
               'Found a cell 193 measurement report that\'s been reported after the last 195 cell measurement report'
    assert buffer_monitoring_count > 0, 'Haven\'t found any private message with BufferMonitoring=0 in second pcap'
    assert buffer_criterion_count > 0, 'Haven\'t found any private message with BufferCriterion=0 in second pcap'
    eventa4_timestamps = find_pcap_messages_timestamps(eventa4_messages)
    blog('eventA3 timestamps:', eventa4_timestamps)
    eventa5_timestamps = find_pcap_messages_timestamps(eventa5_messages)
    blog('eventA5 timestamps:', eventa5_timestamps)
    blog('asserting:', datetime.strptime(eventa5_timestamps[-1][:len(eventa5_timestamps[-1]) - 6], time_format), ' >= ',
         datetime.strptime(eventa4_timestamps[-1][:len(eventa4_timestamps[-1]) - 6], time_format))
    assert datetime.strptime(eventa5_timestamps[-1][:len(eventa5_timestamps[-1]) - 6], time_format) >= \
           datetime.strptime(eventa4_timestamps[-1][:len(eventa4_timestamps[-1]) - 6], time_format), \
           'there are messages containing eventA4 after the last one containing eventA3/A5 only'
    return str(eventa6_meas_id[0])


def assert_measurement_report_containing_both_cells(pcap_path):
    pcap_filter = 'nr-rrc.measResultNeighCells == 0 &&  nr-rrc.physCellId == 193 &&  nr-rrc.physCellId == 195'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    meas_report_num = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                                   pcap_file_path=pcap_path,
                                                   alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert meas_report_num > 0, 'Haven\'t found a measurement report message containing both cells in third pcap'


def check_rrcreconfig_message_with_cell_193_eventa6_addition_and_assert_no_rrcreconfig_and_measreport_after(pcap_path,
                                                                                                            meas_id):
    a6_removal_filter = 'nr-rrc.measIdToRemoveList == 1 && nr-rrc.sCellToAddModList == 1'
    meas_reports_rrc_reconfigs_filter = 'nr-rrc.measurementReport_element || nr-rrc.rrcReconfiguration_element'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    eventa6_message = ute_tshark.read_pcap(packet_filter=a6_removal_filter,
                                           pcap_file_path=pcap_path,
                                           alias=pcap_alias)
    meas_reports_rrc_reconfigs = ute_tshark.read_pcap(packet_filter=meas_reports_rrc_reconfigs_filter,
                                                      pcap_file_path=pcap_path,
                                                      alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    meas_id_found = list(re.compile(r'MeasId:\s\d{1,2}').findall(eventa6_message))
    assert (meas_id_found[0].split(": ")[1]) == meas_id.split(": ")[1], \
           'Found MeasId: {} is not equal to expected: {}'\
           .format(meas_id_found[0].split(": ")[1], meas_id.split(": ")[1])
    scell_release = list(re.compile(r'sCellToReleaseList:(?s:.{1,400})nonCriticalExtension').findall(eventa6_message))
    assert 'SCellIndex: 1' in scell_release[0], 'Haven\'t found SCellIndex = 1 in sCellToReleaseList'
    eventa6_message_timestamp = find_pcap_messages_timestamps(eventa6_message)
    meas_reports_rrc_reconfigs_timestamps = find_pcap_messages_timestamps(meas_reports_rrc_reconfigs)
    for message in meas_reports_rrc_reconfigs_timestamps:
        assert datetime.strptime(message[:len(message) - 6], time_format) <= \
               datetime.strptime(eventa6_message_timestamp[0][:len(eventa6_message_timestamp[0]) - 6], time_format), \
               'Found a measurement report or rrcReconfig message after the eventA6 removal rrcReconfig message'


def get_time():
    return datetime.now().strftime(time_format)


def adb_reboot_ue():
    _ssh.connect_to(hostname=ue.ue_pc_address, username='wro5grrm', password='5gpass!1')
    _ssh.send_command(command='adb reboot')
    _ssh.disconnect()
    time.sleep(30)


def find_first_rrcreconfig_timestamp(pcap_path):
    a4_filter = 'nr-rrc.eventId == 3'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    eventsa4_messages = ute_tshark.read_pcap(packet_filter=a4_filter,
                                             pcap_file_path=pcap_path,
                                             alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    timestamps = find_pcap_messages_timestamps(eventsa4_messages)
    return timestamps[1]


def wait_until_new_timer_starts(timestamp):
    blog('waiting for new timer to start')
    timestamp = datetime.strptime(timestamp[:len(timestamp) - 6], time_format)
    for i in range(1, 16):
        time.sleep(1)
        time_diff = round((datetime.strptime(get_time(), time_format) - timestamp).total_seconds())
        blog('time_diff:', time_diff)
        if time_diff % 13 == 0:
            break
        else:
            assert i != 15, 'couldn\'t find right time'


def check_no_193_and_999_arfcnssbs_reported_in_attach(pcap_path):
    pcap_filter = 'nr-rrc.ssbFrequency == 430090 || nr-rrc.ssbFrequency == 522990'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    arfcnssbs = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                             pcap_file_path=pcap_path,
                                             alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert arfcnssbs == 0, "arfcnSsbs of cell 193 or 999 were reported in attach (not expected)"


def check_buffermonitoring_messages(pcap_path):
    pcap_filter = 'nokiaf1ap.BufferMonitoring == 0'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    message_count = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                                 pcap_file_path=pcap_path,
                                                 alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert message_count > 0, "no bufferMonitoring messages found"


def verify_rsrp_reported_by_deattenuated_cell(pcap_path):
    pcap_filter = 'nr-rrc.measQuantityResults.rsrp'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    meas_reports = ute_tshark.read_pcap(packet_filter=pcap_filter,
                                        pcap_file_path=pcap_path,
                                        alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    pattern = \
        re.compile(r'physCellId: 190\s(?s:.{100,500})rsrp:\s-\d{2,3}dBm\s<=\sSS-RSRP\s<\s-\d{2,3}dBm\s[(]\d{1,2}[)]')
    values = list(pattern.findall(meas_reports))
    blog('rsrp reported:', values[0].split('(')[1].replace(')', ''))
    assert 44 <= int(values[0].split('(')[1].replace(')', '')) < 60, 'rsrp reported not between 44 and 60'


def find_buffercriterion_message_and_scells_for_carrier_aggregation(pcap_path):
    buffercriterion_filter = 'nokiaf1ap.BufferCriterionNotification_element'
    scellindexes_filter = 'nr-rrc.eventId == 1 && nr-rrc.physCellId == 193 && nr-rrc.physCellId == 196 && ' \
                          'nr-rrc.sCellIndex == 1 && nr-rrc.sCellIndex == 2'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    bufferciterion_count = ute_tshark.get_packets_count(packet_filter=buffercriterion_filter,
                                                        pcap_file_path=pcap_path,
                                                        alias=pcap_alias)
    scellindexes_count = ute_tshark.get_packets_count(packet_filter=scellindexes_filter,
                                                      pcap_file_path=pcap_path,
                                                      alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert bufferciterion_count == 1, 'There were more or less than 1 bufferCriterion messages found'
    assert scellindexes_count == 1, 'Found different amount (%s) of 3CC CA messages than expected (1)' \
                                    % scellindexes_count


def find_cell_196_ca_removal_message(pcap_path):
    pcap_filter = '((nr-rrc.SCellIndex == 2) && (nr-rrc.eventId == 0)) && (nr-rrc.measTriggerQuantity.rsrp == 60)'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    cell_196_ca_removal_count = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                                             pcap_file_path=pcap_path,
                                                             alias=pcap_alias)
    cell_196_ca_removal_msg = ute_tshark.read_pcap(packet_filter=pcap_filter,
                                                   pcap_file_path=pcap_path,
                                                   alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert cell_196_ca_removal_count == 1, "Found another amount (%s) of cell 196 removal messages than expected (1)"\
                                           % cell_196_ca_removal_count
    meas_id_pattern = \
        re.compile(r'measIdToAddModList:\s1\sitem(?s:.{1,200})MeasIdToAddMod(?s:.{1,200})measId:\s\d{1,2}')
    return list(meas_id_pattern.findall(cell_196_ca_removal_msg))[0].split(' ')[-1]


def assert_no_privatemessages_in_the_last_phase(pcap_path):
    pcap_filter = 'nokiaf1ap.procedureCode == 14'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    message_count = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                                 pcap_file_path=pcap_path,
                                                 alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert message_count == 0, "found unexpected privateMessage messages"


def assert_cell_193_switched_with_cell_999_in_ca(pcap_path, meas_id):
    pcap_filter = '(((((nr-rrc.SCellIndex == 1) && (nr-rrc.sCellToReleaseList == 1)) && ' \
                  '(nr-rrc.sCellToAddModList == 1)) && (nr-rrc.sCellIndex == 2)) && ' \
                  '(nr-rrc.physCellId == 999)) && (nr-rrc.MeasId == {})'.format(meas_id)
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    message_count = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                                 pcap_file_path=pcap_path,
                                                 alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert message_count == 1, "Found other amount (%s) of CA switch messages than expected (1)" % message_count


def confirm_3cc_carrier_aggregation(pcap_path):
    pcap_filter = 'nr-rrc.physCellId == 196 && nr-rrc.physCellId == 190 && nr-rrc.physCellId == 999 && ' \
                  'nr-rrc.sCellIndex == 1 && nr-rrc.sCellIndex ==2'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    message_count = ute_tshark.get_packets_count(packet_filter=pcap_filter,
                                                 pcap_file_path=pcap_path,
                                                 alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert message_count == 1, "found other amount (%s) of 3CC CA messages than expected (1)" % message_count


def find_handover_message_and_assert_no_measurement_reports_after_handover(pcap_path):
    handover_filter = 'nr-rrc.sCellIndex == 1 && nr-rrc.sCellIndex == 2 && nr-rrc.c1 == 0 &&' \
                      'nr-rrc.physCellId == 999 && nr-rrc.physCellId == 190 && nr-rrc.physCellId == 196'
    scell_remove_filter = 'nr-rrc.SCellIndex == 1 && nr-rrc.SCellIndex == 2 && nr-rrc.physCellId == 999'
    pcap_alias = 'f1ap_pcap'
    ute_tshark.setup_tshark(interface='any', alias=pcap_alias)
    handover_message = ute_tshark.read_pcap(packet_filter=handover_filter,
                                            pcap_file_path=pcap_path,
                                            alias=pcap_alias)
    scells_remove_messages = ute_tshark.get_packets_count(packet_filter=scell_remove_filter,
                                                          pcap_file_path=pcap_path,
                                                          alias=pcap_alias)
    measurement_reports = ute_tshark.read_pcap(packet_filter='nr-rrc.measurementReport_element',
                                               pcap_file_path=pcap_path,
                                               alias=pcap_alias)
    ute_tshark.teardown_tshark(alias=pcap_alias)
    assert scells_remove_messages > 0, "no messages with sCells removal after HO found"
    handover_timestamp = find_pcap_messages_timestamps(handover_message)
    meas_reports_timestamps = find_pcap_messages_timestamps(measurement_reports)
    handover_time = datetime.strptime(handover_timestamp[0][:len(handover_timestamp[0]) - 6], time_format)
    for message in meas_reports_timestamps:
        assert datetime.strptime(message[:len(message) - 6], time_format) < handover_time


def tshark_teardown():
    ute_tshark.teardown_tshark(alias='f1ap_pcap')
