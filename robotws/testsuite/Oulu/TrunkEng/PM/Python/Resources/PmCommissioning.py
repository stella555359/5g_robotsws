import os
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.SCF import SCF
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib import PmCommonLib


class PmCommissioning(object):
    def __init__(self):
        """
        PmCommissioning is a collection of common commissioning methods PM script needs.
        """

        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.scf = SCF()
        self.pm_lib = PmCommonLib()

    @staticmethod
    def wait_after_commissioning(wait_time="30s"):
        info(f"Wait {wait_time} after commissioning")
        BuiltIn().sleep(wait_time)
        info("Done")

    def commission_ntp_ip(self, ip):
        info("Commissioning {} to NTP".format(ip))
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        self.admin.perform_parameter_recommissioning(f"MRBTS-{bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1",
                                                     "ntpServerIpAddrOrFqdnList",
                                                     "update",
                                                     [ip])

    def add_measurements(self, distname, p_name, p_value, interval, meas_intervals=None):
        if meas_intervals:
            # transform_dict = self.pm_lib.find_baseline_measurement_names(reversed_dict=True)
            try:
                if p_name in meas_intervals:
                    info(f"Updating measurement {p_name} interval: {meas_intervals[p_name]}")

                    self.admin.append_parameter_update_to_delta(distname, p_name, (
                        f"{meas_intervals[p_name]}min" if "disabled" not in meas_intervals[p_name] else "disabled"),
                                                                delta_id="pm_update")
            except KeyError:
                info(f"Couldn't find measurement {p_name} from baseline. Using default interval: {interval}min")
        else:
            self.admin.append_parameter_update_to_delta(distname, p_name, (
                    f"{interval}min" if "disabled" not in p_value else "disabled"), delta_id="pm_update")

    def pm_update_intervals(self, period="15", interval="15", pmmnl=False, lnbts_dict=None, cell_dict=None,
                            extra_meas=None, meas_intervals=None, update_intervals=True):
        period = self.pm_lib.strip_min(str(period))
        interval = self.pm_lib.strip_min(str(interval))
        self.admin.create_delta("pm_update")
        info(f"Updating upload period. ({period} min)")
        pmcadm_dn = self.scf.get_distname_based_on_class("PMCADM")[0]
        self.admin.append_parameter_update_to_delta(pmcadm_dn, "reportingIntervalPm", str(period) + "min",
                                                    delta_id="pm_update")

        if update_intervals:
            # Check BTS counter intervals
            info(f"Updating bts intervals. ({interval} min)")
            pmrnl_dict = self.scf.get_class_dict("PMRNL")
            for distname, p_dict in pmrnl_dict.items():
                for p_name, p_value in p_dict.items():
                    if extra_meas:
                        if p_name not in extra_meas:
                            self.add_measurements(distname, p_name, p_value, interval)
                    else:
                        if "mtSIMonitoring" not in p_name:
                            self.add_measurements(distname, p_name, p_value, interval, meas_intervals)

            # Check TRS counter intervals
            info("Updating trs intervals. ({} min)".format(interval))
            pmtnlint_dict = self.scf.get_class_dict("PMTNLINT")
            for distname, p_dict in pmtnlint_dict.items():
                for p_name, p_value in p_dict.items():
                    if p_name not in ("ipDataTrafficVolumeInterval", "utilMeasSampInt"):
                        self.add_measurements(distname, p_name, p_value, interval, meas_intervals)

            if pmmnl:
                pmmnl_dict = self.scf.get_class_dict("PMMNL")
                for distname, p_dict in pmmnl_dict.items():
                    for p_name, p_value in p_dict.items():
                        if p_name not in ("mtSIMonitoring", "mtSBTSSIMon", "actZeroCounterSuppression"):
                            self.add_measurements(distname, p_name, p_value, interval, meas_intervals)

            if lnbts_dict:
                lnbts_dn = self.scf.get_distname_based_on_class("LNBTS")[0]
                for lnbts_key, lnbts_value in lnbts_dict.items():
                    info(f"Updating LNBTS parameter {lnbts_key} to {lnbts_value}")
                    self.admin.append_parameter_update_to_delta(lnbts_dn, lnbts_key, lnbts_value, delta_id="pm_update")
            if cell_dict:
                for cell_dn, cell_values in cell_dict.items():
                    for cell_key, cell_value in cell_values.items():
                        info(f"Updating cell parameter {cell_key} to {cell_value}")
                        self.admin.append_parameter_update_to_delta(cell_dn, cell_key, cell_value, delta_id="pm_update")

        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, "intervals_{}.json".format(timestamp))
        self.admin.save_delta(path_to_delta_file, delta_id="pm_update")
        self.admin.perform_delta_recommissioning(path_to_delta_file, skip_parameter_relation_errors=True)

    def enable_sfp_monitoring(self, period="15"):
        """
        With this method we change SFP monitoring periods and enable monitoring. Saves delta file to test logs with name
        enable_sfp_<timestamp>.json.
        :param period: Time of measurement period

        Changes values of following parameters from disabled to user given value:
        <managedObject class="com.nokia.srbts.mnl:PMMNL" distName="MRBTS-****/MNL-1/MNLENT-1/PMMNL-1"...
            <p name="mtSBTSSfpBBMOD">disabled</p>
            <p name="mtSBTSSfpRMOD">disabled</p>
            <p name="mtSBTSSfpSMOD">disabled</p>
            <p name="mtSbtsSfpBbmodLane">disabled</p>
            <p name="mtSbtsSfpFhs">disabled</p>
            <p name="mtSbtsSfpFhsLane">disabled</p>
            <p name="mtSbtsSfpRmodLane">disabled</p>
            <p name="mtSbtsSfpSmodLane">disabled</p>
            <p name="mtSfp">15min</p
        """
        info("Enable SFP monitoring and update period")
        period = int(self.pm_lib.strip_min(str(period)))
        new_value = f"{period}min"
        self.admin.create_delta("sfp_update")
        pmmnl_dict = self.scf.get_class_dict("com.nokia.srbts.mnl:PMMNL")
        for distname, p_dict in pmmnl_dict.items():
            for p_name, p_value in p_dict.items():
                # if p_name in ("mtSfp", "mtSBTSSfpBBMOD", "mtSBTSSfpRMOD", "mtSBTSSfpSMOD", "mtSbtsSfpBbmodLane",
                #               "mtSbtsSfpFhs", "mtSbtsSfpFhsLane", "mtSbtsSfpRmodLane", "mtSbtsSfpSmodLane"):
                if "mt" in p_name and "Sfp" in p_name:
                    self.admin.append_parameter_update_to_delta(distname, p_name, new_value, delta_id="sfp_update")
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, "enable_sfp_{}.json".format(timestamp))
        self.admin.save_delta(path_to_delta_file, delta_id="sfp_update")
        self.admin.perform_delta_recommissioning(path_to_delta_file, skip_parameter_relation_errors=True)

    def shut_down_cell(self, selected_cell):
        self.admin.perform_parameter_recommissioning(selected_cell, "administrativeState", "update", "shutting down")
        info(f"{selected_cell} is shut down")

    def unlock_cell(self, selected_cell):
        self.admin.perform_parameter_recommissioning(selected_cell, "administrativeState", "update", "unlocked")
        info(f"{selected_cell} is unlocked")

    def lock_unlock_mme(self, lock=True):
        mme_dn = self.scf.get_distname_based_on_class("LNMME")[0]
        self.admin.perform_parameter_recommissioning(mme_dn, "administrativeState", "update",
                                                     "locked" if lock else "unlocked")
        info("MME is locked" if lock else "MME is unlocked")
