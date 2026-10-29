import re
import subprocess
import os
import shutil
from enum import IntEnum
import yaml
try:
    import loguru
except ImportError:
    os.system('pip install loguru')
    import loguru
try:
    from tcp_latency import measure_latency
except ImportError:
    os.system('pip install tcp_latency')
    from tcp_latency import measure_latency


class Branch(IntEnum):
    gnb_build = 0


class CustomConfigBuilder():
    def __init__(self, topology, gnb_build, ap_build, variant, head_flag):
        self.topology = topology
        self.gnb_build = gnb_build
        self.ap_build = ap_build
        self.variant = variant
        self.head_flag = head_flag
        self.wget_cmd = 'wget --timeout=1 --waitretry=0 --tries=1 ' \
                        '"https://{server}/gerrit/gitweb?p=MN/UTE/topology-configs.git;' \
                        'a=blob_plain;f={file_url};hb={hb_path}" -O "{output_file}"'
        self.root_path = "/home/ute/custom_config/"
        self._get_branch()
        self.GERRIT_REPOS = [
                             "gerrit-hzsl2.int.net.nokia.com",
                             "gerrit-bhsl2.int.net.nokia.com",
                             "gerrit-fpsl1.int.net.nokia.com",
                             "gerrit-wrsl1.int.net.nokia.com",
                             "gerrit-essl2.int.net.nokia.com",
                             "gerrit-mn-essl1.int.net.nokia.com",
                            ]

    def get_best_server(self):
        _links = {link: measure_latency(host=link) for link in self.GERRIT_REPOS}
        _links = {key: value for key, value in _links.items() if value}
        self.servers = list(dict(sorted(_links.items(), key=lambda item: item[1])).keys())
        print('servers', self.servers)
        return self.servers

    def build_custom_config_folder(self):
        """Builds custom config folder with AP, GNB and WTS config files"""
        self.get_best_server()
        if self.head_flag.lower() == 'true':
            self.hb_tag = 'HEAD'
        else:
            self.hb_tag = self.head_flag
        shutil.rmtree(self.root_path, ignore_errors=True)
        config_yaml_path = self._download_config_yaml()
        self.config_output_filenames = self.parse_config_yaml(config_yaml_path, self.variant)
        self.output_file_path = self._create_custom_config_directory(self.variant)
        print('output_file_path', self.output_file_path)
        self._get_custom_config_files()
        return self.root_path

    def _get_custom_config_files(self):
        """Downloads custom config files using wget commad for each component"""
        self.file_variant_name = self._frame_file_variant_name()
        for component, config_output_files in self.config_output_filenames.items():
            if self.head_flag.lower() == 'false':
                self.get_hb_tag_when_head_flag_is_false(component)
            for output_filetype, output_filename in config_output_files.items():
                self.file_path = '/'.join([self.file_variant_name, output_filename])
                self.output_file = self.root_path + '/' + output_filename
                self._frame_execute_wget_command(self.file_path, self.output_file)
        return

    def get_hb_tag_when_head_flag_is_false(self, component=''):
        if 'sm' in component:
            self.hb_tag = "refs/tags/{}".format(self.gnb_build)
        elif 'sim' in component or 'vm' in component:
            self.hb_tag = "refs/tags/{}".format(self.ap_build)
        else:
            self.hb_tag = 'HEAD'

    def _execute_wget_command(self, wget_cmd):
        """Executes wget command to download custom config files from testconfigs gerrit repo"""
        retries = 1
        while retries < 3:
            try:
                if retries == 2 and self.head_flag.lower() == 'false':
                    loguru.logger.info('INFO:Retrying download of files from HEAD')
                    wget_cmd = wget_cmd.replace('hb={}'.format(self.hb_tag), 'hb=HEAD')
                    loguru.logger.info('Retry wget_cmd', wget_cmd)
                subprocess.check_call(wget_cmd, shell=True)
                loguru.logger.info('successfully downloaded file using {}'.format(wget_cmd))
                return 0
                break
            except subprocess.CalledProcessError as exc:
                loguru.logger.info('wget command failed {}'.format(exc.cmd))
                retries += 1
                continue
            return 1

    def _frame_execute_wget_command(self, file_path, output_file):
        """frames wget command by replacing file path,hb_tag and output file path for each component
        and corresponding branch"""
        file_path = file_path.replace('+', '%2B')
        for server in self.servers:
            wget_cmd = self.wget_cmd.format(server=server, file_url=file_path, hb_path=self.hb_tag,
                                            output_file=output_file)
            ret_code = self._execute_wget_command(wget_cmd)
            if ret_code == 0:
                break
            else:
                continue
        return

    def _get_branch(self):
        """fetches branch from the gnb_build input using regex"""
        if '5G' in self.gnb_build:
            branch_matches = re.match(r"5G[a-zA-Z0-9]+?_(\w+.\w+).(\w+)", self.gnb_build).groups()
            self.branch = branch_matches[Branch.gnb_build]
        elif 'SBTS' in self.gnb_build:
            branch_matches = re.match(r"(\w+)_ENB_\w+", self.gnb_build).groups()
            self.branch = branch_matches[Branch.gnb_build]
        return

    def _create_custom_config_directory(self, variant=''):
        """Creates empty custom config folder if not exists which is the output directory path"""
        custom_config_path = os.path.join(self.root_path, variant)
        if not os.path.exists(custom_config_path):
            os.makedirs(os.path.join(custom_config_path))
        return custom_config_path

    def _frame_file_variant_name(self):
        """frames file variant name  Eg:ASIB_ABIL_FDD_CPRI_cmwv_NSA_FS"""
        file_variant_name = '/'.join([self.topology,
                                      self.branch])
        return file_variant_name

    def _download_config_yaml(self):
        self._create_custom_config_directory()
        config_yaml_url = f"{self.topology}/{self.branch}/config.yaml"
        config_yaml_path = f"{self.root_path}/config.yaml"
        if self.head_flag.lower() == 'false':
            self.get_hb_tag_when_head_flag_is_false()
            sim_config_yaml_path = f"{self.root_path}/sim_config.yaml"
            self._frame_execute_wget_command(file_path=config_yaml_url, output_file=sim_config_yaml_path)
        self._frame_execute_wget_command(file_path=config_yaml_url, output_file=config_yaml_path)
        return config_yaml_path

    def parse_config_yaml(self, file_name, variant_name):
        with open(file_name, 'r') as stream:
            try:
                files_list = None
                yaml_data = yaml.load(stream, Loader=yaml.FullLoader)
                for each_varient in yaml_data['variants']:
                    if variant_name and each_varient['name'] == variant_name.strip():
                        files_list = self.get_file_paths(each_varient)
                    elif (variant_name is None) and (each_varient['default'] is True):
                        files_list = self.get_file_paths(each_varient)

                if not files_list:
                    raise Exception("No matching config found with varient name and no config is set default:true")
                return files_list
            except yaml.YAMLError as exc:
                print(exc)

    def get_file_paths(self, variants):
        config_output_filenames = {}
        sm_files_dict, sim_files_dict, vm_files_dict = dict(), dict(), dict()
        for each_node_id in variants['nodes']:
            for each_file in each_node_id['files']:
                if each_file['hw_type'] == 'sm':
                    sm_files_dict[each_file['file_type']] = each_file['file_path']
                    config_output_filenames[each_file['hw_type']] = sm_files_dict
                elif each_file['hw_type'] == 'sim':
                    sim_files_dict[each_file['file_type']] = each_file['file_path']
                    config_output_filenames[each_file['hw_type']] = sim_files_dict
                elif each_file['hw_type'] == 'vm':
                    vm_files_dict[each_file['file_type']] = each_file['file_path']
                    config_output_filenames[each_file['hw_type']] = vm_files_dict
        print('config_output_filenames', config_output_filenames)
        return config_output_filenames


def get_args():
    import argparse
    parser = argparse.ArgumentParser(description='To create custom config using custom AP and GNB Build.')
    parser.add_argument('--topology', required=True, help='Topology to use with Agent.')
    parser.add_argument('--gnb_build', required=False, help='GNB Build to be used with Agent.')
    parser.add_argument('--ap_build', required=False, help='AP Build to be used with Agent.')
    parser.add_argument('--variant', required=False, default="", help='Specify the variant name')
    parser.add_argument('--head_flag', required=False, help='head flag to be used')
    args = parser.parse_args()
    return args


def main(args):
    custom_config = CustomConfigBuilder(args.topology, args.gnb_build, args.ap_build, args.variant, args.head_flag)
    custom_config_path = custom_config.build_custom_config_folder()
    return custom_config_path


if __name__ == "__main__":
    import sys
    args = get_args()
    main(args)
    sys.exit()
