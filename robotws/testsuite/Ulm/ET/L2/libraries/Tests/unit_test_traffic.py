import logging
import unittest
import json
import os

from testsuite.Ulm.ET.L2.libraries.traffic import TrafficProfile


class TestTrafficProfileClass(unittest.TestCase):
    def setUp(self) -> None:
        return super().setUp()

    def test_creation_udp_traffic_profile(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "throughput_dl": 10,
            "throughput_ul": 5,
            "qfi": 1,
            "unit_dl": "mbps",
            "unit_ul": "kbps",
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        # ** Test the correct creation of a traffic_profile_object
        self.assertEqual(traffic_profile_instance.name, "traffic_profile_1")

    def test_creatation_rtp_traffic_profile(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "rtp_codec": "amr_wb_23_85",
            "rtp_voice_silence": "1:0",
            "direction": "ul",
            "qfi": 3,
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        # ** Test the correct creation of a traffic_profile_object
        self.assertEqual(traffic_profile_instance.name, "traffic_profile_1")

    def test_traffic_split(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "throughput_dl": 170,
            "throughput_ul": 5,
            "qfi": 1,
            "unit_dl": "mbps",
            "unit_ul": "kbps",
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        self.assertEqual(len(traffic_profile_instance.get_traffic_parameters(max_trf_id_used=3)),
                         3, msg="Incorrect amount of traffic commands created. "
                         "Please check if traffic is split correctly:\n"
                         "%s" % traffic_profile_instance.get_traffic_parameters(max_trf_id_used=3))

    def test_no_split_with_kbps(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "throughput_dl": 300,
            "throughput_ul": 5,
            "qfi": 1,
            "unit_dl": "kbps",
            "unit_ul": "kbps",
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        self.assertEqual(len(traffic_profile_instance.get_traffic_parameters(max_trf_id_used=3)),
                         2, msg="Incorrect amount of traffic commands created. "
                         "Please check if traffic is split correctly:\n"
                         "%s" % traffic_profile_instance.get_traffic_parameters(max_trf_id_used=3))

    def test_both_ul_dl_created(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "throughput_dl": 300,
            "throughput_ul": 5,
            "qfi": 1,
            "unit_dl": "kbps",
            "unit_ul": "kbps",
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        used_directions = []
        for command in traffic_profile_instance.get_traffic_parameters(max_trf_id_used=2):
            self.assertIn("direction", command)
            used_directions.append(command["direction"])
        self.assertSetEqual(set(sorted(used_directions)), {"ul", "dl"},
                            msg="could not find both directions (ul/dl)")

    def test_no_command_for_zero_traffic(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "throughput_dl": 300,
            "throughput_ul": 0,
            "qfi": 1,
            "unit_dl": "kbps",
            "unit_ul": "kbps",
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        used_directions = []
        for command in traffic_profile_instance.get_traffic_parameters(max_trf_id_used=2):
            self.assertIn("direction", command)
            used_directions.append(command["direction"])
        self.assertEqual(list(set(used_directions)), ["dl"])

    def test_rtp_command_generation(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "rtp_codec": "amr_wb_23_85",
            "rtp_voice_silence": "1:0",
            "direction": "ul",
            "qfi": 3,
            "traffic_duration_sec": 10,
            "traffic_type": "static"})
        traffic_commands = traffic_profile_instance.get_traffic_parameters(max_trf_id_used=2)
        for command in traffic_commands:
            self.assertIn("rtp_codec", command)

    def test_additional_parameters_for_traffic(self):
        traffic_profile_instance = TrafficProfile("traffic_profile_1")
        traffic_profile_instance.update_traffic_attributes({
            "throughput_dl": 300,
            "throughput_ul": 0,
            "qfi": 1,
            "unit_dl": "kbps",
            "unit_ul": "kbps",
            "traffic_duration_sec": 10,
            "traffic_type": "static",
            "additional_param": "additional_value"})
        traffic_commands = traffic_profile_instance.get_traffic_parameters(max_trf_id_used=2)
        for command in traffic_commands:
            self.assertIn("additional_param", command)


if __name__ == '__main__':
    Suite = unittest.TestSuite()
    Suite = unittest.TestLoader().loadTestsFromTestCase(TestTrafficProfileClass)
    unittest.TextTestRunner(verbosity=2).run(Suite)
