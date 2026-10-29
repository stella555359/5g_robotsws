from time import sleep
from robot.api import logger
from taf.rfrl.utilities.robot.general import get_builtin_instance
from taf.rfrl.ue.helpers.data_transfer import start_data_transfer_on_real_ue, _get_tput_args
from ta_ue_plugin_android.uepc.ue_manager_exceptions import IperfServerStuckException


deviation_ul = '70%'
deviation_dl = '10%'
duration = '120s'
interval = '1'
linux_congestion = 'reno'
parallel_streams_dl = '4'
parallel_streams_ul = '2'
reboot_ue = True
size_packet_dl = '1400B'
size_packet_ul = '1320B'
timeout_reboot_ue = '100'
tput_dl = '2100 Mbits/sec'
tput_ul = '240 Mbits/sec'


class CallResources(object):
    def __init__(self):
        self.ue = get_builtin_instance(instance_name="taf.ue")
        self.protocol = 'udp'
        self.buffer_client_dl_udp = '4M'
        self.buffer_client_ul_udp = '2M'
        self.buffer_server_dl_udp = '4M'
        self.buffer_server_ul_udp = '2M'

    def attach_ue(self, alias):
        self.ue.attach_ue(alias)

    def detach_ue(self, alias):
        self.ue.detach_ue(alias)
        self.ue.stop_using_ue(alias)

    def prepare_ue_for_call(self, capabilities, reboot_ue=False, timeout_reboot_ue=100, alias='UE'):
        logger.info(f'Prepare ue for call:  {capabilities} {alias}')
        self.ue.require_ue(alias, capabilities=capabilities)
        self.ue.detach_ue(alias)
        if reboot_ue:
            self.ue.reboot_ue(alias, timeout=timeout_reboot_ue)

    def start_generating_max_tput(self, alias, tput_direction, tput_duration):
        try:
            self.start_data_transfer_and_verify_throughput(direction=tput_direction,
                                                           duration=tput_duration,
                                                           tput=tput_dl,
                                                           protocol=self.protocol,
                                                           deviation=deviation_dl,
                                                           parallel_streams=parallel_streams_dl,
                                                           size_packet=size_packet_dl,
                                                           buffer_client=self.buffer_client_dl_udp,
                                                           buffer_server=self.buffer_server_dl_udp,
                                                           interval=interval,
                                                           linux_congestion=None,
                                                           alias=alias)
        except IperfServerStuckException as err:
            logger.console(f"Error cause by (IperfServerStuckException): {err}")
            self.detach_ue(alias)
        except Exception as err:
            logger.console(f"Error cause by: {err}")
            self.detach_ue(alias)

    def start_data_transfer_and_verify_throughput(self,
                                                  direction,
                                                  duration,
                                                  tput,
                                                  protocol='udp',
                                                  deviation='25%',
                                                  parallel_streams='1',
                                                  size_packet='1400B',
                                                  buffer_client=None,
                                                  buffer_server=None,
                                                  interval='1',
                                                  qci=None,
                                                  linux_congestion=None,
                                                  alias='UE'):
        upper_direction = f'DT_{direction.upper()}'
        tput_args = _get_tput_args(dt_name=upper_direction,
                                   ue_alias=alias,
                                   direction=direction,
                                   protocol=protocol,
                                   duration=duration,
                                   tput=tput,
                                   parallel_streams=parallel_streams,
                                   size_packet=size_packet,
                                   buffer_client=buffer_client,
                                   buffer_server=buffer_server,
                                   interval=interval,
                                   qci=qci,
                                   linux_congestion=linux_congestion,
                                   multi_radio_bearer=False)
        self.ue.start_data_transfer(**tput_args)
        sleep(10)
