# -*- coding: utf-8 -*-
"""
:author: Jaroslaw Zima
:contact: jaroslaw.zima@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""
from dsp_crasher.dsp_crasher import DspCrasher


NON_SILENT_DSP_HANDLERS = {
    'FSMF': DspCrasher().crash_nyquist,
    'ASIA': DspCrasher().crash_kepler
}

SILENT_DSP_HANDLERS = {
    'FSMF': DspCrasher().silent_crash_nyquist,
    'ASIA': DspCrasher().silent_crash_kepler
}

GPIO_MAPPING = {
    'enabled': 1,
    'disabled': 0
}


def crash_dsp_core(node, mode='non-silent', gpio='disabled', rel3=False):
    """ Crashes proper DSP core.

    :param str node: node/DSP core that will be crashed, for example: 1231 or 0x1231
    :param str mode: silent|non-silent
    :param str gpio: enabled|disabled
    :param bool rel3: must be set to True for Nyquist DSP, default: False
    """
    board = node[:4] if node.startswith('0x') else '0x' + node[:2]
    cpu = '0x' + node[-2:]
    fsm_release = "FSMF" if rel3 else "ASIA"
    if mode == 'non-silent':
        NON_SILENT_DSP_HANDLERS[fsm_release](board, cpu)
    else:
        SILENT_DSP_HANDLERS[fsm_release](board, cpu, GPIO_MAPPING[gpio])
