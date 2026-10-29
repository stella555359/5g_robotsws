import os
import zipfile
import pytz
from collections import defaultdict
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.GetValuesFromImsHistory import GetValuesFromImsHistory


class OmkpiStartupTimes(object):

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.ims_history = GetValuesFromImsHistory()

    lib_kpis = {
        "Site reset": ["KPI1a", "KPI1b", "KPI1c"],
        "Site reset without RU reset": ["KPI1g", "KPI1f"],
        "Sw inter activation without firmware update": ["KPI2a", "KPI2i", "KPI2k"],
        "Sw inter activation with firmware update": ["KPI2b", "KPI2j", "KPI2k"],
        "Sw intra activation without firmware update": ["KPI2c", "KPI2o"],
        "Sw intra activation with firmware update": ["KPI2d", "KPI2p"],
        "Inter-release SW activation downtime without firmware update": ["KPI2i", "KPI2k"],
        "Inter-release SW activation downtime with firmware updates": ["KPI2j", "KPI2k"],
        "Inter-release blue-green SW activation downtime": ["KPI2l"],
        "Intra-release blue-green SW activation downtime": ["KPI2m"],
        "Power reset": ["KPI3"],
        "Complete upgrade": ["KPI4a", "KPI4b"],
        "BBMOD Warm": ["KPI5a", "KPI5b"],
        "Rat reset LTE KPI#7": ["KPI7"],
        "Rat reset LTE KPI#7a": ["KPI7a", "KPI7c"],
        "Rat reset LTE KPI#7b": ["KPI7b", "KPI7d"],
        "Rat reset NR KPI#10": ["KPI10"],
        "Rat reset NR KPI#10a": ["KPI10a", "KPI10c"],
        "Rat reset NR KPI#10b": ["KPI10b", "KPI10d"],
        "Remote power reset": ["KPI11a", "KPI11b"],
        "Commissioning reset": ["KPI12a", "KPI12b"],
        "Sw rollback": ["KPI13", "KPI13b", "KPI13c"],
        "BBMOD PowerReset": ["KPI14a", "KPI14b"],
        "Cell plan activation": ["KPI15a", "KPI15b"],
        "Cell lock and unlock": ["KPI16a", "KPI16b"],
        "Cell block and unblock": ["KPI17a", "KPI17b"],
        "BBPool reset": ["KPI18a", "KPI18b"],
        "Cell reset": ["KPI19"],
        "Radio reset A/B": ["KPI51a", "KPI51b"],
        "Radio reset C": ["KPI51c"],
        "FHS reset": ["KPI53a", "KPI53b"],
        "Rf power reset": ["KPI54a", "KPI54b"],
        "Manual RU SW upgrade downtime": ["KPI55a", "KPI55b"],
        "Independent sequential RUs SW upgrade duration": ["KPI55d"],
        "Manual DU Inter-release SW activation downtime without firmware update downtime": ["KPI57a", "KPI57e"],
        "Manual DU Inter-release SW activation downtime with firmware update downtime": ["KPI57b", "KPI57f"],
        "Manual DU Intra-release SW activation downtime without firmware update downtime": ["KPI57c", "KPI57g"],
        "Manual DU Intra-release SW activation downtime with firmware update downtime": ["KPI57d", "KPI57h"],
        "Duration of the RU upgrade phase during independent DU upgrade": ["KPI57e"],
        "Complete BTS DU SW upgrade": ["KPI58"],
        "BTS SW upgrade from FDSW": ["KPI61a"],
        "UE perceived outage during upgrade for CPRI radio module": ["KPI77a"],
    }

    @staticmethod
    def check_time_and_limit(name, time, limit, avg=False, netact_active=False):
        netact_text = " (NetAct is active)" if netact_active else ""
        if isinstance(limit, dict):
            limit = limit.get('GENERAL', 0)
            info(f"There are specific limits for different RATs, using GENERAL limit {limit}s for time check")
        if float(time) >= float(limit) > 0:
            print_text = "average limit" if avg else "limit"
            error(f"Time ({time}s) for {name} was over {print_text} ({limit}s){netact_text}")
            return False
        else:
            print_text = "Average time" if avg else "Time"
            info(f"{print_text} for {name} was {time}s{netact_text}")
            return True

    def check_time_against_limit(self, name, start=None, end=None, delta=None, limit=0, netact_active=False):
        time = ""
        if start and end:
            time = int((end - start).total_seconds())
        elif delta:
            time = int(delta.total_seconds())
        if time:
            limit_success = self.check_time_and_limit(name, time, limit, netact_active=netact_active)
            if limit_success:
                return True, str(time)
        else:
            error(f"Couldn't calculate {name}")
            return False, ""
        return False, ""

    @staticmethod
    def get_extra_arguments(args):
        if len(args) == 1:
            parameter1 = args[0]
            parameter2 = ""
        elif len(args) == 2:
            parameter1 = args[0]
            parameter2 = args[1]
        else:
            parameter1 = ""
            parameter2 = ""
        extra_arguments = {
            "KPI3": {'kpi3': {'start_point_timestamp': parameter1}},
            "KPI15": {'kpi15': {'global_cell_id': parameter1}},
            "KPI15a": {'kpi15a': {'global_cell_id': parameter1}},
            "KPI15b": {'kpi15b': {'global_cell_id': parameter1}},
            "KPI16a": {'kpi16a': {'global_cell_id': parameter1}},
            "KPI16b": {'kpi16b': {'global_cell_id': parameter1}},
            "KPI17a": {'kpi17a': {'global_cell_id': parameter1, 'dist_name': parameter2}},
            "KPI17b": {'kpi17b': {'dist_name': parameter2}},
            "KPI19": {'kpi19': {'global_cell_id': parameter1}},
            "KPI54a": {'kpi54a': {'start_point_timestamp': parameter1}},
            "KPI54b": {'kpi54b': {'start_point_timestamp': parameter1}},
            "KPI55a": {'kpi55a': {'cell_dist_names': args}},
            "KPI55b": {'kpi55b': {'cell_dist_names': args}},
            "KPI55c": {'kpi55c': {'cell_dist_names': args}},
            "KPI55d": {'kpi55d': {'cell_dist_names': args}},
            "KPI55e": {'kpi55e': {'cell_dist_names': args}}
        }
        return extra_arguments

    def form_kpi_params(self, args, test_case):
        kpi_params = {}
        extra_arguments = {}
        if args:
            if "Cell" in test_case:
                rat = "lte" if "LN" in args[1] else "gsm" if "GN" in args[1] else "nr"
                args = [self.cells.get_cell_global_id_by_local_id(args[0], rat)]
            extra_arguments = self.get_extra_arguments(args)
            self.logger.debug(f"Extra arguments: {extra_arguments}")
            self.logger.debug(f"Test case Lib kpis:\n{self.lib_kpis[test_case]}")
            for kpi in self.lib_kpis[test_case]:
                kpi_params.update(extra_arguments[kpi])
        if BuiltIn().get_variable_value("${BBMODS_MASK}"):
            cells_dist_names = []
            faulty_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}")
            for cell_name, cell_info in self.bts.cells.items():
                if cell_name not in faulty_cells:
                    cells_dist_names.append(cell_info['id']['internal'])
            info(f"{cells_dist_names} are considered for KPI calculation")
            extra_arguments["cell_dist_names"] = cells_dist_names
            for kpi in self.lib_kpis[test_case]:
                kpi_params[kpi.lower()] = extra_arguments
        if test_case == "Independent sequential RUs SW upgrade duration":  # kpi55d
            cells_dist_names = []
            for cell_name, cell_info in self.bts.cells.items():
                cells_dist_names.append(cell_info['id']['internal'])
            info(f"{cells_dist_names} are considered for KPI calculation")
            extra_arguments["cell_dist_names"] = cells_dist_names
            for kpi in self.lib_kpis[test_case]:
                kpi_params[kpi.lower()] = extra_arguments
        self.logger.debug(f"KPI params: {kpi_params}")
        return kpi_params

    @staticmethod
    def print_kpi_error(kpi_name, result, targets, rat, iteration="", avg=False, extra_targets=None):
        avg_text = "Average time for: " if avg else ""
        avg_text2 = "avg" if avg else "target"
        extra_target = ""
        if extra_targets:
            extra_target = f"{extra_targets[kpi_name][rat]}" if extra_targets and rat else f"{extra_targets[kpi_name]}"
        extra_info = f", {extra_target}s target" if extra_targets else ""
        loop_text = f" Loop {iteration.replace('iteration_', '')}: " if iteration else ""
        limit = targets[kpi_name][rat] if rat else targets[kpi_name]
        error(f"{avg_text}{kpi_name}:{loop_text}{result}s was over limit ({limit}s {avg_text2}{extra_info})")

    def check_all_kpis(self, all_results, targets, avg_targets, rat, kpis):
        success = True
        if all_results:
            for kpi_name, results in all_results.items():
                if kpi_name in kpis:
                    if results["failed"] != 0:
                        for iteration, loop_results in results["results"].items():
                            if loop_results["status"] == "FAILED":
                                self.print_kpi_error(kpi_name, loop_results["delta"], targets, rat, iteration)
                        success = False
                    if avg_targets:
                        if "avg_status" in results:
                            if results["avg_status"] == "FAILED":
                                self.print_kpi_error(kpi_name, results["avg"], avg_targets, rat, avg=True,
                                                     extra_targets=targets)
                                success = False
                        else:
                            error(f"Key 'avg_status' is not found from the results:\n{results}")
                    if 'avg' in results:
                        info(f"Average results for {kpi_name}: {results['avg']}")
                    else:
                        error(f"Key 'avg' is not found from the results:\n{results}")
        else:
            error("KPI check failed. There were no results parsed")
            success = False
        return success

    def find_all_logs_zips(self):
        """
        Find all logs zip. This is used to add kpi file to the same zip as the logs to all_logs.zip, but in SWDL there
        is not any all_logs.zip, there is SWDL_of_T1.zip, SWDL_of_T2.zip and SWDL_of_normal.zip logs.
        """
        list_of_zipped_files = []
        for dirpath, _, filenames in os.walk(self.logger.suite_folder):
            for filename in filenames:
                if filename == "all_logs.zip" or filename in ("SWDL_of_T1.zip", "SWDL_of_T2.zip", "SWDL_of_normal.zip",
                                                              "RF_SWDL_of_T1.zip", "RF_SWDL_of_T2.zip",
                                                              "RF_SWDL_of_Normal.zip"):
                    list_of_zipped_files.append(os.path.join(dirpath, filename))
        self.logger.debug(f"Zipped logs: {list_of_zipped_files}")
        return list_of_zipped_files

    def add_kpi_file_to_zip(self, zipped_logs, kpis_file_path):
        """
        Add kpi file to the same zip as the logs.

        :param list zipped_logs: List of zipped logs.
        :param str kpis_file_path: Path to the kpi file.
        """
        reference_name = BuiltIn().get_variable_value("${REFERENCE_TESTLINE}")
        zip_file_name = os.path.basename(kpis_file_path).replace('kpis', reference_name).replace('.txt', '')
        zipped_file_name = f"{zip_file_name}.zip"
        for zipped_log in zipped_logs:
            with zipfile.ZipFile(zipped_log, 'a', zipfile.ZIP_DEFLATED) as zipf:
                zipf.write(kpis_file_path, os.path.basename(kpis_file_path))
                if os.path.exists(f"{self.logger.log_dir}/Extra_kpis.txt"):
                    zipf.write(f"{self.logger.log_dir}/Extra_kpis.txt", "Extra_kpis.txt")
                    os.remove(f"{self.logger.log_dir}/Extra_kpis.txt")
            if "SWDL_of_" in zipped_log:
                extra_name = zipped_log[zipped_log.rfind("_") + 1:zipped_log.find(".")]
                zipped_file_name = f"{zip_file_name}_{extra_name}.zip"
                print(f"SWDL test, new name for {zipped_log} is {zipped_file_name}")
            new_zipped_file_name = os.path.join(os.path.dirname(zipped_log), zipped_file_name)
            self.logger.debug(f"New zipped file name: {new_zipped_file_name}")
            os.rename(zipped_log, new_zipped_file_name)

    @staticmethod
    def _dict_contains_dict(input_dict):
        """
        Check if input dictionary contains another dictionary.

        :param dict input_dict: Input dictionary
        :return bool: True if dictionary contains another dictionary, False otherwise
        """
        for value in input_dict.values():
            if isinstance(value, dict):
                return True
        return False

    @staticmethod
    def print_info_prints(info_prints):
        """
        Print info prints.

        :param list info_prints: List of info prints
        """
        for info_print in info_prints:
            info(info_print)

    def write_to_file(self, info_prints, file_name):
        """
        Write info prints to file.

        :param list info_prints: List of info prints
        :param str file_name: File name
        """
        file_name = os.path.join(self.logger.log_dir, file_name)
        with open(file_name, "a") as kpi_file:
            for info_print in info_prints:
                kpi_file.write(f"{info_print}\n")
        return file_name

    @staticmethod
    def sort_info_prints(info_prints):
        """
        Sort info prints.

        :param list info_prints: List of info prints
        :return list: Sorted info prints
        """
        return sorted(info_prints, key=lambda x: float(x.split(":")[-1].split("s")[0]))

    @staticmethod
    def _make_offset_aware(datetime_object):
        return datetime_object.astimezone(pytz.UTC) if datetime_object.tzinfo is None else datetime_object

    def _collect_info_prints(self, component_state_dict, test_case, ims_path, start_point=None, rfs=False,
                             only_timestamps=False):

        def find_extra_info_by_dist_name(dist_name):
            def _lookup(items, attr_dist_name, attr_serial, attr_name, only_remote=None):
                for item in items:
                    # optionally restrict for remote=True objects (for smod-remote use case)
                    if only_remote is not None and getattr(item, 'remote', False) != only_remote:
                        continue
                    if getattr(item, attr_dist_name, None) == dist_name:
                        return getattr(item, attr_serial, ""), getattr(item, attr_name, "")
                return None

            if not rfs:
                result = (
                    _lookup(self.bts.bbmods, 'dist_name', 'serial_nmbr', 'name')
                    or _lookup(self.bts.radios, 'dist_name', 'serial_number', 'name')
                    or _lookup(self.bts.smods, 'r_dist_name', 'serial_number', 'name')
                )
            else:
                result = (
                    _lookup(self.bts.bbmods_remote, 'dist_name', 'serial_nmbr', 'name')
                    or _lookup(self.bts.radios_remote, 'dist_name', 'serial_number', 'name')
                    or _lookup(self.bts.smods, 'r_dist_name', 'serial_number', 'name', only_remote=True)
                )
            return result if result else ("", "")
        if start_point:
            start_point = self._make_offset_aware(start_point)
        search_start_point = start_point
        all_timestamps = []
        info_prints = []
        disabled_times = {}
        procedural_not_init = {}
        exceptional_start_point_dict = {
            "Power reset": "Power ON request",
            "Manual RU SW upgrade downtime": "Request RF software upgrade",
            "SWDL_test": "Software update request done",
            "Independent sequential RUs SW upgrade duration": "Request RF software upgrade",
            "RU reset": "RU reset request"
        }
        if self.ims_history.check_multiple_states_from_history(ims_path, component_state_dict, collect_all=True,
                                                               print_to_eventlog=False):
            if "Power reset" in test_case and ("BBMOD_R" in component_state_dict.keys() or not rfs):
                # Power reset needs to wait sync before getting timestamps
                time_dn = [dn for dn in component_state_dict.keys() if "TIME-" in dn][-1]
                search_start_point = self.ims_history.get_timestamp_of_element_from_dict(time_dn, "operationalState",
                                                                                         "Enabled",
                                                                                         print_to_eventlog=False,
                                                                                         start_point=start_point)
                search_start_point = search_start_point[0] if isinstance(
                    search_start_point, list) else search_start_point
            for component_dn, states in component_state_dict.items():
                for state in states:
                    self.logger.debug(f"Checking timestamp for {component_dn} with state {state}")
                    point = list(state['stateInfo'].keys())[0] if self._dict_contains_dict(state) else (
                        list(state.keys()))[0]
                    only_state = state['stateInfo'][point] if self._dict_contains_dict(state) else state[point]
                    if "RU reset" in test_case and "enabled" in only_state.lower() and component_dn in disabled_times:
                        search_start_point = disabled_times[component_dn]
                    if ("RU reset" in test_case and ("initializing" in only_state.lower() or "configured" in
                                                     only_state.lower()) and component_dn in procedural_not_init):
                        search_start_point = procedural_not_init[component_dn]
                    self.logger.debug(f"Point: {point}")
                    self.logger.debug(f"State: {only_state}")
                    self.logger.debug(f"Start point: {start_point}")
                    self.logger.debug(f"Start point for calculations: {search_start_point}")
                    timestamp = self.ims_history.get_timestamp_of_element_from_dict(component_dn, point,
                                                                                    only_state,
                                                                                    print_to_eventlog=False,
                                                                                    start_point=search_start_point,
                                                                                    timestamp_error=False)
                    if timestamp:
                        if isinstance(timestamp, list):
                            info(f"More than one timestamp found for {only_state}: {timestamp}, selecting the last one")
                            timestamp = timestamp[-1]
                        all_timestamps.append(timestamp)
                        self.logger.debug(f"All timestamps: {all_timestamps}")
                        if not only_timestamps:
                            time_print = (timestamp - start_point).total_seconds() if start_point else timestamp
                            only_component = component_dn.split('/')[-1]
                            if (only_component.startswith("RMOD_") or only_component.startswith("BBMOD_") or
                                    only_component.startswith("SMOD_")):
                                sn, name = find_extra_info_by_dist_name(component_dn)
                                if sn or name:
                                    only_component = f"{only_component} ({sn}, {name})"
                            start_point_name = exceptional_start_point_dict[test_case] if (
                                    test_case in exceptional_start_point_dict) else "Reset request"
                            info_prints.append(
                                f"{only_component}: {start_point_name} - {only_state}: {time_print}s")
                    if "RU reset" in test_case and "disabled" in only_state.lower():
                        disabled_times[component_dn] = timestamp
                    if "RU reset" in test_case and "not initialized" in only_state.lower():
                        procedural_not_init[component_dn] = timestamp
        return info_prints, all_timestamps

    def _collect_rfs_info_prints(self, component_state_dict, test_case, ims_path, start_point=None, rfs=False,
                                 only_timestamps=False, info_prints=None, all_timestamps=None):
        """
        Collect info prints for RFS.

        :param dict component_state_dict: Component state dictionary
        :param str test_case: Test case name
        :param str ims_path: Path to IMS file
        :param datetime start_point: Start point for the component
        :param bool rfs: RFS environment
        :param bool only_timestamps: Return only timestamps
        :return list info_prints: List of info prints
        :return list all_timestamps: List of all timestamps
        """
        if not os.path.exists(ims_path):
            ims_path = self.log_collector.ims_file_name
        ims_path_rfs = ims_path.replace(".ims2", "_remote.ims2")
        if not os.path.exists(ims_path_rfs):
            self.log_collector.collect_ims(ims_path)
        if not os.path.exists(ims_path_rfs):
            error(f"IMS file from remote {ims_path_rfs} does not exist")
            return None
        remote_cells_dn = [cell["id"]["internal"] for cell in self.bts.cells_remote.values()]
        self.logger.debug(f"Remote cells considered for KPI calculation: {remote_cells_dn}")
        rfs_state_dict = {cell_dn: [{"operationalState": "enabled"}] for cell_dn in remote_cells_dn}
        if "Power reset" in test_case:
            bbmod_remote_state_dict = {
                bbmod.dist_name: [{"operationalState": "enabled"}]
                for bbmod in self.bts.bbmods_remote
            }
            rfs_state_dict = {**rfs_state_dict, **bbmod_remote_state_dict}
        # Keys are full dist names (e.g. .../SMOD_R-1), not the literal string "SMOD_R".
        if any("SMOD_R" in dn for dn in component_state_dict):
            smod_remote_state_dict = {
                smod.r_dist_name: [{"operationalState": "enabled"}]
                for smod in self.bts.smods if smod.remote and smod.r_dist_name
            }
            rfs_state_dict = {**rfs_state_dict, **smod_remote_state_dict}
        self.logger.debug(f"RFS state dict: {rfs_state_dict}")
        info_prints_rfs, all_timestamps_rfs = self._collect_info_prints(
            rfs_state_dict,
            test_case,
            ims_path_rfs,
            start_point,
            rfs,
            only_timestamps,
        )
        info_prints = info_prints + info_prints_rfs
        all_timestamps = all_timestamps + all_timestamps_rfs
        self.logger.debug(f"Remote info prints: {info_prints_rfs}")
        return info_prints, all_timestamps

    def calculate_extra_kpi(self, component_state_dict, test_case, ims_path, start_point="", print_time=False,
                            write_file=False, rfs=False, only_timestamps=False):
        """
        Get timestamp from component from IMS

        :param dict component_state_dict: Expected component(s) and values. For example:
                {
                "/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-2/SOC_L-1/DSP_L-1": {
                ["stateInfo": {
                    "operationalState": "Disabled"
                      },
                "stateInfo": {
                    "operationalState": "Enabled"
                      }
                ]
                },
                "/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1/POWER_GROUP_L-1/SOC_L-2/DSP_L-1": {
                ["stateInfo": {
                    "operationalState": "Disabled"
                      },
                "stateInfo": {
                    "operationalState": "Enabled"
                      }
                ]
                }
        :param str test_case: Test case name
        :param str ims_path: Path to IMS file
        :param datetime start_point: Start point for the component
        :param bool print_time: Print timestamp:
        :param bool write_file: Write timestamp to file
        :param bool rfs: RFS environment
        :param bool only_timestamps: Return only timestamps
        :return str timestamp: Timestamp
        """
        info_prints, all_timestamps = self._collect_info_prints(component_state_dict, test_case, ims_path, start_point,
                                                                only_timestamps=only_timestamps)
        if rfs:
            info_prints, all_timestamps = self._collect_rfs_info_prints(component_state_dict, test_case, ims_path,
                                                                        start_point, rfs, only_timestamps,
                                                                        info_prints=info_prints,
                                                                        all_timestamps=all_timestamps)
        self.ims_history.clear_values()
        if info_prints:
            self.logger.debug(f"Info prints: {info_prints}")
            sorted_prints = self.sort_info_prints(info_prints)
            if print_time:
                self.print_info_prints(sorted_prints)
            if write_file:
                self.write_to_file(sorted_prints, "Extra_kpis.txt")
        return all_timestamps

    def collect_cells_disabled_enabled(self, cell_state_dict, ims_path, search_start_point):
        cells_timestamp_dict = defaultdict(dict)
        search_start_point = self._make_offset_aware(search_start_point)
        cell_disabled_times = {}
        if self.ims_history.check_multiple_states_from_history(ims_path, cell_state_dict, collect_all=True,
                                                               print_to_eventlog=False):
            for cell_dn, states in cell_state_dict.items():
                for state in states:
                    self.logger.debug(f"Checking timestamp for {cell_dn} with state {state}")
                    point = list(state.keys())[0]
                    only_state = str(state[point])
                    if "enabled" in only_state.lower() and cell_dn in cell_disabled_times:
                        search_start_point = cell_disabled_times[cell_dn]
                    timestamp = self.ims_history.get_timestamp_of_element_from_dict(cell_dn, point,
                                                                                    only_state,
                                                                                    print_to_eventlog=False,
                                                                                    start_point=search_start_point,
                                                                                    timestamp_error=False)
                    cells_timestamp_dict[cell_dn][only_state] = timestamp
                    if "disabled" in only_state.lower():
                        cell_disabled_times[cell_dn] = timestamp
        return cells_timestamp_dict

    def print_cells_disabled_enabled(self, cell_state_dict, ims_path, search_start_point):
        """
        Calculate cells disabled and enabled timestamps

        :param dict cell_state_dict: Cell state dictionary
        :param str ims_path: IMS path
        :param datetime search_start_point: Search start point
        :return str timestamp: Timestamp
        """
        self.logger.debug(f"DEBUG: cell_state_dict: {cell_state_dict}")
        cells_timestamp_dict = self.collect_cells_disabled_enabled(cell_state_dict, ims_path, search_start_point)
        self.logger.debug(f"DEBUG: cells_timestamp_dict: {cells_timestamp_dict}")
        info_prints = []
        for cell_dn, states in cells_timestamp_dict.items():
            enabled_timestamp = states["enabled"]
            disabled_timestamp = states["disabled"]
            if enabled_timestamp and isinstance(enabled_timestamp, list):
                self.logger.debug(f"Select last value from list {enabled_timestamp}")
                enabled_timestamp = states["enabled"][-1]
            if disabled_timestamp and isinstance(disabled_timestamp, list):
                self.logger.debug(f"Select last value from list {disabled_timestamp}")
                disabled_timestamp = states["disabled"][-1]
            if enabled_timestamp and disabled_timestamp:
                time_print = (enabled_timestamp - disabled_timestamp).total_seconds()
                only_component = cell_dn.split('/')[-1]
                info_prints.append(f"{only_component}: Disabled - Enabled: {time_print}s")
            if not states["disabled"]:
                info(f"Cell {cell_dn} didn't have disabled timestamp")
            if not states["enabled"]:
                info(f"Cell {cell_dn} didn't have enabled timestamp")
        sorted_prints = self.sort_info_prints(info_prints)
        self.print_info_prints(sorted_prints)
        self.write_to_file(sorted_prints, "cells_enabled_disabled.txt")

    # def _get_disabled_enabled_radios_from_remote(self, ims_path_rfs):
        # TODO: if we need to check radios of the other side then we need to handle also remote radios
        # faulty_loki_rmods = BuiltIn().get_variable_value("${F_LOKI_RMODS}", default=[])
        # faulty_rmods = BuiltIn().get_variable_value("${FAULTY_BBMODS_RMODS}", default=[])
        # remote_radios = [rmod.dist_name for rmod in self.bts.radios_remote if ((rmod.name not in faulty_rmods) and
        #                                                                       (rmod.name not in faulty_loki_rmods))]
        #  states = [{"operationalState": "disabled"}, {"operationalState": "enabled"}]
        #     rmod_state_dict = {rmod: states for rmod in remote_radios}
        #
        #     ims_path_rfs = ims_path.replace(".ims2", "_remote.ims2")
        #     remote_rmods_timestamp_dict = self.collect_cells_disabled_enabled(rmod_state_dict, ims_path_rfs,
        #                                                                       search_start_point)
        #     self.logger.debug(f"DEBUG: remote_rmods_timestamp_dict: {remote_rmods_timestamp_dict}")
        #     for rmod_dn, states in remote_rmods_timestamp_dict.items():
        #         sn = ""
        #         rmod_name = ""
        #         time_print = (states["enabled"] - states["disabled"]).total_seconds()
        #         only_component = rmod_dn.split('/')[-1]
        #         for rmod in self.bts.radios:
        #             if rmod.dist_name == rmod_dn:
        #                 sn = rmod.serial_number
        #                 rmod_name = rmod.name
        #         only_component = f"{only_component} ({sn}, {rmod_name})"
        #         info_prints.append(f'{only_component}: Disabled ({states["disabled"].strftime("%Y-%m-%d %H:%M:%S")}) '
        #                            f' - Enabled ({states["enabled"].strftime("%Y-%m-%d %H:%M:%S")}) - Duration:'
    #                                f'{time_print}s')
        #     return info_prints

    def print_rmods_disabled_enabled(self, rmod_state_dict, ims_path, search_start_point):  # , rfs):
        """
        Calculate RMODs disabled and enabled timestamps

        :param dict rmod_state_dict: Rmod state dictionary
        :param str ims_path: IMS path
        :param datetime search_start_point: Search start point
        :return str timestamp: Timestamp
        """
        self.logger.debug(f"DEBUG: rmod_state_dict: {rmod_state_dict}")
        rmods_timestamp_dict = self.collect_cells_disabled_enabled(rmod_state_dict, ims_path, search_start_point)
        self.logger.debug(f"DEBUG: rmods_timestamp_dict: {rmods_timestamp_dict}")
        info_prints = []
        for rmod_dn, states in rmods_timestamp_dict.items():
            sn = ""
            rmod_name = ""
            enabled_timestamp = states["enabled"]
            disabled_timestamp = states["disabled"]
            if enabled_timestamp and isinstance(enabled_timestamp, list):
                self.logger.debug(f"Select last value from list {enabled_timestamp}")
                enabled_timestamp = states["enabled"][-1]
            if disabled_timestamp and isinstance(disabled_timestamp, list):
                self.logger.debug(f"Select last value from list {disabled_timestamp}")
                disabled_timestamp = states["disabled"][-1]
            if enabled_timestamp and disabled_timestamp:
                time_print = (enabled_timestamp - disabled_timestamp).total_seconds()
                only_component = rmod_dn.split('/')[-1]
                for rmod in self.bts.radios:
                    if rmod.dist_name == str(rmod_dn):
                        sn = rmod.serial_number
                        rmod_name = rmod.name
                only_component = f"{only_component} ({sn}, {rmod_name})"
                info_prints.append(f'{only_component}: Disabled ({disabled_timestamp.strftime("%Y-%m-%d %H:%M:%S")}) - '
                                   f'Enabled ({enabled_timestamp.strftime("%Y-%m-%d %H:%M:%S")}) - Duration: '
                                   f'{time_print}s')
            if not states["disabled"]:
                info(f"Radio {rmod_dn} didn't have any disabled timestamp")
            if not states["enabled"]:
                info(f"Radio {rmod_dn} didn't have any enabled timestamp")
        # if rfs:
        #     remote_info = self._get_disabled_enabled_radios_from_remote(ims_path_rfs)
        #     info_print = info_prints + remote_info

        sorted_prints = sorted(info_prints, key=lambda x: x.split(": Disabled (")[-1].split(") - Enabled")[0])
        info("RU activation reset is triggered and enabled (sorted by the disabled state):")
        self.print_info_prints(sorted_prints)

    def bbpool_reset_timestamps(self, given_bbpool, start_point, socs_to_reset):
        """
        Calculate BBPool reset duration. Calculation is switched from checking disabled-enabled of BBPOOL_R to check
        affected SOCS because BBPOOL_R is not always disables, but SOCs are.

        :param str given_bbpool: BBPool name e.g BBPool11
        :param datetime start_point: Start point for the component
        :param list socs_to_reset: List of SOCs to reset
        :return str timestamp: Timestamp
        """
        self.logger.debug(f"Check reset timestamps of {given_bbpool} by checking timestamps of {socs_to_reset}")
        ims_path = self.log_collector.ims_file_name
        if not os.path.exists(ims_path):
            self.log_collector.collect_ims(ims_path)
        durations = []
        for bbpool_distname in socs_to_reset:
            bbpool_reset_dict = {}
            bbpool_reset_dict[bbpool_distname] = [{"operationalState": "disabled"}, {"operationalState": "enabled"}]
            time_stamps_of_soc = self.calculate_extra_kpi(bbpool_reset_dict, f"BBPool reset",
                                                          ims_path, start_point=start_point, only_timestamps=True)
            print(f"Timestamps of {bbpool_distname} are {time_stamps_of_soc}")
            if time_stamps_of_soc and len(time_stamps_of_soc) == 2:
                duration = (time_stamps_of_soc[-1] - time_stamps_of_soc[0]).total_seconds()
                info(f"Reset duration of {bbpool_distname} (operationalState enabled - disabled) was {duration}s.")
                durations.append(duration)
            else:
                error(f"Reset timestamps are not found for {bbpool_distname}. Cannot calculate BBPool reset duration.")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
        return durations
