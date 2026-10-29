import unittest
import logging
import json
import os
from testsuite.Ulm.ET.L2.libraries.new_class_libraries.suite import Scenario
from testsuite.Ulm.ET.L2.libraries.new_class_libraries.ue import NsaUE, SaUE, UeGroup, UE
from testsuite.Ulm.ET.L2.libraries.new_class_libraries.traffic import TrafficProfile


class TestScenarioClass(unittest.TestCase):
    def setUp(self) -> None:
        return super().setUp()

    def test_create_scenario(self):
        new_scenairo = Scenario("scenario_1")
        self.assertIsInstance(new_scenairo, Scenario)

    def test_add_ue_group_to_cell(self):
        scenario = Scenario("scenario_1")
        ue_group_1 = UeGroup("ue_group_1", "group")
        scenario.add_ue_group_to_cell(ue_group_1, "1")
        self.assertIn(ue_group_1, scenario.cells["1"])

    def test_get_ue_attach_list(self):
        scenario = Scenario("scenario_1")
        # ** create a NSA Ue Group to test attach with
        ue_group_1 = UeGroup("ue_group_1", "group")
        ue_group_1.add_ue(NsaUE(group="ue_group_1", bearers=[2]))
        ue_group_1.add_ue(NsaUE(group="ue_group_1", bearers=[2]))
        # ** create a SA Ue Group to test attach with
        ue_group_2 = UeGroup("ue_group_2", "group")
        ue_group_2.add_ue(SaUE(group="ue_group_2", pdu=1))
        ue_group_2.add_ue(SaUE(group="ue_group_2", pdu=1))
        scenario.add_ue_group_to_cell(ue_group_1, "1")
        scenario.add_ue_group_to_cell(ue_group_2, "2")
        self.assertEqual(len(scenario.get_ue_attach_list()["nsa"]), 2,
                         msg="the wrong number of UE's is seen in the attach list")
        self.assertEqual(len(scenario.get_ue_attach_list()["sa"]), 2,
                         msg="the wrong number of UE's is seen in the attach list")

    def test_get_traffic_commands(self):
        scenario = Scenario("scenario_1")
        # ** create a NSA Ue Group to test attach with
        ue_group_1 = UeGroup("ue_group_1", "group")
        ue_group_1.add_ue(NsaUE(group="ue_group_1", bearers=[2]))
        ue_group_1.add_ue(NsaUE(group="ue_group_1", bearers=[2]))
        # ** create a SA Ue Group to test attach with
        ue_group_2 = UeGroup("ue_group_2", "group")
        ue_group_2.add_ue(SaUE(group="ue_group_2", pdu=1))
        ue_group_2.add_ue(SaUE(group="ue_group_2", pdu=1))
        scenario.add_ue_group_to_cell(ue_group_1, "1")
        scenario.add_ue_group_to_cell(ue_group_2, "2")
        # ** create a traffic profile
        traffic_profile_1 = TrafficProfile(name="traffic_profile_1", type="udp",
                                           throughput_ul=5, unit_ul="mbps",
                                           throughput_dl=10, unit_dl="mbps",
                                           traffic_duration_sec=30, traffic_type="static")
        scenario.traffic_profiles.update({"traffic_profile_1": traffic_profile_1})
        scenario.add_ue_group_to_traffic_profile(ue_group_1, "traffic_profile_1")
        with self.assertLogs(level=logging.WARN) as cm:
            scenario.get_traffic_commands()
        self.assertIn('WARNING:root:there seems to be no traffic profile set for attached ue_group_2 in scenario_1',
                      cm.output)

    def test_special_keywords(self):
        scenario = Scenario("scenario_1")
        special_keywords = ["Modify Vendor File", "Reboot GNB", "configure Airphone"]
        scenario.special_keywords = special_keywords
        self.assertEqual(scenario.special_keywords, special_keywords)


if __name__ == '__main__':
    Suite = unittest.TestSuite()
    # suite.addTest(TestJsonAnalyzer('test_ue_dict_generator'))
    # runner = unittest.TextTestRunner()
    # runner.run(suite)
    Suite = unittest.TestLoader().loadTestsFromTestCase(TestScenarioClass)
    unittest.TextTestRunner(verbosity=2).run(Suite)
