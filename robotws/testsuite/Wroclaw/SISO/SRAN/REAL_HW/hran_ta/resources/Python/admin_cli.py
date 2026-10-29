import logging
import os
import subprocess
import requests
import json
import xml.etree.ElementTree as ET
import re
import shutil

api_key = 'AKCp8pQH3kiEZTWFo45FwbG5KEcVjNmU99bucUfxV33JhaEGZ81wVMsj6oRdM48DLBJjfXrw5'


class admin_cli:
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self.api_key = None
        self.admin_cli_dir = ''
        self.admin_cli_dir_rad = ''
        self.bts_host = None
        self.bts_username = 'Nemuadmin'
        self.bts_password = 'nemuuser'
        self.bts_port = 443
        self.output_format = 'human'
        self.remove_zip = True
        self.rad_auth = 'Basic Y2FfcHp0c3JhdXQ6dGVzdF9hdXRvbWF0aW9uX3RlYW1fMDE='

    def setup_admin_cli(self, sw_basename, ip, key=api_key, user=None, password=None, port=None, output_format=None,
                        admin_dir='/home/ute/admin_cli', remove_zip_file=True):
        try:
            self.bts_host = ip
            self.api_key = key
            if user:
                self.bts_username = user
            if password:
                self.bts_password = password
            if port:
                self.bts_port = port
            if output_format:
                self.output_format = output_format
            if remove_zip_file:
                self.remove_zip = remove_zip_file
            if "9999" in sw_basename or "9990" in sw_basename:
                _, version = sw_basename.split('_', 1)
                sw_basename = "SBTS00_" + version
            if not os.path.exists(admin_dir):
                os.mkdir(admin_dir)
            if self._check_admin_cli('{}/{}_ADMIN_CLI'.format(admin_dir, sw_basename)):
                self.admin_cli_dir = os.path.join(admin_dir, '{}_ADMIN_CLI'.format(sw_basename))
                logging.info("Admin CLI already exists at: {}.".format(self.admin_cli_dir))
                return self.admin_cli_dir
            self.admin_cli_dir = self._create_admin_cli_baseline_dir(admin_dir, sw_basename)
            admin_cli_path_zip = self._get_admin_cli(sw_basename, self.get_release(sw_basename), self.admin_cli_dir)
            self._extract_zip(admin_cli_path_zip, self.admin_cli_dir)
            if remove_zip_file:
                self._remove_zip(admin_cli_path_zip + '.zip')
        except OSError as e:
            logging.info(e)
        return admin_cli_path_zip

    def setup_admin_cli_rad(self, sw_basename, ip, key, user=None, password=None, port=None, output_format=None,
                            admin_dir='/home/ute/admin_cli', remove_zip_file=True):
        self.setup_admin_cli(sw_basename=sw_basename, ip=ip, key=key, user=user, password=password, port=port,
                             output_format=output_format, admin_dir=admin_dir, remove_zip_file=remove_zip_file)

        latest_zip = self._get_latest_admin_cli_rad()
        if self._check_admin_cli('{}/{}_ADMIN_CLI_RAD'.format(admin_dir, latest_zip.strip('.zip'))):
            self.admin_cli_dir_rad = os.path.join(admin_dir, '{}_ADMIN_CLI_RAD'.format(latest_zip.strip('.zip')))
            logging.info('Admin CLI R&D already exists.')
            return
        version = self.download_admin_cli_rad(latest_zip, admin_dir)
        self.admin_cli_dir_rad = os.path.join(admin_dir, version)
        self._extract_zip(self.admin_cli_dir_rad + '.zip', self.admin_cli_dir_rad)
        self.copy_bundle_file_from_admin_cli_to_rad(self.admin_cli_dir, self.admin_cli_dir_rad)
        if remove_zip_file:
            self._remove_zip(self.admin_cli_dir_rad + '.zip')

    def send_admin_cli_request(self, request_data, output_file=None, return_value=None, input_file=None,
                               output_json=None, admin_cli_path=None):
        if admin_cli_path:
            admin_cli_path = self._get_admin_cli_sh(self.admin_cli_dir_rad)
        else:
            admin_cli_path = self._get_admin_cli_sh(self.admin_cli_dir)
        if not self._check_admin_cli(admin_cli_path):
            self.rise_cli_not_found_error()

        debug_path = os.path.join(admin_cli_path.strip('admin-cli.sh'), 'cli_logs.txt')

        script_args = [
            "--bts-username={}".format(self.bts_username),
            "--bts-password={}".format(self.bts_password),
            "--debug={}".format(debug_path),
            "--bts-host={}".format(self.bts_host),
            "--bts-port={}".format(self.bts_port),
            "--format={}".format(self.output_format),
            "--data={}".format(request_data),
        ]
        if output_file:
            script_args.append("--output-file={}".format(output_file))
        if return_value:
            script_args.append("--return_value={}".format(return_value))
        if input_file:
            script_args.append("--input-file={}".format(input_file))
        if output_json:
            script_args.append("--output-json={}".format(output_json))
        return self._get_json_from_response(self._send_request(admin_cli_path, script_args))

    def send_admin_cli_request_rad(self, request_data, output_file=None, return_value=None,
                                   input_file=None, output_json=None):
        return self.send_admin_cli_request(request_data=request_data, output_file=output_file,
                                           return_value=return_value, input_file=input_file,
                                           output_json=output_json, admin_cli_path=self.admin_cli_dir_rad)

    @staticmethod
    def _send_request(cli_path, script_args):
        logging.info('SEND: {}'.format(script_args))
        cli = subprocess.run([cli_path] + script_args, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
        cli_decoded = cli.stdout.decode("utf-8")
        cli_decoded = cli_decoded.replace('CLI LOG:  ADMIN CLI sign out', '') \
            .replace('CLI LOG:  Flush and exit', '') \
            .replace('CLI LOG:  CLI 3.2.1-rd started with node v18.19.0', '') \
            .replace('CLI LOG:  CLI 3.2.1-client started with node v18.19.0', '') \
            .replace('CLI LOG:  WEBEM CLI TOOL Starts login', '') \
            .replace('CLI LOG:  WEBEM CLI TOOL get login.bundle.js successfully', '') \
            .replace('CLI LOG:  WEBEM CLI TOOL get bundle.js successfully', '') \
            .replace('CLI LOG:  Run as cli client mode', '') \
            .replace('CLI LOG:  Fetching the resource by "post".', '') \
            .replace('CLI LOG:  Cleaning up...', '') \
            .replace('Login response: ', '').strip()
        logging.info('RESPONSE: {}'.format(cli_decoded))
        return cli_decoded

    @staticmethod
    def _get_json_from_response(response):
        return json.loads(response.split("CLI LOG:")[-1])

    @staticmethod
    def _create_admin_cli_baseline_dir(admin_cli_location, sw_baseline):
        admin_baseline_dir = os.path.join(admin_cli_location, sw_baseline + '_ADMIN_CLI')
        os.mkdir(admin_baseline_dir)
        return admin_baseline_dir

    def _get_admin_cli(self, sw_basename, release, save_dir):
        download_link = f'https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local' \
                        f'/build/{release}/{sw_basename}/{sw_basename}_ADMIN_CLI.zip'
        with open('{}/{}_ADMIN_CLI.zip'.format(save_dir, sw_basename), 'wb') as admin_file:
            header = {'X-JFrog-Art-Api': self.api_key}
            with requests.get(download_link, headers=header, stream=True) as admin_zip:
                if admin_zip.iter_content():
                    admin_file.write(admin_zip.content)
        logging.info('{}_ADMIN_CLI.zip downloaded!'.format(sw_basename))
        return os.path.join(save_dir, '{}_ADMIN_CLI'.format(sw_basename))

    def _get_latest_admin_cli_rad(self):
        admin_cli_rad_link = 'https://wrscmi.inside.nsn.com/isource/svnroot/BTS_D_SC_ADMIN_CLI/'
        header = {'Authorization': self.rad_auth}
        tree = ET.fromstring(requests.get(admin_cli_rad_link, headers=header).text)
        admin_cli_list = [i.attrib.get('name') for i in tree.findall('*/file')]
        admin_cli_rad_list = []
        for admin in admin_cli_list:
            pattern = re.compile(r'admin-cli-\d.\d*.\d*.zip')
            if pattern.match(admin):
                admin_cli_rad_list.append(admin)
        latest_admin_cli_rad = admin_cli_rad_list[-1]
        return latest_admin_cli_rad

    def download_admin_cli_rad(self, latest_admin_cli_rad, save_dir):
        admin_cli_rad_link = 'https://wrscmi.inside.nsn.com/isource/svnroot/BTS_D_SC_ADMIN_CLI/'
        header = {'Authorization': self.rad_auth}
        logging.info('Downloading Admin CLI R&D: {}'.format(latest_admin_cli_rad))
        admin_rad_version = latest_admin_cli_rad.strip('.zip')
        with open('{}/{}_ADMIN_CLI_RAD.zip'.format(save_dir, admin_rad_version), 'wb') as admin_file:
            download_cli = admin_cli_rad_link + latest_admin_cli_rad
            with requests.get(download_cli, headers=header, stream=True) as admin_zip:
                if admin_zip.iter_content():
                    admin_file.write(admin_zip.content)
        logging.info('{} downloaded!'.format(latest_admin_cli_rad))
        return admin_rad_version + '_ADMIN_CLI_RAD'

    def _extract_zip(self, admin_cli_zip, unzip_dir):
        os.popen('unzip {} -d {}'.format(admin_cli_zip, unzip_dir)).read()
        # does not make files executable
        # with zipfile.ZipFile(admin_cli_zip, 'r') as zip_ref:
        #    zip_ref.extractall(path_to_extract)
        logging.info('Admin CLI extracted at: {}'.format(unzip_dir))
        if self._check_admin_cli(self._get_admin_cli_sh(unzip_dir)):
            logging.info('Successfully unzip of admin-cli.sh')
        else:
            raise self.rise_cli_sh_not_found_error()

    @staticmethod
    def copy_bundle_file_from_admin_cli_to_rad(admin_cli_path, admin_rad_path):
        logging.info('Copying main.bundle.js file from {} to {}.'.format(admin_cli_path, admin_rad_path))
        bundle_source = os.path.join(admin_cli_path, 'bundle.js')
        bundle_dest = os.path.join(admin_rad_path, 'bundle.js')
        shutil.copy(bundle_source, bundle_dest)

    @staticmethod
    def _remove_zip(admin_cli_zip):
        os.popen('rm {}'.format(admin_cli_zip))
        logging.info('{} removed!'.format(admin_cli_zip))

    @staticmethod
    def _get_admin_cli_sh(baseline_dir):
        return os.path.join(baseline_dir, 'admin-cli.sh')

    @staticmethod
    def _check_admin_cli(admin_cli_dir):
        return os.path.exists(admin_cli_dir)

    @staticmethod
    def get_release(build):
        return build.split("_")[0]

    @staticmethod
    def rise_cli_not_found_error():
        class AdminCLINotFound(Exception):
            logging.error('Setup admin CLI first.')

        raise AdminCLINotFound()

    @staticmethod
    def rise_cli_sh_not_found_error():
        class AdminClIShNotFound(Exception):
            logging.error('"admin-cli.sh" not found in desired location.')

        raise AdminClIShNotFound()
