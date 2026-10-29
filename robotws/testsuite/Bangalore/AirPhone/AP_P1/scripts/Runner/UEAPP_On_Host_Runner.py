import io
import re
import sys
import time
import yaml
import os
import sys
import subprocess
import glob
import tarfile
import json
from shell import ShellExecutor

try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru
try:
    from pathlib import Path
except ImportError:
    os.system('pip install pathlib')
    from pathlib import Path

WORKSPACE_FOLDER = str(Path(__file__).resolve().parents[7])


class UEAPPonHostExecutor():
    def __init__(self, stream, workspace, suite, workspace_path,
                 yaml_file='default', test_variable=''):
        """
                Constructor for the UEAPPonHostExecutor class. Initializes various class variables.

                Parameters:
                stream (str): The stream to be used.
                workspace (str): The workspace path to store the Robot Logs.
                suite (str): The suite name.
                workspace_path (str): The workspace path.
                yaml_file (str): The file path of the yaml file if a new file has to be used. Default is 'default'.
                test_variable (str): Any parameter we want to override in the test case. Default is ''.
        """
        self.stream = stream
        self.user = os.environ.get("AP_USER", "app1")
        self.user_passwd = os.environ.get("APP1_PASSWD", "PA_P0qwe2024#77")
        self.artifactory_list = [
            "airphone-l3callhost-docker-local.artifactory-hz1.int.net.nokia.com",
            "airphone-l3callhost-docker-remote.artifactory-espoo1.int.net.nokia.com",
            "l1sw-docker-global.artifactory-hz1.int.net.nokia.com",
            "l1sw-docker-global.nginx-l1sw-hz1.devops-fwk.dyn.nesc.nokia.net",
            "l1sw-docker-global.artifactory-espoo2.int.net.nokia.com",
            "l1sw-docker-global.nginx-l1sw-es2.devops-fwk.dyn.nesc.nokia.net",
        ]
        self.workspace = workspace
        self.workspace_path = workspace_path
        self.suite = suite
        self.yaml_file = yaml_file
        self.test_variable = test_variable
        self.enb_build = os.environ['GNB_LOAD_ID']
        self.ap_build = os.environ['AP_LOAD_ID']
        self.setup_cmds = "export TERM=xterm"
        self.docker_login_cmd = "docker login -u {} -p {} {}"
        self.shell_execute = ShellExecutor()
        self.remote_root_dir = os.environ.get("REMOTE_ROOT_DIR", "/home/ute/")
        self.l3coh_dir = os.environ.get("L3COH_DIR", "/home/ute/L3CallHost/")
        self.robot_log = (
            f"{self.l3coh_dir}/end_to_end_test/collected_logs/testsuite/log.html"
        )
        self.testcase_log = f"{self.l3coh_dir}/end_to_end_test/collected_logs.zip"
        self.scf_mig_url = (
            "airphone-l3callhost-docker-local.artifactory-hz1.int.net.nokia.com/"
            "keepforever/dev/scfmigrator:auth"
        )
        self.art_link = (
            "https://artifactory-hz1.ext.net.nokia.com/artifactory/"
            "mnp5g-airphone-ci-gen-local/Airphone/"
        )
        self.l3coh_file = open(os.path.join(sys.path[0], 'UEAPPoH_test_cases.yaml'), "r")
        self.l3coh_test_cases = yaml.load(self.l3coh_file, Loader=yaml.FullLoader)
        self.ueapp_test_result = {}
        self.l3coh_build_download = (
            f"sudo -S wget {self.art_link}/{self.ap_build}/L3CallHost.zip --user={self.user} "
            f"--password={self.user_passwd}"
        )
        self.scf_mig_prep_cmd_list = [
            f"cd {self.l3coh_dir}",
            f"export pwd={self.l3coh_dir}",
            f"export SBTS_VERSION={self.enb_build}",
            (
                f"docker run -v {self.l3coh_dir}/tests/legacy/:/app/tests/legacy/ "
                f"-v ~/.netrc:/tmp/.netrc:ro "
                f"-e UID=$(id -u) "
                f"-e GID=$(id -g) "
                f"-e SBTS_VERSION={self.enb_build} {self.scf_mig_url}"
            ),
        ]
        self.scf_migration_cmd_list = [
            "sed -i 's/timerNSAGuardRA\">5000/timerNSAGuardRA\">10000/g' SCF.xml"
        ]

        self.test_run_cmd = [
            f"cd {self.l3coh_dir}/end_to_end_test",
            "sed -i 's/exit ${/#exit ${/g' run_end_to_end_test.sh",
            f"export SBTS_VERSION={self.enb_build}",
            f"cd {self.l3coh_dir}/end_to_end_test",
        ]
        self.install_ueapp_cmd = [
            f"cd {self.remote_root_dir}",
            "echo Welcome123 | sudo -S rm -rf L3CallHost*",
            f"export SBTS_VERSION={self.enb_build}",
            "echo Welcome123 | sudo -S chmod 777 /var/run/docker.sock",
            "yes | docker system prune --all",
            "yes | docker volume prune",
            f"echo Welcome123 | {self.l3coh_build_download}",
            "unzip L3CallHost.zip -d L3CallHost",
            f"chmod -R 777 {self.l3coh_dir}",
        ]
        self.crash_detection_cmds = [f"cd {self.l3coh_dir}/end_to_end_test/collected_logs/"]

    def setup_dockers(self):
        """
            Sets up the Docker environment by executing the setup commands and logging into the Docker repositories.
        """
        self.shell_execute.execute_cmd(self.setup_cmds)
        for art in self.artifactory_list:
            docker_login = self.docker_login_cmd.format(self.user, self.user_passwd, art)
            self.shell_execute.execute_cmd(docker_login)

    def crash_detection(self):
        """
            Detects if there is a crash in the system by checking for 'FATAL' in the log files.

            Returns:
            bool: True if a crash is detected, False otherwise.
        """

        crash_flag = False
        self.crash_detection_cmds.append(
            f"grep -q 'FATAL' {self.l3coh_dir}/end_to_end_test/"
            "collected_logs/*_ue_app-l1_01.log"
        )
        # ue_l1_crash = " && ".join(self.crash_detection_cmds)
        ue_l1_crash = (
            f"grep -q 'FATAL' {self.l3coh_dir}/end_to_end_test/"
            "collected_logs/*_ue_app-l1_01.log"
        )
        output, error, rc = self.shell_execute.execute_cmd(ue_l1_crash)
        if output != "":
            print("===========AP L1 Crash===========")
            print("AP L1 Crash details : ")
            loguru.logger.opt(raw=True).info(f"» {output.lstrip()}")
            crash_flag = True
        self.crash_detection_cmds.pop(-1)
        self.crash_detection_cmds.append(
            f"grep -q 'FATAL' {self.l3coh_dir}/end_to_end_test/"
            "collected_logs/*_gnb-l1sw.log"
        )
        # ue_l1_crash = " && ".join(self.crash_detection_cmds)
        ue_l1_crash = (
            f"grep -q 'FATAL' {self.l3coh_dir}/end_to_end_test/"
            "collected_logs/*_gnb-l1sw.log"
        )
        output, error, rc = self.shell_execute.execute_cmd(ue_l1_crash)
        if output != "":
            print("===========gNB L1 Crash===========")
            print("gNB L1 Crash details : ")
            loguru.logger.opt(raw=True).info(f"» {output.lstrip()}")
            crash_flag = True
        self.crash_detection_cmds.pop(-1)
        self.crash_detection_cmds.append(
            f"grep -q 'FATAL' {self.l3coh_dir}/end_to_end_test/"
            "collected_logs/*_gnbl2l3.log"
        )
        # ue_l1_crash = " && ".join(self.crash_detection_cmds)
        ue_l1_crash = (
            f"grep -q 'FATAL' {self.l3coh_dir}/end_to_end_test/"
            "collected_logs/*_gnbl2l3.log"
        )
        output, error, rc = self.shell_execute.execute_cmd(ue_l1_crash)
        if output != "":
            print("===========gNB L2L3 Crash===========")
            print("gNB L2L3 Crash details : ")
            print("====================================")
            loguru.logger.opt(raw=True).info(f"» {output.lstrip()}")
            crash_flag = True
        return crash_flag

    def run_uc_iter(self):
        """
            Iterates over the test set and updates the SCF for each test case.
        """
        for tests in self.l3coh_test_cases["UEAppOnHost"][self.suite]:
            self.scf_update(tests)

    def scf_update(self, testcase):
        """
                Updates the SCF for the given test case.

                Parameters:
                testcase (str): The test case for which the SCF is to be updated.
        """
        self.scf_migration_cmd_list.insert(
            0, f"cd {self.l3coh_dir}/tests/legacy/{testcase}"
        )
        scf_update_cmd = " && ".join(self.scf_migration_cmd_list)
        self.shell_execute.execute_cmd(scf_update_cmd)
        self.scf_migration_cmd_list.pop(0)

    def scf_migration(self):
        """
               Prepares for SCF migration for all the test sets that are going to be executed.
       """
        scf_mig_cmd = " && ".join(self.scf_mig_prep_cmd_list)
        self.shell_execute.execute_cmd(scf_mig_cmd)
        if "UC" in self.suite:
            self.run_uc_iter()
        else:
            self.scf_update(self.suite)

    def testcase_runner(self):
        """
        Iterates over the test cases in the regression sets and runs each test case.
        """
        for testcase in self.l3coh_test_cases["UEAppOnHost"][self.suite]:
            self.run_testcase(testcase)

    def run_testcase(self, run_testcases):
        """
        Runs the given test case and updates the test result.
        It checks for crash logs after the test execution
        Common variable is updated with test result along with crash detection result

        Parameters:
        run_testcases (str): The test case to be run.
        """
        test_result = {}
        self.test_run_cmd.append(
            "./run_end_to_end_test.sh --testcase={}".format(run_testcases)
        )
        self.test_run_cmd.append(f"cp {self.robot_log} {self.workspace}/{run_testcases}_log.html")
        self.test_run_cmd.append(
            f"cp {self.testcase_log} {self.workspace}/{run_testcases}_collected_logs.zip"
        )
        test_run_cmd = " && ".join(self.test_run_cmd)
        del self.test_run_cmd[4:7]
        try:
            output_robot, error_robot, rc_robot = self.shell_execute.execute_cmd(test_run_cmd)
        except Exception as e:
            print(f"Test case : {run_testcases} failed with exception {e}")
        try:
            crash_result = self.crash_detection()
            testcase_result_pattern = r'(.*?)END TO END TEST OK'
            testcase_status_pattern = r'(\d+ tests, \d+ passed, \d+ failed)'
            testcase_results = re.findall(testcase_result_pattern, output_robot)
            testcase_status_results = re.findall(
                testcase_status_pattern, output_robot
            )
            print(
                "status_result of testcase {} is {}".format(
                    run_testcases, testcase_status_results
                )
            )
        except Exception as e:
            print(e)
            crash_result = "NA"
            testcase_results = "NA"

        test_result["robot_result"] = (
            "PASS" if (testcase_results and testcase_results != "NA") else "FAIL"
        )
        test_result["crash_detected"] = crash_result
        test_result["Run_Type"] = "UEAPP_on_Host"
        test_result["Topology"] = os.environ.get("TOPOLOGY", "UEAPP_on_Host")
        if test_result["robot_result"] == "PASS" and not crash_result:
            test_result["Test_result"] = "PASS"
        else:
            test_result["Test_result"] = "FAIL"
        self.ueapp_test_result[run_testcases] = test_result

    def get_test_case_path(self):
        for suite_tests in self.l3coh_test_cases["UEAppOnHost"].keys():
            if self.suite in self.l3coh_test_cases["UEAppOnHost"][suite_tests]:
                return f"{suite_tests}/{self.suite}"
        raise Exception(f"Testsuite {self.suite} not found in the list")

    def install_ueapp(self):
        """
        Installs the UEAPP by executing the installation commands.
        """
        robotws_path = (
            "robotws/testsuite/Bangalore/AirPhone/AP_P1/AP_Regression/UEAAP_on_Host"
        )
        testcase = f"{self.suite}/*" if "UC" in self.suite else self.get_test_case_path()
        self.install_ueapp_cmd.append(
            f"cp -rf {WORKSPACE_FOLDER}/{robotws_path}/{testcase} "
            f"{self.l3coh_dir}/tests/legacy/"
        )
        install_cmd = " && ".join(self.install_ueapp_cmd)
        self.shell_execute.execute_cmd(install_cmd)

    def update_test_result_file(self):
        """
        Updates the test result json file with the test results for the executed test cases
        """
        gnb_load_details = {}
        suite_statistics = {}
        key_to_find = "Test_result"
        json_file_name = self.suite + '_output.json'
        json_file = os.path.join(self.workspace_path, json_file_name)
        gnb_load_details['UEAPP_on_Host'] = self.enb_build
        # mkdir_cmd = 'mkdir -p ' + path_feature
        # os.system(mkdir_cmd)
        suite_statistics["Total_Cases"] = sum(
            key_to_find in inner_dict for inner_dict in self.ueapp_test_result.values()
            )
        values = [
            inner_dict[key_to_find]
            for inner_dict in self.ueapp_test_result.values()
            if key_to_find in inner_dict
            ]
        suite_statistics['Total_Pass'] = values.count('PASS')
        suite_statistics['Total_Fail'] = values.count('FAIL')
        ueapp_test_result_final = {
            self.suite: {"Suite_Statistics": suite_statistics}
            | {"GNB_Build": gnb_load_details}
            | {"Testcase_Results": self.ueapp_test_result}
            }
        with open(json_file, 'w', encoding='UTF-8') as outfile:
            try:
                json.dump(ueapp_test_result_final, outfile, indent=6, default=self.convert_sets)
            except TypeError as e:
                print(e)
        feature_stats_json_file_name = self.suite + '_feature_stats.json'
        feature_stats_json_file = os.path.join(
            self.workspace_path, feature_stats_json_file_name
        )
        short_desc = {}
        short_desc["short_desc"] = "UEAPP_on_Host"
        feature_stats_test_results = {}
        feature_stats_test_results["Total"] = suite_statistics['Total_Cases']
        feature_stats_test_results["Passed"] = values.count('PASS')
        feature_stats_test_results["Failed"] = values.count('FAIL')
        ueapp_feature_result = {**short_desc, **feature_stats_test_results}
        ueapp_feature_result_final = {self.suite: ueapp_feature_result}
        with open(feature_stats_json_file, 'w') as featurestats_outfile:
            try:
                json.dump(
                    ueapp_feature_result_final,
                    featurestats_outfile,
                    indent=6,
                    default=self.convert_sets,
                )
            except TypeError as e:
                print(e)
        if int(suite_statistics['Total_Fail']) > 0:
            print(
                "We see failures on the run so we will exit with non-zero exit code"
            )
            exit(1)

    def convert_sets(self, obj):
        if isinstance(obj, set):
            return list(obj)
        raise TypeError(
            f"Object of type {obj.__class__.__name__} is not JSON serializable"
        )

    def ueapp_on_host_executor(self):
        """
        Executes the UEAPP on the host by setting up the Docker environment, installing the UEAPP, migrating the SCF,
        running the test cases, and updating the test result file.
        """
        try:
            self.setup_dockers()
            install_flag = os.environ.get("IS_AGENT_REQUIRED", False)
            if (str(install_flag)).lower() == "true":
                self.install_ueapp()
            scf_migration_flag = os.environ.get("scf_migratoration", False)
            if (str(scf_migration_flag)).lower() == "true":
                self.scf_migration()
        except Exception as e:
            raise Exception("Setup Preparation failed so existing runner : {}".format(e))
        if "UC" in self.suite:
            self.testcase_runner()
        else:
            self.run_testcase(self.suite)
        self.update_test_result_file()


