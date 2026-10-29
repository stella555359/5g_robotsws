from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.ue.ue_group import UeCollection
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.traffic import TrafficProfile
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.scenario import Scenario
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.logger import logger, logging

import logging
import re
import os


class GroupParser:
    @classmethod
    @logger
    def add_ue_to_collection(self, collection_object, ue_cell_mapping,
                             ue_collection_contents, ue_collection_identifier):
        for _ in range(ue_collection_contents["number_of_ues"]):
            collection_object.add_ue_to_group(ue_collection_contents["type"].upper(),
                                              cell=ue_cell_mapping[ue_collection_identifier],
                                              **ue_collection_contents)

    @classmethod
    @logger
    def populate_ue_groups(self, readerObject, ue_cell_mapping):
        for ue_collection_identifier, ue_collection_contents in readerObject.ue_profiles['ue_groups'].items():
            if ue_collection_identifier not in list(ue_cell_mapping.keys()):
                print("UE Group: {0} incorrectly configured ! "
                      "Please correct the JSON, ue groups should not be reused".format(ue_collection_identifier))
                continue
            ue_collection_obj = UeCollection(ue_collection_identifier)
            GroupParser.add_ue_to_collection(ue_collection_obj, ue_cell_mapping,
                                             ue_collection_contents, ue_collection_identifier)
        return UeCollection.get_ue_groups()


class TrafficParser:
    @classmethod
    @logger
    def get_traffic_profile_for_each_scenario(self, reader_object):
        ue_group_traffic_profile_map = {}
        for scenario_name, scenario_description in reader_object.test_description.items():
            try:
                ue_group_traffic_profile_map[scenario_name] = scenario_description['traffic_profiles']
                self.get_traffic_profile_description(reader_object)
            except Exception as e:
                print("Scenario {0} does not have a valid traffic profile configured {1}".format(scenario_name, e))

    @classmethod
    @logger
    def get_traffic_profile_description(self, reader_object):
        traffic_profile_map = {}
        for traffic_profile_name, traffic_profile_description in reader_object.traffic_profiles.items():
            traffic_obj = TrafficProfile(name=traffic_profile_name)
            traffic_obj.update_traffic_attributes(traffic_profile_description)
            traffic_profile_map[traffic_profile_name] = traffic_obj
        return traffic_profile_map


