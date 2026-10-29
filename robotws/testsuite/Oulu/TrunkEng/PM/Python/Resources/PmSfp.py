import re
import os
import zipfile
import json
from datetime import datetime, timedelta
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib import PmCommonLib
from testsuite.Oulu.TrunkEng.PM.Python.Resources.exceptions import SFPException
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCheckMeasurements import BaselineMeasurements


class PmSfp(object):
    """This PmSfp resource includes functions for PM SFP tests."""

    tolerances = {
        "Temperature": (0, 70),
        "Voltage": (3000, 3500),
        "Current": (0, 42),
        "TX power": (-7.5, -0.7),
        "RX power": (-14.0, -1.5)
    }

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.python_helper = BuiltIn().get_library_instance("python_helper")
        self.pm_lib = PmCommonLib()
        self.baseline_measurements = BaselineMeasurements()

    def retrieve_and_store_sfp_data(self, timeout=60, connection="log_admin"):
        """
        Retrieve and store SFP monitor data.
        :param int timeout: Timeout for retrieving SFP monitor data.
        :param str connection: Admin connection for retrieving SFP monitor data, default is log_admin.
        """
        sfp_data = {}
        try:
            info("Retrieving and storing SFP monitor data.")
            json_data = self.admin.get_sfp_data(timeout=timeout, detailed_output=True, connection=connection)
            if json_data:
                sfp_json = os.path.join(str(self.logger.log_dir), "sfp_monitor_data.json")
                with open(sfp_json, "w") as f:
                    json.dump(json_data, f, indent=4)
                if "requestMessage" in json_data:
                    sfp_data = self.fill_values_for_sfp(sfp_data, json_data["requestMessage"]["connected"], "source")
                    sfp_data = self.fill_values_for_sfp(sfp_data, json_data["requestMessage"]["connected"],
                                                        "destination")
                    info("SFP monitor data stored")
                else:
                    error(f"Key requestMessage was not found from json data. Check from file {sfp_json} if content of "
                          f"json is correct.")
                    raise SFPException("Key requestMessage was not found from json data.")
            else:
                error("No SFP monitor data was retrieved, json is empty.")
                raise SFPException("No SFP monitor data was retrieved.")
        except (TypeError, ValueError, AttributeError, KeyError, AdminApiConnectionClosedException,
                AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AliasLookupError) as ex:
            error(f"Unable to get sfpData from admin. {ex.__class__.__name__}:{ex} was raised\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            raise SFPException("Unable to get sfpData from admin.")
        return sfp_data

    def fill_values_for_sfp(self, values, json, source):
        """
        Fill values of SFP monitor data. Collected values are: Temperature, Voltage, Current, TX power and RX power.
        :param dict values: Sfp data.
        :param dict json: Json data of 'connected' key.
        :param str source: Source or destination.
        """
        there_were_some_errors = False
        try:
            for sources in json:
                sfp_distname = str(sources[source]["type"])
                sfp_values = sources[source]["connector"]["sfp"]
                values["{}: {}".format(source, sfp_distname)] = {
                    "Temperature": self.parse_only_value(str(sfp_values["temperature"]), sfp_distname, "temperature"),
                    "Voltage": self.parse_only_value(str(sfp_values["voltage"]), sfp_distname, "voltage"),
                    "Current": self.parse_only_value(str(sfp_values["transceiverTxBiasCurrent"]), sfp_distname,
                                                     "current"),
                    "TX power": self.parse_only_value(str(sfp_values["opticalTxPowerInDbM"]), sfp_distname,
                                                      "opticalTxPowerInDbM"),
                    "RX power": self.parse_only_value(str(sfp_values["opticalRxPowerInDbM"]), sfp_distname,
                                                      "opticalRxPowerInDbM")
                }
        except (TypeError, ValueError, OSError, MemoryError, IndexError) as ex:
            error(f"Problems while filling values for sfp. Reason: {ex.__class__.__name__}:'{ex}'.\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            there_were_some_errors = True
        if there_were_some_errors:
            raise SFPException("Problems while filling values for SFP.")
        return values

    @staticmethod
    def parse_only_value(text, dist_name, value_name):
        """
        Parse value from given information.
        :param str text: Text to parse.
        :param str dist_name: Dist name of SFP.
        :param str value_name: Name of value.
        """
        try:
            if "[" in text:
                text = text.replace('[', '').replace(']', '')
            pattern = re.compile(r'(?P<value>(-|)\d+((\.|,)\d+|)).*')
            match = pattern.match(text)
            if match:
                return str(match.group('value')).replace(",", ".")
            else:
                error("Couldn't parse value for {}'s {}. Giving 0 as init value".format(dist_name, value_name))
                return '0'
        except (TypeError, ValueError, OSError, MemoryError, IndexError) as ex:
            error(f"Problems while filling values for sfp, parse_only_value. Reason: {ex.__class__.__name__}:'{ex}'.\n"
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            return '0'

    def find_latest_pm_rd_file(self, file_list, data_type):
        """
        Find latest PM or RD file.
        :param list file_list: List of files.
        :param str data_type: Data type, PM or RD.
        """
        info("Find latest {} file".format(data_type))
        parsed_file_dict = {}
        for file_name in file_list:
            parsed_file_dict[self.parse_filename(file_name, 'date_and_time')] = file_name
        sorted_file_dict = sorted(parsed_file_dict.items())
        info("Latest {} file: {}".format(data_type, sorted_file_dict[-1][1]))
        return sorted_file_dict[-1][1]

    @staticmethod
    def parse_rd_sfp_data(sfp_data, ne_wbts, measurement_type, distname):
        """
        Parse SFP data from RD file.
        :param dict sfp_data: SFP data.
        :param Element ne_wbts: Element of ne_wbts.
        :param str measurement_type: Measurement type.
        :param str distname: Dist name of SFP.
        """
        there_were_some_errors = False
        try:
            if "SFP" in distname and "SBTS_SFP" not in measurement_type:
                data_dict = {
                    "Voltage": ne_wbts.find(r'./SFP_XCVR_TX_SUPPLY_VOLTAGE').text,
                    "Current": ne_wbts.find(r'./SFP_XCVR_TX_BIAS_CURRENT').text,
                    "TX power": str(float(ne_wbts.find(r'./SFP_XCVR_TX_PWR').text) / 10),
                    "RX power": str(float(ne_wbts.find(r'./SFP_XCVR_RX_OPT_PWR').text) / 10),
                    "Temperature": ne_wbts.find(r'./SFP_TEMPERATURE').text
                }
                sfp_data[distname + " | " + measurement_type] = data_dict
        except AttributeError:
            error(
                "Parsing has failed, take contact to script developer.\nDebug info {}:\n\tdistname: {}\n\t"
                "Temperature: {}\n\tVoltage: {}\n\tCurrent: {}\n\tTX power: {}\n\tRX power: {}\n".format(
                    measurement_type, distname, ne_wbts.find(r'./SFP_TEMPERATURE'),
                    ne_wbts.find(r'./SFP_XCVR_TX_SUPPLY_VOLTAGE'), ne_wbts.find(r'./SFP_XCVR_TX_BIAS_CURRENT'),
                    ne_wbts.find(r'./SFP_XCVR_TX_PWR'), ne_wbts.find(r'./SFP_XCVR_RX_OPT_PWR')))
            there_were_some_errors = True
        if there_were_some_errors:
            raise SFPException("Problems while parsing SFP data from RD file.")
        return sfp_data

    @staticmethod
    def parse_sfp_unique_data(bbmod_regex, rmod_regex, smod_regex, distname, for_checks=True):
        """
        Parse unique data from SFP distname.

        :param str bbmod_regex: Regex for BBMOD.
        :param str rmod_regex: Regex for RMOD.
        :param str smod_regex: Regex for SMOD.
        :param str distname: Dist name of SFP.
        :param bool for_checks: Is this for checks or not.
        """
        bbmod_regex = re.compile(bbmod_regex)
        rmod_regex = re.compile(rmod_regex)
        smod_regex = re.compile(smod_regex)
        # SMOD regex
        bbmod_match = bbmod_regex.match(distname)
        rmod_match = rmod_regex.match(distname)
        smod_match = smod_regex.match(distname)
        if bbmod_match:
            return 'bbmod', bbmod_match.group('bbmod'), bbmod_match.group('rf')
        elif rmod_match:
            return 'rmod', rmod_match.group('rmod'), rmod_match.group('opt_if')
        elif smod_match:
            return 'smod', smod_match.group('smod'), smod_match.group('rf')
        else:
            if for_checks:
                error("Couldn't parse {} for unique info".format(distname))
                raise SFPException("Couldn't parse {} for unique info.".format(distname))

    def check_if_data_should_be_parsed(self, distname, sfp_monitor_unique_info, meas_type):
        """
        Check if data should be parsed from RD or not.
        :param str distname: Dist name of SFP.
        :param dict sfp_monitor_unique_info: SFP monitor unique info.
        :param str meas_type: Measurement type
        """
        sfp_rd_unique_info = self.parse_sfp_unique_data(
            r'.*PLMN-PLMN/MRBTS-\d+/EQM-\d+/APEQM-\d+/CABINET-\d+/BBMOD-(?P<bbmod>\d+)/SFP-(?P<rf>\d+).*',
            r'.*PLMN-PLMN/MRBTS-\d+/EQM-\d+/APEQM-\d+/RMOD-(?P<rmod>\d+)/SFP-(?P<opt_if>\d+).*',
            r'.*PLMN-PLMN/MRBTS-\d+/EQM-\d+/APEQM-\d+/CABINET-\d+/SMOD-(?P<smod>\d+)/SFP-(?P<rf>\d+).*',
            distname, for_checks=False)
        unit_type = meas_type.split("SFP_")[-1] if "SFP_" in meas_type else ""
        self.logger.debug(f"unit_type: {unit_type}")
        self.logger.debug(f"distname: {distname}")
        self.logger.debug(f"sfp_rd_unique_info: {sfp_rd_unique_info}")
        self.logger.debug(f"sfp_monitor_unique_info: {sfp_monitor_unique_info}")
        asoe_allowed = False
        for smod in self.bts.smods:
            # ASOE doesn't have BBMOD
            if (unit_type == "SMOD" and "ASOE" in smod.name and sfp_rd_unique_info and
                    sfp_rd_unique_info[1] == smod.name[-1]):
                asoe_allowed = True
        if ("SFP" in distname and sfp_rd_unique_info in sfp_monitor_unique_info and
                (unit_type not in distname or asoe_allowed)):
            info("{} should be checked from RD data".format(distname))
            return True
        elif "SFP" in distname and sfp_rd_unique_info not in sfp_monitor_unique_info:
            info("{} should not be checked from RD data".format(distname))
        return False

    def parse_xml_sfp_data(self, xml_file, sfp_unique_info):
        """
        Parse SFP data from XML file.
        :param str xml_file: Path to XML file.
        :param dict sfp_unique_info: SFP monitor unique info.
        """
        sfp_data = {}
        rd_data = self.pm_lib.parse_file(xml_file)
        if rd_data:
            # rd_data_root = Etr.XML(rd_data)
            # if rd_data_root:
            for pmmo_result in rd_data.findall(r".//PMMOResult"):
                mos = pmmo_result.findall(r'.//MO')
                if mos:
                    for mo in mos:
                        distname = mo.find(r'./DN').text
                        ne_wbts = pmmo_result.find(r'.//NE-WBTS_1.0')
                        measurement_type = ne_wbts.attrib["measurementType"]
                        data_should_be_parsed = self.check_if_data_should_be_parsed(distname, sfp_unique_info,
                                                                                    measurement_type)
                        if data_should_be_parsed:
                            sfp_data = self.parse_rd_sfp_data(sfp_data, ne_wbts, measurement_type, distname)
            # else:
            #     error("Couldn't parse root of XML file {}".format(xml_file))
            #     raise SFPException("Couldn't parse root of XML file {}".format(xml_file))
        else:
            error("Couldn't parse file {}".format(xml_file))
            raise SFPException("Couldn't parse file {}".format(xml_file))
        return sfp_data

    def sfp_information_from_sfp_monitor(self, sfp_monitor_data):
        """
        SFP information from SFP monitor data.
        :param dict sfp_monitor_data: SFP monitor data.
        """
        sfps = []
        for distname in sfp_monitor_data.keys():
            sfps.append(self.parse_sfp_unique_data(r'.*CABINET-\d+/BBMOD-(?P<bbmod>\d+)\(\w+\)\/RF(?P<rf>\d+).*',
                                                   r'.*RMOD-(?P<rmod>\d+)\(\w+\)\/OPT_IF(?P<opt_if>\d+).*',
                                                   r'.*SMOD-(?P<smod>\d+)\(\w+\)\/RF(?P<rf>\d+).*',
                                                   distname))
        return sfps

    def retrieve_and_store_rd_pm_data(self, data, sfp_monitor_data, ip_of_smod):
        """
        Retrieve and store RD or PM data
        :param str data: Data to retrieve and store, for example "RD.BTS".
        :param dict sfp_monitor_data: SFP monitor data that is collected with method retrieve_and_store_sfp_data
        :param str ip_of_smod: IP of SMOD.
        """
        info("Retrieve and store {} SFP data".format(data))
        sfp_unique_info = self.sfp_information_from_sfp_monitor(sfp_monitor_data)
        all_found_filenames = self.ssh.get_content_of_folder_of_smod("/ram/", data)
        all_found_filenames = [item.rstrip() for item in all_found_filenames]
        latest_file = self.find_latest_pm_rd_file(all_found_filenames, data)
        latest_file_in_bts = os.path.join("/ram", latest_file)
        xml_file = self.collect_logs.get_file_or_folder_from_bts_to_test_logs(
            latest_file_in_bts, bts_ip=ip_of_smod)
        parsed_sfp_data = self.parse_xml_sfp_data(xml_file, sfp_unique_info)
        info("{} SFP data stored".format(data))
        return parsed_sfp_data, latest_file, all_found_filenames

    @staticmethod
    def check_values_from_data(data_dict):
        """
        Check values from data dict.
        :param dict data_dict: Data dict.
        :return: True if all values are in tolerance, otherwise False.
        """
        success = True
        if PmSfp.tolerances:
            for value_name, tolerance in PmSfp.tolerances.items():
                for distname, data in data_dict.items():
                    if tolerance[0] <= float(data[value_name]) <= tolerance[1]:
                        info("{name} ({value}) was in tolerance for {dn}".format(
                            name=value_name, value=data[value_name], dn=distname))
                    else:
                        error("{name} ({value}) was not in tolerance boundaries {tolerance} for {dn}".format(
                            name=value_name, value=data[value_name], tolerance=PmSfp.tolerances[value_name],
                            dn=distname))
                        success = False
            if not success:
                raise SFPException("Values were not in tolerance.")
        else:
            info("Tolerance not set. No values were checked.")

    @staticmethod
    def check_amount_of_sfps(amount, correct_amount, rd_data=False):
        """
        Check amount of SFPs.
        :param int amount: Amount of SFPs.
        :param int correct_amount: Correct amount of SFPs.
        :param bool rd_data: Is this RD data or not, default not.
        """
        if (not rd_data and amount == correct_amount) or (rd_data and amount >= correct_amount):
            info("SFP count ({}) equals or have more SFPs to counted SFPs from CABLINK_R-objects ({})".format(
                amount, correct_amount))
        else:
            error("SFP count ({}) does not equal to counted SFPs from CABLINK_R-objects ({}).".format(amount,
                                                                                                      correct_amount))
            raise SFPException("Amount of SFPs was not correct.")

    @staticmethod
    def check_data(data_dict, text, correct_amount_of_sfps):
        """
        Check data from data dict.
        :param dict data_dict: Data dict.
        :param str text: Text to print.
        :param int correct_amount_of_sfps: Correct amount of SFPs.
        :return: True if all values are in tolerance and amount of SFPs is correct, otherwise False.
        """
        info(f"Check {text}")
        PmSfp.check_values_from_data(data_dict)
        PmSfp.check_amount_of_sfps(len(data_dict), correct_amount_of_sfps, rd_data=True if "RD" in text else False)

    def get_snapshot(self):
        """Get snapshot from BTS for RD file checks."""
        return self.pm_lib.collect_snapshot("RD_check")

    @staticmethod
    def get_namelist_from_snapshot(path_of_snapshot):
        """
        Get namelist file (snapshot_file_list.txt) from snapshot.
        :param str path_of_snapshot: Path of snapshot.
        :return: List of files in snapshot.
        """
        if path_of_snapshot:
            try:
                with zipfile.ZipFile(path_of_snapshot, 'r') as z:
                    with z.open('snapshot_file_list.txt') as f:
                        return [item.decode('utf8').strip() for item in f.readlines()]
            except (UnicodeDecodeError, TypeError, zipfile.BadZipFile, zipfile.LargeZipFile) as ex:
                error(f"Couldn't get namelist from snapshot. {ex.__class__.__name__}:{ex} was raised.\n"
                      f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
                raise SFPException("Couldn't get namelist from snapshot.")
        else:
            error("Couldn't get namelist from snapshot")
            raise SFPException("Couldn't get namelist from snapshot.")

    @staticmethod
    def parse_rd_files(list_of_items):
        """
        Parse RD files from list of items.
        :param list list_of_items: List of items.
        :return: List of RD files.
        """
        # BTS10244_1011_RD.BTS-10244.20191017.073000.ANY.xml.gz
        list_of_rd_files = []
        pattern = re.compile(r".*(?P<rd_file>RD\.BTS.*)")
        for item in list_of_items:
            match = pattern.match(item)
            if match:
                list_of_rd_files.append(match.group('rd_file'))
        return list_of_rd_files

    @staticmethod
    def print_difference(missing_files, text):
        """
        Print error messages from difference between lists.
        :param list missing_files: List of missing files.
        :param str text: Text to print.
        """
        if missing_files:
            for item in missing_files:
                error("{} was not found from snapshot files".format(text, item))

    @staticmethod
    def find_missing_files(filelist, snapshot_filelist):
        """
        Find missing files from filelist and snapshot_filelist.
        :param list filelist: List of files.
        :param list snapshot_filelist: List of snapshot files.
        :return: List of missing files.
        """
        return list(set(filelist) - set(snapshot_filelist))

    @staticmethod
    def find_duplicate_files(filelist):
        """Find duplicate files from filelist."""
        return list(set([x for x in filelist if filelist.count(x) > 1]))

    @staticmethod
    def check_namelist(filelist, snapshot_filelist):
        """
        Check that all RD files were found from snapshot.
        :param list filelist: List of files.
        :param list snapshot_filelist: List of snapshot files.
        :return: True if all the files were found and there were no duplicate files, otherwise False.
        """
        info("Check that all RD files were found from snapshot")
        missing = PmSfp.find_missing_files(filelist, snapshot_filelist)
        duplicate_bts = PmSfp.find_duplicate_files(filelist)
        duplicate_snapshot = PmSfp.find_duplicate_files(snapshot_filelist)
        if missing or duplicate_bts or duplicate_snapshot:
            PmSfp.print_difference(missing, 'Missing file(s) in snapshot')
            PmSfp.print_difference(duplicate_bts, 'Duplicate file(s) from BTS')
            PmSfp.print_difference(duplicate_snapshot, 'Duplicate file(s) from snapshot')
            raise SFPException("There were missing or duplicate RD files in snapshot.")
        info("All the files were found and there were no duplicate files")

    def check_snapshot_content(self, file_list):
        """
        Check snapshot content.
        :param list file_list: List of files.
        """
        snapshot = self.get_snapshot()
        snapshot_filelist = PmSfp.get_namelist_from_snapshot(snapshot)
        snapshot_rd_files = PmSfp.parse_rd_files(snapshot_filelist)
        PmSfp.check_namelist(file_list, snapshot_rd_files)
        self.collect_logs.remove_file(snapshot)

    def count_sfp_params_objects(self):
        """
        Count SFP params objects.
        :return: Amount of SFP params objects.
        """
        sfp_count = 0
        cablink_mos = self.admin.get_managed_objects("CABLINK_R")
        # cablink_mos = self.bts.InfoModel.GetManagedObjectsByClass("CABLINK_R")
        if cablink_mos:
            for cablink_mo in cablink_mos:
                parameter_dict = cablink_mo["parameters"]
                if "firstEndpointLabel" in parameter_dict and str(parameter_dict["firstEndpointLabel"]) == "SFP":
                    sfp_count += 1
                if "secondEndpointLabel" in parameter_dict and str(parameter_dict["secondEndpointLabel"]) == "SFP":
                    sfp_count += 1
        return sfp_count

    @staticmethod
    def parse_filename(file_name, component):
        """
        Parse file name.
        :param str file_name: File name.
        :param str component: Component to parse.
        """
        # RD/PM.BTS-10244.20190829.080000.ANY.xml.gz
        pattern = re.compile(r'(PM|RD).BTS-(?P<bts_id>\d+)\.(?P<date_and_time>.*)\.(LTE|ANY).*')
        match = pattern.match(file_name)
        if match:
            return match.group(component)
        else:
            error("File name couldn't be parsed.")
            raise SFPException("File name couldn't be parsed.")

    def check_file_name(self, rd_file_name):
        """
        Check that file name exists.
        :param str rd_file_name: RD file name.
        """
        if rd_file_name:
            info("Check file name ({})".format(rd_file_name))
            time_from_file = self.parse_filename(rd_file_name, 'date_and_time')
            current_time = datetime.utcnow()
            previous_fifteen_minutes = PmSfp.find_previous_fifteen_minutes(current_time)
            previous_15_without_sec = previous_fifteen_minutes.replace(second=0, microsecond=0)
            correct_file_time = previous_15_without_sec.strftime("%Y%m%d.%H%M%S")
            self.check_file_name_parameters(rd_file_name, time_from_file, correct_file_time)
        else:
            error("No file name to be checked")
            raise SFPException("No file name to be checked.")

    def check_file_name_parameters(self, file_name, datetime_from_file, latest_file_time):
        """
        Check file name parameters.
        :param str file_name: File name.
        :param str datetime_from_file: Date time from file.
        :param str latest_file_time: Latest file time.
        """
        success = self.check_bts_id(file_name)
        success = PmSfp.check_date(datetime_from_file, latest_file_time) and success
        if success:
            info("File name parameters were correct.")
        else:
            raise SFPException("File name parameters were not correct.")

    @staticmethod
    def check_date(datetime_from_file, latest_file_time):
        if datetime_from_file == latest_file_time:
            info("Date time is correct in file")
            return True
        else:
            error("Date time is incorrect in RD file ({}). Correct time is {}".format(datetime_from_file,
                                                                                      latest_file_time))
            return False

    def check_bts_id(self, file_name):
        """
        Check BTS id.
        :param str file_name: File name.
        """
        # correct_bts_id = str(self.bts.Settings.BtsNumber)
        correct_bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        bts_id_from_file = self.parse_filename(file_name, 'bts_id')
        if int(correct_bts_id) == int(bts_id_from_file):
            info("BTS id is correct in file")
            return True
        else:
            error("BTS id is incorrect in RD file: {}. Correct id is {}".format(bts_id_from_file, correct_bts_id))
            return False

    @staticmethod
    def find_previous_fifteen_minutes(current_time):
        """
        Find previous fifteen minutes.
        :param str current_time: Current time in utc.
        """
        expiration_minutes = [0, 15, 30, 45]
        while current_time.minute not in expiration_minutes:
            current_time = current_time - timedelta(minutes=1)
        return current_time

    def get_and_check_sfp_dynamic_data(self, bts_ip="192.168.255.129"):
        """
        This method gets and checks SFP dynamic data.
        :param str bts_ip: IP of BTS, default is 192.168.255.129.
        """
        sfp_monitor_data = self.retrieve_and_store_sfp_data()
        sfp_rd_data, latest_rd_file, all_files = self.retrieve_and_store_rd_pm_data("RD.BTS", sfp_monitor_data, bts_ip)
        correct_amount_of_sfps = self.count_sfp_params_objects()
        self.check_file_name(latest_rd_file)
        PmSfp.check_data(sfp_monitor_data, 'SFP monitor data', correct_amount_of_sfps)
        PmSfp.check_data(sfp_rd_data, 'RD file data', correct_amount_of_sfps)
        self.check_snapshot_content(all_files)
