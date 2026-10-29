import time
from typing import List, Optional

from hran_bsc import hran_bsc
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from taf.rfrl.csv4all.resources.test_cases.cell_operation_test import CellOperationTest
from taf.rfrl.csv4all.resources.test_cases.exceptions import TestPreconditionFailed
from taf.rfrl.csv4all.resources.utilities.decorators import method_decorator

from test_constants import *
from robot.api import logger


class CellLockUnlockGsmTest(CellOperationTest):

    def __init__(self, nodes_details: List[dict], test_nodes_details: List[dict], iterations_per_node: int,
                 report: bool, calculate_kpi: Optional[bool] = True, kpi_targets: Optional[dict] = None,
                 use_dcap: Optional[bool] = False, qc_domain: Optional[str] = None, qc_id: Optional[str] = None,
                 qc_project: Optional[str] = None, customers_list: Optional[list] = None,
                 report_comment: Optional[str] = None, sw_build: Optional[str] = None, topology: Optional[str] = None,
                 rat: Optional[str] = None, stop_test_after_fail: bool = False,
                 l3_call_method: Optional[callable] = None, detailed_console_log: bool = True):
        super().__init__(nodes_details, test_nodes_details, iterations_per_node, report,
                         calculate_kpi, kpi_targets, use_dcap, qc_domain, qc_id, qc_project, customers_list,
                         report_comment, sw_build, topology, rat, stop_test_after_fail, l3_call_method,
                         detailed_console_log)
        self.gsm_cells = None

    def set_gsm_cells(self):
        with AdminSession() as admin:
            self.gsm_cells = [c['gsmSectorID'] for c in admin.get_cells_info(cell_type='gsm')]

    def test_operation(self, node):
        self.set_gsm_cells()
        locked_band = next(node.bands_for_test)
        logger.debug(self.get_cells_list_per_band(node))
        node.btsverify.locked_objects = self.get_cells_list_per_band(node)[locked_band]
        self.lock_cells(node)
        self.failed_nodes[node.node_alias].update(self.run_verification(hw_timer=90, alarm_timer=30))
        self.multi_runner.start_watching_alarms_on_all_nodes()
        self.multi_runner.start_log_tracing_all_nodes()
        self.unlock_cells(node)

    @method_decorator()
    def lock_cells(self, node):
        node.btsverify.set_locked_object()
        if self.l3_call_method:
            self.l3_call_dependent_cells = [cell for cell in node.btsverify.cells_verifier.locked_cell]
        self.add_allowed_dss_faults_as_test_specific(node.btsverify.locked_objects)
        self.lock_gsm_cells()

    @method_decorator()
    def unlock_cells(self, node):
        self.unlock_gsm_cells()
        node.btsverify.clear_locked_objects_list()

    def run_test_precondition(self):
        try:
            super().run_test_precondition()
        except TestPreconditionFailed as e:
            raise e

    def lock_gsm_cells(self):
        for cell in self.gsm_cells:
            self.__execute_command_on_bsc(f"ZEQS:BTS={cell}:L;")
            time.sleep(20)

    def unlock_gsm_cells(self):
        for cell in self.gsm_cells:
            self.__execute_command_on_bsc(f"ZEQS:BTS={cell}:U;")
            time.sleep(20)

    @staticmethod
    def __execute_command_on_bsc(cmd):
        bsc = hran_bsc()
        bsc.bsc_ssh_connection(host=GSM_BSC_IP, username=GSM_BSC_USER, password=GSM_BSC_PASS)
        try:
            bsc.write(cmd)
            bsc.read_until("COMMAND EXECUTED")
        finally:
            bsc.close_connection()
