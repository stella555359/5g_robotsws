import os
from datetime import datetime
from collections import defaultdict
from traceback import format_exception
from taf.sw.reporting_portal import reporting_portal
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import ScriptIssue
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.OmkpiStartupTimes import OmkpiStartupTimes
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import KpiNotFound, StartupLimitException
from testsuite.Oulu.TrunkEng.Common.Python.Resources.GetValuesFromImsHistory import GetValuesFromImsHistory
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.Kpi77aFilesAndStrings import Kpi77aFilesAndStrings


class OmkpiStartupTimesInterface(object):

    print_to_eventlog = False
    kpis_file_path = ""
    original_kpi18 = ""
    original_avg_kpi18 = ""
    original_target_kpi_lib = None
    original_avg_target_kpi_lib = None
    iteration = 0
    skipped_kpi_iterations = {}

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.omkpi = BuiltIn().get_library_instance("oam_kpi_calculations")
        self.report_omkpi = BuiltIn().get_library_instance("report_oam_kpi")
        self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")
        self.ims_history = GetValuesFromImsHistory()
        self.omkpi_resource = OmkpiStartupTimes()
        self.rep = reporting_portal()
        self.kpi_times = {}
        self.affected_cells = True
        self.test_case_kpis = []
        self.results = {}
        self.iteration_mods = 0
        self.ims_swdl = ""
        if BuiltIn().get_variable_value("${SERIAL_CONSOLE}"):
            self.omkpi.set_serial_console_connection_status(value=True)
        self.rfs = BuiltIn().get_variable_value("${RFS}")
        self.kpi77_calculations = Kpi77aFilesAndStrings()

    def _get_power_reset_ims(self, ims_path="", retry=0):
        """
        Get power reset ims

        :param str ims_path: IMS file path
        :param int retry: If retry is 0 and error is ErrorCode: 6, then try to get IMS file again
        """
        try:
            self.admin.collect_im_snapshot(ims_path, timeout=900, connection="log_admin")
            if self.rfs:
                self.admin.collect_im_snapshot(ims_path.replace(".ims2", "_remote.ims2"), timeout=900,
                                               connection="log_admin_remote")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AdminApiConnectionClosedException,
                AdminApiTerminatedException, AliasLookupError) as exception:
            tb = ''.join(format_exception(type(exception), exception, exception.__traceback__))
            if "ErrorCode: 69" in tb:
                if retry == 0:
                    warning(f"{ims_path} could not be collected, error: {exception.__class__.__name__}:{exception}\n"
                            f"{tb}.\nErrorCode 69 means that there has been timeout error. WAIT 15min and try again")
                    BuiltIn().sleep(900)
                    self._get_power_reset_ims(ims_path=ims_path, retry=1)
                else:
                    error("Ims file could not be get, error: ErrorCode: 69. Waiting did not help.")
            elif "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    warning(
                        f"Ims file could not be get, error: {exception.__class__.__name__}:{exception}\n"
                        f"{tb}. Restart admin connection and try again.")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    self._get_power_reset_ims(ims_path=ims_path, retry=1)
                else:
                    error("Ims file could not be get, error: ErrorCode: 6. Restarting admin connection did not help.")
            info(tb)
            error(f"Ims file could not be get, error: {exception.__class__.__name__}:{exception}")

    def _set_skipped_iterations(self):
        for kpi in self.test_case_kpis:
            info(f"Set {kpi} as skipped iteration for loop {self.logger.loop + 1}")
            OmkpiStartupTimesInterface.skipped_kpi_iterations.setdefault(kpi, []).append(self.logger.loop + 1)
            # this is needed as skipped_kpi_iterations is used after class init
            BuiltIn().set_suite_variable("${SKIPPED_KPI_ITERATIONS}",
                                         OmkpiStartupTimesInterface.skipped_kpi_iterations)

    def _get_kpi55_for_radio(self, type_radio_cells, devices_info, test_case, ims_path, ims_merge_needed, radio_name):
        if not radio_name:
            error("There is no name for radio.")
            return None
        if radio_name not in type_radio_cells:
            error(f"{radio_name} was not found from the environment.")
            return None
        type_cells = []
        serial_numbers = ""
        last_radio_of_type = ""
        err_text = ""
        for radio, cell_names in type_radio_cells[radio_name].items():
            for cell in cell_names:
                if cell not in type_cells:
                    type_cells.append(cell)
            if not serial_numbers:
                serial_numbers = f"{devices_info[radio]['serial_number']}"
            else:
                serial_numbers += f", {devices_info[radio]['serial_number']}"
            last_radio_of_type = radio
        devices_info[last_radio_of_type]['serial_number'] = serial_numbers
        info(f"Calculating KPI for radio type {radio_name}. All cells affected by the radio type are: "
             f"\n{type_cells}")
        kpi_params = self.omkpi_resource.form_kpi_params(type_cells, test_case)
        self.omkpi.calculate_kpis(
            kpi_names=self.omkpi_resource.lib_kpis[test_case], ims_file_path=ims_path,
            kpi_params=kpi_params, merge_ims_files=ims_merge_needed)
        for kpi in self.omkpi_resource.lib_kpis[test_case]:
            self.logger.debug(f"Updating device info for {kpi} in the latest iteration "
                              f"{devices_info}.")
            self.omkpi.update_device_info_in_latest_iteration(
                kpi_name=kpi, value=devices_info[last_radio_of_type])
        radio_result = self.omkpi.get_results()
        self.results.update(radio_result)
        if self.results:
            r_success = self._loop_kpi_for_radio_type(radio_name)
            if not r_success:
                err_text += f"KPI of {radio_name} fails.\n"
        return err_text

    def _try_to_get_bts_info(self, admin_connection="default"):
        try:
            bts_info = self.admin.get_bts_info(detailed_output=True, connection=admin_connection)
        except Exception as e:
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            error(f"Could not get BTS info with connection {admin_connection}. Error: {e.__class__.__name__}:{e}")
            bts_info = None
        return bts_info

    def _select_or_get_bts_info(self):
        """
        Select bts_info to use in KPI calculations. If bts_info is already given in BTS library, use it. Otherwise,
        try to get. If BTS info cannot be get, set bts_info to None. In this kpi77a LTE should always be on the not
        tested side so we need to pass the remote bts_info.
        """
        if self.log_collector.rfs:
            other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
            if other_master:
                self.logger.debug("Other BTS is master, so pass not tested local BTS info for KPI calculations.")
                if self.bts.bts_info:
                    bts_info = self.bts.bts_info
                else:
                    bts_info = self._try_to_get_bts_info(admin_connection="default")
            else:
                if self.bts.bts_info_remote:
                    bts_info = self.bts.bts_info_remote
                else:
                    bts_info = self._try_to_get_bts_info(admin_connection="remote")
        else:
            self.logger.debug("RFS is not used. Return bts_info of the tested side")
            if self.bts.bts_info:
                bts_info = self.bts.bts_info
            else:
                bts_info = self._try_to_get_bts_info(admin_connection="default")
        if bts_info:
            if "requestMessage" in bts_info:
                return bts_info["requestMessage"]
            else:
                return bts_info
        else:
            error("BTS info cannot be get. Set bts_info to None for KPI calculations.")
            return None

    def collect_kpis(self, test_case, *args):
        """
        Collect KPI results from ims file.

        :param str test_case: Name for the test case. Options: Site reset
        :param args: Additional KPI params: start_point_timestamp, global_cell_id, dist_name. Check list below:
            'kpi3': {'start_point_timestamp': datetime},
            'kpi16a': {'global_cell_id': str},
            'kpi17a': {'global_cell_id': str, 'dist_name': str},
            'kpi17b': {'global_cell_id': str, 'dist_name': str},
            'kpi54a': {'start_point_timestamp': datetime},
            'kpi54b': {'start_point_timestamp': datetime}
        :return dict results: KPI results
        """
        self.results = {}
        ims_merge_needed = False
        if (BuiltIn().get_variable_value("${SKIP_KPI_CALCULATIONS}") and test_case !=
                "UE perceived outage during upgrade for CPRI radio module"):
            info("SKIP_KPI_CALCULATIONS is set to True. Skipping KPI calculations.")
            self._set_skipped_iterations()
            return self.results
        if "${ADD_KPI55C}" in BuiltIn().get_variables():
            if (test_case in self.omkpi_resource.lib_kpis and test_case == "Manual RU SW upgrade downtime"
                    and "KPI55c" not in self.omkpi_resource.lib_kpis[test_case]):
                info(f"Adding KPI55c to the KPI list of the test case '{test_case}'")
                self.omkpi_resource.lib_kpis[test_case].append("KPI55c")
        # if "${ADD_KPI55D}" in BuiltIn().get_variables():
        #     if (test_case in self.omkpi_resource.lib_kpis and test_case == "Manual RU SW upgrade downtime"
        #             and "KPI55d" not in self.omkpi_resource.lib_kpis[test_case]):
        #         info(f"Adding KPI55D to the KPI list of the test case '{test_case}'")
        #         self.omkpi_resource.lib_kpis[test_case].append("KPI55d")
        if "${ADD_KPI55E}" in BuiltIn().get_variables():
            if (test_case in self.omkpi_resource.lib_kpis and test_case == "Manual RU SW upgrade downtime"
                    and "KPI55e" not in self.omkpi_resource.lib_kpis[test_case]):
                info(f"Adding KPI55E to the KPI list of the test case '{test_case}'")
                self.omkpi_resource.lib_kpis[test_case].append("KPI55e")
        self.test_case_kpis = [kpi.lower() for kpi in self.omkpi_resource.lib_kpis[test_case]]
        if "${CALCULATE_KPI}" in BuiltIn().get_variables():
            calculate_kpi = BuiltIn().get_variable_value("${CALCULATE_KPI}")
            self.logger.debug(f"Variable CALCULATE_KPI is set to {calculate_kpi}")
            print(f"Variable CALCULATE_KPI is set to {calculate_kpi}")
            if not calculate_kpi:
                info(f"Do not collect any KPIs. Variable CALCULATE_KPI is set to {calculate_kpi}. Skipping KPI "
                     f"calculations.")
                self._set_skipped_iterations()
                return self.results
        ims_path = None
        try:
            if test_case == "BTS SW upgrade from FDSW":
                swdl_report_path = BuiltIn().get_variable_value("${SWDL_REPORT}")
                self.omkpi.calculate_kpi61a(swdl_report_file_path=swdl_report_path)
                self.results = self.omkpi.get_results()
                print(self.results)
            elif test_case == "UE perceived outage during upgrade for CPRI radio module":
                swdl_start = BuiltIn().get_variable_value("${SWDL_START}")
                if not swdl_start:
                    error("SWDL_START variable is not set. Cannot calculate KPI#77a.")
                    raise KpiNotFound("SWDL_START variable is not set. Cannot calculate KPI#77a.")
                start_point_file = self.kpi77_calculations.get_kpi77a_startpoint_file(swdl_start)
                end_point_files = self.kpi77_calculations.get_kpi77a_endpoint_files(swdl_start)
                bts_info = self._select_or_get_bts_info()
                self.logger.debug(f"Content of BTS info used for KPI#77a calculations:\n{bts_info}")
                BuiltIn().set_suite_variable("${LOOP_KPI}", "kpi77a")
                self.omkpi.calculate_kpi77a(bts_info, start_point_file, end_point_files)
                self.results = self.omkpi.get_results()
                print(self.results)
                # info("NOTE there is no support for KPI#77a in taf.ul.oam_kpi_calculations, skip kpi calculations")
                # BuiltIn().set_suite_variable("${SKIP_KPI_CALCULATIONS}", "${True}")
                # info("SKIP_KPI_CALCULATIONS is set to True. Skipping KPI calculations.")
                # self._set_skipped_iterations()
                return self.results
            else:
                if "SWDL_test" in args:
                    self.logger.debug(f"SWDL test in question: {args}")
                    name_for_swdl_ims = args[1]
                    # Timestamp is long -> it is not used now. If it later looks like it should, use it.
                    swdl_log_name = f"IMS_of_{name_for_swdl_ims.replace(' ', '_')}.ims2"
                    ims_path = os.path.join(self.logger.log_dir, swdl_log_name)
                    self.ims_swdl = ims_path
                    args = ()
                    ims_merge_needed = True
                else:
                    ims_path = self.log_collector.ims_file_name
                if test_case == "Power reset":
                    ims_path = ims_path.replace(".ims2", "_omkpi_power.ims2")
                    self._get_power_reset_ims(ims_path=ims_path)
                elif test_case == "Intra-release blue-green SW activation downtime":
                    info(f"Get IM snapshot to file {ims_path} in blue-green SW activation test")
                    self._get_power_reset_ims(ims_path=ims_path)
                else:
                    if os.path.exists(ims_path) and os.path.isfile(ims_path) and os.path.getsize(ims_path) > 0:
                        print(f"IMS file is already collected, no need to save it again: {ims_path}")
                        self.logger.debug(f"IMS file is already collected, no need to save it again: {ims_path}")
                    else:
                        self.log_collector.collect_ims(ims_path)
                if not self.log_collector.check_if_ims2_is_ok(ims_path):
                    info(f"File {ims_path} is not suitable for KPI calculations.")
                if self.log_collector.ims_file_name_after_swdl:
                    if self.log_collector.check_if_ims2_is_ok(self.log_collector.ims_file_name_after_swdl):
                        print("Collecting KPIs from IMS file after SWDL, give two ims files to calculate KPIs")
                        self.logger.debug("Collecting KPIs from IMS file after SWDL, give two ims files.")
                        ims_path = [self.log_collector.ims_file_name_after_swdl, ims_path]
                    else:
                        info(
                            f"File {self.log_collector.ims_file_name_after_swdl} is not suitable for KPI calculations.")
                if self.log_collector.ims_file_from_disconnection:
                    print(f"Ims2 file from disconnection: {self.log_collector.ims_file_from_disconnection}")
                    self.logger.debug(f"Ims2 file from disconnection: {self.log_collector.ims_file_from_disconnection}")
                    if self.log_collector.check_if_ims2_is_ok(self.log_collector.ims_file_from_disconnection):
                        if isinstance(ims_path, list):  # ims2 after cells disabled was get and disconnection logs
                            self.logger.debug("ims2 after cells disabled was get and also disconnection logs")
                            ims_path.insert(1, self.log_collector.ims_file_from_disconnection)
                        else:  # ims2 after cells disabled was not get
                            self.logger.debug("ims2 after cells disabled was not get")
                            ims_path = [self.log_collector.ims_file_from_disconnection, ims_path]
                        if self.log_collector.ims_file_from_disconnection not in self.log_collector.do_not_move:
                            self.log_collector.do_not_move.append(self.log_collector.ims_file_from_disconnection)
                    else:
                        info(f"File {self.log_collector.ims_file_from_disconnection} is not suitable for KPI "
                             f"calculations.")
                kpi_params = self.omkpi_resource.form_kpi_params(args, test_case)
                if self.rfs and test_case.lower() == "power reset":
                    ims_merge_needed = True
                    if isinstance(ims_path, list):
                        remote_file_names = [one_ims_path.replace(".ims2", "_remote.ims2") for one_ims_path in
                                             ims_path if "disconnect_at" not in one_ims_path]
                        for remote_file in remote_file_names:
                            if self.log_collector.check_if_ims2_is_ok(remote_file):
                                self.logger.debug(f"Remote IMS file is suitable for KPI calculations: {remote_file}")
                                ims_path.append(remote_file)
                            else:
                                info(f"File {remote_file} is not suitable for KPI calculations.")
                        # ims_path.extend(remote_file_names)
                    else:
                        ims_path = [ims_path, ims_path.replace(".ims2", "_remote.ims2")]
                if not ims_path:
                    info("Parameter ims_path is empty. Try to get ims2 file.")
                    ims_path = self.log_collector.collect_ims()
                self.logger.debug(f"Get KPIs from file(s): '{ims_path}', \nKPI results: {self.results}")
                if test_case == "Manual RU SW upgrade downtime":
                    type_radio_cells, devices_info = self._get_radio_type_radio_and_cells()
                    s_variables = BuiltIn().get_variables()
                    if "${RADIO_TYPE}" in s_variables:
                        radio_type = BuiltIn().get_variable_value("${RADIO_TYPE}")
                        if radio_type in type_radio_cells:
                            info(f"Calculating KPI for radio type {radio_type}. All cells affected by the radio type "
                                 f"are: \n{type_radio_cells[radio_type]}")
                            kpi_params = self.omkpi_resource.form_kpi_params(type_radio_cells[radio_type], test_case)
                            self.omkpi.calculate_kpis(
                                kpi_names=self.omkpi_resource.lib_kpis[test_case], ims_file_path=ims_path,
                                kpi_params=kpi_params, merge_ims_files=ims_merge_needed)
                            self.results = self.omkpi.get_results()
                    elif "${ADD_KPI55E}" in s_variables and BuiltIn().get_variable_value("${ADD_KPI55E}"):
                        radio_name = BuiltIn().get_variable_value("${RADIO_NAME}")
                        if not radio_name:
                            error("User has not given any name of any radio as variable RADIO_NAME for KPI55e.")
                            return None
                        error_messages = ""
                        if isinstance(radio_name, list):
                            self.logger.debug(f"Multiple radio types given for RADIO_NAME variable {radio_name}")
                            for rmod in radio_name:
                                error_messages += self._get_kpi55_for_radio(type_radio_cells, devices_info, test_case,
                                                                            ims_path, ims_merge_needed, rmod)
                        else:
                            error_messages = self._get_kpi55_for_radio(type_radio_cells, devices_info, test_case,
                                                                       ims_path, ims_merge_needed, radio_name)
                        if error_messages:
                            error(error_messages)
                            print("KPI fails. Set test to fail so we have logs to analyze from the loop.")
                            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    else:
                        info("Collecting KPIs for Manual RU SW upgrade downtime, KPI#55.\nMethod calculate_kpis will be"
                             f" called {len(type_radio_cells.keys())} times. This is a WA for getting own KPI value for"
                             f" each radio type.")
                        info(f"KPIs of radio types are calculated in this order: {list(type_radio_cells.keys())}")
                        all_rmods_success = True
                        self.logger.debug(f"Test case KPIs: {self.test_case_kpis}")
                        print(f"Test case KPIs: {self.test_case_kpis}")
                        all_radio_errors = ""
                        for r_type in type_radio_cells:
                            error_message = self._get_kpi55_for_radio(
                                type_radio_cells, devices_info, test_case, ims_path, ims_merge_needed, r_type)
                            if error_message:
                                all_rmods_success = False
                                all_radio_errors += error_message
                        if not all_rmods_success:
                            error(all_radio_errors)
                            print("KPI fails. Set test to fail so we have logs to analyze from the loop.")
                            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                            # raise StartupLimitException  cannot be raise error here so that self.results are returned
                else:
                    self.omkpi.calculate_kpis(
                        kpi_names=self.omkpi_resource.lib_kpis[test_case], ims_file_path=ims_path,
                        kpi_params=kpi_params, merge_ims_files=ims_merge_needed)
                    self.results = self.omkpi.get_results()
        except Exception as e:
            if (str(e.__class__.__name__) == "AttributeError" and "object has no attribute" in str(e) and
                    "get_decoder" in str(e)):
                error(f"Collecting KPIs failed by AttributeError. There may be a corrupted ims2 file. Check manually "
                      f"if files are not working:\n{ims_path}")
            else:
                error(f"Collecting KPIs failed by undefined error: {e.__class__.__name__}:{e}")
            info(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.iteration_mods -= 1
            info("Set test to fail (set LOOP_KPI_SUCCESS to False) so we will have some logs to analyze the issue.")
            BuiltIn().set_suite_variable("${LOOP_KPI_SUCCESS}", "${False}")
            self._set_skipped_iterations()
            pass
        if OmkpiStartupTimesInterface.print_to_eventlog:
            info(f"KPI results: {self.results}")
        else:
            self.logger.debug(f"KPI results: {self.results}")
        return None

    def _get_radio_type_radio_and_cells(self):
        """
        This is needed as a WA for KPI#55.
        """
        radio_type_radio_cells = {}
        devices_info = {}
        if not self.bts.radios:
            error("No radios found from the BTS. Cannot calculate KPIs for Manual RU SW upgrade downtime.")
            raise KpiNotFound("No radios found from the BTS. Cannot calculate KPIs for Manual RU SW upgrade downtime.")
        for radio in self.bts.radios:
            cell_names = []
            radio_type = radio.name.split("(")[0]
            if radio_type not in radio_type_radio_cells:
                radio_type_radio_cells[radio_type] = {}
            if radio.name not in devices_info:
                devices_info[radio.name] = {}
            cells_of_radio = self.bts.get_cells_of_radio(radio.name)
            for cell in cells_of_radio:
                internal_name = self.bts.cells[cell]["id"]["internal"]
                self.logger.debug(f"{cell} is same as {internal_name} (is connected to radio {radio.name})")
                cell_names.append(internal_name)
            print(f"cell_names: {cell_names}")
            radio_type_radio_cells[radio_type][radio.name] = cell_names
            device_info = self._create_radio_type_device_info(radio, radio_type)
            devices_info[radio.name] = device_info
        for i in radio_type_radio_cells:
            info(f"All RUs of type {i} are {radio_type_radio_cells[i]}")
        return radio_type_radio_cells, devices_info

    def _create_radio_type_device_info(self, rmod_object, radio_type):
        """
        Create radio type device info.

        :param rmod_object: RMOD object
        :param str radio_type: Radio type, for example FXCA
        """
        device_value = {
            'dist_name': rmod_object.dist_name,
            'product_code': rmod_object.product_code,
            'product_name': radio_type,
            'serial_number': rmod_object.serial_number
        }
        self.logger.debug(f"Device info for {rmod_object.dist_name}: {device_value}")
        return device_value

    def _loop_kpi_for_radio_type(self, radio_type):
        """
        Loop kpi for radio type calculates loop kpi values to eventlog.

        :param str radio_type: Radio type, for example FXCA
        """
        success = True
        self.logger.debug(f"Radio type results: {self.results}")
        targets = BuiltIn().get_variable_value("${OAM_KPI_TARGETS}")
        if not targets:
            error("OAM_KPI_TARGETS is not found. Cannot calculate KPIs for Manual RU SW upgrade downtime.")
            raise KpiNotFound("OAM_KPI_TARGETS is not found. Cannot calculate KPIs for Manual RU SW upgrade downtime.")
        if radio_type:
            OmkpiStartupTimesInterface.iteration += 1
            info(f"KPIs of {radio_type} (iteration_{OmkpiStartupTimesInterface.iteration}):")
            if not self.test_case_kpis:
                error("Test case is not found from the KPI library.")
                raise KpiNotFound("Test case is not found from the KPI library.")
            for kpi in self.test_case_kpis:
                if kpi not in self.results:
                    error(f"{kpi} was not found from the collected kpis for {radio_type}.")
                    raise KpiNotFound
                if kpi not in targets:
                    error(f"KPI {kpi} is not found from the KPI targets.")
                    raise KpiNotFound(f"KPI {kpi} is not found from the KPI targets.")
                if isinstance(targets[kpi], dict) and 'product_name' in targets[kpi]:
                    if radio_type in targets[kpi]['product_name']:
                        ru_limit = targets[kpi]['product_name'][radio_type]
                    elif "GENERAL" in targets[kpi]:
                        ru_limit = targets[kpi]['GENERAL']
                    else:
                        error(f"OAM_KPI_TARGETS is incorrectly created. There is product_name but not radio type "
                              f"{radio_type} nor GENERAL, NOK.")
                        raise KpiNotFound(f"OAM_KPI_TARGETS is incorrectly created for {kpi}.")
                else:
                    ru_limit = targets.get(kpi, 0)
                self.logger.debug(f"Target for {kpi} for {radio_type} is set to {ru_limit}s")
                kpi_success, _ = self.omkpi_resource.check_time_against_limit(
                    name=kpi, delta=self.results[kpi][len(self.results[kpi]) - 1]["delta"],
                    limit=ru_limit)
                success = success and kpi_success
        return success

    def check_loop_kpi(self, test_case, targets, cells=None):
        """
        Check loop KPIs against time limit. Print errors but doesn't fail the case

        :param str test_case: Name of the test case, e.g. Site reset
        :param dict targets: KPI limits in seconds.
        :param list cells: (Optional) Affected cells

        :return: None if KPI not calculated otherwise nothing
        """
        BuiltIn().set_suite_variable("${LOOP_KPI_SUCCESS}", "${True}")
        netact_active = self.bts.check_if_netact_is_active()
        if "${CALCULATE_KPI}" in BuiltIn().get_variables():
            calculate_kpi = BuiltIn().get_variable_value("${CALCULATE_KPI}")
            self.logger.debug(f"Variable CALCULATE_KPI is set to {calculate_kpi} (in check_loop_kpi)")
            print(f"Variable CALCULATE_KPI is set to {calculate_kpi} (in check_loop_kpi)")
            if not calculate_kpi:
                info(f"Skipping KPI calculations (check_loop_kpi), variable CALCULATE_KPI is set to {calculate_kpi}, "
                     f"check_loop_kpi returns True.")
                # BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                return True
        if BuiltIn().get_variable_value("${SKIP_KPI_CALCULATIONS}"):
            info("SKIP_KPI_CALCULATIONS is set to True (in check_loop_kpi), check_loop_kpi returns True")
            # BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            return True
        success = True
        if test_case == "Manual RU SW upgrade downtime":
            self.logger.debug("Loop KPIs for 'Manual RU SW upgrade downtime', KPI#55 is checked in previous method. "
                              "This check_loop_kpi KW will return True.")
            print("Loop KPIs for 'Manual RU SW upgrade downtime', KPI#55 is checked in previous method, check_loop_kpi "
                  "KW will return True. ")
            BuiltIn().set_suite_variable("${LOOP_KPI}", "kpi55")
            return success
        self.affected_cells = True
        if test_case not in self.omkpi_resource.lib_kpis:
            error(f"Test case '{test_case}' is not found from the KPI library.")
            raise KpiNotFound("Test case is not found from the KPI library.")
        self.test_case_kpis = [kpi.lower() for kpi in self.omkpi_resource.lib_kpis[test_case]]
        BuiltIn().set_suite_variable("${LOOP_KPI}", self._get_kpi_name_if_only_one_kpi_in_use(
            without_underscore=True).lower())
        if self.results:
            for kpi in self.test_case_kpis:
                if kpi not in self.results:
                    error(f"{kpi} was not found from the collected kpis.")
                    raise KpiNotFound
                kpi_success1 = True
                if "kpi12" in kpi:   # kpi12 is taken two times per each iteration
                    # takes always the second to last collected KPI
                    if len(self.results[kpi]) < 2:
                        error("Cannot calculate first KPI value of kpi12, because there is no enough kpi results.")
                        kpi_success1 = False
                    else:
                        info("Calculating first KPI value of kpi12 (second to last collected KPI).")
                        kpi_result = self.results[kpi][len(self.results[kpi]) - 2]["delta"]
                        kpi_success1, _ = self.omkpi_resource.check_time_against_limit(
                            name=kpi, delta=kpi_result, limit=targets.get(kpi, 0), netact_active=netact_active)
                # takes always the latest collected KPI
                kpi_result = self.results[kpi][len(self.results[kpi])-1]["delta"]
                kpi_success, _ = self.omkpi_resource.check_time_against_limit(
                    name=kpi, delta=kpi_result, limit=targets.get(kpi, 0), netact_active=netact_active)
                success = success and kpi_success and kpi_success1
        else:
            if cells is not None and not len(cells):
                self.affected_cells = False
                info("There are no affected cells. Skipping KPI calculations")
                success = True
            else:
                error(f"There are no results for {test_case}")
                success = False
        if not success:
            error(f"Loop {self.logger.loop + 1}: Loop KPI failed. Set test to fail so we have logs to analyze from the "
                  f"loop.")
            BuiltIn().set_suite_variable("${LOOP_KPI_SUCCESS}", "${False}")
        if BuiltIn().get_variable_value("${FAULT_CAUSE_DEGRADED_CELLS}"):
            if BuiltIn().get_variable_value("${DEGRADED_CELLS_FAULT_WAS_ACTIVE}"):
                if not BuiltIn().get_variable_value("${SERIAL_CONSOLE}"):
                    info("Remove degraded cells set by FAULT_CAUSE_DEGRADED_CELLS variable")
                    self.omkpi.set_serial_console_connection_status(value=False)
                alarms = BuiltIn().get_library_instance("ALARMS")
                alarms.remove_allowed_alarms_added_in_check_if_fault_active()
        return success

    def check_kpis_taf(self, targets, avg_targets="", rat=""):
        """
        Check KPIs against time limit

        :param dict targets: KPI limits in seconds.
        :param dict avg_targets: (Optional) Average KPI limits in seconds.
        :param str rat: (Optional) RAT
        """
        info("Checking KPIs and average KPIs against targets")
        if self.affected_cells:
            used_kpi = self._get_kpi_name_if_only_one_kpi_in_use()
            ref_tl = ""
            if BuiltIn().get_variable_value("${REFERENCE_TESTLINE}"):
                reference_testline = BuiltIn().get_variable_value("${REFERENCE_TESTLINE}")
                ref_tl = f"{reference_testline}_"
            testcase_dir = os.path.dirname(self.logger.log_dir)
            if not self.kpis_file_path:
                self.kpis_file_path = os.path.join(testcase_dir, f"{used_kpi}{ref_tl}{self.bts.active_sw}.txt")
            else:
                date = datetime.now().strftime("%Y%m%d_%H%M%S")
                self.kpis_file_path = os.path.join(testcase_dir, f"{used_kpi}{ref_tl}{self.bts.active_sw}_{date}.txt")
            skipped_kpi_iterations = BuiltIn().get_variable_value("${SKIPPED_KPI_ITERATIONS}", None)
            info(f"Skipped kpi iterations: {skipped_kpi_iterations}")
            all_results = self.report_omkpi.calculate_summary_results_and_save_to_file(
                oam_kpi_targets=targets, oam_kpi_avg_targets=avg_targets, kpi_summary_file_path=self.kpis_file_path,
                skipped_iterations=skipped_kpi_iterations)
            self.omkpi.clear_results()
            if not self.omkpi_resource.check_all_kpis(all_results, targets, avg_targets, rat, self.test_case_kpis):
                raise StartupLimitException
        else:
            info("There are no affected cells. Skipping KPI calculations")

    def _get_kpi_name_if_only_one_kpi_in_use(self, without_underscore=False):
        """
        Get KPI name if there is only one base KPI in use. For example KPI1 is the base KPI of KPI1a and KPI1b.
        If multiple base KPIs in use, returns an empty string.

        :param bool without_underscore: If True, returns KPI name without underscore.
        :return str return_kpi: Used KPI if only one base KPI in use, otherwise an empty string.
        """
        return_kpi = "KPIs_"
        if self.test_case_kpis:
            for kpi in self.test_case_kpis:
                if kpi == "kpi61a":
                    base_kpi = kpi
                else:
                    base_kpi = kpi[:-1] if kpi[-1].isalpha() else kpi  # remove the last character if it is a letter
                if return_kpi == "KPIs_":
                    return_kpi = base_kpi
                    continue
                if return_kpi != base_kpi:
                    return "KPIs_"
            return_kpi = return_kpi.replace('kpi', 'KPI')
            return f"{return_kpi}_" if not without_underscore else return_kpi
        return return_kpi

    def report_kpi_results(self, kpi_name="", result="", time=True, case_name="", success=False, reference_name=""):
        """
        Reports results to Reporting Portal. Reference testline name is given with KPI calculation.

        :param str kpi_name: KPI name. Needed when time=True
        :param str result: Result time for KPI. Needed when time=True
        :param bool time: Report time KPIs
        :param str case_name: Case name for success rate. Needed when time=False
        :param bool success: Success for case. Needed when time=False
        :param str reference_name: Reference testline name for PowerBI.
        """
        if time:
            self.rep.report_kpi_results("", kpi_name, "True", str(result), "int", reference_name, "OMKPI", "s")
            info(f"Reported to ReP: {kpi_name}: {result}")
        else:
            self.rep.report_kpi_results("", f"{case_name}: Success", "True", "1" if success else "0", "int",
                                        reference_name, "OMKPI", "")
            success = "Passed" if success else "Failed"
            info(f"Reported to ReP '{case_name}' success: {success}")

    def report_kpi_results_taf(self, targets, reference_testline=""):
        """
        Reports results to Reporting Portal. Reference testline name is given with KPI calculation.

        :param dict targets: KPI limits in seconds.
        :param str reference_testline: (Optional) Reference testline
        """
        if reference_testline:
            BuiltIn().run_keyword('taf.sw.reporting_portal.set_reference_configuration_id',
                                  f'ref_configuration_id={reference_testline}')
        selected_oam_kpi_results = {kpi_name: self.results[kpi_name] for kpi_name in self.results if
                                    kpi_name in self.test_case_kpis}
        self.report_omkpi.report_oam_kpi(oam_kpi_results=selected_oam_kpi_results, oam_kpi_targets=targets)

    def print_kpi_values_to_eventlog(self):
        self.logger.debug("Set print_to_eventlog variable to True")
        OmkpiStartupTimesInterface.print_to_eventlog = True

    def add_kpis_to_zip(self):
        if BuiltIn().get_variable_value("${ZIP_LOGS}") and self.kpis_file_path:
            info("Adding kpis.txt -file to loop zip-files")
            zipped_logs = self.omkpi_resource.find_all_logs_zips()
            self.omkpi_resource.add_kpi_file_to_zip(zipped_logs, self.kpis_file_path)

    @staticmethod
    def _check_what_key_to_use_for_kpi18_and_kpi5(kpi_lib):
        kpi18_key = "kpi18" if "kpi18" in kpi_lib else "kpi18a" if "kpi18a" in kpi_lib else None
        if not kpi18_key:
            error("Neither kpi18 nor kpi18a found in OAM_KPI_TARGETS. Skipping KPI#18 target change.")
            return None, None
        kpi5_key = "kpi5" if "kpi5" in kpi_lib else "kpi5a" if "kpi5a" in kpi_lib else None
        if not kpi5_key:
            error("Neither kpi5 nor kpi5a found in OAM_KPI_TARGETS. Skipping KPI#5 target change.")
            return None, None
        return kpi18_key, kpi5_key

    def check_if_bbmod_reset_and_change_kpi_target(self):
        """ If BBPool reset resets BBMOD unit, then target of the KPI#18 should be same that is given in KPI#5. """
        if "${BBPOOL_RESETS_BBMOD}" in BuiltIn().get_variables() and BuiltIn().get_variable_value(
                "${BBPOOL_RESETS_BBMOD}"):
            self.logger.debug("BBPOOL resets whole BBMOD")
            kpi_lib = BuiltIn().get_variable_value("${OAM_KPI_TARGETS}")
            kpi18_key, kpi5_key = self._check_what_key_to_use_for_kpi18_and_kpi5(kpi_lib)
            if not kpi18_key or not kpi5_key:
                return
            OmkpiStartupTimesInterface.original_kpi18 = kpi_lib[kpi18_key]
            info(f"BBPool resets BBMOD unit. Change KPI#18 ({kpi18_key}: {kpi_lib[kpi18_key]}) target to be same as "
                 f"KPI#5 ({kpi5_key}: {kpi_lib[kpi5_key]}).")
            kpi_lib[kpi5_key] = kpi_lib[kpi5_key]
            kpi_average_lib = BuiltIn().get_variable_value("${AVG_OAM_KPI_TARGETS}")
            info(f"BBPool resets BBMOD unit. Change average KPI#18 ({kpi18_key}: {kpi_average_lib[kpi18_key]}) target "
                 f"to be same as KPI#5 ({kpi5_key}: {kpi_average_lib[kpi5_key]}).")
            OmkpiStartupTimesInterface.original_avg_kpi18 = kpi_average_lib[kpi18_key]
            kpi_average_lib[kpi18_key] = kpi_average_lib[kpi5_key]
            BuiltIn().set_suite_variable("${OAM_KPI_TARGETS}", kpi_lib)
            BuiltIn().set_suite_variable("${AVG_OAM_KPI_TARGETS}", kpi_average_lib)

    def change_kpi_targets_back_to_normal(self):
        """ If BBPool reset resets BBMOD unit, then target of the KPI#18 were changed to the value that is given in
        KPI#5. Change back values of original KPI#18 and average KPI#18. """
        if "${BBPOOL_RESETS_BBMOD}" in BuiltIn().get_variables() and BuiltIn().get_variable_value(
                "${BBPOOL_RESETS_BBMOD}"):
            kpi_lib = BuiltIn().get_variable_value("${OAM_KPI_TARGETS}")
            kpi18_key, kpi5_key = self._check_what_key_to_use_for_kpi18_and_kpi5(kpi_lib)
            if not kpi18_key or not kpi5_key:
                return
            info(f"BBPool resets BBMOD unit. Change changed KPI#18 ({kpi18_key}: {kpi_lib[kpi18_key]}) target back to "
                 f"original ({OmkpiStartupTimesInterface.original_kpi18}).")
            kpi_lib[kpi18_key] = OmkpiStartupTimesInterface.original_kpi18
            kpi_average_lib = BuiltIn().get_variable_value("${AVG_OAM_KPI_TARGETS}")
            info(f"BBPool resets BBMOD unit. Change changed average KPI#18 ({kpi18_key}: {kpi_average_lib[kpi18_key]}) "
                 f"target back to original ({OmkpiStartupTimesInterface.original_avg_kpi18}).")
            kpi_average_lib[kpi18_key] = OmkpiStartupTimesInterface.original_avg_kpi18
            BuiltIn().set_suite_variable("${OAM_KPI_TARGETS}", kpi_lib)
            BuiltIn().set_suite_variable("${AVG_OAM_KPI_TARGETS}", kpi_average_lib)
            self.logger.debug("Set BBPOOL_RESETS_BBMOD variable to False")
            BuiltIn().set_suite_variable("${BBPOOL_RESETS_BBMOD}", "${False}")

    def print_extra_kpis(self, test_case, start_point="", cells=False, retry=0, cells_to_print=None):
        """
        Print extra KPI results for test cases that need extra KPIs.
        :param test_case: Name of the test case
        :param start_point: Start point for the component
        :param bool cells: If true prints cells disabled-enabled times
        :param int retry: if retry is 0 and ErrorCode 6, then makes admin reset and recalls this method
        :param list cells_to_print: List of cells to print KPI for
        """
        try:
            def get_link_dn():
                lnmme_params = self.admin.get_parameters_for_all("LNMME")
                servedamf_params = self.admin.get_managed_objects("SERVEDAMF_R")
                lnmme_dn = lnmme_params[0]['id'] if lnmme_params else ""
                servedamf_dn = servedamf_params[0]['distName'] if servedamf_params else ""
                return lnmme_dn if lnmme_dn else servedamf_dn

            link_dn = get_link_dn()
            faulty_bbmods = BuiltIn().get_variable_value("${FAULTY_BBMODS}", default=[])
            faulty_rmods = BuiltIn().get_variable_value("${FAULTY_BBMODS_RMODS}", default=[])
            faulty_cells = BuiltIn().get_variable_value("${FAULTY_BBMODS_CELLS}", default=[])
            faulty_loki_cells = BuiltIn().get_variable_value("${F_LOKI_CELLS}", default=[])
            faulty_loki_rmods = BuiltIn().get_variable_value("${F_LOKI_RMODS}", default=[])
            faulty_loki_bbmod = BuiltIn().get_variable_value("${F_LOKI_BBMOD}", default=[])

            units = {
                "BBMOD": [bbmod.dist_name for bbmod in self.bts.bbmods if ((bbmod.name not in faulty_bbmods) and
                                                                           (bbmod.name not in faulty_loki_bbmod))],
                "RMOD": [rmod.dist_name for rmod in self.bts.radios if ((rmod.name not in faulty_rmods) and
                                                                        (rmod.name not in faulty_loki_rmods))],
                "CELLS": [cell["id"]["internal"] for cell in self.bts.cells.values()],
                "MRBTS": [self.admin.get_managed_objects("MRBTS_M")[0]['distName']],
                "link": [link_dn],
                "time": [self.admin.get_managed_objects("TIME")[0]['distName']],
                "clock": [self.admin.get_managed_objects("CLOCK")[0]['distName']],
                "RU_RESET": [rmod.dist_name for rmod in self.bts.radios],
                "SMOD": [smod.r_dist_name for smod in self.bts.smods if not smod.remote],
            }
            if faulty_cells or faulty_loki_cells:
                self.logger.debug(f"faulty_cells: {faulty_cells}\nfaulty_loki_cells: {faulty_loki_cells}")
                update_list = units["CELLS"]
                self.logger.debug(f"update_list: {update_list}")
                for cel in units["CELLS"]:
                    for cell_name, cell_info in self.bts.cells.items():
                        self.logger.debug(f"!!!! cell_name: {cell_name}")
                        if (cell_name in faulty_cells or cell_name in faulty_loki_cells) and (
                                cell_info['id']['internal'] == cel):
                            self.logger.debug(f"Remove {cel} from state checks because it is allowed to be faulty")
                            update_list.remove(cel)
                units["CELLS"] = update_list
                self.logger.debug(f"After update update_list: {update_list}")
            states = {
                "BBMOD": [{"operationalState": "enabled"}],
                "RMOD": [{"operationalState": "enabled"}],
                "CELLS": [{"operationalState": "enabled"}],
                "CELLS_DISABLED": [{"operationalState": "disabled"},
                                   {"operationalState": "enabled"}],
                "MRBTS": [{'stateInfo': {'proceduralState': 'Commissioned'}},
                          {'stateInfo': {'proceduralState': 'IntegratedToRan'}},
                          {'stateInfo': {'proceduralState': 'OnAir'}}],
                "link": [{"s1LinkStatus": "available"} if "LNMME" in link_dn else {"ngLinkStatus": "Active"}],
                "time": [{'stateInfo': {'operationalState': 'Enabled'}}],
                "clock": [{'tuningVariant': 'None'},
                          {'tuningVariant': 'Coarse'},
                          {'tuningVariant': 'Normal'}],
                # Order is critical here, don't change it!
                "RU_RESET": [{'proceduralStatus': 'not initialized'},
                             {'proceduralStatus': 'initializing'},
                             {'operationalState': 'disabled'},
                             {'operationalState': 'enabled'},
                             {'proceduralStatus': 'configured'},
                             ],
                "SMOD": [{'operationalState': 'enabled'}],
            }
            needed_kpis = {
                "Site reset": ["RMOD", "BBMOD", "MRBTS", "CELLS", "link", "clock", "SMOD"],
                "Power reset": ["RMOD", "BBMOD", "MRBTS", "CELLS", "link", "time", "clock", "SMOD"],
                "Manual RU SW upgrade downtime": ["RMOD", "CELLS"],
                "Independent sequential RUs SW upgrade duration": ["RMOD", "CELLS"],
                "Remote power reset": ["RMOD", "BBMOD", "MRBTS", "CELLS", "link", "time", "clock", "SMOD"],
                "SWDL_test": ["RMOD", "BBMOD", "MRBTS", "CELLS", "link", "time", "clock", "SMOD"],
                "Sw rollback": ["RMOD", "BBMOD", "MRBTS", "CELLS", "link", "time", "clock", "SMOD"],
                "Commissioning reset": ["RMOD", "BBMOD", "MRBTS", "CELLS", "link", "time", "clock", "SMOD"],
                "RU reset": ["RU_RESET"]
            }
            component_state_dict = defaultdict(list)
            ims_path = self.log_collector.ims_file_name
            if "Power reset" in test_case:
                ims_path = self.log_collector.ims_file_name.replace(".ims2", "_omkpi_power.ims2")
            if "SWDL_test" in test_case:
                ims_path = self.ims_swdl
            if not os.path.exists(ims_path):
                self.log_collector.collect_ims(ims_path)
            if not start_point:
                start_point = self.ims_history.check_if_reset_happened(ims_path)
            if test_case in needed_kpis:
                for unit in needed_kpis[test_case]:
                    for unit_dn in units[unit]:
                        if unit_dn:
                            for state in states[unit]:
                                component_state_dict[unit_dn].append(state)
                self.logger.debug(f"Component state dict: {component_state_dict}")
                self.omkpi_resource.calculate_extra_kpi(component_state_dict, test_case, ims_path,
                                                        start_point=start_point, print_time=True, write_file=True,
                                                        rfs=self.rfs)
            if cells:
                try:
                    if "RU reset" in test_case:
                        cell_state_dict = {cell["id"]["internal"]: states["CELLS_DISABLED"]
                                           for cell_name, cell in self.bts.cells.items() if cell_name in cells_to_print}
                    else:
                        cell_state_dict = {cell: states["CELLS_DISABLED"] for cell in units["CELLS"]}
                    self.omkpi_resource.print_cells_disabled_enabled(cell_state_dict, ims_path, start_point)
                except (KeyError, AttributeError, TypeError) as ex:
                    info(f"{ex.__class__.__name__}:{ex}\n{''.join(format_exception(type(ex), ex, ex.__traceback__))}")
            if ("Manual RU SW upgrade downtime" in test_case or
                    "Independent sequential RUs SW upgrade duration" in test_case):
                try:
                    rmod_state_dict = {rmod: states["CELLS_DISABLED"] for rmod in units["RMOD"]}
                    self.omkpi_resource.print_rmods_disabled_enabled(rmod_state_dict, ims_path, start_point)
                except (KeyError, AttributeError, TypeError) as e:
                    info(f"{e.__class__.__name__}:{e}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AdminApiConnectionClosedException,
                AdminApiTerminatedException, AliasLookupError) as exception:
            tb = ''.join(format_exception(type(exception), exception, exception.__traceback__))
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    warning(f"Extra KPI could not be get, error: {exception.__class__.__name__}:{exception}\n"
                            f"{tb}. Restart admin connection and try again.")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    self.print_extra_kpis(test_case=test_case, start_point=start_point, cells=cells, retry=1)
                else:
                    error("Extra KPI could not be get, error: ErrorCode: 6. Restarting admin connection did not help.")
            error(f"Extra KPI could not be get, error: {exception.__class__.__name__}:{exception}\n{tb}")

    def _change_value_of_kpi_lib(self, kpi_lib, kpi_name, new_value, lib_name_for_print):
        """
        Change value of KPI lib in the given file.

        :param dict kpi_lib: KPI lib
        :param str/list kpi_name: Name of the KPI for example 'kpi55a' or ['kpi55a', 'kpi55b']
        :param int new_value: New value for the KPI for example 500
        """
        self.logger.debug(f"Change value of the {lib_name_for_print} KPI lib")
        if isinstance(kpi_name, list):
            for kpi in kpi_name:
                old_value = kpi_lib[kpi]
                kpi_lib[kpi] = int(new_value)
                info(f"Change {lib_name_for_print} value of the {kpi} from {old_value} to {new_value}")
        elif isinstance(kpi_name, str):
            old_value = kpi_lib[kpi_name]
            kpi_lib[kpi_name] = int(new_value)
            info(f"Change {lib_name_for_print} value of the {kpi_name} from {old_value} to {new_value}")
        else:
            error(f"KPI name should be string or list, not {type(kpi_name)}")
            raise ScriptIssue("KPI name should be string or list")
        return kpi_lib

    def change_value_of_avg_oam_kpi_target(self, kpi_name, new_value):
        """
        Change value of avg oam kpi target method changes value of some kpi/kpis to given value.

        :param str/list kpi_name: Name of the KPI for example 'kpi55a' or ['kpi55a', 'kpi55b']
        :param int/str new_value: New value for the KPI for example 500
        """
        kpi_lib = BuiltIn().get_variable_value("${AVG_OAM_KPI_TARGETS}")
        OmkpiStartupTimesInterface.original_avg_target_kpi_lib = kpi_lib
        updated_kpi_lib = self._change_value_of_kpi_lib(kpi_lib, kpi_name, new_value, "AVG_OAM_KPI_TARGETS")
        BuiltIn().set_suite_variable("${AVG_OAM_KPI_TARGETS}", updated_kpi_lib)

    def change_value_of_oam_kpi_target(self, kpi_name, new_value):
        """
        Change value of oam kpi target method changes value of some kpi/kpis to given value.

        :param str/list kpi_name: Name of the KPI for example 'kpi55a' or ['kpi55a', 'kpi55b']
        :param int/str new_value: New value for the KPI for example 500
        """
        kpi_lib = BuiltIn().get_variable_value("${OAM_KPI_TARGETS}")
        OmkpiStartupTimesInterface.original_target_kpi_lib = kpi_lib
        updated_kpi_lib = self._change_value_of_kpi_lib(kpi_lib, kpi_name, new_value, "OAM_KPI_TARGETS")
        BuiltIn().set_suite_variable("${OAM_KPI_TARGETS}", updated_kpi_lib)

    def change_value_of_kpi_targets_back_to_original(self):
        """
        Change value of kpi target back to original method changes kpi/kpis back to original value.
        """
        self.logger.debug("Change value of kpi targets back to original")
        if OmkpiStartupTimesInterface.original_target_kpi_lib:
            BuiltIn().set_suite_variable("${OAM_KPI_TARGETS}", OmkpiStartupTimesInterface.original_target_kpi_lib)
        if OmkpiStartupTimesInterface.original_avg_target_kpi_lib:
            BuiltIn().set_suite_variable("${AVG_OAM_KPI_TARGETS}",
                                         OmkpiStartupTimesInterface.original_avg_target_kpi_lib)

    def check_max_bbpool_duration(self, given_bbpool, start_point, socs_to_reset):
        """
        Check max BBPool duration. If duration is over 150 seconds, set test to fail.

        :param str given_bbpool: Given BBPool name e.g. BBPool11
        :param start_point: Start point timestamp
        :param list socs_to_reset: List of SOCs to reset
        :raises StartupLimitException: If BBPool reset duration is over 150 seconds
        """

        reset_timestamps = self.omkpi_resource.bbpool_reset_timestamps(given_bbpool, start_point, socs_to_reset)
        if not reset_timestamps:
            error("BBPool reset duration timestamps were not get. Cannot check if BBPool reset duration is less than "
                  "150s")
        elif not any(duration > 150 for duration in reset_timestamps):
            info(f"BBPool reset duration was less than 150s. OK.")
        else:
            error("BBPool reset duration is over 150 seconds. Set test to fail.")
            raise StartupLimitException("BBPool reset duration is over 150 seconds.")

    def get_omkpi_timestamp(self, timestamp):
        """
        Get OMKPI timestamp in PC format.
        :param datetime timestamp: Timestamp to be converted
        :return: datetime PC format timestamp
        """
        return self.syslog_search.add_delta_time_to_pc_timestamp(timestamp)
