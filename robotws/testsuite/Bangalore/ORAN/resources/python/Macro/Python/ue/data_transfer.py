# -*- coding: utf-8 -*-
"""
Keywords for UEs.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python.utilities import get_builtin_instance
from testsuite.Bangalore.ORAN.resources.\
    python.Macro.Python.ue.calculator import Calculator


def start_data_transfer_on_real_ue(dt_name, ue_alias,
                                   direction, protocol, duration,
                                   tput, parallel_streams,
                                   size_packet, buffer_client=None,
                                   buffer_server=None, interval=None,
                                   qci=None,
                                   linux_congestion=None):
    ue = get_builtin_instance('ue')
    tput_args = _get_tput_args(dt_name, ue_alias, direction,
                               protocol.lower(), duration, tput,
                               parallel_streams,
                               size_packet, buffer_client=buffer_client,
                               buffer_server=buffer_server,
                               interval=interval, qci=qci,
                               linux_congestion=linux_congestion)
    ue.start_data_transfer(**tput_args)


def _get_tput_args(dt_name, ue_alias, direction, protocol, duration,
                   tput, parallel_streams,
                   size_packet, **kwargs):
    tput_per_stream = Calculator().\
        calculate_tput_per_stream(parallel_streams, total_tput=tput)
    tput_args = {
        'dt_name': dt_name,
        'ue_alias': ue_alias,
        'direction': direction,
        'protocol': protocol,
        'duration': duration,
        'parallel_streams': parallel_streams
    }

    for arg_name in kwargs:
        if kwargs[arg_name]:
            tput_args[arg_name] = kwargs[arg_name]

    if protocol.lower() == 'udp':
        tput_args['throughput'] = tput_per_stream
        tput_args['packet'] = size_packet
    elif protocol.lower() == 'tcp':
        tput_args['max_segment_size'] = size_packet

    return tput_args
