import alarms_handler as alms_hdlr
from ta5g_pm_counters import ta5g_pm_counters
import os
import re
import paramiko
import shutil
import sys
import gzip
import threading
import logging
from datetime import datetime
from evaluate_counter_and_kpi_constraints import evaluate_counter_and_kpi_constraints
from create_pretty_counter_file import create_pretty_counter_file
from create_pretty_kpi_file import create_pretty_kpi_file
import json


class CounterManager:
    def __init__(self):
        self.pm_counters = ta5g_pm_counters()

    def wait_for_next_pm_interval_and_get_counters(self):
        self.pm_counters.wait_for_next_full_pm_interval_classical()


def sftp_get_latest_pm_file(host, port, username, password, remote_directory, local_directory):
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(host, port, username, password)
        sftp = ssh.open_sftp()
        files = sftp.listdir(remote_directory)
        pm_bts_files = [f for f in files if re.match(r'PM\.BTS-\d+\.\d{8}\.\d{6}\.ANY\.xml\.gz', f)]
        if not pm_bts_files:
            print("ERR - No pmc file found!!!")
            return
        latest_file = max(pm_bts_files, key=lambda f: sftp.stat(remote_directory + '/' + f).st_mtime)
        local_filepath = os.path.join(local_directory, latest_file)
        remote_filepath = os.path.join(remote_directory, latest_file)
        sftp.get(remote_filepath, local_filepath)
        sftp.close()
        ssh.close()
        print(f"File {remote_filepath} successfully downloaded to {local_filepath}")
        return local_filepath
    except Exception as e:
        print(f"ERR - exception : {e}")


def uncompress_gz(file_path):
    local_filepath_xml = os.path.splitext(file_path)[0]
    with gzip.open(file_path, 'rb') as f_in:
        with open(local_filepath_xml, 'wb') as f_out:
            f_out.write(f_in.read())
    return local_filepath_xml


def start_pmc_background_monitoring_main_loop(full_constraints_file_path, local_directory, branch_name, stop_event,
                                              do_read_config=False):
    remote_host = "192.168.255.129"
    port = 22
    username = "toor4nsn"
    password = "oZPS0POrRieRtu"
    remote_dir = "/ram"
    pmc_log_dir = local_directory

    # Create pmc_local_log_directory folder
    os.makedirs(pmc_log_dir)
    print(f"{pmc_log_dir} is created")

    dir_path = os.path.dirname(os.path.realpath(__file__))
    script_path = os.path.join(dir_path, "evaluate_counter_and_kpi_constraints.py")
    sweng_def_file_path = os.path.join(dir_path, f"../../../../../resources/SWENG/config/KPI")
    fullConstFilePath = full_constraints_file_path
    kpiDefFile = os.path.join(sweng_def_file_path, f"{branch_name}/KPI_Definitions.csv")
    ctrDefFile = os.path.join(sweng_def_file_path, f"{branch_name}/Counter_Definitions.csv")
    technology = "5G_I_BO"

    counter_manager = CounterManager()
    while not stop_event.is_set():

        # ---------------------------------------------------------------------------------------------------------
        # Performance Monitoring Counter part
        # ---------------------------------------------------------------------------------------------------------
        counter_manager.wait_for_next_pm_interval_and_get_counters()
        local_filepath_gz = sftp_get_latest_pm_file(remote_host, port, username, password, remote_dir, pmc_log_dir)
        local_filepath_xml = uncompress_gz(local_filepath_gz)
        is_sub_sce_running = os.environ.get('IS_SUB_SCE_RUNNING', 'False')
        if is_sub_sce_running.lower() in ['true', '1', 't', 'y', 'yes']:
            print("Sub Sce is running skip analysis")
        else:
            print("Only back ground Sce is running launch analysis")
            result = evaluate_counter_and_kpi_constraints(local_filepath_xml, fullConstFilePath,
                                                          kpiDefFile, ctrDefFile, technology)
            # Log result to a new file
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            full_log_filename = os.path.join(pmc_log_dir, f"eval_pmc_constraints_{timestamp}.log")
            with open(full_log_filename, 'w') as log:
                log.write('raw pmc file is :' + '\n' + local_filepath_xml + '\n')
                print(f"raw pmc file is : {local_filepath_xml}")
                for constraint in result:
                    constraint_str = json.dumps(constraint)
                    log.write(constraint_str + '\n')
                    print(f"{constraint_str}")

        # ---------------------------------------------------------------------------------------------------------
        # Create pretty Counters and KPIs csv files part
        # ---------------------------------------------------------------------------------------------------------
        try:
            print(f"INF - Do create_pretty_counter_file and create_pretty_kpi_file")
            create_pretty_counter_file(local_filepath_xml, pmc_log_dir, ctrDefFile)
            create_pretty_kpi_file(local_filepath_xml, pmc_log_dir, ctrDefFile, kpiDefFile)
        except Exception as e:
            print(f" ERR - create_pretty_counter and/or kpi_file !!! - exception : \n{e}")

        # ---------------------------------------------------------------------------------------------------------
        # Not Allowed Alarm Monitoring part
        # ---------------------------------------------------------------------------------------------------------
        try:
            print(f"INF - Check if Not Allowed Alarms is or are detected")
            alms_hdlr.almw.check_detected_alarms()
        except Exception as e:
            full_log_filename = os.path.join(pmc_log_dir, f"eval_not_allowed_alarm_res_{timestamp}.log")
            with open(full_log_filename, 'w') as log:
                log.write(f"ERR - one or more Not Allowed Alarms is or are detected !!! - exception : \n{e}")
                print(f"ERR - one or more Not Allowed Alarms is or are detected !!! - exception : \n{e}")


def start_pmc_background_monitoring_sub_task(full_constraints_file_path, local_directory, branch_name=None,
                                             do_readConfig=False):
    stop_event = threading.Event()
    pmc_thread = threading.Thread(target=start_pmc_background_monitoring_main_loop,
                                  args=(full_constraints_file_path, local_directory,
                                        branch_name, stop_event, do_readConfig))
    pmc_thread.start()
    return pmc_thread, stop_event


def stop_pmc_background_monitoring_sub_task(stop_event, thread):
    stop_event.set()
    thread.join()
