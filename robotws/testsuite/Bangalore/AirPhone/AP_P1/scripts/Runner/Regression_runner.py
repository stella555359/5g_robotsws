from robot import run, rebot
import io
import sys
import time
import yaml
import os
import sys
import subprocess
import glob
import tarfile
from robot.api import ExecutionResult, ResultVisitor
import json
import robot
import shutil

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
TESTLINE_CONFIG_PATH = '/home/ute/testline_configuration/'
CLEANUP_SCRIPT = 'robotws/testsuite/Bangalore/AirPhone/AP_P1/scripts/Runner/TLEnvCleanup.py'
CLEANUP_CMD = 'python {0}/' + CLEANUP_SCRIPT + ' testline-reboot-after-suite {1} --update_required {2} \
               --is_oran {3} --output_dir {4}'


class APP1RegressionExecutor():
    def __init__(self, stream, workspace, suite, workspace_path, regression_type='CIT',
                 dryrun='false', recovery_reboot='false', tag='AP_REG',
                 yaml_file='default', run_features='all', test_variable=''):
        self.stream = stream
        self.workspace = workspace
        self.workspace_path = workspace_path
        self.suite = suite
        self.regression_type = regression_type
        self.tag = tag
        self.yaml_file = yaml_file
        self.test_variable = test_variable
        self.enb_build = os.environ['GNB_LOAD_ID']
        self.feature_data_parser = FeatureDataParser(self.workspace, self.suite, self.yaml_file, run_features)
        self.test_executor = RobotExecutor(self.stream, regression_type, self.workspace,
                                           dryrun, recovery_reboot, self.suite, self.workspace_path, self.tag,
                                           self.test_variable, self.enb_build)
        self.features = self.get_features()

    def execute(self):
        self.execute_testcase_for_features()

    def get_features(self):
        return self.feature_data_parser.get_features(self.stream, self.regression_type, self.suite)

    def execute_testcase_for_features(self):
        self.test_executor.execute(self.features, self.suite, self.feature_data_parser.run_features)
        return


