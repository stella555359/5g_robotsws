"""
Provides functions that have logic for doing CB006939 tests, based on 5GC002536
"""
import logging
import os
import robot.api.logger as logger
import subprocess
from time import sleep
from datetime import datetime
from event_searching import ISO_DATE_FORMAT, ISO_TIME_FORMAT, BtsLogHandler, SyslogSearcher
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as GnbCell
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning as GnbScf
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog


COMPONENT_NAME_COLUMN = 7


def remove_from_list(list_obj, element_to_remove):
    """
    helper function to remove from list and ignore ValueError if element is not in list
    """
    try:
        list_obj.remove(element_to_remove)
    except ValueError as e:
        logging.info(e.message)


class CB006939_DA:
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self.bts_log_handler = BtsLogHandler()

    def check_syslog_start_stop_latency(self,
                                        mrbts_id,
                                        start_stop_latency):
        """
        Checks if syslog start stop latency is correct, prepares environment and checks
        if start stop latency target is met
        :param mrbts_id: ID of the MRBTS
        :param start_stop_latency: Target latency for syslog start and stop to achieve
        :param server_ip_addr: Ip address of server that collects syslog
        :param server_port_no: Port number of syslog collecting service
        :return: None
        :raise AssertionError when target time will be not met
        """
        logger.console("About to update syslog server parameters in TRBLCADM-1")
        remote_syslog_config = [{
            'remoteSyslogDSCP': '0',
            'remoteSyslogFormat': 'RFC5424',
            'remoteSyslogServerIPaddress': '192.168.255.126',
            'remoteSyslogServerPortNo': '51000',
            'remoteSyslogTransmitDuration': '240',
            'remoteSyslogTransportProtocol': 'UDP',
        }]
        trblcadm_object_path = 'MRBTS-{}/MNL-1/MNLENT-1/TRBLCADM-1'.format(mrbts_id)
        gnb_scf = GnbScf()
        gnb_scf.perform_configuration_parameter_recommissioning(dist_name=trblcadm_object_path,
                                                                parameter='remoteSyslogConfig',
                                                                operation='update',
                                                                value=remote_syslog_config,
                                                                skip_parameter_relation_errors=True,
                                                                timeout=12000)

        gnb_scf.perform_configuration_parameter_recommissioning(dist_name=trblcadm_object_path,
                                                                parameter='actRemoteSyslogTransmission',
                                                                operation='update',
                                                                value='false',
                                                                skip_parameter_relation_errors=True)
        self._check_syslog_state_change_latency(gnb_scf, trblcadm_object_path, 'start', start_stop_latency)
        self._check_syslog_state_change_latency(gnb_scf, trblcadm_object_path, 'stop', start_stop_latency)

    def check_data_freeze_duration(self, request_freeze_latency, start_stop_freeze_latency):
        """
        Check if log freeze latency target is met
        :param request_freeze_latency: Latency between snapshot collection request and end of the freezing operations
        :param start_stop_freeze_latency: Latency between freeze start and freeze stop for each component
        :return:
        """
        request_freeze_latency = float(request_freeze_latency)
        start_stop_freeze_latency = float(start_stop_freeze_latency)
        self.bts_log_handler.start_collecting_btslog()
        sleep(60)
        GnbLog().collect_snapshot()
        sleep(150)
        self._check_syslog_for_freeze_duration(request_freeze_latency, start_stop_freeze_latency)
        self.bts_log_handler.stop_collecting_btslog()

    def _check_syslog_state_change_latency(self, gnb_scf, trblcadm_object_path, type_of_event, start_stop_latency):
        """
        Checks for latency in syslog, if exceeded then raise AssertionError
        :param gnb_scf: GnbScf object instance
        :param trblcadm_object_path: Path to TRBLCADM-1 object in gNB SCF
        :param type_of_event: Type of syslog event that is supported, string 'start' or 'stop' is supported
        :param start_stop_latency: Expected max syslog latency as float number
        :return: None
        :raise AssertionError when syslog latency is exceeded
        :raise ValueError when there is a missing data
        """
        time_start_msg = 'finishActivation'
        if type_of_event == 'start':
            time_end_msg = 'update usageState to 2'
            act_remote_syslog_val = 'true'
        elif type_of_event == 'stop':
            time_end_msg = 'update usageState to 0'
            act_remote_syslog_val = 'false'
        else:
            raise ValueError('Not supported type of event in _check_syslog_state_change_latency')

        messages_to_find = [time_start_msg, time_end_msg]
        syslog_searcher = SyslogSearcher(messages_to_find)

        self.bts_log_handler.start_collecting_btslog()
        gnb_scf.perform_configuration_parameter_recommissioning(trblcadm_object_path,
                                                                'actRemoteSyslogTransmission',
                                                                'update',
                                                                act_remote_syslog_val,
                                                                skip_parameter_relation_errors=True)
        sleep(float(start_stop_latency)*2)
        syslog_searcher.search_for_messages_in_btslog()
        latency = syslog_searcher.calculate_duration_between_msgs(0, 1)
        logger.console('Syslog latency for {} operation is {} max latency {}'.format(
            type_of_event, latency, start_stop_latency))
        if latency > float(start_stop_latency):
            raise AssertionError('Syslog latency for operation {} is exceeded, measured latency: {} '
                                 'expected max latency: {}'.format(type_of_event, latency, start_stop_latency))
        self.bts_log_handler.stop_collecting_btslog()

    def _check_syslog_for_freeze_duration(self, request_freeze_latency, start_stop_freeze_latency):
        """
        Checks collected syslog for duration of
        :param request_freeze_latency:
        :param start_stop_freeze_latency:
        :return:
        """
        snapshot_start_msg = 'startSnapShot'
        freeze_start_msg = 'Starting to freeze files'
        freeze_end_msg = 'Freeze ended'
        start_msg_elements = self._get_component_names(freeze_start_msg)
        end_msg_elements = self._get_component_names(freeze_end_msg)

        diff = set(start_msg_elements).symmetric_difference(set(end_msg_elements))
        if diff:
            logger.warn("Start/end components differ with {}, since snapshot is collected omitting".format(diff))
            for component in diff:
                remove_from_list(start_msg_elements, component)
                remove_from_list(end_msg_elements, component)

        if len(diff) > 1:
            logger.console("Set difference {}".format(
                set(end_msg_elements).symmetric_difference(set(start_msg_elements))))
            raise AssertionError("More than one component freeze time is missing, investigate")

        element_list = end_msg_elements
        messages_to_find = [snapshot_start_msg]
        el_indexes = self._create_freeze_message_pairs_to_find(freeze_start_msg=freeze_start_msg,
                                                               freeze_end_msg=freeze_end_msg,
                                                               element_list=element_list,
                                                               messages_to_find=messages_to_find)
        syslog_searcher = SyslogSearcher(messages_to_find, use_regex=True)
        syslog_searcher.search_for_messages_in_btslog()

        self._check_request_freeze_latency_time(target_request_freeze_latency=request_freeze_latency,
                                                el_indexes=el_indexes,
                                                syslog_searcher=syslog_searcher)
        self._check_start_stop_freeze_latency_time(target_start_stop_latency=start_stop_freeze_latency,
                                                   el_indexes=el_indexes,
                                                   syslog_searcher=syslog_searcher)

    def _get_component_names(self, msg_to_use):
        """
        Gets component names form SYSLOG
        :param msg_to_use:
        :return:
        """
        found_lines = self.bts_log_handler.find_all_message_occurrences(msg_to_use)
        elements_list = [line.split(" ")[COMPONENT_NAME_COLUMN] for line in found_lines]
        logger.debug("For msg {} found following elements: {}".format(msg_to_use, elements_list))
        return elements_list

    def _create_freeze_message_pairs_to_find(self, freeze_start_msg, freeze_end_msg, element_list, messages_to_find):
        """
        Creates messages pairs to find in SYSLOG
        :param freeze_start_msg: Freeze start message that should be found
        :param freeze_end_msg: Freeze end message that should bbu found
        :param element_list: List of elements in SYSLOG for which freeze messages should occur
        :return:
        """
        elements_indexes = {}
        msg_ind = len(messages_to_find)
        for element in element_list:
            start_msg_re = element + ".*" + freeze_start_msg
            end_msg_re = element + ".*" + freeze_end_msg
            messages_to_find.append(start_msg_re)
            messages_to_find.append(end_msg_re)
            elements_indexes[element] = {
                'start_ind': msg_ind,
                'stop_ind': msg_ind + 1
            }
            msg_ind += 2
        return elements_indexes

    def _check_request_freeze_latency_time(self, target_request_freeze_latency, el_indexes, syslog_searcher):
        """
        Checks if request freeze latency time is correct
        :param target_request_freeze_latency: Request freeze latency target that should be achieved
        :param el_indexes: Indexes of elements in message list
        :param syslog_searcher: Instance of SyslogSearcher, that has already found particular events in
        syslog and contains
        timing for this actions
        :return: None
        :raise AssertionError when given latency target is not achieved
        """
        for element, el_data in el_indexes.items():
            start_msg_ind = el_data['start_ind']
            measured_request_freeze_latency = syslog_searcher.calculate_duration_between_msgs(0, start_msg_ind)
            logger.console('Measured request freeze latency for element {} between '
                           'was {}'.format(element, measured_request_freeze_latency))
            if measured_request_freeze_latency > target_request_freeze_latency:
                raise AssertionError("Target latency for freeze duration was exceeded")

    def _check_start_stop_freeze_latency_time(self, target_start_stop_latency, el_indexes, syslog_searcher):
        """
        Checks if start stop freeze latency is correct
        :param target_start_stop_latency: Request freeze latency target that should be achieved
        :param el_indexes: Indexes of elements in message list
        :param syslog_searcher: Instance of SyslogSearcher, that has already found particular events in syslog
        and contains
        timing for this actions
        :return: None
        :raise AssertionError when given latency target is not achieved
        """
        for element, el_data in el_indexes.items():
            measured_start_stop_freeze_latency = syslog_searcher.calculate_duration_between_msgs(
                el_data['start_ind'], el_data['stop_ind'])
            logger.console("measured_start_stop_freeze_latency for element {} was {}".format(
                element, measured_start_stop_freeze_latency))
            if measured_start_stop_freeze_latency > target_start_stop_latency:
                logger.error("measured_start_stop_freeze_latency {} target_start_stop_latency {}".format(
                    measured_start_stop_freeze_latency, target_start_stop_latency))
                raise AssertionError("Target latency for start stop freeze duration was exceeded")

    def check_if_file_exists(self, file):
        """
        :param file: path to file
        :return: bool
        """
        return os.path.isfile(file)

    def get_snapshot_preparation_time(self, snapshot_dir):
        """
        Calculates snapshot preparation time by analyzing snapshot metadata
        :param snapshot_dir:
        :return:
        """
        sr = SnapshotMetaDataReader(snapshot_dir)
        sr.remove_unpacked_snapshot()
        return sr.summary_prepare_duration

    def get_first_cell_id(self):
        """
        :return: first configured cell id
        """
        cells = GnbCell()._get_all_cells_id()
        return cells[0]

    def compare_duration_with_threshold(self, duration, size, expected_big, expected_small, threshold):
        """
        Compares snapshot duration times with expected thresholds
        :param duration: snapshot preparation time
        :param size: snapshot size in bytes
        :param expected_big: maximum expected duration for big snapshot
        :param expected_small: maximum expected duration for small snapshot
        :param threshold: if snapshot size exceeds this value it is considered big, else small
        :return: Nnne
        """
        if float(size) > float(threshold):
            assert float(duration) < float(expected_big), "Big size snapshot preparation time: {}s exceeded " \
                                                          "expected: {}s".format(duration, expected_big)
        else:
            assert float(duration) < float(expected_small), "Small size snapshot preparation time: {}s exceeded " \
                                                            "expected: {}s".format(duration, expected_small)


