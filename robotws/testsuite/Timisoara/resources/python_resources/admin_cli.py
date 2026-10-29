import logging
import os
import subprocess
import signal
import time
import requests
import json
import xml.etree.ElementTree as ET
import re
import shutil


class admin_cli:
    ROBOT_LIBRARY_SCOPE = 'TEST CASE'

    def __init__(self):
        self.admin_cli_dir = ''
        self.admin_cli_dir_rad = ''
        self.bts_host = None
        self.bts_username = 'Nemuadmin'
        self.bts_password = 'nemuuser'
        self.bts_port = 443
        self.output_format = 'human'
        self.remove_zip = True
        self.rad_auth = 'Basic Y2FfcHp0c3JhdXQ6dGVzdF9hdXRvbWF0aW9uX3RlYW1fMDE='
        self.cli_host = '127.0.0.1'
        self.cli_port = 9001
        self.server_process = None

    def setup_admin_cli(self, sw_basename, ip, user=None, password=None, port=None, output_format=None,
                        admin_dir='/home/ute/admin_cli', remove_zip_file=True):
        try:
            self.bts_host = ip
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
            if self._check_admin_cli(f'{admin_dir}/{sw_basename}_ADMIN_CLI'):
                self.admin_cli_dir = os.path.join(admin_dir, f'{sw_basename}_ADMIN_CLI')
                logging.info(f"Admin CLI already exists at: {self.admin_cli_dir}.")
                return self.admin_cli_dir
            self.admin_cli_dir = self._create_admin_cli_baseline_dir(admin_dir, sw_basename)
            admin_cli_path_zip = self._get_admin_cli(sw_basename, self.get_release(sw_basename), self.admin_cli_dir)
            self._extract_zip(admin_cli_path_zip, self.admin_cli_dir)
            if remove_zip_file:
                self._remove_zip(admin_cli_path_zip + '.zip')
        except OSError as e:
            logging.info(e)
        return self.admin_cli_dir

    def setup_admin_cli_rad(self, sw_basename, ip, user=None, password=None, port=None, output_format=None,
                            admin_dir='/home/ute/admin_cli', remove_zip_file=True):
        self.setup_admin_cli(sw_basename=sw_basename, ip=ip, user=user, password=password, port=port,
                             output_format=output_format, admin_dir=admin_dir, remove_zip_file=remove_zip_file)

        latest_zip = self._get_latest_admin_cli_rad()
        if self._check_admin_cli(f'{admin_dir}/{latest_zip.strip(".zip")}_ADMIN_CLI_RAD'):
            self.admin_cli_dir_rad = os.path.join(admin_dir, f'{latest_zip.strip(".zip")}_ADMIN_CLI_RAD')
            logging.info('Admin CLI R&D already exists.')
            return
        version = self.download_admin_cli_rad(latest_zip, admin_dir)
        self.admin_cli_dir_rad = os.path.join(admin_dir, version)
        self._extract_zip(self.admin_cli_dir_rad + '.zip', self.admin_cli_dir_rad)
        self.copy_bundle_file_from_admin_cli_to_rad(self.admin_cli_dir, self.admin_cli_dir_rad)
        if remove_zip_file:
            self._remove_zip(self.admin_cli_dir_rad + '.zip')

    def send_admin_cli_request(self, request_data, output_file=None, return_value=None, input_file=None,
                               output_json=None, admin_cli_path=None, is_rad=False):
        if admin_cli_path:
            admin_cli_path = self._get_admin_cli_sh(self.admin_cli_dir_rad)
        else:
            admin_cli_path = self._get_admin_cli_sh(self.admin_cli_dir)
        if not self._check_admin_cli(admin_cli_path):
            self.rise_cli_not_found_error()

        debug_path = os.path.join(admin_cli_path.strip('admin-cli.sh'), 'cli_logs.txt')

        script_args = [
            f"--bts-username={self.bts_username}",
            f"--bts-password={self.bts_password}",
            f"--debug={debug_path}",
            f"--bts-host={self.bts_host}",
            f"--bts-port={self.bts_port}",
            f"--format={self.output_format}",
            f"--data={request_data}",
        ]
        if output_file:
            script_args.append(f"--output-file={output_file}")
        if return_value:
            script_args.append(f"--return_value={return_value}")
        if input_file:
            script_args.append(f"--input-file={input_file}")
        if output_json:
            script_args.append(f"--output-json={output_json}")
        if output_json:  # if output is redirected to json file it will not be available in the cmd output.
            return self._send_request(admin_cli_path, script_args)
        else:
            return self._get_json_from_response(self._send_request(admin_cli_path, script_args), is_rad)

    def send_admin_cli_request_rad(self, request_data, output_file=None, return_value=None,
                                   input_file=None, output_json=None):
        return self.send_admin_cli_request(request_data=request_data, output_file=output_file,
                                           return_value=return_value, input_file=input_file,
                                           output_json=output_json, admin_cli_path=self.admin_cli_dir_rad,
                                           is_rad=True)

    def setup_admin_cli_server_mode(self, sw_basename, ip, user=None, password=None, port=None,
                                    admin_dir='/home/ute/admin_cli', admin_cli_path=None, cli_host=None, cli_port=None,
                                    output_format=None, remove_zip_file=True, timeout_server_startup=10):
        """Set up Admin CLI and start it in server mode.

        Downloads/extracts Admin CLI if needed and starts the admin-cli server process.

        Args:
            sw_basename (str): Software baseline name (e.g. SBTS00_...)
            ip (str): BTS host IP address.
            user (str, optional): BTS username override. Default value is 'Nemuadmin'.
            password (str, optional): BTS password override. Default value is 'nemuuser'.
            port (int, optional): BTS port override. Default value is 443.
            admin_dir (str, optional): Admin CLI base directory. Default value is '/home/ute/admin_cli'.
            admin_cli_path (str, optional): Explicit path to admin-cli.sh. Default value is None, which means the path
                                            will be determined based on admin_dir and sw_basename.
            cli_host (str, optional): CLI server host override. Default value is '127.0.0.1'.
            cli_port (int, optional): CLI server port override. Default value is 9001.
            output_format (str, optional): Output format for CLI responses. Default value is 'json'.
            remove_zip_file (bool, optional): Remove downloaded ZIP after extraction. Default value is True.
            timeout_server_startup (int, optional): Timeout in seconds to wait for
                                            'BTS connected' in server output. Default value is 10 seconds.
        Returns:
            str: Startup response from the server process.
        """
        admin_cli_dir = self.setup_admin_cli(sw_basename=sw_basename, ip=ip, user=user, password=password, port=port,
                                             output_format=output_format, admin_dir=admin_dir,
                                             remove_zip_file=remove_zip_file)
        if cli_host:
            self.cli_host = cli_host
        if cli_port:
            self.cli_port = cli_port
        if not admin_cli_path:
            admin_cli_path = self._get_admin_cli_sh(admin_cli_dir)
        if not self._check_admin_cli(admin_cli_path):
            self.rise_cli_not_found_error()
        response = self.start_admin_cli_server_mode(admin_cli_path=admin_cli_path,
                                                    timeout_server_startup=timeout_server_startup)

        return response

    def start_admin_cli_server_mode(self, admin_cli_path=None, timeout_server_startup=10):
        """Start Admin CLI in server mode.

        Args:
            admin_cli_path (str, optional): Path to admin-cli.sh. If None, it means the path
                                            will be determined based on admin_dir and sw_basename.
            timeout_for_server_startup (int, optional): Timeout in seconds to wait for
                'BTS connected' in server output. Default value is 10 seconds.
        Returns:
            str: Startup response from the server process.
        """
        debug_path = os.path.join(admin_cli_path.strip('admin-cli.sh'), 'cli_logs.txt')

        script_args = [
            f"--bts-username={self.bts_username}",
            f"--bts-password={self.bts_password}",
            f"--debug={debug_path}",
            f"--bts-host={self.bts_host}",
            f"--bts-port={self.bts_port}",
            f"--cli-host={self.cli_host}",
            f"--cli-port={self.cli_port}",
            f"--format={self.output_format}",
        ]
        server_response, server_popen_object = self._send_request_server(admin_cli_path, script_args,
                                                                         timeout_server_startup=timeout_server_startup)
        self.server_process = server_popen_object
        return server_response

    def send_admin_cli_request_to_server(self, request_data, server_input_file=None, agent_cli_path=None):
        """Send a request to an already running Admin CLI server.

        Args:
            request_data (str): CLI request payload.
            server_input_file (str, optional): Path to input file for CLI request.
            agent_cli_path (str, optional): Explicit path to agent-cli.sh. If None, it is
                resolved from the Admin CLI directory.
        Returns:
            list | None: Parsed JSON response list from the server, or None on failure.
        """
        if not agent_cli_path:
            agent_cli_path = self._get_admin_cli_agent_sh(self.admin_cli_dir)

        if not self._check_admin_cli(agent_cli_path):
            self.rise_cli_not_found_error()

        script_args = [
            f"--data={request_data}",
            f"--cli-host={self.cli_host}",
            f"--cli-port={self.cli_port}",
            f"--format={self.output_format}",
        ]
        if server_input_file:
            script_args.append(f"--server-input-file={server_input_file}")
        try:
            response_from_server = self._send_request(agent_cli_path, script_args, server_mode=True)
            # check return code from tuple response
            if response_from_server[1] != 0 or 'CLI ERROR' in response_from_server[0]:
                self.rise_cli_request_to_server_error(response_from_server[0])
            response_from_server_json = json.loads('[' + response_from_server[0].replace('}\n{', '},{') + ']')
            logging.info(f'Response from admin CLI server: {response_from_server_json}')
            return response_from_server_json
        except Exception as e:
            logging.info(f'Error while sending request to admin CLI server: {e}')
            return None

    def teardown_admin_cli_server_mode(self):
        """Stop the Admin CLI server process if it is running."""
        if self.server_process:
            try:
                logging.info('Teardown admin CLI server mode.')
                os.killpg(self.server_process.pid, signal.SIGTERM)
                self.server_process.wait(timeout=2)
            except subprocess.TimeoutExpired:
                try:
                    os.killpg(self.server_process.pid, signal.SIGKILL)
                    self.server_process.wait(timeout=2)
                except Exception as e:
                    logging.info(f'Error while force-killing admin CLI server process: {e}')
            except Exception as e:
                logging.info(f'Error while terminating admin CLI server process: {e}')

    def _send_request_server(self, cli_path, script_args, timeout_server_startup=10, poll_interval=3):
        logging.info(f'SEND: {cli_path} {script_args}')
        popen_kwargs = dict(stderr=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        popen_kwargs['start_new_session'] = True

        cli_response = subprocess.Popen([cli_path] + script_args, **popen_kwargs)
        combined_output = ''
        deadline = time.time() + timeout_server_startup

        while True:
            remaining = deadline - time.time()
            if remaining <= 0:
                logging.info('Timeout expired while waiting for admin CLI server to start.')
                break
            try:
                output, _ = cli_response.communicate(timeout=min(poll_interval, remaining))
                combined_output = ''.join(str(output))
                if 'BTS connected' in str(output):
                    return combined_output, cli_response
            except subprocess.TimeoutExpired as exc:
                combined_output = ''.join(str(exc.output))
                logging.info(f'exc ... {combined_output}')
                if 'BTS connected' in str(combined_output):
                    return combined_output, cli_response
        self.server_process = cli_response
        self.rise_cli_request_to_server_error(combined_output)

    @staticmethod
    def _send_request(cli_path, script_args, server_mode=False):
        logging.info(f'SEND: {script_args}')
        cli = subprocess.run([cli_path] + script_args, stderr=subprocess.STDOUT, stdout=subprocess.PIPE)
        cli_decoded = cli.stdout.decode("utf-8")
        logging.info(f'RESPONSE: {cli_decoded}')
        return cli_decoded if not server_mode else (cli_decoded, cli.returncode)

    @staticmethod
    def _get_json_from_response(response, is_rad=False):
        # -2 is needed to get the second to last line. Last line is 'CLI LOG:  Cleaning up...'.
        # -4 is used for R&D admin CLI responses.
        split_index = -4 if is_rad else -2
        return json.loads(response.split("CLI LOG:")[split_index])

    @staticmethod
    def _create_admin_cli_baseline_dir(admin_cli_location, sw_baseline):
        admin_baseline_dir = os.path.join(admin_cli_location, sw_baseline + '_ADMIN_CLI')
        os.mkdir(admin_baseline_dir)
        return admin_baseline_dir

    def _get_admin_cli(self, sw_basename, release, save_dir):
        download_link = f'https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local' \
                        f'/build/{release}/{sw_basename}/{sw_basename}_ADMIN_CLI.zip'
        with open(f'{save_dir}/{sw_basename}_ADMIN_CLI.zip', 'wb') as admin_file:
            with requests.get(download_link, stream=True) as admin_zip:
                if admin_zip.iter_content():
                    admin_file.write(admin_zip.content)
        logging.info(f'{sw_basename}_ADMIN_CLI.zip downloaded!')
        return os.path.join(save_dir, f'{sw_basename}_ADMIN_CLI')

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
        logging.info(f'Downloading Admin CLI R&D: {latest_admin_cli_rad}')
        admin_rad_version = latest_admin_cli_rad.strip('.zip')
        with open(f'{save_dir}/{admin_rad_version}_ADMIN_CLI_RAD.zip', 'wb') as admin_file:
            download_cli = admin_cli_rad_link + latest_admin_cli_rad
            with requests.get(download_cli, headers=header, stream=True) as admin_zip:
                if admin_zip.iter_content():
                    admin_file.write(admin_zip.content)
        logging.info(f'{latest_admin_cli_rad} downloaded!')
        return admin_rad_version + '_ADMIN_CLI_RAD'

    def _extract_zip(self, admin_cli_zip, unzip_dir):
        os.popen(f'unzip {admin_cli_zip} -d {unzip_dir}').read()
        # does not make files executable
        # with zipfile.ZipFile(admin_cli_zip, 'r') as zip_ref:
        #    zip_ref.extractall(path_to_extract)
        logging.info(f'Admin CLI extracted at: {unzip_dir}')
        if self._check_admin_cli(self._get_admin_cli_sh(unzip_dir)):
            logging.info('Successfully unzip of admin-cli.sh')
        else:
            raise self.rise_cli_sh_not_found_error()

    @staticmethod
    def copy_bundle_file_from_admin_cli_to_rad(admin_cli_path, admin_rad_path):
        logging.info(f'Copying main.bundle.js file from {admin_cli_path} to {admin_rad_path}.')
        bundle_source = os.path.join(admin_cli_path, 'bundle.js')
        bundle_dest = os.path.join(admin_rad_path, 'bundle.js')
        shutil.copy(bundle_source, bundle_dest)

    @staticmethod
    def _remove_zip(admin_cli_zip):
        os.popen(f'rm {admin_cli_zip}')
        logging.info(f'{admin_cli_zip} removed!')

    @staticmethod
    def _get_admin_cli_sh(baseline_dir):
        return os.path.join(baseline_dir, 'admin-cli.sh')

    @staticmethod
    def _get_admin_cli_agent_sh(baseline_dir):
        return os.path.join(baseline_dir, 'agent-cli/agent-cli.sh')

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

    @staticmethod
    def rise_server_not_started_error():
        class AdminCLIServerNotStarted(Exception):
            logging.error('Admin CLI server did not start properly')

        raise AdminCLIServerNotStarted()

    @staticmethod
    def rise_cli_request_to_server_error(msg):
        class AdminCLIServerRequestError(Exception):
            logging.error('Admin CLI request to server failed {}'.format(msg))

        raise AdminCLIServerRequestError()
