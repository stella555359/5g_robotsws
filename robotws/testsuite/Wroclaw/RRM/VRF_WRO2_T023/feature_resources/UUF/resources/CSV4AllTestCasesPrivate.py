from typing import Union, Optional, List

from testsuite.Wroclaw.RRM.VRF_WRO2_T023.feature_resources.UUF.resources.site_power_reset_test import PowerResetTest


class CSV4AllTestCasesPrivate:

    @staticmethod
    def e2e_tl_power_reset(nodes_details: List[dict], test_nodes_details,
                           iterations_per_node: int, modules_with_pdu_ports: List[dict],
                           report: bool = True, calculate_kpi=True, kpi_targets: dict = None,
                           use_dcap: bool = False,
                           qc_domain: str = None, qc_id: str = None, qc_project: str = None,
                           customers_list: Union[str, list] = None, report_comment: str = None,
                           sw_build: str = None, topology: str = None,
                           stop_test_after_fail: bool = False, l3_call_method=None,
                           detailed_console_log: bool = True):
        """
        Performs power reset for modules which data is passed in modules_with_pdu_ports.

        :param nodes_details: List of nodes dictionaries, as created in csv4all library,
               which will be monitored during test.
        :param test_nodes_details: List of nodes dictionaries, as created in csv4all library,
               which will be participating in test.
        :param iterations_per_node: Number of iterations performed per node.
        :param modules_with_pdu_ports: List of dictionaries containing module serial number as key
               and dictionary with pdu data as value. The PDU data dictionary
               has the same data as PduPort object from __init__.py:
               model, host, port, version.
        :param report: Boolean value defining if report should be sent.
        :param calculate_kpi: Boolean value defining if kpi should be calculated.
        :param kpi_targets: Targets for KPIs.
        :param use_dcap: Boolean value defining if UTF should be used to collect logs.
        :param qc_domain: Domain from Quality Center where test should be reported.
        :param qc_id: Instance ID from Quality Center where test should be reported.
        :param qc_project: Project from Quality Center where test should be reported.
        :param customers_list: List of customers or string with customer name.
        :param report_comment: Comment that should be added to report in Quality Center.
        :param sw_build: Software build which will be verified against active software.
        :param topology: Testline topology.
        :param stop_test_after_fail: Boolean value determining if test should be stopped after fail.
        :param l3_call_method: Additional keyword which may be passed and executed after test loop.
        :param detailed_console_log: Boolean value defining if detailed log should be done in console.
        """
        test = PowerResetTest(**locals())
        test.run_test()
