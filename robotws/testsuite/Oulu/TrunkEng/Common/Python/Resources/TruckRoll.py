import subprocess
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.CheckAlarms import CheckAlarms
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.PowerBreakers import PowerBreakers


class TruckRoll:

    def __init__(self):
        self.log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        self.rt_alarms = BuiltIn().get_library_instance("RT_ALARMS")
        self.truck_roll = BuiltIn().get_variable_value("${TRUCK_ROLL}", "${False}")
        self.alarms = CheckAlarms()

    def truck_roll_procedure(self):
        if self.truck_roll:
            try:
                info("TruckRoll case is found: collecting snapshot and syslog, sending notification and halting the "
                     "test!")
                self.log_collector.collect_snapshot()
                for smod in self.bts.smods:
                    if self.bts_status.asix_is_faulty(smod) and smod.master:
                        self.log_collector.collect_special_snapshot(smod)
                if not self.log_collector.syslog_log_folder:
                    self.log_collector.get_debian_version_and_set_log_folder()
                syslog_files = self.log_collector.get_all_files_from_directory(self.log_collector.syslog_log_folder)
                self.log_collector.add_files_to_zip("syslogs_truck_roll.zip", syslog_files)
            except Exception as e:
                error(f"TruckRoll log collections failed, proceed to halt the test: {e.__class__.__name__}:{e}\n"
                      f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            self.send_notification()
            BuiltIn().sleep("200h", "Test halted for 200h")
        else:
            info("TruckRoll case is found but TruckRoll is disabled, continuing the test.")

    @staticmethod
    def send_notification():
        command = 'echo "put /opt/ute/execution.context.json ${CM_EXECUTION_ID}.json" | ' \
                  'cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
        subprocess.call(command, shell=True)

    def convert_alarms(self, alarms):
        converted_alarms = []
        for fault_id, fault_names in alarms.items():
            for fault_name in fault_names:
                converted_alarms.append(self.alarms.create_alarm(fault_id=fault_id, fault_name=fault_name))
        return converted_alarms

    def check_10_alarm(self, active_alarms_lists, ten_alarm):
        for active_alarms in active_alarms_lists:
            for active_alarm in active_alarms:
                if self.alarms.compare_alarms(active_alarm, ten_alarm):
                    return True
        return False

    def check_truck_roll_alarms(self, unallowed_alarms, expected_alarms):
        if self.truck_roll:
            sf_alarms_dict = {
                '0010': ["No connection to unit", "Failure in optical interface"],
                '10': ["No connection to unit", "Failure in optical interface"],
                '1806': ["Communication failure"],
                '4341': ["FSP subunit lost Link"],
                '4352': ["No connection between primary and BTS extension system module"],
                '4383': ["Virtual node not responding", "Internal service not responding"],
            }
            sf_alarms = self.convert_alarms(sf_alarms_dict)
            pb_checked = False
            for unallowed_alarm in unallowed_alarms:
                for sf_alarm in sf_alarms:
                    if self.alarms.compare_alarms(unallowed_alarm, sf_alarm):
                        info("TruckRoll case is found: {name} ({id})".format(
                            name=sf_alarm.fault_name, id=sf_alarm.fault_id))
                        if "10" in sf_alarm.fault_id:
                            if not pb_checked:  # Check PB port statuses only once if more than one 10 -alarm is found
                                info("10 -alarm is found, wait 10 min before checking PB port statuses.")
                                BuiltIn().sleep("10min", "10 -alarm is found, wait 10 min before checking PB port "
                                                "statuses.")
                                PowerBreakers().print_power_breaker_port_statuses()
                                pb_checked = True
                            if self.check_10_alarm(self.rt_alarms.detected_alarms.values(), sf_alarm):
                                self.truck_roll_procedure()
                            else:
                                info("10 -alarm was cleared during wait time. Not a TruckRoll case")
                                continue
                        if self.unallowed_alarm_expected_alarm_with_wrong_alarm_id(unallowed_alarm, expected_alarms):
                            info("Expected alarm is with wrong alarm_id. Not a TruckRoll case.")
                            continue
                        self.truck_roll_procedure()

    def unallowed_alarm_expected_alarm_with_wrong_alarm_id(self, unallowed_alarm, expected_alarms):
        if expected_alarms:
            for expected_alarm in expected_alarms:
                if (unallowed_alarm.fault_name == expected_alarm.fault_name and
                        unallowed_alarm.fault_id == expected_alarm.fault_id and
                        unallowed_alarm.alarm_id != expected_alarm.alarm_id):
                    self.logger.debug(f"Expected alarm_id for {expected_alarm.fault_id} is {expected_alarm.alarm_id}, "
                                      f"in unallowed alarm {unallowed_alarm.fault_id} has {unallowed_alarm.alarm_id}.")
                    return True
        return False

    def ip_truck_roll(self, ip):
        if not self.bts.ping_ip_until_disconnection_or_reconnection(
                ip_to_ping=ip, time_to_wait=30, boolean_return=True):
            info("TruckRoll case is found: {} is not pinging".format(ip))
            PowerBreakers().print_power_breaker_port_statuses()
            self.truck_roll_procedure()

    def check_other_truck_rolls(self):
        if self.truck_roll:
            self.ip_truck_roll("192.168.255.129")
            mplane_ip = self.bts.get_parameter_value_from_bts_info("btsMplaneIp4V")
            if not mplane_ip:
                mplane_ip = self.bts.get_mplane_ip_from_tl_param()
            self.ip_truck_roll(mplane_ip)
