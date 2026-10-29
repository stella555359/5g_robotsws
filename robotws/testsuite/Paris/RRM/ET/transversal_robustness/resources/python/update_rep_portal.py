import glob
import os
import sys


def update_rep_portal(robot_name, topology, username, build_url):
    campaign = robot_name.split('/')[-1].split('.robot')[0]
    crt_output_dirs = glob.glob(f"/home/ute/CrtRoot/logs/*/{campaign}")
    crt_output_dir = crt_output_dirs[-1]
    crt_test_log = open(f"{crt_output_dir}/crt_ute_run_test.log", "r")
    rep_user = username.replace(" ", "_")
    test_line = None
    enb_build = None
    line = crt_test_log.readline()
    while line and (test_line is None or enb_build is None):
        if "CMD:Test Line Reference" in line:
            test_line = line.split("=")[-1].strip()
        if "VAR:ENB_BUILD" in line:
            enb_build = line.split("=")[-1].strip()
        line = crt_test_log.readline()
    crt_test_log.close()
    if test_line is not None and enb_build is not None:
        os_command = f"/home/ute/test_repo/bin/ute_reporting_portal send -ie  -ro {crt_output_dir}/output.xml " + \
                     f"-tl {test_line} --info {topology} -v --file_path /home/ute/CrtRoot/robotws/{robot_name} " + \
                     f"--sw_version {enb_build} --username {rep_user} -l {topology} --log_link {build_url}"
        print(f"Launching {os_command}")
        os.system(f"{os_command}/robot/report/log.html")
        os.system(f"{os_command}")
    else:
        print("Missing info", test_line, enb_build)


if __name__ == '__main__':
    update_rep_portal(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
