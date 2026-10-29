"""
Syslog event observer.

:copyright: Nokia Networks
:author: Rafal Kawa
:contact: rafal.kawa@nokia.com
:maintainer: rafal.kawa@nokia.com
"""

import logging

from moler.device import DeviceFactory
from taf.rfrl.bts.devices.du.combined.observers import GenericObservers
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console


class SyslogEventObserver(GenericObservers):
    """
    SyslogEventObserver class represents a collection of methods for monitoring custom events in syslog.
    """

    def __init__(self, bts_type='GNB'):
        """
        Initializes the SyslogEventObserver object.
        """
        super().__init__(bts_type)
        self.syslog_events = {}

    @load_moler_configuration_from_tl()
    def start_syslog_event_observer(self, event_name, success_regex, match="all", till_occurs_times=1,
                                    gnb_id=0, du_id=0, timeout=900):
        """
        Starts an observer of the event in syslog.

        Args:
            event_name (str, mandatory): The name of syslog event.
            success_regex (str, mandatory): The success regex of syslog event.
            match (str, optional): Type of awaiting. Possible values: any, all, sequence. Defaults to "all".
            till_occurs_times (str, optional): Number of event occurrence. Defaults to 1.
            gnb_id (int, optional): The ID of the GNB. Defaults to 0.
            du_id (int, optional): The ID of the DU. Defaults to 0.
            timeout (int, optional): The timeout value in seconds. Defaults to 900.
        """

        self.syslog_events[event_name] = {
            "event_success_regex": success_regex,
            "event_detected": False,
            "device_name": None
        }

        self.syslog_events[event_name]['device_name'] = self.syslog_alias.format(gnb_id, du_id)
        sys_device = DeviceFactory.get_device(name=self.syslog_events[event_name]['device_name'])

        if event_name not in self.observers:
            self.observers[event_name] = {}
        logging.info(f"Start '{event_name}' observer on device '{self.syslog_events[event_name]['device_name']}'")

        event_observer = sys_device.get_event(
            event_name="wait4",
            event_params={"detect_patterns": [self.syslog_events[event_name]['event_success_regex']],
                          "match": match,
                          "till_occurs_times": till_occurs_times}
        )
        self.observers[event_name][self.syslog_events[event_name]['device_name']] = event_observer

        event_observer.add_event_occurred_callback(
            callback=self._syslog_event_callback,
            callback_params={'event_name': event_name}
        )
        event_observer.start(timeout=float(timeout))

    def _syslog_event_callback(self, event_name):
        """
        Callback function for syslog event.

        Args:
            event_name (str, mandatory): The name of syslog event.
        """
        log_info_to_console(f"\nFound event '{event_name}' in syslog on device "
                            f"'{self.syslog_events[event_name]['device_name']}'.")
        self.syslog_events[event_name]['event_detected'] = True

    def verify_syslog_event_succeeded(self, event_name):
        """
        Verifies if the syslog event succeeded.

        Args:
            event_name (str, mandatory): The name of syslog event.

        Raises:
            SyslogEventObserverException: If the radio unit reset task not created.
            Exception: If 'start_syslog_event_observer' has not been run before.
        """
        if self.observers[event_name] is None:
            raise Exception("Please first run 'start_syslog_event_observer' ")
        if self.syslog_events[event_name]['event_detected']:
            logging.info(f"{self.observers[event_name][self.syslog_events[event_name]['device_name']].result()}")
            self.syslog_events[event_name]['event_detected'] = False
        else:
            raise SyslogEventObserverException(
                f"Event '{event_name}': '{self.syslog_events[event_name]['event_success_regex']}' not found in syslog "
                f"on device: '{self.syslog_events[event_name]['device_name']}'")

    def get_event_observer_full_result(self, event_name):
        """
        Returns full result of the observer.

        Args:
            event_name (str, mandatory): The name of syslog event.
        """
        return self.observers[event_name][self.syslog_events[event_name]['device_name']].result()[0]

    def get_attribute_of_event_observer_result(self, event_name, attribute_name, item_id=0):
        """
        Returns an attribute of the observer result.

        Args:
            event_name (str, mandatory): The name of syslog event.
            attribute_name (str, mandatory): The observer attribute. Available attributes:
                                            "line", "time", "named_groups", "groups", "matched"
            item_id (int, optional): The item identifier of observer result. Defaults to 0.
        """
        return self.observers[event_name][self.syslog_events[event_name]['device_name']].result()[0][item_id].get(
            attribute_name)


class SyslogEventObserverException(Exception):
    """
    Exception raised when observer of syslog event fails.
    """
    pass
