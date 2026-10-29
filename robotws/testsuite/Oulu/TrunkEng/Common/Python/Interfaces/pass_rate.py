"""
:author:  Pekka Lonnakko
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import datetime
import os
import time
from traceback import format_exception

from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.ul.marvin import marvin

import testsuite.Oulu.TrunkEng.Common.Python.Resources.AddTestExecutionErrorsToFile as TestExecutionErrorsToFile
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, info, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import ScriptIssue
from testsuite.Oulu.TrunkEng.Common.Python.Resources.UnexpectedTestRunning import (
    check_robot_processes,
    get_all_processes,
)
from testsuite.Oulu.TrunkEng.Common.Reporting.HtmlReport import HtmlReport
from testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.E2EBtsStartupCheckpoint import (
    E2EBtsStartupCheckpoint,
)
from testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.ImAnalyserUsage import (
    ImAnalyserUsage,
)

bts = BuiltIn().get_library_instance("BTS")
log_collector = BuiltIn().get_library_instance("COLLECTLOGS")
logger = BuiltIn().get_library_instance("LOG")
rt_alarms = BuiltIn().get_library_instance("RT_ALARMS")
admin = BuiltIn().get_library_instance("ADMIN")
ssh_connection = BuiltIn().get_library_instance("SSH")


im_analyser_cases = ["site reset", "reset bbmod", "omkpi sw activation inter release",
                     "omkpi sw activation intra release", "power reset", "reset rat", "remote power reset",
                     "reset radio"]
e2e_startup_checkpoint_cases = ["Site reset"]


def run_keyword_in_loop_and_return_pass_rate(*args, name="", test_case="", loops="", keywords="", expected_pass_rate="",
                                             collect_test_logs="On failure", omkpi_case=False):
    """
    Loop keywords and calculate pass rate.

    :param args: (Optional) Arguments for the test
    :param str name: Test case name.
    :param str test_case: Test case number.
    :param int loops: Test loop.
    :param str keywords: Keywords within one keyword.
    :param float expected_pass_rate: Expected pass rate between 0-1.
    :param str collect_test_logs: (Optional) Set to On failure as default if not given. Collect logs only when test
    fails if it is set to On failure. Other possible values are Always and Never.
    :param bool omkpi_case: True if OMKPI case
    :return error message: In case ExecutionFailed -error, returns test success and error text.
    """
    run_im_analyser = None
    logs_has_been_removed = False
    try:
        loops = int(loops)
    except ValueError as e:
        error(f"Given loop was not an integer: {loops}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
        raise ScriptIssue
    if omkpi_case:
        run_im_analyser = _check_if_im_analyser_should_be_run(name)
    results = []
    time_loop_success = True
    remove_test_folder = True
    log_collection_success = True
    pass_log_already_collected = False
    BuiltIn().set_suite_variable("${COLLECT_LOGS_FROM_PASS_LOOP}", "${False}")
    start_time = f'{datetime.datetime.now():%Y-%m-%d %H:%M:%S%z}'
    test_start = datetime.datetime.now()
    test_name = get_builtin_value("TEST NAME")
    BuiltIn().set_suite_variable("${TEST_NAME}", test_name)
    BuiltIn().set_suite_variable("${OMKPI_CASE}", omkpi_case)
    use_marvin = not BuiltIn().get_variable_value("${NO_MARVIN}", default=False) \
        and "pre" not in test_case.lower() \
        and "post" not in test_case.lower()
    if use_marvin:
        try:
            m = marvin()
            adapter_list = (
                ["-cpu-mem", "-radio-cpu-mem"]
                if BuiltIn().get_variable_value("${DISABLE_CPU_MEM}", default=False)
                else None
            )
            m.prepare_and_start_marvin(only_test_run=True,
                                       ref_run_id=BuiltIn().get_variable_value("${MARVIN_REF_RUN_ID}",
                                                                               default=None),
                                       print_marvin_link=True, create_test_cases=True,
                                       organization="TV_Trunk_Oul1")
            for loop in range(loops):
                area = "OMKPI" if omkpi_case else "FMReco"
                marvin_test_case = f"{test_name.replace(' ', '_')}_{area}_{loop + 1}"
                m.create_test_case(marvin_test_case)
        except Exception as e:
            error(
                f"Error when preparing marvin: {e.__class__.__name__}: "
                f"{e}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
    title_name = test_name
    sw_version = bts.active_sw
    html = HtmlReport()
    html.modify_template_start(test_name, start_time, title_name, sw_version)
    if BuiltIn().get_variable_value("${WAIT_BEFORE_TEST}"):
        bts.wait_time_and_reason(BuiltIn().get_variable_value("${WAIT_BEFORE_TEST}"),
                                 f"before starting test {test_name}.")
    info(f"Testing of test case {test_name} started.")
    got_kpi_values = []
    loop_success_wo_kpi = []
    if BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}"):
        bts.deactivate_netboot_secondary_smod()
    for loop in range(loops):
        get_all_processes(os.path.join(logger.suite_folder, "all_processes.txt"), f"Loop {loop + 1}:")
        check_robot_processes()
        keep_im_analyser_log = False
        BuiltIn().set_suite_variable("${KW_SUCCESS}", "${True}")  # if false in previous loop updates it to true
        log_collector.clear_swdl_variables()
        if "${CALCULATE_KPI}" in BuiltIn().get_variables():
            BuiltIn().set_suite_variable("${CALCULATE_KPI}", "${True}")  # if false in previous loop updates it to true
        loop_success = False  # initialize as False as default if exception happens then test is not set as pass
        last_line = log_collector.get_last_line_of_eventlog()
        try:
            info("Last eventlog line before test next loop was {}".format(last_line))
            log_collector.start_log_collection(test_case=test_case, loop=loop)
            print_top_information_to_file(loop, start=True)
            bts.print_start_text(name, loop_no=loop, loops=loops)
            rt_alarms.start_rt_alarm_listener()
            if use_marvin:
                try:
                    area = "OMKPI" if omkpi_case else "FMReco"
                    marvin_test_case = f"{test_name.replace(' ', '_')}_{area}_{loop + 1}"
                    m.start_test_case(test_case_name=marvin_test_case,
                                      ref=BuiltIn().get_variable_value("${MARVIN_REF_CASE_ID}", default=None),
                                      adapter_list=adapter_list)
                except Exception as e:
                    error(
                        f"Error when starting marvin test case: {e.__class__.__name__}: "
                        f"{e}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
            loop_success = BuiltIn().run_keyword_and_return_status(keywords, *args)
            if loop_success and not BuiltIn().get_variable_value("${KW_SUCCESS}"):
                print("Loop_success is True, but because KW_SUCCESS is False -> loop_success should be False.")
                loop_success = False
            if omkpi_case:
                loop_success, loop_success_wo_kpi = _check_loop_kpi_success(loop_success, loop_success_wo_kpi)
        except Exception as e:
            error("Error in {}. loop of {}: {}:{}\n{}".format(
                loop + 1, get_builtin_value("TEST NAME"), e.__class__.__name__, e,
                ''.join(format_exception(type(e), e, e.__traceback__))))
            if omkpi_case:
                continue
        finally:
            results.append(loop_success)
            if ("${LOGS_ALREADY_COLLECTED}" in BuiltIn().get_variables() and
                    BuiltIn().get_variable_value("${LOGS_ALREADY_COLLECTED}")):
                info("Skip pass_rate log collection.")
                collect_logs = False
            elif collect_test_logs == "On failure":
                collect_logs = True if (not loop_success or not time_loop_success) else False
            elif collect_test_logs in ("Always", "Never"):
                collect_logs = True if collect_test_logs == "Always" else False
            else:
                error("Invalid user input, collect_test_logs parameter can have values \"On failure\", "
                      "\"Always\" or \"Never\". Value {} is not accepted.".format(collect_test_logs))
                raise ScriptIssue
            if omkpi_case and loop_success and not pass_log_already_collected and loop > 0:
                info("Collecting logs from passed test loop")
                collect_logs = True
                pass_log_already_collected = True
                BuiltIn().set_suite_variable("${COLLECT_LOGS_FROM_PASS_LOOP}", "${True}")
            zip_logs = True if BuiltIn().get_variable_value("${ZIP_LOGS}") else False
            if log_collector.folders_for_zip_and_remove:
                print("Skip always all_logs.zip creation because there are SWDL logs and this will be made later.")
                html_report, log_collection_success_temp = log_collector.stop_log_collection(
                    last_line, collect_logs=collect_logs, zip_logs=False)
            else:
                html_report, log_collection_success_temp = log_collector.stop_log_collection(
                    last_line, collect_logs=collect_logs, zip_logs=zip_logs)
            log_collection_success = log_collection_success_temp and log_collection_success
            if BuiltIn().get_variable_value("${E2E_CHECKPOINTS}"):
                if keywords in e2e_startup_checkpoint_cases:
                    e2e_startup_points = E2EBtsStartupCheckpoint()
                    e2e_startup_points.get_pssw_service_breakdown_kpi_check_points()
            logger.debug("Found html report dict: {}".format(html_report))
            rt_alarms.stop_rt_alarm_listener()
            time.sleep(3)  # added wait time here so rt alarms thread has enough time to stop the admin process
            bts.print_end_text(loop, loop_success)
            log_collector.move_disconnection_logs_to_admin_folder()
            if omkpi_case:
                if name.lower() in im_analyser_cases and run_im_analyser:
                    snapshot_path = log_collector.check_if_file_is_in_logs(
                        filename_to_search="snapshot",
                        path_for_search=logger.log_dir, return_file_path=True)
                    if not snapshot_path:
                        snapshot_coverage = "FullWithoutRFLogs"
                        if bts.smod_is_fsmf():
                            snapshot_coverage = "Full"
                        log_collector.collect_snapshot(
                            extra_name="im_analyser",
                            connection_name="default",
                            coverage=snapshot_coverage,
                            reg_exp_filter="._startup.zip$|.ims.$|^.AaConfigRadMasterHistory.$",
                            no_rfs=True)
                        ImAnalyserUsage().check_and_run_im_analyser("im_analyser.zip")
                    else:
                        ImAnalyserUsage().check_and_run_im_analyser(full_path_to_snapshot=snapshot_path)
                    keep_im_analyser_log = True
                if _check_if_swdl_test(name):
                    keep_im_analyser_log = True
            log_collector.zip_and_delete_folders("admin")
            print_top_information_to_file(loop, start=False)
            if use_marvin:
                try:
                    m.stop_test_case(verdict=loop_success, test_case_name=marvin_test_case)
                except Exception as e:
                    error(
                        f"Error when stopping marvin test case: {e.__class__.__name__}: "
                        f"{e}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
            if "${CALCULATE_KPI}" in BuiltIn().get_variables() and not BuiltIn().get_variable_value("${CALCULATE_KPI}"):
                got_kpi_values.append(False)
            else:
                got_kpi_values.append(True)
            log_collector.move_redundant_logs_for_tester_to_new_folder()
# other than SWDL test case
            if not log_collector.folders_for_zip_and_remove:
                if not collect_logs:
                    if ("${LOGS_ALREADY_COLLECTED}" in BuiltIn().get_variables() and
                            BuiltIn().get_variable_value("${LOGS_ALREADY_COLLECTED}")) and (
                            (collect_test_logs == "On failure" and (not loop_success or not time_loop_success)) or
                            (collect_test_logs == "Always")):
                        info("Do not delete the loop log folder.")
                    else:
                        info(f"Delete test loop log folder and all it's content {logger.log_dir}")
                        logs_has_been_removed = _remove_log_dir(keep_im_analyser_log)
                else:
                    print("Test loop failed (or logs are set to be collected Always) -> Set remove_test_folder to "
                          "False")
                    remove_test_folder = False
# swdl test case
            if log_collector.folders_for_zip_and_remove:
                print("SWDL test in question.")
                remove_test_folder = False
                keep_im_analyser_log = True
                # if not collect_logs:  # pass_rate log collection is not made, check if folders should be zip or
                # removed depending on loop_success and time_loop_success
                if ((collect_test_logs == "On failure" and (not loop_success or not time_loop_success)) or
                        (collect_test_logs == "Always") or collect_logs):
                    print(f"SWDL folders for zip (and remove): {log_collector.folders_for_zip_and_remove}")
                    log_collector.zip_and_delete_folders("ping_logs")
                    log_collector.zip_and_delete_folders("ssh_logs")
                    if zip_logs:
                        info("ZIP_LOGS is set to True. Zip logs.")
                        log_collector.zip_all_logs(swdl_zip=True)
                        for folder_to_zip in log_collector.folders_for_zip_and_remove:
                            name_for_zip = str(folder_to_zip[folder_to_zip.rfind("/") + 1:])
                            log_collector.zip_and_remove_log_folder(folder_to_zip, name_for_zip)
                    else:
                        info("ZIP_LOGS is set to False. Logs are not zip (excluding ping_logs and ssh_logs).")
                else:
                    info(f"Remove SWDL test loop logs: {logger.log_dir}.")
                    logs_has_been_removed = _remove_log_dir(keep_im_analyser_log)
            # info("Check and disconnect all created SSH connections after every loop.")
            ssh_connection.close_all_ssh_connections()
            if BuiltIn().get_variable_value("${FAIL_FAST}") and not loop_success:
                info(r"Test loop {}/{} failed and because FAIL_FAST is set to True testing will stop.".format(
                    loop + 1, loops))
                break  # out from the for -loop
    pass_rate = calculate_pass_rate(number_passed=results.count(True), count_of_all=len(results)) if results else 0
    success_rate = assert_that_pass_rate_is_more_than(expected_pass_rate, pass_rate)
    info(f"Testing of test case {test_name} done.")
    if use_marvin:
        try:
            marvin_verdict = BuiltIn().get_variable_value("${MARVIN_VERDICT}", default=False)
            info(f"Marvin verdict from variable: {marvin_verdict}")
            marvin_final_verdict = m.stop_marvin(fetch_snapshot=True, only_test_run=True, verdict=all(results),
                                                 link_to_rp=True)
            if marvin_verdict and marvin_final_verdict is None:
                warning("Marvin verdict was not set properly during timeout time. This is not failing the test.")
            elif marvin_verdict and not marvin_final_verdict:
                success_rate = False
                error("Marvin verdict was Fail. Check Marvin report for more details.")
        except Exception as e:
            error(
                f"Error when stopping marvin: {e.__class__.__name__}: "
                f"{e}\n{''.join(format_exception(type(e), e, e.__traceback__))}")
    if not success_rate:
        status = "Fail"
    else:
        status = "Pass"
    html.modify_template_loop(loops=loops, loop_success=loop_success, test_name=test_name,
                              time_loop_success=time_loop_success, results=results)
    html.calculate_case_numbers(test_statuses=results)
    # check if there is test logs and if snapshot is missing from the logs
    if omkpi_case:
        info(f"Test case success = {status.lower()}")
#        bts.check_if_netboot_is_deactive_and_activate_it()
        _report_omkpi_success_rate(loop_success_wo_kpi, loops)
        # if there is one fail in loops -> test case folder will not be removed
        try:
            check_if_kpi_file_should_be_created(got_kpi_values)
        except Exception as e:
            error(f"Exception when check_if_kpi_file_should_be_created {e.__class__.__name__}:{e}")
            info(f"Fail the test '{test_name}' because of '{e}'.")
            # BuiltIn().fail(f"{e}")
        modify_html_template(html, test_start, test_name, sw_version, status)
        if logger.errors_and_warnings:
            if any("OCXO init temperature" in msg for msg in logger.errors_and_warnings):
                logger.errors_and_warnings.append(f"OCXO issue found in loop {logger.loop + 1}")
            path_to_f = TestExecutionErrorsToFile.add_test_execution_errors_to_file(
                logger.errors_and_warnings, logger.suite_folder)
            info(f"HTML file 'test_execution_errors.html' has been created to {path_to_f}.")
        if not logs_has_been_removed:
            if log_collector.folders_for_zip_and_remove:
                print("SWDL test in question, do not check if snapshot exists here.")
            else:
                print("Check if snapshot is found from the logs, if not then try to collect one")
                if not log_collector.check_if_file_is_in_logs("snapshot"):
                    log_collector.collect_special_snapshot(extra_name="after_test")
        if not BuiltIn().get_variable_value("${TIME_KW_SUCCESS}"):
            raise Exception("KPI fail (in 'Reset Time')")

    else:  # RECO/ADL/PM
        if remove_test_folder:
            log_collector.delete_test_log_folder()
        else:
            if log_collector.folders_for_zip_and_remove:
                print("SWDL test in question, do not check if snapshot exists here.")
            else:
                print("Check if snapshot is found from the logs, if not then try to collect one")
                if not log_collector.check_if_file_is_in_logs("snapshot"):
                    log_collector.collect_special_snapshot(extra_name="after_test")
        if logger.errors_and_warnings:
            path_to_f = TestExecutionErrorsToFile.add_test_execution_errors_to_file(
                logger.errors_and_warnings, logger.suite_folder)
            info(f"HTML file 'test_execution_errors.html' has been created to {path_to_f}.")
    if not success_rate:
        raise Exception(f"Expected pass rate {expected_pass_rate} not reached with {pass_rate}.")
    if not log_collection_success:
        raise Exception("Problems in log collection. Check warnings.")


def _check_if_im_analyser_should_be_run(name):
    """
    Check if IM Analyser should be run. IM Analyser should be run if the test case is in im_analyser_cases list or user
    has set RUN_IM_ANALYSER variable to True. IM Analyser should not be run if the test case is not in im_analyser_cases
     list or user has set RUN_IM_ANALYSER variable to False.

    :param str name: Test case name.
    :return: True if IM Analyser should be run, False otherwise.
    """
    run_im_analyser = BuiltIn().get_variable_value("${RUN_IM_ANALYSER}", default=None)
    if run_im_analyser is None or (isinstance(run_im_analyser, str) and not run_im_analyser):
        if name.lower() in im_analyser_cases:
            BuiltIn().set_suite_variable("${RUN_IM_ANALYSER}", "${True}")
            print(f"IM Analyser will be run, name ({name.lower()}) was found from im_analyser_cases ("
                  f"{im_analyser_cases}). Set suite variable RUN_IM_ANALYSER to True.")
            run_im_analyser = True
        else:
            print("IM Analyser will not be run, name was not found from im_analyser_cases and user has not set "
                  "RUN_IM_ANALYSER variable to True.")
            run_im_analyser = False
    elif isinstance(run_im_analyser, str):
        if run_im_analyser and run_im_analyser.lower() == "true":
            BuiltIn().set_suite_variable("${RUN_IM_ANALYSER}", "${True}")
            print("IM Analyser will be run, user has set variable ${RUN_IM_ANALYSER} to True.")
            run_im_analyser = True
        elif run_im_analyser and run_im_analyser.lower() == "false":
            print("IM Analyser will not be run, user has set variable ${RUN_IM_ANALYSER} to False")
            BuiltIn().set_suite_variable("${RUN_IM_ANALYSER}", "${False}")
            run_im_analyser = False
        else:
            error(f"Invalid value for RUN_IM_ANALYSER. Possible values are True, true, False or false. "
                  f"The user given value was: {run_im_analyser}")
    elif isinstance(run_im_analyser, bool):
        if run_im_analyser:
            print("IM Analyser will be run, user has set variable ${RUN_IM_ANALYSER} to True.")
        else:
            print("IM Analyser will NOT be run, user has set variable ${RUN_IM_ANALYSER} to False.")
    if name.lower() in ("omkpi sw activation inter release", "omkpi sw activation intra release") and run_im_analyser:
        print("Remove SWDL im_analyser cases from the list so the check im analyser will not be run after test"
              " loop, but in the SWDL tests.")
        im_analyser_cases.remove("omkpi sw activation inter release")
        im_analyser_cases.remove("omkpi sw activation intra release")
    if _check_if_swdl_test(name):
        print("Set return of method _check_if_im_analyser_should_be_run to False so the check im analyser will not "
              "be run after test loop, but in the SWDL tests.")
        run_im_analyser = False
    return run_im_analyser


def _check_if_swdl_test(name):
    """
    Check if swdl test.

    :param str name: Test case name.
    """
    swdl_tests = ["omkpi sw activation inter release", "omkpi sw activation intra release",
                  "omkpi independent du sw upgrade intra", "omkpi rf sw update", "omkpi ru sw update",
                  "sw activation from fdsw", "omkpi sw activation special"]
    for swdl_case in swdl_tests:
        if swdl_case in name.lower():
            print("IM analyser will not be run after test loop, but after every SWDL test.")
            return True
    return False


def _remove_log_dir(keep_im_analyser_log=False):
    """
    Remove log_dir folder.
    """
    files_to_keep = []
    if keep_im_analyser_log:
        files_to_keep.append("-containers")
        files_to_keep.append("-report")
    if BuiltIn().get_variable_value("${COLLECT_ONLY_IMS}"):
        files_to_keep.append(".ims2")
    if BuiltIn().get_variable_value("${COLLECT_ONLY_SNAPSHOT}"):
        files_to_keep.append("snapshot")
    if BuiltIn().get_variable_value("${COLLECT_ONLY_SYSLOG}"):
        files_to_keep.append("syslog")
    files_to_keep.append("E2E_BTS_Startup_Checkpoint")
    files_to_keep.append("E2EBtsStartupCheckpointSnapshotfiles")
    info(f"Remove all files from {logger.log_dir} except chosen {files_to_keep}.")
    log_collector.remove_folder(logger.log_dir, files_to_keep)
    return True


def _check_loop_kpi_success(loop_success, loop_success_wo_kpi):
    """
    Check if loop success is True and KPI calculation is successful.
    :param bool loop_success: Loop success.
    :param list loop_success_wo_kpi: List of loop success without KPI.
    :return: Tuple of loop_success and loop_kpi_success.
    """
    if loop_success and not BuiltIn().get_variable_value("${LOOP_KPI_SUCCESS}"):
        print("Loop_success is True, but because LOOP_KPI_SUCCESS is False -> loop_success should be False.")
        error("Loop success was True, but KPI calculation failed.")
        loop_success = False
        loop_success_wo_kpi.append(True)
    elif loop_success and BuiltIn().get_variable_value("${LOOP_KPI_SUCCESS}"):
        loop_success_wo_kpi.append(True)
    else:
        loop_success_wo_kpi.append(False)
    return loop_success, loop_success_wo_kpi


def _report_omkpi_success_rate(loop_success_wo_kpi, loops):
    """
    Report OMKPI success rate.
    :param list loop_success_wo_kpi: List of loop success without KPI.
    :param int loops: Number of loops.
    :return:
    """
    omkpi = BuiltIn().get_library_instance("report_oam_kpi")
    passed_iterations = loop_success_wo_kpi.count(True)
    kpi_name = BuiltIn().get_variable_value("${LOOP_KPI}")
    if not kpi_name:
        error("KPI name was not found for the test case. Cannot report OMKPI success rate.")
        return
    info(f"Reporting OMKPI success rate for {kpi_name}. Passed iterations: {passed_iterations}, loops: {loops}")
    omkpi.report_oam_kpi_success_rate(kpi_name, passed_iterations, loops)


def check_if_kpi_file_should_be_created(got_kpi_values):
    print("Got KPI values: {}\nSKIP_KPI_CALCULATIONS: {}".format(
        got_kpi_values, BuiltIn().get_variable_value("${SKIP_KPI_CALCULATIONS}")))
    if True in got_kpi_values and not BuiltIn().get_variable_value("${SKIP_KPI_CALCULATIONS}"):
        # Create KPI file:
        try:
            BuiltIn().run_keyword_and_continue_on_failure(
                "Reset Time", get_builtin_value("REPORT"), get_builtin_value("OAM_KPI_TARGETS"),
                get_builtin_value("AVG_OAM_KPI_TARGETS"), get_builtin_value("REFERENCE_TESTLINE"))
        except Exception as e:
            error(f"Exception when calling kw 'reset time' {e.__class__.__name__}:{e}")
            print(f"{''.join(format_exception(type(e), e, e.__traceback__))}")
    else:
        info("KPI calculations and reports are skipped.")


def calculate_pass_rate(number_passed, count_of_all):
    """
    Loop keywords and calculate pass rate.

    :param int number_passed: Number of passed tests in one looper round.
    :param int count_of_all: Number of tests run in one looper round.
    :return pass_rate: Pass rate as float.
    """
    return float(number_passed) / float(count_of_all)


def assert_that_pass_rate_is_more_than(expected, actual):
    """
    Loop keywords and calculate pass rate.

    :param float expected: Expected pass rate.
    :param float actual: Actual pass rate.
    """
    if float(expected) > float(actual):
        error("Expected pass rate {} not reached with {}.".format(expected, actual))
        return False
    else:
        info("Pass rate was: {}".format(actual))
        return True


def print_top_information_to_file(loop, start=True):
    if start:
        handle = os.popen("echo '************  Before test loop {l}  ************' > {lg}/process_and_mem_prints.txt "
                          "| top -b -n 1 >> {lg}/process_and_mem_prints.txt | cat /proc/meminfo "
                          ">> {lg}/process_and_mem_prints.txt | sudo df -h >> {lg}/process_and_mem_prints.txt"
                          .format(l=loop+1, lg=logger.log_dir))
        handle.close()
    else:
        handle = os.popen("echo '************  After test loop {l}  ************' >> {lg}/process_and_mem_prints.txt "
                          "| top -b -n 1 >> {lg}/process_and_mem_prints.txt | cat /proc/meminfo >> "
                          "{lg}/process_and_mem_prints.txt | sudo df -h >> {lg}/process_and_mem_prints.txt"
                          .format(l=loop+1, lg=logger.log_dir))
        handle.close()


def modify_html_template(html, test_start, test_name, sw_version, status):
    """
    Modify the HTML template in OMKPI cases. Additionally, set suite variable ${ROBOT_TEMPLATE}

    :param class html: Class from HtmlReport.py -file.
    :param timedelta test_start: Time at the start of the test.
    :param string test_name: Name of the test.
    :param string sw_version: Software version.
    :param string status: Whether the test case is a Pass or a Fail.
    """
    current_time = f'{datetime.datetime.now():%Y-%m-%d %H:%M:%S%z}'
    test_end = datetime.datetime.now()
    time_difference = (test_end - test_start)
    elapsed_time = str(time_difference)
    html.modify_template_end(test_name, sw_version, current_time, elapsed_time, status)
    BuiltIn().set_suite_variable("${ROBOT_TEMPLATE}", html.modified_template)
