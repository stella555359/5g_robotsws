# -*- coding: utf-8 -*-
"""
Keywords to calculate parameters need for Call Processing tests,
 for example calculating throughput per stream.

:copyright: Nokia Networks
:author: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com
:maintainer: I_MN_5GSC_KRK_AUTO
:contact: I_MN_5GSC_KRK_AUTO@internal.nsn.com

"""

import re
from testsuite.Bangalore.ORAN.resources.python.\
    Macro.Python.exceptions import BadTputFormat


class Calculator(object):
    """Class contains calculator for throughput test"""
    def __init__(self):
        """
        Constructor of Calculator class.
        """

    def calculate_tput_per_stream(self, parallel_streams_number, total_tput):
        """
        Return throughput per stream
        :param parallel_streams_number: Number of streams
        :param total_tput: Tput for all streams
        :return: Tput per stream
        """
        tput_raw = re.search(r'(?P<TPUT_VALUE>^\d+) (?P<TPUT_UNIT>\D+)',
                             total_tput)
        if tput_raw:
            tput_per_stream = \
                float(tput_raw.group('TPUT_VALUE'))/int(
                    parallel_streams_number)
        else:
            raise BadTputFormat('Invalid throughput string: {}, '
                                'eg: 100 MBytes/sec'.
                                format(total_tput))
        return str('{} {}').format(tput_per_stream,
                                   tput_raw.group('TPUT_UNIT'))
