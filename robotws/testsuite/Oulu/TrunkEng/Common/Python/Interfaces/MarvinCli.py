"""
:author: Pekka Lonnakko
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

This module provides a class for interacting with Marvin server.
* Modify the constants according to your environment.
Check comments on the code for common solution.

Usage of this class is demonstrated in the following example:
Library          path.to.MarvinCli.Marvin  WITH NAME  Marvin
Run Keyword And Ignore Error  MarvinCli.Prepare And Start Marvin  Site_Reset_Marvin_Test
     ...                           ref_run_id=9cd3353a-e20f-4d1b-b958-fd9c991785f8
     ...                           ref_case_id=1c55f790-af2e-4f78-8029-4144ad833afd
Run Keyword And Ignore Error  MarvinCli.Stop Marvin  fetch_snapshot=${True}

"""

import json
from subprocess import check_output, CalledProcessError
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info

rat_templates = {
    'lte_case': ["case_common", "case_4G"],
    'nr_case': ["case_common", "case_5G"],
    'lte_run': ["run_common", "run_4G"],
    'nr_run': ["run_common", "run_5G"]
}


class MarvinCli:

    bts_id = ""
    data_collector_order = 0
    data_collector_test_run_id = ""
    analysis_group_case_id = ""
    analysis_group_run_id = ""
    data_collector_test_case_id = ""
    data_collector_timestamp = ""
    data_collector_test_total_id = ""
    tc0_id = ""
    rat_list = []
    marvin_folder = ""
    common_templates = ""
    organization = ""
    marvin_side = ""
    elastic_data_collectors = ""
    data_collector_output_file = ""
    docker_side = ""
    data_collector_meta_host = ""
    data_collector_ae_host = ""
    marvin_client = None
    print_marvin_link = False
    test_cases = {}
    create_test_cases = False
    MarvinClientException = None

    def __init__(self):
        self.admin = admin()  # Use this as common solution

    def _init_setups(self, marvin_folder="/home/ute/marvin",
                     common_templates="/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/"
                                      "Marvin_templates",
                     organization="TV_Trunk_Oul1",
                     marvin_side="prod",
                     print_marvin_link=False,
                     create_test_cases=False):
        MarvinCli.marvin_folder = marvin_folder
        MarvinCli.common_templates = common_templates
        MarvinCli.organization = organization
        MarvinCli.marvin_side = marvin_side
        MarvinCli.elastic_data_collectors = f"python {marvin_folder}/elastic_data_collectors.py"
        MarvinCli.data_collector_output_file = f"{marvin_folder}/data_collector_identifiers.env"
        MarvinCli.docker_side = "classic_prod" if "prod" in marvin_side else "classic_dev"
        MarvinCli.print_marvin_link = print_marvin_link
        MarvinCli.data_collector_meta_host = "meta-service.marvin.ou.nsn-rdnet.net" if "prod" in marvin_side \
            else "meta-service-dev.marvin.ou.nsn-rdnet.net"
        MarvinCli.data_collector_ae_host = "rsp-analysis-engine.ou.nsn-rdnet.net" if "prod" in marvin_side \
            else "dev-engine.analysis.dyn.nesc.nokia.net"
        MarvinCli.create_test_cases = create_test_cases
        if self.organization == "TV_Trunk_Oul1":
            self.bts = BuiltIn().get_library_instance("BTS")  # TV_Trunk_Oul1 specific solution
            self.logger = BuiltIn().get_library_instance("LOG")  # TV_Trunk_Oul1 specific solution for debugging

    def _create_random_uuid(self):
        return self.check_output_with_retries(f"cat /proc/sys/kernel/random/uuid", decode=True)

    def _import_analysis(self, templates):
        paths = []
        paths_str = ""
        for template in templates:
            paths.append(f"{self.common_templates}/{template}")
            paths_str = ",".join(paths)
        if MarvinCli.data_collector_test_case_id:
            self._print_marvin("Creating pm-drops")
            self.check_output_with_retries(f"{self.marvin_folder}/aecli-linux-amd64 analysis create-pm-drops --metahost"
                                           f" '{self.data_collector_meta_host}' --folder '{paths_str}' "
                                           f"--case-id '{MarvinCli.data_collector_test_case_id}'")
        self._print_marvin(f"Importing analysis: {paths_str}")
        return self.check_output_with_retries(f"{self.marvin_folder}/aecli-linux-amd64 --host "
                                              f"{self.data_collector_ae_host} analysis import --include '{paths_str}' "
                                              f"-n '{self.organization}' --plain", decode=True)

    def create_test_run(self):
        self._print_marvin("Creating test run")
        # Templates to be used in the case. Might need some automation to identify RAT
        MarvinCli.data_collector_test_run_id = self._create_random_uuid()
        MarvinCli.data_collector_test_total_id = self._create_random_uuid()
        test_line = {
            "status": ["Production"],
            "organization": [self.organization],
            "test_type": ["CRT"]
        }
        MarvinCli.marvin_client.test_control.update_test_line(MarvinCli.bts_id, test_line)
        MarvinCli.tc0_id = self._create_random_uuid()
        test_run = {
            "id": MarvinCli.data_collector_test_run_id,
            "test_type": ["CRT"],
            "organization": [self.organization],
            "exec_status": "Not started",
            "bts": {
                "id": MarvinCli.bts_id
            },
            "test_cases": [
                {
                    "id": MarvinCli.tc0_id,
                    "name": "Environment_setup",
                    "exec_order": "0",
                    "test_steps": [
                        {"id": "1", "name": "Environment Preparation"},
                        {"id": "2", "name": "BTS SW update"},
                        {"id": "3", "name": "Traffic simulation"},
                        {"id": "4", "name": "Logs collect"},
                        {"id": "5", "name": "Process Logs"}
                    ]
                }]
        }
        MarvinCli.marvin_client.test_control.create_test_run(MarvinCli.bts_id, test_run)
        MarvinCli.analysis_group_run_id = self._import_analysis(rat_templates[MarvinCli.rat_list[0] + "_run"])
        MarvinCli.data_collector_timestamp = self.check_output_with_retries(f"date +'%Y-%m-%dT%H:%M:%S.%6NZ' -u",
                                                                            decode=True)
        # Create test in Elastic
        self.check_output_with_retries(f"{self.elastic_data_collectors} --create --host localhost --test-run-id "
                                       f"{MarvinCli.data_collector_test_run_id} --timestamp "
                                       f"{MarvinCli.data_collector_timestamp} "
                                       f"--output-file {self.data_collector_output_file}")

        if MarvinCli.print_marvin_link:
            marvin_link = "https://marvin-dev.ou.nsn-rdnet.net/analyse?curId=" if MarvinCli.marvin_side == "dev" \
                else "https://marvin.ou.nsn-rdnet.net/analyse?curId="
            self._print_marvin(f"Link to marvin run: {marvin_link}{MarvinCli.data_collector_test_run_id}")

    def create_test_case(self, test_case_name):
        """
        Creates a test case in Marvin and imports the analysis templates.
        :param str test_case_name: Name of the test case to be created.
        """
        self._print_marvin("Creating test case")
        MarvinCli.data_collector_test_case_id = self._create_random_uuid()
        MarvinCli.data_collector_order += 1
        if MarvinCli.create_test_cases:
            MarvinCli.test_cases[test_case_name] = MarvinCli.data_collector_test_case_id
        test_case = {
            "id": MarvinCli.data_collector_test_case_id,
            "name": test_case_name,
            "comment": self.organization,
            "exec_order": MarvinCli.data_collector_order,
        }
        MarvinCli.marvin_client.test_control.create_test_case(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                              test_case)
        MarvinCli.analysis_group_case_id = self._import_analysis(rat_templates[MarvinCli.rat_list[0] + "_case"])

    @staticmethod
    def start_and_stop_init_test_steps():
        MarvinCli.marvin_client.test_control.start_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             MarvinCli.tc0_id, "1")
        MarvinCli.marvin_client.test_control.stop_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            MarvinCli.tc0_id, "1", verdict="Passed")
        MarvinCli.marvin_client.test_control.start_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             MarvinCli.tc0_id, "2")
        MarvinCli.marvin_client.test_control.stop_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            MarvinCli.tc0_id, "2", verdict="Passed")
        MarvinCli.marvin_client.test_control.start_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             MarvinCli.tc0_id, "3")
        MarvinCli.marvin_client.test_control.stop_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            MarvinCli.tc0_id, "3", verdict="Passed")
        MarvinCli.marvin_client.test_control.start_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             MarvinCli.tc0_id, "4")
        MarvinCli.marvin_client.test_control.stop_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            MarvinCli.tc0_id, "4", verdict="Passed")
        MarvinCli.marvin_client.test_control.start_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             MarvinCli.tc0_id, "5")
        MarvinCli.marvin_client.test_control.stop_test_step(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            MarvinCli.tc0_id, "5", verdict="Passed")

    def start_test_run(self, ref):
        self._print_marvin("Starting test run")
        reference_run_id = f" --reference-run-id {ref}" if ref else ""
        cmd = (f"{self.marvin_folder}/aecli-linux-amd64 --host {self.data_collector_ae_host} analysis execute"
               f" --runtime -a {MarvinCli.analysis_group_run_id}"
               f" --started-from 'RSP_Jenkins'"
               f" --run-id {MarvinCli.data_collector_test_run_id}"
               f" --bts-id {MarvinCli.bts_id}{reference_run_id}")
        self.check_output_with_retries(cmd)
        MarvinCli.marvin_client.test_control.start_test_run(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id)
        MarvinCli.marvin_client.test_control.start_test_case(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             MarvinCli.tc0_id)
        self.start_and_stop_init_test_steps()
        MarvinCli.marvin_client.test_control.stop_test_case(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            MarvinCli.tc0_id, exec_verdict="Passed")

    def start_test_case(self, test_case_name, ref=None, adapter_list=None):
        """
        Starts the test case and updates the verdict in Marvin.
        :param str test_case_name: Name of the test case to be started.
        :param str ref: Reference case ID for the test case. This is found from Marvin UI
        :param list adapter_list: Adapters for the test case. E.g. ["-cpu-mem"] disabeles cpu and memory checks.
        """
        self._print_marvin("Starting test case")
        test_case_id = MarvinCli.data_collector_test_case_id
        if MarvinCli.create_test_cases and MarvinCli.test_cases.get(test_case_name):
            test_case_id = MarvinCli.test_cases[test_case_name]
        reference_case_id = f" --reference-case-id {ref}" if ref else ""
        cmd = (f"{self.marvin_folder}/aecli-linux-amd64 --host {self.data_collector_ae_host} analysis execute"
               f" --runtime -a {self.analysis_group_case_id}"
               f" --started-from 'RSP_Jenkins'"
               f" --run-id {MarvinCli.data_collector_test_run_id}"
               f" --case-id {test_case_id}"
               f" --test-phase-name {test_case_name}"
               f" --bts-id {MarvinCli.bts_id}{reference_case_id}")
        self.check_output_with_retries(cmd)
        adapter_str = self._convert_adapters(adapter_list)
        meta = {"test_case": {"name": test_case_name}}
        meta_json = json.dumps(meta)
        cmd = (f"{self.elastic_data_collectors} --start --host localhost --test-run-id "
               f"{MarvinCli.data_collector_test_run_id}  --meta '{meta_json}' --test-case-id "
               f"{test_case_id} --output-file {self.data_collector_output_file}"
               f"{adapter_str}")
        self.check_output_with_retries(cmd)

        MarvinCli.marvin_client.test_control.start_test_case(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                             test_case_id)
        self.check_output_with_retries(f'echo "" >> {self.data_collector_output_file}')
        self.check_output_with_retries(f'echo "DATA_COLLECTOR_TEST_TOTAL_ID='
                                       f'{MarvinCli.data_collector_test_total_id}" >> '
                                       f'{self.data_collector_output_file}')

    def stop_test_case(self, verdict="Passed", test_case_name=""):
        """
        Stops the test case and updates the verdict in Marvin.
        :param str verdict: Verdict for the test case. Default is "Passed".
        :param str test_case_name: Needed if create_test_cases is initialized as True in prepare_and_start_marvin
        """
        self._print_marvin("Stopping test case")
        test_case_id = MarvinCli.data_collector_test_case_id
        if MarvinCli.create_test_cases and MarvinCli.test_cases.get(test_case_name):
            test_case_id = MarvinCli.test_cases[test_case_name]
        cmd = (f"{self.elastic_data_collectors} --stop --host localhost --test-run-id "
               f"{MarvinCli.data_collector_test_run_id}  --test-case-id "
               f"{test_case_id}")
        self.check_output_with_retries(cmd)
        verdict = self._check_verdict(verdict)
        MarvinCli.marvin_client.test_control.stop_test_case(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                            test_case_id, exec_verdict=verdict)

    def stop_test_run(self, verdict="Passed"):
        self._print_marvin("Stopping test run")
        cmd = (f"{self.elastic_data_collectors} --stop --host localhost --test-run-id "
               f"{MarvinCli.data_collector_test_run_id}")
        self.check_output_with_retries(cmd)
        verdict = self._check_verdict(verdict)
        MarvinCli.marvin_client.test_control.stop_test_run(MarvinCli.bts_id, MarvinCli.data_collector_test_run_id,
                                                           exec_verdict=verdict)

    def update_collectors(self):
        try:
            check_output(f"docker container ls -a | grep 'data_collector'", shell=True).decode().strip()
            self._print_marvin("Docker container is already running")
        except CalledProcessError as e:
            self._print_marvin("Updating collectors")
            self._print_marvin(f"Error: {e}\n{''.join(format_exception(type(e), e, e.__traceback__))}", debug=True)
            # needed until 8080 port is modifiable
            self.check_output_with_retries(f"sudo systemctl stop apache2.service")

            # marvin-cli
            self.check_output_with_retries(f"pip install --upgrade marvin-client "
                                           f"--index-url"
                                           f"=https://artifactory-espoo2.int.net.nokia.com/artifactory/api/pypi/"
                                           f"pypi-rsp-ta-local/simple")
            # Data collector
            self.check_output_with_retries(f"wget --no-proxy -T 10 -t 1 -P {self.marvin_folder} "
                                           r"https://rsp-ta-ci-file.es-si-s3-z2.eecloud.nsn-net.net/data-collector/"
                                           r"datacollector_scripts.zip")
            self.check_output_with_retries(f"unzip -o {self.marvin_folder}/datacollector_scripts.zip "
                                           f"-d {self.marvin_folder}  && "
                                           f"rm {self.marvin_folder}/datacollector_scripts.zip")
            # Start docker
            self.check_output_with_retries(f"{self.marvin_folder}/start_docker.sh --config-name={self.docker_side} "
                                           f"sudo=True")
            # AECLI
            self.check_output_with_retries(f"wget --no-proxy -T 10 -t 1 -P {self.marvin_folder} "
                                           f"{self.data_collector_ae_host}/cli/aecli-linux-amd64.gz")
            self.check_output_with_retries(f"gunzip -f {self.marvin_folder}/aecli-linux-amd64.gz")
            self.check_output_with_retries(f"chmod +x {self.marvin_folder}/aecli-linux-amd64")

    def import_marvin_client(self):
        try:
            from marvin_client import MarvinClient
            from marvin_client.exceptions import MarvinClientException
            MarvinCli.marvin_client = MarvinClient(environment="prod" if self.marvin_side == "prod" else "dev")
            MarvinCli.MarvinClientException = MarvinClientException
        except ImportError as e:
            self._print_marvin(f"Error: {e} when trying to import MarvinClient\n"
                               f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise ImportError(f"MarvinClient couldn't be installed. Please check logs.")

    def fetch_single_snapshot(self):
        self.check_output_with_retries(f"{self.marvin_folder}/snapshot_to_glusterfs.py --run-id "
                                       f"{MarvinCli.data_collector_test_run_id} --tags 'Test case end'")

    def collect_bts_id_via_admin(self):
        bts_id = ""
        connection = self.admin.connect_to(name='marvin')
        try:
            bts_info = connection.get_parameters_for_all("BTS")
            bts_id = bts_info[0]["btsId"]
        except IndexError as e:
            self._print_marvin(f"BTS ID not found\n"
                               f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            return ""
        finally:
            self.admin.teardown_admin(connection='marvin')
            return bts_id

    def check_rat(self):
        rat = []
        connection = self.admin.connect_to(name='marvin')
        try:
            bts_info = connection.get_bts_info()
            rat_state_dict = bts_info["ratState"]
            rat = [key for key, value in rat_state_dict.items() if value != "NO_CELLS"]
        except Exception as e:
            self._print_marvin(f"Error: {e} when trying to get RAT\n")
            self._print_marvin(f"Error: {e}\n{''.join(format_exception(type(e), e, e.__traceback__))}", debug=True)
            return []
        finally:
            self.admin.teardown_admin(connection='marvin')
            return rat

    def prepare_and_start_marvin(self, test_case_name="", ref_run_id="", ref_case_id="", only_test_run=False,
                                 adapter_list=None, marvin_folder="/home/ute/marvin",
                                 common_templates="/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/"
                                                  "Marvin_templates",
                                 organization="TV_Trunk_Oul1", marvin_side="prod", print_marvin_link=False,
                                 create_test_cases=False):
        """
        Prepares and starts Marvin server. This method initializes the Marvin environment, creates a test run, and
        starts the test case. It also handles the import of the Marvin client and updates the data collectors.
        The method takes care of the setup and teardown of the Marvin environment, including fetching snapshots and
        stopping the test run.
        :param str test_case_name: Name of the test case to be created and started.
        :param str ref_run_id: Reference run ID for the test run. This is found from Marvin UI
        :param str ref_case_id: Reference case ID for the test case. This is found from Marvin UI
        :param bool only_test_run: If True, only the test run is created and started, without starting the test case.
        :param list adapter_list: Adapters for the test case. E.g. ["-cpu-mem"] disabeles cpu and memory checks.
        :param str marvin_folder: Folder where Marvin is installed.
        :param str common_templates: Templates for Marvin.
        :param str organization: Organization name for the test run.
        :param str marvin_side: Side of the Marvin server (prod or dev).
        :param bool print_marvin_link: If True, prints the link to the Marvin run.
        :param bool create_test_cases: If True, all test cases are created beforehand. stop_test_case will need test
                                       case name as an argument
        """
        self._init_setups(marvin_folder, common_templates, organization, marvin_side, print_marvin_link,
                          create_test_cases)
        self._print_marvin("Starting Marvin")
        if self.organization == "TV_Trunk_Oul1":
            MarvinCli.bts_id = self.bts.get_parameter_value_from_bts_info('btsId')  # TV_Trunk_Oul1 specific solution
        else:
            MarvinCli.bts_id = self.collect_bts_id_via_admin()  # Use this as common solution
        MarvinCli.rat_list = self.check_rat()
        if MarvinCli.bts_id:
            self.update_collectors()
            self.import_marvin_client()
            try:
                self.create_test_run()
                self.start_test_run(ref=ref_run_id)
                if not only_test_run:
                    self.create_test_case(test_case_name)
                    self.start_test_case(test_case_name, ref=ref_case_id, adapter_list=adapter_list)
            except MarvinCli.MarvinClientException as e:
                self._print_marvin(f"Error: {e} when trying to start Marvin\n"
                                   f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        else:
            self._print_marvin("BTS id is not get. Can't start Marvin")

    def stop_marvin(self, fetch_snapshot=False, only_test_run=False, wait_after_run=True, verdict="Passed"):
        self._print_marvin("Stopping Marvin")
        if fetch_snapshot:
            self.fetch_single_snapshot()
        if not only_test_run:
            self.stop_test_case(verdict)
        self.stop_test_run(verdict)
        if wait_after_run:
            BuiltIn().sleep("20min", "Wait 20min after stopping Marvin for Marvin server to fetch all data")

    def create_test_case_and_start(self, test_case_name, ref_case_id="", adapter_list=None):
        self.create_test_case(test_case_name)
        self.start_test_case(test_case_name, ref=ref_case_id, adapter_list=adapter_list)

    def check_output_with_retries(self, cmd, decode=False):
        self._print_marvin(f"Sending command {cmd}", debug=False)
        for i in range(3):
            try:
                output = check_output(cmd, shell=True)
                self._print_marvin(f"Output: {output}", debug=False)
                return output.decode().strip() if decode else output
            except CalledProcessError as e:
                self._print_marvin(f"Error: {e} when trying to send command: {cmd}\n"
                                   f"{''.join(format_exception(type(e), e, e.__traceback__))}\n"
                                   f"Output: {e.output}")
            if i < 2:
                BuiltIn().sleep("5s", "Wait 5s before retrying")
        return None

    def _print_marvin(self, msg, debug=False):
        msg = f"Marvin: {msg}"
        if self.organization == "TV_Trunk_Oul1":
            if debug:
                self.logger.debug(msg)
            else:
                info(msg)
        else:
            print(msg)

    def _check_verdict(self, verdict):
        if isinstance(verdict, bool):
            if verdict:
                return "Passed"
            else:
                return "Failed"
        elif isinstance(verdict, str):
            if "pass" in verdict.lower():
                return "Passed"
            elif "fail" in verdict.lower():
                return "Failed"
            return None
        else:
            self._print_marvin(f"Verdict {verdict} is not valid. Use 'Passed' or 'Failed' or boolean")
            return "Passed"

    def _convert_adapters(self, adapter_list):
        """
        Convert a list of adapter items to a string with the format:
        "defaults item1 item2 ...".

        :param list adapter_list: List of adapter items.
        :return: Formatted string.
        :rtype: str
        """
        if not adapter_list:
            return ""
        if isinstance(adapter_list, list):
            return ' --adapter-list="defaults ' + ' '.join(adapter_list) + '"'
        elif isinstance(adapter_list, str):
            # In case a string is passed, return it as is
            return f' --adapter-list="{adapter_list}"'
        else:
            self._print_marvin(f"Invalid adapter_list type: {type(adapter_list)}")
            return ""
