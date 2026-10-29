import re
import pytz
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from robot.libraries.BuiltIn import BuiltIn


intervals_15min = [
    "LTE_MAC",
    "LTE_Sales_Item_Monitoring",
    "LTE_IP_Data_Traffic_Volume_Stats",
    "IP_Data_Traffic_Volume_Stats ",
    "IP_Data_Traffic_Volume_stats",
]

disabled_enabled_meas_in_result_file = [
    "LTE_EPS_Bearer",
    "LTE_RRC",
    "LTE_S1AP",
    "LTE_X2AP",
    "LTE_ETHIF_stats",
    "LTE_Ethernet_Link",
    "LTE_IP_Filtering",
    "LTE_IP_Stats",
    "ETHIF_stats",
    "SCTP_stats",
    "TCP_UDP_stats",
    "IPIF_stats",
    ]


class BaselineMeasurement(object):
    name = ""
    nw_aggr_level = ""
    nw_profile = ""
    counter_tags = []


class BaselineMeasurements(object):

    baseline = ""

    def collect_baseline_parameters(self, baseline_root, iot_cell):
        BaselineMeasurements.baseline = baseline_root
        baseline_parameters = []
        for measurement in baseline_root.findall(r".//Measurement"):
            baseline_meas = BaselineMeasurement()
            baseline_meas.name = measurement.find(r"Name").text
            baseline_meas.nw_aggr_level = measurement.find(r"NW_Aggregation_Levels").text
            baseline_meas.nw_profile = measurement.find(r"Network_Profile").text
            baseline_meas.counter_tags = self._collect_baseline_counters(measurement)
            if "iot" not in baseline_meas.name.lower() or "iot" in baseline_meas.name.lower() and iot_cell:
                baseline_parameters.append(baseline_meas)
        return baseline_parameters

    @staticmethod
    def _collect_baseline_counters(meas):
        return [counter.find(r'.//PI_ID').text for counter in meas.findall(r'.//PI')]


class PmMeasurement(object):

    def __init__(self):
        self.name = ""
        self.dns = {}
        self.counter_tags = []
        self.counters = {}
        self.interval = ""
        self.start_time = ""


class PMFileMeasurements(object):
    def collect_pmfile_parameters(self, pm_root, iot_cell, energy=False):
        pmfile_parameters = []
        for pm_setup in pm_root.findall(r".//PMSetup"):
            interval = pm_setup.attrib['interval']
            start_time = pm_setup.attrib['startTime']
            pmfile_parameters += [self._fill_pm_parameters(pmmo_result, interval, start_time, iot_cell, energy)
                                  for pmmo_result in pm_setup.findall(r".//PMMOResult")]
        return [x for x in pmfile_parameters if x is not None]

    @staticmethod
    def _interval_sum_counters(meas, counter_number, counter):
        if meas.name == "LTE_EPS_Bearer":  # <DN>PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-11</DN>
            # 8006
            if counter_number < 2 or counter_number == 54 or counter_number == 213:
                meas.counters[counter.tag] = counter.text
        if meas.name == "LTE_Radio_Bearer":  # <DN>PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-11</DN>
            # 8007
            if counter_number < 12:
                meas.counters[counter.tag] = counter.text
        if meas.name == "LTE_UE_State":  # <DN>PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-11</DN>
            # 8013
            if counter_number == 13 or (44 < counter_number < 56):
                meas.counters[counter.tag] = counter.text
        if meas.name == "LTE_eNB_Load":  # <DN>PLMN-PLMN/MRBTS-1/LNBTS-1</DN>
            # 8018
            if counter_number < 10:
                meas.counters[counter.tag] = counter.text
        if meas.name == "LTE_UE_Quantity":  # <DN>PLMN-PLMN/MRBTS-1/LNBTS-1/LNCEL-11</DN>
            # 8051
            if 55 < counter_number < 64:
                meas.counters[counter.tag] = counter.text
        return meas

    def _fill_pm_parameters(self, pmmo_result, interval, start_time, iot_cell, energy):
        meas = PmMeasurement()
        meas.interval = interval
        meas.start_time = start_time
        ne_wbts = pmmo_result.find(r'.//NE-WBTS_1.0')
        mos = pmmo_result.findall(r'.//MO')
        meas.name = ne_wbts.attrib['measurementType']
        if "iot" in meas.name.lower() and not iot_cell:
            return None
        for mo in mos:
            meas.dns[mo.attrib['dimension']] = mo.find(r'./DN').text
        for counter in ne_wbts:
            counter_number = int(counter.tag.split("C")[-1])  # e.g. M8020C1
            meas = self._interval_sum_counters(meas, counter_number, counter)
            if meas.name == "LTE_Cell_Avail":
                # 8020
                if counter_number < 7:  # Test scope is for M8020C0 - M8020C6
                    meas.counters[counter.tag] = counter.text
            if energy:
                meas = self.energy_consumption_counters(meas, counter)
            meas.counter_tags.append(counter.tag)
        return meas

    @staticmethod
    def energy_consumption_counters(meas, counter):
        if meas.name in ("SBTS_Energy_Consumption", "SBTS_RFM_Energy_Monitoring", "SBTS_SM_Energy_Monitoring"):
            meas.counters[counter.tag] = counter.text
        return meas