class ScenarioParser:
    def __init__(self, reader_obj, is_classical):
        self.reader_object = reader_obj
        self._scenarios = {}
        self.ue_group_cell_mapping = {}
        self.ue_group_traffic_profile_mapping = {}
        self.list_of_scenarios = []
        self.required_cells = None
        self.traffic_profiles = None
        self._num_ues_per_cell = {}
        self._all_ue_groups = {}
        self.is_classical = is_classical
        self.run_preparations()
        self.populate_scenarios()
        self.map_ue_group_to_csi_report()
        self.argfile_path = "/home/ute/argfile.txt"

    def map_ue_group_to_csi_report(self):
        for scenario_name, scenario_data in self.reader_object.test_description.items():
            ue_group_csi_mapping = scenario_data.get("ue_group_csi_mapping")
            if ue_group_csi_mapping:
                logging.info("csi report mapping for %s is: %s", scenario_name, ue_group_csi_mapping)
                self._scenarios[scenario_name].ue_group_csi_mapping = ue_group_csi_mapping

    @logger
    def run_preparations(self):
        self.ue_group_cell_mapping = self.get_cell_ue_group_mapping()
        self.traffic_profiles = TrafficParser.get_traffic_profile_description(self.reader_object)

    @logger
    def _populate_num_ues_per_cell(self):
        if not self._all_ue_groups:
            self._all_ue_groups = GroupParser.populate_ue_groups(self.reader_object, self.ue_group_cell_mapping)
        for ue_group in self._all_ue_groups:
            if ue_group.cell in self._num_ues_per_cell.keys():
                self._num_ues_per_cell[ue_group.cell] += len(ue_group.get_list_of_configured_ue_ids())
            else:
                self._num_ues_per_cell[ue_group.cell] = len(ue_group.get_list_of_configured_ue_ids())

    @property
    def num_ues_per_cell(self):
        if not self._num_ues_per_cell:
            self._populate_num_ues_per_cell()
        return self._num_ues_per_cell

    @property
    def scenarios(self):
        return self._scenarios

    @logger
    def get_required_cells(self):
        if not self.required_cells:
            return self.identify_required_cells()
        else:
            return self.required_cells

    @logger
    def get_scenario(self, scenario):
        try:
            return self._scenarios[scenario]
        except KeyError as e:
            logging.error("The selected scenario name ({0}) is not in the json.".format(e))
            return None

    @logger
    def _parse_all_scenarios(fn):
        mapping_dict = {}

        def inner(self):
            scenarios = self._determine_list_of_configured_scenarios()
            for scenario in scenarios:
                mapping_dict.update(fn(self, scenario))
            return mapping_dict
        return inner

    @_parse_all_scenarios
    @logger
    def get_cell_ue_group_mapping(self, scenario):
        mapping_dict = {}
        for cell, ue_group_types in self.reader_object.test_description[scenario]["cells_ue_mapping"].items():
            self._parse_ue_groups_for_cell_ue_mapping(
                cell, ue_group_types, mapping_dict)
        return mapping_dict

    @logger
    def _determine_list_of_configured_scenarios(self):
        return (self.reader_object.test_description.keys())

    @logger
    def _parse_ue_groups_for_cell_ue_mapping(self, cell, ue_group_types, mapping_dict):
        for item in ue_group_types['ue_groups']:
            if item not in list(mapping_dict.keys()):
                mapping_dict[item] = cell
            else:
                print("UE Group {0} already mapped to cell {1}."
                      "Please correct the JSON to ensure that the UE"
                      "groups are not reused".format(item, mapping_dict[item]))

    @logger
    def populate_scenarios(self):
        self._populate_num_ues_per_cell()
        if not self._all_ue_groups:
            self._all_ue_groups = GroupParser.populate_ue_groups(self.reader_object, self.ue_group_cell_mapping)
        """Create Scenario objects"""
        for scenario_name in self.reader_object.test_description.keys():
            self.scenarios.update({scenario_name: Scenario(scenario_name, self.is_classical)})
        for scenario_name, scenario in self._scenarios.items():
            logging.info("Parsing Scenario {0}".format(scenario_name))
            """UE group to Scenario mapping"""
            ue_group_cell_mapping = \
                list(self.reader_object.test_description[scenario_name]['cells_ue_mapping'].values())
            scenario.add_ue_groups_to_scenario(ue_group_cell_mapping, self._all_ue_groups)
            """Traffic profile mapping"""
            self.handle_traffic_profile_mapping(scenario_name, scenario)

            """Misc"""
            scenario.pm_counter_start_before_L3 = \
                self.reader_object.test_description[scenario_name].get("pm_counter_start_before_L3")
            scenario.with_pm_counters = self.reader_object.test_description[scenario_name].get("with_pm_counters")
            scenario.filter_bitmaps = \
                self.reader_object.test_description[scenario_name].get("ttitrace_filter_bitmaps")
            scenario.special_keywords = self.reader_object.test_description[scenario_name].get("special_keywords")

            """Scenario Configuration Handling"""
            self.add_csi_profiles_to_scenarios()
            self.handle_scenario_configuration(scenario_name, scenario)

    def add_csi_profiles_to_scenarios(self):
        for scenario_data in self.scenarios.values():
            scenario_data.csi_report_profiles = self.reader_object.csi_report_profile

    @logger
    def handle_traffic_profile_mapping(self, scenario_name, scenario):
        traffic_mapping = self._get_traffic_profile_ue_group_mapping(scenario_name)
        for ue_group, traffic_profiles in traffic_mapping.items():
            if isinstance(traffic_profiles, str):
                traffic_profiles = [traffic_profiles]
            for traffic_profile in traffic_profiles:
                scenario.add_ue_group_to_traffic_profile(ue_group, self.traffic_profiles[traffic_profile])

    @logger
    def handle_scenario_configuration(self, scenario_name, scenario):
        scenario_identifier = self.reader_object.test_description[scenario_name].get("scenario_identifier")
        if scenario_identifier:
            scenario.scenario_modifications = \
                self.reader_object.scenario_configuration.get(scenario_identifier)
            scenario.collector_name = scenario_identifier
        else:
            logging.info("There is no scenario_configuration set for {0}".format(scenario_name))
            scenario.scenario_modifications = {}
            scenario.collector_name = "default_scenario"

    @logger
    def _get_traffic_profile_ue_group_mapping(self, scenario):
        return self.reader_object.test_description[scenario]["traffic_profiles"]

    @logger
    def get_list_of_scenario_names(self, test_tags):
        if not self.list_of_scenarios:
            self.populate_list_of_scenarios(test_tags)
        return self.list_of_scenarios

    @logger
    def populate_list_of_scenarios(self, test_tags):
        test_tags = set(test_tags)
        self.get_test_names_from_process()
        print(self.tests_called)
        if self.tests_called:
            logging.info("tests called with -t: %s", self.tests_called)
            formated_tests_called = [tc.strip().lower() for tc in self.tests_called]
            for scenario_name in list(sorted(self.reader_object.test_description.keys())):
                required_for_tests = self.reader_object.test_description[scenario_name].get("required_for_testcase")
                if required_for_tests:
                    for required_test in required_for_tests:
                        if required_test.strip().lower() in formated_tests_called:
                            self.list_of_scenarios.append(scenario_name)
        if not self.list_of_scenarios:
            for scenario_name in list(sorted(self.reader_object.test_description.keys())):
                scenario_tags = self.reader_object.test_description[scenario_name].get("tag")
                if scenario_tags:
                    scenario_tags = [scenario_tags] if isinstance(scenario_tags, str) else scenario_tags
                    scenario_tags = set(scenario_tags)
                    tags_to_execute = test_tags.intersection(scenario_tags)
                    if tags_to_execute:
                        self.list_of_scenarios.append(scenario_name)
                        logging.info("adding %s to test since it contains tag(s) %s", scenario_name, tags_to_execute)
        if not self.list_of_scenarios:
            logging.warning("could not find any scenarios matching test tags. Running all instead")
            self.list_of_scenarios = self.reader_object.test_description.keys()
        self.list_of_scenarios = sorted(self.list_of_scenarios)

    def get_required_tests_for_scenario(self, scenario_name):
        return self.reader_object.test_description[scenario_name].get("required_for_testcase")

    def get_tags_for_required_tests_for_scenario(self, scenario_name):
        return self.reader_object.test_description[scenario_name].get("tag")

    @logger
    def get_test_names_from_process(self):
        """checks the processes to get the tests from the robot command line argument.
        """
        if os.path.isfile(self.argfile_path):
            logging.info("found an argfile used in UTE-Cloud execution. Using contents to determine scenarios.")
            with open(self.argfile_path) as f:
                command_strings = f.read()
                logging.info("command_strings = %s" % command_strings)
            self.tests_called = re.findall(pattern=r"-t .*", string=command_strings)
            logging.info("self.tests_called = %s" % self.tests_called)
            self.tests_called = [test[3:] for test in self.tests_called]  # remove the -t from the strings.
        else:
            logging.info("found no argfile. Using process information instead.")
            processes = os.popen("ps ax | grep robot")
            command_strings = processes.read()
            logging.info("command_strings = %s" % command_strings)
            processes_list = command_strings.splitlines()
            cmdline_string = self.get_cmdline(processes_list)
            self.tests_called = re.findall(pattern=r"%s(.*?)%s" % ("-t#", "#"), string=cmdline_string)
        return self.tests_called

    @logger
    def get_cmdline(self, processes_list):
        cmdline_strings = ""
        process_id = None
        for process in processes_list:
            if "robot" in process and "-t" in process:
                process_id = process.split()[0]
                logging.info("process_id = %s" % process_id)
        if process_id:
            processes = os.popen("cat -v /proc/%s/cmdline" % process_id)
            cmdline_strings = processes.read().replace("^@", "#")
            logging.info("cmdline_strings = %s" % cmdline_strings)
        return cmdline_strings

    @logger
    def identify_required_cells(self):
        required_cells = []
        test_description = self.reader_object.test_description
        for scenario in test_description.keys():
            required_cells += test_description[scenario]['cells_ue_mapping'].keys()
        self.required_cells = sorted(list(set(required_cells)))
        return self.required_cells


