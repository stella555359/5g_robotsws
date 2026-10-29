from testsuite.Wroclaw.SyVe.RRM.resources.UEs.QualcommSdx65Factory import QualcommSdx65Factory
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
import time

AIRPLANE_DATA_MODE_SWITCH_TIMEOUT = 3


class QualcommSdx55Factory(QualcommSdx65Factory):

    def __init__(self, id_):
        super(QualcommSdx55Factory, self).__init__(id_)
        self.name = "UE_{}: Qualcomm SDX55 {}".format(self.id, self.ue_sn)
        self.airplane_button_location = '400', '400'
        self.data_button_location = '150', '400'

    def start_dl_tcp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        super(QualcommSdx55Factory, self).start_dl_tcp_transmission(duration, traffic_mb, data_name,
                                                                    buffer_len=kwargs.get("buffer_len", 1400),
                                                                    tcp_window_size=kwargs.get("tcp_window_size",
                                                                                               "2"), **kwargs)

    def start_ul_tcp_transmission(self, duration, traffic_mb, data_name, **kwargs):
        super(QualcommSdx55Factory, self).start_ul_tcp_transmission(duration, traffic_mb, data_name,
                                                                    buffer_len=kwargs.get("buffer_len", 1400),
                                                                    tcp_window_size=kwargs.get("tcp_window_size",
                                                                                               "2"), **kwargs)

    def _change_airplane_and_data_mode_to_attach_ue(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.swipe_down)
        self._execute_adb_command(self.adb.tap_on_screen(self.airplane_button_location))
        time.sleep(AIRPLANE_DATA_MODE_SWITCH_TIMEOUT)
        self._execute_adb_command(self.adb.tap_on_screen(self.data_button_location))
        self._execute_adb_command(self.adb.key_event_home_button)

    def _change_data_and_airplane_mode_to_detach_ue(self):
        self._make_sure_screen_is_on()
        self._execute_adb_command(self.adb.swipe_down)
        self._execute_adb_command(self.adb.tap_on_screen(self.data_button_location))
        time.sleep(AIRPLANE_DATA_MODE_SWITCH_TIMEOUT)
        self._execute_adb_command(self.adb.tap_on_screen(self.airplane_button_location))
        self._execute_adb_command(self.adb.key_event_home_button)

    def _make_sure_screen_is_on(self):
        screen_wake_up_attempt = 15
        time_for_screen_to_wake_up = 1
        while "OFF" in self._execute_adb_command(self.adb.get_screen_state) and screen_wake_up_attempt > 0:
            Logger.debug("{} - the screen was in the state OFF, waking it up".format(self.name))
            self._execute_adb_command(self.adb.key_event_wake_up)
            time.sleep(time_for_screen_to_wake_up)
            self._execute_adb_command(self.adb.swipe_up)
            screen_wake_up_attempt -= 1
