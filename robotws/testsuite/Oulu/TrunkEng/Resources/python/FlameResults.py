import os
import re
import shutil
from testsuite.Oulu.TrunkEng.Resources.python.ReportCounters import ReportCounters

results = {
    0: "OK, result was pass.",
    1: "OK, result was fail.",
    2: "User interrupted with Ctrl-C.",
    3: "Not enough free space in disk.",
    16: "Script loading failed.",
    17: "Script used in settings not found.",
    18: "Environment validation failed for script.",
    19: "Settings validation failed for script.",
    20: "No given root ID to run.",
    21: "Test run setup failed.",
    32: "Script execution failed on script error.",
    160: "Environment settings loading failed.",
    224: "Command line argument missing/invalid.",
    240: "License file missing.",
    241: "License file invalid.",
    255: "Unspecified error."
}


def return_results(result, output_dir):
    print("Stdout: {}".format(result.stdout))
    print("Stderr: {}".format(result.stderr))
    print("-"*80)
    print(results[result.rc] if result.rc in results else "Unknown error code: {}".format(result.rc))
    test_actual_result = check_result(output_dir)
    print("Actual test result: {}".format(test_actual_result))
    report_pm_counters(output_dir)
    if result.rc != 0 and not test_actual_result:
        raise Exception(results[result.rc] if result.rc in results else "Unknown error code: {}".format(result.rc))


def check_result(output_dir):
    output = os.popen('tail -n 60 {}'.format(os.path.join(output_dir, "stdout.txt"))).read()
    save_crash_log(output, output_dir)
    save_admin_debug_log(output_dir)
    return True if "Result: PASS" in output else False


def save_crash_log(output, output_dir):
    match = re.search(r"Log:\s+(.*/crash_.*\.trl)", output)
    if match:
        crash_log = match.group(1)
        path_to_file = os.path.join(output_dir, crash_log.split("/")[-1])
        shutil.copyfile(crash_log, path_to_file)
        print("Crash log saved to: {}".format(path_to_file))


def save_admin_debug_log(output_dir):
    path_to_debug = r"{home}/.flame5/admin_cli/node/linux/bin/node/debug.txt".format(home=os.path.expanduser("~"))
    if os.path.isfile(path_to_debug):
        output_debug = os.path.join(output_dir, "admin_debug.txt")
        shutil.copyfile(path_to_debug, output_debug)
        print("Admin debug saved to: {}".format(output_debug))


def grep_counters(output_dir, filename):
    file_path = os.path.join(output_dir, filename)
    command = """grep "{{'value'.*'id'.*'result'.*}}" {filepath}""".format(filepath=file_path)
    output = os.popen(command).read()
    return output


def report_pm_counters(output_dir):
    output = grep_counters(output_dir, "stdout.txt")
    if output:
        counter_reporter = ReportCounters(log=output)
        counter_reporter.report_counters()
