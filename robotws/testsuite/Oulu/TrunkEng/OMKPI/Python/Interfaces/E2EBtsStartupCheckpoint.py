"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import os
import re
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.bbmods_and_socs import get_bbmod_hex_position
import testsuite.Oulu.TrunkEng.Common.Python.Resources.GetFileFromArchivedFolder as GetFromArchived


pps_service_breakdown_check_points = [
    "STRTCP_BBP_SRVBRK_BOARD_RESET_START", "STRTCP_BBP_SRVBRK_LFS_RESET_START",
    "STRTCP_BBP_SRVBRK_ALL_APP_STOP", "STRTCP_BBP_SRVBRK_APP_PREPARATION_STOP", "STRTCP_BBP_SRVBRK_HWAPI_STOP",
    "STRTCP_BBP_SRVBRK_CCS_STOP", "STRTCP_BBP_SRVBRK_LFS_STOP", "STRTCP_BBP_SRVBRK_ADDON_STOP",
    "STRTCP_BBP_SRVBRK_LFS_BOOT_START", "STRTCP_BBP_SRVBRK_LFS_SECONDARY_BOOT_START",
    "STRTCP_BBP_SRVBRK_LFS_KERNEL_START",
    "STRTCP_BBP_SRVBRK_ADDON_PREPARED", "STRTCP_BBP_SRVBRK_ADDON_READY", "STRTCP_BBP_SRVBRK_LFS_READY",
    "STRTCP_BBP_SRVBRK_CCS_READY", "STRTCP_BBP_SRVBRK_HWAPI_READY", "STRTCP_BBP_SRVBRK_APP_PREPARATION_READY",
    "STRTCP_BBP_SRVBRK_ALL_APP_STARTED", "STRTCP_BBP_SRVBRK_TIME_SYNC", "STRTCP_BBP_SRVBRK_FSP_DETECTED",
    "STRTCP_BBP_SRVBRK_SWIMAGE_TO_FSP", "STRTCP_BBP_SRVBRK_UNIT_ADET_READY",
    "STRTCP_BBP_SRVBRK_L1_RELEASED_FROM_RESET", "STRTCP_BBP_SRVBRK_CPU_ADET_READY",
    "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_START,", "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_START_RESP",
    "STRTCP_BBP_SRVBRK_CONTAINER_STATE", "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_STOP",
    "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_STOP_RESP", "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_KILL",
    "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_KILL_RESP", "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_DELETE",
    "STRTCP_BBP_SRVBRK_CONTAINER_TRIGGER_DELETE_RESP"
]


