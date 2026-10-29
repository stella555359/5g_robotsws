from time import sleep

from ta_ue_plugin_android.uepc.ue_manager_exceptions import UeManagerException, UeNotReservedException

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_library
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger
from .robot_library import RobotLibrary
from .teardown import Teardown

_teardown = Teardown()


class TafUe(RobotLibrary):
    verbose = False

    def __init__(self, verbose=False):
        if self._library_initiation_guard():
            return
        self._taf_ue_backend = None
        self._ue_db = {}
        self.verbose = verbose

    @property
    def _taf_ue(self):
        if self._taf_ue_backend is None:
            self._taf_ue_backend = get_robot_library('taf.ue')
        return self._taf_ue_backend

    def attach_ue(self, ue_alias, capabilities='REAL_UE', attach_wait=3):
        if ue_alias not in self._ue_db:
            logger.info(f"Calling Require UE for {ue_alias}", also_to_console=self.verbose)
            self._taf_ue.require_ue(ue_alias=ue_alias, capabilities=capabilities)
            self._ue_db[ue_alias] = {'attached': False, 'traffic_ul': False, 'traffic_dl': False}
        logger.info(f"Initiating Attach procedure for {ue_alias}", also_to_console=self.verbose)
        if self._ue_db[ue_alias]['attached']:
            self.detach_ue(ue_alias=ue_alias)
        self._taf_ue.attach_ue(ue_alias=ue_alias)
        _teardown.schedule_test_teardown_function('Detach UE', self._detach_ue, [ue_alias])
        self._ue_db[ue_alias]['attached'] = True
        logger.info(f"Sleeping for {attach_wait}s after attach...", also_to_console=self.verbose)
        sleep(attach_wait)

    def start_tput_on_ue(self, ue_alias, direction='ULDL', duration=36000, protocol='tcp', packet_size='1400',
                         max_segment_size='1200', buffer='7M', throughput='max', tput_wait=30):
        kwargs = TafUe._get_protocol_and_tput_specific_taf_data_transfer_kwargs(throughput, protocol, max_segment_size)
        if ue_alias not in self._ue_db or not self._ue_db[ue_alias]['attached']:
            raise UeNotReservedException(f"UE alias {ue_alias} not attached. Have you called attach_ue?")
        duration = duration + tput_wait
        if "UL" in direction:
            logger.info(f"Starting UL data transfer for UE alias {ue_alias}: duration={duration}, protocol={protocol},"
                        f" packet_size={packet_size}, buffer={buffer}, {kwargs}", also_to_console=self.verbose)
            self._taf_ue.start_data_transfer(dt_name=f"{ue_alias}_DT_UL", ue_alias=ue_alias, direction="UL",
                                             duration=f"{duration}s", protocol=protocol, packet_size=packet_size,
                                             buffer=buffer, **kwargs)
            self._ue_db[ue_alias]['traffic_ul'] = True
        if "DL" in direction:
            logger.info(f"Starting DL data transfer for UE alias {ue_alias}: duration={duration}, protocol={protocol},"
                        f" packet_size={packet_size}, buffer={buffer}, {kwargs}", also_to_console=self.verbose)
            self._taf_ue.start_data_transfer(dt_name=f"{ue_alias}_DT_DL", ue_alias=ue_alias, direction="DL",
                                             duration=f"{duration}s", protocol=protocol, packet_size=packet_size,
                                             buffer=buffer, **kwargs)
            self._ue_db[ue_alias]['traffic_dl'] = True
        _teardown.schedule_test_teardown_function('Stop tput', self._stop_tput_on_ue, [ue_alias, direction])
        logger.info(f"Sleeping for {tput_wait}s after starting data transfer...", also_to_console=self.verbose)
        sleep(tput_wait)

    @staticmethod
    def _get_protocol_and_tput_specific_taf_data_transfer_kwargs(throughput, protocol, max_segment_size=1200):
        kwargs = {'max_segment_size': max_segment_size} if protocol.lower() == 'tcp' else {'throughput': '2 Gbits/sec'}
        if throughput != 'max':
            param, value = ('bandwidth', throughput) if protocol.lower() == 'tcp' else \
                ('throughput', f"{throughput}bits/sec")
            kwargs[param] = value
        return kwargs

    def stop_tput_on_ue(self, ue_alias, direction=None):
        self._stop_tput_on_ue(ue_alias, direction)
        _teardown.recall_test_teardown_function('Stop tput')

    def _stop_tput_on_ue(self, ue_alias, direction=None):
        direction = self._resolve_tput_direction_for_ue_alias(ue_alias) if direction is None else direction
        if 'UL' in direction:
            logger.info(f"Stopping UL data transfer for UE alias {ue_alias}", also_to_console=self.verbose)
            self._taf_ue.stop_data_transfer(dt_name=f"{ue_alias}_DT_UL")
            self._ue_db[ue_alias]['traffic_ul'] = False
        if 'DL' in direction:
            logger.info(f"Stopping DL data transfer for UE alias {ue_alias}", also_to_console=self.verbose)
            self._taf_ue.stop_data_transfer(dt_name=f"{ue_alias}_DT_DL")
            self._ue_db[ue_alias]['traffic_dl'] = False

    def await_tput_end(self, ue_alias, direction=None):
        direction = self._resolve_tput_direction_for_ue_alias(ue_alias) if direction is None else direction
        if 'UL' in direction:
            logger.info(f"Awaiting UL data transfer for ue alias {ue_alias} finish...", also_to_console=self.verbose)
            self._taf_ue.await_data_transfer_finish(dt_name=f"{ue_alias}_DT_UL")
            logger.info(f"UL data transfer for ue alias {ue_alias} finished!", also_to_console=self.verbose)
            self._ue_db[ue_alias]['traffic_ul'] = False
        if 'DL' in direction:
            logger.info(f"Awaiting DL data transfer for ue alias {ue_alias} finish...", also_to_console=self.verbose)
            self._taf_ue.await_data_transfer_finish(dt_name=f"{ue_alias}_DT_DL")
            logger.info(f"DL data transfer for ue alias {ue_alias} finished!", also_to_console=self.verbose)
            self._ue_db[ue_alias]['traffic_dl'] = False

    def verify_tput(self, ue_alias, direction='DL', expected='50Mbits/sec', deviation='10%', omit=None):
        self._taf_ue.verify_average_throughput_with_deviation(dt_name=f"{ue_alias}_DT_{direction.upper()}",
                                                              tput=expected, deviation=deviation, omit=omit)

    def get_tput(self, ue_alias, direction='DL', omit=None):
        return self._taf_ue.get_average_throughput(dt_name=f"{ue_alias}_DT_{direction.upper()}", omit=omit)

    def get_tput_stats(self, ue_alias, direction='DL'):
        return self._taf_ue.get_data_transfer_statistics(dt_name=f"{ue_alias}_DT_{direction.upper()}")

    def _resolve_tput_direction_for_ue_alias(self, ue_alias):
        direction = ''
        if self._ue_db[ue_alias]['traffic_ul']:
            direction += 'UL'
        if self._ue_db[ue_alias]['traffic_dl']:
            direction += 'DL'
        return direction

    def detach_ue(self, ue_alias, ignore_error=True):
        self._detach_ue(ue_alias, ignore_error)
        _teardown.recall_test_teardown_function('Detach UE')

    def _detach_ue(self, ue_alias, ignore_error=True):
        logger.info(f"Initiating detach procedure for UE alias {ue_alias}", also_to_console=self.verbose)
        try:
            self._taf_ue.detach_ue(ue_alias=ue_alias)
        except UeManagerException as e:
            if not ignore_error:
                raise
            logger.info("During detach following exception was raised:", also_to_console=self.verbose)
            logger.info(e)
        finally:
            self._ue_db[ue_alias]['attached'] = False
        logger.info(f"UE alias {ue_alias} detached!", also_to_console=self.verbose)
