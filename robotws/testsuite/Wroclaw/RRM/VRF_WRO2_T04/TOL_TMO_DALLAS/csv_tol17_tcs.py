from typing import Union, List
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.TOL_TMO_DALLAS.resources.rat_operations import RatBlockUnblockTest, RatResetTest
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.TOL_TMO_DALLAS.resources.gsm_lock_unlock import CellLockUnlockGsmTest


def e2e_tl_rat_block_unblock_nr(nodes_details: List[dict], test_nodes_details, iterations_per_node: int,
                                report: bool = True,
                                calculate_kpi: bool = True, kpi_targets: dict = None, use_dcap: bool = False,
                                qc_domain: str = None, qc_id: str = None, qc_project: str = None,
                                customers_list: Union[str, list] = None, report_comment: str = None,
                                sw_build: str = None, topology: str = None, stop_test_after_fail: bool = False,
                                l3_call_method=None, detailed_console_log: bool = True):
    test = RatBlockUnblockTest(**locals(), rat_to_block='nr')
    test.run_test()


def e2e_tl_rat_block_unblock_lte(nodes_details: List[dict], test_nodes_details, iterations_per_node: int,
                                 report: bool = True,
                                 calculate_kpi: bool = True, kpi_targets: dict = None, use_dcap: bool = False,
                                 qc_domain: str = None, qc_id: str = None, qc_project: str = None,
                                 customers_list: Union[str, list] = None, report_comment: str = None,
                                 sw_build: str = None, topology: str = None, stop_test_after_fail: bool = False,
                                 l3_call_method=None, detailed_console_log: bool = True):
    test = RatBlockUnblockTest(**locals(), rat_to_block='lte')
    test.run_test()


def e2e_tl_rat_block_unblock_gsm(nodes_details: List[dict], test_nodes_details, iterations_per_node: int,
                                 report: bool = True,
                                 calculate_kpi: bool = True, kpi_targets: dict = None, use_dcap: bool = False,
                                 qc_domain: str = None, qc_id: str = None, qc_project: str = None,
                                 customers_list: Union[str, list] = None, report_comment: str = None,
                                 sw_build: str = None, topology: str = None, stop_test_after_fail: bool = False,
                                 l3_call_method=None, detailed_console_log: bool = True):
    test = RatBlockUnblockTest(**locals(), rat_to_block='gsm')
    test.run_test()


def e2e_tl_rat_reset_lte(
        nodes_details: List[dict], test_nodes_details, iterations_per_node: int, delta: str = None,
        report: bool = True,
        calculate_kpi: bool = False, kpi_targets: dict = None, use_dcap: bool = False, qc_domain: str = None,
        qc_id: str = None, qc_project: str = None, customers_list: Union[str, list] = None,
        report_comment: str = None, sw_build: str = None, topology: str = None, stop_test_after_fail: bool = False,
        l3_call_method=None, detailed_console_log: bool = True):
    test = RatResetTest(**locals(), rat_to_reset='LTE')
    test.run_test()


def e2e_tl_cell_lock_unlock_gsm(nodes_details: List[dict], test_nodes_details,
                                iterations_per_node: int,
                                report: bool = True, calculate_kpi: bool = True,
                                kpi_targets: dict = None,
                                use_dcap: bool = False, qc_domain: str = None, qc_id: str = None,
                                qc_project: str = None, customers_list: Union[str, list] = None,
                                report_comment: str = None, sw_build: str = None, topology: str = None,
                                stop_test_after_fail: bool = False, l3_call_method=None,
                                detailed_console_log: bool = True):
    test = CellLockUnlockGsmTest(**locals(), rat="gsm")
    test.run_test()
