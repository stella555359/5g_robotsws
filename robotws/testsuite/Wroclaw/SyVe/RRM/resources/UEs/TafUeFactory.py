from time import sleep

from testsuite.Wroclaw.SyVe.RRM.resources.Logger import Logger
from robot.libraries.BuiltIn import BuiltIn


class TafUeFactory:

    def __init__(self, id_, capabilities):
        self.alias = "TAF_UE_{}".format(id_)
        self.capabilities = capabilities
        self.lib_ = "taf.ue"
        self.ue = None
        self.build_in = BuiltIn()

    def prepare_ue(self):
        self._prepare_library()
        self.ue.require_ue(self.alias, self.capabilities)

    def attach(self):
        Logger.info("{} - attaching...".format(self.alias))
        self.ue.attach_ue(self.alias)

    def detach(self):
        Logger.info("{} - detaching...".format(self.alias))
        self.ue.detach_ue(self.alias)

    def start_ul_udp_transmission(self, duration, traffic_mb, **kwargs):
        self._start_transmission(duration, traffic_mb, direction="ul", protocol='udp', **kwargs)

    def start_ul_tcp_transmission(self, duration, traffic_mb, **kwargs):
        self._start_transmission(duration, traffic_mb, direction="ul", protocol='tcp', **kwargs)

    def start_dl_udp_transmission(self, duration, traffic_mb, **kwargs):
        self._start_transmission(duration, traffic_mb, direction="dl", protocol='udp', **kwargs)

    def start_dl_tcp_transmission(self, duration, traffic_mb, **kwargs):
        self._start_transmission(duration, traffic_mb, direction="dl", protocol='tcp', **kwargs)

    def stop_ul_transmission(self, **kwargs):
        self._stop_transmission(kwargs)

    def stop_dl_transmission(self, **kwargs):
        self._stop_transmission(kwargs)

    def wait_for_data_transfer_end(self, data_name):
        self.ue.await_data_transfer_finish(data_name)

    def get_average_throughput(self, data_name):
        return self._convert_ute_kbits_to_mbits(self.ue.get_average_throughput(dt_name=data_name))

    def get_maximum_throughput(self, data_name):
        return self._convert_ute_kbits_to_mbits(max(self._get_statistics_throughput(data_name=data_name)))

    def get_minimum_throughput(self, data_name):
        return self._convert_ute_kbits_to_mbits(min(self._get_statistics_throughput(data_name=data_name)))

    def _get_statistics_throughput(self, data_name):
        full_data = self.ue.get_data_transfer_statistics(dt_name=data_name)
        calculated_statistics_part = 0
        calc_data_separator = ";"
        data_separator = ","
        try:
            avg, min_, max_ = full_data.split(calc_data_separator)[calculated_statistics_part].split(data_separator)
        except ValueError:
            raise ValueError("Problem with getting statistics throughput with {} library".format(self.lib_))
        ute_compatible_conversion_factor = 1000
        return float(min_)/ute_compatible_conversion_factor, float(max_)/ute_compatible_conversion_factor

    def verify_average_throughput(self, data_name, expected_min_mb):
        self.ue.verify_average_throughput(dt_name=data_name, tput_min="{}Mbits/sec".format(expected_min_mb))

    def _start_transmission(self, duration, traffic_mb, direction, protocol, **kwargs):
        data_name = kwargs['data_name']
        packet_size = kwargs.get('packet_size', 1024)
        max_segment_size = kwargs.get('max_segment_size', 1400)
        Logger.info(f"{self.alias} - Starting '{data_name}' {direction.upper()} {protocol.upper()} "
                    f"{traffic_mb}Mbits transmission for {duration}s "
                    f"(packet size: {packet_size}, maximum segment size: {max_segment_size}")
        self.ue.start_data_transfer(dt_name=data_name,
                                    ue_alias=self.alias,
                                    direction=direction,
                                    duration="{}s".format(duration),
                                    throughput="{} Mbits/sec".format(traffic_mb),
                                    protocol=protocol,
                                    packet_size=str(packet_size),
                                    max_segment_size=str(max_segment_size))
        self._wait_for_data_transfer_statistics(data_name)

    def _wait_for_data_transfer_statistics(self, data_name):
        from time import sleep
        waiting_time = 60
        interval = 1
        wait_for_logs_time = 5
        warn_msg = "There are not traffic statistics after {}s!".format(waiting_time)
        sleep(wait_for_logs_time)
        while waiting_time > 0:
            try:
                self._get_statistics_throughput(data_name=data_name)
                return
            except ValueError:
                sleep(interval)
                waiting_time -= interval
        Logger.warning(warn_msg)

    def _stop_transmission(self, kwargs):
        data_name = kwargs['data_name']
        Logger.info("{} - Stopping '{}' transmission".format(self.alias, data_name))
        self.ue.stop_data_transfer(data_name)

    def _prepare_library(self):
        try:
            Logger.info("initializing UTE {}".format(self.alias))
            self.ue = BuiltIn().get_library_instance(self.lib_)
        except RuntimeError as err:
            raise RuntimeError("{} Please import {} in robot test resource".format(err, self.lib_))

    @staticmethod
    def _convert_ute_kbits_to_mbits(ute_kilobits_result):
        ute_conversion_factor = 1000
        decimal_places = 2
        return round(float(ute_kilobits_result)/ute_conversion_factor, decimal_places)