class LogsTracesParser:
    def __init__(self, reader_object, is_classical):
        self.is_classical = is_classical
        self.reader_object = reader_object
        self._logs_and_traces_flags = {
            "TTITrace": {"collection": "False",
                         "start_point": "before_attach",
                         "stop_point": "after_detach",
                         "tti_filter": "Default",
                         "phy_cell_ids": False,
                         "stop_delay_sec": 0,
                         "conversion": {
                             "excelCsv": "False",
                             "filtered_json": "False",
                             "pickled_df": "False",
                             "ReaderEvtDec": "False",
                             "ReaderEvtDec_event_nr_max": 30000}},
            "BIPTrace": {
                "L1L2BIPTrace": "False",
                "AP_L1L2BIPTrace": "False",
                "start_point": "before_attach",
                "stop_point": "after_detach",
                "stop_delay_sec": 0
            },
            "BackhaulTrace": {
                "BHTrace": "False",
                "start_point": "during_traffic",
                "stop_point": "after_traffic",
                "bh_filter": "sctp",
                "conversion": {
                    "pdml": "False",
                    "filtered_pdml": ""}
            },
            "DCAP": {
                "collection": "False",
                "custom_profile": [],
                "start_point": "before_attach",
                "stop_point": "after_detach"
            },
            "Syscom_L2_L3_Trace": "False",
            "AP_SOSLogs": "False",
            "X2Trace": "False",
            "BTS_Snapshot": "False",
            "IMS_Snapshot": "False",
            "CellSetup_Syslogs": "False",
            "CellSetup_AP_Syslogs": "False",
            "Syslogs": "False",
            "WtsLogs": "False",
            "CellSetupL2_L3Trace": "False",
            "CellSetup_BH": "False"}
        self._extra_options = {
            "restore_scf": "False"
        }
        self._tti_trace_start = None

    @property
    def logs_and_traces_flags(self):
        # if self.is_classical:
        self._update_traces_and_flags()
        self._update_extra_options()
        self._update_tti_trace_start()
        self.adjust_tti_and_bip_trace_delays_for_template()
        return self._logs_and_traces_flags

    def adjust_tti_and_bip_trace_delays_for_template(self):
        """Adjusts the user specified tti-Trace and BIP Trace Delays for use in the Framework.
        The BIP trace delay cant be longer than the TTI-Trace Delay.
        If the TTI-Trace delay is longer than the BIP Trace delay,
        the delays will be calculated for the stop command to run after each other with this Formulas:

        bip_delay = bip_delay
        tti_delay = tti_delay - bip delay

        In the robot execution the Order of execution shall be as follows:
        {{BIP-Trace Stop begins}}
        {{sleep for BIP Trace delay}}
        {{Stop BIP Traces}}
        {{TTI-Trace Stop begins}}
        {{sleep for TTI Trace delay}}
        {{Stop TTI Traces}}
        """
        if self._logs_and_traces_flags["BIPTrace"]["stop_point"] == \
                self._logs_and_traces_flags["TTITrace"]["stop_point"]:
            bip_delay = self._logs_and_traces_flags["BIPTrace"]["stop_delay_sec"]
            tti_delay = self._logs_and_traces_flags["TTITrace"]["stop_delay_sec"]
            if bip_delay > tti_delay:
                logging.warning("BIP Trace stop delay value defined in the config file is longer than defined stop"
                                " delay for TTI Trace. This behaviour is currently not supported. "
                                "The stop delay defined for the BIP Trace will also be used for the TTI Trace Stop. "
                                "The TTI Trace collection will be delayed by %s s", bip_delay)
                tti_delay = 0
            else:
                tti_delay = tti_delay - bip_delay
                logging.info("Since TTI Trace and BIP Trace stop locations are the same: "
                             "The stop delays for the TTI Trace and BIP Trace are as calculated as follows -> "
                             "delaying %s s before BIP Trace and %s s before TTI Trace.", bip_delay, tti_delay)
            self._logs_and_traces_flags["BIPTrace"]["stop_delay_sec"] = bip_delay
            self._logs_and_traces_flags["TTITrace"]["stop_delay_sec"] = tti_delay
            logging.info("adjusted tti-delay: %s", tti_delay)
            logging.info("adjusted bip-delay: %s", bip_delay)

    @property
    def extra_options(self):
        return self._extra_options

    @property
    def tti_trace_start(self):
        return self._logs_and_traces_flags["TTITrace"].get("start_point")

    @property
    def tti_trace_stop(self):
        return self._logs_and_traces_flags["TTITrace"].get("stop_point")

    @property
    def tti_trace_stop_delay(self):
        return self._logs_and_traces_flags["TTITrace"].get("stop_delay_sec")

    @property
    def bip_trace_start(self):
        return self._logs_and_traces_flags["BIPTrace"].get("start_point")

    @property
    def bip_trace_stop(self):
        return self._logs_and_traces_flags["BIPTrace"].get("stop_point")

    @property
    def bip_trace_stop_delay(self):
        return self._logs_and_traces_flags["BIPTrace"].get("stop_delay_sec")

    @property
    def dcap_trace_start(self):
        return self._logs_and_traces_flags["DCAP"].get("start_point")

    @property
    def dcap_trace_stop(self):
        return self._logs_and_traces_flags["DCAP"].get("stop_point")

    @property
    def backhaul_trace_start(self):
        return self._logs_and_traces_flags["BackhaulTrace"].get("start_point")

    @property
    def backhaul_trace_stop(self):
        return self._logs_and_traces_flags["BackhaulTrace"].get("stop_point")

    @logger
    def _update_traces_and_flags(self):
        for key in self._logs_and_traces_flags:
            if key in self.reader_object.logs_and_traces.keys():
                if key == "TTITrace":
                    for item in self.reader_object.logs_and_traces[key]:
                        if type(self.reader_object.logs_and_traces[key][item]) is dict:
                            self._logs_and_traces_flags[key][item].\
                                update(self.reader_object.logs_and_traces[key][item])
                        else:
                            self._logs_and_traces_flags[key][item] = self.reader_object.logs_and_traces[key][item]
                elif key == "BackhaulTrace":
                    for item in self.reader_object.logs_and_traces[key]:
                        if type(self.reader_object.logs_and_traces[key][item]) is dict:
                            self._logs_and_traces_flags[key][item].\
                                update(self.reader_object.logs_and_traces[key][item])
                        else:
                            self._logs_and_traces_flags[key][item] = self.reader_object.logs_and_traces[key][item]
                elif key == "BIPTrace" or key == "DCAP":
                    self._logs_and_traces_flags[key].update(self.reader_object.logs_and_traces[key])
                else:
                    self._logs_and_traces_flags[key] = self.reader_object.logs_and_traces[key]
            else:
                pass

    @logger
    def _update_tti_trace_start(self):
        valid_input = ["before_attach", "after_attach", "during_traffic", "after_traffic"]
        defined_tti_trace_start = self._logs_and_traces_flags["TTITrace"].get("start_point")
        if defined_tti_trace_start not in valid_input:
            logging.warning("The given TTI-Trace Start: '%s' is not valid, "
                            "using 'before_attach' as start point", defined_tti_trace_start)
            self._logs_and_traces_flags["TTITrace"]["start_point"] = "before_attach"

    @logger
    def handle_extra_options_flag(self, option_present, valid_input=["True", "False"]):
        for key, value in self._extra_options.items():
            if value not in valid_input or not option_present:
                self._extra_options[key] = "False"
                logging.warning("{0} in 'extra_options' not defined or is "
                                "invalid. Default value 'False' will be used".format(key))

    @logger
    def _update_extra_options(self):
        try:
            self._extra_options.update(self.reader_object.extra_options.items())
            self.handle_extra_options_flag(option_present=True)
        except Exception as e:
            self.handle_extra_options_flag(option_present=False)
