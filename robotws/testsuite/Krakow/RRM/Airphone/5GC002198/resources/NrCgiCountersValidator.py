"""
Validator of NR CGI Report Config Sent and Received counters.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import logging

from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from taf.rfrl.bts.devices.generic_bts import login_logout


class NrCgiCountersValidator(GnbCellOperations):
    """
    Validates NR CGI Report Config Sent and Received counters.
    """

    def __init__(self):
        super(GnbCellOperations, self).__init__()
        self.counters = {
            "NRRCC_NRCGI_REPORT_CONF_SENT": {"id": "M55124C05001", "values": []},
            "NRRCC_NRCGI_REPORT_RECV": {"id": "M55124C05002", "values": []}
        }
        self.bts_instance_name = self.global_bts_name = self.cell_name = self._gnb_scf = self._gnb_counter = None

    @property
    def gnb_scf(self):
        if not self._gnb_scf:
            self._gnb_scf = GnbCommissioning()
        return self._gnb_scf

    @property
    def gnb_counter(self):
        if not self._gnb_counter:
            self._gnb_counter = GnbPmCounter()
        return self._gnb_counter

    @login_logout
    def wait_for_next_nrrrc_counters_interval(self, nrpmrnl_id=1, cell_id=1, delay=90, bts_id=0, du_id=0):
        """
        Waits for the next miNrRRCC counters interval with an additional delay.
        Args:
            nrpmrnl_id (int): NRPMRNL ID. Default is 1.
            cell_id (int): Cell ID. Default is 1.
            delay (int): Additional delay in seconds. Default is 90.
            bts_id (int): BTS ID. Default is 0.
            du_id (int): DU ID. Default is 0.
        """
        interval = self.get_nrrrc_counters_interval(nrpmrnl_id, cell_id, bts_id, du_id)
        logging.info(f"Waiting for the next miNrRRCC counters interval: '{interval}'")
        self.gnb_counter.wait_for_next_pm_period(interval, delay)

    @login_logout
    def get_airphone_cell_nrcgi_report_counters(self, cell_id=1, bts_id=0, du_id=0):
        """
        Retrieves and stores NR CGI Report Config Sent and Received counters for a specific cell.
        Args:
            cell_id (int): Cell ID to retrieve counters for. Default is 1.
            bts_id (int): BTS ID. Default is 0.
            du_id (int): DU ID. Default is 0.
        """
        pm_output = self.get_nrcgi_counters(bts_id=bts_id, du_id=du_id)
        self.get_names_based_on_cell_configuration(cell_id, bts_id, du_id)
        cell_data = pm_output["BTS"][self.bts_instance_name][self.global_bts_name][self.cell_name]

        for counter_key, counter_info in self.counters.items():
            counter_info["values"] = self.gnb_counter.extract_counter_data_from_response(
                response=cell_data, counter_id=counter_info["id"]
            )

    def validate_nrcgi_report_counters(self):
        """
        Validates that the NR CGI Report Config Sent counter value is greater than or equal to the NR CGI Report
         Received counter value for the latest interval. Raises a ValueError if the validation fails.
        Raises:
            ValueError: If the NR CGI Report Config Sent counter value is lower than the NR CGI Report Received counter
                        value, or if either of the counter values are not greater than 0.
        """
        latest_interval_id = self.get_latest_counter_interval(
            cell_counters=self.counters["NRRCC_NRCGI_REPORT_CONF_SENT"]["values"])
        logging.info(f"Getting latest_interval_id: {latest_interval_id}")

        report_conf_sent = int(self.counters["NRRCC_NRCGI_REPORT_CONF_SENT"]["values"][0]['timestamps'][0][
                                   latest_interval_id])
        report_recv = int(self.counters["NRRCC_NRCGI_REPORT_RECV"]["values"][0]['timestamps'][0][
                              latest_interval_id])
        if report_conf_sent > 0 and report_recv > 0:
            if report_conf_sent >= report_recv:
                logging.info(f"Verification passed. M55124C05001 NR CGI Report Config Sent counter value: "
                             f"'{report_conf_sent}' is greater than or equal to M55124C05002 NR CGI Report Received "
                             f"counter value: '{report_recv}' in interval '{latest_interval_id}'")
            else:
                raise ValueError(f"Verification failed. M55124C05001 NR CGI Report Config Sent counter value: "
                                 f"'{report_conf_sent}' is lower than M55124C05002 NR CGI Report Received counter value"
                                 f": '{report_recv}', should be greater than or equal to it --> "
                                 f"https://jiradc.ext.net.nokia.com/browse/MNRCA-59742")
        else:
            raise ValueError(f"Verification failed. M55124C05001 NR CGI Report Config Sent counter value and "
                             f"M55124C05002 NR CGI Report Received counter value should be greater than 0 in interval "
                             f"'{latest_interval_id}' --> https://jiradc.ext.net.nokia.com/browse/MNRCA-59742. "
                             f"Current values: {self.counters}")

    @login_logout
    def get_nrrrc_counters_interval(self, nrpmrnl_id, cell_id, bts_id=0, du_id=0):
        """
        Retrieves the miNrRRCC counters interval for the specified NRPMRNL and cell configuration.
        Args:
            nrpmrnl_id (int): The ID of the NRPMRNL to get the miNrRRCC interval for.
            cell_id (int): The ID of the cell to get the miNrRRCC interval for.
            bts_id (int): The ID of the BTS to get the miNrRRCC interval for. Default is 0.
            du_id (int): The ID of the DU to get the miNrRRCC interval for. Default is 0.
        """
        self.get_names_based_on_cell_configuration(cell_id=cell_id, bts_id=bts_id, du_id=du_id)
        parameters = self.gnb_scf.get_parameters_by_dist_name(
            dist_name=f"{self.bts_instance_name}/{self.global_bts_name}/NRPMRNL-{nrpmrnl_id}",
            parameter_list=["miNrRRCC"])
        return parameters["parameters"]["miNrRRCC"]

    @login_logout
    def get_names_based_on_cell_configuration(self, cell_id, bts_id=0, du_id=0):
        """
        Retrieves the bts_instance_name, global_bts_name and cell_name based on the provided cell configuration.
        Args:
            cell_id (int): The ID of the cell to get the names for.
            bts_id (int): The ID of the BTS to get the names for. Default is 0.
            du_id (int): The ID of the DU to get the names for. Default is 0.
        """
        if not self.bts_instance_name:
            cell_dist_name = self._get_configured_cell_dist_name(cell_id=cell_id, bts_id=bts_id, du_id=du_id)
            self.bts_instance_name, self.global_bts_name, self.cell_name = cell_dist_name.split('/')
            logging.info(f"Retrieving cell_dist_name {cell_dist_name}: bts_instance_name: {self.bts_instance_name}"
                         f"global_bts_name: {self.global_bts_name}, cell_name: {self.cell_name}")

    @login_logout
    def get_nrcgi_counters(self, bts_id=0, du_id=0):
        """
        Retrieves the NR CGI Report Config Sent and Received counters for the specified BTS and DU.
        Args:
            bts_id (int): BTS ID. Default is 0.
            du_id (int): DU ID. Default is 0.
        Returns:
            dict: Retrieved counters for the specified BTS and DU.
        """
        counter_ids = f'{self.counters["NRRCC_NRCGI_REPORT_CONF_SENT"]["id"]},' \
                      f'{self.counters["NRRCC_NRCGI_REPORT_RECV"]["id"]}'
        return self.gnb_counter.get_counter(counter_ids, bts_id=bts_id, du_id=du_id)

    @staticmethod
    def get_latest_counter_interval(cell_counters):
        """
        Retrieves the latest interval ID from the provided cell counters.
        Args:
            cell_counters (list): List of counters with timestamp information.
        Returns:
            str: The latest interval ID.
        """
        return max(cell_counters[0]['timestamps'][0])
