from robot import run, rebot
import yaml
import os
import sys
import subprocess
import glob
from testsuite.AIRPHONE.scripts.Runner import RebootListener
import tarfile

ROBOT_PATH = '/home/ute/Auto5G/'


class CITExecutor():
    def __init__(self, stream, workspace, regression_type='CIT', skip_features=None,
                 dryrun='false', recovery_reboot='false'):
        self.stream = stream
        self.workspace = workspace
        self.regression_type = regression_type
        self.feature_data_parser = FeatureDataParser(skip_features, self.workspace)
        self.test_executor = RobotExecutor(self.stream, regression_type, self.workspace,
                                           dryrun, recovery_reboot)
        self.features = self.get_features()

    def execute(self):
        self.execute_testcase_for_features()

    def get_features(self):
        return self.feature_data_parser.get_features(self.stream,
                                                     self.regression_type)

    def execute_testcase_for_features(self):
        self.test_executor.execute(self.features)
        return


class RobotExecutor():
    def __init__(self, stream, regression_type, workspace, dryrun, recovery_reboot):
        self.stream = stream
        self.regression_type = regression_type
        self.host = Host(workspace)
        self.log_path = self._get_log_path(workspace)
        self.dryrun = True if dryrun == 'true' else False
        self.recovery_reboot = True if recovery_reboot == 'true' else recovery_reboot
        self.run_type_variable = 'RUN_TYPE:{}'.format(stream)
        self.variables = [self.run_type_variable]
        self.exclude_tags = ['SKIP', 'PR*']

    def _get_log_path(self, workspace):
        log_folder = self.regression_type + 'Logs'
        return os.path.join(workspace, log_folder)

    def _get_output_dir(self, feature_id):
        return os.path.join(self.log_path, feature_id)

    def execute(self, features):
        for feature in features:
            self.execute_suites_of_feature(feature)
        self.merge_robot_log(features)
        self.tar_logs(features)

    def execute_suites_of_feature(self, feature):
        output_dir = self._get_output_dir(feature.id)
        for suite in feature.suites_absolute_path:
            run(suite, loglevel='TRACE', consolecolors='ansi', critical=self.regression_type,
                outputdir=output_dir,
                dryrun=self.dryrun, exclude=self.exclude_tags,
                listener=RebootListener.RebootListener(self.recovery_reboot),
                debugfile=feature.debug_file,
                variable=self.variables,
                variablefile=self.host.tl_config_file)

    def merge_robot_log(self, features):
        name = '_'.join([self.stream, self.regression_type])
        features_output = glob.glob('{}/*/*.xml'.format(self.log_path))
        rebot(*features_output, critical=self.regression_type, output='output.xml', name=name)
        return

    def tar_logs(self, features):
        for feature in features:
            log_dir = self._get_output_dir(feature.id)
            output_file = '{}.tar.gz'.format(feature.id)
            self.make_tar(output_file, log_dir)
        return

    def make_tar(self, output_file, source_dir):
        with tarfile.open(output_file, "w:gz") as tar:
            tar.add(source_dir, arcname=os.path.basename(source_dir))
        return


class Host():
    HOST_LOCATION_MAPPING = {"2_16": "Wroclaw", "7_2": "Bangalore"}

    def __init__(self, workspace):
        self.workspace = workspace
        self.hostname = self.get_hostname()
        self.location = self.get_location()
        self.tl_config_file = self.get_tl_config_file()

    def get_hostname(self):
        hostname = subprocess.check_output("hostname", shell=True)
        hostname = hostname.strip()
        return hostname.replace("-", "_")

    def get_location(self):
        # hostname will be like 2_16_UTE5GCLASSICAL1561 location_code will be 2_16
        location_code = self.hostname.rsplit("_", 1)[0]
        return self.HOST_LOCATION_MAPPING[location_code]

    def get_tl_config_file(self):
        return os.path.join(ROBOT_PATH, 'config', self.location, self.hostname)


class FeatureDataParser():
    CIT_DATA_FILE = os.path.join(sys.path[0], 'cit_suites.yaml')

    def __init__(self, skip_features, workspace):
        self.stream = open(self.CIT_DATA_FILE, 'r')
        self.skip_features = skip_features.split(",") if skip_features else []
        self.feature_data = yaml.load(self.stream, Loader=yaml.FullLoader)
        self.workspace = workspace

    def get_features(self, stream, regression_type):
        feature_for_stream = self.feature_data[stream][regression_type]
        features = []
        for feature_id, feature_data in self.features_applicable(feature_for_stream):
            features.append(Feature(feature_id, regression_type, feature_data, self.workspace))
        return features

    def features_applicable(self, features_stream):
        # Feature name in yaml should be integer preceded like 1_5GC000795
        for feature_id, feature_data in sorted(features_stream.items(),
                                               key=lambda feature:
                                               int(feature[0].split('_')[0])):
            if feature_id not in self.skip_features:
                yield feature_id, feature_data


class Feature():

    def __init__(self, feature_id, regression_type, feature_data, workspace):
        self.id = feature_id
        self.regression_type = regression_type
        self.path = feature_data['Path']
        self.airphone_base_path = os.path.join(workspace, 'robotws5g/testsuite/AIRPHONE/')
        self.suites = feature_data['Suites']
        self.suites_absolute_path = self._get_suite_absolute_path()
        self.debug_file = self.id + '.log'
        self.output_dir = ''

    def _get_suite_absolute_path(self):
        return [os.path.join(self.airphone_base_path, self.regression_type,
                             self.path, suite_path) for suite_path in self.suites]


def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='Script to Execute CIT')
    parser.add_argument('--runtype', required=True, help='Run Type to be used for Regression.')
    parser.add_argument('--regression_type', required=True, help='CIT/CRT to be executed')
    parser.add_argument('--workspace', required=True, help='Workspace Path to store the Robot Logs')
    parser.add_argument('--skip_features', required=False, help='Skip Features not needed to run.')
    parser.add_argument('--dryrun', required=False, default='false',
                        help='Execute testcases in Robot Framework Dryrun mode.')
    parser.add_argument('--recovery_reboot', required=False, default='false',
                        help='Recover the AP and GNB by rebooting on hitting error.')
    args = parser.parse_args()
    return args


def main(args):
    cit_executor = CITExecutor(args.runtype, args.workspace, args.regression_type,
                               args.skip_features,
                               args.dryrun, args.recovery_reboot)
    cit_executor.execute()
    return


if __name__ == "__main__":
    args = get_args()
    main(args)
