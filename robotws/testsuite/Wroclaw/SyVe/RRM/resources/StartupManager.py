from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsAdminApi import BtsAdminApi
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults, \
    INCOMPATIBLE_SW_ON_RADIOS_FAULT_ID
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsOs import BtsOs
from testsuite.Wroclaw.SyVe.RRM.resources.TestEnvData import TestEnvData as Env
from testsuite.Wroclaw.SyVe.RRM.resources.Pdu import Pdu as Pdu
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState, NOK_STATUSES
from testsuite.Wroclaw.SyVe.RRM.resources.SwDownloader import SwDownloader
from testsuite.Wroclaw.SyVe.RRM.resources.RemoteBtsManager import RemoteBtsManager
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsSw import BtsSw
from testsuite.Wroclaw.SyVe.RRM.resources.Troubleshooting import Troubleshooting
from testsuite.Wroclaw.SyVe.RRM.resources.Swconfig import Swconfig, BASIC_FLAGS
from time import sleep, time

CELL_DEP_TYPE_SA = "SA"


class StartupManager(object):

    def __init__(self):
        self.config = BtsConfig()
        self.faults = BtsFaults()
        self.bts_state = BtsState()
        self.bts_sw = BtsSw()
        self.dl_sw = SwDownloader()
        self.remote_manager = RemoteBtsManager()

    def confirm_sw_version_and_make_sure_bbu_modules_are_enabled_after_installation(self):
        Troubleshooting().check_if_gnb_is_pingable_via_lmp_and_freeze_test_line_otherwise()
        Swconfig().update_swconfig_flags(BASIC_FLAGS)
        running_sw = self.bts_state.get_gnb_running_sw_version()
        Logger.info(f"Running BTS SW is {running_sw}")
        err_msg = f"Incorrect SW version is running on the gNB: '{running_sw}' " \
                  f"than the SUT SW: '{Env.RELEASE_SW_VERSION}'"
        if Env().is_trunk_sw_under_test:
            assert Env.MINOR_SW_VERSION in running_sw, err_msg
        else:
            assert running_sw.strip() == Env.RELEASE_SW_VERSION.strip(), err_msg
        Troubleshooting().check_historical_faults_and_freeze_test_line_if_forbidden_fault_found()
        Logger.info("Checking if all BB modules are working fine after activating {}".format(Env.BUILD_SW_VERSION))
        if self.bts_state.are_bb_cards_online():
            return
        self._wait_for_bb_modules_and_perform_power_reset_as_recovery_action_if_needed()

    def update_sw_and_commission_remote_bts(self, feature,  bts_name,
                                            ssh_connection_details=Env.LTE_VM_SSH_CONN_DETAILS, *scf_path_params,
                                            bts_id=0, recommission_node=False):
        """
        Function calls full config reset procedure with sw update to the being under the test BTS SW
        commissions the BTS to the given SCF for the feature and waits for OnAir with possible incompatible Sw on Radio
        handling
        :param feature: full feature number used in the repository path (case sensitive)
        :param bts_name: full unique BTS ID from SCF file to distinguish SCF for the remote BTS to be commissioned
                       for example: MRBTS-40442, MRBTS-50441
        :param ssh_connection_details: remote SSH connection details taf object read from the init file
        :param scf_path_params: additional parameters for SCF file lookup
        :param bts_id: id of bts in regard to testline list of gNBs/eNBs
        :param recommission_node: force performing commissioning even if SW is correct and BTS is OnAir
        :return: None
        """
        faults_to_skip = None
        Logger.info("Updating SW and determining REMOTE BTS to reach OnAir")
        self.remote_manager.perform_update_and_manage_startup_to_on_air(feature=feature, bts_name=bts_name,
                                                                        ssh_connection_details=ssh_connection_details,
                                                                        bts_id=bts_id, faults_to_skip=faults_to_skip,
                                                                        recommission_node=recommission_node,
                                                                        *scf_path_params)

    def manage_commissioned_remote_bts_to_reach_on_air_state(self, bts_name,
                                                             ssh_connection_details, faults_to_skip=None):
        self.remote_manager.manage_commissioned_remote_bts_to_reach_on_air_state(bts_name, ssh_connection_details,
                                                                                 faults_to_skip)

    def manage_commissioned_bts_to_reach_on_air_state(self, bts_name=None):
        """
        Function checks for raised incompatible SW on Radios or BTS is OnAir.
        Tries to update SW in case of incompatibility within default sw update function timeout
        :return: None
        """
        Logger.info("Determining BTS state to reach OnAir")
        is_sw_update_needed = self.is_incompatible_sw_on_radios_raised_during_bts_startup()
        if not is_sw_update_needed and self.bts_state.are_all_cells_on_air():
            if not self.bts_state.are_all_cell_dep_type_as_expected(CELL_DEP_TYPE_SA):
                self.wait_for_x2_connected()
            self.bts_state.confirm_that_all_cells_are_on_air()
            Troubleshooting().freeze_test_line_for_task_force_if_forbidden_faults_or_connectivity_problems_detected()
            return
        elif is_sw_update_needed:
            self.bts_sw.try_to_update_software_ignoring_procedure_failures(self.dl_sw.download_current_software())
        try:
            self.wait_for_all_cells_on_air()
        except Exception as startup_error:
            Logger.warning(f"Startup not successful, problem found: {startup_error}")
            raise startup_error
        finally:
            Troubleshooting().freeze_test_line_for_task_force_if_forbidden_faults_or_connectivity_problems_detected()

    def manage_commissioned_bts_dss_radio_sharing(self):
        """
        Function checks for raised incompatible SW on Radios.
        Tries to update SW in case of incompatibility within default sw update function timeout
        The bts could reach onAir state, this depends from 4g status
        :return: None
        """
        NOK_STATUSES.remove('degraded')
        Logger.info("Check and update SW no radios if required, DSS gnb radio_sharing")
        is_sw_update_needed = self.is_incompatible_sw_on_radios_raised_during_bts_startup()
        if not is_sw_update_needed:
            return
        self.bts_sw.try_to_update_software_ignoring_procedure_failures(self.dl_sw.download_current_software())

    def is_incompatible_sw_on_radios_raised_during_bts_startup(self, timeout=900, interval=30):
        """
        Checks within timeout for incompatible SW, breaking loop in case of BTS OnAir status
        :param timeout: procedure time limit
        :param interval: sleeping period for the next attempt
        :return: True if SW is incompatible, False otherwise (BTS OnAir or timeout)
        """
        self.wait_for_all_configured_radios_appeared()
        Logger.info("Checking periodically for {}m every "
                    "{}s to confirm is SW incompatible on Radio or BTS is OnAir".format(timeout//60, interval))
        end_time = time() + timeout
        while not self.bts_state.are_all_cells_on_air() and end_time > time():
            Troubleshooting().check_active_fault_and_freeze_test_line_if_forbidden_fault_found()
            if self.faults.is_fault_active(INCOMPATIBLE_SW_ON_RADIOS_FAULT_ID):
                Logger.info("Incompatible SW detected on Radio")
                return True
            sleep(interval)
        Logger.info(f"The {timeout}s waiting time for incompatible SW on Radio has expired or BTS is OnAir")
        return False

    def wait_for_all_cells_on_air(self, timeout=900, interval=10):
        """
        Waits given time for all cells are Online
        :param timeout: procedure time limit
        :param interval: sleeping period for the next attempt
        :return: None
        """
        Logger.info("Waiting up to {}m for OnAir".format(timeout//60))
        end_time = time() + timeout
        while not self.bts_state.are_all_cells_on_air() and end_time > time():
            Troubleshooting().check_active_fault_and_freeze_test_line_if_forbidden_fault_found()
            sleep(interval)
            Logger.info("BTS is not yet OnAir")
        self.bts_state.confirm_that_all_cells_are_on_air()

    def wait_for_cell_on_air(self, cell_id, timeout=900, interval=10):
        """
        Waits given time for cell are Online
        :param cell_id: cell id to check
        :param timeout: procedure time limit
        :param interval: sleeping period for the next attempt
        :return: None
        """
        Logger.info("Waiting up to {}m for cell NRCELL_R-{} get OnAir".format(timeout//60, cell_id))
        end_time = time() + timeout
        while not self.bts_state.is_cell_on_air(cell_id) and end_time > time():
            sleep(interval)
        self.bts_state.confirm_that_cell_is_on_air(cell_id)

    def wait_for_all_configured_radios_appeared(self, timeout=900, interval=10):
        Logger.info("Waiting up to {}m for RF modules".format(timeout // 60))
        end_time = time() + timeout
        while not self.bts_state.are_all_rf_modules_detected() and end_time > time():
            Troubleshooting().check_active_fault_and_freeze_test_line_if_forbidden_fault_found()
            sleep(interval)
        assert timeout > 0, "Not All RF modules are ready, please check active faults"

    def _wait_for_bb_modules_and_perform_power_reset_as_recovery_action_if_needed(self, expected_uptime_min=10):
        bts_uptime = BtsOs().get_uptime_in_seconds()
        if self._are_bb_modules_ready_in_expected_bts_uptime(bts_uptime, expected_uptime_min):
            return
        else:
            self.faults.log_active_faults()
            Pdu().perform_gnb_power_reset()
            BtsAdminApi().wait_for_admin_connection_possibility()
        assert self._are_bb_modules_ready_in_expected_bts_uptime(BtsOs().get_uptime_in_seconds(),
                                                                 expected_uptime_min), \
            "Not All BB modules are ready, please check active faults"

    def _are_bb_modules_ready_in_expected_bts_uptime(self, bts_uptime, expected_bts_uptime_min):
        timeout = expected_bts_uptime_min*60 - bts_uptime
        interval = 20
        end_time = time() + timeout
        Logger.debug(f"Waiting for {timeout//60}m for all BB Modules enabled")
        while end_time > time():
            sleep(interval)
            if self.bts_state.are_bb_cards_online():
                return True
        return False

    def wait_for_x2_connected(self, timeout=900, interval=10, gnb_id=0, lmp_ip_if_gnb0=True):
        Logger.info(f"Waiting up to {timeout//60}m for x2 on GNB_{gnb_id}")
        end_time = time() + timeout
        while (not self.bts_state.is_x2_link_available(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0)
               and end_time > time()):
            sleep(interval)
        assert self.bts_state.is_x2_link_available(gnb_id=gnb_id, lmp_ip_if_gnb0=lmp_ip_if_gnb0), \
            f'LTEENB x2 link is not available on GNB_{gnb_id}'
        Logger.info(f'LTEENB x2 link is available on GNB_{gnb_id}')
