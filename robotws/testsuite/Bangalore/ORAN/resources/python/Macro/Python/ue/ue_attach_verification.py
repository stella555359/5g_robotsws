# -*- coding: utf-8 -*-
"""
Keywords for UEs.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
import logging
from moler.device import DeviceFactory
from moler.exceptions import ConnectionObserverTimeout
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python.bts.common.log import GnbLog


class UeAttachVerification(object):
    def __init__(self):
        self._observer = None

        self.__nr_cell_id = None
        self.__beam_id = None

    @property
    def nr_cell_id(self):
        return self.__nr_cell_id

    @property
    def beam_id(self):
        return self.__beam_id

    def start_ue_rach_observer(self, bts_id=0, du_id=0):
        """
        Start observing RACH on syslog device.
        :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line
        configuration - gnb.dus[]
        """
        gnblog = GnbLog()
        gnblog.start_collecting_syslog()
        syslog = DeviceFactory.get_device(name=gnblog.syslog_alias.
                                          format(bts_id, du_id))
        syslog.goto_state('SYSLOG', keep_state=False)
        self._observer = syslog.get_event(event_name="ue5g_rach",
                                          event_params={
                                              "till_occurs_times": 1}
                                          )
        self._observer.start()

    def verify_rach(self, timeout=60, stop_collecting_syslog=True,
                    raise_exception=False):
        """

        :param timeout: Maximum time for waiting on RACH message.
        :param stop_collecting_syslog: Flag True/False if stop syslog
        collection at th end
        :param raise_exception: raise RachFailure exception when Rach fails.
        """
        try:
            results = self._observer.await_done(timeout=timeout)[0]
            logging.debug("Detected events: {}".format(results))
            # self.__nr_cell_id = results[0]['named_groups']['NR_CELL_ID']
            # self.__beam_id = results[2]['named_groups']['BEAM']
            # MolerTest.info("UE attached to 5G. NR_CELL_ID={},
            # BEAM_ID={}".format(self.__nr_cell_id, self.__beam_id))
        except ConnectionObserverTimeout:
            if raise_exception:
                raise RachFailure("UE Attach to 5G failed. 5G Rach is not "
                                  "visible in syslog!")
            logging.warning("UE Attach to 5G failed. 5G Rach is not "
                            "visible in syslog!.\n"
                            "It's in testing phase so if you think UE "
                            "attached "
                            "correctly please contact Tomasz Krol")
        finally:
            if stop_collecting_syslog:
                GnbLog().stop_collecting_syslog()


class RachFailure(Exception):
    pass
