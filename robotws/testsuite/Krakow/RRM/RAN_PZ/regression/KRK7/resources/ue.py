import datetime
from functools import wraps
from time import sleep

from robot.api import logger

from taf.rfrl.ue.helpers.data_transfer import _get_tput_args
from taf.rfrl.ue.logs.tput_logs_collecting import (collect_logs_during_data_transfer, download_logs_from_gnb)
from taf.rfrl.utilities.robot.general import get_builtin_instance


def retry(tries=2, delay=30):
    def wrapper(func):
        @wraps(func)
        def retry_until_max_retries(self, *args, **kwargs):
            method_id = "{}({}, {})".format(func.__name__, args, kwargs)
            iteration = 0
            while iteration < tries + 1:
                try:
                    func(*args, **kwargs)
                except Exception as e:
                    logger.console("Method: {} - Try {} out of {} - Result: {}".format(method_id,
                                                                                       iteration,
                                                                                       tries, e))
                    self.ue.reboot_ue(timeout=100)
                iteration += 1
                sleep(delay)
            raise Exception("All {} retries failed".format(tries))
        return retry_until_max_retries
    return wrapper


class CallResources(object):
    def __init__(self):
        self.ue = get_builtin_instance(instance_name="taf.ue")
        self.protocol = 'tcp'
        self.buffer_client_dl_udp = None
        self.buffer_client_ul_udp = None
        self.buffer_server_dl_udp = None
        self.buffer_server_ul_udp = None
        self.COLLECT_LOGS_DURING_DATA_TRANSFER = False

    def verify_dl_tput(self, capabilities, alias, reboot_ue, timeout_reboot_ue, duration, tput_dl, deviation_dl,
                       parallel_streams_dl, size_packet_dl, interval, linux_congestion, qci=None):
        logger.console('Verify DL tput')
        self.prepare_ue_for_call(capabilities=capabilities,
                                 alias=alias,
                                 reboot_ue=reboot_ue,
                                 timeout_reboot_ue=timeout_reboot_ue)
        self.data_transfer_dl(alias, duration, tput_dl, deviation_dl, parallel_streams_dl, size_packet_dl,
                              interval, linux_congestion, qci)
        self.ue.detach_ue(alias)
        self.ue.stop_using_ue(alias)

    def verify_dl_tput_with_attenuation(self, capabilities, alias, reboot_ue, timeout_reboot_ue, duration, tput_dl,
                                        deviation_dl, parallel_streams_dl, size_packet_dl, interval, attenuator,
                                        attenuation, attenuation_duration, delay, begin_attenuation, max_react,
                                        linux_congestion=None, qci=None):
        logger.console('Verify DL tput with attenuation')
        self.prepare_ue_for_call(capabilities=capabilities,
                                 alias=alias,
                                 reboot_ue=reboot_ue,
                                 timeout_reboot_ue=timeout_reboot_ue)
        self.data_transfer_dl_with_attenuation(alias, duration, tput_dl, deviation_dl, parallel_streams_dl,
                                               size_packet_dl, interval, linux_congestion, qci, attenuator,
                                               attenuation, attenuation_duration, delay,
                                               begin_attenuation, max_react)
        self.ue.detach_ue(alias)
        self.ue.stop_using_ue(alias)

    def prepare_ue_for_call(self, capabilities, alias, reboot_ue, timeout_reboot_ue):
        self.ue.require_ue(alias, capabilities=capabilities)
        self.ue.detach_ue(alias)
        if reboot_ue:
            self.ue.reboot_ue(alias, timeout=timeout_reboot_ue)

    def data_transfer_dl(self, alias, duration, tput_dl, deviation_dl, parallel_streams_dl, size_packet_dl, interval,
                         linux_congestion, qci):
        self.ue.attach_ue(alias)
        self.start_data_transfer_and_verify_throughput(direction='dl', duration=duration, tput=tput_dl,
                                                       protocol=self.protocol, deviation=deviation_dl,
                                                       parallel_streams=parallel_streams_dl,
                                                       size_packet=size_packet_dl,
                                                       buffer_client=self.buffer_client_dl_udp,
                                                       buffer_server=self.buffer_server_dl_udp,
                                                       interval=interval, qci=qci,
                                                       linux_congestion=linux_congestion, alias=alias)

    def data_transfer_dl_with_attenuation(self, alias, duration, tput_dl, deviation_dl, parallel_streams_dl,
                                          size_packet_dl, interval, linux_congestion, qci, attenuator,
                                          attenuation, attenuation_duration, delay, begin_attenuation, max_react):
        logger.console(f"Start data_transfer_dl_with_attenuation on time: {datetime.datetime.now().time()}")
        logger.debug(f"Set beginning attenuation at {begin_attenuation} on time: {datetime.datetime.now().time()}")
        attenuator.attenuate(attenuation_value=begin_attenuation)
        sleep(5)  # TODO: od czego to jest?
        logger.debug(f"Before self.ue.attach_ue(alias) on time: {datetime.datetime.now().time()}")
        self.ue.attach_ue(alias)
        logger.debug(f"After self.ue.attach_ue(alias) on time: {datetime.datetime.now().time()}")
        self.start_data_transfer_with_attenuation_and_verify_throughput(direction='dl',
                                                                        duration=duration,
                                                                        tput=tput_dl,
                                                                        protocol=self.protocol,
                                                                        deviation=deviation_dl,
                                                                        parallel_streams=parallel_streams_dl,
                                                                        size_packet=size_packet_dl,
                                                                        buffer_client=self.buffer_client_dl_udp,
                                                                        buffer_server=self.buffer_server_dl_udp,
                                                                        interval=interval,
                                                                        qci=qci,
                                                                        linux_congestion=linux_congestion,
                                                                        alias=alias,
                                                                        attenuator=attenuator,
                                                                        attenuation=attenuation,
                                                                        attenuation_duration=attenuation_duration,
                                                                        delay=delay,
                                                                        begin_attenuation=begin_attenuation,
                                                                        max_react=max_react)

    def start_data_transfer_and_verify_throughput(self, direction, duration, tput, protocol, deviation,
                                                  parallel_streams, size_packet, buffer_client, buffer_server,
                                                  interval, qci, linux_congestion, alias):
        upper_direction = 'DT_{}'.format(direction.upper())
        tput_args = _get_tput_args(dt_name=upper_direction, ue_alias=alias, direction=direction, protocol=protocol,
                                   duration=duration, tput=tput, parallel_streams=parallel_streams,
                                   size_packet=size_packet, buffer_client=buffer_client, buffer_server=buffer_server,
                                   interval=interval, qci=qci, linux_congestion=linux_congestion,
                                   multi_radio_bearer=False)
        self.ue.start_data_transfer(**tput_args)
        try:
            if self.COLLECT_LOGS_DURING_DATA_TRANSFER:
                collect_logs_during_data_transfer(direction=upper_direction)
            self.ue.check_data_transfer_is_alive(dt_name=upper_direction)
            self.ue.await_data_transfer_finish(dt_name=upper_direction)
            self.ue.stop_data_transfer(dt_name=upper_direction)
            self.ue.verify_average_throughput_with_deviation(dt_name=upper_direction, tput=tput, deviation=deviation)
        finally:
            if self.COLLECT_LOGS_DURING_DATA_TRANSFER:
                download_logs_from_gnb(sub_dir='data_transfer')

    def start_data_transfer_with_attenuation_and_verify_throughput(self, direction, duration, tput, protocol,
                                                                   deviation, parallel_streams, size_packet,
                                                                   buffer_client, buffer_server,
                                                                   interval, qci, linux_congestion,
                                                                   alias, attenuator, delay, attenuation_duration,
                                                                   attenuation, begin_attenuation, max_react):
        upper_direction = 'DT_{}'.format(direction.upper())
        tput_args = _get_tput_args(dt_name=upper_direction, ue_alias=alias, direction=direction, protocol=protocol,
                                   duration=duration, tput=tput, parallel_streams=parallel_streams,
                                   size_packet=size_packet, buffer_client=buffer_client, buffer_server=buffer_server,
                                   interval=interval, qci=qci, linux_congestion=linux_congestion,
                                   multi_radiSo_bearer=False)
        logger.debug(f"Before self.ue.start_data_transfer(**tput_args) on time: {datetime.datetime.now().time()}")
        self.ue.start_data_transfer(**tput_args)
        logger.debug(f"After self.ue.start_data_transfer(**tput_args) on time: {datetime.datetime.now().time()}")
        sleep(delay)
        logger.debug(f"After attenuation delay - sleep {delay} sec.; on time: {datetime.datetime.now().time()}")
        logger.debug(f"Setting attenuation on {attenuation}; on time: {datetime.datetime.now().time()}")
        attenuator.attenuate(attenuation_value=attenuation)
        sleep(attenuation_duration)
        if max_react:
            self.repeat_attenuation_loop(attenuator=attenuator,
                                         begin_attenuation=begin_attenuation,
                                         attenuation=attenuation,
                                         attenuation_duration=attenuation_duration,
                                         max_react=max_react)
        logger.debug(f"After attenuate(attenuation_value={attenuation}); on time: {datetime.datetime.now().time()}")
        attenuator.attenuate(attenuation_value=begin_attenuation)
        logger.debug(f"After restoring attenuation to begin_attenuation ({begin_attenuation});"
                     f" on time: {datetime.datetime.now().time()}")
        try:
            if self.COLLECT_LOGS_DURING_DATA_TRANSFER:
                collect_logs_during_data_transfer(direction=upper_direction)
            self.ue.check_data_transfer_is_alive(dt_name=upper_direction)
            # self.ue.await_data_transfer_finish(dt_name=upper_direction)
            self.ue.stop_data_transfer(dt_name=upper_direction)
            self.ue.verify_average_throughput_with_deviation(dt_name=upper_direction, tput=tput, deviation=deviation)
        finally:
            logger.console(f"Finally within start_data_transfer_with_attenuation_and_verify_throughput;"
                           f" on time: {datetime.datetime.now().time()}")
            if self.COLLECT_LOGS_DURING_DATA_TRANSFER:
                download_logs_from_gnb(sub_dir='data_transfer')

    @staticmethod
    def repeat_attenuation_loop(attenuator, begin_attenuation, attenuation, attenuation_duration, max_react):
        logger.debug(f"Setting attenuation at {begin_attenuation} and immediately returning to {attenuation};"
                     f" on time: {datetime.datetime.now().time()}")
        max_react_range = int(max_react) + 1
        for react in range(1, max_react_range):
            logger.debug(f"No. #{react} react loop of supervision timer and retry timer")
            attenuator.attenuate(attenuation_value=begin_attenuation)
            attenuator.attenuate(attenuation_value=attenuation)
            sleep(attenuation_duration)