class SnapshotMetaDataReader:
    def __init__(self, snapshot_dir=None, metadata_dir=None):
        self._snapshot_dir = snapshot_dir
        if snapshot_dir:
            output_dir = self._unzip_snapshot(self._snapshot_dir)
            self._file_name = self._find_metadata_file(output_dir)
        elif metadata_dir:
            self._file_name = metadata_dir
        else:
            raise ValueError("Wrong arguments passed for SnapshotReader")

        self._lines = []
        self._read()

    def _read(self):
        """
        Reads snapshot metadata into a variable
        :return:
        """
        with open(self._file_name, mode='r') as f:
            self._lines = f.readlines()

    @property
    def overall_time(self):
        """
        :return: overall snapshot preparation and transfer time in seconds
        """
        start_timestamp = [line for line in self._lines if 'Start Time' in line][0].split(' : ')[1].strip()
        end_timestamp = [line for line in self._lines if 'End Time' in line][0].split(' : ')[1].strip()
        return (datetime.strptime(end_timestamp, ISO_DATE_FORMAT) -
                datetime.strptime(start_timestamp, ISO_DATE_FORMAT)).total_seconds()

    def _get_lines_with_timestamps(self):
        """
        :return: lines from meta data table containing file prep and transfer durations
        """
        indexes = []
        start_found = False
        for line_index, line in enumerate(self._lines):
            if '-------' in line:
                indexes.append(line_index)
                start_found = True
            elif '______' in line and start_found:
                indexes.append(line_index)
                break
        return self._lines[indexes[0] + 1:indexes[1]]

    @property
    def summary_prepare_duration(self):
        """
        :return: difference between first file preparation start timestamp and last file preparation end timestamp (s)
        """
        prepare_starts = []
        prepare_ends = []
        for line in self._get_lines_with_timestamps():
            line = line.split('  |  ')
            if line[2].strip() != '--':
                prepare_starts.append(datetime.strptime(line[2].strip(), ISO_TIME_FORMAT))
            if line[3].strip() != '--':
                prepare_ends.append(datetime.strptime(line[3].strip(), ISO_TIME_FORMAT))
        return (max(prepare_ends) - min(prepare_starts)).total_seconds()

    @property
    def extra_transfer_duration(self):
        """
        :return: difference between last file preparation ends and last file transfer end (s)
        """
        prepare_starts = []
        prepare_ends = []
        for line in self._get_lines_with_timestamps():
            line = line.split('  |  ')
            if line[3].strip() != '--':
                prepare_starts.append(datetime.strptime(line[3].strip(), ISO_TIME_FORMAT))
            if line[6].strip() != '--':
                prepare_ends.append(datetime.strptime(line[6].strip(), ISO_TIME_FORMAT))
        return (max(prepare_ends) - max(prepare_starts)).total_seconds()

    def _unzip_snapshot(self, snapshot_path, output_dir=None):
        """
        :param snapshot_path: path to snapshot .zip file
        :param output_dir: optional, dir where snapshot will be unzipped
        :return: output dir for upacked snapshot
        """
        if output_dir is None:
            output_dir = snapshot_path.rstrip('.zip')
        cmd = ['unzip', snapshot_path, '-d', output_dir]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        proc.communicate()
        print('Unpacked snapshot to {}'.format(output_dir))
        return output_dir

    def _find_metadata_file(self, unpacked_snapshot_dir):
        """
        :param unpacked_snapshot_dir:
        :return: path to metadata file in unpacked snapshot
        """
        cmd = ['ls', unpacked_snapshot_dir]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, err = proc.communicate()
        output = output.decode('ascii')
        metadata_file_name = [filename for filename in output.split() if 'metadata.txt' in filename][0]
        return unpacked_snapshot_dir + '/' + metadata_file_name

    def remove_unpacked_snapshot(self):
        """

        :return:
        """
        cmd = ['rm', '-rf', '/'.join(self._file_name.split('/')[:-1])]
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        proc.communicate()
