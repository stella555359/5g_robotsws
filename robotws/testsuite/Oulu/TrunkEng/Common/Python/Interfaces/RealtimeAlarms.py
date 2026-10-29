"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import re
from collections import defaultdict
from robot.libraries.BuiltIn import BuiltIn
from collections import namedtuple
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, alarm, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.HaltTests import HaltTest
from threading import Thread
from traceback import format_exception
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse

Alarm = namedtuple("Alarm", ['alarm_id', 'fault_id', 'fault_name', 'hw_path', 'severity', 'reason', 'unit_path',
                             'impacted_cells_list', 'impacted_cell', 'degraded_cells', 'faulty_cells',
                             'cells_cli_info'])


class RealtimeAlarms:
    """
    RealtimeAlarms is used for printing alarms to eventlog in realtime.
    RealtimeAlarms start and stop is called in pass_rate.py.
    """
    # To this list all active alarms that were seen during session are collected
    active_alarms_during_test = defaultdict(list)
    checks_alarms_in_realtime = False
    _detected_alarms = defaultdict(list)
    admin_connection_ok = False
    admin_connection_remote_ok = False

    def __init__(self):
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        RealtimeAlarms._detected_alarms = defaultdict(list)
        self.rfs = BuiltIn().get_variable_value("${RFS}")
        self._thread = None
        self._running = False
