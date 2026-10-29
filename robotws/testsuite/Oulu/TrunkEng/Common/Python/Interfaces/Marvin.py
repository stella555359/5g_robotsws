"""
:author: Pekka Lonnakko
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com

This module provides a class for interacting with Marvin server.
* Modify the constants according to your environment.
Check comments on the code for common solution.

Usage of this class is demonstrated in the following example:
Library          path.to.Marvin.Marvin  WITH NAME  Marvin
Run Keyword And Ignore Error  Marvin.Prepare And Start Marvin  Site_Reset_Marvin_Test
     ...                           ref_run_id=9cd3353a-e20f-4d1b-b958-fd9c991785f8
     ...                           ref_case_id=1c55f790-af2e-4f78-8029-4144ad833afd
Run Keyword And Ignore Error  Marvin.Stop Marvin  fetch_snapshot=${True}

"""

import json
from subprocess import check_output, CalledProcessError
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info

# Modify the following constants according to your environment
MARVIN_FOLDER = "/home/ute/marvin"
COMMON_TEMPLATES = f"/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/Marvin_templates"
ORGANIZATION = "TV_Trunk_Oul1"
DATA_COLLECTOR_AE_HOST = "rsp-analysis-engine.ou.nsn-rdnet.net"  # Dev: dev-engine.analysis.dyn.nesc.nokia.net
SUMMARY_VIEW_BACKEND_URL = "http://csv-be.marvin.ou.nsn-rdnet.net:8091"  # dev=csv-be-dev.marvin.ou.nsn-rdnet.net
DOCKER_SIDE = "classic_prod"  # dev=classic_dev

# Other constants
FORMATTER_APP = f"{MARVIN_FOLDER}/formatter.py"
ELASTIC_DATA_COLLECTORS = f"python {MARVIN_FOLDER}/elastic_data_collectors.py"
DATA_COLLECTOR_OUTPUT_FILE = f"{MARVIN_FOLDER}/data_collector_identifiers.env"
CONFIG_FOLDER = f"{MARVIN_FOLDER}/config"
TEST_LINE_JSON = f"{CONFIG_FOLDER}/01_test_line_json/test_line.json"
TEST_RUN_CREATION_TOTAL = f"{CONFIG_FOLDER}/02_test_run_creation_json/case_id_0.json"
TEST_RUN_CREATION_JSON = f"{CONFIG_FOLDER}/02_test_run_creation_json/test_run.json"
TEST_RUN_READY_TOTAL_JSON = f"{CONFIG_FOLDER}/03_test_run_ready_json/case_id_0.json"
TEST_RUN_READY_JSON = f"{CONFIG_FOLDER}/03_test_run_ready_json/test_run.json"

rat_templates = {
    'lte_case': ["case_common", "case_4G"],
    'nr_case': ["case_common", "case_5G"],
    'lte_run': ["run_common", "run_4G"],
    'nr_run': ["run_common", "run_5G"]
}


