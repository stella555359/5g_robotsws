import logging
import shutil
import unittest

from testsuite.Ulm.ET.L2.libraries.ScfChanges import ScfChanges


class TestScfChangesClass(unittest.TestCase):
    def setUp(self) -> None:
        self.test_data_path = "/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/"
        with open(self.test_data_path + "test_scf.xml",
                  "r") as test_scf_file:
            self.xml_content = test_scf_file.read()

    def test_simple_scf_change(self):
        scf_changes_object = ScfChanges(self.xml_content)
        scf_changes_object.add_change({"regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
                                       "p_name": "reqMinNumPuschPrb",
                                       "value": "30"})
        expected_parameters = [{'parameterName': 'reqMinNumPuschPrb',
                                'value': '30',
                                'operation': 'update'}]

        result = scf_changes_object.get_modifications_for_commissioning()
        self.assertTrue(result, msg="result is empty!")
        for entry in result:
            self.assertEqual(entry["parameters"], expected_parameters)

    def test_simple_scf_change_warning(self):
        scf_changes_object = ScfChanges(self.xml_content)
        scf_changes_object.add_change({"regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
                                       "p_name": "reqMinNumPuschPrb",
                                       "value": "30"})
        self.assertWarns(Warning, scf_changes_object.add_change(
                                      {"regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
                                       "p_name": "reqMinNumPuschPrb",
                                       "value": "30"}))

    def test_list_change(self):
        scf_changes_object = ScfChanges(self.xml_content)
        scf_changes_object.add_change({
            "regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
            "list_name": "periodicCsiAcquisition",
            "p_name": "csiReportPeriodicity",
            "value": "slots160"})
        expected_parameters = [{'parameterName': 'periodicCsiAcquisition',
                                'operation': 'update',
                                'value': [{'csiReportPeriodicity': 'slots160'}]}]
        result = scf_changes_object.get_modifications_for_commissioning()
        self.assertTrue(result, msg="result is empty!")
        for entry in result:
            self.assertEqual(entry["parameters"], expected_parameters)

    def test_complex_list_change(self):
        scf_changes_object = ScfChanges(self.xml_content)
        scf_changes_object.add_change({
            "regex": "MRBTS-[0-9]+/NRBTS-[0-9]+/NRCELL-[0-9]+",
            "p_name": "basicBeamSet",
            "list_name": "beamSet",
            "value": "beamSet_6"})
        expected_parameters = [{'parameterName': 'beamSet',
                                'operation': 'update',
                                'value': [{'basicBeamSet': 'beamSet_6',
                                           'leftEdgeAngle': '60',
                                           'nrBtsBeamRefinementP2': 'false',
                                           'rightEdgeAngle': '60'}]}]

        result = scf_changes_object.get_modifications_for_commissioning()
        self.assertTrue(result, msg="result is empty!")
        for entry in result:
            self.assertEqual(entry["parameters"], expected_parameters)
            print(entry["distName"])


if __name__ == '__main__':
    Suite = unittest.TestSuite()
    Suite.addTest(TestScfChangesClass('test_simple_scf_change'))
    Suite.addTest(TestScfChangesClass('test_list_change'))
    Suite.addTest(TestScfChangesClass('test_complex_list_change'))
    Suite.addTest(TestScfChangesClass('test_simple_scf_change_warning'))
    unittest.TextTestRunner(verbosity=2).run(Suite)
