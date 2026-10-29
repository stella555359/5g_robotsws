"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
from datetime import datetime
from subprocess import check_output
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.sw.dcap.rd import rd
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import UTFLabFailure, InvalidUserInput


class UTF(object):
    """
    This class is called in common_resources.robot if UPGRADE_UTF is given as a TAG. It initializes
    UTF specific libraries and variables and starts DCAP log collections.
    """

    trace_ids = []
    trace_profiles = {}
    utf_duration = -1

    def __init__(self):
        self.dcap_object = rd()
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.bts = BuiltIn().get_library_instance("BTS")
        # self.initialize_utf()

    def initialize_utf(self):
        """
        Initializes UTF specific libraries and variables.
        """
        try:
            info("Initializing UTF specific libraries and variables...")
            self.collect_logs.give_command_to_terminal("utf_lab-controller start")
            info("UTF specific libraries and variables initialized successfully.")
        except Exception as e:
            error(f"Failed to initialize UTF specific libraries and variables. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in initialize_utf, {e.__class__.__name__}:{e}")

    def finalize_utf(self):
        """
        Finalizes UTF specific libraries and variables.
        """
        try:
            info("Finalizing UTF specific libraries and variables...")
            self.collect_logs.give_command_to_terminal("utf_lab-controller stop")
            info("UTF specific libraries and variables finalized successfully.")
        except Exception as e:
            error(f"Failed to finalize UTF specific libraries and variables. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in finalize_utf, {e.__class__.__name__}:{e}")

    def set_profiles_and_start_trace(self, mplaneip, bts_trace_profile_value=None,
                                     enb_trace_profile_value=None, gnb_trace_profile_value=None,
                                     enb_custom_profile_value=None, gnb_custom_profile_value=None,
                                     bts_custom_profile_value=None):
        """
        Set profiles and start trace.

        :param str mplaneip: M-plane IP address
        :param str bts_trace_profile_value: BTS trace profile value
        :param str enb_trace_profile_value: ENB trace profile value
        :param str gnb_trace_profile_value: GNB trace profile value
        :param str enb_custom_profile_value: ENB custom profile value
        :param str gnb_custom_profile_value: GNB custom profile value
        :param str bts_custom_profile_value: BTS custom profile value
        :return: None
        """
        trace_id = self.start_utf_trace(
            [{'host': mplaneip, 'username': 'Nemuadmin', 'password': 'nemuuser', 'port': 443}],
            duration=UTF.utf_duration, gnb_trace_profile=gnb_trace_profile_value,
            enb_trace_profile=enb_trace_profile_value, bts_trace_profile=bts_trace_profile_value,
            gnb_custom_profile=gnb_custom_profile_value, enb_custom_profile=enb_custom_profile_value,
            bts_custom_profile=bts_custom_profile_value, wait_for_activation=True)
        if trace_id:
            UTF.trace_ids.append(str(trace_id["tracer_id"]))

    def check_if_multiple_same_profiles(self, bts_len, enb_len, gnb_len, mplaneip):
        """
        Check if multiple same profiles are given and start traces for them.

        :param int bts_len: Length of bts profiles
        :param int enb_len: Length of enb profiles
        :param int gnb_len: Length of gnb profiles
        :param str mplaneip: M-plane IP address
        :return: None
        """
        params = {'bts_len': bts_len, 'enb_len': enb_len, 'gnb_len': gnb_len}
        max_param = max(params, key=params.get)
        max_value = params[max_param]
        for i in range(1, max_value):
            bts_trace_profile_value = None
            enb_trace_profile_value = None
            gnb_trace_profile_value = None
            if bts_len and (bts_len - i) > 0:
                bts_trace_profile_value = UTF.trace_profiles['bts_trace_profile'][i]
            if enb_len and (enb_len - i) > 0:
                enb_trace_profile_value = UTF.trace_profiles['enb_trace_profile'][i]
            if gnb_len and (gnb_len - i) > 0:
                gnb_trace_profile_value = UTF.trace_profiles['gnb_trace_profile'][i]
            self.set_profiles_and_start_trace(mplaneip, bts_trace_profile_value=bts_trace_profile_value,
                                              enb_trace_profile_value=enb_trace_profile_value,
                                              gnb_trace_profile_value=gnb_trace_profile_value)

    def start_utf_logs(self, port='9443', username=None, password=None, rd_version='dcapv3', secure=True, alias=None):
        """
        Collects UTF specific logs.

        :param str port: Port number for UTF connection
        :param str username: Username for UTF connection
        :param str password: Password for UTF connection
        :param str rd_version: RD version for UTF connection
        :param bool secure: Secure connection flag for UTF connection
        :param str alias: Alias for UTF connection
        :return: None
        """
        try:
            self.initialize_utf()
            BuiltIn().sleep(10)
            info("Connect to UTF lab")
            vm_ip = self.find_vm_ip()
            self.dcap_object.connect_to(host=vm_ip, port=port, username=username, password=password,
                                        rd_version=rd_version, secure=secure, alias=alias)
            info(f"Successfully Connected to UTF lab ({vm_ip})")
            mplaneip = self.add_bts_to_utf()
            self.get_all_bts_profiles()
            info("Start collecting UTF specific logs...")
            if UTF.trace_profiles:
                bts_trace_profile_value = None
                enb_trace_profile_value = None
                gnb_trace_profile_value = None
                enb_custom_profile_value = None
                gnb_custom_profile_value = None
                bts_custom_profile_value = None
                UTF.utf_duration = BuiltIn().get_variable_value("${utf_duration}", default=-1)
                info(f"Trace profiles to be used: {', '.join(f'{k}={v}' for k, v in UTF.trace_profiles.items())}")
                bts_len = 0
                enb_len = 0
                gnb_len = 0
                if 'bts_trace_profile' in UTF.trace_profiles:
                    bts_len = len(UTF.trace_profiles['bts_trace_profile'])
                    bts_trace_profile_value = UTF.trace_profiles['bts_trace_profile'][0]
                if 'enb_trace_profile' in UTF.trace_profiles:
                    enb_len = len(UTF.trace_profiles['enb_trace_profile'])
                    enb_trace_profile_value = UTF.trace_profiles['enb_trace_profile'][0]
                if 'gnb_trace_profile' in UTF.trace_profiles:
                    gnb_len = len(UTF.trace_profiles['gnb_trace_profile'])
                    gnb_trace_profile_value = UTF.trace_profiles['gnb_trace_profile'][0]
                if 'enb_custom_profile' in UTF.trace_profiles:
                    enb_custom_profile_value = UTF.trace_profiles['enb_custom_profile']
                if 'gnb_custom_profile' in UTF.trace_profiles:
                    gnb_custom_profile_value = UTF.trace_profiles['gnb_custom_profile']
                if 'bts_custom_profile' in UTF.trace_profiles:
                    bts_custom_profile_value = UTF.trace_profiles['bts_custom_profile']
                self.set_profiles_and_start_trace(mplaneip, bts_trace_profile_value=bts_trace_profile_value,
                                                  enb_trace_profile_value=enb_trace_profile_value,
                                                  gnb_trace_profile_value=gnb_trace_profile_value,
                                                  enb_custom_profile_value=enb_custom_profile_value,
                                                  gnb_custom_profile_value=gnb_custom_profile_value,
                                                  bts_custom_profile_value=bts_custom_profile_value)
                self.check_if_multiple_same_profiles(bts_len, enb_len, gnb_len, mplaneip)
            else:
                error("No trace profiles has been given to test. Traces not started.")
                raise InvalidUserInput("No trace profiles has been given to test. Traces not started.")
        except Exception as e:
            error(f"Failed to collect UTF specific logs. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in start_utf_logs, {e.__class__.__name__}:{e}")

    @staticmethod
    def check_if_profiles_has_given_profile(profiles, profile, profile_name):
        """
        Check if profiles has given profile.

        :param list profiles: List of profile dictionaries
        :param str profile: Profile to be checked for example bts_trace_profile, enb_trace_profile or gnb_trace_profile
        :param str profile_name: Name or gnb_enb_id of profile to be checked for example 'Call KPI problem' or
                                 'standard-call-kpi'
        :return: True if profile is found, False otherwise
        """
        for pro in profiles:
            if profile_name in pro.values():
                info(f"Profile '{profile_name}' is found in {profile} DCAP profiles.")
                if profile not in UTF.trace_profiles:
                    UTF.trace_profiles[profile] = [profile_name]
                elif profile_name not in UTF.trace_profiles[profile]:
                    UTF.trace_profiles[profile].append(profile_name)
                else:
                    info(f"Profile '{profile_name}' is already added to {profile} trace profiles.")
                return True
        return False

    @staticmethod
    def check_if_str_or_list(bts_profiles, profile_type, profile_name, search_method):
        """
        Check if profile_name is str or list and validate accordingly.

        :param list bts_profiles: List of profile dictionaries
        :param str profile_type: Profile to be checked for example bts_trace_profile, enb_trace_profile or
                                 gnb_trace_profile
        :param str profile_name: Name or gnb_enb_id of profile to be checked for example 'Call KPI problem' or
                                 'standard-call-kpi'
        :param str search_method: Method name where profiles are searched for example get_bts_profiles, get_lte_profiles
                                  or get_5g_profiles
        :return: None
        """
        if isinstance(profile_name, str):
            if not UTF.check_if_profiles_has_given_profile(bts_profiles, profile_type, profile_name):
                error(f"User has given {profile_type}={profile_name}, profile with that name or gnb_enb_id "
                      f"is not found from the output of {search_method}-method")
                raise InvalidUserInput(f"Profile profile_type={profile_name} doesn't exists in DCAP.")
        elif isinstance(profile_name, list):
            profile_ok = True
            for p in profile_name:
                if not UTF.check_if_profiles_has_given_profile(bts_profiles, profile_type, p):
                    error(
                        f"User has given profile {p} for {profile_type}, profile with that name or gnb_enb_id"
                        f" is not found from the output of {search_method}-method")
                    profile_ok = False
            if not profile_ok:
                raise InvalidUserInput(f"Profiles {profile_name} for {profile_type} doesn't exists in DCAP.")

    def get_all_bts_profiles(self):
        """
        Gets all BTS profiles.
        """
        try:
            info("Get BTS profiles...")
            destination_folder = os.path.join(self.logger.log_dir, "utf_logs")
            if not os.path.exists(destination_folder):
                os.makedirs(destination_folder, exist_ok=True)
            profile_file = os.path.join(destination_folder, "utf_profiles.txt")
            bts_profiles = self.dcap_object.get_bts_profiles(timeout=90)
            if BuiltIn().get_variable_value("${bts_trace_profile}", default=False):
                profile_name = BuiltIn().get_variable_value('${bts_trace_profile}')
                UTF.check_if_str_or_list(bts_profiles, "bts_trace_profile", profile_name, "get_bts_profiles")
            if BuiltIn().get_variable_value("${bts_custom_profile}", default=False):
                profile_name = BuiltIn().get_variable_value('${bts_custom_profile}')
                if isinstance(profile_name, str):
                    UTF.trace_profiles["bts_custom_profile"] = [profile_name]
                elif isinstance(profile_name, list):
                    UTF.trace_profiles["bts_custom_profile"] = profile_name
            nr = False
            if self.bts.check_if_5g_environment():
                profiles = self.dcap_object.get_5g_profiles(timeout=90)
                nr = True
                if BuiltIn().get_variable_value("${gnb_trace_profile}", default=False):
                    profile_name = BuiltIn().get_variable_value('${gnb_trace_profile}')
                    UTF.check_if_str_or_list(profiles, "gnb_trace_profile", profile_name, "get_5g_profiles")
                if BuiltIn().get_variable_value("${gnb_custom_profile}", default=False):
                    profile_name = BuiltIn().get_variable_value('${gnb_custom_profile}')
                    if isinstance(profile_name, str):
                        UTF.trace_profiles["gnb_custom_profile"] = [profile_name]
                    elif isinstance(profile_name, list):
                        UTF.trace_profiles["gnb_custom_profile"] = profile_name
            else:
                profiles = self.dcap_object.get_lte_profiles(timeout=90)
                if BuiltIn().get_variable_value("${enb_trace_profile}", default=False):
                    profile_name = BuiltIn().get_variable_value('${enb_trace_profile}')
                    UTF.check_if_str_or_list(profiles, "enb_trace_profile", profile_name, "get_lte_profiles")
                if BuiltIn().get_variable_value("${enb_custom_profile}", default=False):
                    profile_name = BuiltIn().get_variable_value('${enb_custom_profile}')
                    if isinstance(profile_name, str):
                        UTF.trace_profiles["enb_custom_profile"] = [profile_name]
                    elif isinstance(profile_name, list):
                        UTF.trace_profiles["enb_custom_profile"] = profile_name
            if not (os.path.exists(profile_file) and os.path.isfile(profile_file)):
                with open(profile_file, "w") as log:
                    log.write("BTS Profiles:\n\n")
                    log.write(str(bts_profiles))
                    log.write("\n\nLTE profiles:\n\n" if not nr else "\n\n5G profiles:\n\n")
                    log.write(str(profiles))
            info(f"All DCAP profiles found from the BTS are saved to file {profile_file}")
            if not UTF.trace_profiles:
                info("User hasn't offered any trace profiles to test. Adding default profiles to trace profiles.")
                UTF.check_if_str_or_list(bts_profiles, "bts_trace_profile", "dcap-lite-default", "get_bts_profiles")
                if nr:
                    UTF.check_if_str_or_list(profiles, "gnb_trace_profile", "dcap-lite-default", "get_5g_profiles")
                else:
                    UTF.check_if_str_or_list(profiles, "enb_trace_profile", "dcap-lite-default", "get_lte_profiles")
        except Exception as e:
            error(f"Failed to get and set BTS profiles. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in get_all_bts_profiles, {e.__class__.__name__}:{e}")

    def add_bts_to_utf(self):
        """
        Adds BTS to UTF lab.
        """
        try:
            host_already_exists = False
            mplane_ip = self.bts.get_s1_ip()  # bts name is
            all_bts = self.dcap_object.get_all_bts_info()
            if isinstance(all_bts, list):
                for bts in all_bts:
                    if isinstance(bts, dict) and bts['host'] == mplane_ip:
                        self.logger.debug(f"BTS with IP {mplane_ip} already exists in UTF lab, skipping addition.")
                        host_already_exists = True
                        break
            elif isinstance(all_bts, dict) and all_bts['host'] == mplane_ip:
                self.logger.debug(f"BTS with IP {mplane_ip} already exists in UTF lab, skipping addition.")
                host_already_exists = True
            if not host_already_exists:
                info("Add BTS to UTF lab")
                self.dcap_object.create_bts(mplane_ip, port='443', username='Nemuadmin', password='nemuuser',
                                            bts_alias=self.bts.bts_name, connection=None, timeout=90)
                info(f"BTS {self.bts.bts_name} ({mplane_ip}) added successfully to UTF lab.")
                all_info = self.dcap_object.get_all_bts_info()
                destination_folder = os.path.join(self.logger.log_dir, "utf_logs")
                if not os.path.exists(destination_folder):
                    os.makedirs(destination_folder, exist_ok=True)
                all_bts_info = os.path.join(destination_folder, "all_bts_info_in_utf_lab.txt")
                with open(all_bts_info, "w") as log:
                    log.write("All BTS info in UTF lab:\n\n")
                    log.write(str(all_info))
                info(f"All BTS in UTF lab information saved to file: {all_bts_info}")
            return mplane_ip
        except Exception as e:
            error(f"Failed to add BTS to UTF lab. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in add_bts_to_utf, {e.__class__.__name__}:{e}")

    def find_vm_ip(self):
        """
        Find VM IP address.

        :return: VM IP address as string
        """
        try:
            vm_ip = ""
            output = check_output(r"/sbin/ifconfig eth0 | grep 'inet' | grep -v 'inet6'", shell=True)
            self.logger.debug(f"Output: {output}")
            pattern = re.compile(r".*inet\s+(?P<ip>\d+\.\d+\.\d+\.\d+)\s+netmask.*")
            match = pattern.match(str(output))
            if match:
                vm_ip = str(match.group("ip"))
            else:
                error(f"Could not find VM IP from {output}")
            return vm_ip
        except Exception as e:
            error(f"Failed to find VM IP. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in find_vm_ip, {e.__class__.__name__}:{e}")

    def start_utf_trace(self, bts_list, wait_for_activation=True, **kwargs):
        """
        Start UTF trace.

        :param bts_list: List of BTS connection parameters
        :param wait_for_activation: Boolean to wait for activation
        """
        try:
            info("Starting traces...")
            trace_id = self.dcap_object.start_trace(bts=bts_list, wait_for_activation=wait_for_activation, **kwargs)
            info(f"UTF logs started successfully. Trace_id: {trace_id}")
            return trace_id
        except Exception as e:
            error(f"Failed to start UTF logs. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in start_utf_logs, {e.__class__.__name__}:{e}")

    def stop_trace_and_get_logs(self, trace_id=None):
        """
        Stop trace and get logs

        :param str trace_id: Id of trace to be stopped, if none is given then all traces are stopped
        :return: dict with operation information
        """
        try:
            if UTF.utf_duration == -1:
                self.stop_utf_trace(trace_id)
            else:
                info(f"UTF trace duration is given: {UTF.utf_duration} minutes. Traces are stopped automatically.")
            BuiltIn().sleep(5)  # wait for trace to stop properly
            self.get_utf_logs(trace_id)
        except Exception as e:
            error(f"Failed to stop UTF logs. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in stop_trace_and_get_logs, {e.__class__.__name__}:{e}")

    def get_utf_logs(self, trace_id=None, destination_folder=None):
        """
        Get UTF logs.

        :param str trace_id: (OPTIONAL) Id of trace to get logs from
        :param str destination_folder: (OPTIONAL) Folder where logs are saved
        :return: Path to saved logs
        """
        try:
            info("Getting UTF logs...")
            if destination_folder and not os.path.exists(destination_folder):
                os.makedirs(destination_folder, exist_ok=True)
            elif not destination_folder:
                destination_folder = os.path.join(self.logger.log_dir, "utf_logs")
                if not os.path.exists(destination_folder):
                    os.makedirs(destination_folder, exist_ok=True)
            time_for_log = datetime.now().strftime("%Y%m%d_%H%M%S")
            log_path = self.dcap_object.get_results(timeout=600, result_id=trace_id, target_dir=destination_folder,
                                                    target_file_name=f"UTFLab_Logs_{time_for_log}")
            info(f"UTF logs retrieved successfully. Logs saved at: {log_path}")
            return log_path
        except Exception as e:
            error(f"Failed to get UTF logs. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in get_utf_logs, {e.__class__.__name__}:{e}")

    def stop_utf_trace(self, trace_id=None):
        """
        Stop UTF trace.

        :param str trace_id: Id of trace to be stopped, if none is given then all traces are stopped
        """
        try:
            destination_folder = os.path.join(self.logger.log_dir, "utf_logs")
            if not os.path.exists(destination_folder):
                os.makedirs(destination_folder, exist_ok=True)
            result_output = os.path.join(destination_folder, "utf_result_output.txt")
            with open(result_output, "w") as log:
                log.write("\nStop UTF trace results:\n\n")
            info("Stopping traces...")
            if trace_id is None:
                if UTF.trace_ids:
                    for trace_i in UTF.trace_ids:
                        r = self.dcap_object.stop_trace(trace_id=trace_i)
                        # info(f"!!!!  Stopped trace {trace_i} with result:\n{r}")
                        with open(result_output, "a") as log:
                            log.write(f"\n\nTrace {trace_i} results:\n\n")
                            log.write(str(r))
                UTF.trace_ids = []
            else:
                result = self.dcap_object.stop_trace(trace_id=trace_id)
                # info(f"!!!! Stopped trace {trace_id} with result: {result}")
                UTF.trace_ids.remove(trace_id)
                with open(result_output, "a") as log:
                    log.write(f"\n\nTrace {trace_id} results:\n\n")
                    log.write(str(result))
        except Exception as e:
            error(f"Failed to stop UTF traces. {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise UTFLabFailure(f"Problems in stop_utf_trace, {e.__class__.__name__}:{e}")