class RobotExecutor():
    def __init__(self, stream, regression_type, workspace, dryrun, recovery_reboot, suite, workspace_path, tags,
                 test_variable, enb_build):
        self.stream = stream
        self.regression_type = regression_type
        self.workspace = workspace
        self.feature_stats = {}
        self.host = Host(workspace)
        self.workspace_path = workspace_path
        self.log_path = self._get_log_path(workspace_path)
        self.dryrun = True if dryrun == 'true' else False
        is_agent_required = os.environ.get('IS_AGENT_REQUIRED')
        self.is_agent_required = True if is_agent_required == 'true' else is_agent_required
        force_install = os.environ.get('force_install', 'true')
        self.force_install = True if force_install == 'true' else force_install
        self.rotta_copy = os.environ.get('LOGS_STORAGE', 'nesc_or_rotta')
        self.recovery_reboot = True if recovery_reboot == 'true' else recovery_reboot
        self.suite = suite
        self.run_type_variable = 'RUN_TYPE:{}'.format(stream)
        self.skip_reporting = 'AP_P1:{}'.format("True")
        self.enb_build = "ENB_BUILD:{}".format(enb_build)
        self.variables = [self.run_type_variable, self.skip_reporting, self.enb_build]
        if test_variable != '':
            self.test_variables = test_variable.split(',')
            self.variables.extend(self.test_variables)
        self.include_tags = tags
        self._initialize_rotta_variables()
        if self.is_agent_required is True:
            self._tar_agent_logs()

    def _tar_agent_logs(self):
        install_log_folder = self.suite + '_install_logs'
        install_output_dir = self.log_path + '/' + '{}.tar.gz'.format(install_log_folder)
        os.system('mkdir -p {}/robot_log_collector'.format(self.log_path))
        execution_id = os.listdir('/home/ute/.ute-ca/executions')[0]
        install_source_dir = '/home/ute/.ute-ca/executions/' + execution_id + '/'
        self.make_tar(install_output_dir, install_source_dir)

    def execute_command_in_shell(self, command, log=True, timeout=0.5, filename="shell_output.log"):
        with io.open(filename, "w") as writer, io.open(filename, "r", 1) as reader:
            process = subprocess.Popen(
                command, shell=True, executable="/bin/bash", stdout=writer, stderr=writer
            )
            while process.poll() is None:
                if log:
                    sys.stdout.write(reader.read())
                time.sleep(timeout)
            if log:
                sys.stdout.write(reader.read())
            if "fatal" in reader.read():
                raise ShellException
            if "unable to re-open stdin" in reader.read():
                raise ShellException
        return filename

    def _get_log_path(self, workspace_path):
        log_folder = 'robot_log_collector'
        return os.path.join(workspace_path, log_folder)

    def _get_output_dir(self, feature_id):
        return os.path.join(self.log_path, feature_id)

    def execute(self, features, suite, run_features=''):
        for feature in features:
            self.execute_suites_of_feature(feature)
            self.tar_logs(feature)
            self.copy_egate_console_logs(feature)
            if self.rotta_copy == 'nesc_or_rotta':
                self.copy_logs_to_rotta()
                self.transfer_file_to_central_system()
            elif self.rotta_copy == 'pet_server':
                self.copy_logs_to_p1_log_server()
            else:
                loguru.logger.info("Logs copy to rotta or server is skipped!!")
            self.delete_tar_post_copy_to_rotta(self.workspace_path)
        self.feature_stats_json_file_creation()
        loguru.logger.info("Going to start merge robot")
        self.merge_robot_log(features, self.suite)

    def execute_suites_of_feature(self, feature):
        output_dir = self._get_output_dir(feature.id)
        sys.path.append(self.workspace)
        for suite in feature.suites_absolute_path:
            if not os.path.exists(suite):
                loguru.logger.error(f"{suite} does not exist")
                continue
            final_testcase_arg = ''
            test_cases = []
            self.cleanup_workspace_stale_process()
            is_oran = "True" if 'ORAN' in feature.variant else "False"
            self.variables.append("IS_ORAN:{}".format(is_oran))
            if self.dryrun is False and feature.cleanup_mode == 'env_reset':
                custom_config = "/home/ute/tl_custom_config/" \
                    if feature.custom_config == "false" else feature.custom_config
                update_required = "True"
                os.system(CLEANUP_CMD.format(WORKSPACE_FOLDER, custom_config, update_required,
                                             is_oran, output_dir))
            else:
                loguru.logger.info(f"Skipping cleanup of AP,gNB and WTS as cleanup mode is {feature.cleanup_mode}\n")
            if self.include_tags.lower().startswith("tc_name:"):
                tc_list = self.include_tags.split(":", 1)[1].split(',')
                for each_test in tc_list:
                    final_testcase_arg += f' -t "*{each_test.strip()}*"'
            elif self.include_tags == "AP_REG" or self.include_tags == "P3_REG":
                if feature.tags:
                    combined_tags = f"{self.include_tags}AND{feature.tags}"
                    include_tags = combined_tags.split(',')
                else:
                    include_tags = self.include_tags.split(',')
                inc_tag = " --include " + "OR".join(tag.strip() for tag in include_tags)
            else:
                include_tags = self.include_tags.split(',')
                inc_tag = " --include " + "OR".join(tag.strip() for tag in include_tags)
            loguru.logger.info(f"variables are {self.variables}")
            print(f"variables are \n {self.variables}")
            if not final_testcase_arg and feature.testcase_name:
                testcase_to_run = feature.testcase_name.split(',')
                for each_test in testcase_to_run:
                    final_testcase_arg = final_testcase_arg + " -t *" + each_test + '*'
            # Ugly way of isolating scope need to find a proper fix
            """run(suite, loglevel='TRACE', consolecolors='ansi',
                outputdir=output_dir,
                dryrun=self.dryrun, include=include_tags,
                debugfile=feature.debug_file,
                variable=self.variables,
                variablefile=self.host.tl_config_file,
                log=feature.log_html)"""
            var = " -v " + " -v ".join(self.variables)
            file_feature = feature.id + "shell_output.log"
            dry_run = "" if self.dryrun is False else " --dryrun"
            debug = "-b {}".format(feature.debug_file)
            test_identifer = final_testcase_arg if final_testcase_arg else inc_tag
            self.execdir_log_path = os.path.join(os.getcwd(), "logs")
            loguru.logger.info(f"execdir_log_path is {self.execdir_log_path}")
            os.system(f"mkdir -p {self.execdir_log_path}")
            robot_cmd = (f"stdbuf -o0 -e0 robot -L TRACE -d {output_dir}{dry_run} {debug} {test_identifer} {var} "
                         f"-V {self.host.tl_config_file} -l {feature.log_html} {suite}")
            loguru.logger.info(f"Robot cmd to be executed: {robot_cmd} \n")
            self.execute_command_in_shell(robot_cmd, timeout=300, filename=file_feature)
            self.feature_details(feature, output_dir)
            log_html_cp_cmd = 'cp {}/*_log.html {}'.format(output_dir, self.log_path)
            os.system(log_html_cp_cmd)

    def get_stats_related_object_for_robot(self, xml_path):
        testcase = ExecutionResult(xml_path)
        test_obj = TestMetrics()
        return testcase, test_obj

    def feature_details(self, feature, output_dir):
        featurename = feature.id.split('_', 1)[1]
        feature_info = {}
        feature_info_master = {}
        feature_info["short_desc"] = feature.description
        xml_path = os.path.join(output_dir, 'output.xml')
        testcase, test_obj = self.get_stats_related_object_for_robot(xml_path)
        testcase.visit(test_obj)
        stats = testcase.statistics
        if int(robot.__version__.split('.')[0]) > 3:
            feature_info["Total"] = stats.total.total
            feature_info["Passed"] = stats.total.passed
            feature_info["Failed"] = stats.total.failed
        else:
            feature_info["Total"] = stats.total.all.total
            feature_info["Passed"] = stats.total.all.passed
            feature_info["Failed"] = stats.total.all.failed
        self.feature_stats[featurename] = feature_info
        return feature_info

    def feature_stats_json_file_creation(self):
        json_file_name = self.suite + '_feature_stats.json'
        path_feature = os.path.join(self.workspace_path, "feature_stats")
        mkdir_cmd = 'mkdir -p ' + path_feature
        os.system(mkdir_cmd)
        json_file = os.path.join(path_feature, json_file_name)
        with open(json_file, 'w') as outfile:
            json.dump(self.feature_stats, outfile, indent=6)

    def merge_robot_log(self, feature, suite):
        name = '_'.join([self.stream, self.regression_type])
        features_output = glob.glob('{}/*/*output*.xml'.format(self.log_path))
        rebot(*features_output, output='output.xml', name=name)
        return

    def _initialize_rotta_variables(self):
        self.gnb_load = os.environ["GNB_LOAD_ID"]
        self.ap_load = os.environ["AP_LOAD_ID"]
        self.workspace = os.environ["WORKSPACE"]
        self.multiphase_build_id = os.environ["MULTI_PHASE_BUILD_ID"]
        self.build_id = os.environ["BUILD_NUMBER"]
        self.topology = os.environ["TOPOLOGY"]
        self.week_no = os.environ["WEEK_NO"]
        rotta_user_bk = os.environ.get("ROTTA_USER", "")
        rotta_passwd_bk = os.environ.get("ROTTA_PASSWD", "")
        rotta_user = os.environ.get("AP_USER", rotta_user_bk)
        rotta_passwd = os.environ.get("APP1_PASSWD", rotta_passwd_bk)
        script_name = "entitytests/tools/scripts/misc/rotta_auth_update/rotta_krb_auth_update.py"
        script_options = "krb-install-pkg --username {} --passwd {}".format(rotta_user, rotta_passwd)
        script_path = os.path.join(self.workspace, script_name)
        enable_auth_cmd = "python {} {}".format(script_path, script_options)
        self.execute_command_in_shell(enable_auth_cmd)

    def tar_logs(self, feature):
        log_dir = self._get_output_dir(feature.id)
        os.system(f"scp -rC {self.execdir_log_path} {log_dir}")
        output_file = self.log_path + '/' + '{}.tar.gz'.format(feature.id)
        self.make_tar(output_file, log_dir)
        return

    def copy_egate_console_logs(self, feature):
        log_dir = self._get_output_dir(feature.id)
        base_log_dir = os.path.join(log_dir, 'Logs-*', '*')
        destination_log_dir = os.path.join(self.log_path, f"{feature.id}_egate_logs")
        log_file_name = "egate_console.log"
        target_folders = []
        matching_folders = glob.glob(base_log_dir)
        for folder_name in matching_folders:
            folder_path = os.path.join(base_log_dir, folder_name)
            if os.path.isdir(folder_path):
                log_file_path = os.path.join(folder_path, log_file_name)
                if os.path.exists(log_file_path):
                    target_folders.append(folder_name)
                else:
                    loguru.logger.info(f"{log_file_name} not found in {log_file_path}")
        self.copy_target_egate_console_logs(base_log_dir, destination_log_dir, log_file_name, target_folders)

    def copy_target_egate_console_logs(self, base_log_dir, destination_log_dir, log_file_name, target_folders):
        for folder in target_folders:
            log_file_path = os.path.join(base_log_dir, folder, log_file_name)
            final_part_of_folder = os.path.basename(folder)
            truncated_final_part_of_folder = final_part_of_folder[:50]
            folder_destination = os.path.join(destination_log_dir, truncated_final_part_of_folder)
            os.makedirs(folder_destination, exist_ok=True)
            try:
                shutil.copy(log_file_path, os.path.join(folder_destination, log_file_name))
            except Exception as e:
                loguru.logger.info(f"An error occurred: {e}")

    def make_tar(self, output_file, source_dir):
        with tarfile.open(output_file, "w:gz") as tar:
            tar.add(source_dir, arcname=os.path.basename(source_dir))
        return

    def copy_logs_to_rotta(self):
        success_flag = False
        loguru.logger.info("Going to start rotta copy")
        rotta_user_bk = os.environ.get("ROTTA_USER", "")
        rotta_passwd_bk = os.environ.get("ROTTA_PASSWD", "")
        rotta_user = os.environ.get("AP_USER", rotta_user_bk)
        rotta_passwd = os.environ.get("APP1_PASSWD", rotta_passwd_bk)
        rotta_mnt_cmds = [
            (f"sudo -S mount -t cifs //nescrotta.dyn.nesc.nokia.net/rotta/AIRPHONE/AP3/AP_P1 "
             f"/mnt/AP_P1_logs -o username={rotta_user},password={rotta_passwd},iocharset=utf8,"
             "uid=1000,gid=1000,domain=NSN-INTRA.NET"),
            (f"sudo -S mount -t cifs -v -o vers=2.0,sec=krb5,uid=ute,gid=ute "
             "//eseefsn50.emea.nsn-net.net/rotta4internal/MN_Airphone/AP_P1 /mnt/AP_P1_logs")
        ]
        log_folder = (f"/mnt/AP_P1_logs/{self.week_no}/{self.regression_type}/{self.ap_load}/"
                      f"{self.gnb_load}/{self.multiphase_build_id}/{self.topology}/{self.build_id}/")
        for rotta_path in rotta_mnt_cmds:
            cmds = [
                'sudo umount -f -l /mnt/AP_P1_logs || echo ""',
                "sudo mkdir -p /mnt/AP_P1_logs",
                (f"{rotta_path}"),
                f"sudo mkdir -p {log_folder}",
                (f"sudo scp -rC {self.workspace}/robot_log_collector/*.tar.gz {self.workspace}/run.properties "
                 f"{self.workspace}/robot_log_collector/*log.html "
                 f"{self.workspace}/robot_log_collector/*_egate_logs {log_folder}"),
                f"ls -ltr {log_folder}",
                "sudo umount -f -l /mnt/AP_P1_logs",
                "echo 'Successfully Uploaded'",
            ]
            shell_commands = " && ".join(cmds)
            try:
                file_name = self.execute_command_in_shell(shell_commands)
                with open(file_name, "r") as f:
                    console = f.read().lower()
            except Exception as e:
                loguru.logger.info(f"Failed during rotta mount and copy: {e}")
                console = None
                continue
            if console and ("no space".lower() in console.lower() or "mount error".lower() in console.lower()):
                continue
            else:
                success_flag = True
                break
        if success_flag is False:
            loguru.logger.info("All options to copy to Rotta has failed, Saving it temp on the VM itself")
            copy_cmd = (f"sudo cp {self.workspace}/robot_log_collector/*.tar.gz {self.workspace}/run.properties "
                        f"{self.workspace}/robot_log_collector/*log.html /home/ute/logs/")
            try:
                file_name = self.execute_command_in_shell(copy_cmd)
                with open(file_name, "r") as f:
                    console = f.read().lower()
            except Exception as e:
                loguru.logger.info(f"Local VM copy failed with error : {e}")
            return
        path_val = [x for x in rotta_path.split() if "ap_p1" in x.lower()][0]
        ROTTA_LINK = (f"file://{path_val}/{self.week_no}/"
                      f"{self.regression_type}/{self.ap_load}/{self.gnb_load}/{self.multiphase_build_id}/")
        loguru.logger.info(f"ROTTA LINK: {ROTTA_LINK}")
        return

    # The gunzipped files will be sent to the central system.
    def transfer_file_to_central_system(self):
        server = os.environ['host']
        user = os.environ['username']
        password = os.environ['passwd']
        dir_path = "/".join([self.week_no, self.regression_type, self.ap_load, self.gnb_load,
                             self.multiphase_build_id, self.topology, self.build_id])
        dest_dir = "/home/" + user + '/P1_Func_Logs/' + dir_path
        cmds = [
                (f"sshpass -p {password} ssh {user}@{server} mkdir -p {dest_dir}"),
                (f"sshpass -p {password} scp -rC {self.workspace}/robot_log_collector/*.tar.gz "
                 f"{self.workspace}/run.properties "
                 f"{self.workspace}/robot_log_collector/*log.html "
                 f"{self.workspace}/robot_log_collector/*_egate_logs {user}@{server}:{dest_dir}")]
        shell_commands = " && ".join(cmds)
        file_name = self.execute_command_in_shell(shell_commands)
        with open(file_name, 'r') as file:
            file_content = file.read()
        if "timed out" not in file_content:
            self.execute_command_in_shell("ls -ltr /home/ute/logs/")
            delete_cmd = "rm -rf /home/ute/logs/*tar.gz"
            self.execute_command_in_shell(delete_cmd)
            self.execute_command_in_shell("ls -ltr /home/ute/logs/")
            loguru.logger.info(f"copied logs to local server {server} in path {dest_dir}")
        else:
            self.execute_command_in_shell("ls -ltr /home/ute/logs/")
            loguru.logger.info('Logs to local server not copied')
        return

    def copy_logs_to_p1_log_server(self):
        server = '10.45.131.158'
        user = 'ute'
        password = 'App1@k_zxc2022'
        dir_path = "/".join([self.week_no, self.regression_type, self.ap_load, self.gnb_load,
                             self.multiphase_build_id, self.topology, self.build_id])
        dest_dir = "/home/" + user + '/Regression_Logs/' + dir_path
        loguru.logger.info('dest_dir is {}'.format(dest_dir))
        cmds = [
                (f"sshpass -p {password} ssh {user}@{server} mkdir -p {dest_dir}"),
                (f"sshpass -p {password} scp -rC {self.workspace}/robot_log_collector/*.tar.gz "
                 f"{self.workspace}/run.properties "
                 f"{self.workspace}/robot_log_collector/*log.html "
                 f"{self.workspace}/robot_log_collector/*_egate_logs {user}@{server}:{dest_dir}")]
        shell_commands = " && ".join(cmds)
        file_name = self.execute_command_in_shell(shell_commands)
        with open(file_name, 'r') as file:
            file_content = file.read()
        loguru.logger.info(f"Local transfer output: {file_content}")
        return

    def delete_tar_post_copy_to_rotta(self, workspace):
        self.execute_command_in_shell("rm -rf {}/robot_log_collector/*.tar.gz".format(workspace))

    def cleanup_workspace_stale_process(self):
        os.system("df -h /home/|awk 'NR>1{print $5}' >/dev/null 2>&1")
        os.system("sudo lsof +L1 | awk '$10 ~ /^\\/home\\/ute\\/workspace/ {print $2}' > /tmp/staleprocess.txt")
        if os.stat('/tmp/staleprocess.txt').st_size == 0:
            loguru.logger.info("stale process file is empty")
        else:
            file_handle = open('/tmp/staleprocess.txt', 'r')
            process_list = list(set(file_handle.readlines()))
            for process_id in process_list:
                os.system('kill -9 {}'.format(process_id.strip()))
                loguru.logger.info(f"killed process with {process_id.strip()}")
            os.system("df -h /home/|awk 'NR>1{print $5}'")
        os.system('rm -rf /tmp/staleprocess.txt')
        return