def get_args():
    """
    Parses the command line arguments.

    Returns:
    argparse.Namespace: The parsed command line arguments.
    """
    import argparse
    parser = argparse.ArgumentParser(description='Script to Execute AP_P1')
    parser.add_argument('--runtype', required=True, help='Run Type to be used for Regression.')
    parser.add_argument('--workspace', required=True, help='Workspace Path to store the Robot Logs')
    parser.add_argument('--suite', required=True, help='suite name')
    parser.add_argument('--workspace_path', required=True, help='workspace path.')
    parser.add_argument('--yaml_file', required=True, help='file path of the yaml file if new file has to be used')
    parser.add_argument('--test_variable', required=False, default='',
                        help='Any parameter we want to overide in the test case')
    args = parser.parse_args()
    return args


def main(args):
    """
    The main function that creates an instance of the UEAPPonHostExecutor class and executes the UEAPP on the host.

    Parameters:
    args (argparse.Namespace): The command line arguments.
    """
    app1_executor = UEAPPonHostExecutor(
        args.runtype,
        args.workspace,
        args.suite,
        args.workspace_path,
        args.yaml_file,
        args.test_variable,
    )
    app1_executor.ueapp_on_host_executor()
    return


if __name__ == "__main__":
    args = get_args()
    main(args)
