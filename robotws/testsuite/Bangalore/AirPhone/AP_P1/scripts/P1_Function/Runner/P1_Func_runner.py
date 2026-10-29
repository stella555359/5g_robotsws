from robot import run, rebot
import io
import time
import yaml
import os
import sys
import subprocess
import glob
import tarfile
import json
import robot
from robot.api import ExecutionResult, ResultVisitor

try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru

TESTLINE_CONFIG_PATH = '/home/ute/testline_configuration/'


class APP1Executor():
    def __init__(self, stream, workspace, suite, workspace_path, regression_type='CIT',
                 dryrun='false', recovery_reboot='false', tag='AP_P1', test_variable=''):
        self.stream = stream
        self.workspace = workspace
        self.workspace_path = workspace_path
        self.suite = suite
        self.regression_type = regression_type
        self.tag = tag
        self.test_variable = test_variable
        self.feature_data_parser = FeatureDataParser(self.workspace, self.suite)
        self.test_executor = RobotExecutor(self.stream, regression_type, self.workspace,
                                           dryrun, recovery_reboot, self.suite, self.workspace_path, self.tag,
                                           self.test_variable)
        self.features = self.get_features()

    def execute(self):
        self.execute_testcase_for_features()

    def get_features(self):
        return self.feature_data_parser.get_features(self.stream, self.regression_type, self.suite)

    def execute_testcase_for_features(self):
        self.test_executor.execute(self.features, self.suite)
        return


