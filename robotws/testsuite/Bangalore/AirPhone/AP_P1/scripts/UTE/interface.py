import os
import subprocess
import yaml
from agent_runner import AgentInstaller
from custom_config_builder import CustomConfigBuilder
try:
    from pathlib import Path
except ImportError:
    os.system('pip install pathlib')
    from pathlib import Path
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru


ROBOTWS_ROOT_PATH = str(Path(__file__).resolve().parents[6])


class AgentInterface():
    def __init__(self, topology, gnb_build, ap_build, head_flag, variant, force_install, yaml_file='',
                 custom_config_p1=None):
        self.topology = topology
        self.gnb_build = gnb_build
        self.ap_build = ap_build
        self.head_flag = head_flag
        self.variant = variant
        self.force_install = force_install
        self.feature_yaml_file = yaml_file
        self.custom_config_p1 = custom_config_p1

    def get_config_files_for_bringup(self):
        """If Head flag is True It will download the config files from master else it will proceed with agent custom
            config files """
        try:
            force_custom_config = os.environ.get("FORCE_CUSTOM_CONFIG", "false")
            print("Force custom var value :", force_custom_config)
            if force_custom_config.lower() == "true":
                yaml_file = os.path.join(ROBOTWS_ROOT_PATH, self.feature_yaml_file)
                yaml_file_fh = open(yaml_file, 'r')
                feature_data = yaml.load(yaml_file_fh, Loader=yaml.FullLoader)
                test_suite = os.environ.get("SUITES", "")
                if test_suite != "":
                    config_file = feature_data["FS_TDD_NSA"]["P1_Feature"][test_suite].get("Custom_Config", "false")
                    self.head_flag = config_file
                    print("Custom config used : ", self.head_flag)
        except Exception as e:
            print("Trying to get the custom config operation failed with exception ", repr(e))
        if "testsuite" in self.head_flag or "config" in self.head_flag:
            custom_config_path = os.path.join(ROBOTWS_ROOT_PATH, self.head_flag)
        elif self.head_flag.lower() != "false":
            custom_config = CustomConfigBuilder(self.topology, self.gnb_build, self.ap_build, self.variant,
                                                self.head_flag)
            custom_config_path = custom_config.build_custom_config_folder()
        else:
            custom_config_path = ''
        installer = AgentInstaller(self.topology, self.gnb_build, self.ap_build, custom_config_path, self.variant,
                                   self.force_install, self.custom_config_p1)
        rc = installer.install()
        if rc > 0:
            loguru.logger.error("Installation failed!!!")
        return rc


def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='To execute agent sim installation with custom configuration support')
    parser.add_argument('--topology', required=True, help='Topology to use with Agent.')
    parser.add_argument('--gnb_build', required=True, help='GNB Build to be used with Agent.')
    parser.add_argument('--ap_build', required=False, help='AP Build to be used with Agent.')
    parser.add_argument('--head', required=False,
                        help='true if the config files need to be picked from master. '
                             'custom_path if we want to give a custom path. false if we'
                             'want agent to pick the files')
    parser.add_argument('--variant', required=False, default=None, help='Specify the variant name')
    parser.add_argument('--force_install', required=False, default=None, help='config load without CA install')
    parser.add_argument('--feature_yaml', required=False, default=None, help='feature yaml file path')
    parser.add_argument('--custom_config_p1', required=False, default=None, help='custom config file path')
    args = parser.parse_args()
    return args


def main(args):
    agent = AgentInterface(args.topology, args.gnb_build, args.ap_build, args.head, args.variant,
                           args.force_install, args.feature_yaml, args.custom_config_p1)
    rc = agent.get_config_files_for_bringup()
    return rc


if __name__ == "__main__":
    import sys
    args = get_args()
    return_code = main(args)
    sys.exit(return_code)
