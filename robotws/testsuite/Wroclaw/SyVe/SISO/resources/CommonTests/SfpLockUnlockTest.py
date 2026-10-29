from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsConfig import BtsConfig
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsOam import BtsOam
from testsuite.Wroclaw.SyVe.RRM.resources.StartupManager import StartupManager
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsFaults import BtsFaults
from testsuite.Wroclaw.SyVe.RRM.resources.BtsAdmin.BtsState import BtsState
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from time import sleep

TIMEOUT_20MIN = 20*60
INTERVAL_5SEC = 5


class SfpLockUnlockTest(object):

    def __init__(self):
        self.bts_config = BtsConfig()
        self.bts_startup = StartupManager()
        self.bts_faults = BtsFaults()
        self.bts_oam = BtsOam()
        self.bts_state = BtsState()

    def perform_sfp_lock_unlock_test(self, bts_id, bbmods_sfps_to_test):
        for bbmod, sfps in bbmods_sfps_to_test.items():
            for sfp in sfps:
                if self._check_if_sfp_has_synchonization_role(sfp, bbmod):
                    Logger.info(f'BBMOD-{bbmod}/SFP-{sfp} has synchronization role - omitting')
                else:
                    self._lock_sfp(bts_id, bbmod, sfp)
                    self._reset_gnb_and_wait_for_on_air()
                    self._check_if_fault1868_occurred()
                    self._unlock_sfp(bts_id, bbmod, sfp)
                    self._check_if_fault1868_is_not_active_after_unlock_sfp()

    def _lock_sfp(self, bts_id, bbmod_id, sfp_id):
        self.bts_config.perform_parameter_recommissioning(
            dist_name=f'MRBTS-{bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-{bbmod_id}/SFP-{sfp_id}/LANE-1',
            parameters=['administrativeState'], value='Locked')

    def _unlock_sfp(self, bts_id, bbmod_id, sfp_id):
        self.bts_config.perform_parameter_recommissioning(
            dist_name=f'MRBTS-{bts_id}/EQM-1/APEQM-1/CABINET-1/BBMOD-{bbmod_id}/SFP-{sfp_id}/LANE-1',
            parameters=['administrativeState'], value='Unlocked')

    def _check_if_fault1868_occurred(self, timeout=TIMEOUT_20MIN, interval=INTERVAL_5SEC):
        while timeout > 0:
            if self.bts_faults.is_fault_active(fault_id=1868):
                Logger.info('Fault 1868 is visible')
                return
            sleep(interval)
            timeout -= interval
        assert False, "Fault 1868 NOT visible!"

    def _check_if_fault1868_is_not_active_after_unlock_sfp(self):
        if self.bts_faults.is_fault_active(fault_id=1868):
            assert False, "Fault 1868 IS visible after SFP unlock!"

    def _reset_gnb_and_wait_for_on_air(self):
        self.bts_oam.reset_gnb_site()
        self.bts_startup.wait_for_all_configured_radios_appeared()

    def _get_sfp_roles(self, sfp_id, bbmod_id):
        bbmods = self.bts_state.bts_info(gnb_id=0, lmp_ip_if_gnb0=True)['basebandModules']
        cables = self.bts_state.bts_info(gnb_id=0, lmp_ip_if_gnb0=True)['cables']

        for module in bbmods:
            for port in module['ports']:
                if 'configuration' in port['id']:
                    if port['id']['configuration'].endswith(f'BBMOD-{bbmod_id}/SFP-{sfp_id}'):
                        sfp_label = port['label']
                        for cable in cables:
                            if cable['firstEndPointId']['configuration'].endswith(f'BBMOD-{bbmod_id}/{sfp_label}'):
                                return cable['linkMode']
        raise Exception(f"SFP roles not found for BBMOD-{bbmod_id}/SFP-{sfp_id}")

    def _check_if_sfp_has_synchonization_role(self, sfp_id, bbmod_id):
        return self._get_sfp_roles(sfp_id, bbmod_id)['synchronization']
