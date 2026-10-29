import logging
import subprocess
import urllib
import os
import zipfile
import time
import json
from datetime import datetime
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException
from taf.selenium.gnb.oam.core.webdrivers import CustomWebDriverFirefox
from taf.gnb.oam.coam.admin import admin as coam_admin
from taf.rfrl.bts.devices.generic_bts import GenericBts, login_logout
from robot.errors import KeywordError

default_wait = 10
login_username_xpath = '//input[@id="login-username"]'
login_password_xpath = '//input[@id="login-password"]'
login_button_xpath = "//button/span[contains(text(),'Login')]"
modal_confirm_button_xpath = "//div[@class='ui-modal']//button[contains(text(),'Confirm')]"
runtime_container_xpath = "//div[@class='runtime-view-container']"
diagnostics_menu_xpath = "//span[@ui-tooltip='Diagnostic']"
snapshot_button_xpath = "//span[text()='Snapshot']"
collect_button_xpath = "//button[contains(text(),'Collect')]"
snapshot_collecting_status_xpath = "//label[contains(@class,'status-info') and contains(text(),'Collecting')]"
current_trunk_branch = "22R1"
admin_local_path = "/home/ute/ADMIN/"


class LoginGuiMeasurements:
    ROBOT_LIBRARY_SCOPE = "TEST CASE"

    def __init__(self):
        self.driver = None

    def open_browser(self, download_dir='/tmp/'):
        """
        Opens firefox browser window with CustomWebDriver configuration
        :param download_dir: default browser directory
        """
        self.driver = CustomWebDriverFirefox(download_dir=download_dir)

    def _wait_for_element(self, xpath, timeout):
        """
        Generic wait for element functions
        :param xpath: xpath of the element to wait for
        :param timeout: timeout on the xpath element search
        :return element: xpath element
        """
        element_presence = EC.presence_of_element_located((By.XPATH, xpath))
        return WebDriverWait(driver=self.driver, timeout=timeout).until(element_presence)

    def open_login_page(self, ip_address, page_timeout=5):
        """
        Enters WebEM application
        :param ip_address: WebEm mplane/LMP ip address
        :param page_timeout: timeout for the WebEm login page load
        :return datetime: WebEm login page load duration
        """
        start_timestamp = datetime.now()
        self.driver.get("https://{}".format(ip_address))
        self._wait_for_element(login_username_xpath, page_timeout)
        self._wait_for_element(login_password_xpath, page_timeout)
        duration = (datetime.now() - start_timestamp).total_seconds()
        logging.warn("Page loading took {}s".format(duration))
        return duration

    def login(self, username='Nemuadmin', password='nemuuser', modal_timeout=30, runtime_timeout=30):
        """
        Logs in to WebEM application when login screen is visible
        :param username: BTS https username
        :param password: BTS https password
        :param modal_timeout:  timeout for modal pop out to show
        :param runtime_timeout: timeout for runtime view to be available
        :return datetime: modal pop up view time, runtime view availability time
        """
        username_element = self.driver.find_element_by_xpath(login_username_xpath)
        username_element.send_keys(username)
        password_element = self.driver.find_element_by_xpath(login_password_xpath)
        password_element.send_keys(password)

        start_timestamp = datetime.now()
        self.driver.find_element_by_xpath(login_button_xpath).click()
        confirm_button = self._wait_for_element(modal_confirm_button_xpath, modal_timeout)
        modal_timestamp = datetime.now()

        confirm_button.click()
        self._wait_for_element(runtime_container_xpath, runtime_timeout)
        runtime_timestamp = datetime.now()

        modal_duration = (modal_timestamp - start_timestamp).total_seconds()
        runtime_duration = (runtime_timestamp - modal_timestamp).total_seconds()
        logging.warn("Modal displayed after {}s\nRuntime visible after: {}s".format(modal_duration,
                                                                                    runtime_duration))
        return modal_duration, runtime_duration

    def collect_snapshot(self):
        """
        Collects snapshot when in runtime view
        :return: None
        """
        self.driver.find_element_by_xpath(diagnostics_menu_xpath).click()
        self._wait_for_element(snapshot_button_xpath, default_wait).click()
        self._wait_for_element(collect_button_xpath, default_wait).click()
        self._wait_for_element(snapshot_collecting_status_xpath, default_wait)

    def get_webdriver_memory_consumption(self):
        """
        Retrieves firefox memory consumption in MB
        :return int: WebEm memory consumption in MB
        """
        ps = subprocess.Popen(('ps', '-ef'), stdout=subprocess.PIPE, shell=True)
        grep_1 = subprocess.Popen(('grep', 'firefox-esr'), stdin=ps.stdout, stdout=subprocess.PIPE)
        grep_2 = subprocess.Popen(('grep', '-v', '-i', 'grep'), stdin=grep_1.stdout, stdout=subprocess.PIPE)
        awk = subprocess.check_output(('awk', '{print $1}'), stdin=grep_2.stdout)
        memory = 0
        for pid in awk.split():
            output = subprocess.check_output(('ps', '-p', pid, '-ho', 'rss'))
            memory += int(output)
        return int(memory) / 1000

    def close_browser(self):
        """
        Closes currently opened browser
        :return: None
        """
        self.driver.close()


