import datetime
import pytz
import os
import re
import subprocess
import socket
import paramiko
import importlib.util
import taf.transport.ssh as ssh
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.transport.ssh.exceptions import CommandExecutionError, ConnectFailedError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (
    NoReplyToPing, PingToIpNotLost, ScriptIssue, EnvironmentIssue, BTSConnectionFailure, CellDownWithoutActiveAlarm,
    TimeOutWhenDownloadingFromArtifactory, ExpectedSwBuildIsNotActive, BuildNotFoundFromArtifactory, NoFronthaulSwitch,
    SizeOfSwBuildIsUnexpected, InvalidUserInput, CellsDown, UnitResetFailed, FhsSoftwareUpdateFailure,
    WrongRadioUptimes, ErrorFromAdmin)


class BTS:
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'

    """
    BTS is a collection of BTS information found with its methods or in other classes.
    A variable should be added here if the variable's value is used in more than one file.

    BTS is called in common_resources.robot. If the class is already initiated once, import robot BuiltIn
        >> from robot.libraries.BuiltIn import BuiltIn
    and call with
        >> BuiltIn().get_library_instance("BTS")
    """

    active_partition = None
    active_sw = None
    antennae = []
    bbmods = []
    bts_info = None
    bts_info_remote = None
    bts_side_is_right = False
    cells = None
    cells_remote = None
    cloud_env = False
    current_status = {}
    expected_status = {}
    passive_sw = None
    radios = []
    radios_remote = []
    right_side_mods = []
    _rmod_cell_links = {}
    smods = []
    side = "1"
    fullrack = False
    path_to_ute_env_init = ""
    bts_name = ""
    bts_name_remote = ""
    bbmods_connected_to_rmods = {}
    tl = None
    step = 0
    position_in_subrack = ""
    rmod_ant_direction_and_cell = {}
    admin_parameters_for_all_bts = None
    admin_parameters_for_all_bts_remote = None
    default_smod_ip = "192.168.255.129"

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.antenna_lib = BuiltIn().get_library_instance("ANTENNAE")
        self.cell_operations = BuiltIn().get_library_instance("CELLS")
        self.bbmod_lib = BuiltIn().get_library_instance("BBMODS")
        self.rmod_lib = BuiltIn().get_library_instance("RMODS")
        self.smod_lib = BuiltIn().get_library_instance("SMODS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = BuiltIn().get_library_instance("SCF")
        self.ssh = BuiltIn().get_library_instance("SSH")

        self.cell_resources = None
        self.path_to_bts_sw_zip = None
        self.start_time = None
        self.collect_logs = None
        self.get_tl_param()

    @property
    def rmod_cell_links(self):
        return BTS._rmod_cell_links

    @rmod_cell_links.setter
    def rmod_cell_links(self, rmod_cell_links):
        BTS._rmod_cell_links = rmod_cell_links

    def check_if_ute_cloud_env(self):
        """
        Check if UTE Cloud Environment or local environment.
        If UTE Env, change self.cloud_env to True.
        """
        if os.name != "nt" and os.path.exists(self.get_path_of_ute_init_file()):
            self.logger.debug("A UTE Cloud Environment.")
            BTS.cloud_env = True
        else:
            self.logger.debug("Not a UTE Cloud Environment.")

    @staticmethod
    def _check_if_init_file_is_valid(path_to_init_file):
        """
        Check if init file is valid
        """
        if os.path.exists(path_to_init_file):
            if os.path.isfile(path_to_init_file):
                if os.path.getsize(path_to_init_file) < 50:
                    print(f"File {path_to_init_file} is not suitable for parsing TL information, size of it is less "
                          f"than 50 bytes")
                    return False
                else:
                    return True
            else:
                print(f"{path_to_init_file} is not a file")
        else:
            print(f"{path_to_init_file} doesn't exists")
        return False

    def get_path_of_ute_init_file(self):
        """
        Return path of __init__.py file if there is one.
        """
        hostname = str(socket.gethostname()).replace('-', '_')
        self.logger.debug(f"Call of get_path_of_ute_init_file Hostname: {socket.gethostname()}")
        print(f"Call of get_path_of_ute_init_file Hostname: {socket.gethostname()}")
        if os.path.exists("/home/ute/config/TLVD/TAF") and BTS._check_if_init_file_is_valid(
                "/home/ute/config/TLVD/TAF/__init__.py"):  # 4G
            BTS.path_to_ute_env_init = "/home/ute/config/TLVD/TAF/__init__.py"
        elif os.path.exists("/home/ute/testline_init_results/retry_2") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_2/execution/configs/testline_configuration/{hostname}/"
                f"__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/retry_2/execution/configs/"
                                        f"testline_configuration/{hostname}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/retry_2") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_2/execution/configs/testline_configuration/TL_{hostname}/"
                f"__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/retry_2/execution/configs/"
                                        f"testline_configuration/TL_{hostname}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/retry_2") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_2/execution/configs/testline_configuration/TL_{hostname[:-2]}/"
                f"__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/retry_2/execution/configs/"
                                        f"testline_configuration/TL_{hostname[:-2]}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/retry_1") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_1/execution/configs/testline_configuration/{hostname}/"
                f"__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/retry_1/execution/configs/"
                                        f"testline_configuration/{hostname}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/retry_1") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_1/execution/configs/testline_configuration/TL_{hostname}/"
                f"__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/retry_1/execution/configs/"
                                        f"testline_configuration/TL_{hostname}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/retry_1") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_1/execution/configs/testline_configuration/TL_{hostname[:-2]}/"
                f"__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/retry_1/execution/configs/"
                                        f"testline_configuration/TL_{hostname[:-2]}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/retry_1") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/retry_1/execution/configs/testline_configuration/__init__.py"):
            BTS.path_to_ute_env_init = ("/home/ute/testline_init_results/retry_1/execution/configs/"
                                        "testline_configuration/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/execution") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/execution/configs/testline_configuration/{hostname}/__init__.py"):
            BTS.path_to_ute_env_init = \
                f"/home/ute/testline_init_results/execution/configs/testline_configuration/{hostname}/__init__.py"
        elif os.path.exists("/home/ute/testline_init_results/execution") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/execution/configs/testline_configuration/TL_{hostname}/__init__.py"):
            BTS.path_to_ute_env_init = \
                f"/home/ute/testline_init_results/execution/configs/testline_configuration/TL_{hostname}/__init__.py"
        elif os.path.exists("/home/ute/testline_init_results/execution") and BTS._check_if_init_file_is_valid(
                f"/home/ute/testline_init_results/execution/configs/testline_configuration/"
                f"TL_{hostname[:-2]}/__init__.py"):
            BTS.path_to_ute_env_init = (f"/home/ute/testline_init_results/execution/configs/testline_configuration/"
                                        f"TL_{hostname[:-2]}/__init__.py")
        elif os.path.exists("/home/ute/testline_init_results/execution") and BTS._check_if_init_file_is_valid(
                "/home/ute/testline_init_results/execution/configs/testline_configuration/__init__.py"):
            BTS.path_to_ute_env_init = \
                "/home/ute/testline_init_results/execution/configs/testline_configuration/__init__.py"
        elif os.path.exists("/home/ute/.ute-ca/executions"):  # 5G common agent
            tl_dir = sorted(os.listdir("/home/ute/.ute-ca/executions"), reverse=True)
            print(f"5G common agent: {tl_dir}")
            self.logger.debug("Folders in /home/ute/.ute-ca/executions: {}".format(tl_dir))
            if BTS._check_if_init_file_is_valid(
                    "/home/ute/.ute-ca/executions/{}/configs/testline_configuration/__init__.py".format(tl_dir[0])):
                BTS.path_to_ute_env_init = (
                    "/home/ute/.ute-ca/executions/{}/configs/testline_configuration/__init__.py".format(tl_dir[0]))
        elif os.path.exists("/home/ute/output/config"):  # 4G and some 5G
            tl_dir = os.listdir("/home/ute/output/config")
            self.logger.debug("Folders in /home/ute/output/config: {}".format(tl_dir))
            if BTS._check_if_init_file_is_valid("/home/ute/output/config/{}/__init__.py".format(tl_dir[0])):
                BTS.path_to_ute_env_init = "/home/ute/output/config/{}/__init__.py".format(tl_dir[0])
        elif (os.path.exists("/home/ute/ute_ca_logs/execution/configs/testline_configuration") and
              BTS._check_if_init_file_is_valid(
                  "/home/ute/ute_ca_logs/execution/configs/testline_configuration/__init__.py")):
            BTS.path_to_ute_env_init = "/home/ute/ute_ca_logs/execution/configs/testline_configuration/__init__.py"
        elif (os.path.exists(f"/home/ute/testline_configuration/{hostname}") and
              BTS._check_if_init_file_is_valid("/home/ute/testline_configuration/{hostname}/__init__.py")):
            BTS.path_to_ute_env_init = f"/home/ute/testline_configuration/{hostname}/__init__.py"
        else:
            self.logger.debug("Path /home/ute/config/TLVD/TAF nor /home/ute/testline_init_results/retry_1 nor "
                              "/home/ute/testline_init_results/execution nor /home/ute/output/config nor "
                              "/home/ute/.ute-ca/executions/ nor "
                              "/home/ute/ute_ca_logs/execution/configs/testline_configuration "
                              "nor /home/ute/testline_configuration/{BTS.bts_name} does not exist -> this "
                              "is not a cloud environment or some changes were made to the cloud agents")
            print(f"Path /home/ute/config/TLVD/TAF nor /home/ute/testline_init_results/retry_1 nor "
                  f"/home/ute/testline_init_results/execution nor /home/ute/output/config nor "
                  f"/home/ute/.ute-ca/executions/ nor /home/ute/ute_ca_logs/execution/configs/testline_configuration "
                  f"nor /home/ute/testline_configuration/{BTS.bts_name} does not exist -> this is not a cloud "
                  f"environment or some changes were made to the cloud agents")
            return ""
        self.logger.debug("Path to ute environment init-file is {}".format(BTS.path_to_ute_env_init))
        return BTS.path_to_ute_env_init

    def get_tl_param(self):
        self.check_if_ute_cloud_env()
        if BTS.cloud_env:
            self.get_path_of_ute_init_file()
        path = BTS.path_to_ute_env_init if BTS.cloud_env else "/home/ute/local_configuration/__init__.py"
        info("Path to init -file: '{}'".format(path))
        if os.path.exists(path):
            module_name = "__init__"
            spec = importlib.util.spec_from_file_location(module_name, path)
            init_module = importlib.util.module_from_spec(spec)
            spec.loader.exec_module(init_module)
            BTS.tl = init_module.tl
            if not BuiltIn().get_variable_value("${tl}") and BTS.tl:
                info(f"Set BTS.tl parameter to ${{tl}}")
                BuiltIn().set_global_variable("${tl}", BTS.tl)
        else:
            warning("Path to init does not exist, use tl -parameter from init in git.")
            BTS.tl = BuiltIn().get_variable_value("${tl}")
        if not BTS.tl:
            warning("Problems finding tl -parameter.")

    @staticmethod
    def find_ute_tl_name():
        """
        Finds the UTE testline name

        :return: UTE testline name
        """
        pattern = re.compile(r".*(?P<testline>\d+\-\d+\-\w+\d+(\-\d+|)).*")
        output = subprocess.check_output(r"cat /etc/hosts", shell=True)
        match = pattern.match(str(output))
        if match:
            return match.group("testline").replace("-", "_")
        warning("Could not find UTE testline name for SCOUT reporting")
        return ""

    def get_mplane_ip_from_tl_param(self):
        """
        Get mplane IP from tl parameter. This is done by checking the gnbs and enbs in tl parameter and getting the
        mplane IP.
        """
        mplane_ip = ""
        try:
            if self.tl.enbs:
                for unit_obj in self.tl.enbs:
                    mplane_ip = unit_obj.oam_ip.v4
                    self.logger.debug(f"Found mplane IP {mplane_ip} from enb object in tl parameter.")
            if self.tl.gnbs:
                for unit_obj in self.tl.gnbs:
                    if unit_obj.cu.oam_ssh_connection_details.addr == "192.168.255.129":  # local master
                        mplane_ip = unit_obj.cu.backhaul_site_oam_ip.v4
                        self.logger.debug(f"Found mplane IP {mplane_ip} from gnb object in tl parameter.")
                        break
            if not mplane_ip:
                error("Could not find mplane IP from tl -object.")
                return ""
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            error(f"Error while getting mplane IP from tl parameter: {e.__class__.__name__}:{e}")
            return ""
        return mplane_ip.split("/")[0] if mplane_ip and "/" in mplane_ip else mplane_ip

    def update_sw_information(self, print_to_eventlog=True, retry=0):
        """
        Find active and passive SW, update both to self.active_sw and self.passive_sw respectively.
        """
        try:
            sws = self.admin.get_software_info(timeout=60)
            BTS.active_sw = sws["Active SW version"]
            BTS.passive_sw = sws["Passive SW version"]
            if print_to_eventlog:
                info("Active SW: {}".format(BTS.active_sw))
                info("Passive SW: {}".format(BTS.passive_sw))
            else:
                print("Active SW: {}".format(BTS.active_sw))
                print("Passive SW: {}".format(BTS.passive_sw))
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
                AliasInUse) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            if ("ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb)
                    and retry == 0):
                info("Unable topdate active and passive software information, because of session invalidation."
                     "Set test to fail so we will have logs about the issue and restart admin connection.")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                self.logger.debug(tb)
                self.reset_admin_connection(admin="default")
                self.update_sw_information(print_to_eventlog=True, retry=1)
            else:
                error(f"Unable to update active and passive software information. {admin_error.__class__.__name__}:"
                      f"{admin_error} was raised.")
                info(f"{tb}")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            BTS.active_sw = "Unknown active sw build, no admin connection"
            BTS.passive_sw = "Unknown passive sw build, no admin connection"
            raise BTSConnectionFailure

    @staticmethod
    def print_sw_versions_to_eventlog():
        """ Prints active and passive SW versions to eventloop. """
        info("Active SW: {}".format(BTS.active_sw))
        info("Passive SW: {}".format(BTS.passive_sw))

    def site_is_fullrack(self):
        """
        Checks if a site is fullrack or not. This is done by checking the number of SMODs.

        :return bool: Site is fullrack if returns True.
        """
        if len(self.admin.get_ids_for_all("SMOD")) > 1:
            self.logger.debug("Found {} SMODs in environment, site is fullrack (number of SMODs is "
                              "more than 1).".format(len(self.admin.get_ids_for_all("SMOD"))))
            return True
        self.logger.debug("Found {} SMOD in environment, site is not fullrack (number of SMODs is 1).".format(
            len(self.admin.get_ids_for_all("SMOD"))))
        return False

    def get_bts_side(self):
        """
        Get side of BTS with ddal ssh command.
        """
        side = r"\d+" if BTS.fullrack else "1"
        all_suite_variables = BuiltIn().get_variables()
        if '${RFS}' in all_suite_variables and all_suite_variables['${RFS}'] is True:
            side = r"\d+"
        else:
            if not BTS.fullrack:
                command = "ddal -s ddal_sysinfo_module_get_domain_id 0"
                output = self.ssh.send_command_to_smod_by_ssh(command, return_output=True, print_to_eventlog=False,
                                                              name_for_log="to_smod_get_side")
                if output:
                    if "dimd=1" in output or "dmid=1" in output:
                        side = "1"
                    elif "dimd=2" in output or "dmid=2" in output:
                        side = "4"
                    elif "dimd=3" in output or "dmid=3" in output:
                        side = "2"
                    elif "dimd=4" in output or "dmid=4" in output:
                        side = "3"
        self.logger.debug(f"Side of bts is: {side}")
        if side == "4":
            BTS.bts_side_is_right = True
        return side

    def get_bts_configs(self):
        """
        Get self.bbmods, self.radios and self.cells from site configuration.
        """
        if BTS.default_smod_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                BTS.default_smod_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
        self.check_if_ute_cloud_env()
        BTS.fullrack = self.site_is_fullrack()
        BTS.side = self.get_bts_side()
        info(rf"BTS side is {BTS.side} (4=right, 1,2,3=left, \d+=fullrack/RFS)")
        BTS.bts_info = self.admin.get_bts_info(detailed_output=True)
        BTS.bts_name = self.get_parameter_value_from_bts_info("btsName")
        info("btsName: {}".format(BTS.bts_name))
        BTS.position_in_subrack = self.smod_lib.check_if_position_in_subrack(BTS.fullrack)
        BTS.smods = self.smod_lib.get_smod_connections()
        info("Found SMOD(s):")
        for smod in BTS.smods:
            info(f"{smod.name}, {smod.dist_name}, {smod.r_dist_name}, {smod.serial_number}, master: {smod.master}")
        BTS.bbmods = self.bbmod_lib.get_bbmod_connections()
        info("Found BBMODs: ")
        for bbmod in BTS.bbmods:
            info(f"{bbmod.name}, {bbmod.dist_name}, {bbmod.l_dist_name}, {bbmod.serial_nmbr}, {bbmod.scf_dist_name}, "
                 f"{bbmod.hw_path}")
        BTS.radios = self.rmod_lib.get_radio_connections()
        self.rmod_lib.update_bbmods_for_chained_rmods_to_rci()
        self.update_hw_path_for_radios()
        self.rmod_lib.check_if_shared_radios_and_not_master()
        info("Found radios: ")
        for radio in BTS.radios:
            info(f"{radio.name}, {radio.dist_name}, {radio.serial_number}, {radio.scf_dist_name}, {radio.hw_path},"
                 f"multi-fibre connections: {radio.multi_fibre_connection}, master: {radio.master_radio}")
        if len(BTS.radios) != len(self.admin.get_parameters_for_all("RMOD")):
            error("Script finds too many radios. Contact script developers.")
            raise EnvironmentIssue("Script finds too many radios. Contact script developers.")
        BTS.cells = self.cell_operations.get_all_cells()
        info(f"Cells: {list(BTS.cells.keys())}")
        rfs_envi = BuiltIn().get_variable_value("${RFS}")
        if rfs_envi and rfs_envi in (True, "true", "True", "TRUE"):  # RFS environment
            BTS.bts_info_remote = self.admin.get_bts_info(connection="remote", detailed_output=True)
            BTS.bts_name_remote = self.get_parameter_value_from_bts_info("btsName", remote=True)
            BTS.cells_remote = self.cell_operations.get_all_cells("remote")
            info(f"Cells of not tested side: {list(BTS.cells_remote.keys())}")
            BTS.bbmods_remote = self.bbmod_lib.get_bbmod_connections(remote=True)
            info("BBMODs of not tested side:")
            for bbmod in BTS.bbmods_remote:
                info(f"{bbmod.name}, {bbmod.dist_name}, {bbmod.serial_nmbr}")
            BTS.radios_remote = self.rmod_lib.get_radio_connections(remote=True)
            self.rmod_lib.check_if_shared_radios_and_not_master(remote=True)
            info("Radios of not tested side:")
            for radio in BTS.radios_remote:
                for rmod in BTS.radios:
                    if radio.serial_number == rmod.serial_number:
                        radio.shared_radio = rmod.name
                        rmod.shared_radio = radio.name
                        break
                info(f"{radio.name}, {radio.dist_name}, {radio.serial_number}, {radio.scf_dist_name}, {radio.hw_path},"
                     f"multi-fibre connections: {radio.multi_fibre_connection}, master: {radio.master_radio}, "
                     f"shared_radio: {radio.shared_radio}")

        BTS.antennae = self.antenna_lib.get_antenna_connections()
        info("Found antennae: ")
        for antenna in BTS.antennae:
            info(f"{antenna.label}: {antenna.dist_name} ({antenna.direction}) {antenna.runtime_dist_name}\n"
                 f"connected_radios: {antenna.connected_radios}\nconnected_cells: {antenna.connected_cells}")

        self.get_rmods_connected_to_bbmods()
        self.get_tl_param()
        info("Found tl parameter: {}".format(BTS.tl))

    def update_rmod_information(self):
        """Gets radio information from the BTS and updates it. This is needed because IP of radio is dynamic and may
        change in BTS resets."""
        BTS.radios = self.rmod_lib.get_radio_connections()
        self.rmod_lib.update_bbmods_for_chained_rmods_to_rci()
        self.update_hw_path_for_radios()
        info("Updated radio information: ")
        for radio in BTS.radios:
            info(f"{radio.name}, {radio.dist_name}, {radio.serial_number}, {radio.scf_dist_name}, {radio.hw_path}")

    def update_hw_path_for_bbmods(self, print_to_eventlog=False):
        """
        This method is for updating hw_path attribute. This is needed because realtime view values may change during
        resets.

        :param bool print_to_eventlog: Print changed value to eventlog. Default is False
        """
        BTS.smods = self.smod_lib.get_smod_connections()  # update smod objects to ensure R number is correct
        for bbmod in BTS.bbmods:
            hw_path = self.bbmod_lib.get_hw_path(bbmod.name, bbmod.dist_name, bbmod.l_dist_name)
            bbmod.hw_path = hw_path
            if print_to_eventlog:
                info(f"Updated_hw_path: {hw_path} for {bbmod.name}")

    def update_hw_path_for_radios(self, print_to_eventlog=False):
        """
        This method is for updating hw_path attribute. This is needed because realtime view values may change during
        resets.

        :param bool print_to_eventlog: Print changed value to eventlog. Default is False
        """
        for radio in BTS.radios:
            hw_path = self.rmod_lib.get_hw_path(radio.name, radio.dist_name)
            radio.hw_path = hw_path
            if print_to_eventlog:
                info(f"Updated_hw_path: {hw_path} for {radio.name}")

    def update_bbmod_and_radio_information(self):
        """This is needed after resets, because runtime names may change during a reset."""
        # clear this variable so if information is later collected it will be from post reset situation
        BTS.admin_parameters_for_all_bts = None
        BTS.bbmods = self.bbmod_lib.get_bbmod_connections()
        info("Updated BBMODs: ")
        for bbmod in BTS.bbmods:
            info("{}, {}, {}, {}, {}".format(
                bbmod.name, bbmod.dist_name, bbmod.serial_nmbr, bbmod.scf_dist_name, bbmod.hw_path))
        BTS.radios = self.rmod_lib.get_radio_connections()
        self.rmod_lib.update_bbmods_for_chained_rmods_to_rci()
        self.update_hw_path_for_radios()
        info("Updated radios: ")
        for radio in BTS.radios:
            info(f"{radio.name}, {radio.dist_name}, {radio.serial_number}, {radio.scf_dist_name}, {radio.hw_path}")

    def print_start_text(self, name, loop_no=0, loops="1"):
        """
        Print start text to Eventlog. Prints test name, loop number and start time.

        :param str name: Test name.
        :param int loop_no: Loop nmbr.
        :param str loops: Number of loops per test case.
        """
        BTS.step = 0
        self.start_time = datetime.datetime.now()
        info(("\n" +
              "*" * 99 +
              f"\nNAME:      {name}" +
              f"\nLOOP:      {loop_no + 1}/{loops}" +
              f"\nSTART:     {self.start_time}\n" +
              "*" * 99))
        self.logger.loops = loops

    @staticmethod
    def print_step_text(step, description, automatic=False):
        """
        Print step number and step text to Eventlog.

        :param int step: Test step number.
        :param str description: Description/Title of test step.
        :param bool automatic: Automatic step calculation
        """
        if automatic:
            BTS.step += 1
        info(("\n" +
              "-" * 79 +
              f"\nSTEP {BTS.step if automatic else step}:   {description}\n" +
              "-" * 79))

    def print_end_text(self, loop, loop_success):
        """
        Print end text to Eventlog. Prints end time and test duration.
        Requires that print_start_text is executed first.
        """
        end_time = datetime.datetime.now()
        if not self.start_time:
            duration = "Could not calculate test duration, please refer to the timestamps in logs."
        else:
            duration = end_time - self.start_time
        test_loop = "failed."
        if loop_success is True:
            test_loop = "passed."
        info(f"The {loop + 1}. test loop {test_loop}")  # same numbering as in print_start_text
        info(("\n" +
              "*" * 99 +
              f"\nEND:       {end_time}" +
              f"\nDURATION:  {duration}\n" +
              "*" * 99))

    @staticmethod
    def print_text_to_eventlog(text_for_print):
        """Print some text to Eventlog."""
        info(f"{text_for_print}")

    def _parse_parameter(self, bts_dict, parameter):
        """
        Parse parameter parses given paarmeter from the given dictionary

        :param dict bts_dict: BTS info dictionary
        :param str parameter: Parameter that is searched from the bts info
        """
        try:
            self.logger.debug(f"Parse parameter '{parameter}' from BTS information: {bts_dict}")
            for all_bts_parameters in bts_dict:
                for bts_parameter in all_bts_parameters:
                    if parameter in bts_parameter:
                        self.logger.debug(f"{parameter} returned {all_bts_parameters[bts_parameter]}")
                        parameter_value = all_bts_parameters[bts_parameter]
                        return parameter_value
            warning(f"Parameter {parameter} was not found from BTS info {bts_dict}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AliasLookupError, AdminApiConnectionClosedException, TypeError,
                AttributeError) as admin_error:
            warning(f"Unable to give get_parameters_for_all command to admin, "
                    f"{admin_error.__class__.__name__}:{admin_error} was raised. "
                    f"Parameter {parameter} not found from BTS info {bts_dict}\n"
                    f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
        return ""

    def get_parameter_value_from_bts_info(self, parameter, get_all_parameters_again=False, remote=False):
        """
        Get parameter value from bts_info.

        :param str parameter: Parameter found in bts_info, e.g. 'btsName'
        :param bool get_all_parameters_again: Default is False and uses saved content if it exists. If True makes
                                              admin request and overwrites the saved content.
        :param bool remote: Default False
        :return str: Parameter value if found. If parameter not found, returns an empty string.
        """
        if get_all_parameters_again:
            BTS.admin_parameters_for_all_bts = None
            BTS.admin_parameters_for_all_bts_remote = None
        if remote:
            if not BTS.admin_parameters_for_all_bts_remote:
                BTS.admin_parameters_for_all_bts_remote = self.admin.get_parameters_for_all("BTS",
                                                                                            connection="remote")
            return self._parse_parameter(BTS.admin_parameters_for_all_bts_remote, parameter)

        else:
            if not BTS.admin_parameters_for_all_bts:
                BTS.admin_parameters_for_all_bts = self.admin.get_parameters_for_all("BTS")
            return self._parse_parameter(BTS.admin_parameters_for_all_bts, parameter)

    @staticmethod
    def find_name_with_dist_name(obj_list, dist_name):
        """
        Find name of radio (from bts.radios) or BBMOD (from bts.bbmods) when distName is known.

        :param list[obj] obj_list: bts.radios or bts.bbmods.
        :param str dist_name: distName of the given object.
        :return str name: Returns object's name, i.e. ABIA1 or ARGA(1.1.1.1).
        """
        for obj in obj_list:
            if obj.dist_name == dist_name:
                return obj.name
        return None

    @staticmethod
    def find_scf_dist_name_with_name(obj_list, name):
        """
        Find dist_name of f.ex. BBMOD/RMOD (from bts.bbmods/bts.radios) that is used in SCF when name is known.

        :param list[obj] obj_list: bts.bbmods or bts.radios.
        :param str name: name, i.e. ABIA1, FXDB(1.1.1.1), BBMOD-1, RMOD-1
        :return str scf_dist_name: Returns object's scf dist_name
        """
        for obj in obj_list:
            if obj.name == name or any(mod for mod in ["RMOD-", "BBMOD-"] if mod in name and name in obj.scf_dist_name):
                return obj.scf_dist_name
        return None

    def get_bbmod_scf_dist_name(self, bbmod_name):
        """
        Get dist_name of BBMOD (from bts.bbmods) that is used in SCF when name is known.

        :param str bbmod_name: name, i.e. BBMOD-1, ABIA1
        :return str scf_dist_name: Returns BBMOD's scf dist_name
        """
        return self.find_scf_dist_name_with_name(BTS.bbmods, bbmod_name)

    def find_name_with_serial_number(self, unit_list, serial_number):
        """
        Find name of radio (from bts.radios) or BBMOD (from bts.bbmods) when serialNumber is known.

        :param list[obj] unit_list: bts.radios or bts.bbmods.
        :param str serial_number: serialNumber of the given object.
        :return str name: Returns object's name, i.e. ABIA1 or ARGA(1.1.1.1).
        """
        for unit in unit_list:
            if hasattr(unit, 'serial_nmbr') and unit.serial_nmbr == serial_number:
                self.logger.debug(f"Unit {unit.name} has {unit.serial_nmbr}")
                return unit.name
            elif hasattr(unit, 'serial_number') and unit.serial_number == serial_number:
                self.logger.debug(f"Unit {unit.name} has {unit.serial_number}")
                return unit.name
        warning(f"Could not find a unit from radio or bbmod list with serial number {serial_number}")
        return "Unknown unit"

    @staticmethod
    def get_smod_object(name="SMOD1"):
        """
        Gets SMOD object based on given name.

        :param str name: User can give values for example SMOD1, ASOE, ASOE1. If there is only one SMOD in the
                         environment, it is returned. If name not given, SMOD1 is returned.
        :return object: Returns SMOD object that fits to user given value.
        """
        if len(BTS.smods) == 1:
            info("There is only one SMOD in the environment, returning its SMOD object.")
            return BTS.smods[0]
        for smod in BTS.smods:
            if "SMOD" in name and smod.name[-1] == name[-1]:
                return smod
            elif name in smod.name:
                return smod
        error(f"User have given wrong name to SMOD module to be parsed from this environment's topology. "
              f"SMOD '{name}' is not found from this environment. Check and change variable in the "
              f"test case '{BuiltIn().get_variable_value('${TEST NAME}')}' if you want to run the test.")
        raise InvalidUserInput("User have given wrong name to SMOD module to be parsed from this environment's "
                               "topology.")

    def check_if_smod_type_in_environment(self, type_name):
        """
        Check if smod type in environment method check if the given type is found from the SMODs. Returns True if smod
        with the given type is found, otherwise False.

        :param str/list type_name: Type name to be checked. For example, ASIB, ASOE, ASOH...
        :return bool: Returns True if smod with the given type is found, otherwise False.
        """
        self.logger.debug(f"Check if SMOD type '{type_name}' is found from the environment.")
        if any(type_n in smod.name for smod in BTS.smods for type_n in (
                type_name if isinstance(type_name, list) else [type_name])):
            info(f"SMOD type '{type_name}' is found from the environment.")
            return True
        else:
            return False

    @staticmethod
    def _get_configuration_independent_bbmod(conf_match, user_given_value, print_eventlog):
        """
        Get configuration independent bbmod
        """
        if print_eventlog:
            info(f"User has given BBMOD with configuration independent name: {user_given_value}")
        else:
            print(f"User has given BBMOD with configuration independent name: {user_given_value}")
        selected_smod = conf_match.group("smod")
        if not selected_smod:
            selected_smod = "SMOD1"
        mgroup = conf_match.group("bbmod")
        if selected_smod == "SMOD2":
            if "." not in mgroup:
                print(f"Modify bbmod name {mgroup} to configuration independent")
                mgroup = f"{mgroup[:-1]}2.{mgroup[-1]}"
                print(mgroup)
        conf_bbmod = mgroup.split("BBMOD")
        if conf_bbmod:
            bbmod_nmbr = conf_bbmod[1]  # only the number part is in conf_bbmod[1] 2.1... or 2
        else:
            error(f"No BBMOD<number> or BBMOD<number>.<number> in {user_given_value}")
            raise InvalidUserInput
        for bbmod in BTS.bbmods:
            if "." in mgroup and "." in bbmod.name and bbmod_nmbr == bbmod.name[-3:]:
                print(f"Selected right side BBMOD: {bbmod.name}")
                return bbmod
            elif "." not in mgroup and "." not in bbmod.name and bbmod_nmbr == bbmod.name[-1]:
                print(f"Selected BBMOD: {bbmod.name}")
                return bbmod
        error(f"User has given BBMOD with configuration independent name {user_given_value} that doesn't exists"
              f" in the used environment")
        raise InvalidUserInput

    @staticmethod
    def _get_hw_path_bbmod(match, user_given_value, hw_path_pattern):
        """Get hw path bbmod"""
        info(f"User has given BBMOD with hw_path: {user_given_value}")
        for bbmod in BTS.bbmods:
            match2 = hw_path_pattern.match(bbmod.hw_path)
            if match and match2:
                if match.group("smod_side") == 'x' and match.group("bbmod_side") == 'x' and match.group(
                        "bbmod_position") == match2.group("bbmod_position"):
                    return bbmod
                elif (match.group("smod_side") == match2.group("smod_side") and
                      match.group("bbmod_side") == match2.group("bbmod_side") and
                      match.group("bbmod_position") == match2.group("bbmod_position")):
                    return bbmod
        error(f"User have given wrong name to BBMOD module to be parsed from this environment's topology. "
              f"BBMOD '{user_given_value}' is not found from this environment. Check and change variable in the "
              f"test case '{BuiltIn().get_variable_value('${TEST NAME}')}' if you want to run the test.")
        raise InvalidUserInput

    def get_bbmod_object_from_user_given_values(self, user_given_value, print_eventlog=True):
        """
        Gets BBMOD object from user given values.

        :param str user_given_value: User can give values for example:
                                    Exact name: ABIA1, ABIN2, ABIO3, ABIA2.1, ABIA2.2, ABIO2.3...
                                    Configuration name: BBMOD-3, BBMOD-1...
                                    Configuration independent: BBMOD1, BBMOD2, SMOD2-BBMOD1, SMOD1-BBMOD2...
                                    Hw_path: /SMOD_R-1(Left)/BBMOD_R-3(Left_Top)
                                     or without side info using x /SMOD_R-y(x)/BBMOD_R-z(x_Bottom)...

        :param bool print_eventlog: Default True. If False then do not print to eventlog.
        :return object: Returns BBMOD object that fits to user given value.
        """
        side_str = "Left|Right|x"
        position_str = "Bottom|Middle|Top"
        hw_path_pattern = re.compile(
            rf".SMOD_R-.+\((?P<smod_side>{side_str})\).BBMOD_R-.+\((?P<bbmod_side>{side_str})_"
            rf"(?P<bbmod_position>{position_str})\)")
        match = hw_path_pattern.match(user_given_value)
        conf_independent = re.compile(r"(?P<smod>SMOD\d+|)(-|)(?P<bbmod>BBMOD\d+.\d+|BBMOD\d+)")
        conf_match = conf_independent.match(user_given_value)
        if conf_match:
            return BTS._get_configuration_independent_bbmod(conf_match, user_given_value, print_eventlog)
        elif match:
            return BTS._get_hw_path_bbmod(match, user_given_value, hw_path_pattern)
        else:
            if print_eventlog:
                info(f"User has given BBMOD as {'configuration' if 'BBMOD-' in user_given_value else 'exact'} name: "
                     f"{user_given_value}")
            else:
                self.logger.debug(
                    f"User has given BBMOD as {'configuration' if 'BBMOD-' in user_given_value else 'exact'} "
                    f"name: {user_given_value}")
            for bbmod in BTS.bbmods:
                if bbmod.name == user_given_value or ("BBMOD-" in user_given_value and user_given_value in
                                                      bbmod.scf_dist_name):
                    return bbmod
        error(f"User have given wrong name to BBMOD module to be parsed from this environment's topology. "
              f"BBMOD '{user_given_value}' is not found from this environment. Check and change variable in the "
              f"test case '{BuiltIn().get_variable_value('${TEST NAME}')}' if you want to run the test.")
        raise InvalidUserInput

    def get_rmod_object_from_user_given_values(self, user_given_value):
        """
        Gets RMOD object from user given values.

        :param str user_given_value: User can give values for example:
            Configuration independent:
                BBMOD1-RMOD1, BBMOD1-RMOD2-RMOD1, BBMOD1-RMOD3, BBMOD2-RMOD1, BBMOD3-RMOD2,
                SMOD2-BBMOD1-RMOD1, SMOD2-BBMOD2-RMOD2-RMOD1 ...
            RCI - Radio Configuration Identifier:
                1.1.1.1, 2.1.1.1, 1.3.1.1, FXEB(1.3.2.2), FRHA(1.4.2.1), (1.4.2.1)...,
            Last part of commissioned RMOD name
                RMOD-1, RMOD-2, RMOD-3, RMOD-4...,
            Hw_path:
                /SMOD_R-1(Left)/BBMOD_R-3(Left_Top)/rf1/RMOD_R-3 or without side info using x
                /SMOD_R-y(x)/BBMOD_R-z(x_Bottom)/rf2/RMOD_R-v (NOTE numbers y, z and v are ignored)
            Short style (r + last part of commissioned RMOD name):
                r1, r2, r3, r4...
        :return object: Returns RMOD object that fits to user given value.
        """
        side_str = "Left|Right|x"
        position_str = "Bottom|Middle|Top"
        hw_path_pattern = re.compile(
            rf".SMOD_R-.+\((?P<smod_side>{side_str})\).BBMOD_R-.+\((?P<bbmod_side>{side_str})_"
            rf"(?P<bbmod_position>{position_str})\)/rf(?P<bbmod_rf_port>\d+)/RMOD_R-\d+")
        match = hw_path_pattern.match(user_given_value)
        short_style = re.compile(r"r(?P<rmod_nmbr>\d+)")
        match3 = short_style.match(user_given_value)
        conf_independent = re.compile(
            r"(?P<smod>SMOD\d+|)(-|)(?P<bbmod>BBMOD\d+|)-(?P<rmod>RMOD\d+)(-|)(?P<rmod_in_chain>RMOD\d+|)")
        conf_match = conf_independent.match(user_given_value)
        if conf_match:
            info(f"User has given radio with configuration independent name: {user_given_value}.")
            return self.select_radio_from_configuration_independent_value(
                conf_match.group("smod"), conf_match.group("bbmod"), conf_match.group("rmod"),
                conf_match.group("rmod_in_chain"))
        else:
            for rmod in BTS.radios:
                if user_given_value in rmod.name or user_given_value in rmod.multi_fibre_connection or (
                        "RMOD-" in user_given_value and user_given_value in rmod.scf_dist_name and
                        rmod.scf_dist_name[rmod.scf_dist_name.rfind("/") + 1:] == user_given_value):
                    return rmod

                if (match3 and rmod.scf_dist_name and "/RMOD-" in rmod.scf_dist_name
                        and rmod.scf_dist_name.split("/RMOD-")[1] == match3.group("rmod_nmbr")):
                    return rmod
                match2 = hw_path_pattern.match(rmod.hw_path)
                if match and match2:
                    if (match.group("smod_side") == 'x' and
                            match.group("bbmod_side") == 'x' and
                            match.group("bbmod_position") == match2.group("bbmod_position") and
                            match.group("bbmod_rf_port") == match2.group("bbmod_rf_port")):
                        return rmod
                    elif (match.group("smod_side") == match2.group("smod_side") and
                          match.group("bbmod_side") == match2.group("bbmod_side") and
                          match.group("bbmod_position") == match2.group("bbmod_position") and
                          match.group("bbmod_rf_port") == match2.group("bbmod_rf_port")):
                        return rmod
        error(f"User have given wrong name to radio module to be parsed from this environment's topology."
              f" Radio '{user_given_value}' is not found from this environment. Check and change variable in the "
              f"test case '{BuiltIn().get_variable_value('${TEST NAME}')}' if you want to run the test.")
        raise InvalidUserInput

    def select_radio_from_configuration_independent_value(self, smod, bbmod, rmod, rmod_in_chain):
        """
        Selects radio from user given configuration independent string.

        BBMOD1-RMOD1, BBMOD1-RMOD2-RMOD1, BBMOD1-RMOD3, BBMOD2-RMOD1, BBMOD3-RMOD2, SMOD2-BBMOD1-RMOD1,
        SMOD2-BBMOD2-RMOD2-RMOD1, SMOD1-RMOD1

        :param str smod: If empty, SMOD1 as default. Can have value SMOD1 or SMOD2.
        :param str bbmod: Can have value BBMOD1, BBMOD2 or BBMOD3. NOTE in ASOE BBMOD1 stands also for internal BBMOD.
        :param str rmod: Can have value RMOD1, RMOD2, RMOD12...
        :param str rmod_in_chain: If empty, no radios in chain. Can have value RMOD1, RMOD2...
        :return str: Radio parsed from user given configuration independent value.
        """
        rmod_units = []
        for rm in BTS.radios:
            # ASOE has one internal FSP unit, internal BBMOD has 0 in topology
            if not bbmod and smod in ("SMOD1", "SMOD2", "SMOD") and ("0" in (rm.name[-6], rm.name[-7])):
                rmod_units.append(rm.name)
            elif (((not smod or "SMOD1" in smod) and "1" in (rm.name[-8], rm.name[-9]))
                  or ((smod and "SMOD2" in smod) and "2" in (rm.name[-8], rm.name[-9]))) and (
                    bbmod[-1] in (rm.name[-6], rm.name[-7])):
                rmod_units.append(rm.name)
        rmods_ordered = sorted(rmod_units, key=lambda s: s[-5:])
        if rmod and rmods_ordered and len(rmods_ordered) >= int(rmod[-1]):
            selected_radio = rmods_ordered[int(rmod[-1]) - 1]
            if rmod_in_chain:
                c_radios = self.get_chained_rmods(selected_radio, True)
                chain_radios = sorted(c_radios, key=lambda i: i[-2:])
                if len(chain_radios) >= int(rmod_in_chain[-1]):
                    selected_radio = chain_radios[int(rmod_in_chain[-1]) - 1]
                    info(f"Selected radio is {selected_radio} and it is in chain")
                else:
                    error(f"User has given invalid input. Environment doesnt have {bbmod}-{rmod}-{rmod_in_chain}. "
                          f"All found chain radios {chain_radios}")
                    raise InvalidUserInput
        else:
            error(f"User has given invalid input. Environment doesnt have {bbmod}-{rmod}. "
                  f"All found radios {rmods_ordered}")
            raise InvalidUserInput
        for radio in BTS.radios:
            if radio.name == selected_radio or selected_radio in radio.multi_fibre_connection:
                return radio
        error(f"User has given invalid input. Environment doesnt have any {smod}-{bbmod}-{rmod}-{rmod_in_chain}. "
              f"All found radios in the environment are: {BTS.radios}")
        raise InvalidUserInput

    def get_values_from_object(self, unit_object, unit_object_attribute):
        """
        With this method it is able to get value of specific attribute of object. F.ex. scf_dist_name of BBMOD object.
        Or attributes of all objects as a list for example serial_numbers of all RMODs.

        :param object/list unit_object: Object that's attribute values are searched.
        :param str unit_object_attribute: Attribute that's value is searched.
        """
        if not unit_object:
            self.logger.debug("Attribute unit_object is empty/None")
        elif isinstance(unit_object, list):
            list_of_attributes = []
            if unit_object:
                for unit_obj in unit_object:
                    for key, value in unit_obj.__dict__.items():
                        self.logger.debug(f"{key} : {value}")
                        if key == unit_object_attribute:
                            list_of_attributes.append(value)
            return list_of_attributes
        else:
            for key, value in unit_object.__dict__.items():
                self.logger.debug(f"{key} : {value}")
                if key == unit_object_attribute:
                    return value
        return None

    def get_cells_of_bbmod(self, bbmod_name):
        """
        Get cells that have resources on BBMOD.

        :param str bbmod_name: BBMOD that cells are get. Possible values are f.ex. ABIA1, ABIL3, ABIB2.2.
        """
        cells = self.bbmod_lib.get_cells_mapped_to_bbmod(bbmod_name)
        info(f"Cell(s) {cells} are mapped to {bbmod_name}")
        return cells

    def get_cells_of_radio(self, rmod_name, print_to_eventlog=True):
        """
        Get cells of selected radio.

        :param str/list rmod_name: Radio that cells are get. Possible values are f.ex. FRHA(1.2.1.1), ARGA(2.1.1.2) ...
        :param bool print_to_eventlog: Default True if not wanted to print set to False.
                                       or list of RMOD objects
        """
        if not rmod_name:
            self.logger.debug("No rmod_name -> cannot get cells of rmod")
        elif isinstance(rmod_name, list):
            cells = []
            for rmod in rmod_name:
                r_c = self.rmod_lib.get_cells_mapped_to_rmod(rmod.name)
                if print_to_eventlog:
                    info(f"Cell(s) of {rmod.name} are {r_c}")
                else:
                    self.logger.debug(f"Cell(s) of {rmod.name} are {r_c}")
                cells.extend(r_c)
            return cells
        else:
            cells = self.rmod_lib.get_cells_mapped_to_rmod(rmod_name)
            if print_to_eventlog:
                info(f"Cell(s) of {rmod_name} are {cells}")
            else:
                self.logger.debug(f"Cell(s) of {rmod_name} are {cells}")
            return cells
        return None

    def get_master_radios(self):
        """Get all master radios"""
        return self.rmod_lib.get_all_master_radios()

    def get_cells_of_master_radios(self):
        """Get cells of master radios"""
        return self.rmod_lib.get_cells_of_all_master_radios()

    def get_all_radios(self, multifibre_radios=True):
        """
        Searches names of all radio modules and returns them in a list.
        :param bool multifibre_radios: Default is True and returns also names of radios that are in multi-fibre

        :return list: List of names of radios
        """
        name_list = []
        if self.radios:
            for rmod_object in self.radios:
                name_list.append(rmod_object.name)
                if rmod_object.multi_fibre_connection and multifibre_radios:
                    for rmod in rmod_object.multi_fibre_connection:
                        name_list.append(rmod)
        self.logger.debug(f"All radios: {sorted(name_list)}")
        return sorted(name_list)

    def get_all_bbmods(self):
        """
        Searches names of all BBMOD units and returns them in a list.

        :return list: List of names of BBMODs
        """
        name_list = []
        if self.bbmods:
            for bbmod_object in self.bbmods:
                name_list.append(bbmod_object.name)
        return name_list

    def get_chained_rmods(self, rmod_name, return_names=False, print_to_eventlog=True):
        """
        Get all radios that are chained to the selected radio.

        :param str rmod_name: Radio Configuration Identifier -> Possible values are f.ex.
                              FRHA(1.2.1.1), ARGA(2.1.1.2), FXEB(1.3.1.3) ...
        :param bool return_names: Default is False and returns rmod objects, if True returns just names of radios.
        :param bool print_to_eventlog: Default is True and then prints to eventlog, otherwise not.
        :return list: List of objects or list of radio names
        """
        if rmod_name:
            chained_rmods = self.rmod_lib.get_radios_in_chain(rmod_name, return_names, print_to_eventlog)
            if not chained_rmods:
                if print_to_eventlog:
                    info(f"No chained units found to {rmod_name}")
                else:
                    self.logger.debug(f"No chained units found to {rmod_name}")
                return None
        else:
            error("No radio module given to this method, unable to check if there are radios in chain.")
            raise ScriptIssue
        return chained_rmods

    def get_cells_of_rat(self, rat):
        """
        Gets all cells of RAT, f.ex. LTE.

        :param str rat: Radio access technology. Possible values are: LTE, NR, WCDMA and GSM.
        :return list: Returns list of cells of given RAT or empty.
        """
        cells_of_rat = self.cell_operations.get_cells_rmods_or_both_of_rat(rat, "cells")
        if cells_of_rat:
            info("Cells of {} are: {}".format(rat, cells_of_rat))
        else:
            info("There are no cells on {}".format(rat))
        return cells_of_rat

    def get_rmods_of_rat(self, rat):
        """
         Gets all radios of RAT, f.ex. LTE.

         :param str rat: Radio access technology. Possible values are: LTE, NR, WCDMA and GSM.
         :return list: Returns list of radios of given RAT or empty.
         """
        rmods_of_rat = self.cell_operations.get_cells_rmods_or_both_of_rat(rat, "rmods")
        if rmods_of_rat:
            info("Radios of {} are: {}".format(rat, rmods_of_rat))
        else:
            info("There are no radios on {}".format(rat))
        return rmods_of_rat

    @staticmethod
    def _check_if_radio_name_in_list(rmod):
        """
        Check if radio name in list
        """
        radios_of_name = []
        for radio in BTS.radios:
            if rmod in radio.name:
                info(f"Radio {radio.name} ({radio.scf_dist_name}) is {rmod}-radio")
                radios_of_name.append(radio)
        return radios_of_name

    @staticmethod
    def get_rmods_of_name(rmod_name):
        """
         Get rmods of same name f.ex. AHLOA

         :param str/list rmod_name: Radio name
         :return list: Returns list of radios of given name.
         """
        radios_of_name = []
        if isinstance(rmod_name, list):
            for rmod in rmod_name:
                r_na = BTS._check_if_radio_name_in_list(rmod)
                if r_na:
                    radios_of_name.append(r_na)
        else:
            radios_of_name = BTS._check_if_radio_name_in_list(rmod_name)
        return radios_of_name

    def get_active_partition(self):
        """
        Get active SW partition from BTS. Uses IP 192.168.255.129.
        If active partition not found, gives a warning.

        :return str: Active partition. If not found, returns an empty string.
        """
        self.ssh.take_ssh_connection(BTS.default_smod_ip, "FSM")
        output_of_ssh_l = self.ssh.send_command_to_ip_return_output("ls -all /ffs/ -w 160", "FSM")
        active_partition = self._parse_ssh_l_output(output_of_ssh_l)
        if active_partition:
            info("Active partition is {}.".format(active_partition))
            BTS.active_partition = active_partition
        else:
            warning("Active partition was not get.")
        self.ssh.close_ssh_connection("FSM")
        return active_partition

    def get_path_to_bts_sw_zip_in_ute_cloud(self):
        """
        Get path to BTS SW zip of UTE cloud environment

        :raise ScriptIssue: If function called in non-UTE environment.
        :return str path_to_zip: Returns path to BTS SW zip.
        """
        if not BTS.cloud_env:
            error("Not a UTE environment! You cannot call method get_path_to_bts_sw_zip_in_ute_cloud "
                  "from a non-UTE environment.")
            raise ScriptIssue
        sw_build_dir = os.listdir('/home/ute/.ute-ca/cache/bts/')
        self.logger.debug(sw_build_dir)
        sw_build_dir2 = os.listdir('/home/ute/.ute-ca/cache/bts/{}'.format(sw_build_dir[0]))
        self.logger.debug(sw_build_dir2)
        path_to_zip = '/home/ute/.ute-ca/cache/bts/{}/{}'.format(sw_build_dir[0], sw_build_dir2[0])
        info("Path to UTE BTS SW zip is {}".format(path_to_zip))
        self.path_to_bts_sw_zip = path_to_zip
        return path_to_zip

    def print_targetbd_of_sw_zip(self, path_to_zip=None):
        """
        Parse TargetBD name from SW zip file and print it to user.

        :param str path_to_zip: Path to SW build zip file. If not given, check if UTE cloud and parse information.
        :raise ScriptIssue: If function used in non-UTE environment without path_to_zip information.
        """
        import zipfile
        if not path_to_zip:
            self.check_if_ute_cloud_env()
            if BTS.cloud_env:
                path_to_zip = self.get_path_to_bts_sw_zip_in_ute_cloud()
            else:
                error("In non-UTE environments it is mandatory to give path_to_zip for this function.")
                raise ScriptIssue
        self.path_to_bts_sw_zip = path_to_zip
        sw_zip = zipfile.ZipFile(path_to_zip, "r")
        for name in sw_zip.namelist():
            if "TargetBD" in name:
                info("TargetBD is {}".format(name.replace('bts_sw/', '')))
                return name.replace('bts_sw/', '').replace('.xml', '')
        return None

    @staticmethod
    def wait_time_and_reason(sleep_time="10", wait_reason=""):
        """
        Wait user given time and print reason why we are waiting into the eventlog.

        :param str wait_reason: Reason why we are waiting.
        :param str sleep_time: Time that we will wait. If set to 0, will not wait nor print anything.
        """
        if sleep_time != "0":
            info("Wait {} seconds {}".format(sleep_time, wait_reason))
            BuiltIn().sleep("{}s".format(sleep_time))

    def ping_ip_until_disconnection_or_reconnection(self, ip_to_ping=default_smod_ip, disconnection=False,
                                                    time_to_wait=300, save_pings_to_file=True, boolean_return=False,
                                                    ping_answers=3, ignore_rfs_ip_changes=False,
                                                    level_in_error="error"):
        """
        Waits for ping to given IP be lost, disconnection or waits for reply, reconnection, depending on user
        selections.

        :param str ip_to_ping: Set to 192.168.255.129 if not given. IP to ping.
        :param bool disconnection: Default value is false, waits for ping to ip to reply.
        :param int time_to_wait: Time in seconds to wait for reconnection/disconnection. Default value is 300s.
        :param bool save_pings_to_file: Default is True, writes IP pings to file.
        :param bool boolean_return: Returns True or False from the method if set ti True. Default is False.
        :param int ping_answers: How many times ping is waited to be noticed. Default is 3.
        :param bool ignore_rfs_ip_changes: Default is False, but if IP should not be changes because of RFS, set True.
        :param str level_in_error: Can have value error/warning/info. If error then raises error, if warning raises
                                   warning and if info just prints to eventlog.
        :raise BTSConnectionFailure: If BTS could not be disconnected within timeout.
        :raise PingToIpNotLost: If IP is pinging after wait time, even though it should not.
        :raise NoReplyToPing: If IP is not pinging after wait time, even though it should.
        """
        if not ignore_rfs_ip_changes:
            self.logger.debug("Checking if rsf changes are needed...")
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            if self.collect_logs.rfs:
                remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
                if other_master:
                    self.logger.debug(f"Switch IP to remote mPlane IP: {remote_mplane_ip}")
                    ip_to_ping = remote_mplane_ip
        else:
            self.logger.debug(f"Keep the given ip {ip_to_ping}, no RFS changes.")
        text_to_eventlog = "disconnection" if disconnection else "reconnection"
        info("Ping ip {} until {} is noticed or timeout time {}s reached".format(
            ip_to_ping, text_to_eventlog, time_to_wait))
        expected_strings = ['1 packets transmitted, 1 received,', ', 0% packet loss'] if os.name != "nt" else [
            'Packets: Sent = 1, Received = 1, Lost = 0', '(0% loss)']
        if disconnection:
            # Added Destination Host Unreachable as an option due to pings failing
            expected_strings = ['1 packets transmitted, 0 received,', '100% packet loss',
                                'Destination Host Unreachable'] if os.name != "nt" else [
                'Packets: Sent = 1, Received = 0, Lost = 1', '(100% loss)', 'TTL expired in transit',
                'Destination Host Unreachable']
        self.logger.debug("Expected ping prints are '{}'".format(expected_strings))
        found_ping = 0
        start_time = datetime.datetime.now()
        try:
            found_ping = self._wait_for_ping_print_to_appear_3_times(
                expected_strings, ip_to_ping, save_pings_to_file, text_to_eventlog, time_to_wait, start_time,
                int(ping_answers))
        except (ValueError, OSError, MemoryError, IndexError, TypeError) as ex:
            txt = f"Problems when trying to ping IP {ip_to_ping}. Reason: '{ex.__class__.__name__}:{ex}'.\n"\
                  f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}"
            if level_in_error == "error":
                error(txt)
            elif level_in_error == "warning":
                warning(txt)
            elif level_in_error == "info":
                info(txt)
            if "No space left on device" in txt:
                self.collect_logs.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")
        if found_ping != int(ping_answers):
            if found_ping == 0:
                e_txt = f"During {time_to_wait}s ping time, {text_to_eventlog} of {ip_to_ping} not noticed, NOK."
                if level_in_error == "error":
                    error(e_txt)
                elif level_in_error == "warning":
                    warning(e_txt)
                elif level_in_error == "info":
                    info(e_txt)
            if disconnection:
                if boolean_return:
                    return False
                if level_in_error == "error":
                    raise PingToIpNotLost
                return None
            else:
                if boolean_return:
                    return False
                if level_in_error == "error":
                    raise NoReplyToPing
                return None
        else:
            return True

    def ping_ips(self, list_of_ips, time_to_wait=300, disconnection=False, save_pings_to_file=True,
                 ping_from_smod=True):
        """
        Ping given list of IPs and wait for reply or disconnection.

        :param list/dictionary/str list_of_ips: List/dictionary/string of IPs to ping.
        :param int/str time_to_wait: Time to wait for reply or disconnection.
        :param bool disconnection: Default is False, but if disconnection is expected set to True.
        :param bool save_pings_to_file: Default is True, but if not wanted to save pings to file set to False.
        :param bool ping_from_smod: Default is True, but if ping is done from test PC set to False.
        """
        error_msg = ""
        if ping_from_smod:
            if not self.ping_ip_from_smod(list_of_ips, time_to_ping=time_to_wait, disconnection=False,
                                          lxc_attach=False):
                error_msg += f"{list_of_ips} has problems."
        else:
            for ip in list_of_ips:
                if not self.ping_ip_until_disconnection_or_reconnection(ip_to_ping=ip, disconnection=disconnection,
                                                                        time_to_wait=int(time_to_wait),
                                                                        save_pings_to_file=save_pings_to_file,
                                                                        boolean_return=True):
                    error_msg += f"IP {ip} has problems."
        if error_msg:
            if disconnection:
                raise PingToIpNotLost
            else:
                raise NoReplyToPing
        else:
            info(f"Ping checks are working as expected. OK.")

    def _ping_ip_from_smod(self, smod_ssh, command, ip_to_ping, time_to_ping, disconnection, commands_after_ping,
                           ip_name="", disconnect_ssh=True, return_ssh_object=False):
        """
        Method that pings ip/ips from smod. This is needed so no need to take new ssh connection between every IP that
        is ping from smod.

        :param smod_ssh: SSH connection to SMOD.
        :param str command: Command that is given to SMOD.
        :param str ip_to_ping: IP that is pinged.
        :param str time_to_ping: Time to wait for reply to ping (or if disconnection=True that ping is lost).
        :param bool disconnection: Default is False, but if disconnection is expected set to True.
        :param list commands_after_ping: (OPTIONAL) List of commands that can be given right after reply to ping is get.
        :param str ip_name: (OPTIONAL) Name of IP.
        """
        # prompt = re.compile(r"(:~ >|:~\$|#|> |:~.|tmp#|:~#)")
        expected_reply = False
        expected_strings = ['1 packets transmitted, 1 received,', ', 0% packet loss']
        if disconnection:
            expected_strings = ['1 packets transmitted, 0 received,', '100% packet loss']
        start_time = datetime.datetime.now()
        while (datetime.datetime.now() - start_time).total_seconds() < int(time_to_ping) and not expected_reply:
            # smod_ssh.sendline(command)
            # smod_ssh.expect(prompt, timeout=300)
            if return_ssh_object:
                output, ssh_object = self.ssh.send_command_to_smod_by_ssh(
                    command, enb_ssh=smod_ssh, return_output=True, ssh_timeout=300, print_to_eventlog=True,
                    raise_error=True, disconnect_ssh=False, return_ssh_object=return_ssh_object)
            else:
                output = self.ssh.send_command_to_smod_by_ssh(command, enb_ssh=smod_ssh, return_output=True,
                                                              ssh_timeout=300, print_to_eventlog=True, raise_error=True,
                                                              disconnect_ssh=False, return_ssh_object=return_ssh_object)
            if not output:
                info("No output from SMOD.")
                output = str(smod_ssh.before)
            if output and any(expected for expected in expected_strings if expected in output):
                expected_reply = True
        if expected_reply:
            info("{} noticed, {}IP {} {} to ping from SMOD. OK.".format(
                "Disconnection" if disconnection else "Connection", "" if not ip_name else "%s " % ip_name, ip_to_ping,
                "doesn't reply" if disconnection else "replies"))
            if commands_after_ping is not None:
                self.ssh.send_command_to_smod_by_ssh(commands_after_ping, enb_ssh=smod_ssh, return_output=False,
                                                     ssh_timeout=60, print_to_eventlog=False,
                                                     disconnect_ssh=disconnect_ssh, return_ssh_object=return_ssh_object)
                info("Commands are given")
        if return_ssh_object:
            return expected_strings, smod_ssh
        return expected_reply

    def ping_ip_from_smod(self, ip_to_ping, time_to_ping="300", disconnection=False, lxc_attach=False,
                          commands_after_ping=None, only_warning=False, return_ssh_object=False, disconnect_ssh=True):
        """
        Take ssh connection to SMOD and ping given IP for the given time and check if the ip replies to the ping
        during the given time.

        :param str/list/dict ip_to_ping: IP to ping for example ip of radio module or BBMOD.
        :param str time_to_ping: Time to wait for reply to ping (or if disconnection=True that ping is lost).
        :param bool disconnection: Default is False, but if disconnection is expected set to True.
        :param bool lxc_attach: Default is False, but if for example radio is going to be ping then lxc-attach needs to
                                be done.
        :param list commands_after_ping: List of commands that can be given right after reply to ping is get.
        :param bool only_warning: If True, do not raise errors but just give a warning of failed connection.
        :param bool return_ssh_object: Default False. If True returns ssh object.
        :param bool disconnect_ssh: Default True, but if we want to use sam ssh object to other command set to False.
        """
        command = f"ping -c 1 {ip_to_ping}"
        if lxc_attach:
            smod_ssh = self.ssh.ssh_connection_to_smod_ltx_attach(name_for_log="to_smod_lxc")
        else:
            smod_ssh = self.ssh.ssh_connection_to_smod(name_for_log="to_smod")
        expected_reply = False
        ping_nok = []
        if isinstance(ip_to_ping, list):
            expected_reply = True
            for ip in ip_to_ping:
                command = f"ping -c 1 {ip}"
                e_reply = self._ping_ip_from_smod(smod_ssh, command, ip, time_to_ping, disconnection,
                                                  commands_after_ping, disconnect_ssh=disconnect_ssh)
                if not e_reply:
                    ping_nok.append(ip)
                expected_reply = expected_reply and e_reply
        elif isinstance(ip_to_ping, str):
            expected_reply = self._ping_ip_from_smod(smod_ssh, command, ip_to_ping, time_to_ping, disconnection,
                                                     commands_after_ping, disconnect_ssh=disconnect_ssh)
        elif isinstance(ip_to_ping, dict):
            expected_reply = True
            for ip_name, ip in ip_to_ping.items():
                command = f"ping -c 1 {ip}"
                e_reply = self._ping_ip_from_smod(smod_ssh, command, ip, time_to_ping, disconnection,
                                                  commands_after_ping, ip_name, disconnect_ssh=disconnect_ssh)
                expected_reply = expected_reply and e_reply
                if not e_reply:
                    ping_nok.append(f"{ip_name}: {ip}")
        else:
            error(f"IP {ip_to_ping} is not string, list of strings or dictionary.")
            raise ScriptIssue
        if disconnect_ssh:
            self.ssh.disconnect_ssh_connection(smod_ssh)
        if expected_reply:
            info(f"Pinging of IP {ip_to_ping} from SMOD was successful. OK.")
            if return_ssh_object:
                if disconnect_ssh:
                    error("Parameter disconnect_ssh was set to True and return_ssh_object was set to True. If you want"
                          " to return ssh object, you cannot disconnect ssh.")
                    raise ScriptIssue("Parameter disconnect_ssh was set to True and return_ssh_object was set to True.")
                return smod_ssh
            else:
                return True
        else:
            if disconnection:
                if ping_nok:
                    error(f"Disconnection not noticed from IPs {ping_nok}. NOK.")
                else:
                    error(f"No disconnection, IP {ip_to_ping} still replies to ping from SMOD. NOK.")
                raise PingToIpNotLost
            else:
                if not only_warning:
                    if ping_nok:
                        error(f"No connection, no reply to ping from SMOD to {ping_nok}. NOK.")
                    else:
                        error(f"No connection, IP {ip_to_ping} doesn't reply to ping from SMOD. NOK.")
                    raise NoReplyToPing
                else:
                    warning(f"No connection, IP {ip_to_ping} doesn't reply to ping from SMOD. NOK.")
                    return None

    def reset_site_and_wait_for_bts_to_reply_ping(self, ip_to_ping=default_smod_ip, time_to_wait=300):
        """
        Reset site and wait for BTS to reply to ping. Default time to wait is 300s.

        :param str ip_to_ping: IP to ping, default is 192.168.255.129.
        :param int/str time_to_wait: Time to wait for BTS to reply to ping.
        """
        self.print_text_to_eventlog("Request site reset.")
        try:
            self.admin.reset_site(detailed_output=True, wait_for_reconnection=False)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AdminApiTerminatedException, AliasLookupError, AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to reset site, {admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise BTSConnectionFailure
        self.ping_ip_until_disconnection_or_reconnection(ip_to_ping=ip_to_ping, disconnection=True,
                                                         time_to_wait=int(time_to_wait))
        self.ping_ip_until_disconnection_or_reconnection(ip_to_ping=ip_to_ping, time_to_wait=int(time_to_wait),
                                                         ping_answers=3)

    def _uboot_env_get(self, parameter, ip, log_name="to_smod_uboot_env_get"):
        """
        Uboot env get command to get parameter from BTS.

        :param str parameter: Parameter to get from BTS.
        :param str ip: IP of BTS.
        :param str log_name: Name for log.
        :return bool env_variable_active: True if parameter is active and False if not.
        """
        env_variable_active = False
        command = "uboot_env get"
        info(f"Checking if NET boot is in use in {ip}")
        output = self.ssh.send_command_to_smod_by_ssh(command, return_output=True, print_to_eventlog=False,
                                                      name_for_log=log_name, ip_to_connect=ip)
        if output and parameter in output:
            info(f"'{parameter}' was found from '{command}' output ({ip})")
            env_variable_active = True
        else:
            info(f"'{parameter}' was not found from '{command}' output ({ip})")
        return env_variable_active

    def check_uboot_env_get(self, parameter):
        """
        Checks content of uboot_env get command.

        :param str parameter: Value to be checked f.ex. netboot_first.
        :return bool env_variable_active: True if parameter is active and False if not.
        """
        env_variable_active = self._uboot_env_get(parameter, BTS.default_smod_ip)
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if self.collect_logs.rfs:
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            if remote_mplane_ip:
                env_variable_active = self._uboot_env_get(
                    parameter, remote_mplane_ip, log_name="to_remote_smod_uboot_env_get") and env_variable_active
        return env_variable_active

    def get_bbmod_uboot_info(self):
        """
        Get uboot_env get -information of BBMODs with FSP connection.
        Writes the info into a file called ssh_bbmod_uboot_{timestamp}.log.
        """
        command = "uboot_env get"
        fsp_ips = BuiltIn().get_library_instance("FSP")
        ssh_object = self.ssh.ssh_connection_to_given_ip(user_name="toor4nsn", ssh_password="oZPS0POrRieRtu",
                                                         ip_to_connect="192.168.255.129", name_for_log="bbmod_uboot",
                                                         print_to_eventlog=False, raise_error=False)
        for bbmod in self.bbmods:
            fsp = fsp_ips.get_ip_of_selected_fsp(bbmod.name, selected_soc=bbmod.primary_soc, smod_ssh=ssh_object)
            fsp_object = self.ssh.connect_to_fsp(ssh_object, fsp, "toor4nsn", known_hosts=False)
            self.ssh.send_command_to_fsp_by_ssh(fsp_object, command, ssh_timeout=60)
        self.ssh.disconnect_ssh_connection(ssh_object)

    def _rat_check_print(self, rat_text, object_distname, print_eventlog):
        """
        Rat check print

        :param str rat_text: Text of RAT
        :param object object_distname: Object for checks
        :param bool print_eventlog: If True print text to evenlog, otherwise to debug log and log.html.
        """
        if object_distname:
            if print_eventlog:
                info(rat_text)
            else:
                self.logger.debug(rat_text)
                print(rat_text)
            return True
        else:
            if print_eventlog:
                info(f"Not {rat_text}")
            else:
                self.logger.debug(f"Not {rat_text}")
                print(f"Not {rat_text}")
            return False

    def check_if_5g_environment(self, print_eventlog=True, admin_connection="default"):
        """
        Checks if scf.xml includes managedObject class com.nokia.srbts.nrbts:NRBTS.

        :param bool print_eventlog: Default True, if set False doesn't print text to eventlog.
        :param str admin_connection: Default is default can also be f.ex. log_admin
        :return bool: True if 5G and False if not.
        """
        object_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.nrbts:NRBTS",
                                                               admin_connection=admin_connection)
        return self._rat_check_print("5G environment", object_distname, print_eventlog)

    def check_if_gsm_environment(self, print_eventlog=True, admin_connection="default"):
        """
        Checks if scf.xml includes managedObject class com.nokia.srbts.gsm:GNBTS.

        :param bool print_eventlog: Default True, if set False doesn't print text to eventlog.
        :param str admin_connection: Default is default can also be f.ex. log_admin
        :return bool: True if GSM and False if not.
        """
        object_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.gsm:GNBTS",
                                                               admin_connection=admin_connection)
        return self._rat_check_print("GSM environment", object_distname, print_eventlog)

    def check_if_lte_environment(self, print_eventlog=True, admin_connection="default"):
        """
        Checks if scf.xml includes managedObject class NOKLTE:LNBTS

        :param bool print_eventlog: Default True, if set False doesn't print text to eventlog.
        :param str admin_connection: Default is default can also be f.ex. log_admin
        :return bool: True if LTE and False if not.
        """
        object_distname = self.scf.get_distname_based_on_class("NOKLTE:LNBTS",
                                                               admin_connection=admin_connection)
        return self._rat_check_print("LTE environment", object_distname, print_eventlog)

    def smod_is_fsmf(self, include_fsih=False):
        """
        Check if smod is FSMF/FSMr3 or if include_fsih=True also FSHI

        :param bool include_fsih: Default is False, if set to True also FSHI is checked.
        """
        smod_list = ["FSMr3", "FSMF"]
        print_text = "FSMF/FSMr3"
        if include_fsih:
            smod_list.append("FSIH")
            print_text = "FSMF/FSMr3/FSIH"
        for smod in BTS.smods:
            if any(smod_type for smod_type in smod_list if smod_type in smod.name):
                self.logger.debug(f"{smod.name} is {print_text}")
                return True
        self.logger.debug(f"SMOD is not {print_text}")
        return False

    def check_if_netboot_is_active_and_deactivate_it(self):
        """
        Checks if netboot_first is found from output of uboot_env get -command. Tries to deactivate netboot anyway.
        """

        if self.smod_is_fsmf():
            if self.check_uboot_env_get("uboot_recovery=1"):
                info("Netboot is active (uboot_recovery=1), we have to deactivate it")
                info("Deactivate netboot (Give command: uboot_env del uboot_recovery)")
                self.ssh.send_command_to_smod_by_ssh("uboot_env del uboot_recovery", print_to_eventlog=False,
                                                     name_for_log="to_smod_uboot_env_del",
                                                     ip_to_connect=BTS.default_smod_ip)
        else:
            if self.check_uboot_env_get("netboot_first"):
                info("Netboot is active (netboot=netboot_first), we have to deactivate it")
                info("Deactivate netboot (Give command: uboot_env del netboot)")
                self.ssh.send_command_to_smod_by_ssh("uboot_env del netboot", print_to_eventlog=False,
                                                     name_for_log="to_smod_uboot_env_del",
                                                     ip_to_connect=BTS.default_smod_ip)
                if not self.collect_logs:
                    self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
                if self.collect_logs.rfs:
                    remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                    info(f"Deactivate netboot also in remote BTS {remote_mplane_ip}")
                    self.ssh.send_command_to_smod_by_ssh(
                        "uboot_env del netboot", return_output=True, print_to_eventlog=False,
                        name_for_log="to_remote_smod_uboot_env_del", ip_to_connect=remote_mplane_ip)
                self.check_uboot_env_get("netboot_first")
        info("Netboot is deactivated.")

    def check_if_netboot_is_deactive_and_activate_it(self):
        """
        Checks if netboot_first is not found from output of uboot_env get -command. If it is not found, activates it.
        """
        if self.smod_is_fsmf():
            if not self.check_uboot_env_get("uboot_recovery=1"):
                info("Netboot is not active (uboot_recovery=1), we have to activate it")
                info("Activate netboot (Give command: uboot_env set uboot_recovery=1)")
                self.ssh.send_command_to_smod_by_ssh("uboot_env set uboot_recovery=1", print_to_eventlog=False,
                                                     name_for_log="to_smod_uboot_env_set")
        else:
            if not self.check_uboot_env_get("netboot_first"):
                info("Netboot is not active (netboot=netboot_first), we have to activate it")
                info("Activate netboot (Give command: uboot_env set netboot=netboot_first)")
                self.ssh.send_command_to_smod_by_ssh("uboot_env set netboot=netboot_first", print_to_eventlog=False,
                                                     name_for_log="to_smod_uboot_env_set")
                if not self.collect_logs:
                    self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
                if self.collect_logs.rfs:
                    remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                    info(f"Activate netboot also in remote BTS {remote_mplane_ip}")
                    self.ssh.send_command_to_smod_by_ssh(
                        "uboot_env set netboot=netboot_first", return_output=True, print_to_eventlog=False,
                        name_for_log="to_remote_smod_uboot_env_del", ip_to_connect=remote_mplane_ip)
                self.check_uboot_env_get("netboot_first")
        info("Netboot is activated.")

    def deactivate_netboot_secondary_smod(self):
        """Deactivate netboot secondary smod. Check if netboot is active on secondary smod and deactivates it"""
        command = "uboot_env get"
        output, ssh_object = self.ssh.send_command_to_secondary_smod_by_ssh(
            command, check_side=True, return_output=True, ssh_timeout=60, print_to_eventlog=False, raise_error=True,
            disconnect_ssh=False, return_ssh_object=True, name_for_log="Deactivate_netboot_secondary_smod")
        if output and "netboot_first" in output:
            info("Netboot is active in secondary SMOD, we have to deactivate it")
            self.ssh.send_command_to_secondary_smod_by_ssh(
                "uboot_env del netboot", ssh_object=ssh_object, print_to_eventlog=False, ssh_timeout=60,
                raise_error=True, disconnect_ssh=False)
        self.ssh.send_command_to_secondary_smod_by_ssh(
            command, ssh_object=ssh_object, ssh_timeout=60, print_to_eventlog=False, raise_error=True,
            disconnect_ssh=True)
        info("Netboot is deactivated from secondary SMOD")

    def activate_netboot_secondary_smod(self):
        """Activate netboot to secondary smod. Check if netboot is deactive on secondary smod and activates it"""
        command = "uboot_env get"
        output, ssh_object = self.ssh.send_command_to_secondary_smod_by_ssh(
            command, check_side=True, return_output=True, ssh_timeout=60, print_to_eventlog=False, raise_error=True,
            disconnect_ssh=False, return_ssh_object=True, name_for_log="Activate_netboot_secondary_smod")
        if output and "netboot_first" not in output:
            info("Netboot is deactive in secondary SMOD, we have to activate it (uboot_env set netboot=netboot_first)")
            self.ssh.send_command_to_secondary_smod_by_ssh(
                "uboot_env set netboot=netboot_first", ssh_object=ssh_object, print_to_eventlog=False, ssh_timeout=60,
                raise_error=True, disconnect_ssh=False)
        self.ssh.send_command_to_secondary_smod_by_ssh(
            command, ssh_object=ssh_object, ssh_timeout=60, print_to_eventlog=False, raise_error=True,
            disconnect_ssh=True)
        info("Netboot is activated to secondary SMOD")

    def check_graceful_values_from_scf(self, managed_class, p_parameter, p_values=None, admin_connection="default"):
        """
        Check graceful values actGrflShdn (5G) or enableGrflShdn (4G) of ManagedObject class from scf.xml.

        :param str managed_class: ManagedObject class from the scf.xml.
        :param str p_parameter: Name of p from the scf.xml.
        :param list p_values: List of p_values
        :param str admin_connection: Default is default can also be f.ex. log_admin
        """
        if p_values is None:
            p_values = ["true", "false"]
        object_distnames = self.scf.get_distname_based_on_class(managed_class, admin_connection=admin_connection)
        if not object_distnames:
            if admin_connection == "remote":
                used_scf = BuiltIn().get_variable_value("${REMOTE_SCF}")
                print(f"Load the remote side SCF {used_scf}.")
                self.scf.load_scf_file(used_scf)
                self.scf.remote_loaded = True
            else:
                print(f"Load the SCF {self.scf.scf_file_path}.")
                self.scf.load_scf_file(self.scf.scf_file_path)
            object_distnames = self.scf.get_distname_based_on_class(managed_class, admin_connection=admin_connection)
        if object_distnames:
            object_distname = object_distnames[0]
            value_of_graceful = self.scf.get_value_from_scf(dist_name=object_distname, p_name=p_parameter,
                                                            admin_connection=admin_connection, allow_missing=True)
            if not value_of_graceful:
                self.logger.debug(f"{p_parameter} was not found from scf.xml for {object_distname}. It has default "
                                  f"value.")
                print(f"{p_parameter} was not found from scf.xml for {object_distname}. It has default value.")
                if p_parameter == "actGrflShdn":  # 5g default false, Disabled
                    value_of_graceful = p_values[1]
                elif p_parameter == "enableGrflShdn":  # 4g default Enabled, true
                    value_of_graceful = p_values[0]
                else:
                    error(f"Unkonwn parameter for graceful cell shutdown check: {p_parameter}.")
                    raise ScriptIssue(f"Unkonwn parameter for graceful cell shutdown check: {p_parameter}")
            if value_of_graceful == p_values[0]:  # true or enabled
                omit_check = BuiltIn().get_variable_value("${OMIT_GRACEFUL_CELL_CHECK}", default=False)
                if omit_check and (isinstance(omit_check, bool) or (
                        isinstance(omit_check, str) and omit_check.lower() == "true")):
                    info(f"Value for 'Activate graceful cell shutdown' ({object_distname}, {p_parameter})= "
                         f"{p_values[0]}")
                else:
                    error(f"Value for 'Activate graceful cell shutdown' ({object_distname}, {p_parameter})= "
                          f"{p_values[0]}")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            elif value_of_graceful == p_values[1]:  # false or disabled
                info(f"Value for 'Activate graceful cell shutdown' ({object_distname}, {p_parameter})=  {p_values[1]}")
            else:
                warning(f"Value of {p_parameter} was not {p_values[0]} nor {p_values[1]}, it was {value_of_graceful}. "
                        f"Check if changes in commissioning.")
            if admin_connection == "remote":
                print("Load the tested side SCF back to use after checks.")
                self.scf.load_scf_file(self.scf.scf_file_path)
                self.scf.remote_loaded = False
        else:
            warning(f"Class {managed_class} not found from SCF.xml. Check if test case and commissioning are suitable")

    def check_if_graceful_cell_shutdown(self):
        """
        Checks value of parameter actGrflShdn (5G) or enableGrflShdn (4G) from scf.xml file
        """
        if self.check_if_5g_environment(print_eventlog=False):
            self.check_graceful_values_from_scf("com.nokia.srbts.nrbts:NRBTS", "actGrflShdn")
        else:
            self.check_graceful_values_from_scf("NOKLTE:LNBTS", "enableGrflShdn", ["Enabled", "Disabled"])
        if BuiltIn().get_variable_value("${RFS}", default=False):
            print("Check graceful cell shutdown also from the remote side")
            if self.check_if_5g_environment(print_eventlog=False, admin_connection="remote"):
                self.check_graceful_values_from_scf("com.nokia.srbts.nrbts:NRBTS", "actGrflShdn",
                                                    admin_connection="remote")
            else:
                self.check_graceful_values_from_scf("NOKLTE:LNBTS", "enableGrflShdn", ["Enabled", "Disabled"],
                                                    admin_connection="remote")

    def get_rmods_connected_to_bbmods(self, multifibre_radios=True):
        """
        Create dictionary of BBMODs connected to Radios. BBMOD as a key and list of radios as a value.
        :param bool multifibre_radios: Default is True and returns also names of radios that are in multi-fibre

        """
        all_radios = self.get_all_radios(multifibre_radios)
        for bbmod in BTS.bbmods:
            BTS.bbmods_connected_to_rmods[bbmod.name] = []
            for radio_name in all_radios:
                if BTS.fullrack and '.' in bbmod.name:
                    if '2' in (radio_name[-8], radio_name[-9]) and bbmod.name[-1] in (radio_name[-6], radio_name[-7]):
                        BTS.bbmods_connected_to_rmods[bbmod.name].append(radio_name)
                elif BTS.fullrack and '.' not in bbmod.name:
                    if '1' in (radio_name[-8], radio_name[-9]) and bbmod.name[-1] in (radio_name[-6], radio_name[-7]):
                        BTS.bbmods_connected_to_rmods[bbmod.name].append(radio_name)
                elif radio_name and bbmod.name[-1] in (radio_name[-6], radio_name[-7]):
                    BTS.bbmods_connected_to_rmods[bbmod.name].append(radio_name)
            bbmod.connected_radios = BTS.bbmods_connected_to_rmods[bbmod.name]
            self.logger.debug(f"Updated value of bbmod object (connected_radios, incl. multi-fibre connections): "
                              f"{bbmod.connected_radios}")
        info(f"DEBUG BBMODs connected to radios: {BTS.bbmods_connected_to_rmods}")

    @staticmethod
    def _remove_multifibre_radios(radios):
        for radio in BTS.radios:
            if radio.multi_fibre_connection:
                for rmod in radio.multi_fibre_connection:
                    if rmod in radios:
                        radios.remove(rmod)
        info(f"Radios after removing multi-fibre radios: {radios}")

    def get_rmods_connected_to_bbmod(self, bbmod_name, remove_multifibre=False):
        """
        Gets radios that are connected to BBMOD unit.

        :param str bbmod_name: Name of BBMOD f.ex. ABIA1, ABIA2, ABIA2.3
        :param bool remove_multifibre: Default is False, if set to True, removes multi-fibre radios from list.
        :return list: Returns list of radios that are connected to BBMOD f.ex. ['FHEA(1.1.1.1)', 'FHEA(1.1.2.1)']
        """
        if bbmod_name in BTS.bbmods_connected_to_rmods:
            info(f"Radios connected to tested BBMOD ({bbmod_name}): {BTS.bbmods_connected_to_rmods[bbmod_name]}")
            if remove_multifibre:
                self._remove_multifibre_radios(BTS.bbmods_connected_to_rmods[bbmod_name])
            return BTS.bbmods_connected_to_rmods[bbmod_name]
        else:
            error(f"Given BBMOD '{bbmod_name}' is not found from bbmods_connected_to_rmods dictionary "
                  f"'{BTS.bbmods_connected_to_rmods}'")
            raise ScriptIssue(f"Given BBMOD '{bbmod_name}' is not found from bbmods_connected_to_rmods dictionary.")

    def _select_bts_ip(self):
        """Check if RFS environment and select IP according to user selections. If not RFS return 192.168.255.129."""
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        bts_ip = BTS.default_smod_ip
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
                BTS.default_smod_ip = bts_ip
        if self.collect_logs.rfs:
            self.logger.debug("RFS environment.")
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
            if other_master:
                self.logger.debug(
                    f"RFS environment and other is master. Change IP {bts_ip} to {remote_mplane_ip}")
                bts_ip = remote_mplane_ip
        return bts_ip

    def check_if_admin_connection_available(self, wait_for_connection=130, create_connection=False,
                                            additional_wait=True):
        """
        Checks if connection to admin is possible and if not tries to connect as long as parameter wait_for_connection
        is set.

        :param int wait_for_connection: Default value is 130 seconds.
        :param bool create_connection: Default is False, if set to True, tries to create connection.
        :param bool additional_wait: If True wait additional 15s after admin connection is noticed.
        """
        start_time = datetime.datetime.now()
        admin_connection = False
        admin_error_msg = ""
        while not admin_connection and (
                (datetime.datetime.now() - start_time).total_seconds() < int(wait_for_connection)):
            try:
                bts_ip = self._select_bts_ip()
                release = self.get_sw_release_via_targetbd(lmp_ip=bts_ip)
                self.admin.connect_to(
                    bts_host=bts_ip, bts_port=443, username='Nemuadmin', password='nemuuser',
                    update_interval=1000, admin_api_log_dir=self.logger.create_admin_folder(), name='connection_check',
                    timeout=20, release=release)
                if additional_wait:
                    info("Admin connection is now available! Wait additional 15s")
                    BuiltIn().sleep("15s")
                else:
                    info("Admin connection is now available!")
                admin_connection = True
            except (AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiTerminatedException,
                    AdminApiProcedureTimeoutException, AdminApiNoResponseException, AliasInUse
                    ) as admin_error:
                tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
                self.logger.debug(f"No admin connection {admin_error.__class__.__name__}:{admin_error}.\n{tb}\nTry "
                                  f"again.")
                admin_error_msg = f"{admin_error.__class__.__name__}:{admin_error}\n{tb}"
        if not admin_connection:
            error(f"Unable to connect to admin in {wait_for_connection}s wait time. "
                  f"{admin_error_msg} was raised")
            raise BTSConnectionFailure("Admin connection not available")
        else:
            self.logger.debug("Disconnect 'connection_check' admin connection")
            self.teardown_selected_admin_connection(selected_admin='connection_check')
            if create_connection:
                bts_ip = self._select_bts_ip()
                self.admin.connect_to(
                    bts_host=bts_ip, bts_port=443, username='Nemuadmin', password='nemuuser',
                    admin_api_log_dir=self.logger.create_admin_folder(), timeout=10, release=release)

    def check_if_cell_down_and_no_active_alarm_and_wait_for_fault(self, degraded_cells=None):
        """
        Checks cell states and if there are disabled cells checks active alarms. If there are no active
        alarm for faulty cell wait max 31min for fault 4261 to appear.

        :param list degraded_cells: (Optional) List of degraded cells. If not given, all cells are supposed to be
                                    degraded if serial console is in use
        """
        faulty_loki_cells = []
        if BuiltIn().get_variable_value("${SERIAL_CONSOLE}"):
            degraded_cells = "All"
        print_txt = "BREAK_LOKI"
        if BuiltIn().get_variable_value("${BREAK_LOKI}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}")
        if BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}"):
            faulty_loki_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
            print_txt = "BBMODS_MASK"
        if faulty_loki_cells:
            info(f"{print_txt} is in variables and cells {faulty_loki_cells} are allowed to be faulty and disabled.")
        if isinstance(degraded_cells, str):
            if degraded_cells == "All":
                degraded_cells = []
                cells = self.cells
                for cell in cells:
                    degraded_cells.append(cell)
        disabled_cells = self.cell_operations.get_faulty_cells(degraded_cells=degraded_cells)
        time_limit = 1865  # 31min + 5s
        start_time = datetime.datetime.now()
        first_time = True
        alarming_cells = []
        if disabled_cells:
            if faulty_loki_cells:
                if sorted(disabled_cells) == sorted(faulty_loki_cells):
                    info(f"All disabled cells ({faulty_loki_cells}) are allowed to be faulty and disabled because "
                         f"{print_txt} is set.")
                    return
            info("There are disabled cells {}. Check if all faulty cells have some active alarm.\n"
                 "If there are cells down without alarm, wait max {} seconds for cells to be up and "
                 "running or fault 4261 to appear.".format(disabled_cells, time_limit))
            loop = "Loop {}: ".format(self.logger.loop + 1)
            while (datetime.datetime.now() - start_time).total_seconds() < int(time_limit) and disabled_cells:
                if not first_time:  # no need to check again in first loop
                    disabled_cells = self.cell_operations.get_faulty_cells(
                        degraded_cells=degraded_cells, print_to_eventlog=False)
                active_alarms = self.admin.get_active_alarms(severity=None, timeout=10, connection='log_admin')
                self.logger.debug("!!! Active alarms: {}\n ".format(active_alarms))
                for cell in disabled_cells:
                    cell_for_alarm = self.cell_operations.parse_cell_information_for_alarm(cell)
                    cell_in_alarm = self.cell_operations.get_cells_to_alarm_format(cell)
                    for active_alarm in active_alarms:
                        aa_ics = active_alarm['impactedCells'].replace("\n", "").replace("\t", "").replace("\r", "")
                        all_lte_cells = re.findall(r'LNCEL-\d+', aa_ics)
                        all_nr_cells = re.findall(r'NRCEL-\d+', aa_ics)
                        all_cells = all_lte_cells + all_nr_cells
                        self.logger.debug(f"LTE cells in alarm: {all_lte_cells}\nNR cells in alarm: {all_nr_cells}\n"
                                          f"All cells in alarm: {all_cells}")
                        if (active_alarm["configObjectName"] in cell_for_alarm
                                or ('impactedCellsList' in active_alarm
                                    and any(j for j in active_alarm['impactedCellsList']
                                            if j[j.rfind("-") + 1:] == cell))
                                or (active_alarm["degradedCells"] == "Faulty: All")
                                or (cell_in_alarm == active_alarm['impactedCell'])
                                or (cell_in_alarm == aa_ics)
                                or (cell_in_alarm and "Faulty:" in cell_in_alarm and
                                    cell_in_alarm.split("Faulty:")[1] in all_cells)) and cell not in alarming_cells:
                            error("{}There is active alarm '{}' '{}' for cell {}. ".format(
                                loop, active_alarm["faultName"], active_alarm["faultId"], cell))
                            alarming_cells.append(cell)
                        if active_alarm["alarmId"] and str(active_alarm["alarmId"]) in ["7650", "7111"]:
                            error("{}There is active alarm '{}' '{}' for SMOD -> All cells are faulty.".format(
                                loop, active_alarm["faultName"], active_alarm["faultId"]))
                            alarming_cells = list(disabled_cells)
                if not disabled_cells or (alarming_cells and len(disabled_cells) == len(alarming_cells)):
                    break  # break out of while
                BuiltIn().sleep("5s")
                first_time = False
        if not disabled_cells and (datetime.datetime.now() - start_time).total_seconds() > 5:
            info("All cells are now enabled. Waited {} seconds extra.".format(
                (datetime.datetime.now() - start_time).total_seconds()))
        elif disabled_cells and alarming_cells and len(disabled_cells) == len(alarming_cells):  # all cells have alarm
            info("All faulty cells have some active alarm. Waited {} seconds extra.\n".format(
                (datetime.datetime.now() - start_time).total_seconds()))
            raise CellsDown
        elif alarming_cells and len(disabled_cells) > len(alarming_cells):
            error("Cells {} doesn't have any active alarm. Waited already 31min extra for 4261 fault to "
                  "be raised. NOK.".format([noa for noa in disabled_cells if noa not in alarming_cells]))
            raise CellDownWithoutActiveAlarm
        elif disabled_cells and not alarming_cells:
            error("Cells {} doesn't have any active alarm. Waited already 31min extra for 4261 fault to "
                  "be raised. NOK.".format(disabled_cells))
            raise CellDownWithoutActiveAlarm

    def increase_test_step(self, increase_test_step=1):
        """
        Increase saved test step value with user given value. Default is 1.

        :param int increase_test_step: Default value is 1.
        :return int: Returns increased step
        """
        self.logger.debug("Increase test step {} + {} ".format(BTS.step, increase_test_step))
        BTS.step += int(increase_test_step)
        self.logger.debug("Saves test step {} to BTS.step parameter.".format(BTS.step))
        return BTS.step

    def set_test_step_value(self, step_value):
        """
        Set test step value with user given value.

        :param int step_value: Value that will be saved to BTS.step parameter.
        """
        self.logger.debug("Set test step to = {}".format(step_value))
        BTS.step = int(step_value)

    def get_test_step_value(self):
        """
        Get test step value. Returns value that is saved to BTS.step parameter.

        :return int: Returns value that is saved to BTS.step parameter.
        """
        self.logger.debug("Test step = {}".format(BTS.step))
        return BTS.step

    def check_if_step_smaller_or_same_as_saved_if_is_increase(self, step):
        """
        This method is for increasing step value when looping TestKeyword with run_keyword_in_loop_and_return_pass_rate
        -method. Checks if first loop in question, if is then sets the value of BTS.step to user given step-value. If
        the value of BTS.step is same or smaller than user given step then increases value with 1.

        :param int step: Value that will be saved to BTS.step parameter and used as step in the first loop.
        :return int: Returns step value that is saved to BTS.step parameter and increased
        """
        if step and "." in str(step):
            step = str(step)
            self.logger.debug(f"Step value {step} is float so user wants to grow just the step value after .")
            step_list = step.split(".") if step else [step]
            return "{}".format(step_list[0] + "." + str(int(step_list[1]) + 1))
        if self.logger.loop == 0 and int(step) == 1 and BTS.step == 0:
            self.set_test_step_value(step)
        elif int(step) <= int(BTS.step):  # and self.logger.loop != 0:
            self.logger.debug("User given step {} was smaller or equal that saved {} -> increase".format(step,
                                                                                                         BTS.step))
            self.increase_test_step()
        elif int(step) > int(BTS.step):
            self.logger.debug("User given step {} was higher that saved {} -> update BTS.step".format(step, BTS.step))
            BTS.step = int(step)
        return BTS.step

    def get_current_step_value(self):
        """Get current step value."""
        self.logger.debug("Step is {} in BTS.step variable".format(BTS.step))
        return BTS.step

    @staticmethod
    def _parse_ssh_l_output(output_of_ssh_l):
        """
        Parses SSH command's '"ls -all /ffs/ -w 160", "FSM"' -output for method get_active_partition.

        :param str output_of_ssh_l: Command output.
        :return str: Active partition. If not found, returns an empty string.
        """
        re_active_partition = re.compile(r".*run.*\s+->\s+/ffs/(?P<active_partition>.*)")
        if output_of_ssh_l:
            all_partitions = output_of_ssh_l.split("\n") if output_of_ssh_l else []
            for partition in all_partitions:
                match = re_active_partition.match(partition)
                if match and match.group("active_partition"):
                    return str(match.group("active_partition")).strip()
        return ""

    def _wait_for_ping_print_to_appear_3_times(self, expected_strings, ip_to_ping, save_pings_to_file,
                                               text_to_eventlog, time_to_wait, start_time, ping_answers):
        """
        Waits for the expected ping print to appear 3 times.

        :param list[str] expected_strings: A list of expected ping prints.
        :param str ip_to_ping: IP to ping.
        :param bool save_pings_to_file: Writes IP pings to file if set to True.
        :param str text_to_eventlog: Eventlog print text.
        :param int time_to_wait: Time in seconds to wait for reconnection/disconnection.
        :param start_time: Time when ping was started.
        :param int ping_answers: Number of ping answers. Default is usually 3.
        """
        try:
            command = "ping -c 1 {}".format(ip_to_ping) if os.name != "nt" else "ping -n 1 {}".format(ip_to_ping)
            print_found = 0
            log_name = ""
            save_path = self.logger.log_dir
            if not os.path.exists(self.logger.log_dir):
                save_path = self.logger.suite_folder
                info(f"Folder {self.logger.log_dir} doesn't exists anymore, use suite folder path to save the ping "
                     f"file: {save_path}")
            if save_pings_to_file:
                if not os.path.exists(f"{save_path}/ping_logs"):
                    self.logger.debug(f"Folder {save_path}/ping_logs doesn't exists, create it.")
                    os.makedirs(f"{save_path}/ping_logs", exist_ok=True)
                log_name = os.path.join(save_path, "ping_logs", "ping_ip_{}.txt".format(
                    datetime.datetime.now().strftime("%Y%m%d_%H%M%S")))
                self.logger.debug(f"Save ping logs to {log_name}.")
                # command = '{c} >> {f}'.format(c=command, f=log_name)  # writes to file, but no output for popen
            while (datetime.datetime.now() - start_time).total_seconds() < int(time_to_wait):
                handle = os.popen(command)
                output = ''.join(handle.readlines())
                handle.close()
                if output and any(expected for expected in expected_strings if expected in output):
                    print_found += 1
                if not output:
                    error("No output gotten when pinging {} Time: {}.".format(
                        ip_to_ping, datetime.datetime.now().strftime("%Y%m%d_%H%M%S")))
                if output and save_pings_to_file:
                    with open(log_name, 'a') as f:
                        f.write(str(output))
                if print_found == int(ping_answers):
                    info("{} of {} is noticed".format(text_to_eventlog, ip_to_ping))
                    return print_found
                BuiltIn().sleep("1s")
            if print_found != 0:
                error(f"During {time_to_wait}s ping time, {text_to_eventlog} of {ip_to_ping} is expected to be seen "
                      f"{ping_answers} times now it is seen just {print_found} times, NOK.")
            return print_found
        except OSError as e:
            error(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.collect_logs.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def print_test_loop(self):
        """
        Print loop of current test to log.html.
        """
        info("".format(int(self.logger.loop) + 1, self.logger.loops))

    def check_if_file_is_in_folder(url_to_file, location_folder):
        """
        Check if file is in folder

        :param str url_to_file: Url to the file
        :param str location_folder: Location to where the file is planned to get.
        :return: Path to file if file is found otherwise None
        """
        filename = url_to_file[url_to_file.rfind("/") + 1:]
        filepath = os.path.join(location_folder, filename)
        if os.path.exists(filepath):
            info(f"File '{filepath}' already exists. No need to get it again.")
            return filepath
        else:
            print(f"File '{filepath}' doesn't exists yet.")
            return None

    def check_if_special_sw_is_found(self, location_folder):
        """
        Check if SW build is found from given file path.

        :param str location_folder: Folder where the file should be.
        :return bool: Returns True if file is found, otherwise raises FileNotFoundError.
        """
        filename = os.path.basename(location_folder)
        directory = os.path.dirname(location_folder)
        info(f"Check if SW build '{filename}' is found in directory '{directory}'.")
        if BTS.check_if_file_is_in_folder(filename, directory):
            info(f"SW was found in {location_folder}.")
            return True
        else:
            error("SW build was not found on PC. Failing test.")
            raise FileNotFoundError("File not found.")

    @staticmethod
    def use_wget_commands(sw_url, build_to_download, path_to_saved_build, swdl_path="/home/ute/logs/"):
        """
        Use wget command to get SW build from website.

        :param str sw_url: Url from where the build is downloaded.
        :param str build_to_download: Name of the build.
        :param str path_to_saved_build: Path where the build is saved.
        :param str swdl_path: Path where the build is saved. Default is /home/ute/logs/.
        """
        if BTS.check_if_file_is_in_folder(sw_url, swdl_path):
            return
        try:
            info(f"Get build from {sw_url} to {swdl_path} -folder")
            command = f"wget --content-on-error -P {swdl_path} {sw_url}"
            subp = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            try:
                outs, errs = subp.communicate(timeout=7200)
                print("Software fetched!")
                if "ERROR 404: Not Found.".encode() in errs:
                    error("Build {} was not found from artifactory. Cannot download build. Downloading"
                          " url {} returns ERROR: 404 Not Found".format(build_to_download, sw_url))
                    print(errs)
                    raise BuildNotFoundFromArtifactory
                info("Build was saved to {}".format(path_to_saved_build))
            except subprocess.TimeoutExpired:
                error("TimeoutExpired when getting build from artifactory ({})".format(sw_url))
                subp.kill()
                outs, errs = subp.communicate()
                print(outs, errs)
                raise TimeOutWhenDownloadingFromArtifactory
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def check_if_rfs_other_is_master_and_lmp(self):
        """
        Check if RFS Other is MASTER and LMP_SWDL is True. This method is used to check if we should run SWDL on the
        other VM or not.
        """
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if self.collect_logs.rfs:
            if BuiltIn().get_variable_value("${MASTER}") == "Other":
                lmp_value = BuiltIn().get_variable_value("${LMP_SWDL}")
                if (isinstance(lmp_value, bool) and lmp_value) or (
                        isinstance(lmp_value, str) and lmp_value.lower() == "true"):
                    info("RFS Other is MASTER and LMP_SWDL is True. Run SWDL on the other VM.")
                    return True
        return False

    def get_build_from_artifactory(self, build_to_download, release=None, package_type="A54", save_to_pc=True):
        """
        Get path to build or download given build from the artifactory (url):
        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/

        :param str build_to_download: Name of build. For example SBTS00_ENB_9999_230418_000008.
        :param str release: Release. Default is SBTS00.
        :param str package_type: SW package type. Default is A54.zip.
        :param bool save_to_pc: Default is True. If True saves build to /home/ute/logs folder of test PC. If False gives
                                url to package to WebEM.
        :return str: Returns path to sw, path can be either url or path to build on pc.
        :raise BuildNotFoundFromArtifactory: If build is tried to save to PC and not found.
        """
        build_name = "{}_release_BTSSM_downloadable_{}.zip".format(build_to_download, package_type)
        if release is None:
            release = self.get_branch_from_build_name(build_to_download)
        if BuiltIn().get_variable_value("${KNIFE_NUMBER}"):
            knf_nmbr = BuiltIn().get_variable_value("${KNIFE_NUMBER}")
            sw_url = f"https://es-si-s3-z2.eecloud.nsn-net.net/knife-results/{knf_nmbr}/{build_name}"
        else:
            sw_url = (f"https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/"
                      f"build/{release}/{build_to_download}/{build_name}")
        if self.check_if_rfs_other_is_master_and_lmp():
            return sw_url
        if save_to_pc:
            path_to_saved_build = "/home/ute/logs/{}".format(build_name)
            if os.path.exists(path_to_saved_build):
                info("Software build file {} is already found from /home/ute/logs -folder. No need to fetch it "
                     "again.".format(build_name))
            else:
                self.use_wget_commands(sw_url, build_to_download, path_to_saved_build)
                if not self.check_size_of_sw_build(path_to_saved_build, return_boolean=True):
                    info("Size of build was not OK. Try to download the SW build again.")
                    self.use_wget_commands(sw_url, build_to_download, path_to_saved_build)
                    self.check_size_of_sw_build(path_to_saved_build)
        else:
            path_to_saved_build = sw_url
            info("Software path: {}".format(path_to_saved_build))
        return path_to_saved_build

    def create_netrc_file(self, url, user, password):
        """
        Create netrc file for wget command.

        :param str url: Url, for example artifactory-espoo2.int.net.nokia.com
        :param str user: Username.
        :param str password: Password.
        """
        try:
            home_dir = str(os.path.expanduser('~'))
            netrc_file = os.path.join(home_dir, ".netrc")
            if os.path.exists(netrc_file) and os.path.isfile(netrc_file):
                self.logger.debug(f"Netrc file {netrc_file} already exists. Check if url and user and passwords are in "
                                  f"file.")
                with open(netrc_file, "r") as f:
                    lines = f.readlines()
                    for line in lines:
                        if url in line and user in line:
                            self.logger.debug(f"Netrc file {netrc_file} already contains given url and user.")
                            return
            else:
                with open(netrc_file, "w") as f:
                    f.write(f"machine {url} login {user} password {password}")
                self.logger.debug(f"Netrc file {netrc_file} created.")
        except OSError as e:
            error(f"{e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "No space left on device" in str(e):
                self.collect_logs.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                BuiltIn().fatal_error("No space left on device. Stopping execution of the suite.")

    def get_fhs_build_from_artifactory(self, fhs_build_type, fhs_build_folder, fhs_product):
        """
        Get FHS build from artifactory to test PC.

        :param str fhs_build_type: Can have value ReleaseCandidates or Releases.
        :param str fhs_build_folder: Folder where the build is located. For example FHS24r3.06.R03.
        :param str fhs_product: Can have value ID or OD. ID means indoor and OD means outdoor.
        :return a fhs software version
        """
        if fhs_build_type not in ["ReleaseCandidates", "Releases"]:
            error(f"FHS build type should be either ReleaseCandidates or Releases, but it is {fhs_build_type}")
            raise InvalidUserInput("FHS build type should be either ReleaseCandidates or Releases.")
        if fhs_product not in ["ID", "OD"]:
            error(f"Product should be either ID or OD, but it is {fhs_product}")
            raise InvalidUserInput("FHS product should be either ID or OD.")
        self.create_netrc_file("artifactory-espoo1.int.net.nokia.com", "psnsn",
                               "AKCp5Zm7hU3DGe2MtzRDQSAdC5qK7MZPGjGN5RcFhkyDPqyvi8vaFvN11hThT1NnH1XKnRxRE")
        sw_url = (f"https://artifactory-espoo1.int.net.nokia.com/artifactory/mnpbbp-fhs-bin-local/FHS/{fhs_build_type}/"
                  f"{fhs_build_folder}/C_Element/SE_FHS/SS_FHS{fhs_product}/Target/")
        url_content = self.get_content_of_url(sw_url)
        if not url_content:
            error(f"FHS Software was not found from {sw_url}. Check if you have given right values to FHS_BUILD_TYPE, "
                  f"FHS_BUILD_FOLDER and FHS_PRODUCT variables.")
            raise InvalidUserInput(f"FHS Software was not found from {sw_url}.")
        fhs_sw_version = self.get_fhs_sw_from_url(url_content)
        fhs_sw_url = os.path.join(sw_url, fhs_sw_version)
        fhs_swdl_path = "/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/FhsSwUpdateScripts"
        path_to_saved_build = os.path.join(fhs_swdl_path, fhs_sw_version)
        if os.path.exists(path_to_saved_build) and os.path.isfile(path_to_saved_build):
            info(f"FHS software build file {fhs_sw_version} is already found from {fhs_swdl_path} -folder. No need to "
                 f"fetch it again.")
        else:
            self.use_wget_commands(fhs_sw_url, fhs_sw_version, path_to_saved_build, swdl_path=fhs_swdl_path)
        return fhs_sw_version

    def get_content_of_url(self, url):
        """
        Get content of url.

        :param str url: Url that content is fetched.
        :return str: Content of url.
        """
        output_file = "output_of_url.txt"
        self.logger.debug(f"Use wget to fetch the content of {url} and save it to the file output_of_url.txt")
        os.system(f"wget -O {output_file} {url}")
        with open(output_file, 'r') as f:
            content = f.read()
        self.logger.debug(f"Content of the url:\n{content}")
        return content

    def get_fhs_sw_from_url(self, url_content):
        """
        Get fhs sw from url parses name of latest FHS SW from the url. Note that if there are multiple FHS SW versions
        that ends with .tar.lzma (packages that doesn't end with md5, sha1 or sha256) then the last one will be selected

        :param str url_content: Content of url.
        :return str: Name of FHS SW.
        :raise EnvironmentIssue: If no FHS software found from content.
        """
        fhs_sw = ""
        all_softwares = re.findall(r"<a href=.FHS-.*</a>", url_content)
        for sw in all_softwares:
            if not any(j for j in ["md5", "sha1", "sha256"] if j in sw):
                fhs_sw = sw[sw.find(">") + 1:sw.rfind("<")]
                self.logger.debug(f"Parsed FHS SW: {fhs_sw}")
        if fhs_sw:
            info(f"FHS software to be get is: {fhs_sw}")
        else:
            error(f"No FHS software found from content:\n{url_content}")
            raise EnvironmentIssue("No FHS software found from content.")
        return fhs_sw

    @staticmethod
    def check_size_of_sw_build(sw_build_path, return_boolean=False):
        """
        Check that size of software build is at least 8GiB. If not, raise error.

        :param str sw_build_path: Path to sw build.
                                  For example
                                  /home/ute/logs/SBTS00_ENB_9999_230606_000009_release_BTSSM_downloadable_
                                  testpackage_T1_A54.zip
        :param bool return_boolean: Default False.
        :raise SizeOfSwBuildIsUnexpected: If size of .zip file is less than 8GiB
        :return boolean: If return_boolean is True.
        """
        build_size = os.path.getsize(sw_build_path)
        min_build_size = "8000000000"
        if "_FSM3_" in sw_build_path:
            min_build_size = "1500000000"
        if build_size < int(min_build_size):
            error("Size of {} should be at least {} ({}GB), it is {}. Invalid software package. NOK.".format(
                sw_build_path, min_build_size, min_build_size[0], build_size))
            if return_boolean:
                return False
            raise SizeOfSwBuildIsUnexpected
        info("Size of {} is {}, OK.".format(sw_build_path, build_size))
        if return_boolean:
            return True
        return None

    def parse_sw_build_name_from_download_package(self, expected_sw):
        """
        Parse name of build from BTSSM download package name.

        :param str expected_sw: BTSSM download package name for example
                   /home/ute/logs/SBTS00_ENB_9999_230605_000009_release_BTSSM_downloadable_testpackage_T1_A54.zip.
        """
        build_pattern = re.compile(
            r".*/(?P<build>\w+_ENB_\w+_\w+_\w+|\w+_FSM3_\w+_\w+_\w+)_release_BTSSM_downloadable"
            r"(?P<testp>_\w+|_testpackage_T1_\w+|_testpackage_T2_\w+).zip.*")
        match = build_pattern.match(expected_sw)
        if match:
            self.logger.debug("Build_pattern MATCH")
            if "T1" in match.group("testp"):
                parsed_sw = "{}T1".format(match.group("build"))
            elif "T2" in match.group("testp"):
                parsed_sw = "{}T2".format(match.group("build"))
            else:
                parsed_sw = "{}".format(match.group("build"))
            self.logger.debug("{} to {}".format(expected_sw, parsed_sw))
            return parsed_sw
        else:
            info(f"Path {expected_sw} didn't have sw build version in its names, check name of sw build from "
                 f"TargetBD file of the provided zip.")
            target_bd = self.print_targetbd_of_sw_zip(path_to_zip=expected_sw)
            if target_bd:
                return target_bd
            else:
                error(f"Build given in path {expected_sw} didn't have suitable name in the path nor in TargetBD file.")
                raise ScriptIssue("Couldn't parse build name from the path nor from TargetBD.")

    def check_that_sw_has_been_updated(self, expected_sw, kpi_print=True):
        """
        Checks that expected sw is active on BTS.

        :param str expected_sw: Expected active build.
        :param bool kpi_print: Default True, if False doesn't print anything related to KPI.
        :raise ExpectedSwBuildIsNotActive: If expected SW is not active.
        """
        self.update_sw_information()
        self.logger.debug(f"Builds are {BTS.active_sw} and {expected_sw}")
        if not expected_sw:
            error("Expected software build is empty string, cannot check if expected build is active.")
            raise ScriptIssue("Expected software build is empty string.")
        if not BTS.active_sw:
            error("Admin returns that Active software is empty string/None. Cannot check if expected build is active.")
            raise EnvironmentIssue("Active software build is empty string.")
        if "/" in expected_sw:
            self.logger.debug(f"Path to build {expected_sw}")
            expected_sw = self.parse_sw_build_name_from_download_package(expected_sw)
        if BTS.active_sw[BTS.active_sw.find("_"):] == expected_sw[expected_sw.find("_"):]:
            info("Expected build is activated, OK")
        else:
            error(f"Build {expected_sw} is expected to be active, but build {BTS.active_sw} is active, NOK")
            if kpi_print:
                info("Because expected software is not active, we will skip all KPI calculations.")
                BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${False}")
            raise ExpectedSwBuildIsNotActive(f"Build {expected_sw} is expected to be active, "
                                             f"but build {BTS.active_sw} is active")

    def get_build_that_is_currently_active_on_bts(self, branch=None, save_to_pc=True, testpackage=None):
        """
        Downloads build that is currently active on BTS from artifactory to test PC.
        Branch is needed because Trunk SW on BTS is shown for example as SBTS23R1_ENB_9999_000777_000000.

        :param str branch: Branch for example SBTS00. Default is None and then it is parsed from the build name.
        :param bool save_to_pc: Default is True. If True saves build to /home/ute/logs folder of test PC. If False gives
                                url to package to WebEM.
        :param str testpackage: Default None, then gets basic package. If value is T1 or T2 gets testpackage,
        :return str: Return path to build that is saved to test PC.
        """
        if branch is None:
            branch = self.get_branch_of_active_build()
        build_to_get = "{}{}".format(branch, BTS.active_sw[BTS.active_sw.find("_"):])
        if "T" in build_to_get[-2]:
            build_to_get = build_to_get[:-2]
        if "_FSM3" in branch:
            build_to_get = "{}{}".format(branch.split("_FSM3")[0] if branch and "_FSM3" in branch else
                                         branch, BTS.active_sw[BTS.active_sw.find("_FSM3_"):])
        self.logger.debug(f"Build to get: {build_to_get}")
        if testpackage == "T1":
            return self.get_build_from_artifactory(build_to_get, release=branch, package_type="testpackage_T1_A54",
                                                   save_to_pc=save_to_pc)
        elif testpackage == "T2":
            return self.get_build_from_artifactory(build_to_get, release=branch, package_type="testpackage_T2_A54",
                                                   save_to_pc=save_to_pc)
        else:
            return self.get_build_from_artifactory(build_to_get, release=branch, package_type="A54",
                                                   save_to_pc=save_to_pc)

    def get_branch_of_active_build(self):
        """
        Gets branch of build that is currently active on BTS.
        """
        return self.get_branch_from_build_name(BTS.active_sw)

    def get_branch_from_build_name(self, build_name):
        """
        Get branch from the name of the build. This method supports Trunk, FSMr3 Trunk, non FSM3 branches that
        don't have _ in the name and FSM3 branches (that have _ in the name).

        :param str build_name: Name of the build for example SBTS24R2_FSM3_9999_231210_000001,
                                                             SBTS23R1_ENB_0000_001738_000000,
                                                             SBTS00_ENB_9999_231112_000015.

        """
        if "artifactory-espoo" in build_name:
            branch_pattern = re.compile(r".*build/(?P<branch>\w+)/(?P<build>.*)")
            match = branch_pattern.match(build_name)
            if match:
                branch = match.group("branch")
                info(f"Branch of artifactory SW build is: {branch}")
                return branch
            else:
                error(f"Couldn't parse branch from path '{build_name}'\nCheck the used regex.")
                return ""
        if "/" in build_name:
            self.logger.debug("Remove folder information...")
            bn = build_name[build_name.rfind("/")+1:]
            branch = "{}".format(bn[:bn.find("_")])
        else:
            branch = "{}".format(build_name[:build_name.find("_")])
        if "_FSM3_999" in build_name:
            self.logger.debug("_FSM3_999 in the name of build -> Branch is FSMr3 trunk: "
                              "SBTS00_FSM3")
            branch = "SBTS00_FSM3"
        elif "_ENB_999" in build_name:
            self.logger.debug("_ENB_999 in the name of build -> Branch is trunk: SBTS00")
            branch = "SBTS00"
        elif "FSM3" in build_name:
            self.logger.debug("FSM3 in the name of build -> Branch is non trunk FSM3")
            branch = "{}_FSM3".format(build_name[:build_name.find("_FSM3")])
        info(f"Branch of SW build {build_name} is: {branch}")
        return branch

    @staticmethod
    def _get_year_and_release_from_branch(branch):
        branch_regex = re.compile(r"SBTS(?P<year>\d+)R(?P<release>\d+)(|_FSM3)")
        match = branch_regex.match(branch)
        if match:
            year = int(match.group("year"))
            release = int(match.group("release"))
            return year, release
        else:
            error("Couldn't parse year and release from branch {}".format(branch))
            raise ScriptIssue

    def get_branch_and_check_if_same_or_newer_than_given(self, branch_to_compare):
        """
        Get branch of build that is currently active on BTS and check if it is same or newer than given branch.

        :param str branch_to_compare: Branch that is expected to be active on BTS for example
        :return bool: True if active branch is same or newer than expected branch, False if not.
        """
        active_branch = self.get_branch_of_active_build()
        if active_branch and "SBTS00" in active_branch:
            info(f"Branch of active SW is Trunk ({active_branch}) so it is the newest SW (newer than "
                 f"{branch_to_compare})")
            return True
        elif active_branch == branch_to_compare:
            info(f"Branch of active SW is same as {branch_to_compare}.")
            return True
        else:
            active_year, active_release = BTS._get_year_and_release_from_branch(active_branch)
            expected_year, expected_release = BTS._get_year_and_release_from_branch(branch_to_compare)
            if (active_year > expected_year) or (active_year == expected_year and active_release > expected_release):
                info(f"Branch of active SW ({active_branch}) is newer than {branch_to_compare}.")
                return True
            else:
                info(f"Branch of active SW ({active_branch}) is older than {branch_to_compare}.")
                return False

    def get_active_sw_of_bts(self):
        """ Get active SW. """
        # info("Active SW: {}".format(BTS.active_sw))
        self.update_sw_information()
        return BTS.active_sw

    def get_passive_sw_of_bts(self):
        """ Get passive SW. """
        # info("Passive SW: {}".format(BTS.active_sw))
        self.update_sw_information()
        return BTS.passive_sw

    def get_cell_resources(self):
        """Get cell resources"""
        if not self.cell_resources:
            self.cell_resources = BuiltIn().get_library_instance("CELL_RESOURCES")
        return self.cell_resources.get_corepools_of_cell()

    @staticmethod
    def check_sanity_of_user_given_value(user_given_value):
        """
        Check sanity of user given values

        :param str user_given_value: Name of BBPool. Name should be one of these BBPool11, BBPool12, BBPool21,
                                     BBPool22, BBPool31 or BBPool32.
        :raise ScriptIssue: if value is not in BBPool11, BBPool12, BBPool21, BBPool22, BBPool31 or BBPool32
        """
        if user_given_value not in ("BBPool11", "BBPool12", "BBPool21", "BBPool22", "BBPool31", "BBPool32"):
            error("Name of BB POOL should be BBPool11, BBPool12, BBPool21, BBPool22, BBPool31 or BBPool32."
                  "Given value {} is not allowed".format(user_given_value))
            raise ScriptIssue

    def check_that_user_given_bbpool_exists(self, bbpool_numbers):
        """
        Verify that user given BBPool(s) exists in the environment

        :param list bbpool_numbers: Numbers of BB Pools in a list. For example ["12", "22]
        :raise EnvironmentIssue: If required information is missing from the environment,
        :raise ScriptIssue: If user has given not suitable input.
        """
        environments_bbpools = []
        bbpools = list(self.admin.get_managed_objects("BBPOOL_L"))
        if bbpools:
            for bbpool in bbpools:
                if "distName" in bbpool:
                    self.logger.debug("Distname of bbpool is {}".format(bbpool["distName"]))
                    bbpool_dn = bbpool["distName"]
                    if bbpool_dn[bbpool_dn.rfind("-") + 1:] not in environments_bbpools:
                        environments_bbpools.append(bbpool_dn[bbpool_dn.rfind("-") + 1:])
                else:
                    error("distName is not found for BBPOOL_L")
                    raise EnvironmentIssue
            if environments_bbpools and bbpool_numbers:
                set1 = set(environments_bbpools)
                set2 = set(bbpool_numbers)
                self.logger.debug("environments_bbpools: {}({}),  bbpool_numbers: {}({})".format(
                    environments_bbpools, set1, bbpool_numbers, set2))
                if set1.intersection(set2):
                    self.logger.debug("All user given BB Pools are found from the used environment.")
                else:
                    error("There are BBPool{} in the environment. All BBPools given in testcase (BBPool{}) are not "
                          "found from the environment".format(", BBPool".join(set1), ", BBPool".join(set2)))
                    raise ScriptIssue
            else:
                error("No environments_bbpools and bbpool_numbers.")
                raise ScriptIssue
        else:
            error("BBPOOL_L object is not found. Check ims2 logs and take contact to script developer.")
            raise EnvironmentIssue

    def get_bbpool_from_user_given_values(self, user_given_value):
        """
        Creates BBPool list from user given values.

        :param str/list user_given_value: User can give value for example:
                        BBPool11, BBPool12, BBPool21, BBPool22, BBPool31 or BBPool32. User can also give multiple
                        BB Pools at the same time with list, for example [BBPool12, BBPool22]
        :return list: Returns list that includes user given BBPools in reset sufficient format.
        """
        bbpool_list = []
        number_list = []
        if isinstance(user_given_value, list):
            for value in user_given_value:
                self.check_sanity_of_user_given_value(value)
                value_split = value.split("BBPool") if value and "BBPool" in value else [value]
                number_list.append(value_split[1] if len(value_split) > 1 else "")
        elif isinstance(user_given_value, str):
            self.check_sanity_of_user_given_value(user_given_value)
            user_given_value_split = user_given_value.split("BBPool") if (
                    user_given_value and "BBPool" in user_given_value) else [user_given_value]
            number_list.append(user_given_value_split[1] if len(user_given_value_split) > 1 else "")
        self.check_that_user_given_bbpool_exists(number_list)
        bts_id = self.get_parameter_value_from_bts_info("btsId")
        for nmbr in number_list:
            bbpool_list.append("MRBTS-{}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-{}".format(bts_id, nmbr))
        return bbpool_list

    def get_fhs_from_user_selection(self, selected_fhs):
        fhs_list = self.admin.get_fhs_list()
        info("All found FHS of the environment: {}".format(fhs_list))
        if not fhs_list:
            error("There are no Fronthaul switches in this environment (FHS). Cannot run the test.")
            raise NoFronthaulSwitch
        for fhs in fhs_list:
            if "id" not in fhs:
                error("Key 'id' is missing from {}, something has changed in BTS SW".format(fhs_list))
                raise EnvironmentIssue
            if "internal" not in fhs["id"]:
                error("Parameter internal is missing from {}, something has changed in BTS SW".format(
                    fhs_list))
                raise EnvironmentIssue
            if selected_fhs[-1] == fhs["id"]["internal"][-1]:
                self.logger.debug("User has selected sane FHS ({} == {})".format(selected_fhs, fhs))
                self.logger.debug("Configuration information for FHS: {}".format(fhs["id"]["configuration"]))
                return fhs["id"]["configuration"]
        error("User given FHS ({}) is not found from the environment ({}).".format(selected_fhs, fhs_list))
        raise ScriptIssue("Unknown FHS selected")

    def nokia_nahka_rmod(self, unit_name):
        """
        Checks if Nokia nahka/made radio in question.

        :param str unit_name: Name of unit for example ARGA(1.1.1.1)
        :return bool: True or False
        """
        # TODO Move this method to RMOD library when it is done
        if unit_name[0] == "A":
            info("{} is Nokia nahka/made radio.".format(unit_name))
            return True
        else:
            self.logger.debug("{} is not Nokia nahka/made radio.".format(unit_name))
            return False

    def get_node_to_attach(self):
        """Get node to which attach will be made"""
        if self.side == "1":
            return "0x1018"
        else:
            return "0x2018"

    def check_if_mimo_mode_and_sync_sign_transmission_mode(self):
        """
        Check parameters of class NOKLTE:LNCEL_FDD or NOKLTE:LNCEL_TDD.
        Check if Mimo mode for cell is not SingleTX. Value is in dlMimoMode element of the class.
        Check if Sync sign transmission mode for cell is TxDiv. Value is in syncSigTxMode element of the class.

        :return bool: True if dlMimoMode is not SingleTX and syncSigTxMode is TxDiv, otherwise return False.
        """
        mimo_mode_singe_tx = []
        other_than_tx_div_more = []
        object_dist_names = self.scf.get_distname_based_on_class("NOKLTE:LNCEL_FDD")
        mimo = False
        sync_sig = False
        if not object_dist_names:
            object_dist_names = self.scf.get_distname_based_on_class("NOKLTE:LNCEL_TDD")
        for object_dist_name in object_dist_names:
            dl_mimo_mode = self.scf.get_value_from_scf(dist_name=object_dist_name, p_name="dlMimoMode",
                                                       allow_missing=True)
            if not dl_mimo_mode:
                info(f"dlMimoMode is not found for {object_dist_name} it is optional parameter. Default is TXDiv.")
                dl_mimo_mode = "TXDiv"
            info("'Mimo mode' is ({}, dlMimoMode)= {}".format(object_dist_name, dl_mimo_mode))
            if dl_mimo_mode == "SingleTX":
                mimo_mode_singe_tx.append(object_dist_name)
            sync_sig_trans = self.scf.get_value_from_scf(dist_name=object_dist_name, p_name="syncSigTxMode",
                                                         allow_missing=True)
            if not sync_sig_trans:
                info(f"syncSigTxMode is not found for {object_dist_name} it is optional parameter. Default is SingleTx")
                sync_sig_trans = "SingleTx"
            info("'Sync sign transmission mode' is ({}, syncSigTxMode)= {}".format(object_dist_name, sync_sig_trans))
            if sync_sig_trans != "TxDiv":
                other_than_tx_div_more.append(object_dist_name)
        if mimo_mode_singe_tx and len(mimo_mode_singe_tx) < len(self.cells.keys()):
            info("Mimo mode of some cells is SingleTX.")
        else:
            info("Mimo mode of all cells is other than SingleTX.")
            mimo = True
        if other_than_tx_div_more and len(other_than_tx_div_more) < len(self.cells.keys()):
            info("Sync sign transmission mode of some cells is other than TxDiv.")
        else:
            info("Sync sign transmission mode of all cells is TxDiv.")
            sync_sig = True
        return mimo and sync_sig

    @staticmethod
    def _check_if_both_radios_have_tx_on_cell(cell_and_directions_of_selected, cell_and_directions_of_rmod):
        """Checks if both radios have some TX"""
        tx_on_rmod1 = False
        tx_on_rmod2 = False
        for val in cell_and_directions_of_selected.values():
            if any(tx for tx in val if "TX" in tx):
                tx_on_rmod1 = True
        for val2 in cell_and_directions_of_rmod.values():
            if any(tx2 for tx2 in val2 if "TX" in tx2):
                tx_on_rmod2 = True
        return tx_on_rmod1 and tx_on_rmod2

    def check_if_cell_resources_on_two_radios(self, radio_name, check_also_tx=True, print_to_eventlog=True):
        """
        Check if cell resources are reserved from two different RMODs (like in H-config). If check_also_tx is True
        checks also if cell has more than one TX (1TX in RMOD1 ja 1 TX RMOD2).

        :param str radio_name: Name of radio.
        :param bool print_to_eventlog: If True prints to eventlog, if False prints just to debugger log.
        :param bool check_also_tx: If True check that other radio also has some TX, if False this check is skipped.
        :return bool: Returns either just cell_resources_on_two_radio or if check_also_tx is True also check_also_tx.
        """
        cell_resources_on_two_radio = False
        cell_on_both_radios_has_tx = False
        cells_of_radio = self.get_cells_of_radio(radio_name, print_to_eventlog)
        cell_and_directions_of_selected = self.rmod_lib.get_directions_of_cell_on_radio(radio_name,
                                                                                        cells_of_radio)
        for radio in BTS.radios:
            rmod_cells = self.get_cells_of_radio(radio.name, print_to_eventlog=False)
            if radio.name != radio_name:
                if sorted(rmod_cells) == sorted(cells_of_radio):
                    cell_resources_on_two_radio = True
                    if print_to_eventlog:
                        info("Cell resources are reserved from two different RMODs: {}: {} and {}: {}".format(
                            radio_name, cells_of_radio, radio.name, rmod_cells))
                    else:
                        self.logger.debug("Cell resources are reserved from two different RMODs: {}: {} and {}: "
                                          "{}".format(radio_name, cells_of_radio, radio.name, rmod_cells))
                    if check_also_tx:
                        cell_and_directions_of_rmod = self.rmod_lib.get_directions_of_cell_on_radio(
                            radio.name, rmod_cells)
                        if self._check_if_both_radios_have_tx_on_cell(cell_and_directions_of_selected,
                                                                      cell_and_directions_of_rmod):
                            cell_on_both_radios_has_tx = True
                            if print_to_eventlog:
                                info("Cell(s) have TX on both radios.")
                            else:
                                self.logger.debug("Cell(s) have TX on both radios.")
                        else:
                            if print_to_eventlog:
                                info("No TX on cells on both radios.")
                            else:
                                self.logger.debug("No TX on cells on both radios.")
                    else:
                        break
        if check_also_tx:
            return cell_resources_on_two_radio, cell_on_both_radios_has_tx
        else:
            return cell_resources_on_two_radio

    def check_if_lte441a_feature_is_active(self, hot_remove_insert=""):
        """
        Check if LTE441-a feature is active. Feature is expected to be active if cell has more than 1 TX (TXs can be in
        same RMOD or in different RMOD), txPathFailureMode = keepCellInService, Mimo mode for cell != SingleTX and
        Sync sign transmission mode for cell = TxDiv. NOTE in rmod hot remove insert cases also

        NOTE if RMOD hot remove case is in question need to check in addition that cell resources are reserved from two
        different RMODs (like in H-config) and cell has more than one TX (1TX in RMOD1 ja 1 TX RMOD2).

        More info about LTE441-a and cell states can be found from LTE_OAM_12659_FDD&TDD_v3.xlsx
        and http://oam.emea.nsn-net.net/btsom_efs/State_Management/States/CellStates/StateMgmt_CellAvailabilityStatus
        Management.html
        """
        if self.check_if_5g_environment(print_eventlog=False):
            info("5G environment. Feature LTE441-a is not for 5G and it is not active.")
            return False
        at_least_two_tx_per_cell = self.cell_operations.check_if_cells_have_at_least_two_tx()
        tx_path_failure_mode = False
        mimo_sync_sig_mode = self.check_if_mimo_mode_and_sync_sign_transmission_mode()
        object_distnames = self.scf.get_distname_based_on_class("NOKLTE:LNBTS")
        if object_distnames:
            object_distname = object_distnames[0]
            tx_path_mode = self.scf.get_value_from_scf(dist_name=object_distname, p_name="txPathFailureMode",
                                                       allow_missing=True)
            if not tx_path_mode:
                info(f"Value for 'TX path failure mode' is not found for {object_distname} it is optional parameter. "
                     f"Default is keepCellInService.")
                tx_path_mode = "keepCellInService"
            info("Value for 'TX path failure mode' is (({}, txPathFailureMode)= {})".format(object_distname,
                                                                                            tx_path_mode))
            if tx_path_mode == "keepCellInService":
                tx_path_failure_mode = True
        else:
            warning("Class NOKLTE:LNBTS is not found from SCF.xml, cannot check if txPathFailureMode.")
        if hot_remove_insert:  # if radio is given
            cell_resources_on_two_radio, cell_on_both_radios_has_tx = self.check_if_cell_resources_on_two_radios(
                hot_remove_insert)
            lte441a_active = (at_least_two_tx_per_cell and tx_path_failure_mode and mimo_sync_sig_mode
                              and cell_resources_on_two_radio and cell_on_both_radios_has_tx)
        else:
            lte441a_active = at_least_two_tx_per_cell and tx_path_failure_mode and mimo_sync_sig_mode
        if lte441a_active:
            info("Feature LTE441-a is active.")
            return True
        else:
            info("Feature LTE441-a is not active.")
            return False

    def get_s1_ip(self):
        """Gets MplaneIp4V address from admin or if not found there from tl parameters."""
        mplane_ip = self.get_parameter_value_from_bts_info("btsMplaneIp4V")
        if not mplane_ip:
            mplane_ip = self.get_mplane_ip_from_tl_param()
        if not mplane_ip:
            error("Couldn't find btsMplaneIp4V information or IP from tl parameters")
            raise EnvironmentIssue
        self.logger.debug("S1 ip is {}".format(mplane_ip))
        return mplane_ip

    def take_s1_connection_to_admin(self):
        """Searches S1 IP address and creates connection to admin to it."""
        try:
            mplane_ip = self.get_s1_ip()
            if not mplane_ip:
                error("Could not get btsMplaneIp4V address, cannot make admin connection to it")
                raise EnvironmentIssue
            info("Take admin connection to {}".format(mplane_ip))
            # self.admin.connect_to(bts_host=mplane_ip, admin_api_log_dir=self.logger.create_admin_folder(), name='s1')
            release = self.get_sw_release_via_targetbd(lmp_ip=mplane_ip)
            self.admin.setup_admin(bts_host=mplane_ip, admin_api_log_dir=self.logger.create_admin_folder(), name="s1",
                                   release=release)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException) as admin_error:
            error("Unable to take s1 connection to admin. {}:{} was raised.\n{}".format(
                admin_error.__class__.__name__, admin_error,
                ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))))
            raise BTSConnectionFailure

    def teardown_selected_admin_connection(self, selected_admin="s1"):
        """
        Teardown selected admin connection.

        :param str selected_admin: Name of admin connection that is disconnected. Default is s1.
        """
        self.logger.debug("Disconnect '{}' admin connection".format(selected_admin))
        try:
            self.admin.teardown(connection=selected_admin)
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, AdminApiProcedureFailureException,
                AdminApiProcedureTimeoutException, AdminApiNoResponseException, AdminApiTerminatedException,
                AdminApiConnectionClosedException, AliasInUse) as e:
            self.logger.debug(f"While tearing down selected admin connection, ERROR {e.__class__.__name__}:{e}")
            print(f"While tearing down selected admin connection, ERROR {e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    @staticmethod
    def get_start_time():
        """Gets current time"""
        return datetime.datetime.now()

    @staticmethod
    def calculate_duration(start_time):
        """
        Calculates duration from the given start time to this time

        :param timedelta start_time: datetime object.
        """
        time_now = datetime.datetime.now()
        duration = (time_now - start_time).total_seconds()
        info(f"SW update request took {duration} seconds.")

    def get_active_antennas_of_radio_and_cells(self, radio, print_to_eventlog=True):
        """
        Get active antennas of radio, it's direction and cells that are affected by it

        :param object radio: Radio object.
        :param bool print_to_eventlog: If True prints to eventlog, if False prints just to debugger log.
        :return dict: Returns dictionary where antenna as key and direction and affected cells as value
        """
        antenna_direction_cells = {}
        self.logger.debug("Parse radio, antenna, tx rx and affected cells from this: {}".format(BTS.antennae))
        for antenna in BTS.antennae:
            self.logger.debug("Antenna in BTS.antennae: {} - {} - {} - {}".format(
                antenna.label, antenna.connected_radios, antenna.direction, antenna.connected_cells))
            if radio.scf_dist_name in antenna.connected_radios and antenna.direction in ("TX/RX", "TX", "RX"):
                if antenna.label not in antenna_direction_cells:
                    antenna_direction_cells[antenna.label] = (antenna.direction, antenna.connected_cells)
                else:
                    self.logger.debug("This is already: {}: {} ({}) {}\nconnected_radios: {}"
                                      "\nconnected_cells: {}".format(antenna.label, antenna.dist_name,
                                                                     antenna.direction, antenna.runtime_dist_name,
                                                                     antenna.connected_radios, antenna.connected_cells))
        if print_to_eventlog:
            info("{} has {} active antennas: {}".format(radio.name, len(antenna_direction_cells.keys()),
                                                        antenna_direction_cells))
        else:
            self.logger.debug("{} has {} active antennas: {}".format(radio.name, len(antenna_direction_cells.keys()),
                                                                     antenna_direction_cells))
        BTS.rmod_ant_direction_and_cell = antenna_direction_cells
        return antenna_direction_cells

    def select_antenna_from_active_antennas_of_radio_by_position(self, rx_tx, radio, print_to_eventlog=True):
        """
        Get active RX or TX of radio, it's direction and cells that are affected by it.

        :param str rx_tx: Can have value TX1, TX2,...TX8, RX1, RX2,...RX8 or if all active TX are wanted All_TX or
                          if all active RXs are wanted All_RX.
        :param object radio: Radio object.
        :param bool print_to_eventlog: If True prints to eventlog, if False prints just to debugger log.
        :return str/list: The antenna to which TX or RX is, for example ANT1 or if all TX/RX that are wanted list of
                          antennas for example ['ANT1', 'ANT3', 'ANT5']
        """
        ant_txrx_cell = self.get_active_antennas_of_radio_and_cells(radio, print_to_eventlog=True)
        active_ant = []
        if ant_txrx_cell:
            for ant in ant_txrx_cell:
                if "RX" in rx_tx and ant_txrx_cell[ant][0] in ("TX/RX", "RX"):
                    if ant in ("PHYANT", "OPT_IF2", "OPT_IF3", "OPT_IF4"):
                        ant = self.modify_antenna_label(ant)
                    active_ant.append(ant)
                elif "TX" in rx_tx and ant_txrx_cell[ant][0] in ("TX/RX", "TX"):
                    if ant in ("PHYANT", "OPT_IF2", "OPT_IF3", "OPT_IF4"):
                        ant = self.modify_antenna_label(ant)
                    active_ant.append(ant)
            if not active_ant:
                error("Active antennas were not found from {} ".format(radio))
                raise EnvironmentIssue
            active_ant = sorted(active_ant)
            if rx_tx in ("All_TX", "All_RX"):
                if print_to_eventlog:
                    info("There is {} active {}s on the radio {} ({}).".format(
                        len(active_ant), rx_tx.split("_")[1] if rx_tx and "_" in rx_tx else
                        rx_tx, radio.name, active_ant))
                else:
                    self.logger.debug("There is {} active {}s on the radio {} ({}).".format(
                        len(active_ant), rx_tx.split("_")[1] if rx_tx and "_" in rx_tx else
                        rx_tx, radio.name, active_ant))
                return active_ant
            if len(active_ant) < int(rx_tx[-1]):
                error("There is {} active {}s on the radio {}, user have give {}, impossible selection of "
                      "direction.".format(len(active_ant), rx_tx[:-1], radio, rx_tx))
                raise ScriptIssue
            selected_antenna = active_ant[int(rx_tx[-1]) - 1]
            if print_to_eventlog:
                info("{} is in {} of {}.".format(rx_tx, selected_antenna, radio.name))
            else:
                self.logger.debug("{} is in {} of {}.".format(rx_tx, selected_antenna, radio.name))
            return selected_antenna
        else:
            error("Method get_active_antennas_of_radio_and_cells didn't get information.")
            raise ScriptIssue

    def modify_antenna_label(self, ant):
        """
        If antenna label is "PHYANT", "OPT_IF2" or "OPT_IF3"

        :param str ant: Can have value PHYANT, OPT_IF2, OPT_IF3 or OPT_IF4
        :return str: Returns ANT<number>, for example ANT1
        """
        self.logger.debug(
            "Label of antenna is {}, modify it to form ANT<number> so it can be used in tests".format(ant))
        if ant == "PHYANT":
            ant = "ANT1"
        elif ant == "OPT_IF2":
            ant = "ANT2"
        elif ant == "OPT_IF3":
            ant = "ANT3"
        elif ant == "OPT_IF4":
            ant = "ANT4"
        return ant

    def get_cells_of_resource_on_antenna(self, rmod, resource, print_to_eventlog=True):
        """
        This method parses cells that are on the selected resource on the selected antenna.

        :param object rmod: Radio object.
        :param str resource: Resource on radio, TX1-TX8 or RX1-RX8
        :param bool print_to_eventlog: Default is True and prints to eventlog
        :return list: Returns list of cells affected by the resource in the selected antenna.
        """
        if resource == "LTX":
            self.logger.debug("Resource is LTX so all cells of radio are affected -> return all cells of rmod")
            return self.get_cells_of_radio(rmod.name, print_to_eventlog=False)
        antenna_direction_cells = self.get_active_antennas_of_radio_and_cells(rmod, print_to_eventlog)
        antenna = self.select_antenna_from_active_antennas_of_radio_by_position(resource, rmod, print_to_eventlog)
        if antenna in antenna_direction_cells:
            return antenna_direction_cells[antenna][1]
        else:
            error("Parsed that {} is in antenna {}, but antenna was not found from active antennas {}.".format(
                resource, antenna, antenna_direction_cells))
            raise ScriptIssue

    def check_failed_component_and_get_dumps(self):
        """
        This method checks failed component from ims2 and collects dumps to test logs if the dumps are available.
        """
        info("Collect CORE_DUMPs.")
        mos = self.admin.get_managed_objects("CORE_DUMP_L")
        if not mos:
            error("CORE_DUMP_L is not found from ims2 even though alarm 6450 was found as active.")
            self.smod_lib.get_restart_cause()
        else:
            already_collected = []
            for mo in mos:
                element_list = ["path", "processId", "name", "nodeId", "signal"]  # find for all core_dumps
                collected = list(element_list)
                mo_distname = mo["distName"]
                current_list = []
                isfound = False
                parameter_dict = mo["parameters"]
                for elem in element_list:
                    if elem in parameter_dict:
                        collected.remove(elem)
                        im_element = "{e}: {ev}".format(e=elem, ev=str(parameter_dict[elem]))
                        current_list.append(im_element)
                if already_collected:
                    for ac in already_collected:
                        if current_list == ac[1:]:
                            isfound = True
                if not isfound:  # current_list not in already_collected:
                    current_list.insert(0, "Failed component: {c}".format(c=mo_distname))
                    already_collected.append(current_list)
                if collected:
                    error("Couldn't find information of parameters {p} of {c}".format(p=collected, c=mo_distname))
                    # raise EnvironmentIssue  # not raised so can parse alla items, test is failed due unallowed alarms
            if already_collected:
                collected_paths = []
                for cl in already_collected:
                    path_name = ""
                    for el in cl:
                        # smod_object = None
                        error("{e}".format(e=el))
                        # check if fullrack and from which side the fault is
                        if BTS.fullrack and "Failed component" in el:
                            for smod in BTS.smods:
                                if "BTS_L-1" in el:  # left side
                                    if "BTS_L-1" in smod.dist_name and not smod.master:
                                        info("Component has failed from the extension SMOD, {}".format(smod.name))
                                    elif "BTS_L-1" in smod.dist_name and smod.master:
                                        info("Component has failed from the master SMOD, {}".format(smod.name))
                                    # smod_object = smod
                                elif 'BTS_L-4' in el:  # right side
                                    if "BTS_L-4" in smod.dist_name and not smod.master:
                                        info("Component has failed from the extension SMOD, {}".format(smod.name))
                                    elif "BTS_L-4" in smod.dist_name and smod.master:
                                        info("Component has failed from the master SMOD, {}".format(smod.name))
                                    # smod_object = smod
                        el_split = el.split('path: ') if el and 'path: ' in el else [el]
                        path_name = el_split[1] if len(el_split) > 1 else ""
                        collected_paths.append(path_name)
                        if path_name:
                            info("Get file {} to test logs.".format(path_name))
                            collect_logs_lib = BuiltIn().get_library_instance("COLLECTLOGS")
                            collect_logs_lib.get_file_or_folder_from_bts_to_test_logs(path_name)
                self.smod_lib.get_restart_cause()

    def teardown_suite_admin(self):
        """Teardown admin connection that is created in 'Common Suite Setup'."""
        try:
            info("Teardown suite admin")
            self.admin.teardown_admin(connection="default")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException) as admin_error:
            self.logger.debug(f"Unable to teardown suite admin. "
                              f"{admin_error.__class__.__name__}:{admin_error} was raised."
                              f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")

    def connect_suite_admin(self, retry=0, always_default=False, from_common=False):
        """
        Connect suite admin connects default admin connection that was created in 'Common Suite Setup'.

        :param int retry: Number of retries if connection fails.
        :param bool always_default: If True, always use default admin IP.
        :param bool from_common: Default False. Only in call from common_resources.robot the value is True.
        :return bool: True if connection is successful.
        :returns: True if connection ok
        :raise BTSConnectionFailure: If unable to connect suite admin.
        """
        if from_common:
            use_mplane_ip = BuiltIn().get_variable_value("${USE_MPLANE_IP}")
            if use_mplane_ip and use_mplane_ip in (True, "true", "TRUE", "True"):
                default_ip = self.get_mplane_ip_from_tl_param()
                if not default_ip:
                    error("Variable USE_MPLANE_IP is set to True but M-Plane IP address is not found from tl "
                          "parameters.")
                    raise EnvironmentIssue("M-Plane IP address is not found from tl parameters.")
                info(f"Variable USE_MPLANE_IP is set to {use_mplane_ip}. M-Plane IP is {default_ip} (from init-file).")
                BuiltIn().set_suite_variable("${DEFAULT_ADMIN_IP}", default_ip)
                BTS.default_smod_ip = default_ip
        info("Connect suite admin")
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        try:
            suite_admin_dir = BuiltIn().get_variable_value("${SUITE_ADMIN_DIR}")
            release = self.get_sw_release_via_targetbd(lmp_ip=BTS.default_smod_ip)
            if always_default:
                self.admin.connect_to(bts_host=BTS.default_smod_ip, admin_api_log_dir=suite_admin_dir, timeout=180,
                                      release=release)
            else:
                if self.collect_logs.rfs:
                    remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                    other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
                    if other_master:
                        self.admin.connect_to(bts_host=remote_mplane_ip, admin_api_log_dir=suite_admin_dir, timeout=180,
                                              release=release)
                    else:
                        self.admin.connect_to(bts_host=BTS.default_smod_ip, admin_api_log_dir=suite_admin_dir,
                                              timeout=180, release=release)
                else:
                    self.admin.connect_to(bts_host=BTS.default_smod_ip, admin_api_log_dir=suite_admin_dir, timeout=180,
                                          release=release)
            return True
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException, AliasInUse
                ) as admin_error:
            if retry > 2:
                info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
                error(f"Unable to connect suite admin. {admin_error.__class__.__name__}:{admin_error} was raised.")
                raise BTSConnectionFailure("Unable to connect suite admin.")
            else:
                info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
                info(f"Unable to connect suite admin. {admin_error.__class__.__name__}:{admin_error} was raised.\n"
                     f"Wait 90s and try again to connect suite admin. Retry {retry + 1}/3.")
                BuiltIn().sleep("90s")
                self.connect_suite_admin(retry=retry + 1, always_default=always_default, from_common=from_common)

    def setup_admin_connection(self, bts_ip, interval, admin_alias, timeout):
        """
        Setup admin connection creates admin connection to given ip with given interval and alias

        :param str admin_alias: Admin connection that will be reset.
        :param str bts_ip: IP address of BTS.
        :param int interval: Interval of admin connection
        :param int timeout: Timeout for setup
        """
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
                BTS.default_smod_ip = bts_ip
        try:
            self.logger.debug(f"Check that {bts_ip} replies to ping before admin setup.")
            self.ping_ip_until_disconnection_or_reconnection(ip_to_ping=bts_ip, disconnection=False, time_to_wait=300,
                                                             save_pings_to_file=True, level_in_error="info")
            release = self.get_sw_release_via_targetbd(lmp_ip=bts_ip)
            self.admin.setup_admin(bts_host=bts_ip, update_interval=interval, name=admin_alias,
                                   admin_api_log_dir=self.logger.create_admin_folder(), timeout=timeout,
                                   release=release)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_err:
            return admin_err
        return None

    def reset_admin_connection(self, admin="log_admin", bts_ip=default_smod_ip, raise_error=True):
        """
        Reset the given admin connection.

        :param str admin: Admin connection that will be reset. Default is log_admin.
        :param str bts_ip: IP address of BTS. Default is 192.168.255.129
        :param bool raise_error: Default is True and then test will fail of there are any problems. If False then fails
                                 if admin connection cannot be recreated.
        """
        loop = "Loop {}: ".format(self.logger.loop + 1) if self.logger.loop else ""
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
                BTS.default_smod_ip = bts_ip
        info(f"Reset {admin} connection")
        try:
            self.admin.teardown_admin(connection=admin)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            warning(f"Problems when tearing down admin connection {admin_error.__class__.__name__}:{admin_error} "
                    f"(this will not fail the test)")
        BuiltIn().sleep("1s")
        if self.collect_logs.rfs:
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
            if other_master:
                info(f"RFS environment. Change given ip {bts_ip} to connect to remote BTS {remote_mplane_ip}.")
                bts_ip = remote_mplane_ip
        admin_err = self.setup_admin_connection(bts_ip, 250, admin, 180)
        if admin_err and admin_err.__class__.__name__ == "AdminApiTerminatedException":
            if raise_error:
                error("Admin connection was terminated, we were unable to setup admin connection.\nWaiting 30s and "
                      "try to reconnect again (NOTE this will fail the test even if reconnection is successful so "
                      "we will have logs about admin reconnection problems).")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            else:
                warning("Admin connection was terminated, unable to setup admin connection.\nWait 30s and try to "
                        "reconnect again (NOTE test will not fail to this if connection is later successful because "
                        "raise_error is False).")
            info(f"{admin_err.__class__.__name__}:{admin_err} was raised.\n"
                 f"{''.join(format_exception(type(admin_err), admin_err, admin_err.__traceback__))}")
            BuiltIn().sleep("30s")
            admin_err = self.setup_admin_connection(bts_ip, 250, admin, 300)
        elif admin_err and admin_err.__class__.__name__ == "AdminApiConnectionClosedException":
            if raise_error:
                error(f"Admin connection was closed, we were unable to setup admin connection. There may be reset "
                      f"that is causing this.\nPing IP {bts_ip}(NOTE this will fail the test even if reconnection "
                      f"is successful so we will have logs about admin reconnection problems).")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            else:
                warning(f"Admin connection was closed, unable to setup admin connection.\nPing IP {bts_ip} and try to "
                        f"reconnect again (NOTE test will not fail to this if connection is later successful because "
                        f"raise_error is False).")
            info(f"{admin_err.__class__.__name__}:{admin_err} was raised.\n"
                 f"{''.join(format_exception(type(admin_err), admin_err, admin_err.__traceback__))}")
            self.ping_ip_until_disconnection_or_reconnection(ip_to_ping=bts_ip, disconnection=False, time_to_wait=300,
                                                             save_pings_to_file=True, level_in_error="info")
            admin_err = self.setup_admin_connection(bts_ip, 250, admin, 300)
        if admin_err:
            info(f"{''.join(format_exception(type(admin_err), admin_err, admin_err.__traceback__))}")
            error(f"{loop}Unable to reset admin connection named to {admin}. "
                  f"{admin_err.__class__.__name__}:{admin_err} was raised.")
            raise BTSConnectionFailure(f"Unable to reset admin connection named to {admin}.")

    def reset_unit_with_error_handling(self, unit, reset_type="Warm", timeout=600, detailed_output=True,
                                       admin_connection="log_admin", allow_error=False):

        """
        Reset unit with error handling.

        :param str unit: dist_name of unit for example
                         /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
        :param str reset_type: Type of reset. Default is Warm can be Soft, Hard, Warm, PowerReset.
        :param int timeout: Time out for reset. Default is 600 seconds.
        :param bool detailed_output: Default value is True.
        :param str admin_connection: Name of admin connection. Default is log_admin.
        :param bool allow_error: If True allows error to be raised and only prints the error.
        """
        try:
            print(f"Request unit {unit} with {reset_type} reset.")
            self.admin.reset_unit(dist_name=unit, reset_type=reset_type, timeout=int(timeout),
                                  detailed_output=detailed_output, connection=admin_connection)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException) as admin_error:
            if allow_error:
                info(f"Error noticed when trying to reset unit {unit}. {admin_error.__class__.__name__}:{admin_error} "
                     f"was raised. Errors are allowed, most likely timeout is just set too tight for testing purposes.")
                return
            else:
                error(f"Error noticed during reset of unit {unit}. {admin_error.__class__.__name__}:{admin_error} was "
                      f"raised.{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                raise UnitResetFailed

    def wait_admin_connection(self, admin_connection="log_admin", bts_ip=default_smod_ip, wait_admin=300,
                              connect_always=False):
        """
        Waits for admin connection and if it is available and ims logs were successfully fetch resets it.

        :param str admin_connection: Name of admin connection. Default is log_admin.
        :param str bts_ip: IP address of BTS. Default is 192.168.255.129.
        :param int wait_admin: Time to wait for admin connection. Default is 300 seconds.
        :param bool connect_always: If True waits for admin connection always. Default is False.
        """
        a_error = ""
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if bts_ip == "192.168.255.129":
            if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
                BTS.default_smod_ip = bts_ip
        if self.collect_logs.ims_file_name_after_swdl or connect_always:
            info("Reconnecting admin...")
            admin_ok = False
            start_time = datetime.datetime.now()
            try_time = 0
            release = self.get_sw_release_via_targetbd(lmp_ip=bts_ip)
            admin_folder = self.logger.create_admin_folder()
            if self.collect_logs.rfs:
                remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
                other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
                if other_master:
                    self.logger.debug(f"RFS environment and other is master. Change IP {bts_ip} to {remote_mplane_ip}")
                    bts_ip = remote_mplane_ip
            while (datetime.datetime.now() - start_time).total_seconds() < int(wait_admin) and not admin_ok:
                try:
                    try_time += 1
                    self.logger.debug(f"Try to connect to admin {try_time}. time.")
                    self.admin.connect_to(
                        bts_host=bts_ip, update_interval=250, admin_api_log_dir=admin_folder, name=admin_connection,
                        timeout=10, release=release)
                    # self.admin.setup_admin(bts_host=bts_ip, update_interval=250, admin_api_log_dir=admin_folder,
                    #                        timeout=10, name=admin_connection)
                    info("Admin connection is now available.")
                    admin_ok = True
                except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                        AdminApiTerminatedException, AdminApiProcedureTimeoutException,
                        AdminApiNoResponseException, AliasInUse) as admin_error:
                    self.logger.debug(f"No admin connection yet {admin_error.__class__.__name__}:{admin_error}. "
                                      f"Try again.")
                    a_error = (f"Unable to connect to admin in {wait_admin}s wait time. "
                               f"{admin_error.__class__.__name__}:{admin_error} was raised.")
                    self.logger.debug(
                        f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            if not admin_ok:
                info("Admin connection was not successfully made with connect_to method, try with setup_admin method.")
                try:
                    self.admin.setup_admin(bts_host=bts_ip, update_interval=250, name=admin_connection,
                                           admin_api_log_dir=self.logger.create_admin_folder(), timeout=180,
                                           release=release)
                    info("Admin connection is now available (with setup_admin method).")
                    admin_ok = True
                except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                        AdminApiTerminatedException, AdminApiProcedureTimeoutException,
                        AdminApiNoResponseException, AliasInUse) as admin_error:
                    self.logger.debug(f"No admin connection {admin_error.__class__.__name__}:{admin_error}. ")
                    a_error = (f"Unable to connect to admin with {wait_admin}s wait time. "
                               f"{admin_error.__class__.__name__}:{admin_error} was raised.")
                    info(f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            if not admin_ok:
                if a_error:
                    err_text = a_error
                else:
                    err_text = f"Unable to connect to admin in {wait_admin}s wait time."
                error(err_text)
                raise BTSConnectionFailure(err_text)
            info("Admin connection reset done.")

    def check_if_admin_connection_reset_can_be_done(self, admin_connection="log_admin", always_reset=False):
        """
        Check if admin connection reset can be done. Admin connection can be reset if collecting of ims2 log has
        successfully done.

        :param str admin_connection: Name of admin connection. Default is log_admin.
        :param bool always_reset: If True, resets admin connection always, even-thought ims was not successfully
                                  collected when SWDL was made. If False resets admin connection only if ims was
                                  successfully collected after SWDL.
        """
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if self.collect_logs.ims_file_name_after_swdl:
            info("IMS file was successfully collected after SWDL, we may reset the admin connection.\nTeardown admin "
                 "connection")
            self.teardown_selected_admin_connection(selected_admin=admin_connection)
        elif always_reset:
            info("IMS file was not collected after SWDL. Reset the admin connection anyway because always_reset=True"
                 ".\nTeardown admin connection")
            self.teardown_selected_admin_connection(selected_admin=admin_connection)
        else:
            info("There is no ims2 file from the time after SWDL and always_reset was not set to True, we cannot reset "
                 "admin connection.")

    def timestamp_from_bts(self, via_ssh=True, ip=default_smod_ip):
        """
        Get power on timestamp from BTS

        :param via_ssh: If True gets timestamp via SSH, if False gets timestamp from syslog
        :param str ip: IP address of BTS. Default is 192.168.255.129
        :return datetime-object: Returns datetime object of bts time
        """
        if via_ssh:
            command = "date -u +%s"
            power_on_epoch = str(self.ssh.send_command_to_smod_by_ssh(command, return_output=True, ip_to_connect=ip))
            return datetime.datetime.utcfromtimestamp(int(power_on_epoch)).strftime('%c')
        else:
            try:
                syslog = BuiltIn().get_library_instance("SYSLOGSEARCH")
                syslog_time, bts_time = syslog.get_time_of_last_syslog_line(bts_time=True)
                return syslog_time, bts_time
            except (TypeError, AttributeError) as e:
                error(f"Error {e.__class__.__name__}:{e} was raised. Cannot get PC and BTS syslog times.\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                raise EnvironmentIssue

    def current_test_loop(self):
        """
        Return current test loop as integer.
        """
        loop = self.logger.loop + 1
        print(f"Current test loop is {loop}")
        return loop

    def update_software_to_fhs(self, all_suite_variables):
        """
        Update software to FHS method first gets build from artifactory and then runs script that updates the
        software. Note that user has to provide FHS_BUILD_TYPE, FHS_BUILD_FOLDER, and FHS_PRODUCT suite variables.

        :param dict all_suite_variables: All suite variables.
        """
        if ('${FHS_BUILD_TYPE}' in all_suite_variables and '${FHS_BUILD_FOLDER}' in all_suite_variables and
                '${FHS_PRODUCT}' in all_suite_variables):
            fhs_build_type = BuiltIn().get_variable_value("${FHS_BUILD_TYPE}")
            fhs_build_folder = BuiltIn().get_variable_value("${FHS_BUILD_FOLDER}")
            fhs_product = BuiltIn().get_variable_value("${FHS_PRODUCT}")
            fhs_build_name = self.get_fhs_build_from_artifactory(fhs_build_type, fhs_build_folder, fhs_product)
            if not self.collect_logs:
                self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
            self.collect_logs.give_command_to_terminal(
                "chmod +x /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/FhsSwUpdateScripts/"
                "lzma_upload.sh", print_to_eventlog=False)
            self.run_fhs_swdl_and_check_if_swdl_was_ok(fhs_build_name)
        else:
            error("Suite variables FHS_BUILD_TYPE, FHS_BUILD_FOLDER and FHS_PRODUCT are not given.")
            raise InvalidUserInput("Suite variables FHS_BUILD_TYPE, FHS_BUILD_FOLDER and FHS_PRODUCT are not given.")

    def check_if_fhs_sw_is_updated(self, fhs_build_name, output):
        """
        Check if fhs sw is updated.

        :param str fhs_build_name: Name of the build that was updated to FHS unit.
        :param str output: Output of the sw man shell commands
        """
        self.logger.debug("check_if_fhs_sw_is_updated")
        pattern = r"name:\s*(\S+)\s*version:\s*(\S+)\s*integrity:\s*(\S+)\s*usage:\s*(\d+)\s*-\s*it's\s*(\w+)"
        matches = re.findall(pattern, output)
        for match in matches:
            name, version, integrity, usage, status = match
            print(f"Name: {name}, Usage: {usage}, Status {status}")
            if name == fhs_build_name:
                if status and status == "active":
                    info(f"Software {name} is updated to FHS unit and is active.")
                    return True
                elif status and status == "passive":
                    error(f"Software {name} is found from FHS unit, but it is as passive.")
                    return False
                else:
                    error(f"Software {name} is not found from active nor passive. NOK.")
                    return False
        error(f"Software {fhs_build_name} is not found from output {output}. NOK.")
        return False

    def run_fhs_swdl_and_check_if_swdl_was_ok(self, fhs_build_name):
        """
        Run fhs swdl and check if swdl was ok.
        :param str fhs_build_name: Name of FHS SW build
        """
        fhs_swdl = True
        output1 = self.collect_logs.give_command_to_terminal(
            f"cd /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/FhsSwUpdateScripts/ && "
            f"./lzma_upload.sh {fhs_build_name}", print_to_eventlog=True, return_output=True)
        if output1 and "swman is not running" in output1:
            error("Unable to update software to FHS because swman is not running.")
            raise FhsSoftwareUpdateFailure("Unable to update software to FHS because swman is not running.")
        if output1:
            ok_status = len(re.findall(r"status:\s+OK", output1))
            if ok_status < 4:
                error(f"Problems when updating FHS software. Expects 4 OK statuses from the lzma_upload.sh script, "
                      f"but got only {ok_status}.")
                fhs_swdl = False
        else:
            error("No output get for terminal commands: cd /home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/"
                  "Common/Resources/FhsSwUpdateScripts/ && ./lzma_upload.sh {fhs_build_name}")
            fhs_swdl = False
        output = self.ssh.connection_command_and_output("cat /etc/version && SWmanShellCommand -i",
                                                        ip="192.168.1.131")
        info(f"Output after FSH software update (given commands were: cat /etc/version && SWmanShellCommand -i):"
             f"\n{output}")
        fhs_swdl2 = self.check_if_fhs_sw_is_updated(fhs_build_name, output)
        if not fhs_swdl or not fhs_swdl2:
            raise FhsSoftwareUpdateFailure

    def check_rmod_uptimes(self, max_tries="60"):
        """
        Check RMOD uptimes
        :param int max_tries: Maximum tries to get RMOD uptime, default is 60 tries (60 x 5s)
        :return List rmod_uptimes: List of tuples (rmod object, uptime of rmod)
        """
        if "${BREAK_LOKI}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${BREAK_LOKI}"):
            info("BREAK_LOKI is set to True, not checking RMOD uptimes.")
            return
        if "${BBMODS_MASK}" in BuiltIn().get_variables() and BuiltIn().get_variable_value("${BBMODS_MASKS}"):
            info("There is value in BBMODS_MASK, not checking RMOD uptimes.")
            return
        rmod_uptimes = []
        info("Getting radio uptimes")
        for rmod in self.radios:
            tries = 0
            rmod_uptime = None
            try:
                while tries < int(max_tries):
                    rmod_uptime = self.admin.get_rmod_measurements_by_id(rmod.scf_dist_name)['uptime']
                    if rmod_uptime['seconds'] != "-":
                        break
                    tries += 1
                    self.logger.debug(f"Couldn't get radio uptime, retrying... tries: {tries} (max 60)")
                    BuiltIn().sleep("5s")
            except (AttributeError, ValueError) as e:
                warning(f"Error {e} was raised when trying to get uptime of {rmod.name}")
                continue
            info(f"{rmod.name} uptime is: {rmod_uptime['dd:hh:mm:ss']}, HW path is: {rmod.hw_path}")
            if rmod_uptime['seconds'] == "-":
                warning(f"Couldn't get uptime of {rmod.name} after {max_tries} tries.")
                rmod_uptime = {"seconds": 0, "dd:hh:mm:ss": 0}
            rmod_uptimes.append((rmod, rmod_uptime))
        return rmod_uptimes

    def check_if_rmods_were_reset(self, previous_uptimes, rat_reset=False):
        """
        Check if RMODs were reset in site reset without RU reset.
        OBSAI radios will reset in site reset, while CPRI radios will not.

        :param list previous_uptimes: List of tuples (rmod object, uptime of rmod), values of previous uptimes.
        :param bool rat_reset: If True, not failing if OBSAI radio does not reset in RAT reset.
        :raises RadioDidNotReset: If radio did not reset.
        :raises RadioPerformedUnallowedReset: If radio performed unallowed reset.
        """
        success = True
        current_rmod_uptimes = self.check_rmod_uptimes()
        all_variables = BuiltIn().get_variables()
        if "${BREAK_LOKI}" in all_variables and BuiltIn().get_variable_value("${BREAK_LOKI}"):
            info("BREAK_LOKI is set to True, not checking if RMODs were reset or not.")
            return
        if "${BBMODS_MASK}" in all_variables and BuiltIn().get_variable_value("${BBMODS_MASK}"):
            info("There is value in BBMODS_MASK, not checking if RMODs were reset or not.")
            return
        if "SBTS24R3_ENB_" in BTS.active_sw:
            info("SBTS24R3 software is active, not checking if RMODs were reset or not.")
            return
        info("----------------------------------------------------------------")
        for rmod, uptime in current_rmod_uptimes:
            for previous_rmod, previous_uptime in previous_uptimes:
                if rmod == previous_rmod:
                    if rmod.cablink_type == "RP3_01Link":
                        if not rat_reset:
                            extra_time = int(BuiltIn().get_variable_value("${WAIT_FOR_CELLS_UP}", default=300))
                            previous_and_extra_time = int(previous_uptime['seconds']) + extra_time
                            if int(uptime['seconds']) > previous_and_extra_time:
                                error(f"{rmod.name} uptime is {uptime['seconds']} seconds, "
                                      f"it should be under {previous_and_extra_time} seconds"
                                      f" since reset was expected.")
                                success = False
                            else:
                                info(f"{rmod.name} was reset --> OK")
                                self.logger.debug(f"{rmod.name} uptime is: {uptime['seconds']} seconds")
                        else:
                            info(f"RAT reset is: {rat_reset}, not comparing radio uptimes for OBSAI radios.")
                    elif rmod.cablink_type == "EthLink" or "CPRILink":
                        if int(uptime['seconds']) < int(previous_uptime['seconds']):
                            error(f"{rmod.name} uptime is {uptime['seconds']} seconds,"
                                  f" it should be over {previous_uptime['seconds']} seconds"
                                  f" since reset was NOT expected.")
                            success = False
                        else:
                            info(f"{rmod.name} was NOT reset --> OK")
                            self.logger.debug(f"{rmod.name} uptime is: {uptime['seconds']} seconds")
                    else:
                        info(f"{rmod.name} cablinkType is: {rmod.cablink_type}, "
                             f"and uptime is: {uptime['dd:hh:mm:ss']}. cablinkType is not RP3_01Link, "
                             f"EthLink or CPRILink, expected behaviour is unknown")
        if success:
            info("Radios checked, everything as expected --> OK.")
        else:
            error("Radios checked, errors were found --> NOK")
            raise WrongRadioUptimes

    def check_if_active_sw_is_asked(self, sw_version_for_check):
        """
        Check if active SW is asked. This method can be used to for example check if SW is TMO sw or not.

        :param str sw_version_for_check: SW version that is checked if it is active.
        """
        if not sw_version_for_check:
            print("SW version for check is not given to check_if_active_sw_is_asked, returning False")
            return False
        if not BTS.active_sw:
            self.update_sw_information(print_to_eventlog=False)
        if not BTS.active_sw:
            warning("Active SW is not found from BTS, cannot check if active SW is asked, returning False")
            return False
        if BTS.active_sw == sw_version_for_check:
            print(f"Active SW is exactly {sw_version_for_check}")
            return True
        elif sw_version_for_check in BTS.active_sw:
            print(f"Active SW contains {sw_version_for_check}")
            return True
        else:
            print("Active SW is not asked")
            return False

    def check_if_netact_is_active(self):
        """
        Check if NetAct is active. This method can be used to check if NetAct is active or not.
        """
        self.logger.debug("Check if NetAct is active")
        nms_mos = self.admin.get_managed_objects("NE3SADAPT")
        if nms_mos:
            for nms_mo in nms_mos:
                print(f"nms: {nms_mo['parameters']['nmsStateInfo']['proceduralState']}")
                if "Connected" in str(nms_mo['parameters']['nmsStateInfo']['proceduralState']):
                    self.logger.debug("NetAct is active")
                    return True
        self.logger.debug("NetAct is not active")
        return False

    def smod_is_on_right_side_of_rack(self):
        """Smod is on right side of rack method return True if SMOD on right side, otherwise False"""
        self.logger.debug(f"SMOD is on right side of the rack: {BTS.bts_side_is_right}")
        return BTS.bts_side_is_right

    def user_defined_reset(self):
        """
        Give a reset based on the type of reset user gives.
        The value is taken from suite variable ${USER_DEFINED_RESET} and supported values are: site and remote power.
        If the user gives any other value, error is raised.

        :raises InvalidUserInput: If user-given input is not supported
        """
        try:
            reset_type = BuiltIn().get_variable_value("${USER_DEFINED_RESET}")
            if reset_type:
                if reset_type.strip().lower() == "site":
                    info("Resetting site")
                    self.admin.reset_site(detailed_output=True, wait_for_reconnection=False)
                    info("Site reset command was given")
                    self.cell_operations.wait_for_cells_faulty("300")
                    self.cell_operations.wait_for_all_cells_up("360")
                    info("site reset procedure done")
                elif reset_type.strip().lower() == "remote power":
                    info("Performing remote power reset")
                    self.admin.power_reset(timeout=900)
                    info("Remote power reset command was given")
                    self.cell_operations.wait_for_cells_faulty("300")
                    self.cell_operations.wait_for_all_cells_up("360")
                    info("Remote power procedure done")
                else:
                    error(f"{reset_type.strip().lower()} reset is not supported. "
                          f"Currently supporting: site and remote power resets. "
                          f"If you would like to add this type of reset, please contact the script developers.")
                    raise InvalidUserInput
                # ensure there is enough time for everything to be ok between tests
                BuiltIn().sleep("5s")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            error(f"Unable to give user defined reset."
                  f"{admin_error.__class__.__name__}:{admin_error} was raised.\n"
                  f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
            raise ErrorFromAdmin(
                f"Unable to give user defined reset reset."
                f"{admin_error.__class__.__name__} was raised.")

    def check_build_and_change_bbmod_state(self, bbmod_dictionary):
        """
        Check build and change bbmod state dictionary based on it due to new state in 25R2
        """
        build = self.get_active_sw_of_bts()
        if "25R1" in build:
            info(f"Didn't change bbmod dictionary availabilityStatus to power off because build is: {build}")
            return bbmod_dictionary
        info(f"Changing bbmod dictionary to availabilityStatus: power off, operationalState: disabled")
        return {"availabilityStatus": "power off", "operationalState": "disabled"}

    @staticmethod
    def get_current_time_and_return_user_defined_values(user_given_time="", return_weekdays=False):
        """
        Get the current time and return either only the current time as a string in the format HH:MM
        or the current time + user_given_time and the weekdays as an 8-bit bitmask.

        :param string user_given_time: User given time to be added on top of the current time.
        :param bool return_weekdays: If True, will return the current weekday + the next day as a bitmask.

        :Return: current time OR current time + user_given_time AND/OR return_weekdays
        """
        time_to_return = None
        current_time = datetime.datetime.now(pytz.timezone("Europe/Helsinki"))
        if user_given_time:
            if user_given_time.endswith("h"):
                time_to_return = current_time + datetime.timedelta(hours=int(user_given_time.split("h")[0]))
            elif user_given_time.endswith("min"):
                time_to_return = current_time + datetime.timedelta(minutes=int(user_given_time.split("min")[0]))
            elif user_given_time.endswith("s"):
                time_to_return = current_time + datetime.timedelta(seconds=int(user_given_time.split("s")[0]))
        if return_weekdays:
            week_mapping = {0: "Monday", 1: "Tuesday", 2: "Wednesday", 3: "Thursday", 4: "Friday",
                            5: "Saturday", 6: "Sunday"}
            today = current_time.weekday()
            # Example: Monday and Tuesday --> 00000011
            weekday_bitmask = (1 << today) | (1 << ((today + 1) % 7))
            info(f"Today is: {week_mapping[today]} and tomorrow is: {week_mapping[(today + 1) % 7]}. "
                 f"Value converted to an integer with a bitmask is: {weekday_bitmask}")
            if user_given_time:
                return time_to_return.strftime("%H:%M"), weekday_bitmask
            return current_time.strftime("%H:%M"), weekday_bitmask

        return time_to_return.strftime("%H:%M") if user_given_time else current_time.strftime("%H:%M")

    @staticmethod
    def parse_user_given_time_to_seconds(user_given_time):
        """
        User given time in the format of xh, xmin or xs

        :param str user_given_time: User given time

        :return str: Time formatted to seconds without any suffixes
        """
        if user_given_time.endswith("h"):
            return str(int(user_given_time.replace("h", "")) * 3600)
        elif user_given_time.endswith("min"):
            return str(int(user_given_time.replace("min", "")) * 60)
        elif user_given_time.endswith("s"):
            return user_given_time.replace("s", "")
        else:
            return user_given_time

    def bbmod_shares_resources_to_different_cell_technologies(self, bbmod_name):
        """
        Bbmod shares resources to different cell technologies. Check if BBMOD unit has cells of multiple technologies.

        :param str bbmod_name: Name of BBMOD f.ex. ABIA1, ABIA2, ABIA2.3
        :return True if there are more than one technology on cells of the given BBMOD unit, otherwise return False.
        """
        cells_of_bbmod = self.get_cells_of_bbmod(bbmod_name)
        if not cells_of_bbmod:
            error(f"No cells on {bbmod_name}")
            raise InvalidUserInput(f"No cells on selected BBMOD unit {bbmod_name}")
        # 'NRCell-306', 'LNCell-70'
        technologies = [cell.split("-")[0] if cell and "-" in cell else cell for cell in cells_of_bbmod]
        technology = set(technologies)
        if len(technology) > 1:
            info(f"{bbmod_name} is shared, it has resources of cells of different technologies ({technology})")
            return True
        else:
            info(f"{bbmod_name} is not shared, it has cells of single technology ({technology})")
            return False

    def amount_of_test_loops(self):
        """Amount of test loops returns test loops count"""
        return int(self.logger.loops)

    @staticmethod
    def get_configuration_names_of_all_radios(full_name=False):
        """
        Get configuration names of all radios

        :param bool full_name: If True adds fullname to list otherwise just the end
        :return: List including all radios. For example if full_name is False [RMOD-1, RMOD-2, RMOD-3, RMOD-4]. If
                 full_name is True returns [MRBTS-100807/EQM-1/APEQM-1/RMOD-1, MRBTS-100807/EQM-1/APEQM-1/RMOD-2,
                 MRBTS-100807/EQM-1/APEQM-1/RMOD-3, MRBTS-100807/EQM-1/APEQM-1/RMOD-4]
        """
        return_list = []
        if BTS.radios:
            for radio in BTS.radios:
                return_list.append(
                    radio.scf_dist_name if full_name else radio.scf_dist_name[radio.scf_dist_name.rfind("/") + 1:])
            return_list.sort()
        else:
            error("No radios found.")
            raise EnvironmentIssue("No radios in tested environment")
        info(f"ALL radios: {return_list}")
        return return_list

    def get_active_sw_and_compare_it(self, old_build, current_should_be_old=True):
        """
        Gets active SW of BTS and compares it to the given 'old' build. This is used for UC4, but generalized if needed
        somewhere else.

        :param str old_build: Old build (also called with get_active_sw_of_bts()
        :param bool current_should_be_old: True if the current build is expected to be same as the old one, False
                                           otherwise
        """
        new_build = self.get_active_sw_of_bts()
        if current_should_be_old:
            if old_build == new_build:
                info(f"Current SW: {new_build} is the same as the old one: {old_build} as expected.")
                return
            error(f"Current SW: {new_build} is different from the old one: {old_build}, NOK.")
            raise ExpectedSwBuildIsNotActive
        else:
            if old_build != new_build:
                info(f"Current SW: {new_build} is different from the old one: {old_build} as expected.")
                return
            error(f"Current SW: {new_build} is the same as the old one: {old_build}, NOK.")
            raise ExpectedSwBuildIsNotActive

    def get_sw_release_via_targetbd(self, lmp_ip="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"):
        def __get_sw_release():
            self.ssh_conn = ssh.connect(lmp_ip, username, password)
            target_bd = self.ssh_conn.execute(command="ls -1 /ffs/run/TargetBD*.xml", timeout=15)
            sw_pattern = re.compile(r".*TargetBD_(?P<sw>.*)\.xml")
            match = sw_pattern.search(target_bd)
            if match:
                release = match.group("sw").partition("_")[0]
                self.logger.debug(f"Determined SW release for admin connection: {release}")
                return release if release else None
            else:
                return None
        try:
            self.ssh_con = None
            return __get_sw_release()
        except (ConnectFailedError, CommandExecutionError, paramiko.ssh_exception.SSHException) as e:
            self.logger.debug(f"Could not get TargetBD via SSH from {lmp_ip} ({e}). Trying again")
            try:
                return __get_sw_release()
            except (ConnectFailedError, CommandExecutionError, paramiko.ssh_exception.SSHException) as e:
                self.logger.debug(f"Could not get TargetBD via SSH from {lmp_ip} on second attempt either ({e}). Using"
                                  f"default release")
                return None
        finally:
            if self.ssh_con:
                self.ssh_con.disconnect()
