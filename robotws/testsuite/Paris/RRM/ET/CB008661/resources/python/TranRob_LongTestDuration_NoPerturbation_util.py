import os
import pmc_background_monitoring_task as pmcBkgMonTask
import sce_background_task as sceBkgTask
from timer_services import PmcIdTimerService
from btslogfile_analyse import CircularFileParser

# global variables
# ----------------
btslog_analysys_instance = None


def create_btslog_analysis_instance(root_tmp_dir, sub_res_dir_prefix, inc_filter_file, exc_filter_file, loop_inter):
    global btslog_analysys_instance
    btslog_analysys_instance = CircularFileParser(root_tmp_dir,
                                                  sub_res_dir_prefix,
                                                  inc_filter_file,
                                                  exc_filter_file,
                                                  loop_inter)


def Start_Btslog_Monitoring_python():
    global btslog_analysys_instance
    btslog_analysys_instance.start()
    print("btslog_analysys_instance is started")


def Stop_Btslog_Monitoring_python():
    global btslog_analysys_instance
    btslog_analysys_instance.stop()
    print("btslog_analysys_instance is stopped")


# --------------------------------------------------------------------------------------------------
# PmcIdTimerService instance creation
pmc_id_timer_instance = PmcIdTimerService(5)


def start_pmcIdTimerService_python(granularity):
    pmc_id_timer_instance.start(granularity)
    print(f"pmc_id_timer_service is started with granularity = {granularity}")


def stop_pmcIdTimerService_python():
    pmc_id_timer_instance.stop()
    print("pmc_id_timer_service is stopped")


def wait_for_pm_period_index_python(target_value):
    pmc_id_timer_instance.wait_for_pm_period_index_target_value(target_value)


# --------------------------------------------------------------------------------------------------
def start_pmc_background_monitoring_python(local_pmc_path, full_constraints_file_path,
                                           branch_name, do_readConfig=False):
    pmc_thread, stop_event = pmcBkgMonTask.start_pmc_background_monitoring_sub_task(full_constraints_file_path,
                                                                                    local_pmc_path, branch_name,
                                                                                    do_readConfig)
    return pmc_thread, stop_event


def stop_pmc_background_monitoring_python(stop_event, pmc_thread):
    pmcBkgMonTask.stop_pmc_background_monitoring_sub_task(stop_event, pmc_thread)
    print(f"Stopping pmc thread. Thread is alive: {pmc_thread.is_alive()}")


# -----------------------------------------------------------------------------------------------------
def start_sce_background_python(path_scenario, output_dir):
    sce_thread, stop_event, thread_log_file = sceBkgTask.start_sce_background_sub_task(path_scenario, output_dir)
    return sce_thread, stop_event, thread_log_file


def stop_sce_background_python(stop_event, sce_thread, thread_log_file):
    sceBkgTask.stop_sce_background_sub_task(stop_event, sce_thread, thread_log_file)
    print(f"Stopping sce thread. Thread is alive: {sce_thread.is_alive()}")