class AdminSessionsMeasurements:
    ROBOT_LIBRARY_SCOPE = "TEST CASE"

    def __init__(self):
        self.coam_admin = coam_admin()
        self.admin_sessions = []

    def establish_max_number_of_sessions(self, bts_ip_address, expected_max):
        """
        Establishes maximum expected sessions and expects error on the next one
        :param bts_ip_address: BTS LMP/m-plane address
        :param expected_max: maximum number of session allowed by BTS
        :return: None
        """
        for session_num in range(1, int(expected_max) + 1):
            connection_name = "connection_{}".format(session_num)
            logging.warn("Trying to establish Admin session with name {}".format(connection_name))
            self.coam_admin.connect_to(bts_host=bts_ip_address, name=connection_name)
            self.admin_sessions.append(connection_name)
            logging.warn("Current active EM sessions count: {}".format(self._get_active_sessions_count()))
        try:
            logging.warn("Trying to establish last session, error is expected")
            redundant_connection = "connection_{}".format(int(expected_max) + 1)
            self.coam_admin.connect_to(bts_host=bts_ip_address, name=redundant_connection)
            self.admin_sessions.append(redundant_connection)
            raise Exception("Established more sessions than expected")
        except AdminApiProcedureTimeoutException:
            logging.warn("Exception caught as expected, could not establish last session")

    def teardown_all_admin_sessions(self):
        """
        Cleanup function to tear down all created admin sessions
        :return: None
        """
        logging.warn("Active sessions count on teardown: {}".format(self._get_active_sessions_count()))
        for session in self.admin_sessions:
            self.coam_admin.teardown(connection=session)

    def _get_active_sessions_count(self):
        """
        Retrieves active sessions count, NOTE: can only be used when there is any connection established
        :return int: number of active EM sessions
        """
        sessions = self.coam_admin.check_link_status(connection=self.admin_sessions[0])
        return len([session for session in sessions if (session[u'stateInfo'][u'usageState'] == u'Active' and
                                                        session[u'type'] == u'EM')])


