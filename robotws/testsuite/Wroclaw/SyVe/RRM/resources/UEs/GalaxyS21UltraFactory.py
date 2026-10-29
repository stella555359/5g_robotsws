from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from time import sleep

WAIT_FOR_SCREEN_STATE_UPDATE = 10


class GalaxyS21UltraFactory(AdbUeBase):

    def __init__(self, id_):
        super(GalaxyS21UltraFactory, self).__init__(id_)
        self.name = "UE_{}: Samsung Galaxy S21 Ultra {}".format(self.id, self.ue_sn)

    def restart_ue(self):
        Logger.info("{} - will be restarted".format(self.name))
        self._make_sure_ue_is_authorized()
        self._execute_adb_command(self.adb.reboot)
        self._wait_for_ue_is_rebooting()
        self.wait_for_ue_rebooted()
        sleep(WAIT_FOR_SCREEN_STATE_UPDATE)
        self._wait_for_ue_screen_withdrawed_from_doze_suspend_state()

    def _wait_for_ue_screen_withdrawed_from_doze_suspend_state(self, timeout=20, interval=1):
        if "DOZE_SUSPEND" in self._execute_adb_command(self.adb.get_screen_state):
            Logger.warning("{} - the screen was in the state DOZE_SUSPEND, waking it up".format(self.name))
            self._execute_adb_command(self.adb.key_event_wake_up)
            while timeout > 0:
                timeout -= interval
                Logger.debug("Waiting for screen state to turn off...")
                if "OFF" in self._execute_adb_command(self.adb.get_screen_state):
                    Logger.info("UE screen is OFF, ready to begin attach procedure")
                    return
            assert False, "UE screen state was not OFF. The state was: {}".format(
                self._execute_adb_command(self.adb.get_screen_state))

    def _check_if_set_date_and_time_window_appeared(self):
        date_and_time_window_name = "com.android.phone"
        command_output = self._execute_adb_command(self.adb.look_for_set_date_and_time_window())
        Logger.warning("Set date and time window appeared, cancelling...")
        return True if date_and_time_window_name in command_output else False

    def _tap_cancel_on_set_date_and_time_window(self):
        cancel_on_set_date_and_time_window_coordinates = (286, 2098)
        self._execute_adb_command(self.adb.tap_on_screen(cancel_on_set_date_and_time_window_coordinates))

    def _collect_possible_ue_logs(self):
        ue_specific_logs_pattern = "*{}_ue*".format(self.ue_sn)
        self._collect_ue_screenshot()
        self._collect_ue_dumpsys()
        self._download_files_matching_pattern(pattern=ue_specific_logs_pattern)
        self._try_to_remove_files_with_pattern_on_iperf(pattern=ue_specific_logs_pattern)

    def _collect_ue_screenshot(self):
        self._execute_adb_command(self.adb.get_ue_screenshot_and_pass_to_file())

    def _collect_ue_dumpsys(self):
        self._execute_adb_command(self.adb.get_ue_dumpsys_window_log_and_pass_to_file())
