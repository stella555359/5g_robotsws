import traceback
import os
import sys
from robot.libraries.Process import Process
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
import re

builtin_obj = BuiltIn()
time_stamp = builtin_obj.get_time().replace("-", "").replace(" ", "").replace(":", "")

# ##### personal setting ############
log_save_dir = "/home/ute/rotta/5G_2/zhangyin/{}".format(time_stamp)
console_log = "/home/ute/robot_console.log"
pass_cases = "/home/ute/cases_pass.log"
fail_cases = "/home/ute/cases_fail.log"
pass_load_logs = True

# each line in execute_case_cmd_list:
# robot -L trace -v SNAPSHOT_FLAG:pass:False,fail:False -v SOS_REPORT_FLAG:pass:False,fail:False
# -l log_001.html -o output_001.xml <robot_file>
execute_case_cmd_list = """
"""
# # report REP
# report_rep = False  # report REP if set True and case pass
# # tl_type = "CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD"
# tl_name_default = "2_16_UTE5GCLASSICAL1445"  # rep report for manual execute robot
# ##### setting done ################

os_obj = OperatingSystem()
os_obj.create_file(console_log)
os_obj.create_file(pass_cases)
os_obj.create_file(fail_cases)

if os.path.exists("/home/ute/rotta/5G_2") is False:
    print("pls execute ./mount_rotta.sh to mount rotta")
    print("and then execute this script again")
    sys.exit()
else:
    os_obj.create_directory(log_save_dir)
print("logs are deposited under %s" % log_save_dir)
print("you can execute tail -f %s to follow the progress" % console_log)

proc = Process()
for case_cmd in execute_case_cmd_list.strip().splitlines():
    try:
        match = re.search(r"-l\s+(\S+.html).*-o\s+(\S+.xml)", case_cmd, re.I)
        log_name = match.group(1)
        output_name = match.group(2)
        match2 = re.search(r"-d\s+(\S+)", case_cmd, re.I)
        if match2:
            output_dir = match2.group(1)
        else:
            output_dir = "./"

        result = proc.run_process("%s 2>&1 | tee -ai %s" % (case_cmd, console_log), timeout="120min", shell=True)
        result = "%s\n%s" % (result.stdout, result.stderr)
        if result.count("0 failed"):
            pass_flag = True
        else:
            pass_flag = False
        if pass_flag:
            print("rename %s to pass_%s" % (log_name, log_name))
            print("rename %s to pass_%s" % (output_name, output_name))
            os_obj.move_file("%s/%s" % (output_dir, log_name), "pass_%s" % log_name)
            os_obj.move_file("%s/%s" % (output_dir, output_name), "pass_%s" % output_name)
            proc.run_process("echo %s >> %s" % (case_cmd, pass_cases), shell=True)
            # if report_rep:
            #     tl_name = proc.run_process("hostname", shell=True)
            #     tl_name = tl_name.stdout.replace("-", "_")
            #     if tl_name.count("CLOUD") == 0:
            #         tl_name = tl_name_default
            #
            #     tl_type = proc.run_process("cat /opt/ute/reservation.json |awk -F, "
            #                                "'{print $9}'|awk -F: '{print $2}'| sed 's/\"//g'", shell=True)
            #     print("tl_type=%s" % tl_type)
            #     rep_result = proc.run_process("ute_reporting_portal send -ie -ro %s -tl %s -l '%s'"
            #                                   % ("pass_%s" % output_name, tl_name, tl_type),
            #                                   timeout="30s", shell=True)
            #     rep_result = "%s\n%s" % (rep_result.stdout, rep_result.stderr)
            #     print(rep_result)
            proc.run_process("cp pass_%s pass_%s %s" % (log_name, output_name, log_save_dir), timeout="60", shell=True)
        else:
            print("rename %s to fail_%s" % (log_name, log_name))
            print("rename %s to fail_%s" % (output_name, output_name))
            os_obj.move_file("%s/%s" % (output_dir, log_name), "fail_%s" % log_name)
            os_obj.move_file("%s/%s" % (output_dir, output_name), "fail_%s" % output_name)
            proc.run_process("echo %s >> %s" % (case_cmd, fail_cases), shell=True)
            proc.run_process("cp fail_%s fail_%s %s" % (log_name, output_name, log_save_dir), timeout="60", shell=True)

        if pass_flag is False or pass_flag is True and pass_load_logs is True:
            match = re.search(r"LOG_DIR=(\S+)", result, re.I)
            log_dir = match.group(1)
            new_name = log_name.split(".")[0].split("_")[-1] + "_" + log_dir.split("/")[-2]
            proc.run_process("cp -r %s %s/%s" % (log_dir, log_save_dir, new_name), timeout="10min", shell=True)
        proc.run_process("cp -f %s %s %s %s" % (console_log, pass_cases, fail_cases, log_save_dir), timeout="60",
                         shell=True)
    except Exception:
        detail = traceback.format_exc()
        print(detail)