class AdminCliConnection(GenericBts):

    def __init__(self):
        super(AdminCliConnection, self).__init__(bts_type="GNB")
        self.connection_established = False
        self.admin_cli_connections = []
        self.data_retrieved = False

    def download_admin_package(self):
        """
        Downloads an ADMIN CLI package compatible to current BTS SW version
        :return: None
        """
        url = self._get_download_url()
        os.mkdir(admin_local_path)
        _file = admin_local_path + url.split('/')[-1]
        if os.path.isfile(_file):
            return _file
        logging.warn("Downloading {url} to {path}".format(url=url, path=_file))
        urllib.urlretrieve(url, _file)
        self._unzip_admin_cli(path=_file)
        subprocess.call(['chmod', '-R', '+x', admin_local_path])

    def _unzip_admin_cli(self, path):
        """
        Unzips the file at the desired path location
        :param path: path to unpacked files
        :return: None
        """
        with zipfile.ZipFile(path, 'r') as zip_ref:
            zip_ref.extractall(admin_local_path)

    @login_logout
    def _get_download_url(self, bts_id=0, du_id=0):
        """
        Provides the URL of ADMIN CLI compatible to current SW version on BTS
        :param bts_id: int
        :param du_id: int
        :return: datetime stop_time: time at which string was found
        """
        sw_version = self.admin.get_software_info(connection=self.rest_alias.format(bts_id, du_id)).get(
            'Active SW version')
        admin_url = 'https://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/{branch}/{sw}_ADMIN_CLI.zip'
        admin_url = admin_url.format(branch=sw_version.split("_")[0].replace(current_trunk_branch, "00"),
                                     sw=sw_version.replace(current_trunk_branch, "00"))
        assert urllib.urlopen(admin_url).getcode() == 200, "Link not valid {}".format(admin_url)
        return admin_url

    def open_cli_connection_server_mode(self, mplane_ip, port="9001"):
        """
        Establishes a new admin cli connection in server mode
        :param mplane_ip: BTS m-plane ip address
        :param port: port on which connection is to be opened
        :return float: time within connection was established in seconds
        """
        cmd = ["--bts-username", "Nemuadmin",
               "--bts-password", "nemuuser",
               "--bts-host", mplane_ip,
               "--bts-port", "443",
               "--cli-port", port,
               "--secure", "false"]
        logging.info("Admin connection in server mode is to be established, check logs at /home/ute/"
                     "ADMIN/admin_log_{}.txt".format(port), "Starting time measuring now")
        start_timestamp = datetime.now()
        with open(admin_local_path + 'admin_log_{}.txt'.format(port), 'a') as output:
            output.truncate(0)
            self.admin_cli_connections.append(subprocess.Popen(executable=admin_local_path + "admin-cli.sh",
                                                               args=cmd, stdout=output, stderr=output, shell=True))
        stop_timestamp = self.verify_if_connection_established_server_mode(port=port, timeout=time.time() + 30)
        return (stop_timestamp - start_timestamp).total_seconds()

    def verify_if_connection_established_server_mode(self, port, timeout):
        """
        Verifies whether admin cli connection was established by output string in admin_log_${port}.txt containing
        "BTS Connected" logged when connection opened,
        :param port: port on which connection was established
        :param timeout: time within the connection should be established
        :return: datetime: time at which string "BTS connected" was found
        """
        admin_logs_path = admin_local_path + 'admin_log_{}.txt'.format(port)
        while not self.connection_established:
            # with open(admin_logs_path) as admin_logs:
            #     for index, line in enumerate(admin_logs):
            #         if "BTS connected" in line:
            bts_connection_log = self.check_if_string_in_admin_logs(admin_logs_path, "BTS connected")
            if bts_connection_log:
                stop_timestamp = datetime.now()
                self.connection_established = True
                logging.info("Found string: {}".format(bts_connection_log))
            if time.time() > timeout:
                errors = self.check_if_string_in_admin_logs(admin_logs_path, "ERROR")
                raise AdminApiProcedureTimeoutException("Connection was not established with errors: "
                                                        "{}".format(errors))
        else:
            logging.warn("Connection on port {} established".format(port))
            self.connection_established = False
            return stop_timestamp

    def check_if_time_within_range(self, measurments, timeout):
        """
        Verifies whether admin cli connection was established within less than 30 seconds.
        :param measurments: time within the connection was established
        :param timeout: time within connection SHOULD be established
        :return: None
        """
        if measurments <= 0 or measurments > timeout:
            raise KeywordError("Connection establishment/request response took too long with time  {}"
                               .format(measurments))

    def kill_current_admin_cli(self):
        """
        Kills existing admin cli connections.
        :return: None
        """
        ps = subprocess.Popen(('ps', '-ef'), stdout=subprocess.PIPE)
        grep_1 = subprocess.Popen(('grep', 'ADMIN'), stdin=ps.stdout, stdout=subprocess.PIPE)
        grep_2 = subprocess.Popen(('grep', '-v', '-i', 'grep'), stdin=grep_1.stdout, stdout=subprocess.PIPE)
        awk = subprocess.check_output(('awk', '{print $2}'), stdin=grep_2.stdout)
        logging.warn("Process pids to kill: {}".format(', '.join(awk.split())))
        for pid in awk.split():
            subprocess.call(('kill', '-9', pid))

    def open_cli_connection_standalone_mode(self, mplane_ip):
        """
        Opens admin cli connection in standalone mode
        :param  mplane_ip: M-plane ip address of BTS
        :return: None
        """
        cmd = ["--bts-username", "Nemuadmin",
               "--bts-password", "nemuuser",
               "--bts-host", mplane_ip,
               "--bts-port", "443",
               "--secure", "true",
               "--data", '{"requestId":1,"parameters":{"name":"getActiveAlarms"}}',
               "--output-json", admin_local_path + "cli_request.json"]
        logging.info("Admin connection is to be established, check logs at /home/ute/ADMIN/admin_log_standalone.txt")
        with open(admin_local_path + 'admin_log_standalone.txt', 'a') as output:
            output.truncate(0)
            start_timestamp = datetime.now()
            subprocess.Popen(executable=admin_local_path + "admin-cli.sh", args=cmd,
                             stdout=output, stderr=output, shell=True).wait()
            logging.warn("Time measuring started at {}".format(start_timestamp))
            stop_timestamp = self.verify_connection_established_standalone_mode(timeout=time.time() + 20)
            return (stop_timestamp - start_timestamp).total_seconds()

    def verify_connection_established_standalone_mode(self, timeout):
        """
        Verifies wether admin cli connection in standalone mode was opened properly by checking the request response
        :param  timeout: timeout within the operation should succeed
        :return datetime: time at which requested data was retrieved
        """
        while not os.path.exists(admin_local_path + 'cli_request.json'):
            if time.time() > timeout:
                raise AdminApiProcedureTimeoutException("JSON file not created on time")
        else:
            with open(admin_local_path + 'cli_request.json', 'r+') as json_file:
                stop_timestamp = self.verify_data_retrieved(data=json.loads(json_file.read()), timeout=timeout)
                json_file.truncate(0)
                logging.warn("STOP time measured {}".format(stop_timestamp))
                return stop_timestamp

    def get_EMCLI_sessions_count(self, mplane_ip):
        """
        Retrieves active EMCLI sessions count, NOTE: can only be used when there is any connection established
        :return int: number of established EMCLI sessions
        """
        admin = coam_admin().connect_to(bts_host=mplane_ip, name="admin")
        sessions = admin.check_link_status()
        admin.teardown_admin()
        return len([session for session in sessions if (session[u'stateInfo'][u'usageState'] == u'Active' and
                                                        session[u'type'] == u'EMCLI')])

    def open_5_concurrent_admin_server_connections_expect_error_at_6th(self, mplane_ip, start_port=9000,
                                                                       end_port=9004):
        """
        Opens 5 ADMIN cli connections and verifies whether the 6th one fails due to number of sessions exceeded.
        :param mplane_ip: BTS m-plane ip address
        :param start_port: port on which 1st admin cli connection will be established
        :param end_port: port on which 5th admin cli connection will be established
        :return: None
        """
        number_of_sessions_exceeded = False
        for port in [item for item in range(start_port, end_port + 1)]:
            measures = self.open_cli_connection_server_mode(mplane_ip=mplane_ip, port=str(port))
            self.check_if_time_within_range(measurments=measures, timeout=30.0)
        current_cli_sessions = self.get_EMCLI_sessions_count(mplane_ip=mplane_ip)
        if current_cli_sessions == 5:
            try:
                self.open_cli_connection_server_mode(mplane_ip=mplane_ip, port=str(end_port + 1))
            except AdminApiProcedureTimeoutException:
                with open(admin_local_path + 'admin_log_{}.txt'.format(end_port + 1)) as admin_logs:
                    for index, line in enumerate(admin_logs):
                        if "Error: Number of sessions exceeded" in line:
                            logging.warn("Found string at index {}: {}".format(index, line.strip()))
                            number_of_sessions_exceeded = True
                            pass
            if not number_of_sessions_exceeded:
                raise Exception("No \"Error: Number of sessions exceeded\" found in logs")
        else:
            raise Exception("Less than 5 connections opened")

    def request_latency_server_mode(self, port="9008"):
        """
        Requests data from BTS through opened admin cli connection in server mode. NOTE that connection in server
        mode needs to be opened first
        :param port: port on which cli connection is opened
        :return float: time within cli request provided data
        """
        cmd = ["--cli-port", port,
               "--data", '{"requestId":1,"parameters":{"name":"getActiveAlarms"}}']
        logging.info("Check json logs at /home/ute/ADMIN/agent_log_{}.json".format(port))
        with open(admin_local_path + 'agent_log_{}.json'.format(port), 'a') as json_file:
            json_file.truncate(0)
            logging.info("Starting time measuring now")
            start_timestamp = datetime.now()
            agent_cli = subprocess.Popen(executable=admin_local_path + "/agent-cli/agent-cli.sh", args=cmd,
                                         stdout=subprocess.PIPE, stderr=json_file, shell=True)
            output = agent_cli.communicate()[0]
            stop_timestamp = self.verify_data_retrieved(json.loads(output), time.time() + 10)
            return (stop_timestamp - start_timestamp).total_seconds()

    def verify_data_retrieved(self, data, timeout):
        """
        Checks whether json file with retrieved data contains required data.
        :return datetime: time at which requested data was provided
        """
        while not self.data_retrieved:
            if data["requestMessage"] and data["requestStatus"] == "completed":
                self.data_retrieved = True
                data_retrieval_time = datetime.combine(datetime.now().date(),
                                                       datetime.strptime(data["time"], '%I:%M:%S %p').time())
            if time.time() > timeout:
                raise AdminApiProcedureTimeoutException
        else:
            logging.warn("Data retrieved successfully")
            self.data_retrieved = False
            return data_retrieval_time

    def check_if_string_in_admin_logs(self, logs_file_path, string):
        """
        Checks whether desired string was logged in admin cli logs
        :param logs_file_path: path to admin cli logs
        :param string: desired sting
        :return List: list of string occurrences found in logs
        """
        lines_found = []
        with open(logs_file_path) as admin_logs:
            for index, line in enumerate(admin_logs):
                if string in line:
                    lines_found.append("Line {}: {}".format(index, line.strip()))
        return lines_found
