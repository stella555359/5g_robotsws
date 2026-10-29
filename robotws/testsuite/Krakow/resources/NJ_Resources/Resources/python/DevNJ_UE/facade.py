from .provider import UeProvider


class CommonUe(object):
    def __init__(self, ue_index):
        """
        Class for providing a consistent interface for a set of interfaces in the sub UE class.
        """
        self._ue_instance = UeProvider(ue_index).get_ue_interface()

    def login_ue(self):
        self._ue_instance.login_ue()

    def logout_ue(self):
        self._ue_instance.logout_ue()

    def attach_ue(self):
        self._ue_instance.attach_ue()

    def detach_ue(self):
        self._ue_instance.detach_ue()

    def reboot_ue(self):
        self._ue_instance.reboot_ue()

    def __del__(self):
        print("Delete {}".format(self._ue_instance))
        del self._ue_instance

    def ue_attach_and_start_adb_log(self, ue_index):
        self._ue_instance.ue_attach_and_start_adb_log(ue_index)

    def start_and_verify_dl_udp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                dl_expect_tput, dl_deviation):
        self._ue_instance.start_and_verify_dl_udp(dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                                  dl_expect_tput, dl_deviation)

    def start_and_verify_ul_udp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                ul_expect_tput, ul_deviation):
        self._ue_instance.start_and_verify_ul_udp(dt_name, ue_index, direction, duration, iperf_ul_throughput,
                                                  protocol, ul_expect_tput, ul_deviation)

    def start_and_verify_dl_tcp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                dl_expect_tput, dl_deviation):
        self._ue_instance.start_and_verify_dl_tcp(dt_name, ue_index, direction, duration, iperf_throughput,
                                                  protocol, dl_expect_tput, dl_deviation)

    def start_and_verify_ul_tcp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                ul_expect_tput, ul_deviation):
        self._ue_instance.start_and_verify_ul_tcp(dt_name, ue_index, direction, duration, iperf_ul_throughput,
                                                  protocol, ul_expect_tput, ul_deviation)

    def start_dl_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        self._ue_instance.start_dl_async_process(index, t_put, tput_dura, protocol, data_trans_name)

    def start_ul_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        self._ue_instance.start_ul_async_process(index, t_put, tput_dura, protocol, data_trans_name)

    def calculate_and_verify_dl_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='dl_test', protocol='udp'):
        self._ue_instance.calculate_and_verify_dl_async_tput(index, expect_tput, deviation, tput_dura,
                                                             data_trans_name=data_trans_name, protocol=protocol)

    def calculate_and_verify_ul_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='ul_test', protocol='udp'):
        self._ue_instance.calculate_and_verify_ul_async_tput(index, expect_tput, deviation, tput_dura,
                                                             data_trans_name=data_trans_name, protocol=protocol)

    def ue_postcondition(self, ue_num):
        self._ue_instance.ue_postcondition(ue_num)

    # SMAWave UE Specific
    def get_frequency_locking_information(self):
        result = self._ue_instance.get_frequency_locking_information()
        return result

    def lock_4g_or_5g_frequency(self, tech, xfcn, _4g_pci_or_5g_scs):
        self._ue_instance.lock_4g_or_5g_frequency(tech, xfcn, _4g_pci_or_5g_scs)

    def unlock_4g_or_5g_frequency(self, tech):
        self._ue_instance.unlock_4g_or_5g_frequency(tech)

    def set_ue_sa_mode_disable(self):
        self._ue_instance.set_ue_sa_mode_disable()

    def set_ue_sa_mode_enable(self):
        self._ue_instance.set_ue_sa_mode_enable()

    # Android UE Specific
    def verify_5g_success_and_stop_adb_log(self, lte_cell_index):
        result = self._ue_instance.verify_5g_success_and_stop_adb_log(lte_cell_index)
        return result

    def stop_adb_log(self):
        self._ue_instance.stop_adb_log()

    def is_exception_ue(self):
        is_exception_ue = self._ue_instance.is_exception_ue()
        return is_exception_ue

    def reserve_ue(self):
        self._ue_instance.reserve_ue()

    def android_dl_traffic_with_cmd(self, duration, iperf_throughput, dl_expect_tput, dl_deviation, window_size):
        self._ue_instance.android_dl_traffic_with_cmd(duration, iperf_throughput, dl_expect_tput, dl_deviation,
                                                      window_size)

    def android_ul_traffic_with_cmd(self, duration, iperf_ul_throughput, ul_expect_tput, ul_deviation):
        self._ue_instance.android_ul_traffic_with_cmd(duration, iperf_ul_throughput, ul_expect_tput, ul_deviation)

    def check_adb_devices_and_reboot_uepc(self):
        self._ue_instance.check_adb_devices_and_reboot_uepc()

    def fetch_ue_address(self):
        self._ue_instance.fetch_ue_address()

    def set_apn(self, apn_name):
        self._ue_instance.set_apn(apn_name)

    def verify_attached_cell_id(self, cell_id):
        self._ue_instance.verify_attached_cell_id(cell_id)

    def set_default_gateway(self):
        self._ue_instance.set_default_gateway()