class Marvin:

    bts_id = ""
    data_collector_order = 0
    data_collector_test_run_id = ""
    analysis_group_case_id = ""
    analysis_group_run_id = ""
    data_collector_test_case_id = ""
    data_collector_timestamp = ""
    data_collector_test_total_id = ""
    cpu_mem_collection = True
    rat_list = []

    def __init__(self):
        self.admin = admin()  # Use this as common solution
        if ORGANIZATION == "TV_Trunk_Oul1":
            self.bts = BuiltIn().get_library_instance("BTS")  # TV_Trunk_Oul1 specific solution
            self.logger = BuiltIn().get_library_instance("LOG")  # TV_Trunk_Oul1 specific solution for debugging

    def _create_random_uuid(self):
        return self.check_output_with_retries(f"cat /proc/sys/kernel/random/uuid", decode=True)

    def _import_analysis(self, templates):
        paths = []
        paths_str = ""
        for template in templates:
            paths.append(f"{COMMON_TEMPLATES}/{template}")
            paths_str = ",".join(paths)
        self._print_marvin(f"Importing analysis: {paths_str}")
        return self.check_output_with_retries(f"{MARVIN_FOLDER}/aecli-linux-amd64 --host {DATA_COLLECTOR_AE_HOST} "
                                              f"analysis import --include '{paths_str}' -n '{ORGANIZATION}' --plain",
                                              decode=True)

    def _complete_case_summary(self, verdict="Passed"):
        verdict = self._check_verdict(verdict)
        test_run = {
            "test_phase": {
                "run_id": Marvin.data_collector_test_run_id,
                "case_id": Marvin.data_collector_test_case_id
            },
            "id": Marvin.data_collector_test_case_id,
            "exec_status": "Completed",
            "end_time": Marvin.data_collector_timestamp,
            "verdict": verdict
        }
        with open(f"{CONFIG_FOLDER}/03_test_run_ready_json/case_id_{Marvin.data_collector_order}.json", "w") as f:
            json.dump(test_run, f)
        self.check_output_with_retries(f"export SUMMARY_VIEW_BACKEND_URL='{SUMMARY_VIEW_BACKEND_URL}' && python "
                                       f"{FORMATTER_APP} --path '{CONFIG_FOLDER}/03_test_run_ready_json/' "
                                       f"--update --datatype 'testrun'")

    def _complete_summary(self, verdict="Passed"):
        verdict = self._check_verdict(verdict)
        test_run = {
            "test_phase": {"run_id": Marvin.data_collector_test_run_id},
            "test_run": {
                "id": Marvin.data_collector_test_run_id,
                "exec_status": "Completed",
                "end_time": Marvin.data_collector_timestamp,
                "verdict": verdict
            }
        }
        with open(TEST_RUN_READY_JSON, "w") as f:
            json.dump(test_run, f)
        test_total = {
            "test_phase": {
                "run_id": Marvin.data_collector_test_run_id,
                "case_id": Marvin.data_collector_test_total_id
            },
            "id": Marvin.data_collector_test_run_id,
            "test_steps": [
                {"id": "1", "name": "Environment Preparation", "exec_status": "Completed", "verdict": "Passed"},
                {"id": "4", "name": "Logs collect", "exec_status": "Completed", "verdict": "Passed"},
                {"id": "5", "name": "Process Logs", "exec_status": "Completed", "verdict": "Passed"}
            ]
        }
        with open(TEST_RUN_READY_TOTAL_JSON, "w") as f:
            json.dump(test_total, f)
        self.check_output_with_retries(f"export SUMMARY_VIEW_BACKEND_URL='{SUMMARY_VIEW_BACKEND_URL}' && python "
                                       f"{FORMATTER_APP} --path '{CONFIG_FOLDER}/03_test_run_ready_json/' "
                                       f"--update --datatype 'testrun'")

    def _update_summary(self):
        test_run = {
            "test_phase": {"run_id": Marvin.data_collector_test_run_id},
            "test_run": {
                "id": Marvin.data_collector_test_run_id,
                "exec_status": "Ongoing",
                "start_time": Marvin.data_collector_timestamp,
            }
        }
        with open(TEST_RUN_READY_JSON, "w") as f:
            json.dump(test_run, f)
        test_total = {
            "test_phase": {
                "run_id": Marvin.data_collector_test_run_id,
                "case_id": Marvin.data_collector_test_total_id
            },
            "id": Marvin.data_collector_test_run_id,
            "test_steps": [
                {"id": "1", "name": "Environment Preparation", "exec_status": "Completed", "verdict": "Passed"},
                {"id": "4", "name": "Logs collect", "exec_status": "Ongoing"},
                {"id": "5", "name": "Process Logs", "exec_status": "Ongoing"}
            ]
        }
        with open(TEST_RUN_READY_TOTAL_JSON, "w") as f:
            json.dump(test_total, f)
        self.check_output_with_retries(f"export SUMMARY_VIEW_BACKEND_URL='{SUMMARY_VIEW_BACKEND_URL}' && python "
                                       f"{FORMATTER_APP} --path '{CONFIG_FOLDER}/02_test_run_creation_json/' "
                                       f"--update --datatype 'testrun'")

    def create_test_run(self):
        self._print_marvin("Creating test run")
        self.check_output_with_retries(f"rm -f {CONFIG_FOLDER}/02_test_run_creation_json/*.json")
        self.check_output_with_retries(f"rm -f {CONFIG_FOLDER}/03_test_run_ready_json/*.json")
        # Templates to be used in the case. Might need some automation to identify RAT
        Marvin.analysis_group_run_id = self._import_analysis(rat_templates[Marvin.rat_list[0] + "_run"])
        Marvin.data_collector_test_run_id = self._create_random_uuid()
        Marvin.data_collector_test_total_id = self._create_random_uuid()
        Marvin.data_collector_timestamp = self.check_output_with_retries(f"date +'%Y-%m-%dT%H:%M:%S.%6NZ' -u",
                                                                         decode=True)
        # Create test in Elastic
        self.check_output_with_retries(f"{ELASTIC_DATA_COLLECTORS} --create --host localhost --test-run-id "
                                       f"{Marvin.data_collector_test_run_id} --timestamp "
                                       f"{Marvin.data_collector_timestamp} --output-file {DATA_COLLECTOR_OUTPUT_FILE}")
        test_line_dict = {
                            "test_phase": {
                                "run_id": None,
                                "case_id": None,
                                "step_id": None
                            },
                            "test_line": {
                                "bts_id": Marvin.bts_id,
                                "status": ["Production"],
                                "organization": [ORGANIZATION],
                                "test_type": ["CRT"]
                            }
                        }
        with open(TEST_LINE_JSON, "w") as f:
            json.dump(test_line_dict, f)
        self.check_output_with_retries(f"export SUMMARY_VIEW_BACKEND_URL='{SUMMARY_VIEW_BACKEND_URL}' && python "
                                       f"{FORMATTER_APP} --path '{CONFIG_FOLDER}/01_test_line_json/' "
                                       f"--datatype 'testline'")

        test_run_dict = {
            "test_phase": {
                "run_id": Marvin.data_collector_test_run_id
            },
            "test_run": {
                "id": Marvin.data_collector_test_run_id,
                "test_type": ["CRT"],
                "organization": [ORGANIZATION],
                "exec_status": "Not started",
                "test_line_status": ["Production"],
                "bts": {
                    "id": Marvin.bts_id
                }
            }
        }
        with open(TEST_RUN_CREATION_JSON, "w") as f:
            json.dump(test_run_dict, f)
        test_case_dict = {
            "test_phase": {
                "run_id": Marvin.data_collector_test_run_id,
                "case_id": Marvin.data_collector_test_run_id
            },
            "id": Marvin.data_collector_test_run_id,
            "name": "Total",
            "exec_order": Marvin.data_collector_order,
            "test_steps": [
                {"id": "1", "name": "Environment Preparation", "exec_status": "Ongoing"},
                {"id": "2", "name": "BTS SW update"},
                {"id": "3", "name": "Traffic simulation"},
                {"id": "4", "name": "Logs collect", "exec_status": "Not started"},
                {"id": "5", "name": "Process Logs", "exec_status": "Not started"}
            ]
        }
        with open(TEST_RUN_CREATION_TOTAL, "w") as f:
            json.dump(test_case_dict, f)
        self.check_output_with_retries(f'export SUMMARY_VIEW_BACKEND_URL="{SUMMARY_VIEW_BACKEND_URL}" && python '
                                       f'{FORMATTER_APP} --path "{CONFIG_FOLDER}/02_test_run_creation_json" '
                                       f'--datatype "testrun"')

    def create_test_case(self, test_case_name):
        self._print_marvin("Creating test case")
        # Templates to be used in the case. Might need some automation to identify RAT
        self.check_output_with_retries(f"rm -f {CONFIG_FOLDER}/02_test_run_creation_json/*.json")
        self.check_output_with_retries(f"rm -f {CONFIG_FOLDER}/03_test_run_ready_json/*.json")
        Marvin.analysis_group_case_id = self._import_analysis(rat_templates[Marvin.rat_list[0] + "_case"])
        Marvin.data_collector_test_case_id = self._create_random_uuid()
        Marvin.data_collector_order += 1
        test_case_dict = {
                            "test_phase": {
                                "run_id": Marvin.data_collector_test_run_id,
                                "case_id": Marvin.data_collector_test_case_id
                            },
                            "id": Marvin.data_collector_test_case_id,
                            "name": test_case_name,
                            "comment": ORGANIZATION,
                            "exec_order": Marvin.data_collector_order,
                            "test_steps": []
                        }
        case_id_order_json = f"{CONFIG_FOLDER}/02_test_run_creation_json/case_id_{Marvin.data_collector_order}.json"
        with open(case_id_order_json, "w") as f:
            json.dump(test_case_dict, f)
        self.check_output_with_retries(f'export SUMMARY_VIEW_BACKEND_URL="{SUMMARY_VIEW_BACKEND_URL}" && python '
                                       f'{FORMATTER_APP} --path "{CONFIG_FOLDER}/02_test_run_creation_json" --update '
                                       f'--datatype "testrun"')

    def start_test_run(self, ref):
        self._print_marvin("Starting test run")
        reference_run_id = f" --reference-run-id {ref}" if ref else ""
        cmd = (f"{MARVIN_FOLDER}/aecli-linux-amd64 --host {DATA_COLLECTOR_AE_HOST} analysis execute --runtime -a "
               f"{Marvin.analysis_group_run_id} --started-from 'RSP_Jenkins'"
               f" --run-id {Marvin.data_collector_test_run_id}"
               f" --bts-id {Marvin.bts_id}{reference_run_id}")
        self.check_output_with_retries(cmd)

    def start_test_case(self, test_case_name, ref):
        self._print_marvin("Starting test case")
        reference_case_id = f" --reference-case-id {ref}" if ref else ""
        cmd = (f"{MARVIN_FOLDER}/aecli-linux-amd64 --host {DATA_COLLECTOR_AE_HOST} analysis execute --runtime -a "
               f"{self.analysis_group_case_id} --started-from 'RSP_Jenkins' --run-id {self.data_collector_test_run_id}"
               f" --case-id {self.data_collector_test_case_id} --test-phase-name {test_case_name}"
               f" --bts-id {self.bts_id}{reference_case_id}")
        self.check_output_with_retries(cmd)
        cpu_mem_collection = "" if Marvin.cpu_mem_collection else ' --adapter-list="defaults -cpu-mem"'
        meta = {"test_case": {"name": test_case_name}}
        meta_json = json.dumps(meta)
        cmd = (f"{ELASTIC_DATA_COLLECTORS} --start --host localhost --test-run-id "
               f"{Marvin.data_collector_test_run_id}  --meta '{meta_json}' --test-case-id "
               f"{Marvin.data_collector_test_case_id} --output-file {DATA_COLLECTOR_OUTPUT_FILE}"
               f"{cpu_mem_collection}")
        self.check_output_with_retries(cmd)
        Marvin.data_collector_timestamp = self.check_output_with_retries(f"date +'%Y-%m-%dT%H:%M:%S.%6NZ' -u",
                                                                         decode=True)
        self._update_summary()
        self.check_output_with_retries(f'echo "" >> {DATA_COLLECTOR_OUTPUT_FILE}')
        self.check_output_with_retries(f'echo "DATA_COLLECTOR_TEST_TOTAL_ID='
                                       f'{Marvin.data_collector_test_total_id}" >> {DATA_COLLECTOR_OUTPUT_FILE}')

    def stop_test_case(self, verdict="Passed"):
        self._print_marvin("Stopping test case")
        cmd = (f"{ELASTIC_DATA_COLLECTORS} --stop --host localhost --test-run-id "
               f"{Marvin.data_collector_test_run_id}  --test-case-id "
               f"{Marvin.data_collector_test_case_id}")
        self.check_output_with_retries(cmd)
        Marvin.data_collector_timestamp = self.check_output_with_retries(f"date +'%Y-%m-%dT%H:%M:%S.%6NZ' -u",
                                                                         decode=True)
        self._complete_case_summary(verdict)

    def stop_test_run(self, verdict="Passed"):
        self._print_marvin("Stopping test run")
        cmd = (f"{ELASTIC_DATA_COLLECTORS} --stop --host localhost --test-run-id "
               f"{Marvin.data_collector_test_run_id}")
        self.check_output_with_retries(cmd)
        Marvin.data_collector_timestamp = self.check_output_with_retries(f"date +'%Y-%m-%dT%H:%M:%S.%6NZ' -u",
                                                                         decode=True)
        self._complete_summary(verdict)

    def update_collectors(self):
        try:
            check_output(f"docker container ls -a | grep 'data_collector'", shell=True).decode().strip()
            self._print_marvin("Docker container is already running")
        except CalledProcessError as e:
            self._print_marvin("Updating collectors")
            self._print_marvin(f"Error: {e}\n{''.join(format_exception(type(e), e, e.__traceback__))}", debug=True)
            # needed until 8080 port is modifiable
            self.check_output_with_retries(f"sudo systemctl stop apache2.service")

            # Formatter.py
            self.check_output_with_retries(f"wget --no-proxy -T 10 -t 1 -P {MARVIN_FOLDER} "
                                           f"https://rsp-ta-ci-file.es-si-s3-z2.eecloud.nsn-net.net/marvin/"
                                           f"summary_view_formatter.zip")
            self.check_output_with_retries(f"unzip -o {MARVIN_FOLDER}/summary_view_formatter.zip -d {MARVIN_FOLDER}  "
                                           f"&& rm {MARVIN_FOLDER}/summary_view_formatter.zip")
            # Data collector
            self.check_output_with_retries(f"wget --no-proxy -T 10 -t 1 -P {MARVIN_FOLDER} "
                                           r"https://rsp-ta-ci-file.es-si-s3-z2.eecloud.nsn-net.net/data-collector/"
                                           r"datacollector_scripts.zip")
            self.check_output_with_retries(f"unzip -o {MARVIN_FOLDER}/datacollector_scripts.zip -d {MARVIN_FOLDER}  && "
                                           f"rm {MARVIN_FOLDER}/datacollector_scripts.zip")
            # Start docker
            self.check_output_with_retries(f"{MARVIN_FOLDER}/start_docker.sh --config-name={DOCKER_SIDE}  sudo=True")
            # AECLI
            self.check_output_with_retries(f"wget --no-proxy -T 10 -t 1 -P {MARVIN_FOLDER} "
                                           f"{DATA_COLLECTOR_AE_HOST}/cli/aecli-linux-amd64.gz")
            self.check_output_with_retries(f"gunzip -f {MARVIN_FOLDER}/aecli-linux-amd64.gz")
            self.check_output_with_retries(f"chmod +x {MARVIN_FOLDER}/aecli-linux-amd64")

    def fetch_single_snapshot(self):
        self.check_output_with_retries(f"{MARVIN_FOLDER}/snapshot_to_glusterfs.py --run-id "
                                       f"{Marvin.data_collector_test_run_id} --tags 'Test case end'")

    def init_setups(self):
        self.check_output_with_retries(f"mkdir -p {CONFIG_FOLDER}/01_test_line_json")
        self.check_output_with_retries(f"mkdir -p {CONFIG_FOLDER}/02_test_run_creation_json")
        self.check_output_with_retries(f"mkdir -p {CONFIG_FOLDER}/03_test_run_ready_json")

    def collect_bts_id_via_admin(self):
        bts_id = ""
        connection = self.admin.connect_to(name='marvin')
        try:
            bts_info = connection.get_parameters_for_all("BTS")
            bts_id = bts_info[0]["btsId"]
            return bts_id
        except IndexError as e:
            self._print_marvin(f"BTS ID not found\n"
                               f"{''.join(format_exception(type(e), e, e.__traceback__))}")
        finally:
            self.admin.teardown_admin(connection='marvin')
        return bts_id

    def check_rat(self):
        rat_list = []
        connection = self.admin.connect_to(name='marvin')
        try:
            bts_info = connection.get_bts_info()
            rat_state_dict = bts_info["ratState"]
            rat_list = [key for key, value in rat_state_dict.items() if value != "NO_CELLS"]
            return rat_list
        except Exception as e:
            self._print_marvin(f"Error: {e} when trying to get RAT\n")
            self._print_marvin(f"Error: {e}\n{''.join(format_exception(type(e), e, e.__traceback__))}", debug=True)
        finally:
            self.admin.teardown_admin(connection='marvin')
        return rat_list

    def prepare_and_start_marvin(self, test_case_name="", ref_run_id="", ref_case_id="", cpu_mem=True,
                                 only_test_run=False):
        self._print_marvin("Starting Marvin")
        if ORGANIZATION == "TV_Trunk_Oul1":
            Marvin.bts_id = self.bts.get_parameter_value_from_bts_info('btsId')  # TV_Trunk_Oul1 specific solution
        else:
            Marvin.bts_id = self.collect_bts_id_via_admin()  # Use this as common solution
        Marvin.cpu_mem_collection = cpu_mem
        Marvin.rat_list = self.check_rat()
        if Marvin.bts_id:
            self.update_collectors()
            self.init_setups()
            self.create_test_run()
            self.start_test_run(ref=ref_run_id)
            if not only_test_run:
                self.create_test_case(test_case_name)
                self.start_test_case(test_case_name, ref=ref_case_id)
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

    def create_test_case_and_start(self, test_case_name, ref_case_id=""):
        self.create_test_case(test_case_name)
        self.start_test_case(test_case_name, ref=ref_case_id)

    def check_output_with_retries(self, cmd, decode=False):
        self._print_marvin(f"Sending command {cmd}", debug=True)
        for i in range(3):
            try:
                output = check_output(cmd, shell=True)
                self._print_marvin(f"Output: {output}", debug=True)
                return output.decode().strip() if decode else output
            except CalledProcessError as e:
                self._print_marvin(f"Error: {e} when trying to send command: {cmd}\n"
                                   f"{''.join(format_exception(type(e), e, e.__traceback__))}\n"
                                   f"Output: {e.output}")
                if i < 2:
                    BuiltIn().sleep("5s", "Wait 5s before retrying")

    def _print_marvin(self, msg, debug=False):
        msg = f"Marvin: {msg}"
        if ORGANIZATION == "TV_Trunk_Oul1":
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
        else:
            self._print_marvin(f"Verdict {verdict} is not valid. Use 'Passed' or 'Failed' or boolean")
            return "Passed"
