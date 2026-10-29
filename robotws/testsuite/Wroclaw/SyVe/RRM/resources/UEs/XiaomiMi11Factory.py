from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from time import sleep


class XiaomiMi11Factory(AdbUeBase):

    def __init__(self, id_):
        super(XiaomiMi11Factory, self).__init__(id_)
        self.name = f"UE_{self.id}: Xiaomi Mi 11 {self.ue_sn}"
        self.airplane_button_location = '1245', '2000'
        self.vonr_active = "mVoiceRegState=0(IN_SERVICE)"
        self.vonr_status_cmd = f"adb -s {self.ue_sn} shell 'dumpsys telephony.registry | grep -m1 mVoiceRegState'"

    def get_vonr_status(self):
        return self.vonr_active in self._execute_adb_command(self.vonr_status_cmd)

    def _change_airplane_mode(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.key_event_home_button)
        self._execute_adb_command(self.adb.invoke_airplane_settings)
        sleep(AdbUeBase.AIRPLANE_MODE_SETTING_APPEAR_TIMEOUT)
        self._execute_adb_command(self.adb.tap_on_screen(self.airplane_button_location))
        self._execute_adb_command(self.adb.key_event_go_back)
