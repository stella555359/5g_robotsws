from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest

from taf.rfrl.bts.devices.du.combined.observers import GenericObservers
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class RlfObserver(GenericObservers):
    bts_type = 'GNB'

    def __init__(self):
        super(RlfObserver, self).__init__(bts_type=RlfObserver.bts_type)

    @load_moler_configuration_from_tl()
    def start_rlf_observer(self, gnb_id=0, timeout=None, du_id=0, rlf_type_name=None):
        """
        Start radio link failure observer on gNB.
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param timeout: timeout for running observer
        :param rlf_type_name: name of obserbed RLF (RLF_DL_HARQ or RLF_BSI_CSI)
        :return: syslog events for RLF occurance, RLF timeout, RLF recovery
        """
        device_name = self.syslog_alias.format(gnb_id, du_id)

        _re_rlf = rlf_type_name
        self.observers['rlf'] = {}

        _re_rlf_timer_timeout = 'Timeout RLF Guard Timer'
        self.observers['rlf_timer_timeout'] = {}

        _re_rlf_timer_stop = 'RLF_OFF'
        self.observers['rlf_timer_stop'] = {}

        MolerTest.info("Start RLF observer on device {}".format(device_name))
        sys_device = DeviceFactory.get_device(name=device_name)

        rlf_syslog_event = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_rlf],
                          "till_occurs_times": 1, "match": 'all'}
        )

        rlf_timeout_syslog_event = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_rlf_timer_timeout],
                          "till_occurs_times": 1, "match": 'all'}
        )

        rlf_off_syslog_event = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_rlf_timer_stop],
                          "till_occurs_times": 1, "match": 'all'}
        )

        self.observers['rlf'][device_name] = rlf_syslog_event
        self.observers['rlf_timer_timeout'][device_name] = rlf_timeout_syslog_event
        self.observers['rlf_timer_stop'][device_name] = rlf_off_syslog_event

        rlf_syslog_event.start(timeout=timeout)
        rlf_timeout_syslog_event.start(timeout=timeout)
        rlf_off_syslog_event.start(timeout=timeout)

        return rlf_syslog_event, rlf_timeout_syslog_event, rlf_off_syslog_event

    def stop_rlf_observer(self, gnb_id=0, du_id=0, recovery=None):
        """
        Stop radio link failure observer on gNB.
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param recovery: indicates if RLF recovery is expected(True) or not (False)
        :return: None
        """

        device_name = self.syslog_alias.format(gnb_id, du_id)
        try:
            rlf_syslog_event = self.observers['rlf'][device_name]
            rlf_timeout_syslog_event = self.observers['rlf_timer_timeout'][device_name]
            rlf_off_syslog_event = self.observers['rlf_timer_stop'][device_name]
            if not rlf_syslog_event.done():
                raise Exception("RLF with an appropriate cause was not triggered!")
            else:
                if recovery:
                    if rlf_timeout_syslog_event.done():
                        raise Exception("RLF was triggered!")
                    else:
                        if not rlf_off_syslog_event.done():
                            raise Exception("RLF was not stopped!")
                else:
                    if rlf_off_syslog_event.done():
                        raise Exception("RLF was stopped!")
                    else:
                        if not rlf_timeout_syslog_event.done():
                            raise Exception("RLF was not triggered!")
            rlf_syslog_event.cancel()
            rlf_timeout_syslog_event.cancel()
            rlf_off_syslog_event.cancel()
        except KeyError:
            raise Exception("Please first run 'start_rlf_observer' for gnb_id={}".format(gnb_id))
