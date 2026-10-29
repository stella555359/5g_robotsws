import traceback

from typing import List, Optional

from taf.config.testline import PduPort
from taf.hw.pdu import pdu

from taf.rfrl.csv4all.resources.test_cases.csv4all_test import CSV4AllTest, Node
from taf.rfrl.csv4all.resources.test_cases.exceptions import TestPreconditionFailed
from taf.rfrl.csv4all.resources.utilities.decorators import function_wrapper
from taf.rfrl.csv4all.resources.utilities.utilities import test_logger
from taf.rfrl.csv4all.resources.utilities.exceptions import PduFormatError


class PowerResetTest(CSV4AllTest):
    pdu = pdu()

    def __init__(self, nodes_details: List[dict], test_nodes_details: List[dict], iterations_per_node: int,
                 modules_with_pdu_ports: List[dict],
                 report: bool, calculate_kpi: Optional[bool] = True, kpi_targets: Optional[dict] = None,
                 use_dcap: Optional[bool] = False, qc_domain: Optional[str] = None, qc_id: Optional[str] = None,
                 qc_project: Optional[str] = None, customers_list: Optional[list] = None,
                 report_comment: Optional[str] = None, sw_build: Optional[str] = None, topology: Optional[str] = None,
                 stop_test_after_fail: bool = False, l3_call_method: Optional[callable] = None,
                 detailed_console_log: bool = True):
        super().__init__(nodes_details, test_nodes_details, iterations_per_node, report,
                         calculate_kpi, kpi_targets, use_dcap, qc_domain, qc_id, qc_project, customers_list,
                         report_comment, sw_build, topology, stop_test_after_fail, l3_call_method,
                         detailed_console_log)
        self.modules_with_pdu_ports = modules_with_pdu_ports
        self.reset_incrementation = True
        self.uuf_case_type = "reset"

    def test_setup(self):
        """
        Performs test setup for site power reset test.
        Code based on site_reset_test.py from csv4all library.
        Performs general test setup for csv4all tests, adds allowed alarms for power reset test,
        logs warning in case tests reports will not be sent, verifies if active software
        is the same as target software passed by user.
        """

        super().test_setup()
        self.add_allowed_power_reset_alarms()
        self._log_if_reports_to_uuf_wont_be_sent()
        self.verify_active_sw()

    def run_test_precondition(self):
        """
        Executes actions necessary before test loop execution.
        Code taken from site_reset_test.py from csv4all library.
        Checks available free space in /home/ute and /tmp directiories
        and stops execution if there is not enough space.
        """
        failed_nodes = self.run_precheck_method()
        if failed_nodes:
            self.gather_mumin_logs_and_snapshot("test_precondition")
            if self.report_to_rp:
                for node in self.test_nodes:
                    self.test_reporter.report_result_to_uuf_dashboard(node, "failed", "", self.current_iteration)
            self.run_recovery_method(failed_nodes)
            raise TestPreconditionFailed()

    def test_operation(self, node):
        """
        Performs test operation for site power reset test.
        Code based on site_reset_test.py from csv4all library.
        Gets start time of the loop, adds allowed alarms specific for test operation,
        performs power reset of all modules (SMODs and RMODs).

        :param node: Node object as created in csv4all library.
        """
        if self.report_to_rp:
            self.test_reporter.get_start_time()
        test_logger("Gathering snapshot")
        node.admin.get_snapshot(target_file_name=f"{self.current_logs_dir}/snapshot_before_reset.zip",
                                timeout=3600)
        self.add_all_allowed_specific_faults(node)
        self.all_modules_reset_via_pdu(self.modules_with_pdu_ports)

    def test_teardown(self):
        """
        Performs test teardown for site power reset test.
        Code based on site_reset_test.py from csv4all library.
        Performs general test teardown for csv4all tests.
        """
        super()._common_test_teardown()

    def run_test_verification(self, node, hw_timer: int = None, alarm_timer: int = None):
        """
        Performs test verification for site power reset test.
        Code taken from site_reset_test.py from csv4all library.
        Verifies nodes - checks if all nodes went on air before timeout as well as
        performs alarm verification, removes temporary allowed alarms,
        reports to reporting portal if report_to_rp is set to true, logs loop result.

        :param node: Node object as created in csv4all library.
        :param hw_timer: Timeout for HW to go on air.
        :param alarm_timer: Time dedicated to waiting for unexpected alarms.
        :return List of failed nodes.
        """
        failed_nodes = super().run_test_verification(node, hw_timer, alarm_timer)
        if self.report_to_rp:
            self.test_reporter.get_end_time()
        if failed_nodes:
            test_logger(f"[{node.node_alias}] SITE POWER RESET FAILED", "error")
        else:
            test_logger(f"[{node.node_alias}] SITE POWER RESET PASSED", hyperlink=True)
        return failed_nodes

    @function_wrapper
    def verify_active_sw(self):
        """
        Verifies active software version against target software passed by user to node.
        Code taken from site_reset_test.py from csv4all library.
        """
        for node in self.test_nodes:
            self.check_active_sw(node, node.target_sw)

    def add_allowed_power_reset_alarms(self):
        """
        Adds allowed alarms for power reset test. Alarms may appear
        after more than a few minutes, so this should be called in
        setup or account for this.
        """
        for node in self.test_nodes:
            test_logger("Create", log_level="INFO")
            alarm_4592 = node.watchdog.create_alarm(fault_id="4592")
            alarm_4589 = node.watchdog.create_alarm(fault_id="4589", fault_name="Unit power reset")
            alarm_4590 = node.watchdog.create_alarm(fault_id="4590", fault_name="Fault signature for crash or failure",
                                                    fault_signature={"category": "POWER_OFF"})
            temp_alarm_4590 = node.watchdog.create_alarm(fault_id="4590",
                                                         fault_name="Fault signature for crash or failure")

            test_logger(node.watchdog, log_level="INFO")
            node.watchdog.allow_alarm(alarm_4592)
            node.watchdog.allow_alarm(alarm_4589)
            node.watchdog.allow_alarm(alarm_4590)
            test_logger("Append", log_level="INFO")
            node.btsverify.test_specific_alarms.append(alarm_4589)
            node.btsverify.test_specific_alarms.append(alarm_4590)
            node.btsverify.test_specific_alarms.append(alarm_4592)
            node.btsverify.test_specific_alarms.append(temp_alarm_4590)

    def all_modules_reset_via_pdu(self, modules_with_pdu_ports):
        """
        Performs power reset for all modules passed in test.

        :param modules_with_pdu_ports: List of dictionaries containing module serial number as key
               and dictionary with pdu data as value. The PDU data dictionary
               has the same data as PduPort object from __init__.py:
               model, host, port, version.
        """
        for module in modules_with_pdu_ports:
            self.module_reset_via_pdu(module)

    def module_reset_via_pdu(self, module: dict):
        """
        Performs power reset for one module
        Code taken from radio_module_power_reset_test.py from csv4all library.
        Prints pdu detail, it checks if pdu details passed to test are of PduPort
        object type and setups pdu accordingly then resets pdu ports of given module,
        if incorrect data format is used, an error will be raised, finally it performs
        pdu teardown or raises error in case an issue occurs.

        :param module: Dictionary containing module serial number as key
               and dictionary with pdu data as value. The PDU data dictionary
               has the same data as PduPort object from __init__.py:
               model, host, port, version.
        """
        pdu_details = list(module.values())[0]
        test_logger(f"PDU details: {pdu_details}")
        if isinstance(pdu_details, PduPort):
            self.pdu.setup_pdu(pdu_details.pdu)
            self.pdu.reset_ports([pdu_details])
        elif isinstance(pdu_details, dict):
            if pdu_details.get("version"):
                self.pdu.setup_pdu(model=pdu_details["model"], host=pdu_details["host"],
                                   version=pdu_details.get("version"))
            else:
                self.pdu.setup_pdu(model=pdu_details["model"], host=pdu_details["host"])
            self.pdu.reset_ports(pdu_details["port"] if isinstance(pdu_details["port"], list)
                                 else [pdu_details["port"]], time_interval=10)
        else:
            test_logger("Wrong format of Pdu Details provided!\nPlease provide either instance of PduPort class, or "
                        "dictionary with host, model(and version if needed), port keys according to example in guide!\n"
                        "Aborting Test!", "error")
            raise PduFormatError("Wrong format of PDU! Aborting test!")
        try:
            self.pdu.teardown_pdu()
        except NotImplementedError as e:
            test_logger(e, "error")
            test_logger(traceback.format_exc(), log_level="debug", console=False)
