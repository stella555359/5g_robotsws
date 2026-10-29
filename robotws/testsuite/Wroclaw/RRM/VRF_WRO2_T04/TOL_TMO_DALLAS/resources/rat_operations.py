from typing import List, Union, Optional
from robot.api import logger
from taf.rfrl.csv4all.resources.test_cases.csv4all_test import CSV4AllTest, method_decorator
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from taf.rfrl.csv4all.resources.test_cases.delta_commissioning_test import DeltaCommissioningTest
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException


class RatBlockUnblockTest(CSV4AllTest):
    def __init__(self, nodes_details: List[dict], test_nodes_details: List[dict], iterations_per_node: int,
                 report: bool, rat_to_block: str, calculate_kpi: Optional[bool] = True,
                 kpi_targets: Optional[dict] = None,
                 use_dcap: Optional[bool] = False, qc_domain: Optional[str] = None, qc_id: Optional[str] = None,
                 qc_project: Optional[str] = None, customers_list: Optional[list] = None,
                 report_comment: Optional[str] = None, sw_build: Optional[str] = None, topology: Optional[str] = None,
                 stop_test_after_fail: bool = False, l3_call_method: Optional[callable] = None,
                 detailed_console_log: bool = True):
        super().__init__(nodes_details, test_nodes_details, iterations_per_node, report,
                         calculate_kpi, kpi_targets, use_dcap, qc_domain, qc_id, qc_project, customers_list,
                         report_comment, sw_build, topology, stop_test_after_fail, l3_call_method, detailed_console_log)
        self.failed_nodes_after_block = None
        self.rat_to_block = rat_to_block

    def test_operation(self, node):
        node.add_test_specific_alarm(fault_id='4614')
        self.block_rat(node)
        self.add_all_allowed_specific_faults(node)
        self.failed_nodes[node.node_alias].update(self.run_verification(hw_timer=90, alarm_timer=30))
        self.multi_runner.start_watching_alarms_on_all_nodes()
        self.multi_runner.start_log_tracing_all_nodes()
        self.unblock_rat(node)

    @method_decorator()
    def block_rat(self, node):
        node.btsverify.blocked_objects.extend(node.cells_per_rat[self.rat_to_block.lower()])
        node.btsverify.set_blocked_object()
        with AdminSession() as admin:
            admin.block_rat(rat=self.rat_to_block.upper(), timeout=90)

    @method_decorator()
    def unblock_rat(self, node):
        with AdminSession() as admin:
            admin.unblock_rat(rat=self.rat_to_block.upper(), timeout=90)
        node.btsverify.clear_blocked_objects_list()


class RatResetTest(DeltaCommissioningTest):

    def __init__(self, nodes_details, test_nodes_details: List[dict], iterations_per_node: int, delta: str,
                 report: bool, rat_to_reset: str = None, calculate_kpi: Optional[bool] = True,
                 kpi_targets: Optional[dict] = None,
                 use_dcap: Optional[bool] = False, qc_domain: Optional[str] = None, qc_id: Optional[str] = None,
                 qc_project: Optional[str] = None, customers_list: Union[str, list] = None,
                 report_comment: Optional[str] = None, sw_build: Optional[str] = None, topology: Optional[str] = None,
                 stop_test_after_fail: bool = False, l3_call_method: Optional[callable] = None,
                 detailed_console_log: bool = True):
        super().__init__(nodes_details, test_nodes_details, iterations_per_node, report, delta, rat_to_reset,
                         calculate_kpi, kpi_targets, use_dcap, qc_domain, qc_id, qc_project, customers_list,
                         report_comment, sw_build, topology, stop_test_after_fail, l3_call_method, detailed_console_log)
        self.rat_to_reset = rat_to_reset
        self.reset_incrementation = False

    def run_iteration_postcondition(self, node):
        return

    def test_operation(self, node):
        with AdminSession() as admin:
            try:
                admin.rat_reset(self.rat_to_reset.upper(), timeout=10)
            except AdminApiProcedureTimeoutException:
                logger.debug("Ignoring timeout..")
        if self.rat_to_reset:
            self.wait_till_rat_is_reseted(node, self.rat_to_reset)
            self.set_l3_all_dependent_cells(node, self.rat_to_reset)
            self.check_cells_not_affected(node)
