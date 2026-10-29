from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from time import sleep


class Nokia83Factory(AdbUeBase):

    def __init__(self, id_):
        super(Nokia83Factory, self).__init__(id_)
        self.name = "UE_{}: Nokia 8.3 {}".format(self.id, self.ue_sn)
        self.change_airplane_mode_on_sequence = [self.adb.key_event_go_up,
                                                 self.adb.key_event_go_down,
                                                 self.adb.key_event_go_down,
                                                 self.adb.key_event_tap_pad_center,
                                                 self.adb.key_event_go_back]
        self.change_airplane_mode_off_sequence = [self.adb.key_event_go_up,
                                                  self.adb.key_event_go_down,
                                                  self.adb.key_event_tap_pad_center,
                                                  self.adb.key_event_go_back]

    def _change_airplane_mode_on(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.key_event_home_button)
        self._execute_adb_command(self.adb.invoke_airplane_settings)
        sleep(AdbUeBase.AIRPLANE_MODE_SETTING_APPEAR_TIMEOUT)
        for action in self.change_airplane_mode_on_sequence:
            sleep(AdbUeBase.UE_GUI_DELAY_TIMEOUT)
            self._execute_adb_command(action)

    def _change_airplane_mode_off(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.key_event_home_button)
        self._execute_adb_command(self.adb.invoke_airplane_settings)
        sleep(AdbUeBase.AIRPLANE_MODE_SETTING_APPEAR_TIMEOUT)
        for action in self.change_airplane_mode_off_sequence:
            sleep(AdbUeBase.UE_GUI_DELAY_TIMEOUT)
            self._execute_adb_command(action)
