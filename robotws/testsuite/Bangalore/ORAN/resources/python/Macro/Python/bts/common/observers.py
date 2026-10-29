# -*- coding: utf-8 -*-
"""
Generic keywords for BTS.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
from robot.api import logger
from moler.device import DeviceFactory
from moler.util.moler_test import MolerTest
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.generic_bts import GenericBts, convert_id_to_int, get_builtin_value
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    utilities import load_moler_configuration_from_tl, get_timestamp
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.common.log import GnbLog
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    exceptions import UnexpectedBtsResetOccurred
from taf.internal.robot_typecasts import time_to_seconds


class GenericObservers(GenericBts):
    """Observer keywords for eNB and gNB"""
    def ping_callback(self, ping):
        ping.cancel()

    @load_moler_configuration_from_tl()
    def _ping_bts(self, bts_id, event_name, bts_ip, timeout, du_id=0):
        """
        ping bts and wait for response
        :param bts_id: bts id
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param event_name: event waiting for response or rejected packets
         after ping command
        :param bts_ip: ip address of bts to execute command
        :param timeout: timeout for execute command
        """
        timeout = time_to_seconds(time=timeout)
        sys_device = DeviceFactory.get_device(
            name=self.ssh_alias.format(bts_id, du_id),
            establish_connection=False)
        sys_device.goto_state("PROXY_PC")
        event = sys_device.get_event(
            event_name=event_name,
            event_params={"till_occurs_times": 1}
        )
        ping = sys_device.get_cmd(cmd_name="ping", cmd_params={
            'destination': bts_ip
        })
        event.add_event_occurred_callback(
            callback=self.ping_callback,
            callback_params={'ping': ping}
        )
        event.start()
        ping.start(timeout=timeout-20)
        event.await_done(timeout=timeout)
        return

    def verify_host_response(self, bts_id=0, bts_ip="192.168.255.129",
                             timeout=120, du_id=0):
        """
        Using function _ping_bts, wait for host response
        :param bts_id: bts id
        :param du_id: DU id(Distributed Unit) - id related to Test
        Line configuration - gnb.dus[]
        :param bts_ip: bts ip
        :param timeout: timeout for execute command
        :return:
        """
        self._ping_bts(bts_id, "ping_response", bts_ip, timeout, du_id)

    def verify_host_no_response(self, bts_id=0, bts_ip="192.168.255.129",
                                timeout=120, du_id=0):
        """
        Using function _ping_bts, wait for host  no response
        :param bts_id: bts id
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param bts_ip: bts ip
        :param timeout: timeout for execute command
        :return:
        """
        self._ping_bts(bts_id, "ping_no_response", bts_ip, timeout, du_id)

    observers = {}


class EnbObservers(GenericObservers):
    """Class contains Observer keywords for eNB"""

    bts_type = 'ENB'

    def __init__(self):
        """
        Constructor of Enb class.

        """

        super(EnbObservers, self).__init__(bts_type=EnbObservers.bts_type)


class GnbObservers(GenericObservers):
    """Class contains Observer keywords for gNB"""

    bts_type = 'GNB'

    def __init__(self):
        """
        Constructor of Gnb class.
        """
        super(GnbObservers, self).__init__(bts_type=GnbObservers.bts_type)
        self.wasSiteReset = False

    @load_moler_configuration_from_tl()
    @convert_id_to_int
    def start_drop_x2_link_observer(self, gnb_id=0, timeout=None, du_id=0):
        """
        Start drop X2 link observer on passed gNB and collect snapshot
         when event occurred.
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param timeout: timeout for running observer
        :return: syslog_event
        """
        _re_drop_x2_link = 'report Fault x2LinkNotAvailableAl'
        device_name = self.syslog_alias.format(gnb_id, du_id)
        if 'drop_x2_link' not in self.observers:
            self.observers['drop_x2_link'] = {}

        MolerTest.info("Start drop X2 link observer on device {}".format(
            device_name))
        sys_device = DeviceFactory.get_device(name=device_name)

        syslog_event = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [_re_drop_x2_link],
                          "till_occurs_times": -1, "match": 'all'}
        )

        self.observers['drop_x2_link'][device_name] = syslog_event

        syslog_event.add_event_occurred_callback(
            callback=self._drop_x2_link_callback,
            callback_params={'gnb_id': gnb_id}
        )

        syslog_event.start(timeout=timeout)

        return syslog_event

    def _drop_x2_link_callback(self, gnb_id=0, du_id=0):
        logger.info("\t{} Detected x2LinkNotAvailable in SYSYLOG".format(
            get_timestamp()), also_console=True)
        logger.info("\t{} Start collecting snapshot via REST API".format(
            get_timestamp()), also_console=True)

        log_dir = get_builtin_value(param_name="OUTPUT DIR")
        GnbLog().collect_snapshot(gnb_id=gnb_id, log_dir=log_dir, du_id=du_id)

        logger.info("\t{} Collecting snapshot finished".format(
            get_timestamp()), also_console=True)

    @convert_id_to_int
    def stop_drop_x2_link_observer(self, gnb_id=0, du_id=0):
        """
        Stop drop X2 link observer on passed gNB.
        :param gnb_id: gNB id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to
        Test Line configuration - gnb.dus[]
        :return: None
        """

        device_name = self.syslog_alias.format(gnb_id, du_id)
        try:
            syslog_event = self.observers['drop_x2_link'][device_name]
            syslog_event.cancel()
        except KeyError:
            raise Exception("Please first run 'start_drop_x2_link"
                            "_observer' for gnb_id={}".format(gnb_id))

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def start_monitoring_gnb_online_status(
            self, bts_id=0, du_id=0, callback=None, callback_params=None):
        """
        Start executing recovery action site reset observer on passed bts.
        Use verify_site_reset_not_occurred() to verify if site reset occurred.

        :param bts_id: bts id - related to Test Line configuration.
        :param du_id: DU id(Distributed Unit) - id related to Test Line
         configuration - gnb.dus[]
        :param callback: Optional. Function to call, when event occurred.
        :param callback_params: Optional. Parameters to callback.

        """
        syslog = DeviceFactory.get_device(
            self.syslog_alias.format(bts_id, du_id))
        syslog.goto_state('SYSLOG', keep_state=False)

        gnb_recovery = syslog.get_event(
            event_name="executing_recovery_action_site_reset", event_params={})

        if not callback:
            callback = self._fail_test
            callback_params = {
                'msg': 'executing_recovery_action_site_reset',
            }

        gnb_recovery.add_event_occurred_callback(
            callback=callback,
            callback_params=callback_params,
        )
        gnb_recovery.start()

    @MolerTest.raise_background_exceptions()
    def _fail_test(self, msg):
        self.wasSiteReset = True
        MolerTest.error(raise_exception=True, msg=msg)

    def verify_site_reset_not_occurred(self):
        """
        Verify if site reset occurred.
        start_monitoring_gnb_online_status() function should be called firstly.
        :raises: UnexpectedBtsResetOccurred
        """
        if self.wasSiteReset:
            self.wasSiteReset = False
            raise UnexpectedBtsResetOccurred()