class RobotExecutor():
    def __init__(self, stream, regression_type, workspace, dryrun, recovery_reboot, suite, workspace_path, tags,
                 test_variable):
        self.stream = stream
        self.regression_type = regression_type
        self.host = Host(workspace)
        self.feature_stats = {}
        self.workspace_path = workspace_path
        self.log_path = self._get_log_path(workspace_path)
        self.dryrun = True if dryrun == 'true' else False
        self.recovery_reboot = True if recovery_reboot == 'true' else recovery_reboot
        self.suite = suite
        self.run_type_variable = 'RUN_TYPE:{}'.format(stream)
        self.skip_reporting = 'AP_P1:{}'.format("True")
        is_agent_required = os.environ.get('IS_AGENT_REQUIRED')
        self.is_agent_required = True if is_agent_required == 'true' else is_agent_required
        loguru.logger.info('Value of is_agent_required', self.is_agent_required)
        if test_variable == '':
            self.variables = [self.run_type_variable, self.skip_reporting]
        else:
            self.variables = test_variable.split(',')
            self.variables.extend([self.run_type_variable, self.skip_reporting])
        self.include_tags = tags.split(',')
        self._initialize_rotta_variables()
        if self.is_agent_required is True and '6G' not in self.suite:
            self._tar_agent_logs()

    def execute_command_in_shell(self, command, log=True, timeout=0.5):
        filename = "shell_output.log"
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

    def _initialize_rotta_variables(self):
        self.gnb_load = os.environ["GNB_LOAD_ID"]
        self.ap_load = os.environ["AP_LOAD_ID"]
        self.workspace = os.environ["WORKSPACE"]
        self.multiphase_build_id = os.environ["MULTI_PHASE_BUILD_ID"]
        self.build_id = os.environ["BUILD_NUMBER"]
        self.topology = os.environ["TOPOLOGY"]
        self.week_no = os.environ["WEEK_NO"]
        rotta_user_bk = os.environ["ROTTA_USER"]
        rotta_passwd_bk = os.environ["ROTTA_PASSWD"]
        rotta_user = os.environ.get("AP_USER", rotta_user_bk)
        rotta_passwd = os.environ.get("APP1_PASSWD", rotta_passwd_bk)
        script_name = "entitytests/tools/scripts/misc/rotta_auth_update/rotta_krb_auth_update.py"
        script_options = "krb-install-pkg --username {} --passwd {}".format(rotta_user, rotta_passwd)
        script_path = os.path.join(self.workspace, script_name)
        enable_auth_cmd = "python {} {}".format(script_path, script_options)
        self.execute_command_in_shell(enable_auth_cmd)

    def _tar_agent_logs(self):
        install_log_folder = self.suite + '_install_logs'
        install_output_dir = self.log_path + '/' + '{}.tar.gz'.format(install_log_folder)
        os.system('mkdir -p {}/robot_log_collector'.format(self.log_path))
        execution_id = os.listdir('/home/ute/.ute-ca/executions')[0]
        install_source_dir = '/home/ute/.ute-ca/executions/' + execution_id + '/'
        self.make_tar(install_output_dir, install_source_dir)

    def _get_log_path(self, workspace_path):
        log_folder = 'robot_log_collector'
        return os.path.join(workspace_path, log_folder)

    def _get_output_dir(self, feature_id):
        return os.path.join(self.log_path, feature_id)

    def execute(self, features, suite):
        for feature in features:
            self.execute_suites_of_feature(feature)
            self.tar_logs(feature)
            self.copy_logs_to_rotta()
            self.transfer_file_to_central_system()
            self.delete_tar_post_copy_to_rotta(self.workspace_path)
        self.feature_stats_json_file_creation()
        self.merge_robot_log(features, self.suite)

    def execute_suites_of_feature(self, feature):
        output_dir = self._get_output_dir(feature.id)
        for suite in feature.suites_absolute_path:
            run(suite, loglevel='TRACE', consolecolors='ansi',
                outputdir=output_dir,
                dryrun=self.dryrun, include=self.include_tags,
                debugfile=feature.debug_file,
                variable=self.variables,
                variablefile=self.host.tl_config_file,
                log=feature.log_html)
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
        loguru.logger.info(f"Robot Version : {robot.__version__}")
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
        features_output = glob.glob('{}/{}/*output.xml'.format(self.log_path, suite))
        rebot(*features_output, output='output.xml', name=name)
        return

    def tar_logs(self, feature):
        log_dir = self._get_output_dir(feature.id)
        output_file = self.log_path + '/' + '{}.tar.gz'.format(feature.id)
        self.make_tar(output_file, log_dir)
        return

    def make_tar(self, output_file, source_dir):
        with tarfile.open(output_file, "w:gz") as tar:
            tar.add(source_dir, arcname=os.path.basename(source_dir))
        return

    def copy_logs_to_rotta(self):
        loguru.logger.info("Going to start rotta copy")
        success_flag = False
        rotta_user_bk = os.environ.get("ROTTA_USER", "")
        rotta_passwd_bk = os.environ.get("ROTTA_PASSWD", "")
        rotta_user = os.environ.get("AP_USER", rotta_user_bk)
        rotta_passwd = os.environ.get("APP1_PASSWD", rotta_passwd_bk)
        rotta_mnt_cmds = [
            (f"sudo -S mount -t cifs -v -o vers=2.0,sec=krb5,uid=ute,gid=ute "
             "//eseefsn50.emea.nsn-net.net/rotta4internal/MN_Airphone/ap_rel_logs/ /mnt/AP_QT_logs"),
            (f"sudo -S mount -t cifs //nescrotta.dyn.nesc.nokia.net/rotta/AIRPHONE/AP3/AP_REL_LOGS/ "
             f"/mnt/AP_QT_logs -o username={rotta_user},password={rotta_passwd},"
             "uid=1000,gid=1000,rw,domain=NSN-INTRA.NET"),
        ]
        log_folder = (f"/mnt/AP_QT_logs/{self.week_no}/{self.regression_type}/{self.ap_load}/"
                      f"{self.gnb_load}/{self.multiphase_build_id}/{self.topology}/{self.build_id}/")
        loguru.logger.info(f" Log folder : {log_folder}")
        for rotta_path in rotta_mnt_cmds:
            loguru.logger.info(f"rotta path : {rotta_path}")
            cmds = [
                'sudo umount -f -l /mnt/AP_QT_logs || echo ""',
                "sudo mkdir -p /mnt/AP_QT_logs",
                (f"{rotta_path}"),
                f"sudo mkdir -p {log_folder}",
                f"df -kh",
                f"ls -ltr {log_folder}",
                (f"sudo scp -rC {self.workspace}/robot_log_collector/*.tar.gz {self.workspace}/run.properties "
                 f"{self.workspace}/robot_log_collector/*log.html {log_folder}"),
                f"ls -ltr {log_folder}",
                f"df -kh",
                "sudo umount -f -l /mnt/AP_QT_logs",
                "echo 'Successfully Uploaded'",
            ]
            shell_commands = " && ".join(cmds)
            try:
                file_name = self.execute_command_in_shell(shell_commands)
                with open(file_name, "r") as f:
                    console = f.read().lower()
                loguru.logger.info(f"Console output: {console}")
            except Exception as e:
                loguru.logger.info(f"Failed during rotta mount and copy: {e}")
                try:
                    print(f"output of the console: {console}")
                except Exception as e:
                    loguru.logger.info("Console output can't be retrieved")
                console = None
                continue
            loguru.logger.info(f"console output: {console}")
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
                loguru.logger.info(f"Console output for VM copy: {console}")
            except Exception as e:
                loguru.logger.info(f"Local VM copy failed with error : {e}")
            return
        loguru.logger.info(f"rotta_path : {rotta_path}")
        os.system(f"ls -ltr {log_folder}")
        os.system(f"df -kh")
        path_val = [x for x in rotta_path.split() if "ap_rel_logs" in x.lower()][0]
        loguru.logger.info(f"Rotta server chosen: {path_val}")
        ROTTA_LINK = (f"file://{path_val}{self.week_no}/"
                      f"{self.regression_type}/{self.ap_load}/{self.gnb_load}/{self.multiphase_build_id}/")
        loguru.logger.info(f"ROTTA LINK: {ROTTA_LINK}")
        rota_var = f'ROTTA_LOG={ROTTA_LINK}'
        rota_file = os.path.join(self.workspace, "run.properties")
        with open(rota_file, 'a') as f:
            f.write(rota_var + "\n")
            f.close()
        return

    # The gunzipped files will be sent to the central system.
    def transfer_file_to_central_system(self):
        server = os.environ['host']
        user = os.environ['username']
        password = os.environ['passwd']
        dir_path = "/".join([self.week_no, self.regression_type, self.ap_load, self.gnb_load,
                             self.multiphase_build_id, self.topology, self.build_id])
        dest_dir = "/home/" + user + '/P1_Func_Logs/' + dir_path
        loguru.logger.info('dest_dir is {}'.format(dest_dir))
        cmds = [
                (f"sshpass -p {password} ssh {user}@{server} mkdir -p {dest_dir}"),
                (f"sshpass -p {password} scp -rC {self.workspace}/robot_log_collector/*.tar.gz "
                 f"{self.workspace}/run.properties "
                 f"{self.workspace}/robot_log_collector/*log.html {user}@{server}:{dest_dir}")]
        shell_commands = " && ".join(cmds)
        file_name = self.execute_command_in_shell(shell_commands)
        with open(file_name, 'r') as file:
            file_content = file.read()
        if "timed out" not in file_content:
            delete_cmd = "rm -rf /home/ute/logs/*tar.gz"
            self.execute_command_in_shell(delete_cmd)
            self.execute_command_in_shell("ls -ltr /home/ute/logs/")
            loguru.logger.info('copied logs to local server {} in path {}'.format(server, dest_dir))
        else:
            self.execute_command_in_shell("ls -ltr /home/ute/logs/")
            loguru.logger.info('Logs to local server not copied')
        return

    def delete_tar_post_copy_to_rotta(self, workspace):
        self.execute_command_in_shell("rm -rf {}/robot_log_collector/*.tar.gz".format(workspace))


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
    APP1_DATA_FILE = os.path.join(sys.path[0], 'P1_Func_suites.yaml')

    def __init__(self, workspace, suite):
        self.stream = open(self.APP1_DATA_FILE, 'r')
        self.feature_data = yaml.load(self.stream, Loader=yaml.FullLoader)
        self.workspace = workspace
        self.suite = suite

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
            if feature_id == self.suite:
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
        self.description = feature_data.get('Description', '')

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
    loguru.logger.info(result)
    stdout = result.stdout.decode('utf-8')
    wts_ver = stdout[:stdout.find('tar')-1]
    wts_ver_bk = "esimmode_WTS_{}".format(ap_load)
    wts_link_cmd = "cd /opt/iphy/ && ln -s /opt/wts/latest {}".format(wts_ver)
    wts_link_cmd2 = "cd /opt/iphy/ && ln -s /opt/wts/latest {}".format(wts_ver_bk)
    wts_cmd = wts_link_cmd if "WTS" in wts_ver else wts_link_cmd2
    wts_result = subprocess.run(wts_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, timeout=180)
    loguru.logger.info(wts_result)


def verify_iphy_wts_link_exists():
    cmd = "ls /opt/iphy | grep WTS"
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True,
                            timeout=180)
    loguru.logger.info(result)
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
    parser.add_argument('--tags', required=False, default='AP_P1', help='Test tags to be used')
    parser.add_argument('--test_variable', default='', required=False,
                        help='If any variables have to be updated in runtime')
    args = parser.parse_args()
    return args


def main(args):
    app1_executor = APP1Executor(args.runtype, args.workspace, args.suite, args.workspace_path,
                                 args.regression_type, args.just_fetch_tc_name, args.recovery_reboot,
                                 args.tags, args.test_variable)
    link_iphy_wts_version()
    app1_executor.execute()
    return


if __name__ == "__main__":
    args = get_args()
    main(args)
