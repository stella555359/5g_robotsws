from abc import ABCMeta, abstractmethod


class BasicUe(object):
    """
    This class only reserves the abstract functions which used by both SMAWave and Android.
    """
    __metaclass__ = ABCMeta

    @abstractmethod
    def attach_ue(self):
        pass

    @abstractmethod
    def detach_ue(self):
        pass

    @abstractmethod
    def reboot_ue(self):
        pass

    @abstractmethod
    def ue_attach_and_start_adb_log(self, ue_index):
        pass

    @abstractmethod
    def start_and_verify_dl_udp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                dl_expect_tput, dl_deviation):
        pass

    @abstractmethod
    def start_and_verify_ul_udp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                ul_expect_tput, ul_deviation):
        pass

    @abstractmethod
    def start_dl_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        pass

    @abstractmethod
    def start_ul_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        pass

    @abstractmethod
    def calculate_and_verify_dl_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='dl_test', protocol='udp'):
        pass

    @abstractmethod
    def calculate_and_verify_ul_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='ul_test', protocol='udp'):
        pass

    @abstractmethod
    def fetch_ue_address(self):
        pass
