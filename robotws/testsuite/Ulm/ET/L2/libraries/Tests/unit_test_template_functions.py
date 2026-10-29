import unittest
import testsuite.Ulm.ET.L2.libraries.template_functions as template_functions
import shutil


class TestTemplateManagerClass(unittest.TestCase):
    def setUp(self) -> None:
        self.test_data_path = "/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/"
        return super().setUp()

    @classmethod
    def setUpClass(cls):
        super(TestTemplateManagerClass, cls).setUpClass()
        test_data_path = "/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/"
        cls.template_functions = template_functions.initialize_test(
            # relative_path_to_json="Tests/Test_Data/test_config.json",
            relative_path_to_json="Tests/Test_Data/test_config.json",
            path_to_basic_cfg=test_data_path + "basic_setup.cfg",
            modified_file_path=test_data_path + "m_config.cfg")

    def test_attach_list(self):
        cell_attach_data = template_functions.get_attach_list("scenario_2")
        # print(cell_attach_data)
        for ue_mode, ue_group in cell_attach_data.items():
            for ue_id, ue_data in ue_group.items():
                print(ue_id)
                self.assertIn("nr_ue_cap", ue_data)
                self.assertIs(type(ue_data["bearer"]), int)
                self.assertIs(type(ue_data["cell"]), str)
                self.assertIs(type(ue_data["optional_lte_attach_args"]), dict)
                self.assertIs(type(ue_data["optional_dual_connectivity_args"]), dict)
                if ue_mode == "nsa":
                    self.assertGreaterEqual(ue_id, 101, msg=f"ue_id for ue {ue_id} of type {ue_mode} is wrong")
                else:
                    self.assertGreater(101, ue_id, msg=f"ue_id for ue {ue_id} of type {ue_mode} is wrong")

    def test_get_list_of_all_scenarios(self):
        scenarios = template_functions.get_list_of_all_scenarios(isCIT=False)
        self.assertIs(type(scenarios), list)
        for scenario in scenarios:
            self.assertIs(type(scenario), str)

    def test_get_traffic_commands(self):
        traffic_commands = template_functions.get_traffic_commands("scenario_1")
        for command in traffic_commands:
            self.assertIs(type(command["ue_id"]), str)
            self.assertIs(type(command["ue_id"]), str)
            self.assertIs(type(command["trf_id"]), int)
            self.assertIs(type(command["protocol"]), str)
            self.assertIs(type(command["direction"]), str)
            try:
                self.assertIs(type(command["mbps"]), int)
            except KeyError:
                pass
            self.assertIs(type(command["seconds"]), int)

    def test_multiple_traffic_profiles_per_ue_group(self, scenario="scenario_1"):
        traffic_commands = template_functions.get_traffic_commands(scenario)
        ue_ids = []
        for command in traffic_commands:
            ue_ids.append({command["ue_id"]: command["trf_id"]})
        '''traffic ids should not be reuses'''
        trf_id_used_by_ue = {}
        for ue in ue_ids:
            for id, trf_id in ue.items():
                if id in trf_id_used_by_ue.keys():
                    self.assertNotEqual(trf_id, trf_id_used_by_ue[id],
                                        msg=f"traffic ids have been reused for ue {id}\n{ue_ids}\n{traffic_commands}")
                trf_id_used_by_ue.update({id: trf_id})

    def test_backwards_compatibility_for_traffic_profiles(self):
        traffic_commands = template_functions.get_traffic_commands("scenario_2")
        self.assertGreater(len(traffic_commands), 1)

    def test_special_traffic_cases(self):
        traffic_commands = template_functions.get_traffic_commands("scenario_3")
        for command in traffic_commands:
            self.assertIn("burst", command.keys())
            self.assertIn("period_ms", command.keys())

    def test_high_traffic_case(self):
        traffic_commands = template_functions.get_traffic_commands("scenario_4")
        expected_total_throughput = 350
        for command in traffic_commands:
            # Make sure no traffic stream is above 150 mbps
            self.assertGreaterEqual(150, command['mbps'])
        created_total_traffic = sum(command["mbps"] for command in traffic_commands)
        self.assertEqual(created_total_traffic, expected_total_throughput)
        # also make sure traffic ID is not reused
        self.test_multiple_traffic_profiles_per_ue_group("scenario_4")

    def test_bi_directional_traffic(self):
        traffic_commands = template_functions.get_traffic_commands("scenario_2")
        directions = []
        for command in traffic_commands:
            directions.append(command["direction"])
        self.assertIn("ul", directions)

    def test_VoNr_traffic_commands(self):
        traffic_commands = template_functions.get_traffic_commands("scenario_5")
        for command in traffic_commands:
            self.assertIn("rtp_codec", command)
            self.assertIn("rtp_voice_silence", command)
            self.assertIn("direction", command)

    def test_is_scenario_modifications_configured(self):
        configured, data = template_functions.is_scenario_modifications_configured(scenario_name="scenario_1")
        if configured:
            self.assertIs(type(data), dict, msg=configured)
        else:
            self.assertIs(data, None, msg="something went wrong")

    def test_basic_config_modifier(self):
        shutil.copyfile("/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/basic_setup.cfg",
                        "/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/b_basic_setup.cfg")
        template_functions.configure_basic_cfg_file()
        modified_file_path = self.test_data_path + "m_config.cfg"
        with open(modified_file_path, 'r') as basic_config:
            lines = basic_config.readlines()
        for line in lines:
            if "ue_param id=1 ue_nr_capabilities" in line:
                self.assertIn("modified_ue_cap", line)
        shutil.copyfile("/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/b_basic_setup.cfg",
                        "/home/ute/DEVELOPMENT/robotws/testsuite/Ulm/ET/L2/libraries/Tests/Test_Data/basic_setup.cfg")

    def test_get_list_of_ues_for_pdu_modification(self):
        ues = template_functions.get_list_of_ues_for_pdu_modification(scenario_name="scenario_1", ue_type="sa")
        for ue_name, ue_data in ues.items():
            self.assertEqual(ue_data["qos_flows"], ["1", "3"])
            self.assertEqual(ue_data["pdu"], "3")

    def test_get_list_of_all_scenarios(self):
        scenarios = template_functions.get_list_of_all_scenarios(["CRT"])
        self.assertEqual(scenarios, ["scenario_1", "scenario_2", "scenario_3", "scenario_4", "scenario_5"])


if __name__ == '__main__':
    Suite = unittest.TestSuite()
    Suite.addTest(TestTemplateManagerClass('test_get_list_of_all_scenarios'))
    # runner = unittest.TextTestRunner()
    # runner.run(Suite)
    Suite = unittest.TestLoader().loadTestsFromTestCase(TestTemplateManagerClass)
    unittest.TextTestRunner(verbosity=2).run(Suite)
