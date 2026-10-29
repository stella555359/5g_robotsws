from testsuite.Wroclaw.SyVe.RRM.CB006991.Res6991 import *
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.collectors.SyslogCollector import SyslogCollector

RIMRI_ALARM_ID = 7525
RIM_RI_MANAGER = 'isRiDetected:1'


class ResCni95601(Res6991):

    def __init__(self):
        super(ResCni95601, self).__init__()
        self.feature = "CNI95601"
        self.bts_config = BtsConfig()
        self.bts_faults = BtsFaults()
        self.syslog = SyslogCollector()
        self.interval = 60
        self.timeout = 30*self.interval

    def commissioned_victim_gnb_with_feature_cni95601_activated(self):
        scf_file = ScfPathFinder().get_scf_path_for_feature(self.feature, 'victim')
        self.bts_config.perform_full_commissioning(scf_file)

    def rimrimanager_is_stored_in_syslog(self):
        nr_of_rimrimanager = self.get_mesgs_count_in_syslog(RIM_RI_MANAGER)
        assert nr_of_rimrimanager >= 1, "Unexpected number={} of RimRsManager".format(nr_of_rimrimanager)

    def rimri_alarm_is_active(self):
        Logger.info("SYSLOG is going to be collected for 30 minutes and RIM alarm activation is going to be monitored. "
                    "Starting now - please wait")
        while not self.bts_faults.is_fault_active(RIMRI_ALARM_ID) and self.timeout > 0:
            self.timeout -= self.interval
            sleep(self.interval)
        Logger.info("Waiting 5 more minutes for SYSLOG to update")
        sleep(5*self.interval)
