from testsuite.Wroclaw.SyVe.RRM.resources.UEs.AdbUeBase import AdbUeBase
from time import sleep


class QualcommSdx65Factory(AdbUeBase):

    def __init__(self, id_):
        super(QualcommSdx65Factory, self).__init__(id_)
        self.name = "UE_{}: Qualcomm SDX65 {}".format(self.id, self.ue_sn)
        self.airplane_button_location = '932', '1172'

    def _change_airplane_mode(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.key_event_home_button)
        self._execute_adb_command(self.adb.invoke_airplane_settings)
        sleep(AdbUeBase.AIRPLANE_MODE_SETTING_APPEAR_TIMEOUT)
        self._execute_adb_command(self.adb.tap_on_screen(self.airplane_button_location))
        self._execute_adb_command(self.adb.key_event_home_button)
