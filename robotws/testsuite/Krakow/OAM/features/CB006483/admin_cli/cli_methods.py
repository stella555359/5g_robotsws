"""
ADMIN CLI class

:copyright: Nokia Networks
:author: Swies  Wioleta
:contact: wioleta.swies@nokia.com
"""
import os
import zipfile
from taf.rfrl.utilities import tl_config
from robot.api import logger
import subprocess
import re
import json
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)


class AdminCli:
    _AMIN_CLI_FILE = 'ADMIN_CLI.zip'
    _ADMIN_CLI_SH = 'admin-cli.sh'

    def __init__(self, sw_version, admin_cli_path=None, bts_type='GNB'):
        self.lterel_link = 'https://artifactory-espoo2.int.net.nokia.com/artifactory/' \
                           'mn-cosi-sran-central-public-local/build/'
        self.execute_admin_cli = self.get_admin_cli(sw_version) if not admin_cli_path else admin_cli_path
        self.bts_type = bts_type
        self.port = tl.gnbs[0].cu.oam_http_connection_details.port

    def get_admin_cli(self, sw_version, local_path='/tmp'):
        """
        Prepare admin_cli.sh if not pass local_path, download ADMIN_CLI.zip file and return path to the shell file.
        @param sw_version: software version of gnb/du
        @param local_path: path where admin-cli.sh file is stored
        @return:
        """
        if not os.path.exists(os.path.join(local_path, sw_version, self._ADMIN_CLI_SH)):
            return self.download_admin_cli_package(sw_version=sw_version, local_path=local_path)
        return os.path.join(local_path, sw_version, self._ADMIN_CLI_SH)

    def download_admin_cli_package(self, sw_version, local_path):
        """
        Download, unzip and set rights for admin-cli.sh file
        @param sw_version:
        @param local_path:
        @return: path to admin_cli file
        """
        release = sw_version.split('_')[0]
        file_name = '{}_{}'.format(sw_version, self._AMIN_CLI_FILE)
        build_path = os.path.join(self.lterel_link, release, sw_version, file_name)
        wget_cmd = ['wget', '-P', str(local_path), str(build_path)]
        logger.debug('Downloading admin cli: {}'.format(' '.join(wget_cmd)))
        proc = subprocess.Popen(wget_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise Exception('Software package has not been downloaded.\n STDERR: {}\n RETURN_CODE: {}'.
                            format(err, proc.returncode))
        path_to_admin_cli = os.path.join(local_path, sw_version, self._ADMIN_CLI_SH)
        return self.unzip_file(sw_version, local_path, path_to_admin_cli)

    def unzip_file(self, sw_version, local_path, path_to_admin_cli):
        """
        Unzip ADMIN_CLI.zip file and set rights
        @param sw_version:
        @param local_path:
        @param path_to_admin_cli:
        @return:
        """
        file_name = '{}_{}'.format(sw_version, self._AMIN_CLI_FILE)
        with zipfile.ZipFile(os.path.join(local_path, file_name), 'r') as zip_ref:
            zip_ref.extractall(os.path.join(local_path, sw_version))
            if os.path.exists(path_to_admin_cli):
                self.chmod(sw_version, local_path)
                return path_to_admin_cli
            raise Exception('File not exist')

    def chmod(self, sw_version, local_path, permission=777):
        admin_cli_path = os.path.join(local_path, sw_version)
        os.system('chmod {} {}'.format(permission, os.path.join(admin_cli_path, self._ADMIN_CLI_SH)))
        os.system('chmod {} {}'.format(permission, os.path.join(admin_cli_path, 'node/linux/bin/node')))
        os.system('chmod {} {}'.format(permission, os.path.join(admin_cli_path, 'agent-cli/agent-cli.sh')))
        os.system('chmod {} {}'.format(permission, os.path.join(admin_cli_path, 'agent-cli/node/linux/bin/node')))

    def create_connection_data(self, bts_id=0, du_id=0):
        """
        Create connection data as a parameter for admin-cli.sh
        @param bts_id:
        @param du_id:
        @return: (str) connection data
        """
        credentials = tl_config.get_web_credentials_for_du(bts_id=bts_id, du_id=du_id, bts_type=self.bts_type)
        conn = '--bts-username {} --bts-password {} --bts-host {} --bts-port {} --format human'.format(
            credentials['username'], credentials['password'], credentials['ip'], self.port)
        logger.debug('Connection data {}'.format(conn))
        return conn

    def get_command_result(self, data, output_file=None):
        """
        Execute command using admin-cli.sh file and data
        @param data: parameter to set
        @param output_file:
        @return: (str) Output file if was passed else None
        """
        data = '--data {}'.format(self.prepare_data_to_send(data))
        output = '--output-file {}'.format(output_file) if output_file else ''
        cmd = '{} {} {} {}'.format(self.execute_admin_cli, self.create_connection_data(), data, output)
        logger.debug('Send command: {}'.format(cmd))
        result = subprocess.Popen([cmd], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
        return self.check_output_result(result)

    @staticmethod
    def prepare_data_to_send(data):
        """
        Prepare data to send
        @param data:
        @return: double encoding data
        """
        return json.dumps(json.dumps(data))

    def check_output_result(self, result):
        """
        Check command result
        @param result:
        @return:
        """
        statuses = self.prepare_readable_output(result)
        reverse_status = reversed(statuses)
        for status in reverse_status:
            if status['requestStatus'] == 'completed':
                output_file_name = status.get('outputFileName', None)
                logger.info('Commend finished successful')
                return output_file_name
            elif status['requestStatus'] == 'failed':
                if 'License not available' in status['requestMessage']:
                    raise Exception('ActCli parameter should be set on TRUE. {}'.format(status['requestMessage']))
                raise Exception('Commend finished fail. {}'.format(status['requestMessage']))

    @staticmethod
    def prepare_readable_output(result):
        """
        Create data in readable format
        @param result:
        @return: dict with parameters (eg. time, result, message)
        """
        out, err = result.communicate()
        logger.debug(out.decode("utf-8"))
        status_results = re.search(r'CLI\sLOG:\s+{\s+[\"\w:\s,\S}]+}', out.decode("utf-8"))
        if status_results:
            match = status_results.group(0)
            cli_log = re.split(r'CLI\sLOG:\s+', match)
            result_list = [json.loads(line) for line in cli_log if line and 'client' not in line]
            logger.debug('Result: {}'.format(result_list))
            return result_list
        raise Exception('Could not parse the oputput: \n {}'.format(out))