class PmCheckMeasurements(object):

    def __init__(self, baseline_root, ignored_meas, ignored_counters):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.amount_iot_cell = self.count_infomodel_objects("NBIOT_FDD_R")
        self.baseline_parameters = BaselineMeasurements().collect_baseline_parameters(baseline_root,
                                                                                      self.amount_iot_cell)
        self.ignored_meas = self.textfile_to_list(ignored_meas, "Ignored measurements")
        self.ignored_counters = self.textfile_to_list(ignored_counters, "Ignored counters")
        self.meas_count_dict = self.create_meas_count_dict()
        self.pmfile_parameters = []
        self.case_interval_change = False
        self.full_intervals = None
        self.incomplete_interval_value = ""
        self.correct_interval = ""
        self.disabled_measurements = []
        self.expired_measurements = []
        self.counter_values = {}
        self.intermediate = False
        self.incomplete_intervals = None
        self.measurements_disabled = None
        self.case_meas_disabled_enabled = False
        self.upload_period = 0
        self.case_15min_to_60min = ""
        self.times_in_file = 0
        self.m8020_counters = None
        self.ntp_faulty = None

    def set_ignored_measurements_and_counters(self, ignored_meas, ignored_counters):
        self.ignored_meas = self.textfile_to_list(ignored_meas, "Ignored measurements")
        self.ignored_counters = self.textfile_to_list(ignored_counters, "Ignored counters")

    @staticmethod
    def _remove_comments(lines):
        return [re.sub(r'#.*$', '', line).rstrip() for line in lines if re.sub(r'#.*$', '', line).rstrip()]

    def textfile_to_list(self, path, name=""):
        info("Path to {} file: {}".format(name, path))
        with open(path, "r") as f:
            content = f.read()
        listed_content = content.splitlines()
        listed_content = self._remove_comments(listed_content)
        info("Content of the {} file: {}".format(name, listed_content))
        return listed_content

    def create_meas_count_dict(self):
        info("Create measurement count dictionary")
        ethif_count = self.count_ethif()
        ipif_count = self.count_managed_objects("IPIF")
        smod_count = self.count_infomodel_objects("SMOD_R")
        meas_count_dict = {
            "LTE_Neighb_Cell_HO": self.count_managed_objects("LNREL"),
            "SBTS_SFP_SMOD": self.count_infomodel_objects("CABLINK_R"),
            "SBTS_SFP_SMOD_LANE": self.count_infomodel_objects("CABLINK_R"),
            "LTE_X2_SCTP_Statistics": self.count_managed_objects("LNADJ"),
            "LTE_S1_SCTP_Statistics": self.count_managed_objects("LNMME"),
            "SBTS_Antenna_Line": self.count_antenna_lines(),
            "ETHIF_stats": ethif_count,
            "SCDSCH_stats": ethif_count,
            "Ethernet_Interface_Utilization_stats": ethif_count,
            "Ethernet_Interface_Utilization_Untagged_Frames_stats": ethif_count,
            "PHB_stats": ipif_count,
            "IPv4_addr_stats": ipif_count,
            "IPIF_stats": ipif_count,
            "IPv4_Interface_Stats": ipif_count,
            "IPv6_Interface_Stats": ipif_count,
            "IPv4_RX_PHB_Stats": ipif_count,
            "IPv4_TX_PHB_Stats": ipif_count,
            "IPv6_TX_PHB_Stats": ipif_count,
            "IPv6_RX_PHB_Stats": ipif_count,
            "FSCH_stats": self.count_managed_objects("FSTSCH"),
            "SBTS_SFP_RMOD": self.count_sfp_objects("RMOD"),
            "SBTS_SFP_BBMOD": self.count_sfp_objects("BBMOD"),
            "SBTS_SFP_RMOD_LANE": self.count_sfp_objects("RMOD"),
            "SBTS_SFP_BBMOD_LANE": self.count_sfp_objects("BBMOD"),
            "SBTS_RMOD_TEMPERATURE": self.count_infomodel_objects("RMOD_R"),
            "LTE_Baseband_Pool_Monitoring": self.count_infomodel_objects("BBPOOL_R"),
            "LTE_DAC_Word_Statistics": smod_count,
            "SBTS_SM_Energy_Monitoring": smod_count,
        }
        info("Created")
        return meas_count_dict

    @staticmethod
    def _modify_full_intervals(intervals_list):
        intervals = []
        for interval in intervals_list:
            if "min" in interval:
                intervals.append(interval.strip("min"))
            elif "h" in interval:
                intervals.append(str(int(interval.strip("h")) * 60))
        return intervals

    def init_pm_check_values(self, pm_root, interval="15min", expired_measurements=None, disabled_measurements=None,
                             counter_values=None, intermediate=None, incomplete_intervals=None,
                             measurements_disabled=None, upload_period=None, upload_period_change=None,
                             times_in_file=None, time=None, m8020_counters=None, ntp_faulty=None):
        self.case_interval_change = True if isinstance(interval, tuple) else False
        self.full_intervals = None
        if self.case_interval_change:
            # interval = full_intervals, expiration_times, incomplete_intervals
            self.full_intervals = self._modify_full_intervals(interval[0])
            if time.tzinfo and time.utcoffset().total_seconds() == 0:
                time = time.astimezone(pytz.timezone("Europe/Helsinki"))
            self.incomplete_interval_value = interval[1][time]
            info(f"Full intervals: {self.full_intervals}")
            info(f"Incomplete interval value: {self.incomplete_interval_value}")
        self.correct_interval = str(interval)
        self.expired_measurements = expired_measurements[0] if isinstance(expired_measurements,
                                                                          tuple) else expired_measurements
        if self.expired_measurements:
            info(f"Expired measurements: {self.expired_measurements}")
        self.disabled_measurements = disabled_measurements[1] if isinstance(disabled_measurements,
                                                                            tuple) else disabled_measurements
        if self.disabled_measurements:
            info(f"Disabled measurements: {self.disabled_measurements}")
        self.counter_values = counter_values
        self.m8020_counters = m8020_counters
        self.intermediate = intermediate
        self.ntp_faulty = ntp_faulty
        self.incomplete_intervals = incomplete_intervals
        self.measurements_disabled = measurements_disabled
        self.case_meas_disabled_enabled = True if (
                    incomplete_intervals is False or measurements_disabled is False) else False
        if not upload_period_change:
            self.upload_period = upload_period
        self.case_15min_to_60min = upload_period_change
        self.times_in_file = times_in_file
        self.pmfile_parameters = PMFileMeasurements().collect_pmfile_parameters(pm_root, self.amount_iot_cell)

    def check_pm_file(self, pm_file, interval="15min", expired_measurements=None, disabled_measurements=None,
                      counter_values=None, intermediate=None, incomplete_intervals=None, measurements_disabled=None,
                      upload_period=None, upload_period_change=None, times_in_file=None, time=None,
                      m8020_counters=None, ntp_faulty=None):
        self.init_pm_check_values(pm_file, interval, expired_measurements, disabled_measurements, counter_values,
                                  intermediate, incomplete_intervals, measurements_disabled, upload_period,
                                  upload_period_change, times_in_file, time, m8020_counters, ntp_faulty)
        found_pm_measurements, missing_measurements = self.get_combined_measurements()
        success = self.check_counters(found_pm_measurements)
        success = self.check_dn(found_pm_measurements) and success
        success = self.check_intervals(found_pm_measurements) and success
        success = self.report_missing_measurements(missing_measurements) and success
        if self.case_interval_change:
            success = self.report_not_expired_measurements(found_pm_measurements) and success
        if self.counter_values or self.m8020_counters:
            success = self.check_counters_values(found_pm_measurements) and success
        if self.case_meas_disabled_enabled:
            success = self.check_disabled_measurements(found_pm_measurements) and success
        info("Measurement and counter check completed. Result was: {}".format("Pass" if success else "Fail"))
        return success

    def count_sfp_objects(self, sfp_object):
        measurement_count = 0
        sfp_mos = self.admin.get_managed_objects("SFP_R", timeout=10)
        for sfp_mo in sfp_mos:
            if sfp_object in sfp_mo["distName"]:
                measurement_count += 1
        return measurement_count

    def count_ethif(self):
        ethif_ctr = 0
        for distname in list(self.scf.get_distname_based_on_class("ETHIF")):
            all_link_values = self.scf.get_all_p_values(distname, "linkSelectorDN")
            ethif_ctr += sum('IBRGPRT' in link for link in all_link_values)
        return ethif_ctr

    def count_managed_objects(self, mo_class):
        return len(list(self.scf.get_distname_based_on_class(mo_class)))

    def count_infomodel_objects(self, im_class):
        return len(self.admin.get_managed_objects(im_class))

    def count_antenna_lines(self):
        measurement_count = 0
        channel_mos = self.scf.get_class_dict("CHANNEL")
        for channel_distname, p_names in channel_mos.items():
            for cell in self.bts.cells:
                cell_id = cell.split("-")[-1]
                if re.search(r"LCELL-{}".format(cell_id), channel_distname) and \
                        p_names["direction"] == "TX":
                    measurement_count += 1
        return measurement_count

    def get_bts_id(self):
        return self.bts.get_parameter_value_from_bts_info('btsId')

    def get_cell_global_ids(self):
        cell_global_ids = []
        for _, cell_info in self.bts.cells.items():
            cell_global_ids.append(str(cell_info["globalCellId"]))
        return cell_global_ids

    @staticmethod
    def strip_min(input_value):
        if input_value:
            return int(str(input_value).strip("min"))

    def check_disabled_measurements(self, found_measurements):
        success = True
        disabled_found = []
        info("Checking that disabled measurements are not found from PM measurement file")
        if self.measurements_disabled:
            for meas in found_measurements:
                if meas.name not in disabled_enabled_meas_in_result_file:
                    continue
                if meas.name not in disabled_found:
                    disabled_found.append(meas.name)
                    error("->Disabled measurement [{}]: was found from PM measurement file.".format(
                        meas.name))
                    success = False
        return success

    def check_global_id(self, global_id, meas):
        all_cells = self.get_cell_global_ids()
        if str(global_id) in all_cells:
            return True
        else:
            error("Check cell id (got {}) for meas {}. It should be global cell id ({}).".format(
                global_id, meas, all_cells))
            return False

    def check_dn(self, found_measurements):
        success = True
        bts_id = self.get_bts_id()
        cell_list_regex = self.collect_cell_list_regex()
        for meas in found_measurements:
            baseline_meas = self.get_matching_baseline_meas(meas)
            correct_dn_regex = self.form_correct_dns(baseline_meas, bts_id, cell_list_regex)
            success = self.check_dn_correctness(meas, correct_dn_regex) and success
        info("DN check: {}".format("Pass" if success else "Fail"))
        return success

    @staticmethod
    def check_dn_correctness(meas, correct_dn_regex):
        success = True
        for dimension, dn in meas.dns.items():
            if dimension in correct_dn_regex.keys():
                if not re.match(correct_dn_regex[dimension], dn):
                    error("DN ({}) not found for {}. Allowed dns: {}".format(
                        dn, meas.name, correct_dn_regex[dimension]))
                    success = False
            else:
                error("Dimension ({}) for {} is not recognized. Allowed dimensions: {}".format(
                    dimension, meas.name, correct_dn_regex.keys()))
                success = False
        return success

    def get_matching_baseline_meas(self, meas):
        for baseline_meas in self.baseline_parameters:
            if baseline_meas.name == meas.name:
                return baseline_meas

    def form_correct_dns(self, baseline_meas, bts_id, cell_list_regex):
        correct_dn_regex = {}
        network_profiles = re.split(", |,", baseline_meas.nw_profile)
        for network_profile in network_profiles:
            dn_regex = r""
            dimension = ""
            parts_of_nw_profile = network_profile.split("-")
            if "PLMN-MRBTS" in network_profile:
                for part_of_nw_profile in parts_of_nw_profile:
                    dimension = "network_element"
                    if "PLMN" in part_of_nw_profile:
                        dn_regex += r"PLMN-PLMN"
                    elif "MRBTS" in part_of_nw_profile:
                        dn_regex += r"/MRBTS-{btsId}".format(btsId=bts_id)
                    elif "LNBTS" in part_of_nw_profile:
                        dn_regex += r"/LNBTS-{btsId}".format(btsId=bts_id)
                    elif "LNCEL" in part_of_nw_profile:
                        dn_regex += r"/LNCEL-(?:{cell})".format(cell=cell_list_regex)
                    else:
                        dn_regex += r"/{nw}-\d+".format(nw=part_of_nw_profile)
            if "MCC-MNC" in network_profile:
                dimension = "MCCMNC"
                dn_regex = r"PLMN-PLMN/MCC-\d+/MNC-\d+"
            if "CMCC-CMNC" in network_profile:
                dimension = "Core_network_MCC_MNC"
                dn_regex = r"PLMN-PLMN/CMCC-\d+/CMNC-\d+"
            if "EARFCN" in network_profile:
                dimension = "EUTRA_frequency"
                dn_regex = r"PLMN-PLMN/EARFCN-\d+"
            if "UARFCN" in network_profile:
                dimension = "UTRAN_FREQUENCY"
                dn_regex = r"PLMN-PLMN/UARFCN-\d+"
            if "LAC-TCID" in network_profile:
                dimension = "HO_Target"
                dn_regex = r"PLMN-PLMN/LAC-\d+/TCID-\d+"
            if "HOT-TCID" in network_profile:
                dimension = "HO_Target"
                dn_regex = r"PLMN-PLMN/HOT-\d+/TCID-\d+"
            if "PMQAP" in network_profile:
                dimension = "PM_QCI_ARP_Profile"
                dn_regex = r"PLMN-PLMN/PMQAP-\d+"
            if "ECI" in network_profile:
                dimension = "HANDOVER_ADJACENT_CELL"
                dn_regex = r"PLMN-PLMN/ECI-\d+"
            correct_dn_regex[dimension] = dn_regex
            if network_profiles.count("MCC-MNC") == 2:
                dimension = "Destination_MCC_MNC"
                dn_regex = r"PLMN-PLMN/MCC-\d+/MNC-\d+"
                correct_dn_regex[dimension] = dn_regex
        self.logger.debug(f"Correct DN regex: {correct_dn_regex} for {baseline_meas.name}")
        return correct_dn_regex

    def collect_cell_list_regex(self):
        cell_list = ""
        for cell_global_id in self.get_cell_global_ids():
            cell_list += r"{}{}".format(("|" if cell_list else ""), cell_global_id)
        return cell_list

    def check_counters(self, found_measurements):
        missing_counters, extra_counters, duplicates_counters = self.collect_counters(found_measurements)
        success = self.report_counters(missing_counters, extra_counters, duplicates_counters)
        info("Counters check: {}".format("Pass" if success else "Fail"))
        return success

    def collect_counters(self, found_measurements):
        missing_counters = {}
        extra_counters = {}
        duplicate_counters = {}
        for baseline_meas in self.baseline_parameters:
            for meas in found_measurements:
                if baseline_meas.name == meas.name and meas.name:
                    missing_counters[meas.name] = list(set(baseline_meas.counter_tags) - set(meas.counter_tags))
                    extra_counters[meas.name] = list(set(meas.counter_tags) - set(baseline_meas.counter_tags))
                    duplicate_counters[meas.name] = list(
                        set([x for x in meas.counter_tags if meas.counter_tags.count(x) > 1]))
        return self.remove_ignored_from_dict(missing_counters), self.remove_ignored_from_dict(extra_counters), \
            self.remove_ignored_from_dict(duplicate_counters)

    def report_counters(self, missing_counters, extra_counters, duplicate_counters):
        success = self.report_error_counters(missing_counters, 'missing')
        success = self.report_error_counters(extra_counters, 'extra') and success
        success = self.report_error_counters(duplicate_counters, 'duplicate') and success
        return success

    @staticmethod
    def report_error_counters(counters, text):
        success = True
        for meas, missing_counters in counters.items():
            if missing_counters:
                success = False
                error("->[{}]: {} counters ({}): {}".format(meas, text, len(missing_counters), missing_counters))
        return success

    def report_missing_measurements(self, missing_measurements):
        success = True
        for missing_measurement in missing_measurements:
            if self.case_interval_change and (len(
                    self.full_intervals) > 1 and missing_measurement not in self.expired_measurements):
                continue
            elif (self.case_interval_change and len(self.full_intervals) == 1 and
                  missing_measurement in self.disabled_measurements):
                continue
            elif (self.case_meas_disabled_enabled and
                  self.measurements_disabled and
                  missing_measurement in disabled_enabled_meas_in_result_file):
                continue
            else:
                error("Missing measurement->[{}]: Measurement was not found from result file".format(
                    missing_measurement))
                success = False
        return success

    def report_not_expired_measurements(self, found_measurements):
        success = True
        should_not_expired = []
        for meas in found_measurements:
            if meas.name not in should_not_expired and len(
                    self.full_intervals) > 1 and meas.name not in self.expired_measurements \
                    and meas.name not in self.disabled_measurements:
                should_not_expired.append(meas.name)
                error("->[{}]: should not be expired in this result file.".format(meas.name))
                success = False
        return success

    def get_combined_measurements(self):
        found_measurements = []
        for baseline_meas in self.baseline_parameters:
            for pm_meas in self.pmfile_parameters:
                if pm_meas not in found_measurements and pm_meas.name in baseline_meas.name:
                    found_measurements.append(pm_meas)
        missing_measurements = self.find_missing_measurements(found_measurements)
        return self.remove_ignored_measurements(found_measurements), missing_measurements

    def find_missing_measurements(self, found_measurements):
        baseline_names = [meas.name for meas in self.baseline_parameters if meas.name not in self.ignored_meas]
        found_names = [meas.name for meas in found_measurements if meas.name not in self.ignored_meas]
        return list(set(baseline_names) - set(found_names))

    def check_intervals(self, found_measurements):
        success = True
        checked_measurements = []
        for meas in found_measurements:
            if self.case_interval_change and (
                    len(self.full_intervals) > 1 and meas.name not in self.expired_measurements and
                    meas.interval != self.incomplete_interval_value):
                continue
            elif self.measurements_disabled and meas.name in disabled_enabled_meas_in_result_file:
                continue
            else:
                result_intervals = [found_meas.interval for found_meas in found_measurements if
                                    found_meas.name == meas.name]
                if meas.name not in checked_measurements:
                    measurement_count = [found_meas.name for found_meas in found_measurements].count(meas.name)
                    correct_measurement_count = self.get_meas_count(meas)
                    success = self.interval_check(meas.name, measurement_count, correct_measurement_count,
                                                  meas.interval, result_intervals) and success
                    checked_measurements.append(meas.name)
        if not checked_measurements:
            error("There is no checked measurements in interval check")
            success = False
        info("Interval check: {}".format("Pass" if success else "Fail"))
        return success

    def specific_measurement_name_count(self, meas):
        return self.meas_count_dict[meas] if meas in self.meas_count_dict else 1

    def get_meas_count(self, meas):
        measurement_count = self.specific_measurement_name_count(meas.name)
        if "iot" in meas.name.lower() and "LTE_NB_IoT_BTS_Level_Measurements" not in meas.name:
            measurement_count = self.amount_iot_cell
        elif "LNCEL" in meas.dns["network_element"] and "LTE_Neighb_Cell_HO" not in meas.name:
            measurement_count = len(self.bts.cells) * measurement_count - self.amount_iot_cell
        if self.case_interval_change:
            measurement_count = self.get_meas_count_for_interval_change(meas, measurement_count)
        elif self.upload_period == 60 and (meas.name in intervals_15min or "15" in self.correct_interval):
            measurement_count = measurement_count * (self.upload_period / 15)
        elif self.case_15min_to_60min:
            measurement_count = measurement_count * 2
        elif self.expired_measurements and meas.name in self.expired_measurements:
            if "15" in self.expired_measurements[meas.name]:
                measurement_count = measurement_count * 4
            elif "30" in self.expired_measurements[meas.name]:
                measurement_count = measurement_count * 2
        if self.times_in_file:
            measurement_count = measurement_count * self.times_in_file
        return measurement_count

    def get_meas_count_for_interval_change(self, meas, measurement_count):
        if not self.full_intervals:  # when all intervals are 15min
            measurement_count = measurement_count * 4
        elif len(self.full_intervals) == 1:  # First file with incomplete intervals
            if meas.name in self.expired_measurements and self.expired_measurements[meas.name] == "15":
                measurement_count = measurement_count * 4
        else:
            meas_interval = self.expired_measurements[meas.name]  # Intervals are changed
            times_in_result_file = 60 / int(meas_interval) if int(meas_interval) < 60 else 1
            measurement_count = measurement_count * times_in_result_file
        return measurement_count

    def check_incomplete_intervals_after_change(self, meas_name, measurement_count, result_intervals):
        # file should contain 2*15min and 1*30min measurements.
        success = True
        if meas_name in self.expired_measurements and not result_intervals.count("15") == 2*measurement_count:
            error("->[{}]: 15min intervals found {} times (should be found {} times)".format(
                meas_name, result_intervals.count("15"), 2*measurement_count))
            success = False
        if meas_name in self.expired_measurements and not result_intervals.count("30") == measurement_count:
            error("->[{}]: 30min intervals found {} times (should be found {} times)".format(
                meas_name, result_intervals.count("30"), measurement_count))
            success = False
        for resultInterval in result_intervals:
            if not resultInterval == "15" and not resultInterval == "30":
                error("->[{}]: unallowed interval found: {}".format(meas_name, resultInterval))
                success = False
        info("{}: intervals: [{}]".format(meas_name, ','.join(result_intervals)))
        return success

    def check_interval_change_intervals(self, meas_name, meas_count, correct_count, meas_interval, result_intervals):
        success = True
        if len(self.full_intervals) == 1:
            if meas_name in self.expired_measurements and self.expired_measurements[meas_name] == "15":
                success = self.check_normal_intervals(meas_name, meas_count, correct_count, meas_interval,
                                                      result_intervals=result_intervals) and success
            else:
                success = self.check_incomplete_intervals_after_change(meas_name, correct_count,
                                                                       result_intervals) and success
        else:
            success = self.check_normal_intervals(meas_name, meas_count, correct_count, meas_interval,
                                                  result_intervals=result_intervals) and success
        return success

    def check_normal_intervals(self, meas_name, measurement_count, correct_measurement_count, interval,
                               result_intervals=""):
        success = True
        if not measurement_count == correct_measurement_count:
            error("->[{}]: was found {} times (should have been found {} times).".format(
                meas_name, measurement_count, correct_measurement_count))
            success = False
        if result_intervals:  # incomplete intervals case
            for result_interval in result_intervals:
                if self.full_intervals and interval not in self.full_intervals:
                    if not result_interval == str(self.incomplete_interval_value):
                        error("->[{}]: interval from measuring report:({}). Expected: ({})".format(
                            meas_name, result_interval, self.incomplete_interval_value))
                        success = False
                elif self.incomplete_intervals and meas_name in disabled_enabled_meas_in_result_file:
                    if abs(int(result_interval) - 10) > 2:
                        error(f"Incomplete interval {result_interval} for {meas_name} differs from 10 more than "
                              f"2 units.")
                        success = False
                elif not result_interval == interval:
                    error("->[{}]: interval from measuring report:({}). Expected: ({})".format(
                        meas_name, result_interval, interval))
                    success = False
        elif self.intermediate:  # intermediate period
            if int(interval) < 3 or int(interval) > 12:
                error("->[{}]: has incorrect interval: {}".format(meas_name, interval))
                success = False
        elif "LTE_MAC" in self.correct_interval:
            success = self.interval_check_lte_mac(meas_name, interval) and success
        elif self.expired_measurements and meas_name in self.expired_measurements:
            if not interval == self.expired_measurements[meas_name].strip("min"):
                error("->[{}]: interval ({}) is not {}".format(
                    meas_name, interval, self.expired_measurements[meas_name]))
                success = False
        elif self.ntp_faulty:
            if int(interval) < 10 or int(interval) > 14:  # NTP is unavailable for few minutes and sync is lost
                error("->[{}]: has incorrect interval: {}".format(meas_name, interval))
                success = False
        else:
            if not interval == self.correct_interval.strip("min"):
                error("->[{}]: interval ({}) is not {}".format(meas_name, interval, self.correct_interval))
                success = False
        return success

    def interval_check(self, meas_name, measurement_count, correct_measurement_count, interval, all_intervals):
        if self.case_interval_change:
            success = self.check_interval_change_intervals(meas_name, measurement_count, correct_measurement_count,
                                                           interval, all_intervals)
        elif self.case_meas_disabled_enabled:
            success = self.check_normal_intervals(meas_name, measurement_count, correct_measurement_count, interval,
                                                  all_intervals)
        else:
            success = self.check_normal_intervals(meas_name, measurement_count, correct_measurement_count, interval)
        return success

    def interval_check_lte_mac(self, meas_name, interval):
        success = True
        interval = int(interval)
        if self.correct_interval == "LTE_MAC with reset":
            if meas_name not in intervals_15min:
                if interval < 45 or interval > 60:
                    error("->[{}]: interval ({}) is not between 45-60min range".format(meas_name, interval))
                    success = False
            else:
                if interval < 0 or interval > 15:
                    error("->[{}]: interval ({}) is not between 0-15min range".format(meas_name, interval))
                    success = False
        elif self.correct_interval == "LTE_MAC":
            if meas_name not in intervals_15min:
                if interval != 60:
                    error("->[{}]: interval ({}) is not 60min".format(meas_name, interval))
                    success = False
            else:
                if interval != 15:
                    error("->[{}]: interval ({}) is not 15min".format(meas_name, interval))
                    success = False
        return success

    def remove_ignored_measurements(self, item_list):
        return [item for item in item_list if item.name not in self.ignored_meas]

    def remove_ignored_from_dict(self, item_dict):
        filtered_dict = {}
        for meas, counters_list in item_dict.items():
            filtered_counters = []
            if meas not in self.ignored_meas:
                for counter in counters_list:
                    if counter not in self.ignored_counters:
                        filtered_counters.append(counter)
                filtered_dict[meas] = filtered_counters
        return filtered_dict

    @staticmethod
    def reformat_m8020_data(pmmo_result):
        formatted_list = []
        counters = pmmo_result.getElementsByTagName("NE-WBTS_1.0")[0].childNodes
        for counter in counters:
            formatted_list.append((counter.nodeName, int(counter.firstChild.data)))
            formatted_list.sort(key=lambda x: int(x[0].split("C")[-1]))  # Sort M8020Cx by x
        return formatted_list

    def compare_m8020_ctr_values(self, cell_global_id, counter, ctr_number, counters, tolerance=None):
        success = True
        ctr_id = f"{counter}{ctr_number}"
        checked_value = int(counters[ctr_number][1])
        correct_value = self.m8020_counters[cell_global_id][ctr_number]
        if tolerance:
            if abs(checked_value - correct_value) > tolerance:
                error(f"CELL-{cell_global_id}: {ctr_id} value from PM-file ({checked_value}) differs from "
                      f"calculated value ({correct_value}) more than {tolerance} samples.")
                success = False
            else:  # DEBUG poista
                self.logger.debug(f"CELL-{cell_global_id}: {ctr_id} value from PM-file {checked_value} is within "
                                  f"tolerance.")
        else:
            if checked_value != correct_value:
                error(f"CELL-{cell_global_id}: {ctr_id} value from PM-file {checked_value} is not the"
                      f" same as calculated value: {correct_value}")
                success = False
            else:  # DEBUG poista
                self.logger.debug(f"CELL-{cell_global_id}: {ctr_id} value from PM-file {checked_value} is correct.")
        return success

    def check_all_m8020_counter_values(self, cell_global_id, counters):
        success = True
        try:
            if counters[0][0] == "M8020C0":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 0, counters) and success
            if counters[1][0] == "M8020C1":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 1, counters) and success
            if counters[2][0] == "M8020C2":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 2, counters) and success
            if counters[3][0] == "M8020C3":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 3, counters, tolerance=6) and success
            if counters[4][0] == "M8020C4":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 4, counters, tolerance=6) and success
            if counters[5][0] == "M8020C5":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 5, counters, tolerance=6) and success
            if counters[6][0] == "M8020C6":
                success = self.compare_m8020_ctr_values(cell_global_id, "M8020C", 6, counters, tolerance=6) and success
        except IndexError as e:
            error("Check M8020Cx counter noted in error message: {}".format(e))
            success = False
        info(f"CELL-{cell_global_id}: Calculated values: {self.m8020_counters[cell_global_id]}")
        info(f"CELL-{cell_global_id}: PM-file values: {dict(counters)}")
        return success

    def compare_ctr_values(self, counter, meas_dn):
        success = True
        ctr_id, ctr_value = counter
        self.logger.debug(f"Counter {ctr_id} value from PM-file: {ctr_value}")
        if ctr_id in self.ignored_counters:
            info(f"Counter {ctr_id} is ignored. Not checked.")
        elif ctr_id in self.counter_values:
            self.logger.debug(f"Calculated value: {self.counter_values[ctr_id]}")
            if int(ctr_value) <= int(self.counter_values[ctr_id]):
                error(f"{meas_dn}: Counter {ctr_id} value from PM-file ({ctr_value}) should be incremented")
                success = False
            else:
                info(f"{meas_dn}: Counter {ctr_id} value from PM-file {ctr_value} is incremented correctly.")
        return success

    def check_counter_values(self, counters, meas_dn=None):
        success = True
        for counter in counters:
            success = self.compare_ctr_values(counter, meas_dn) and success
        return success

    def deviation_check(self, cell_global_id):
        # C6 - (C3+C4+C5) <= 10
        success = False
        m8020c = self.m8020_counters[cell_global_id]
        deviation = m8020c[6] - (m8020c[3] + m8020c[4] + m8020c[5])
        if deviation > 10:
            error(f"CELL-{cell_global_id}: Deviation is greater than 10 ({deviation})")
        else:
            success = True
            info(f"CELL-{cell_global_id}: Deviation: {deviation}")
        return success

    def check_pm_m8020_data(self, pm_m8020_dict):
        info("Check M8020 Cell Availability counters")
        counter_success = True
        if not self.m8020_counters:
            error("Calculated counter values are not available. (Usually means that cell(s) have not been "
                  "disabled/enabled.)")
            counter_success = False
        elif not pm_m8020_dict:
            error("LTE_Cell_Avail measurements not found from PM file. -> Could not check M8020 counters.")
            counter_success = False
        else:
            for cell_global_id, counters in pm_m8020_dict.items():
                if not isinstance(counters, list):
                    counters = self.reformat_m8020_data(counters)
                counter_success = self.check_all_m8020_counter_values(cell_global_id, counters) and counter_success
                counter_success = self.deviation_check(cell_global_id) and counter_success
        return counter_success

    def check_counters_values(self, found_measurements):
        success = True
        for meas in found_measurements:
            pm_m8020_dict = {}
            if "network_element" in meas.dns and "LNCEL" in meas.dns[
                    "network_element"]:
                sorted_counters = sorted(meas.counters.items())  # List of tuples e.g [('M8020C1', '50')]
                self.logger.debug(f"Counters for {meas.name}: {sorted_counters}")
                lncel_global_id = str(meas.dns["network_element"].split("LNCEL-")[-1])
                success = self.check_global_id(lncel_global_id, meas.name) and success
                if "LTE_Cell_Avail" in meas.name and self.m8020_counters:
                    pm_m8020_dict[lncel_global_id] = sorted_counters
                    success = self.check_pm_m8020_data(pm_m8020_dict) and success
                if (meas.name in ("LTE_EPS_Bearer", "LTE_Radio_Bearer", "LTE_UE_State", "LTE_UE_Quantity")
                        and self.counter_values):
                    success = self.check_counter_values(sorted_counters, meas_dn=meas.dns[
                        "network_element"]) and success
            if "LTE_eNB_Load" in meas.name and "network_element" in meas.dns and "LNCEL" not in meas.dns[
                    "network_element"] and self.counter_values:
                sorted_counters = sorted(meas.counters.items())  # List of tuples
                self.logger.debug(f"Counters for {meas.name}: {sorted_counters}")
                success = self.check_counter_values(sorted_counters, meas_dn=meas.dns[
                    "network_element"]) and success
        info("Extra counters (e.g. M8020) check: {}".format("Pass" if success else "Fail"))
        return success
