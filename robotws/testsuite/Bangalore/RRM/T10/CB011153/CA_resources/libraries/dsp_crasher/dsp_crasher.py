# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from builtins import object
from contextlib import contextmanager

from robot.api import logger

from .DspCrash import CDspCrash


FSM_IP = '192.168.255.129'


class DspCrasher(object):
    """ Class with `keywords` used to crash DSP  """

    def __init__(self):
        self._port = 15003

    def crash_faraday(self, board, cpu):
        """ Crashes DSP - Faraday

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        """
        self._crash_dsp('faraday', board, cpu)

    def crash_nyquist(self, board, cpu):
        """ Crashes DSP - Nyquist (FSMF)

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        """
        self._crash_dsp('nyquist', board, cpu)

    def crash_kepler(self, board, cpu):
        """ Crashes DSP - Kepler (ASIA)

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        """
        self._crash_dsp('kepler', board, cpu)

    def silent_crash_faraday(self, board, cpu, silent_crash_type):
        """ Silently crashed DSP - Faraday

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        :param int silent_crash_type: 1 for GPIO enabled, 0 for disabled
        """
        self._silent_crash_dsp('faraday', board, cpu, silent_crash_type)

    def silent_crash_nyquist(self, board, cpu, silent_crash_type):
        """ Silently crashed DSP - Nyquist (FSMF)

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        :param int silent_crash_type: 1 for GPIO enabled, 0 for disabled
        """
        self._silent_crash_dsp('nyquist', board, cpu, silent_crash_type)

    def silent_crash_kepler(self, board, cpu, silent_crash_type):
        """ Silently crashed DSP - Kepler (ASIA)

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        :param int silent_crash_type: 1 for GPIO enabled, 0 for disabled
        """
        self._silent_crash_dsp('kepler', board, cpu, silent_crash_type)

    def generate_fault_indication(self, board, cpu, fault_id, fault_msg, fault_state):
        """ Generates fault in cpu

        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        :param str fault_id:
        :param str fault_msg:
        :param str fault_state:
        """
        with self._perform_operation_with_dsp_crasher() as dsp_crasher:  # type: CDspCrash
            dsp_crasher.sendFaultIndicationMessageToBts(board, cpu, fault_id, fault_msg, fault_state)

    def _crash_dsp(self, cpu_type, board, cpu):
        """ Main non-silent crashing method

        :param str cpu_type: type of DSP - faraday|nyquist|kepler
        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        """
        with self._perform_operation_with_dsp_crasher() as dsp_crasher:  # type: CDspCrash
            logger.debug('Crash {} `{}` core from `{}` board'.format(cpu_type, cpu, board))
            dsp_crasher.generateExceptionToDsp(cpu_type, board, cpu)

    def _silent_crash_dsp(self, cpu_type, board, cpu, silent_crash_type):
        """" Main silent crashing method

        :param str cpu_type: type of DSP - faraday|nyquist|kepler
        :param str board: board where DSP is located, for example: 0x12 (for DSP core 0x1231)
        :param str cpu: cpu to crash, for example: 0x31 (for DSP core 0x1231)
        :param int silent_crash_type: 1 for GPIO enabled, 0 for disabled
        """
        with self._perform_operation_with_dsp_crasher() as dsp_crasher:  # type: CDspCrash
            logger.debug('Silent crash {} `{}` core from `{}` board (silent crash type: {})'.format(cpu_type,
                                                                                                    cpu,
                                                                                                    board,
                                                                                                    silent_crash_type))
            dsp_crasher.generateSilentCrashToDsp(cpu_type, board, cpu, silent_crash_type)

    @contextmanager
    def _perform_operation_with_dsp_crasher(self):
        """ Sets up and tears down backend """
        try:
            logger.debug('Initialize DspCrasher')
            dsp_crasher = CDspCrash(FSM_IP, self._port, False)
            dsp_crasher.openConnection()
            yield dsp_crasher
            logger.debug('Teardown DspCrasher')
            dsp_crasher.closeConnection()
        except Exception as e:
            logger.error(e)
            raise