class TestMetrics(ResultVisitor):
    def __init__(self):
        self.test_info = {}

    def visit_test(self, test):
        self.test_info[test.name] = test.status


class Host():

    def __init__(self, workspace):
        self.workspace = workspace
        self.hostname = self.get_hostname()
        self.tl_config_file = self.get_tl_config_file()

    def get_hostname(self):
        hostname = subprocess.check_output("hostname", shell=True)
        hostname = hostname.decode('UTF-8')
        hostname = hostname.strip()
        return hostname.replace("-", "_")

    def get_tl_config_file(self):
        return os.path.join(TESTLINE_CONFIG_PATH, self.hostname)


class FeatureDataParser():
    APP1_DATA_FILE = os.path.join(sys.path[0], 'P1_Regression_suites.yaml')

    def __init__(self, workspace, suite, yaml_file, run_features):
        local_yaml_file = os.environ.get("local_yaml_file", "false")
        if local_yaml_file == "true":
            job_workspace = os.environ.get("WORKSPACE", "")
            self.yaml_file = os.path.join(job_workspace, 'regression_suites.yaml')
        else:
            self.yaml_file = yaml_file
        self.stream = open(self.APP1_DATA_FILE, 'r') if self.yaml_file == 'default' else open(self.yaml_file, 'r')
        self.feature_data = yaml.load(self.stream, Loader=yaml.FullLoader)
        self.workspace = workspace
        self.suite = suite
        run_features = self.feature_data['FEATURE_DICT_MAPPING'].get(self.suite, run_features)
        loguru.logger.info(f"run_features are {run_features}")
        self.run_features = [x.strip() for x in run_features.split(',')] if run_features != 'all' else run_features

    def get_features(self, stream, regression_type, suite):
        feature_for_stream = self.feature_data[stream][regression_type]
        features = []
        for feature_id, feature_data in self.features_applicable(feature_for_stream, suite):
            features.append(Feature(feature_id, regression_type, feature_data, self.workspace))
        return features

    def features_applicable(self, features_stream, suite):
        for feature_id, feature_data in sorted(features_stream.items(),
                                               key=lambda feature:
                                               int(feature[0].split('_')[0])):
            if self.run_features != 'all' and feature_id in self.run_features:
                yield feature_id, feature_data
            if self.run_features == 'all':
                yield feature_id, feature_data


