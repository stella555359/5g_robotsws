import os
from datetime import datetime
from time import sleep

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.bip_log_collector import \
    BipLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.btslog_collector import (
    Btslog5GCollector, BtslogLTECollector)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.elt_log_collector import \
    EltLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.qxdm_log_collector import \
    QxdmLogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.snapshot_log_collector import (
    Snapshot5GCollector, SnapshotLTECollector)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.tcpdump_log_collector import (
    NGAPLogCollector, X2APLogCollector)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.log_collectors.tti_collector import \
    TTILogCollector
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.meta_test.meta_test import (
    AdminInterface, CollectorsInterface, MetaTestInterface, TafUeInterface)
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wireshark_plugin_downloader import \
    PluginManager


class PerfCapTestInterface(MetaTestInterface, CollectorsInterface, TafUeInterface, AdminInterface):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.output_csv = None
        self._log_prefix_path = ""
        self._additional_time_to_wait_after_cells_are_online_after_commissioning = 60
        self._sw_branch = ""

    def suite_setup(self, config=None):
        super().suite_setup(config)
        self.load_robot_taf_ue()
        self.backup_scfs()
        self._sw_branch = self.get_active_software().split("_")[0]
        PluginManager().prepare_mcshark()

    def test_setup(self, testname=None):
        super().test_setup(testname)
        self.setup_admins(self.cfg.mode, self.common_cfg.multirat)
        self.setup_all_collectors()
        self.start_test_collectors()
        self.commission_bts_if_requested()
        self._log_prefix_path = os.path.join(self.test_dir, self._get_formatted_log_prefix())
        self.output_csv = f"{self._log_prefix_path}.csv"
        self._create_output_csv()

    def test_teardown(self):
        self.stop_test_collectors()
        self.download_test_logs(self._log_prefix_path)
        super().test_teardown()

    def setup_all_collectors(self):
        if self.cfg.ue_log:
            ue_log_collector = EltLogCollector() if self.cfg.ue_app.upper() == "ELT" else QxdmLogCollector()
            self.add_verification_collector(ue_log_collector)
        if self.cfg.bip:
            self.add_verification_collector(BipLogCollector())
        if self.cfg.tti:
            self.add_verification_collector(TTILogCollector())
        if self.cfg.snapshot:
            self.add_test_collector(Snapshot5GCollector())
            if self.cfg.mode == "NSA" and not self.common_cfg.multirat:
                self.add_test_collector(SnapshotLTECollector())
        if self.cfg.btslog:
            if self.cfg.analyze_btslog:
                self.add_verification_collector(Btslog5GCollector())
                if self.cfg.mode == "NSA" and not self.common_cfg.multirat:
                    self.add_verification_collector(BtslogLTECollector())
            else:
                self.add_test_collector(Btslog5GCollector())
                if self.cfg.mode == "NSA" and not self.common_cfg.multirat:
                    self.add_test_collector(BtslogLTECollector())
        if self.cfg.tcpdump:
            if self.cfg.mode == "NSA" and not self.common_cfg.multirat:
                self.add_verification_collector(X2APLogCollector())
            else:
                self.add_verification_collector(NGAPLogCollector())
        super().setup_all_collectors()
        if self.cfg.ue_log:
            ue_log_collector.set_logging_filter()

    def backup_scfs(self):
        if self.common_cfg.backup_scf_5g:
            self.save_5g_scf_file(local_dir=self.suite_dir)
        if self.common_cfg.backup_scf_lte:
            self.save_lte_scf_file(local_dir=self.suite_dir)

    def commission_bts_if_requested(self):
        self.commission_bts(scf_5g=self.cfg.scf_5g, scf_lte=self.cfg.scf_lte)
        self.wait_for_testline_cells_on_air(
            mode=self.cfg.mode, multirat=self.common_cfg.multirat, timeout=420, interval=10
        )
        if self.cfg.scf_5g or self.cfg.scf_lte:
            sleep(self._additional_time_to_wait_after_cells_are_online_after_commissioning)

    def _create_output_csv(self):
        with open(self.output_csv, "w") as output_file:
            output_file.write(",".join(self.cfg.csv_header))
            output_file.write("\n")

    def _get_formatted_log_prefix(self):
        try:
            prefix = self.cfg.log_prefix.format(
                datetime=datetime.now().strftime("%Y-%m-%d__%H:%M:%S"), testname=self.testname
            )
        except KeyError:
            prefix = self.cfg.log_prefix
        return prefix

    def _logs_to_collect_list(self):
        names = ("BIP", "UE_LOG", "TTI", "SNAPSHOT", "BTSLOG", "TCPDUMP")
        collected = (self.cfg.bip, self.cfg.ue_log, self.cfg.tti, self.cfg.snapshot, self.cfg.btslog, self.cfg.tcpdump)
        return [name for name, is_collected in zip(names, collected) if is_collected]

    def gather_logs(self, iteration):
        raise NotImplementedError

    def analyze_logs(self, logs):
        raise NotImplementedError
