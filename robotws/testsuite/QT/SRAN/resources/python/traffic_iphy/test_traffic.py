import unittest
import parsers
from pprint import pprint


example_bearer_stats = """
    ===========================================
    UE 1, bearer 1: DL L3 stats for internal traffic
    ====================================================
    Parameter                           Value
    ----------------------------------------------------
    Timebase interval (msec)            1000
    Average window size (in timebases)  10
    Real average window size            10
    ----------------------------------------------------
    Maximum data rate                   56000    (56.0 K)
    Minimum data rate                   53760    (53.8 K)
    Average data rate                   55552    (55.6 K)
    Last data rate                      56000    (56.0 K)
    ----------------------------------------------------
    Maximum latency                     52
    Minimum latency                     4
    Average latency                     4
    Latency violations                  0
    ----------------------------------------------------
    Packets sent                        5801
    Total Packets sent                  5801
    Packets dropped (congestion)        0
    Packets dropped (Gen.suspended)     0
    ----------------------------------------------------
    Packets received                    5800
    Packets lost                        0
    PN forward jumps (>32 SDUs)         0
    ----------------------------------------------------
    Packets out of sequence             0
    Packets duplicated                  0
    PN backward jumps (>32 SDUs)        0
    Packets corrupted                   0
    Packets unexpected                  0
    Total Packets Lost                  0
    ----------------------------------------------------
    Absolute max packet interval        153
    Absolute min packet interval        0
    Maximum packet interval             68
    Minimum packet interval             5
    Average packet interval             20
    ====================================================
    """
expected = {
     'absolute_max_packet_interval': 153,
     'absolute_min_packet_interval': 0,
     'average_data_rate': 55552,
     'average_latency': 4,
     'average_packet_interval': 20,
     'average_window_size': 10,
     'last_data_rate': 56000,
     'latency_violations': 0,
     'maximum_data_rate': 56000,
     'maximum_latency': 52,
     'maximum_packet_interval': 68,
     'minimum_data_rate': 53760,
     'minimum_latency': 4,
     'minimum_packet_interval': 5,
     'packets_corrupted': 0,
     'packets_dropped': 0,
     'packets_duplicated': 0,
     'packets_lost': 0,
     'packets_out_of_sequence': 0,
     'packets_received': 5800,
     'packets_sent': 5801,
     'packets_unexpected': 0,
     'pn_backward_jumps': 0,
     'pn_forward_jumps': 0,
     'real_average_window_size': 10,
     'timebase_interval': 1000,
     'total_packets_lost': 0,
     'total_packets_sent': 5801,
     'ue': 1
}


class TestTraffic(unittest.TestCase):

    def test_parse(self):
        bs = parsers.BearerStats(example_bearer_stats)
        pprint(bs)
        self.assertEqual(bs.stats, expected)
