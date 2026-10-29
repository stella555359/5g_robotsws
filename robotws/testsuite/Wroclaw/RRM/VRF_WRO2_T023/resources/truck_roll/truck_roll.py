import psutil
import os
import signal
import datetime
from multiprocessing import Process, Value
from multiprocessing.managers import BaseManager
import importlib
import time
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from threading import Thread
import taf.sbts.oam.coam.admin

run = Value('i', 1)


class SyslogOrSnapshotCollectionException(Exception):
    pass


class SnapshotIssueException(Exception):
    pass


class SyslogIssueException(Exception):
    pass


def import_pause():
    try:
        from robot.libraries.Dialogs import pause_execution as robot_pause
    except (ImportError, ModuleNotFoundError):
        robot_pause = importlib.import_module('robot.libraries.Dialogs').pause_execution
    return robot_pause


def get_single_alarms_info(alias_object_tuple):
    alarm_list = []
    alias, obj = alias_object_tuple
    try:
        result = obj.get_active_alarms()
        for alarm in result:
            alarm_list.append(alarm['faultId'])
    finally:
        return alarm_list


def get_snapshot(admin_object_instance, alias_object_tuple):
    results_path = BuiltIn().get_variable_value("${LOG_PATH}")
    if results_path is None:
        results_path = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    if results_path[-1] != '/':
        results_path = results_path + '/'
    now = datetime.datetime.now()
    formatted_date = now.strftime("%Y_%m_%d__%H_%M_%S")
    snapshot_name = results_path + 'Snapshot_' + str(alias_object_tuple[0]) + '_' + formatted_date + '.zip'
    ret = False
    try:
        logger.console('\ncollecting snapshot\n')
        admin_object_instance.collect_snapshot(snapshot_name, connection=alias_object_tuple[0])
        ret = True
    finally:
        return ret, snapshot_name


def get_syslog(syslog_object_instance):
    results_paths = []
    ret = False
    try:
        syslog_aliases = syslog_object_instance.store.aliases
        if len(syslog_aliases) == 0:
            return False
        for alias in syslog_aliases:
            ctrl_instance = syslog_object_instance.store.get(alias=alias)['ctrl'].log_path
            results_paths.append(ctrl_instance)
            syslog_object_instance.collect_syslog_results(alias=alias)
        ret = True
    finally:
        return ret, results_paths


def is_robot_process_exist(return_pid=False):
    process_name = "robot"
    pid = []
    for proc in psutil.process_iter():
        if process_name in proc.name():
            pid.append(proc.pid)
    if len(pid) == 0:
        return False, None
    elif return_pid:
        return True, pid
    else:
        return True


def show_error_dialog(alarms):
    pause = import_pause()
    now = datetime.datetime.now()
    cmd = "TruckRoll detected at: " + str(now) + "\nAlarms:" + str(*alarms)
    pause(cmd)


def error_handler(alarms, admin_object_instance, alias_object_tuple, syslog_object_instance):
    error_dialog_thread = Process(target=show_error_dialog, args=alarms)
    error_dialog_thread.daemon = True
    error_dialog_thread.start()
    path_to_snapshot = None
    path_to_syslog = None
    try:
        syslog_status, path_to_syslog = get_syslog(syslog_object_instance)
        snapshot_status, path_to_snapshot = get_snapshot(admin_object_instance, alias_object_tuple)
        if not syslog_status:
            raise SyslogIssueException("Snapshot fetch failed")
        if not snapshot_status:
            raise SnapshotIssueException("Snapshot fetch failed")
    except SyslogOrSnapshotCollectionException:
        raise SyslogOrSnapshotCollectionException("Cant collect full logs.")
    finally:
        error_dialog_thread.join(timeout=5)
        return path_to_snapshot, path_to_syslog


def start_truck_and_roll(objects):
    admin_object_instance, syslog_object_instance = objects
    pid_exist = is_robot_process_exist()
    not_allowed_alarms = [61524]
    not_allowed_alarms = [613]
    alias_object_tuples = list(admin_object_instance.lookup_handler.store.all)
    while pid_exist:
        if run.value:
            for alias_object_tuple in alias_object_tuples:
                actual_alarm_list = get_single_alarms_info(alias_object_tuple)
                logger.console(actual_alarm_list)
                alarms = set(not_allowed_alarms) & set(actual_alarm_list)
                logger.console(alarms)
                if len(alarms) > 0:
                    try:
                        path_to_snapshot, path_to_syslog = error_handler(alarms,
                                                                         admin_object_instance,
                                                                         alias_object_tuple,
                                                                         syslog_object_instance)
                        run.value = 0
                        logger.console('\n'+path_to_snapshot+'\n')
                        logger.console('\n'+str(path_to_syslog)+'\n')
                    finally:
                        admin_object_instance.teardown_all_aliases_for_admin()
                        pid_exist, pids = is_robot_process_exist(return_pid=True)
                        for pid in pids:
                            os.kill(pid, signal.SIGKILL)
                        break
        pid_exist = is_robot_process_exist()
        logger.console('\nloop\n')


# Funkcja do użycia w setupie w robocie
def init_stop_fix(*objects):
    thread1 = Thread(target=start_truck_and_roll, args=(objects,))
    thread1.daemon = True
    thread1.start()


# Funkcja pauzująca
def pause_stop_fix():
    run.value = 0


def continue_stop_fix():
    run.value = 1


# Funkcja do użycia w teardownie
def stop_stop_fix(thread1):
    thread1.join()