class Feature():
    def __init__(self, feature_id, regression_type, feature_data, workspace):
        self.id = feature_id
        self.regression_type = regression_type
        self.path = feature_data['Path']
        self.airphone_base_path = workspace
        self.suites = feature_data['Suites']
        self.suites_absolute_path = self._get_suite_absolute_path()
        self.debug_file = self.id + '.log'
        self.log_html = self.id + '_log.html'
        self.output_dir = ''
        self.custom_config = self.get_custom_config_details(feature_data)
        self.tags = feature_data.get('Tags', '')
        self.description = feature_data.get('Description', '')
        self.testcase_name = feature_data.get('TC_Name', '')
        self.variant = feature_data.get('Variant', '')
        self.cleanup_mode = feature_data.get('Cleanup_Mode', 'env_reset')

    def get_custom_config_details(self, feature_data):
        if str(feature_data['Custom_Config']).lower() == "false":
            return "false"
        else:
            return os.path.join(self.airphone_base_path, feature_data['Custom_Config'])

    def _get_suite_absolute_path(self):
        return [os.path.join(self.airphone_base_path, self.path, suite_path) for suite_path in self.suites]


def link_iphy_wts_version():
    output = verify_iphy_wts_link_exists()
    if output != '':
        loguru.logger.info("softlink for WTS package already exists in /opt/iphy folder")
        return
    ap_load = os.environ["AP_LOAD_ID"]
    cmd = "cd /home/ute/.ute-ca/cache/airphone/{}/ && ls esim*".format(ap_load)
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
                            timeout=180)
    stdout = result.stdout.decode('utf-8')
    wts_ver = stdout[:stdout.find('tar')-1]
    wts_ver_bk = "esimmode_WTS_{}".format(ap_load)
    wts_link_cmd = "cd /opt/iphy/ && ln -s /opt/wts/latest {}".format(wts_ver)
    wts_link_cmd2 = "cd /opt/iphy/ && ln -s /opt/wts/latest {}".format(wts_ver_bk)
    wts_cmd = wts_link_cmd if "WTS" in wts_ver else wts_link_cmd2
    wts_result = subprocess.run(wts_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, timeout=180)
    return


