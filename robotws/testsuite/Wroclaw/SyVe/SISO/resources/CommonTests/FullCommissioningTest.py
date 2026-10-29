from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.CommonSuite import CommonSuite


class FullCommissioningTest(CommonSuite):

    def __init__(self):
        super().__init__()
        self.bts_state = BtsState()

    def prepare_testline(self):
        assert self.bts_state.are_all_cells_on_air(), "Not all cells have on-air status."
        self.syslog.start_btslog_on_local_machine()

    def perform_commissioning_test(self, scf_file):
        BtsOs().config_reset()
        self.bts_config.perform_full_commissioning(scf_file)

    def wait_for_all_cells_on_air(self):
        self.startup_manager.wait_for_all_cells_on_air()

    def cleanup_the_setup_and_collect_logs_if_the_test_fails(self):
        super().cleanup_the_setup_and_collect_logs_if_the_test_fails()