class E2EBtsStartupCheckpoint:
    """
    E2E BTS Startup Checkpoints. CNI-124831 PSSW Service Breakdown KPI check points.
    NOTE E2EBtsStartupCheckpoint is not called in common_resources.robot.

    Information for the startup checkpoints is collected from a file:
    https://nokia.sharepoint.com/:x:/r/sites/ps/specification/_layouts/15/Doc.aspx?sourcedoc=%7BD4E78220-BA5F-4368-868B-
    05A04E7E6E78%7D&file=STRTCP_BBP_SRVBRK%20checkpoints.xlsx&action=default&mobileredirect=true
    """
    files_including_checkpoints = []
    hex_and_unit = {}

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.bts = BuiltIn().get_library_instance("BTS")

    def _get_unit_names_for_snapshot_search(self):
        """
        Get unit names for snapshot search. This function is used to get the unit names for the snapshot search.
        """
        smod_log = []
        for sm in self.bts.smods:
            if "BTS_L-4" in sm.dist_name:
                smod_log.append("_2011")
                E2EBtsStartupCheckpoint.hex_and_unit["_2011"] = sm.name
            elif "BTS_L-1" in sm.dist_name:
                smod_log.append("_1011")
                E2EBtsStartupCheckpoint.hex_and_unit["_1011"] = sm.name
        bbmod_log = []
        for bbmod in self.bts.bbmods:
            bbmod_hex_primary = get_bbmod_hex_position(bbmod.name, self.bts.side, bbmod.primary_soc)
            if bbmod_hex_primary and bbmod_hex_primary not in bbmod_log:
                bbmod_log.append(f"_{bbmod_hex_primary}")
                E2EBtsStartupCheckpoint.hex_and_unit[f"_{bbmod_hex_primary}"] = f"{bbmod.name}/{bbmod.primary_soc}"
            for secondary in bbmod.secondary_socs:
                bbmod_hex_secondary = get_bbmod_hex_position(bbmod.name, self.bts.side, secondary)
                if bbmod_hex_secondary and bbmod_hex_secondary not in bbmod_log:
                    bbmod_log.append(f"_{bbmod_hex_secondary}")
                    E2EBtsStartupCheckpoint.hex_and_unit[f"_{bbmod_hex_secondary}"] = f"{bbmod.name}/{secondary}"
        # bbmod_logs = [f"_{b}" for b in bbmod_log]
        return smod_log, bbmod_log

    def get_pssw_service_breakdown_kpi_check_points(self, file_path=None):
        """
        Get pssw service breakdown kpi check points gets lines which contains the print from syslog and from snapshot.

        :param str file_path: Path to the file to which PPS service breakdown KPI check points will be collected.
                              If not given, the file will be created in the log directory.
        """
        if not file_path:
            name_for_file = BuiltIn().get_variable_value("${EXTRA_INFO_FOR_LOOP}", default="")
            path_for_the_file = os.path.join(self.logger.log_dir, f"E2E_BTS_Startup_Checkpoint{name_for_file}.txt")
        else:
            path_for_the_file = file_path
        self._pps_service_breakdown_kpi_check_points_from_syslog(path_for_the_file)
        # info(f"PPS service breakdown KPI check points from syslog added to {path_for_the_file}")
        include_snapshot_check = BuiltIn().get_variable_value("${E2E_CHECK_FROM_SNAPSHOT}", default=True)
        if include_snapshot_check in [True, 'True', 'true', 'TRUE']:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            smod_log, bbmod_log = self._get_unit_names_for_snapshot_search()
            self.get_all_e2e_bts_startup_files_from_snapshot_to_logs(smod_log, bbmod_log)
            if E2EBtsStartupCheckpoint.files_including_checkpoints:
                self._pps_service_breakdown_kpi_check_points_from_snapshot(path_for_the_file, smod_log, bbmod_log)
            else:
                error("Unable to get files from snapshot including Pssw service breakdown kpi check points.")

    def _get_file_add_it_to_list(self, name_of_file, folder_to_extract, upper_folder, upper_upper_folder,
                                 add_name_to_get_file, not_in_name, extra_name):
        """ Get file add it to list """
        self.logger.debug(
            f"Currently collected: {E2EBtsStartupCheckpoint.files_including_checkpoints}.\nGet {name_of_file} from "
            f"{add_name_to_get_file}")
        file_of_s = self.collect_logs.get_file_from_zip_or_tar(
            name_of_file, archived_path=self.collect_logs.snapshot_file_name, folder_to_extract=folder_to_extract,
            upper_folder=upper_folder, upper_upper_folder=upper_upper_folder, add_name_to_get_file=add_name_to_get_file,
            not_in_name=not_in_name, extra_name=extra_name
        )
        if file_of_s:
            E2EBtsStartupCheckpoint.files_including_checkpoints.append(file_of_s)

    def get_all_e2e_bts_startup_files_from_snapshot_to_logs(self, smod_log, bbmod_log):
        path_for_the_folder = os.path.join(self.logger.log_dir, "E2EBtsStartupCheckpointSnapshotfiles")
        os.makedirs(path_for_the_folder, exist_ok=True)
        from_smod_and_bbmod = smod_log
        from_smod_and_bbmod.extend(bbmod_log)
        if not os.path.exists(self.collect_logs.snapshot_file_name):
            info("No snapshot file. Collect one.")
            self.collect_logs.collect_snapshot(connection_name=None)
        for sb in from_smod_and_bbmod:
            # file_of_s = self.collect_logs.get_file_from_zip_or_tar(
            #     "runtime_HWAPI.log", archived_path=self.collect_logs.snapshot_file_name,
            #     folder_to_extract=path_for_the_folder, upper_folder=sb, upper_upper_folder=None,
            #     add_name_to_get_file=sb, not_in_name=None, extra_name=None)
            self._get_file_add_it_to_list(
                "runtime_HWAPI.log", path_for_the_folder, sb, "_pm_", f"{sb[1:]}_", None, "pm_")
            self._get_file_add_it_to_list(
                "var/log/last.0/service_break_checkpoints", path_for_the_folder, "_linux_logs", sb, f"{sb[1:]}_", None,
                "last0_")
            self._get_file_add_it_to_list(
                "var/log/last.0/CCS", path_for_the_folder, "_linux_logs", sb, f"{sb[1:]}_", None, None)
            self._get_file_add_it_to_list(
                "var/log/xtart.msg", path_for_the_folder, "_linux_logs", sb, f"{sb[1:]}_", None, None)
            self._get_file_add_it_to_list(
                "var/log/uboot.msg", path_for_the_folder, "_linux_logs", sb, f"{sb[1:]}_", None, None)
            self._get_file_add_it_to_list(
                "var/log/service_break_checkpoints", path_for_the_folder, "_linux_logs", sb, f"{sb[1:]}_", None, None)
            self._get_file_add_it_to_list(
                "startup_DEFAULT.log", path_for_the_folder, sb, None, f"{sb[1:]}_", None, None)
            self._get_file_add_it_to_list(
                "startup_HWAPI.log", path_for_the_folder, sb, None, f"{sb[1:]}_", "_pm_", None)
            self._get_file_add_it_to_list(
                "runtime_HWAPI.log", path_for_the_folder, sb, None, f"{sb[1:]}_", "_pm_", None)
            self._get_file_add_it_to_list(
                "var/log/kernel", path_for_the_folder, "_linux_logs", sb, f"{sb[1:]}_", None, None)
        info(f"Files ({len(E2EBtsStartupCheckpoint.files_including_checkpoints)} pcs) from snapshot that should include"
             f" PPS service breakdown KPI check points:\n{E2EBtsStartupCheckpoint.files_including_checkpoints}")

    def _pps_service_breakdown_kpi_check_points_from_syslog(self, path_for_the_file):
        """
        PPS service breakdown KPI check points from syslog gets all check points given in list
         pps_service_breakdown_check_points from syslog and writes them to file pps_service_breakdown_check_points.txt

        :param str path_for_the_file: Path to the file to which PPS service breakdown KPI check points will be collected
        """
        info("Collect E2E BTS Startup Checkpoints from syslog.")
        try:
            pattern = r'([^:]+):(\d+):(.*?)(?=\s*/tmp|$)'
            with open(path_for_the_file, "a") as f:
                f.write(f"PPS service breakdown KPI check points from syslog:\n\n")
                for e2e_print in pps_service_breakdown_check_points:
                    result = {}
                    output = self.collect_logs.give_command_to_terminal(
                        f"grep -Hn '{e2e_print}' {self.collect_logs.syslog_log_folder}/SYSLOG_*.LOG",
                        return_output=True)
                    if output:
                        matches = re.findall(pattern, output, re.DOTALL)
                        if matches:
                            result = [{'filename': m[0], 'line': int(m[1]), 'value': m[2].strip()} for m in matches]
                    if result:
                        f.write(f"{e2e_print}\n")
                        for res in result:
                            r_f = str(res['filename'])
                            f.write(f"\tFrom file:{r_f[r_f.rfind('/')+1:]} in line:{res['value']}\n")
                        f.write(f'{"-" * 100}\n')
                    else:
                        f.write(f"{e2e_print}\n\tWas not found.\n{'-' * 100}\n")
                info(f"PPS service breakdown KPI check points from syslog added to {path_for_the_file}")
        except (FileExistsError, FileNotFoundError, PermissionError, IsADirectoryError, IOError, UnicodeDecodeError,
                UnicodeEncodeError, NotADirectoryError, TypeError, AttributeError) as e:
            error(f"Exception when getting PPS service breakdown KPI check points from syslog. "
                  f"{e.__class__.__name__}:{e}. This will not fail the test case.")
            info(''.join(format_exception(type(e), e, e.__traceback__)))

    @staticmethod
    def _fill_file_lines_dict(search_print, file_to_check, file_lines):
        for log_file in E2EBtsStartupCheckpoint.files_including_checkpoints:
            if file_to_check in log_file:
                file_lines[log_file] = None
                if log_file.endswith('.gz') or log_file.endswith('.xz'):
                    checkpoint_line = GetFromArchived.search_from_xz_gz_archive(log_file, search_print)
                    if checkpoint_line:
                        file_lines[log_file] = checkpoint_line
                else:
                    with open(log_file, "rt", encoding="utf-8") as log_read:
                        for line in log_read:
                            if search_print in line:
                                print(f"Found {search_print} from {line}")
                                file_lines[log_file] = line
                                break
                break
        return file_lines

    def _check_if_requested_file_exists_and_read_content(self, search_print, unit_hex, file_to_check, f):
        """
        Check if requested file exists and read content
        """
        file_lines = {}
        if isinstance(file_to_check, list):
            for ftc in file_to_check:
                file_lines = self._fill_file_lines_dict(search_print, ftc, file_lines)
        else:
            file_lines = self._fill_file_lines_dict(search_print, file_to_check, file_lines)
        if not file_lines:
            f.write(f"  {E2EBtsStartupCheckpoint.hex_and_unit[unit_hex]} file: {file_to_check}\n\tFile "
                    f"and print was not found.\n")
        else:
            for k, v in file_lines.items():
                if v is None:
                    f.write(f"  {E2EBtsStartupCheckpoint.hex_and_unit[unit_hex]} file: {k}\n\tDid not have the "
                            f"checkpoints.\n")
                else:
                    f.write(f"  {E2EBtsStartupCheckpoint.hex_and_unit[unit_hex]} file: {k}\n\tCheckpoints were found "
                            f"from line:\n\t\t{v}\n")

    def _get_and_write_to_file_from_smod_and_bbmod(self, exp, smod_log, bbmod_log, l_file_name, f):
        for smod in smod_log:
            if isinstance(l_file_name, list):
                files_to_check = [f"{smod[1:]}_{i}" for i in l_file_name]
            else:
                files_to_check = f"{smod[1:]}_{l_file_name}"
            self._check_if_requested_file_exists_and_read_content(exp, smod, files_to_check, f)
        for bbm in bbmod_log:
            if isinstance(l_file_name, list):
                files_to_check = [f"{bbm[1:]}_{i}" for i in l_file_name]
            else:
                files_to_check = f"{bbm[1:]}_{l_file_name}"
            self._check_if_requested_file_exists_and_read_content(
                exp, bbm, files_to_check, f)

    def _pps_service_breakdown_kpi_check_points_from_snapshot(self, path_for_the_file, smod_log, bbmod_log):
        """
        PPS service breakdown KPI check points from snapshot gets all check points from given in list
         pps_service_breakdown_check_points from snapshot and writes them to file pps_service_breakdown_check_points.txt

        :param str path_for_the_file: Path to the file to which PPS service breakdown KPI check points will be collected
        :param list smod_log: List of smod hexs, can have value [_1011] or [_2011] or [_1011, _2011] depending on
                              the used environment.

        """
        f = open(path_for_the_file, "a")
        try:
            f.write(f"\n\nPPS service breakdown KPI check points from snapshot:\n\n")
            for index, exp in enumerate(pps_service_breakdown_check_points):
                # info(f"!!!!  {exp}")
                f.write(f"{exp}\n")
                if index in (0, 1, 4):
                    for smod in smod_log:
                        self._check_if_requested_file_exists_and_read_content(
                            exp, smod, f"{smod[1:]}_pm_runtime_HWAPI.log", f)
                    if index in (0, 4):
                        for bbm in bbmod_log:
                            self._check_if_requested_file_exists_and_read_content(
                                exp, bbm, f"{bbm[1:]}_pm_runtime_HWAPI.log", f)
                elif index in (24, 25, 26, 27, 28, 29, 30, 31, 32):
                    l_file_name = ["runtime_HWAPI.log", "startup_HWAPI.log"]
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index in (2, 3, 6, 7):
                    l_file_name = "last0_service_break_checkpoints"
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index == 5:
                    l_file_name = "CCS"
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index in (8, 9, 10, 22):
                    l_file_name = ["xtart.msg", "uboot.msg"]
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index in (11, 12, 13, 16):
                    l_file_name = "service_break_checkpoints"
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index == 14:
                    l_file_name = "startup_DEFAULT.log"
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index in (15, 18, 23):
                    l_file_name = "startup_HWAPI.log"
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index == 17:
                    l_file_name = ["startup_DEFAULT.log", "service_break_checkpoints", "kernel"]
                    self._get_and_write_to_file_from_smod_and_bbmod(exp, smod_log, bbmod_log, l_file_name, f)
                elif index == 19:
                    for smod in smod_log:
                        self._check_if_requested_file_exists_and_read_content(
                            exp, smod, [f"{smod[1:]}_service_break_checkpoints", f"{smod[1:]}_kernel"], f)
                elif index == 20:
                    for bbm in bbmod_log:
                        self._check_if_requested_file_exists_and_read_content(
                            exp, bbm, [f"{bbm[1:]}_xtart.msg", f"{bbm[1:]}_uboot.msg"], f)
                elif index == 21:
                    for smod in smod_log:
                        self._check_if_requested_file_exists_and_read_content(
                            exp, smod, f"{smod[1:]}_startup_HWAPI.log", f)

        except Exception as e:
            error(f"Exception when getting PPS service breakdown KPI check points from snapshot. "
                  f"{e.__class__.__name__}: {e}")
            info(''.join(format_exception(type(e), e, e.__traceback__)))
        finally:
            info(f"PPS service breakdown KPI check points from snapshot added to {path_for_the_file}")
            f.close()
