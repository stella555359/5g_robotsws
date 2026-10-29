
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.PM.Python.Resources.exceptions import StateException
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommonLib import PmCommonLib
from testsuite.Oulu.TrunkEng.PM.Python.Resources.PmCommissioning import PmCommissioning


class PmCommissioningInterface(object):

    def __init__(self):
        """
        PmCommissioning is a collection of common commiossining methods PM script needs.
        """

        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.bts = BuiltIn().get_library_instance("BTS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.pmlib = PmCommonLib()
        self.pm_commissioning = PmCommissioning()

    def commission_ntp_ip(self, ip):
        """
       Commission NTP ip

       param str ip:  IP address for NTP
       """
        info("Commissioning {} to NTP".format(ip))
        bts_id = self.bts.get_parameter_value_from_bts_info('btsId')
        self.admin.perform_parameter_recommissioning(
            "MRBTS-{}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1".format(bts_id), "ntpServerIpAddrList", "update", [ip])
        self.pm_commissioning.wait_after_commissioning()

    def check_ntp_availability(self, status="InSync"):
        """
        Check NTP availability via admin cli

        :param str status:  Operational state (InSync/Unavailable/Unknown/Available)
        :raise StateException: Raises error if operational state is different that wanted
        """
        info("Checking that NTP is {}".format(status))
        ntp_distname = "/MRBTS-1/RAT-1/RUNTIME_VIEW-{bts_side}/MRBTS_R-{bts_side}/MNL_CONF_M-1/MNLENT_CONF_M-1/" \
                       "SYNC_CONF_M-1/CLOCK_CONF_M-1/NTP_CONF_M-1/NTP_R-1".format(bts_side=self.bts.side)
        ntp_object = self.admin.get_parameters(ntp_distname)
        current_state = str(ntp_object["ntpServerStatusList"][0]["ntpStatus"]).lower()
        if current_state != status.lower():
            error("NTP was {} instead of {}".format(current_state, status))
            raise StateException("NTP was {} instead of {}".format(current_state, status))
        else:
            info("NTP is {}".format(status))

    def update_pm_data(self, period="15", interval="15", pmmnl=False, lnbts_dict=None, cell_dict=None, extra_meas=None,
                       meas_intervals=None, update_intervals=True):
        """
        Update PM measurements periods and intervals via delta commissioning. Saves intervals_*timestamp*.json to log
        folder

        param str period: Upload period
        param str interval: Measurement interval
        param bool pmmnl: True if PMMNL is used
        param dict lnbts_dict: E.g {value_name, value}
        param dict cell_dict: E.g {cell_dn: {value_name, value}}
        param tuple extra_meas: Extra measurements which are not updated
        param dict meas_intervals: {measurement abbreviation: interval}
        param bool update_intervals: False if only PMCADM is needed to be updated
        """
        self.pm_commissioning.pm_update_intervals(
            period, interval, pmmnl, lnbts_dict, cell_dict, extra_meas, meas_intervals, update_intervals)
        self.pm_commissioning.wait_after_commissioning()

    def enable_sfp_monitoring(self, period="15"):
        """
        Enable SFP monitoring and update period via delta commissioning. Saves enable_sfp_*timestamp*.json to log folder
        param str period: Time of measurement period
        """
        self.pm_commissioning.enable_sfp_monitoring(period)
        self.pm_commissioning.wait_after_commissioning()

    def gcs_procedure(self, selected_cell):
        """
        Graceful Cell Shutdown procedure. Shuts down the cell and waits for 200s
        :param str selected_cell: Distname of selected cell
        """
        self.pm_commissioning.shut_down_cell(selected_cell)
        self.pm_commissioning.wait_after_commissioning("200s")

    def unlock_cell(self, selected_cell):
        """
        Unlocks cell
        :param str selected_cell: Distname of selected cell
        """
        self.pm_commissioning.unlock_cell(selected_cell)
        self.pm_commissioning.wait_after_commissioning()

    def lock_mme(self):
        """
        Locks MME
        """
        self.pm_commissioning.lock_unlock_mme()
        self.pm_commissioning.wait_after_commissioning()

    def unlock_mme(self):
        """
        Unlocks MME
        """
        self.pm_commissioning.lock_unlock_mme(False)
        self.pm_commissioning.wait_after_commissioning()

    @staticmethod
    def set_all_values_to(new_value, meas_dict):
        new_dict = {}
        for meas in meas_dict.keys():
            new_dict[meas] = str(new_value)
        return new_dict
