from testsuite.Wroclaw.SyVe.RRM.resources.UEs.UeFactory import UeFactory, TAF_UE
from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from taf.ue.rpc.jsonrpc import RpcError


class Ue(object):

    def __init__(self, type_=TAF_UE, ue_id=1, capabilities="REAL_UE"):
        self.ue = UeFactory.get_ue(type_, ue_id, capabilities)

    def restart_ue(self):
        self.ue.restart_ue()

    def prepare_ue(self):
        self.ue.prepare_ue()

    def attach(self):
        self.ue.attach()

    def detach(self):
        self.ue.detach()

    def get_ue_ip(self):
        return self.ue.ue_ip

    def get_ue_name(self):
        return self.ue.name

    def get_average_megabits_data_transfer(self, data_name, **kwargs):
        return self.ue.get_average_throughput(data_name=data_name, **kwargs)

    def get_minimum_megabits_data_transfer(self, data_name):
        return self.ue.get_minimum_throughput(data_name=data_name)

    def get_maximum_megabit_data_transfer(self, data_name, **kwargs):
        return self.ue.get_maximum_throughput(data_name=data_name, **kwargs)

    def get_all_throughput_values(self, data_name, **kwargs):
        return self.ue.get_all_throughput_values(data_name=data_name, **kwargs)

    def start_udp_uplink_data_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ue.start_ul_udp_transmission(duration=duration, traffic_mb=traffic_mb, data_name=data_name, **kwargs)

    def start_tcp_uplink_data_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ue.start_ul_tcp_transmission(duration=duration, traffic_mb=traffic_mb, data_name=data_name, **kwargs)

    def start_udp_downlink_data_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ue.start_dl_udp_transmission(duration=duration, traffic_mb=traffic_mb, data_name=data_name, **kwargs)

    def start_tcp_downlink_data_transmission(self, duration, traffic_mb, data_name, **kwargs):
        self.ue.start_dl_tcp_transmission(duration=duration, traffic_mb=traffic_mb, data_name=data_name, **kwargs)

    def stop_uplink_transmission(self, data_name, **kwargs):
        self.ue.stop_ul_transmission(data_name=data_name, **kwargs)

    def stop_downlink_transmission(self, data_name, **kwargs):
        self.ue.stop_dl_transmission(data_name=data_name, **kwargs)

    def wait_for_data_transmission_end(self, data_name):
        self.ue.wait_for_data_transfer_end(data_name)

    def verify_minimum_required_average_transmission(self, data_name, expected_min_mb):
        self.ue.verify_average_throughput(data_name, expected_min_mb)

    def try_to_get_and_remove_traffic_log_files(self):
        self.ue.try_to_get_and_remove_traffic_log_files()

    def try_to_detach_ue(self):
        try:
            self.ue.detach()
        except Exception as detach_error:
            Logger.info("UE detach procedure failed with: {}".format(detach_error))

    def make_phone_call(self, phone_number):
        self.ue.make_phone_call(phone_number)

    def get_phone_call_status(self):
        return self.ue.get_phone_call_status()

    def hang_up_phone_call(self):
        self.ue.hang_up_phone_call()

    def get_vonr_status(self):
        return self.ue.get_vonr_status()

    def wait_for_ue_rebooted(self):
        self.ue.wait_for_ue_rebooted()

    def get_pci(self):
        return self.ue.get_pci()

    def get_mnci_cell_id(self):
        return self.ue.get_mnci_cell_id()

    def get_band(self):
        return self.ue.get_band()

    def get_tac(self):
        return self.ue.get_tac()

    def get_nrarfcn(self):
        return self.ue.get_nrarfcn()

    def get_plmn(self):
        return self.ue.get_plmn()

    def get_rat(self):
        return self.ue.get_rat()

    def get_rsrp(self):
        return self.ue.get_rsrp()

    def get_rsrq(self):
        return self.ue.get_rsrq()

    def get_sinr(self):
        return self.ue.get_sinr()

    def generate_traffic_via_ping_to_appserver(self, ping_name="PING", time_for_ping=60):
        self.ue.generate_traffic_via_ping_from_ue(ping_name=ping_name, time_for_ping=time_for_ping)

    def ping_stop_and_check_results(self, lost_ping_percent=20):
        self.ue.stop_ping_and_check_results(lost_ping_percent=lost_ping_percent)

    def attempt_to_attach_several_times(self, retry_number=5):
        for attempt in range(retry_number):
            try:
                self.attach()
                Logger.info(f"{self.get_ue_name()} - attached in the attempt #{attempt + 1}")
                return
            except (AssertionError, RpcError):
                Logger.warning(f"{self.get_ue_name()} - not attached in the attempt #{attempt + 1}")
                self.detach()
        assert False, f"{self.get_ue_name()} - not attached in all attempts"