# rfs
        self._thread_remote = None
        self._running_remote = False
        self._alarm_interval = 0

    def _check_and_set_alarm_interval(self):
        if "${RT_ALARM_UPDATE_INTERVAL}" in BuiltIn().get_variables():
            update_interval = BuiltIn().get_variable_value("${RT_ALARM_UPDATE_INTERVAL}")
            if isinstance(update_interval, int) or update_interval.isdigit():
                self._alarm_interval = int(update_interval)
            else:
                error(f"User has given invalid value for RT_ALARM_UPDATE_INTERVAL. It should be integer or numeric"
                      f" string, not {update_interval}. ")

    @property
    def detected_alarms(self):
        return RealtimeAlarms._detected_alarms

    @detected_alarms.setter
    def detected_alarms(self, detected_alarms):
        RealtimeAlarms._detected_alarms = detected_alarms

    def connect_admin(self, starting_thread=False):
        """
        Connect to admin for realtime alarm listener. Update_interval can be modified with TAG
        RT_ALARM_UPDATE_INTERVAL

        :param bool starting_thread: If True we check previous values of RealtimeAlarms.admin_connection_ok and
                                     RealtimeAlarms.admin_connection_remote_ok
        """
        interval = 250
        ip = '192.168.255.129'
        if "${RT_ALARM_UPDATE_INTERVAL}" in BuiltIn().get_variables():
            update_interval = BuiltIn().get_variable_value("${RT_ALARM_UPDATE_INTERVAL}")
            if isinstance(update_interval, int) or update_interval.isdigit():
                interval = int(update_interval)
            else:
                error(f"User has given invalid value for RT_ALARM_UPDATE_INTERVAL. It should be integer or numeric"
                      f" string, not {update_interval}. Using default value 250 (NOTE ms in question).")
        try:
            if (starting_thread and not RealtimeAlarms.admin_connection_ok) or not starting_thread:
                if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
                    ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")
                    self.logger.debug(f"Trying to connect to M-Plane IP {ip} for realtime alarm listener.")
                release = self.bts.get_sw_release_via_targetbd(lmp_ip=ip)
                self.admin.connect_to(bts_host=ip, update_interval=interval,
                                      admin_api_log_dir=self.logger.create_admin_folder(), name='rt_alarms',
                                      release=release)
                RealtimeAlarms.admin_connection_ok = True
            else:
                self.logger.debug(f"Admin connection to {ip} for Realtime alarm search already ok.")
        except (AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                AdminApiNoResponseException, AdminApiTerminatedException, AliasLookupError, AliasInUse) as e:
            self.logger.debug(f"Unable to start real time alarm search to {ip}. {e.__class__.__name__}{e}")
            self.logger.debug(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        if self.rfs:
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            try:
                if (starting_thread and not RealtimeAlarms.admin_connection_remote_ok) or not starting_thread:
                    release = self.bts.get_sw_release_via_targetbd(lmp_ip=remote_mplane_ip)
                    self.admin.connect_to(bts_host=remote_mplane_ip, update_interval=interval,
                                          admin_api_log_dir=self.logger.create_admin_folder(), name='rt_alarms_other',
                                          release=release)
                    RealtimeAlarms.admin_connection_remote_ok = True
                else:
                    self.logger.debug(f"Admin connection to {remote_mplane_ip} for Realtime alarm search already ok.")
                self.logger.debug(f"Admin connection to remote BTS {remote_mplane_ip} for Realtime alarm search "
                                  f"established.")
            except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                    AdminApiProcedureTimeoutException,
                    AdminApiNoResponseException, AdminApiTerminatedException, AliasLookupError, AliasInUse) as ex:
                self.logger.debug(
                    f"Unable to start real time alarm search to {remote_mplane_ip}. {ex.__class__.__name__}{ex}")
                self.logger.debug(f"{''.join(format_exception(type(ex), ex, ex.__traceback__))}")

    def check_if_admin_started_in_thread_and_kill_it(self, name_of_connection, stop=False):
        """
        Check if admin started in thread and kill it checks if admin process is already started with the given name. If
        it is started then kills the process.

        :param str name_of_connection: Can be for example rt_alarms, log_admin, default etc.
        :param bool stop: Default is False. If True is called when stopping thread.
        """
        collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        # collect_logs.give_command_to_terminal(f"ps auxf|grep admin_api", print_to_eventlog=False, return_output=False)
        output = collect_logs.give_command_to_terminal(f"ps auxf|grep admin_api_{name_of_connection}",
                                                       print_to_eventlog=False, return_output=True)
        admin_process = re.findall(f"admin_api_{name_of_connection}.log", output)
        if admin_process:
            if stop:
                self.logger.debug(f"There is admin thread with alias {name_of_connection}. Kill it.")
            else:
                info(f"There is hanging admin thread with alias {name_of_connection}. Kill it before staring new "
                     f"thread.")
            pid_admin = re.findall(r"ute\s+\d+\s+", output)
            self.logger.debug(f"Pid_admin parsed from output: {pid_admin}")
            if pid_admin:
                for ute_pids in pid_admin:
                    ute_pid = self._safe_split(ute_pids, "ute")[1].strip()
                    collect_logs.give_command_to_terminal(f"sudo kill {ute_pid}", print_to_eventlog=False,
                                                          return_output=False)
            BuiltIn().sleep("1s")
            output = collect_logs.give_command_to_terminal(f"ps auxf|grep admin_api_{name_of_connection}",
                                                           print_to_eventlog=False, return_output=True)
            admin_process = re.findall(f"admin_api_{name_of_connection}.log", output)
            if admin_process:
                error(f"Unable to kill all admin connection threads with alias {name_of_connection}")

    def start_thread(self, name='RealtimeAlarms-Thread', connection='rt_alarms'):
        """
        Start thread method starts the realtime alarm listener thread.

        :param str name: Name of the thread.
        :param str connection: Connection name to be used when starting the thread.
        """
        if connection == 'rt_alarms' and not self._running:
            self._running = True
            if self._thread is None or not self._thread.is_alive():
                info("Starting realtime alarm listener.")
                self.logger.debug(f"Connection to be started is {connection}.")
                self._thread = Thread(target=self.loop_alarm_checks, name=name, args=(connection,), daemon=True)
                self._thread.daemon = True
                self._thread.start()
        if connection == 'rt_alarms_other' and not self._running_remote:
            self._running_remote = True
            if self._thread_remote is None or not self._thread_remote.is_alive():
                info("Starting realtime alarm listener for remote BTS.")
                self.logger.debug(f"Connection to be started is {connection}.")
                self._thread_remote = Thread(target=self.loop_alarm_checks, name=name, args=(connection,), daemon=True)
                self._thread_remote.daemon = True
                self._thread_remote.start()

    def start_rt_alarm_listener(self):
        """
        Start rt alarm listener starts the realtime alarm listener. This is called in method
        run_keyword_in_loop_and_return_pass_rate of pass_rate.py. If it cannot start the thread tries in every 15s in
        total of 15 times, if not successful error is printed to log.
        """
        self.check_if_admin_started_in_thread_and_kill_it('rt_alarms')
        if self.rfs:
            self.check_if_admin_started_in_thread_and_kill_it('rt_alarms_other')
        RealtimeAlarms._detected_alarms = defaultdict(list)
        RealtimeAlarms.checks_alarms_in_realtime = True
        try_to_start_thread = 1
        while (RealtimeAlarms.checks_alarms_in_realtime and try_to_start_thread < 16
               and not RealtimeAlarms.admin_connection_ok):
            try:
                self.connect_admin(starting_thread=True)
                if self.rfs:
                    if RealtimeAlarms.admin_connection_ok and RealtimeAlarms.admin_connection_remote_ok:
                        info("Admin connections to lmp ip and remote BTS ip is successfully created for realtime "
                             "alarms.")
                        break
                else:
                    if RealtimeAlarms.admin_connection_ok:
                        info("Admin connection to lmp ip of BTS is successfully created for realtime alarms.")
                        break
            except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                    AdminApiProcedureTimeoutException, ValueError, TypeError, AttributeError) as e:
                self.logger.debug(f"Unable to connect to admin for realtime alarm listener ({try_to_start_thread}.try)."
                                  f" {e.__class__.__name__}:{e} was raised"
                                  f"\n{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.logger.debug(f"Problems to connect to admin for realtime alarm listener ({try_to_start_thread}.try)."
                              f"Wait 15s and try again.")
            try_to_start_thread += 1
            self.wait_given_time(15)
        if try_to_start_thread >= 15:
            error("Unable to start realtime alarm listener. Cannot create connection to admin and because of this we "
                  "cannot monitor alarms to eventlog. Please check the admin connection.")
        else:
            self.start_thread()
            if self.rfs:
                self.start_thread(name='RealtimeAlarms-Thread-Other', connection="rt_alarms_other")

    @staticmethod
    def _get_and_sort_impacted_cells_list(impacted_cells_list):
        """
        Get and sort impacted cells method. In MultiRat and RFS environments alarm may be raised for both LTE and
        NR cells. Check if impactedCellsList field is list of dicts or list of cells. This method sorts the list.

        :param list impacted_cells_list: Impacted cells list. May be for example [
        {'LTE': [{'cellId': 'LNCEL-1', 'cellName': None, 'impact': 'Faulty'},
                 {'cellId': 'LNCEL-2', 'cellName': None, 'impact': 'Faulty'}]},
        {'NR': [{'cellId': 'NRCELL-1', 'cellName': 'KA3A0026A11', 'impact': 'Faulty'}]}
        ]
        or [
        '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-32249/LNCEL_R-2',
        '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-32249/LNCEL_R-1'
        ]
        or [{"LTE": "All Failed"}]
        or [{"null": "All Unknown"}]
        or [{"LTE": "All Degraded"}]
        or []
        """
        sorted_impactedcelllist = []
        try:
            multirat_or_rfs = False
            if impacted_cells_list:
                for cell_type in impacted_cells_list:
                    if isinstance(cell_type, dict):  # MultiRat and RFS may have both LTE and NR cells in alarm
                        multirat_or_rfs = True
                        for key, value in cell_type.items():
                            if "All Failed" in value or "All Unknown" in value or "All Degraded" in value:
                                sorted_impactedcelllist.append({key: value})
                            else:
                                cell_type[key] = sorted(value, key=lambda x: x['cellId'])
                                if cell_type not in sorted_impactedcelllist:
                                    sorted_impactedcelllist.append(cell_type)
                if not multirat_or_rfs:
                    sorted_impactedcelllist = sorted(impacted_cells_list)
        except (TypeError, AttributeError, ValueError, IndexError, KeyError) as e:
            error(f"ERROR {e.__class__.__name__}:{e} while sorting impacted cells list. Will not fail the test, take "
                  f"contact to script developers.\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        return sorted_impactedcelllist

    def _check_if_alarm_fields_are_in_alarm(self, active_alarm):
        required_fields = ['btsObservationTime', 'number', 'faultId', 'faultName', 'hwPath', 'severity',
                           'configObjectName', 'impactedCellsList', 'impactedCell', 'degradedCells']
        all_ok = True
        for field in required_fields:
            if field not in active_alarm:
                error(f"Active alarm is missing required field: {field}.")
                all_ok = False
        if not all_ok:
            info(f"Alarm data from admin:\n{active_alarm}")

    def parse_active_alarm(self, active_alarm):
        """
        Parse information of active alarm that is get from get_active_alarms method of taf.sbts.oam.coam.admin library.

        :param dict active_alarm: Active alarm object of admin
        :return tuple: Returns alarm information as tuple.
        """
        self._check_if_alarm_fields_are_in_alarm(active_alarm)
        observation_time = active_alarm['btsObservationTime']
        detection_time = "{}-{}-{} {}:{}:{}{}".format(
            observation_time[:4], observation_time[4:6], observation_time[6:8], observation_time[8:10],
            observation_time[10:12], observation_time[12:14], observation_time[14:17])
        faulty_cells = []
        impacted_cells = None
        if 'impactedCellsLcrIdList' in active_alarm:
            faulty_cells = active_alarm['impactedCellsLcrIdList']
        if 'impactedCells' in active_alarm:
            impacted_cells = active_alarm['impactedCells'].replace("\n", "").replace("\t", "").replace("\r", "")
        impacted_cell_list = RealtimeAlarms._get_and_sort_impacted_cells_list(active_alarm['impactedCellsList'])
        suppl_info = active_alarm.get('supplAlarmInfo')
        if not suppl_info:
            if 'alarmText' in active_alarm and 'alarmAdditionalInfo' in active_alarm['alarmText']:
                suppl_info = active_alarm['alarmText']['alarmAdditionalInfo'].get('supplAlarmInfo')
        return (active_alarm['number'], active_alarm['faultId'], active_alarm['faultName'],
                active_alarm['hwPath'], active_alarm['severity'], suppl_info,
                active_alarm['configObjectName'], str(impacted_cell_list),
                active_alarm['impactedCell'], active_alarm['degradedCells'], str(sorted(faulty_cells)),
                impacted_cells, detection_time)

    def wait_given_time(self, time_to_wait):
        """
        Waits given time.

        :param int time_to_wait: Time to wait.
        """
        wait_ok = True
        for i in range(0, int(time_to_wait)):
            if RealtimeAlarms.checks_alarms_in_realtime:
                BuiltIn().sleep("1s")
            else:
                self.logger.debug("RealtimeAlarm listener stop requested during wait time -> stop waiting")
                wait_ok = False
                break
        return wait_ok

    @staticmethod
    def _parse_halt_alarm(input_string):
        pattern = r'(\w+)=([^,]+)'
        matches = re.findall(pattern, input_string)
        parsed_dict = {key: value.strip() for key, value in matches}
        return parsed_dict

    @staticmethod
    def _check_alarm_halt_conditions(user_alarm_dict, alarm_tuple):
        # Mapping dictionary keys to corresponding tuple indices
        key_to_index = {
            'alarm_id': 0,
            'fault_id': 1,
            'fault_name': 2,
            'hw_path': 3
        }
        for key, value in user_alarm_dict.items():
            if key in key_to_index:
                if value != alarm_tuple[key_to_index[key]]:
                    return False
        return True

    def _halt_rt_alarms(self, alarm_tuple):
        """
        Usage of HALT_TEST_ALARM -tag:
        @{HALT_TEST_ALARM}      fault_id=10, fault_name=No connection to unit, hw_path=RMOD-3, alarm_id=7116

        There can be one or more fields used but upper example has all the current fields that can be used.

        """
        if (BuiltIn().get_variable_value("${HALT_TEST_ALARM}", default=None) or
                BuiltIn().get_variable_value("@{HALT_TEST_ALARM}", default=None)):
            user_given_alarm_list = BuiltIn().get_variable_value("${HALT_TEST_ALARM}")
            if not isinstance(user_given_alarm_list, list):
                user_given_alarm_list = [user_given_alarm_list]
            for user_alarm in user_given_alarm_list:
                alarm_dict = self._parse_halt_alarm(user_alarm)
                if self._check_alarm_halt_conditions(alarm_dict, alarm_tuple):
                    error(f"HALT_TEST_ALARM alarm detected")
                    HaltTest().halt_test()

    def _fill_alarms(self, active_alarm, parsed_active_alarms, other_bts=False):
        a_id, f_id, f_name, hw_path, sev, reason, unit_path, i_c_l, i_c, d_c, faulty_c, c_cli, d_time = \
            self.parse_active_alarm(active_alarm)
        alarm_tuple = Alarm(str(a_id), str(f_id), f_name, hw_path, sev, reason, unit_path,
                            i_c_l, i_c, d_c, faulty_c, c_cli)
        if RealtimeAlarms._detected_alarms.get(other_bts):
            if alarm_tuple not in RealtimeAlarms._detected_alarms[other_bts]:
                alarm(f"ACTIVE: {sev} - {a_id} - {f_name} ({f_id}) - {unit_path} - {reason} - {hw_path} - "
                      f"{i_c_l} - {i_c} - degradedCells:{d_c} - {faulty_c} - {c_cli}")
                RealtimeAlarms._detected_alarms[other_bts].append(alarm_tuple)
                if alarm_tuple not in RealtimeAlarms.active_alarms_during_test:
                    RealtimeAlarms.active_alarms_during_test[other_bts].append(alarm_tuple)
        else:  # if there is no detected alarms yet
            alarm(f"ACTIVE: {sev} - {a_id} - {f_name} ({f_id}) - {unit_path} - {reason} - {hw_path} - {i_c_l} - "
                  f"{i_c} - degradedCells:{d_c} - {faulty_c} - {c_cli}")
            RealtimeAlarms._detected_alarms[other_bts].append(alarm_tuple)
            if alarm_tuple not in RealtimeAlarms.active_alarms_during_test:
                RealtimeAlarms.active_alarms_during_test[other_bts].append(alarm_tuple)
        parsed_active_alarms.append(alarm_tuple)
        self._halt_rt_alarms(alarm_tuple)
        return parsed_active_alarms

    @staticmethod
    def _clear_alarms(parsed_active_alarms, other_bts=False):
        if len(RealtimeAlarms._detected_alarms[other_bts]) > len(parsed_active_alarms):
            for history_alarm in list(RealtimeAlarms._detected_alarms[other_bts]):
                if history_alarm not in parsed_active_alarms:
                    alarm(
                        f"CLEARED: {history_alarm.severity} - {history_alarm.alarm_id} - "
                        f"{history_alarm.fault_name} ({history_alarm.fault_id}) - {history_alarm.unit_path} - "
                        f"{history_alarm.reason} - {history_alarm.hw_path} - {history_alarm.impacted_cells_list} - "
                        f"{history_alarm.impacted_cell} - degradedCells:{history_alarm.degraded_cells} - "
                        f"{history_alarm.faulty_cells} - {history_alarm.cells_cli_info}")
                    RealtimeAlarms._detected_alarms[other_bts].remove(history_alarm)

    def loop_alarm_checks(self, connection='rt_alarms'):
        """
        Loops active alarm checks and if changes are noticed print those to eventlog.
        """
        active_alarms = []
        while (connection == 'rt_alarms' and self._running and RealtimeAlarms.checks_alarms_in_realtime) or (
                connection == 'rt_alarms_other' and self._running_remote and RealtimeAlarms.checks_alarms_in_realtime):
            try:
                active_alarms = self.admin.get_active_alarms(severity=None, timeout=10, connection=connection)
            except AdminApiConnectionClosedException:
                self.logger.debug("Connection to admin is closed, AdminApiConnectionClosedException was raised.")
                if not RealtimeAlarms.checks_alarms_in_realtime or (
                        connection == 'rt_alarms' and not self._running) or (
                        connection == 'rt_alarms_other' and not self._running_remote):
                    self.logger.debug("RealtimeAlarm listener stop request noticed -> break out of while loop.")
                    break
                self.logger.debug("Wait 120s and try to create new admin connection for realtime alarm listener")
                if not self.wait_given_time(120):
                    break
                try:
                    if not RealtimeAlarms.checks_alarms_in_realtime or (
                            connection == 'rt_alarms' and not self._running) or (
                            connection == 'rt_alarms_other' and not self._running_remote):
                        self.logger.debug("RealtimeAlarm listener stop request noticed -> break out of while loop.")
                        break
                    self.connect_admin()
                    if not self.wait_given_time(5):
                        break
                    active_alarms = self.admin.get_active_alarms(severity=None, timeout=10, connection=connection)
                except AdminApiConnectionClosedException:
                    self.logger.debug("Connection to admin is closed, AdminApiConnectionClosedException was raised.")
            except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                    AliasLookupError, AdminApiTerminatedException, AliasInUse) as e:
                if "http sessionId invalid" in str(e):
                    self.logger.debug(f"{e.__class__.__name__}:{e} was raised. Because there was: "
                                      f"'http sessionId invalid.' error. Try to reset admin connection and try again.\n"
                                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
                    self.admin.reset_admin(connection=connection)
                else:
                    self.logger.debug(f"Unable to give get_active_alarms command to admin {connection} for realtime "
                                      f"alarm listener. {e.__class__.__name__}:{e} was raised. Wait 60s and try "
                                      f"again.\n{''.join(format_exception(type(e), e, e.__traceback__))}")
                if not self.wait_given_time(60):  # if request to stop is send during wait time, break out of while
                    break
                try:
                    active_alarms = self.admin.get_active_alarms(severity=None, timeout=10, connection=connection)
                except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                        AdminApiNoResponseException, AdminApiTerminatedException, AliasLookupError, AliasInUse) as e:
                    self.logger.debug(f"Unable to give get_active_alarms command to admin for realtime alarm listener"
                                      f"{e.__class__.__name__}:{e} was raised.\n"
                                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            parsed_active_alarms = []
            other_bts = True if connection == 'rt_alarms_other' else False
            if active_alarms:
                for active_alarm in active_alarms:
                    parsed_active_alarms = self._fill_alarms(active_alarm, parsed_active_alarms, other_bts)
            if RealtimeAlarms._detected_alarms and RealtimeAlarms._detected_alarms[other_bts] and parsed_active_alarms:
                self._clear_alarms(parsed_active_alarms, other_bts)
            if self._alarm_interval:
                BuiltIn().sleep(f"{self._alarm_interval}ms")
            pass

    def stop_rt_alarm_listener(self):
        """
        Stops the realtime alarm listener. This is called in run_keyword_in_loop_and_return_pass_rate method
        of pass_rate.py
        """
        info("Stopping realtime alarm listener.")
        RealtimeAlarms.checks_alarms_in_realtime = False
        if self._running:
            self._running = False
            if self._thread is not None:
                self._thread.join()
                self._thread = None  # Remove reference to thread
        if self._running_remote:
            self._running_remote = False
            if self._thread_remote is not None:
                self._thread_remote.join()
                self._thread_remote = None  # Remove reference to thread
        try:
            BuiltIn().sleep("2s")
            self.teardown_realtime_alarms_admin()
            RealtimeAlarms._detected_alarms = defaultdict(list)
            RealtimeAlarms.active_alarms_during_test = defaultdict(list)
            BuiltIn().sleep("1s")
            self.check_if_admin_started_in_thread_and_kill_it("rt_alarms", stop=True)
            if self.rfs:
                self.teardown_realtime_alarms_admin(connection="rt_alarms_other")
                BuiltIn().sleep("1s")
                self.check_if_admin_started_in_thread_and_kill_it("rt_alarms_other", stop=True)
            RealtimeAlarms.admin_connection_ok = False
            RealtimeAlarms.admin_connection_remote_ok = False
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, AliasInUse) as e:
            self.logger.debug(f"While stopping rt alarm listener, ERROR {e.__class__.__name__}:{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    def teardown_realtime_alarms_admin(self, connection="rt_alarms"):
        """ Teardown realtime alarm admin connections"""
        try:
            self.logger.debug("Teardown RealtimeAlarms admin connection")
            self.admin.teardown_admin(connection=connection)
            BuiltIn().sleep("1s")
        except (AttributeError, TypeError, ValueError, IndexError, AliasLookupError, AliasInUse) as e:
            self.logger.debug(f"While tearing down rt_alarms admin connection, ERROR {e.__class__.__name__}:{e}\n"
                              f"{''.join(format_exception(type(e), e, e.__traceback__))}")

    @staticmethod
    def reset_active_alarms_during_test():
        """Clears active_alarms_during_test list"""
        RealtimeAlarms.active_alarms_during_test = defaultdict(list)

    @staticmethod
    def _safe_split(value, sep):
        """Safely split values that may be None; returns list from splitting str(value)."""
        if value is None:
            return [""]
        return str(value).split(sep)
