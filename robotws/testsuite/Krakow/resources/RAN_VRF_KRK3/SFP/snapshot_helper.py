"""
Library to collect Snapshot and retrieve SFP data from Snapshot.

:copyright: Nokia Networks
:author: Marek Bodziony
:contact: marek.bodziony@nokia.com
:maintainer: Marek Bodziony
:contact: marek.bodziony@nokia.com
"""
import os
import re
import logging
import gzip
import time
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
import taf.rfrl.bts.parsers.snapshot_analyzer as snapshot_analyzer


class SnapshotHelper(GnbLog):
    """
    Class contains methods to collect Snapshot and retrieve SFP data from Snapshot.
    """

    def __init__(self):
        """
        Constructor of SnapshotHelper class.
        """
        super(GnbLog, self).__init__()
        self.snapshot_dir = "/tmp/snapshot"

    def get_latest_sfp_param_values_from_snapshot(self, num_of_rmods=1):
        """
        Get latest RMOD SFPs parameters stored in Snapshot
        :param num_of_rmods:    number of RMODs
        :return:                list of dicts with latest SFP dynamic parameters stored in Snapshot
        """
        snapshot_path = self.collect_snapshot(log_dir=self.snapshot_dir)
        logging.info("Snapshot collected in: {}".format(snapshot_path))
        bts_part_files = snapshot_analyzer._get_bts_zip_files_list(directory=snapshot_path)

        rmod_sfp_dynamic_parameters_list = list()
        for i in range(1, int(num_of_rmods) + 1):
            rmod_sfp_parameter_monitor_file = "RMOD_L_{}_SfpParameterMonitorFile.txt.gz".format(i)
            sfp_parameter_monitor_file_gz = \
                snapshot_analyzer._get_specific_snapshot_file(bts_part_files, rmod_sfp_parameter_monitor_file)
            with gzip.open(sfp_parameter_monitor_file_gz, mode="rt") as sfp_parameter_monitor_file:
                rmod_sfp_data = sfp_parameter_monitor_file.read()
                rmod_sfp_data = [re.split(";", rmod_sfp_data)][0]
                latest_rmod_sfp_parameters = rmod_sfp_data[-2]
                latest_rmod_sfp_parameters = latest_rmod_sfp_parameters.split(",")
                rmod_sfp_dynamic_parameters = dict()
                rmod_sfp_dynamic_parameters["dynamic"] = dict()
                rmod_sfp_dynamic_parameters["dynamic"]["TXSupplyVoltage"] = int(latest_rmod_sfp_parameters[4])
                rmod_sfp_dynamic_parameters["dynamic"]["TXBiasCurrent"] = int(latest_rmod_sfp_parameters[5])
                rmod_sfp_dynamic_parameters["dynamic"]["TXOpticalPowerUW"] = float(latest_rmod_sfp_parameters[7])
                rmod_sfp_dynamic_parameters["dynamic"]["RXOpticalPowerUW"] = float(latest_rmod_sfp_parameters[6])
                rmod_sfp_dynamic_parameters["dynamic"]["moduleTemperature"] = int(latest_rmod_sfp_parameters[3])
                rmod_sfp_dynamic_parameters_list.append(rmod_sfp_dynamic_parameters)
        logging.info("SFP dynamic parameters from Snapshot ({}):\n{}".format(snapshot_path,
                                                                             rmod_sfp_dynamic_parameters_list))
        return rmod_sfp_dynamic_parameters_list

    def remove_snapshot_temp_dir(self):
        """
        Remove temporary snapshot directory
        """
        os.system("rm -r {}".format(self.snapshot_dir))

    def _get_latest_sfp_param_values_from_pm_counters(self, bts_id, num_of_modules, module_type_in_pm):
        """
        Get latest SFPs dynamic parameters stored in PM counters for module
        :param bts_id:              id of bts (from config)
        :param num_of_modules:      number of BBMODs/RMODs to get SFP params from PM counters
        :param module_type_in_pm:   name of module for SFP in PM counters (for RMOD: SFPRM, for BBMOD: SFPBM)
        :return:                    list of dicts with latest SFP dynamic parameters stored in PM counters
        """
        latest_sfp_pm_counters_file_gz, snapshot_path = self._get_latest_sfp_pm_counter_file_from_snapshot()
        sfp_dynamic_parameters = dict()
        with gzip.open(latest_sfp_pm_counters_file_gz, mode="rt") as sfp_pm_counters_file:
            sfp_pm_counters_file = sfp_pm_counters_file.read()
            logging.info("All PM counters in Snapshot:\n{}".format(sfp_pm_counters_file))

            for counter in ['M40007C2', 'M40007C10', 'M40015C1', 'M40015C2',
                            'M40015C4', 'M40015C5', 'M40015C7', 'M40015C8']:
                regex = r"({counter})\>([0-9-\.]+)\<\/({counter})".format(counter=counter)
                counters = re.findall(regex, sfp_pm_counters_file)
                sfp_dynamic_parameters[counter] = [float(elem[1]) for elem in counters]

        if len(sfp_dynamic_parameters) == 0:
            logging.warning("Empty list of SFP dynamic parameters from PM counters")

        return sfp_dynamic_parameters

    def get_latest_sfp_param_values_from_pm_counters_for_rmod(self, bts_id, num_of_rmods=1):
        """
        Get latest SFPs dynamic parameters stored in PM counters for RMOD
        :param bts_id:              id of bts (from config)
        :param num_of_rmods:        number of RMODs to get SFP params from PM counters
        :return:                    list of dicts with latest SFP dynamic parameters stored in PM counters
        """
        return self._get_latest_sfp_param_values_from_pm_counters(bts_id, num_of_rmods, module_type_in_pm="SFPRM")

    def get_latest_sfp_param_values_from_pm_counters_for_bbmod(self, bts_id, num_of_bbmods=1):
        """
        Get latest SFPs dynamic parameters stored in PM counters for BBMOD
        :param bts_id:              id of bts (from config)
        :param num_of_bbmods:       number of BBMODs to get SFP params from PM counters
        :return:                    list of dicts with latest SFP dynamic parameters stored in PM counters
        """
        return self._get_latest_sfp_param_values_from_pm_counters(bts_id, num_of_bbmods, module_type_in_pm="SFPBM")

    @staticmethod
    def _get_latest_sfp_pm_counter_file_name(snapshot_path):
        """
        Get the name of latest xml file with SFPs dynamic parameters stored in PM counters in Snapshot
        :param snapshot_path:   path to snapshot where SFP PM counters should be found
        :return:                name of file with latest SFPs dynamic parameters stored in PM counters
        """
        rmod_files_in_snapshot = snapshot_analyzer.find_mandatory_files_in_snapshot(directory=snapshot_path)
        pm_counters_files_in_snapshot = list()
        for rmod_file in rmod_files_in_snapshot:
            if "PM.BTS" in rmod_file and "xml" in rmod_file:
                pm_counters_files_in_snapshot.append(rmod_file)
        if len(pm_counters_files_in_snapshot) == 0:
            sfp_pm_counters_file = None
        else:
            sfp_pm_counters_file = pm_counters_files_in_snapshot[-1]
            logging.info("Latest file with PM counters in Snapshot: {}".format(sfp_pm_counters_file))
        return sfp_pm_counters_file

    def _get_latest_sfp_pm_counter_file_from_snapshot(self, pm_interval=15, wait_for_next_pm=True):
        """
        Get the latest file with SFPs dynamic parameters stored in PM counters in Snapshot or wait for next PM counters
        ann collect Snapshot again and then look for dynamic parameters stored in PM counters
        :param pm_interval:         time interval for PM counters collection on BTS
        :param wait_for_next_pm:    indicates if should wait for next PM counters and collect Snapshot again if no PM
                                    counters with SFP params in current Snapshot
        :return:                    name of file with latest SFPs dynamic parameters stored in PM counters in Snapshot
        :return:                    path to dir where Snapshot was collected
        """
        snapshot_path = self.collect_snapshot(log_dir=self.snapshot_dir)
        logging.info("Snapshot collected in: {}".format(snapshot_path))
        bts_part_files = snapshot_analyzer._get_bts_zip_files_list(directory=snapshot_path)
        latest_sfp_pm_counters_file = self._get_latest_sfp_pm_counter_file_name(snapshot_path)
        if latest_sfp_pm_counters_file is None and wait_for_next_pm:
            logging.warning("No PM counters with SFP params in Snapshot, waiting {}min for next PM counters"
                            .format(pm_interval))
            time.sleep(pm_interval * 60)
            self._get_latest_sfp_pm_counter_file_from_snapshot(wait_for_next_pm=False)
        latest_sfp_pm_counters_file_gz = snapshot_analyzer._get_specific_snapshot_file(bts_part_files,
                                                                                       latest_sfp_pm_counters_file)
        return latest_sfp_pm_counters_file_gz, snapshot_path
