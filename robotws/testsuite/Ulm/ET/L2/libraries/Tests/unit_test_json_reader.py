import logging
import unittest
from testsuite.Ulm.ET.L2.libraries.new_class_libraries.json_reader import JsonReader, ScenarioParser
import logging
import json
import os


class TestJsonReader(unittest.TestCase):
    def setUp(self) -> None:
        return super().setUp()

    def test_reader_creation(self):
        reader_object = JsonReader()
        self.assertIn("scenario_1", reader_object.test_description)
        with self.assertLogs(level=logging.ERROR):
            JsonReader(filename="Fail")


class TestScenarioParser(unittest.TestCase):
    def setUp(self) -> None:
        return super().setUp()

    def test_get_scenario(self):
        scenario_parser = ScenarioParser("../../Template/l2_template.json")
        scenario_name = "scenario_1"
        scenario_1 = scenario_parser.get_scenario(scenario=scenario_name)
        self.assertEqual(scenario_name, scenario_1.name)
        self.assertNotEqual(scenario_1.cells, {}, msg=f"there are no cells configured for {scenario_name}")
        self.assertNotEqual(scenario_1.traffic_profiles_mapping, {},
                            msg=f"there are no traffic_profile configured for {scenario_name}")


if __name__ == '__main__':
    suite = unittest.TestSuite()
    # suite.addTest(TestJsonAnalyzer('test_ue_dict_generator'))
    # runner = unittest.TextTestRunner()
    # runner.run(suite)
    suite = unittest.TestLoader().loadTestsFromTestCase(TestJsonReader)
    unittest.TextTestRunner(verbosity=2).run(suite)