def verify_iphy_wts_link_exists():
    cmd = "ls /opt/iphy | grep WTS"
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
                            timeout=180)
    stdout = result.stdout.decode('utf-8')
    return stdout


def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='Script to Execute AP_P1')
    parser.add_argument('--runtype', required=True, help='Run Type to be used for Regression.')
    parser.add_argument('--regression_type', required=True, help='AP_P1 to be executed')
    parser.add_argument('--workspace', required=True, help='Workspace Path to store the Robot Logs')
    parser.add_argument('--suite', required=True, help='suite name')
    parser.add_argument('--just_fetch_tc_name', required=False, default='false',
                        help='Execute testcases in Robot Framework Dryrun mode.')
    parser.add_argument('--recovery_reboot', required=False, default='false',
                        help='Recover the AP and GNB by rebooting on hitting error.')
    parser.add_argument('--workspace_path', required=True, help='workspace path.')
    parser.add_argument('--tags', required=True, help='Test tags to be used')
    parser.add_argument('--yaml_file', required=True, help='file path of the yaml file if new file has to be used')
    parser.add_argument('--run_features', required=True, help='The feature list which you want to run')
    parser.add_argument('--test_variable', required=False, default='',
                        help='Any parameter we want to overide in the test case')
    args = parser.parse_args()
    return args


def main(args):
    app1_executor = APP1RegressionExecutor(args.runtype, args.workspace, args.suite, args.workspace_path,
                                           args.regression_type, args.just_fetch_tc_name,
                                           args.recovery_reboot, args.tags, args.yaml_file, args.run_features,
                                           args.test_variable)
    link_iphy_wts_version()
    app1_executor.execute()
    return


if __name__ == "__main__":
    args = get_args()
    main(args)
