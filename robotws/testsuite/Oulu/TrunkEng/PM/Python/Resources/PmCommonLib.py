import re
import gzip
import os
import xml.etree.ElementTree as Etr
import pytz
import math
from dateutil import tz
from robot.libraries.BuiltIn import BuiltIn
from datetime import datetime, timedelta
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.PM.Python.Resources.exceptions import (PMFileDoesntExist, PMFileExist, StateException,
                                                                    PMFileCheckFailed, SnapshotException)
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCheckMeasurements import BaselineMeasurements
from testsuite.Oulu.TrunkEng.Common.Python.Resources.GetValuesFromImsHistory import GetValuesFromImsHistory
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod import FaultingRmod


class PmCommonLib(object):

    def __init__(self):
        """
        PmCommonLib is a collection of common functions PM needs.

        """

        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.baseline_measurements = BaselineMeasurements()
        self.ims_history = GetValuesFromImsHistory()
        self.check_alarms = BuiltIn().get_library_instance("ALARMS")
        self.faulting_rmod = FaultingRmod()

    @staticmethod
    def parse_file(xml_file):
        if not xml_file:
            error("File path is empty. Check the file path.")
            return None
        if '.gz' in xml_file:
            with gzip.open(xml_file, 'rb') as f:
                file_content = f.read()
            if file_content:
                return Etr.XML(file_content)
            else:
                error("File content is empty.")
                return None
        else:
            return Etr.parse(xml_file).getroot()

    @staticmethod
    def match_aomparameterid(name, remarks, transform_dict):
        aomparameterid_pattern = re.compile(r'(.*(aomParameterId|parameterId):\s*(?P<aomParameterId>\w+).*)')
        aomparameterid_match = aomparameterid_pattern.match(remarks)
        if aomparameterid_match:
            transform_dict[name] = aomparameterid_match.group("aomParameterId")
        elif remarks and "aomParameterId" not in remarks:
            transform_dict[name] = remarks
        else:
            transform_dict[name] = "Aom parameter not supported"

    @staticmethod
    def find_name_and_remarks(meas):
        trs_measurements = {
            "NTP_stats": "ntpStatisticsInterval",
            "Loose_Phase_and_Time_Sync_stats": "loosePhaseAndTimeStatisticsInterval",
            "SBTS_Antenna_Line": "mtSBTSAntennaLine",
            "Bridge_Port_Stats": "bridgePortStatisticsInterval",
            "TOP_PhaseSync_Stats": "topPhaseSyncStatisticsInterval",
            "TOP_FreqSync_stats": "topFreqSyncStatisticsInterval",
            "PHB_stats": "ipPerHopBehaviourStatisticsInterval",
            "SCDSCH_stats": "secondLevelSchedulerStatisticsInterval",
            "FSCH_stats": "firstLevelSchedulerStatisticsInterval",
            "S1_X2_TAC_Stats": "s1X2TacStatisticsInterval",
            "TWAMP_Stats": "twampStatisticsInterval",
            "IPSEC_stats": "ipSecStatisticsInterval",
            "IPSEC_SA_stats": "ipSecSaStatisticsInterval",
            "IP_filtering_Stats": "ipFilteringInterval",
            "IPv6_addr_stats": "ipV6AddressStatisticsInterval",
            "SCTP_stats": "sctpStatisticsInterval",
            "TCP_UDP_stats": "tcpUdpStatisticsInterval",
            "IPNO_stats": "ipNodeStatisticsInterval",
            "IPv4_addr_stats": "ipV4AddressStatisticsInterval",
            "IPIF_stats": "ipInterfaceStatisticsInterval",
            "VLAN_stats": "vlanStatisticsInterval",
            "ETHLK_stats": "ethernetLinkInterval",
            "ETHIF_stats": "ethernetInterfaceStatisticsInterval",
            "PDH_Interface_stats": "pdhInterfaceStatisticsInterval",
            "IPv6_Interface_Stats": "ipV6InterfaceStatisticsInterval",
            "IPv4_Interface_Stats": "ipV4InterfaceStatisticsInterval",
        }
        name = meas.find(r"Name").text
        remarks = meas.find(r"Remarks").text
        if (not remarks or "aomParameterId" not in remarks) and name in trs_measurements:
            remarks = trs_measurements[name]
        return name, remarks

    def form_transform_dict(self):
        transform_dict = {}
        measurements = self.baseline_measurements.baseline.findall(r".//Measurement")
        for measurement in measurements:
            name, remarks = self.find_name_and_remarks(measurement)
            if not name or not remarks:
                error("Check baseline: Name ({}) or remarks ({}) is missing".format(name, remarks))
                continue
            self.match_aomparameterid(name, remarks, transform_dict)
        return transform_dict

    def find_baseline_measurement_names(self, reversed_dict=False):
        transform_dict = self.form_transform_dict()
        if reversed_dict:
            transform_dict = {aomparameterid: name for name, aomparameterid in transform_dict.items()}
            self.logger.debug(f"Reversed transform dict: {transform_dict}")
            return transform_dict
        self.logger.debug(f"Transform dict: {transform_dict}")
        return transform_dict

    @staticmethod
    def strip_min(value):
        return value.strip("min")

    def _collect_file_names_from_bts(self, filetype):
        command = "ls /ram/ |grep {}.BTS".format(filetype)
        if BuiltIn().get_variable_value("${RFS}") and BuiltIn().get_variable_value("${MASTER}") == "Other":
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            output = self.ssh.connection_command_and_output(command, ip=remote_mplane_ip)
        else:
            output = self.ssh.connection_command_and_output(command)
        all_found_filenames = [item.rstrip() for item in output.splitlines() if "raw" not in item]
        self.logger.debug("All found filenames: {}".format(all_found_filenames))
        return all_found_filenames

    def utc_interval(self, interval, next_interval=True, local_time=False):
        time = datetime.now(pytz.utc)
        if local_time:
            time = time.astimezone(pytz.timezone("Europe/Helsinki"))
        expiration_dict = {
            5: [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55],
            15: [0, 15, 30, 45],
            30: [0, 30],
            60: [0],
            360: [0, 6, 12, 18],
            720: [0, 12],
            1440: [0]
        }
        if interval in [5, 15, 30, 60]:
            start_time = datetime(time.year, time.month, time.day, time.hour, time.minute, 0, tzinfo=time.tzinfo)
            if time.minute in expiration_dict[interval]:
                start_time = start_time + timedelta(minutes=1)
            while start_time.minute not in expiration_dict[interval]:
                if next_interval:
                    start_time = start_time + timedelta(minutes=1)
                else:
                    start_time = start_time - timedelta(minutes=1)
        else:
            start_time = datetime(time.year, time.month, time.day, time.hour, 0, 0, tzinfo=time.tzinfo)
            if time.hour in expiration_dict[interval] and time.minute != 0:
                start_time = start_time + timedelta(hours=1)
            while start_time.hour not in expiration_dict[interval]:
                if next_interval:
                    start_time = start_time + timedelta(hours=1)
                else:
                    start_time = start_time - timedelta(hours=1)
        self.logger.debug(f"Start time: {start_time}")
        return start_time

    def wait_for_interval(self, interval, next_interval, delta, wait_after, only_return):
        wait_until_time = self.utc_interval(interval, next_interval=next_interval)
        if delta:
            wait_until_time = wait_until_time + timedelta(seconds=delta)
            info(f"Wait until (utc-time) {wait_until_time}")
        else:
            info("Wait for {} ({}min) interval".format("next" if next_interval else "previous", interval))
        self.logger.debug("Wait until (utc): {}".format(wait_until_time))
        if not only_return:
            utc_time = datetime.now(pytz.utc)
            while utc_time < wait_until_time:
                BuiltIn().sleep("2s")
                utc_time = datetime.now(pytz.utc)
            if wait_after != "0s":
                info(f"Wait {wait_after} for file to be created")
                BuiltIn().sleep(wait_after)
            info("Waiting done")
        return wait_until_time

    def latest_file(self, filetype, interval=15, next_interval=False, file_extension="gz"):
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        latest_interval = self.utc_interval(interval, next_interval)
        formatted_utc = latest_interval.strftime("%Y%m%d.%H%M%S")
        return f"{filetype}.BTS-{bts_id}.{formatted_utc}.ANY.xml.{file_extension}"

    def check_latest_file_existence(self, filetype, exist):
        exist_str = "exist" if exist else "doesn't exist"
        info("Check latest {}-file {} on BTS".format(filetype, exist_str))
        all_found_filenames = self._collect_file_names_from_bts(filetype)
        correct_latest_file = self.latest_file(filetype)
        if exist and correct_latest_file in all_found_filenames:
            info("Latest {}-file was found on BTS".format(correct_latest_file))
        elif not exist and correct_latest_file not in all_found_filenames:
            info("Latest {}-file was not found on BTS".format(correct_latest_file))
        else:
            exist_str2 = "was not" if exist else "was"
            error("Latest {}-file {} found from BTS".format(correct_latest_file, exist_str2))
            raise PMFileDoesntExist if exist else PMFileExist

    def check_ntp_availability(self, status):
        ntp_ok = False
        info("Checking that NTP is {}".format(status))
        ntp_distname = "/MRBTS-1/RAT-1/RUNTIME_VIEW-{bts_side}/MRBTS_R-{bts_side}/MNL_CONF_M-1/MNLENT_CONF_M-1/" \
                       "SYNC_CONF_M-1/CLOCK_CONF_M-1/NTP_CONF_M-1/NTP_R-1".format(bts_side=self.bts.side)
        timeout = 0
        current_state = ""
        while not ntp_ok and timeout < 600:
            BuiltIn().sleep("5s")
            timeout += 5
            ntp_object = self.admin.get_parameters(ntp_distname)
            current_state = str(ntp_object["ntpServerStatusList"][0]["ntpStatus"]).lower()
            if current_state == status.lower():
                info("NTP is {}".format(status))
                ntp_ok = True
        if not ntp_ok:
            error("NTP was {} instead of {}".format(current_state, status))
            raise StateException("NTP was {} instead of {}".format(current_state, status))

    def download_latest_file(self, filetype="PM", interval=15):
        latest_file = self.latest_file(filetype, interval)
        path_to_file = "/ram/{}".format(latest_file)
        pm_files = os.path.join(self.logger.log_dir, "PM_files")
        if not os.path.exists(pm_files):
            os.mkdir(pm_files)
        local_path = os.path.join(pm_files, latest_file)
        if BuiltIn().get_variable_value("${RFS}") and BuiltIn().get_variable_value("${MASTER}") == "Other":
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            self.ssh.connection_and_download_file(path_to_file, local_path, ip=remote_mplane_ip)
        else:
            self.ssh.connection_and_download_file(path_to_file, local_path)
        return local_path

    def check_latest_file_name(self, file_name, filetype, interval=15, next_interval=False, file_extension="gz",
                               bool_return=False):
        latest_file = self.latest_file(filetype, interval, next_interval, file_extension)
        if latest_file != file_name:
            error(f"Latest {filetype} file is {latest_file} instead of {file_name}")
            if bool_return:
                return False
            raise PMFileCheckFailed(f"Latest {filetype} file is {latest_file} instead of {file_name}")
        info(f"Latest {filetype} file ({file_name}) is correctly named")
        return True

    def get_samples_for_cell(self, selected_cell, cell_locked_usage, start_point=None):
        ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        if not os.path.exists(ims_file_path):
            self.admin.collect_infomodel_log_from_current_session(ims_file_path, timeout=900, connection="log_admin")
        disabled_state = {"operationalState": "disabled"}
        enabled_state = {"operationalState": "enabled"}
        blocked_state = {"administrativeState": "locked"} if cell_locked_usage else {"blockingState": "Blocked"}
        unblocked_state = {"administrativeState": "unlocked"} if cell_locked_usage else {"blockingState": "Unblocked"}
        cell_operational_dict = {selected_cell: [disabled_state, enabled_state]}
        cell_blocked_dict = {selected_cell: [blocked_state, unblocked_state]}
        unavailable_samples = disabled_samples = unplanned_samples = 0
        # Two checks because uncertainty on which order these happen and method needs correct chronological order
        if (self.ims_history.check_multiple_states_from_history(ims_file_path, cell_operational_dict, collect_all=True)
                and self.ims_history.check_multiple_states_from_history(ims_file_path, cell_blocked_dict,
                                                                        collect_all=True)):
            cell_disabled = self.ims_history.get_timestamp_of_element_from_dict(selected_cell, "operationalState",
                                                                                "disabled", start_point=start_point)
            cell_enabled = self.ims_history.get_timestamp_of_element_from_dict(selected_cell, "operationalState",
                                                                               "enabled", start_point=cell_disabled)
            cell_blocked = self.ims_history.get_timestamp_of_element_from_dict(selected_cell,
                                                                               "administrativeState" if
                                                                               cell_locked_usage else "blockingState",
                                                                               "locked" if cell_locked_usage
                                                                               else "Blocked", start_point=start_point)
            cell_unblocked = self.ims_history.get_timestamp_of_element_from_dict(selected_cell,
                                                                                 "administrativeState" if
                                                                                 cell_locked_usage else "blockingState",
                                                                                 "unlocked" if cell_locked_usage
                                                                                 else "Unblocked",
                                                                                 start_point=start_point)
            if not cell_locked_usage:
                # When unblocking cell, it doesn't have 'unblocking' status
                # causing the calculations to be 0.5s off, this is fixed by rounding up instead of down.
                unavailable_samples = math.ceil(float((cell_unblocked - cell_blocked).total_seconds()))
            else:
                unavailable_samples = round(float((cell_unblocked - cell_blocked).total_seconds()))
            disabled_samples = round(float((cell_enabled - cell_disabled).total_seconds()))
            unplanned_samples = round(float((cell_enabled - cell_unblocked).total_seconds()))
        return unavailable_samples, disabled_samples, unplanned_samples

    def calculate_m8020x_counters(self, selected_cell, rat, cell_locked):
        m8020x_counters = {}
        previous_interval_start_time = self.utc_interval(15, next_interval=False, local_time=True)
        previous_interval_start_time = previous_interval_start_time.astimezone(pytz.UTC)
        self.logger.debug(f"Previous interval start time: {previous_interval_start_time}")
        selected_cell = selected_cell if selected_cell.isdigit() else selected_cell[7:]
        for cell_name, cell_info in self.bts.cells.items():
            if rat in cell_name and selected_cell == cell_name[7:] or "All cells" in cell_name:
                unavailable_samples, disabled_samples, unplanned_samples = self.get_samples_for_cell(
                    cell_info["id"]["internal"], cell_locked, start_point=previous_interval_start_time)
                m8020c0 = 1
                m8020c1 = 1
                m8020c2 = 0
                m8020c3 = 900 - disabled_samples  # 15min
                m8020c4 = unavailable_samples
                m8020c5 = unplanned_samples if unplanned_samples >= 30 else 0
                m8020c6 = 900  # 15min
            else:
                m8020c0 = 0
                m8020c1 = 0
                m8020c2 = 0
                m8020c3 = 900  # 15min
                m8020c4 = 0
                m8020c5 = 0
                m8020c6 = 900  # 15min
            m8020x_counters[str(cell_info["globalCellId"])] = (m8020c0, m8020c1, m8020c2, m8020c3, m8020c4, m8020c5,
                                                               m8020c6)
        self.logger.debug(f"M8020X counters: {m8020x_counters}")
        return m8020x_counters

    def get_mme_specific_samples(self, only_unavailable, start_point, ims_file_path):
        s1_link_available = s1_link_unavailable = None
        s1_link_unavailable_dict = {"s1LinkStatus": "unavailable"}
        s1_link_status_list = [s1_link_unavailable_dict]
        if not only_unavailable:
            s1_link_available_dict = {"s1LinkStatus": "available"}
            s1_link_status_list.append(s1_link_available_dict)
        lnmme_dn = self.admin.get_parameters_for_all("LNMME")[0]['id']
        mme_s1linkstatus_dict = {lnmme_dn: s1_link_status_list}
        if self.ims_history.check_multiple_states_from_history(ims_file_path, mme_s1linkstatus_dict, collect_all=True):
            if not only_unavailable:
                s1_link_available = self.ims_history.get_timestamp_of_element_from_dict(lnmme_dn, "s1LinkStatus",
                                                                                        "available",
                                                                                        start_point=start_point)
            s1_link_unavailable = self.ims_history.get_timestamp_of_element_from_dict(lnmme_dn, "s1LinkStatus",
                                                                                      "unavailable",
                                                                                      start_point=start_point)
        return s1_link_unavailable, s1_link_available

    def get_disabled_samples_for_mme(self, cell_dn, occasion, previous_interval):
        ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        self.admin.collect_infomodel_log_from_current_session(ims_file_path, timeout=900, connection="log_admin")
        if occasion == "1":
            s1_link_unavailable, s1_link_available = self.get_mme_specific_samples(False, previous_interval,
                                                                                   ims_file_path)
            if s1_link_available and s1_link_unavailable:
                return round(float((s1_link_available - s1_link_unavailable).total_seconds()))
        elif occasion == "2":
            s1_link_unavailable, _ = self.get_mme_specific_samples(True, previous_interval, ims_file_path)
            info(f"Timestamp for previous interval: {previous_interval}")
            return 900 - round(float((s1_link_unavailable - previous_interval).total_seconds()))
        elif occasion == "3":
            cell_enabled_state = {cell_dn: [{"operationalState": "enabled"}]}
            cell_enabled = 0
            if self.ims_history.check_multiple_states_from_history(ims_file_path, cell_enabled_state, collect_all=True):
                cell_enabled = self.ims_history.get_timestamp_of_element_from_dict(cell_dn, "operationalState",
                                                                                   "enabled",
                                                                                   start_point=previous_interval)
            return round(float((cell_enabled - previous_interval).total_seconds()))
        error("Can't calculate disabled samples for MME. Using default value 0")
        return 0

    def calculate_m8020x_mme_counters(self, occasion):
        m8020x_counters = {}
        # Previous interval start time is 15min before the current interval start time. Local time need to be used to
        # convert to naive-utc later
        previous_interval_start_time = self.utc_interval(15, next_interval=False, local_time=True) - timedelta(
            minutes=15)
        # ims-files times are naive, convert to naive-utc. This is needed for comparison. Timedelta changes
        previous_interval_start_time = previous_interval_start_time.astimezone(pytz.UTC)
        for cell_name, cell_info in self.bts.cells.items():
            disabled_samples = self.get_disabled_samples_for_mme(cell_info["id"]["internal"], occasion,
                                                                 previous_interval_start_time)
            m8020c0 = 1 if occasion in ("1", "3") else 0
            m8020c1 = 0
            m8020c2 = 1 if occasion in ("1", "2") else 0
            m8020c3 = 900 - disabled_samples
            m8020c4 = 0
            m8020c5 = disabled_samples if disabled_samples >= 30 else 0
            m8020c6 = 900
            m8020x_counters[str(cell_info["globalCellId"])] = (m8020c0, m8020c1, m8020c2, m8020c3, m8020c4, m8020c5,
                                                               m8020c6)
        return m8020x_counters

    def get_shutting_down_cell(self, selected_cell, cell_dn):
        self.logger.debug(f"Cell DN for shutting down: {cell_dn}")
        ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        cell_shutting_down_dict = {cell_dn: {"administrativeState": "shutting down"}}
        if self.ims_history.check_if_in_history(ims_file_path, cell_shutting_down_dict):
            cell_shutting_down = self.ims_history.get_timestamp_of_element_from_dict(cell_dn, "administrativeState",
                                                                                     "shutting down")
            cell_locked = self.ims_history.get_timestamp_of_element_from_dict(cell_dn, "administrativeState", "locked")
            cell_shutting_down = cell_shutting_down[0] if isinstance(cell_shutting_down, list) else cell_shutting_down
            cell_locked = cell_locked[0] if isinstance(cell_locked, list) else cell_locked
            return cell_shutting_down, cell_locked
        else:
            error(f"Shutting down state was not found for cell-{selected_cell}. Can't calculate GCS time.")
            return None, None

    def collect_snapshot(self, file_name="", remove_snapshot=False):
        log_file = os.path.join(str(self.logger.log_dir),
                                f"{file_name}_Snapshot_{datetime.now().strftime('%Y%m%d_%H%M%S')}.zip")
        self.collect_logs.collect_snapshot(snapshot_path=log_file)
        if log_file:
            if remove_snapshot:
                info(f"Removing snapshot {log_file}")
                os.remove(log_file)
                info(f"Snapshot {log_file} removed")
                return
            else:
                return log_file
        error("Couldn't fetch snapshot")
        raise SnapshotException("Couldn't fetch snapshot")

    def check_pm_file_creation_time(self, max_time):
        info("Check PM file creation time")
        latest_file = self.latest_file("PM")
        cmd = f"stat /ram/{latest_file} | grep 'Modify'"
        output = self.ssh.connection_command_and_output(cmd)
        # Modify: 2024-04-25 11:45:24.952280231 +0300
        self.logger.debug(f"Output from grepping timestamp: {output}")
        if output and "No such file" not in output:
            datetime_str, tz_str = output.split("Modify: ")[1].rsplit(" ", 1)
            # 2024-04-25 11:45:24.952280231 has too many decimals for datetime. Remove last 3 decimals
            pm_file_time = datetime.strptime(datetime_str[:26], "%Y-%m-%d %H:%M:%S.%f")
            # E.g. +0300 -> Etc/GMT-3
            timezone = tz.gettz(f"Etc/GMT{int(tz_str[:3]) * -1}")
            creation_time = pm_file_time.replace(tzinfo=timezone).astimezone(pytz.UTC)
            previous_interval = self.utc_interval(15, next_interval=False, local_time=True).astimezone(pytz.UTC)
            self.logger.debug(f"PM file creation time: {creation_time}, Previous interval start time: "
                              f"{previous_interval}")
            time_diff = (creation_time - previous_interval).total_seconds()
            if 0 < float(time_diff) < max_time:
                info(f"PM file creation time is {time_diff} seconds for {latest_file}")
            else:
                error(f"PM file creation time is {time_diff} seconds. It should be less than {max_time} seconds")
                raise PMFileCheckFailed(f"PM file creation time is {time_diff} seconds. It should be less than "
                                        f"{max_time} seconds")
        else:
            error("Couldn't get PM file creation time")
            raise PMFileCheckFailed("Couldn't get PM file creation time")

    def check_cells_and_clear_fault_1907(self, rmod):
        """
        Check if there is more than one cell, if there is only one cell the fault is cleared with an
        autonomous reset. In case of multiple cells, the fault is cancelled.

        :param rmod: RMOD name, for example "r1"
        """
        rmod_object = self.bts.get_rmod_object_from_user_given_values(rmod)
        if len(self.bts.get_cells_of_radio(rmod_object.name)) > 1:
            BuiltIn().sleep("150s")
            self.check_alarms.check_expected_alarms()
            self.faulting_rmod.raise_fault_to_rmod("1907",
                                                   self.bts.get_rmod_object_from_user_given_values(rmod),
                                                   "TX1", True)
        else:
            self.check_alarms.check_expected_alarms()

    def add_expected_alarm_based_on_number_of_cells(self, rmod):
        """
        Add expected alarm based on number of cells.

        :param rmod: RMOD name, for example "r1"
        """
        rmod_object = self.bts.get_rmod_object_from_user_given_values(rmod)
        number_of_cells = len(self.bts.get_cells_of_radio(rmod_object.name))
        if number_of_cells == 1:
            info(f"There is only 1 cell, Radio autonomous reset alarm is expected")
            self.check_alarms.add_expected_alarm(alarm_id=7101, fault_id=1907,
                                                 fault_name="Radio autonomous reset as recovery action",
                                                 unit_path=rmod_object.unit_path, hw_path=rmod_object.hw_path)
        else:
            info(f"There is more than 1 cell, TX out of order alarm is expected")
            self.check_alarms.add_expected_alarm(alarm_id=7116, fault_id=1907,
                                                 fault_name="TX out of order",
                                                 unit_path=rmod_object.unit_path, hw_path=rmod_object.hw_path)

    def calculate_1907_m8020x_counters(self, selected_cell, rat):
        """
        Calculate M8020X counters in 1907 resource failure test case.

        :param int selected_cell: Counters are checked from the cell with this number.
        :param str rat: Used RAT, can be LN or NR

        :return dict: Dictionary containing cells as keys and counter tuple as values
        """
        m8020x_counters = {}
        for cell_name, cell_info in self.bts.cells.items():
            if rat in cell_name and selected_cell == cell_name[7:]:
                unavailable_samples = self.get_1907_specific_samples_for_cell(
                    cell_info["id"]["internal"])
                m8020c0 = 1
                m8020c1 = 0
                m8020c2 = 1
                m8020c3 = 900 - unavailable_samples  # 15min
                m8020c4 = 0
                m8020c5 = unavailable_samples if unavailable_samples >= 30 else 0
                m8020c6 = 900  # 15min
            else:
                m8020c0 = 0
                m8020c1 = 0
                m8020c2 = 0
                m8020c3 = 900  # 15min
                m8020c4 = 0
                m8020c5 = 0
                m8020c6 = 900  # 15min
            m8020x_counters[str(cell_info["globalCellId"])] = (m8020c0, m8020c1, m8020c2, m8020c3, m8020c4, m8020c5,
                                                               m8020c6)
        self.logger.debug(f"M8020X counters: {m8020x_counters}")
        return m8020x_counters

    def get_1907_specific_samples_for_cell(self, selected_cell):
        """
        Get unavailable samples for 1907 resource failure test case.

        :param str selected_cell: Selected cell

        :return int: Unavailable samples
        """
        ims_file_path = os.path.join(self.logger.log_dir, "ims_history.ims2")
        if not os.path.exists(ims_file_path):
            self.admin.collect_infomodel_log_from_current_session(ims_file_path, timeout=900, connection="log_admin")
        disabled_state = {"operationalState": "disabled"}
        enabled_state = {"operationalState": "enabled"}
        cell_operational_dict = {selected_cell: [disabled_state, enabled_state]}
        disabled_samples = 0
        if self.ims_history.check_multiple_states_from_history(ims_file_path, cell_operational_dict):
            cell_disabled = self.ims_history.get_timestamp_of_element_from_dict(selected_cell, "operationalState",
                                                                                "disabled")
            cell_enabled = self.ims_history.get_timestamp_of_element_from_dict(selected_cell, "operationalState",
                                                                               "enabled")
            disabled_samples = round(float((cell_enabled - cell_disabled).total_seconds()))
        return disabled_samples
