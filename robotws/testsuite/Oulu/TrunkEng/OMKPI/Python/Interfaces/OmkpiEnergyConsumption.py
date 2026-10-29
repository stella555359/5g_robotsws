"""
:author:  Valtteri Lamberg
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import gzip
import os
import pytz
import xml.etree.ElementTree as Etr
from datetime import datetime, timedelta
from collections import defaultdict
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import (CounterDoesNotExist, CounterNotInLimits,
                                                                       PMFileDoesntExist, PMFileExist)
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error


class PmMeasurement(object):

    def __init__(self):
        self.name = ""
        self.dns = {}
        self.counter_tags = []
        self.counters = {}
        self.interval = ""
        self.start_time = ""


class OmkpiEnergyConsumption(object):

    all_measurements = []

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.smod_lib = BuiltIn().get_library_instance("SMODS")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.all_measurements = []
        self.radio_counters = defaultdict(dict)

    def print_to_textfile_and_report(self, meas, counter, output_file, fsm, radio, serial, pc, reference_tl, limits):
        success = True
        limit_success = True
        init_text = "Energy consumption"
        if counter in meas.counters:
            value = int(meas.counters[counter])
            if fsm:
                init_text = "{init} ({fsm})".format(init=init_text, fsm=fsm)
            if radio:
                init_text = "{init} ({radio} {serial} {pc})".format(init=init_text, radio=radio, serial=serial, pc=pc)
                # FXDB(1.1.1.1)(1M162062576) -> FXDB(1M162062576)
                self.radio_counters[counter][f'{radio.partition("(")[0]}({serial})'] = value
            output_file.write("{init}: {counter}: {value}\n".format(init=init_text, counter=counter, value=value))
            BuiltIn().run_keyword('taf.sw.reporting_portal.report_kpi_results',
                                  "",  # target
                                  "{init}: {counter}".format(init=init_text, counter=counter),  # target
                                  'True',  # visible_to_db
                                  str(value),  # value
                                  "",  # kpi_type
                                  str(reference_tl),  # description
                                  "OMKPI",  # category
                                  str(int),  # unit
                                  "",  # kpi_id
                                  "")  # variant
            info("{init}: {counter}: {value}".format(init=init_text, counter=counter, value=value))
            if limits:
                limit_success = self.check_counter_against_limit(counter, value) and limit_success
        else:
            error("{} doesn't exist in PM file".format(counter))
            success = False
        if not limit_success:
            raise CounterNotInLimits
        return success

    @staticmethod
    def check_counter_against_limit(counter, value):
        limit_var = f"${{{counter.upper()}_LIMIT}}"
        limit = BuiltIn().get_variable_value(limit_var, default=None)
        if limit is not None:
            limit_int = int(limit)
            if value > limit_int:
                error(f"{counter} counter value {value} exceeds limit of {limit_int}")
                return False
            else:
                info(f"{counter} counter value {value} is within limit of {limit_int}")
                return True
        return True

    def check_and_report_counters(self, counter_list, meas, output_file, reference_tl, fsm="", radio="", serial="",
                                  pc="", limits=False):
        success = True
        for counter in counter_list:
            success = self.print_to_textfile_and_report(meas, counter, output_file, fsm, radio, serial, pc,
                                                        reference_tl, limits) and success
        return success

    def link_rmods_to_objects(self, user_given_rmods):
        rmods = []
        for user_rmod in user_given_rmods:
            rmods.append(self.bts.get_rmod_object_from_user_given_values(user_rmod))
        return rmods

    @staticmethod
    def find_radio_via_distname(dn, rmods):
        for rmod in rmods:
            if "PLMN-PLMN/{}".format(rmod.scf_dist_name) == dn:
                return rmod

    def report_m4000x_counters(self, user_given_rmods, average_list, reference_testline=""):
        success = False
        rmods = ""
        rmod_plmn_distnames = None
        if user_given_rmods:
            rmods = self.link_rmods_to_objects(user_given_rmods)
            rmod_plmn_distnames = ["PLMN-PLMN/{}".format(rmod.scf_dist_name) for rmod in rmods]
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        log_name = f'Counters_{timestamp}_{self.bts.active_sw}.txt'
        counter_file = os.path.join(os.path.join(self.logger.log_dir, log_name))
        with open(counter_file, 'w') as output_file:
            for meas in average_list:
                if meas.name == "SBTS_Energy_Consumption":
                    success = self.check_and_report_counters(["M40002C0", "M40002C1", "M40002C2"], meas,
                                                             output_file, reference_testline, limits=True)
                elif meas.name == "SBTS_SM_Energy_Monitoring":
                    fsm = self.smod_lib.get_master_smod_productname()
                    success = self.check_and_report_counters(
                        ["M40004C0", "M40004C1", "M40004C2", "M40004C3", "M40004C4", "M40004C5"], meas, output_file,
                        reference_testline, fsm=fsm) and success

                elif rmods and meas.name == "SBTS_RFM_Energy_Monitoring" and meas.dns[
                     'network_element'] in rmod_plmn_distnames:
                    rmod = self.find_radio_via_distname(meas.dns['network_element'], rmods)
                    success = self.check_and_report_counters(
                        ["M40003C0", "M40003C1", "M40003C2", "M40003C3", "M40003C4", "M40003C5"], meas,
                        output_file, reference_testline, radio=rmod.name, serial=rmod.serial_number,
                        pc=rmod.product_code) and success
            if self.radio_counters:
                self.write_radio_counters_to_file(output_file)
        if not success:
            raise CounterDoesNotExist

    def write_radio_counters_to_file(self, output_file):
        output_file.write("\nRadio counters formatted for result excel:\n")
        info("Radio counters formatted for result excel:")
        for counter, radios_and_values in self.radio_counters.items():
            output_file.write(f"{counter}\n")
            info(f"{counter}")
            for radio, value in radios_and_values.items():
                output_file.write(f"{radio}: {value}\n")
                info(f"{radio}: {value}")

    @staticmethod
    def collect_all_counters(counters):
        counters_dict = defaultdict(list)
        for meas in counters:
            for counter, value in meas.counters.items():
                if "SBTS_RFM_Energy_Monitoring" in meas.name:
                    counter = "{}-{}".format(meas.dns["network_element"], counter)
                counters_dict[counter].append(int(value))
        return counters_dict

    def set_values_to_list(self, average_values):
        average_list = []
        temp_list = []
        for meas in self.all_measurements:
            if (meas.name, meas.dns["network_element"]) not in temp_list:
                for counter, value in average_values.items():
                    if meas.name == "SBTS_RFM_Energy_Monitoring" and meas.dns["network_element"] in counter:
                        counter = counter.split("-")[-1]
                    if len(counter) == 8:
                        meas.counters[counter] = value
                average_list.append(meas)
                temp_list.append((meas.name, meas.dns["network_element"]))
        return average_list

    def calculate_average_values(self):
        counters_dict = self.collect_all_counters(self.all_measurements)
        self.logger.debug("Counters: {}".format(counters_dict))
        average_values = {counter: sum(value) / len(value) for counter, value in counters_dict.items()}
        average_measurements_list = self.set_values_to_list(average_values)
        return average_measurements_list

    def get_energy_consumption_counters(self):
        latest_pm_file = self.download_latest_file()
        parsed_pm_file = self.parse_file(latest_pm_file)
        pm_parameters = self.collect_pmfile_parameters(pm_root=parsed_pm_file, iot_cell=0)
        for meas in pm_parameters:
            if meas.name in ("SBTS_Energy_Consumption", "SBTS_RFM_Energy_Monitoring", "SBTS_SM_Energy_Monitoring"):
                self.all_measurements.append(meas)
        info("All energy consumption counters were collected from {}".format(latest_pm_file))

    def wait_for_interval(self, interval=15, next_interval=True, delta=0, wait_after="120s", only_return=False):
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

    def collect_pmfile_parameters(self, pm_root, iot_cell):
        pmfile_parameters = []
        for pm_setup in pm_root.findall(r".//PMSetup"):
            interval = pm_setup.attrib['interval']
            start_time = pm_setup.attrib['startTime']
            pmfile_parameters += [self._fill_pm_parameters(pmmo_result, interval, start_time, iot_cell)
                                  for pmmo_result in pm_setup.findall(r".//PMMOResult")]
        return [x for x in pmfile_parameters if x is not None]

    def _fill_pm_parameters(self, pmmo_result, interval, start_time, iot_cell):
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
            meas = self.energy_consumption_counters(meas, counter)
            meas.counter_tags.append(counter.tag)
        return meas

    @staticmethod
    def energy_consumption_counters(meas, counter):
        if meas.name in ("SBTS_Energy_Consumption", "SBTS_RFM_Energy_Monitoring", "SBTS_SM_Energy_Monitoring"):
            meas.counters[counter.tag] = counter.text
        return meas

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
