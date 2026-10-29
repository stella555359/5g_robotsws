from .facade import CommonUe
from functools import wraps
from robot.api import logger
from taf.internal.aliasing import aliasing_scope
from testsuite.Krakow.resources.SMAwave_kws.python.DevNJ_UE.common.ue_config import UeYamlConfiguration


def manage_ue_instance(func):
    """
    Not used for now.
    It can be used as decorator for functions in class CommonUeInterface.
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        ret = None
        if len(args) > 1:
            print("Parameter is a tuple: ue_index={}".format(args[1]))
            ue_index = args[1]
        elif 'ue_index' in kwargs.keys():
            print("Parameter is a dictionary: ue_index={}".format(kwargs['ue_index']))
            ue_index = kwargs['ue_index']
        global ue
        ue = CommonUe(ue_index)
        ret = func(*args, **kwargs)
        # ue.__del__()
        return ret
    return wrapper


class CommonUeInterface(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    lookup_handler, store = aliasing_scope()

    def __init__(self):
        """
        Class for providing keyword interface.
        """
        self.ue_config_instance = UeYamlConfiguration()
        self.ue_num = self.ue_config_instance.ue_num()

    def set_ue_variables(self):
        """
        Stand-alone Keyword
        This function has no actual function, it is kept only for legacy KW.
        """
        logger.info("\nThis is legacy keyword, please don't call this keyword in the future", also_console=True)
        return self.ue_config_instance.setup_ue_variables()

    @staticmethod
    def setup_ue_instance(ue_index):
        return CommonUe(ue_index)

    def reboot_ues(self, ue_index):
        """
        Stand-alone Keyword
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
            self.store.add(ue_obj, alias=ue_index)
        ue_obj.reboot_ue()

    def ue_attach_only(self, ue_index):
        """
        Stand-alone Keyword
        Not recommended KW, it is kept only due to legacy feature.
        Postconditions_ForUE is needed
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
            self.store.add(ue_obj, alias=ue_index)
        ue_obj.attach_ue()

    def ue_detach_only(self, ue_index):
        """
        Stand-alone Keyword
        Not recommended KW, it is kept only due to legacy feature.
        Postconditions_ForUE is needed
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
            self.store.add(ue_obj, alias=ue_index)
        ue_obj.detach_ue()
        self.store.remove(ue_index)

    def attach_all_ues(self):
        """
        Not recommended KW, it is kept only due to legacy feature.
        """
        for ue_index in range(1, self.ue_num + 1):
            self.ue_attach_only(ue_index)

    def detach_all_ues(self):
        """
        Not recommended KW, it is kept only due to legacy feature.
        """
        for ue_index in range(1, self.ue_num + 1):
            self.ue_detach_only(ue_index)

    def ue_attach_and_start_adb_log(self, ue_index):
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
            self.store.add(ue_obj, alias=ue_index)
        ue_obj.ue_attach_and_start_adb_log(ue_index)

    def start_and_verify_downlink_tcp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                      dl_expect_tput, dl_deviation):
        ue_obj = self.store.get(ue_index)
        ue_obj.start_and_verify_dl_tcp(dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                       dl_expect_tput, dl_deviation)

    def start_and_verify_uplink_tcp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                    ul_expect_tput, ul_deviation):
        ue_obj = self.store.get(ue_index)
        ue_obj.start_and_verify_ul_tcp(dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                       ul_expect_tput, ul_deviation)

    def start_and_verify_downlink_udp(self, dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                      dl_expect_tput, dl_deviation):
        ue_obj = self.store.get(ue_index)
        ue_obj.start_and_verify_dl_udp(dt_name, ue_index, direction, duration, iperf_throughput, protocol,
                                       dl_expect_tput, dl_deviation)

    def start_and_verify_uplink_udp(self, dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                    ul_expect_tput, ul_deviation):
        ue_obj = self.store.get(ue_index)
        ue_obj.start_and_verify_ul_udp(dt_name, ue_index, direction, duration, iperf_ul_throughput, protocol,
                                       ul_expect_tput, ul_deviation)

    def reserve_ues(self):
        """
        This keyword is only used for Android UEs, please do not use it for SMAWave UEs
        """
        for ue_index in range(1, self.ue_num + 1):
            ue_obj = self.setup_ue_instance(ue_index)
            ue_obj.reserve_ue()

    def verify_5g_success_and_stop_adb_log(self, ue_index, lte_cell_index):
        """
        This keyword is only used for Android UEs, please do not use it for SMAWave UEs.
        It is always used after the KW "ue_attach_and_start_adb_log".
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        result = ue_obj.verify_5g_success_and_stop_adb_log(lte_cell_index)
        return result

    def stop_adb_log(self):
        """
        This keyword is only used for Android UEs, please do not use it for SMAWave UEs.
        It is always used after the KW "ue_attach_and_start_adb_log".
        """
        for ue_index in range(1, self.ue_num + 1):
            ue_index = str(ue_index)
            try:
                ue_obj = self.store.get(ue_index)
            except Exception:
                continue
            ue_obj.stop_adb_log()

    def postconditions_forue(self):
        """
        This keyword is to perform SMAWave/Android UE teardown operation.
        It must be called in Teardown section of test case.
        """
        for ue_index in range(1, self.ue_num + 1):
            ue_index = str(ue_index)
            try:
                ue_obj = self.store.get(ue_index)
            except Exception:
                continue
            ue_obj.ue_postcondition(self.ue_num)
            try:
                self.store.remove(ue_index)
            except Exception:
                continue

    def start_dl_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        ue_obj = self.store.get(index)
        ue_obj.start_dl_async_process(index, t_put, tput_dura, protocol, data_trans_name)

    def start_ul_async_process(self, index, t_put, tput_dura, protocol, data_trans_name):
        ue_obj = self.store.get(index)
        ue_obj.start_ul_async_process(index, t_put, tput_dura, protocol, data_trans_name)

    def calculate_and_verify_dl_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='dl_test', protocol='udp'):
        ue_obj = self.store.get(index)
        ue_obj.calculate_and_verify_dl_async_tput(index, expect_tput, deviation, tput_dura,
                                                  data_trans_name, protocol)

    def calculate_and_verify_ul_async_tput(self, index, expect_tput, deviation, tput_dura,
                                           data_trans_name='ul_test', protocol='udp'):
        ue_obj = self.store.get(index)
        ue_obj.calculate_and_verify_ul_async_tput(index, expect_tput, deviation, tput_dura, data_trans_name, protocol)

    def is_exception_ue(self, ue_index):
        """
        Stand-alone Keyword
        This keyword is only used for Android UEs, please do not use it for SMAWave UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        is_exception_ue = ue_obj.is_exception_ue()
        return is_exception_ue

    def android_dl_traffic_with_cmd(self, ue_index, duration, iperf_throughput, dl_expect_tput, dl_deviation,
                                    window_size='20m'):
        """
        Stand-alone Keyword
        """
        ue_obj = self.store.get(ue_index)
        ue_obj.android_dl_traffic_with_cmd(duration, iperf_throughput, dl_expect_tput, dl_deviation, window_size)

    def android_ul_traffic_with_cmd(self, ue_index, duration, iperf_ul_throughput, ul_expect_tput, ul_deviation):
        """
        Stand-alone Keyword
        """
        ue_obj = self.store.get(ue_index)
        ue_obj.android_ul_traffic_with_cmd(duration, iperf_ul_throughput, ul_expect_tput, ul_deviation)

    def get_frequency_locking_information(self, ue_index):
        """
        Stand-alone Keyword
        This keyword is only used for SMAWave UEs, please do not use it for Android UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        result = ue_obj.get_frequency_locking_information()
        return result

    def lock_4g_or_5g_frequency(self, ue_index, tech, xfcn, pci_4g_or_scs_5g):
        """
        Stand-alone Keyword
        This keyword is only used for SMAWave UEs, please do not use it for Android UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        ue_obj.lock_4g_or_5g_frequency(tech, xfcn, pci_4g_or_scs_5g)

    def unlock_4g_or_5g_frequency(self, ue_index, tech):
        """
        Stand-alone Keyword
        This keyword is only used for SMAWave UEs, please do not use it for Android UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        ue_obj.unlock_4g_or_5g_frequency(tech)

    def check_adb_devices_and_reboot_uepc(self, ue_index):
        """
        Sometimes Android UE is ADB offline status, use this KW to reboot UEPC as a workaround.
        Note : This KW is used only for Android Traffic with CMD case, and use it after "Reboot UEs".
        This keyword is only used for Android UEs, please do not use it for SMAWave UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        ue_obj.check_adb_devices_and_reboot_uepc()

    def fetch_ue_address(self, ue_index):
        """
        This keyword used to get UE IP address after attach operation.
        Note: for SMAWave, please ensure COMD service restart otherwise can't obtain assigned address.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        ue_obj.fetch_ue_address()

    def set_ue_sa_mode_disable(self, ue_index):
        """
        Stand-alone Keyword
        This keyword is only used for SMAWave UEs, please do not use it for Android UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        ue_obj.set_ue_sa_mode_disable()

    def set_ue_sa_mode_enable(self, ue_index):
        """
        Stand-alone Keyword
        This keyword is only used for SMAWave UEs, please do not use it for Android UEs.
        """
        try:
            ue_obj = self.store.get(ue_index)
        except Exception:
            ue_obj = self.setup_ue_instance(ue_index)
        ue_obj.set_ue_sa_mode_enable()
