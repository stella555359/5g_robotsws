import json
import collections

from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.logger import logger, logging
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.ScfChanges import ScfChanges
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.helper_functions import to_bool, unpack_list_of_lists


class Scenario:
    def __init__(self, name, is_classical):
        self.name = name
        self._collector_name = None
        self._with_pm_counters = True
        self._pm_counter_start_before_L3 = False
        self.cells = {}
        self.csi_report_profiles = {}
        self.scenario_modifications = {}
        self.traffic_profiles_mapping = collections.defaultdict(list)
        self.traffic_profiles = {}
        self._special_keywords = []
        self.ue_groups = []
        self.attach_dict = {'auto_attach': {'nsa': {}, 'sa': {}},
                            'not_auto_attach': {'nsa': {}, 'sa': {}},
                            'generation_complete': False}
        self.num_ues_per_cell_in_scenario = {}
        self.traffic_commands = []
        self.ue_group_csi_mapping = {}
        self.is_classical = is_classical
        self.ue_id_rnti_mapping = {}
        self.ue_id_rnti_lte_mapping = {}

    @property
    def with_pm_counters(self):
        return self._with_pm_counters

    @property
    def pm_counter_start_before_L3(self):
        return self._pm_counter_start_before_L3

    @property
    def special_keywords(self):
        return self._special_keywords

    @property
    def filter_bitmaps(self):
        return self._filter_bitmaps

    @property
    def collector_name(self):
        return self._collector_name

    @filter_bitmaps.setter
    def filter_bitmaps(self, filter_bitmaps):
        if not filter_bitmaps:
            logging.info(
                'filter_bitmaps was not found for %s, using the default filters', self.name)
            self._filter_bitmaps = ["0xFFFFFFFF", "0xFFFFFFFF"]
        else:
            self._filter_bitmaps = filter_bitmaps

    @with_pm_counters.setter
    def with_pm_counters(self, is_activated):
        if not is_activated:
            logging.warning(
                'with_pm_counters is not set for %s, using default (True)', self.name)
            self._with_pm_counters = True
        else:
            self._with_pm_counters = to_bool(is_activated)
        if self._pm_counter_start_before_L3:
            logging.warning("You are using the delayed pm counter start, this may cause problem in longer"
                            " Tests and is EXPERIMENTAL")
            self._with_pm_counters = False

    @pm_counter_start_before_L3.setter
    def pm_counter_start_before_L3(self, delayed_start):
        logging.info('given_value: %s', delayed_start)
        self._pm_counter_start_before_L3 = bool(
            to_bool(delayed_start)) if delayed_start is not None else False
        logging.info('saved_value: %s', self._pm_counter_start_before_L3)

    @special_keywords.setter
    def special_keywords(self, special_keywords):
        if special_keywords:
            self._special_keywords = special_keywords
        else:
            logging.info(
                'special Keywords were not found for %s', self.name)

    @collector_name.setter
    def collector_name(self, scenario_identifier):
        self._collector_name = self.name + '_' + scenario_identifier

    @logger
    def _populate_num_ues_per_cell(self, ue_group_obj):
        if ue_group_obj.cell not in self.num_ues_per_cell_in_scenario:
            self.num_ues_per_cell_in_scenario[ue_group_obj.cell] = len(
                ue_group_obj.get_list_of_configured_ue_ids())
        else:
            self.num_ues_per_cell_in_scenario[ue_group_obj.cell] += len(
                ue_group_obj.get_list_of_configured_ue_ids())

    @logger
    def add_ue_groups_to_scenario(self, ue_group_cell_mapping, ue_group_objects):
        ue_group_list = unpack_list_of_lists([cell['ue_groups'] for cell in ue_group_cell_mapping])
        relevant_ue_group_objects = []
        for ue_group_name_in_json in ue_group_list:
            relevant_ue_group_objects.extend([
                ue_group for ue_group in ue_group_objects if str(ue_group) == ue_group_name_in_json])
        for ue_group in relevant_ue_group_objects:
            self.ue_groups.append(ue_group)
            self._populate_num_ues_per_cell(ue_group)

    @logger
    def add_ue_group_to_traffic_profile(self, ue_group, traffic_profile):
        ue_group_obj = next((obj for obj in self.ue_groups if obj.group_name == ue_group), None)
        if not ue_group_obj:
            logging.error('the given ue_group is not associated to this scenario. '
                          'scenario_name: %s, ue_group_name: %s', self.name, ue_group)
            return None
        self.traffic_profiles_mapping[traffic_profile].append(ue_group_obj)

    def get_csi_report_profile_dict(self):
        report_profile_dict = {}
        for index, ue_group in enumerate(self.ue_groups):
            if ue_group.group_name not in self.ue_group_csi_mapping.keys():
                continue
            ue_ids_formatted = ",".join(
                [str(ue) for ue in ue_group.get_list_of_configured_ue_ids()])
            try:
                cqi_params = self.csi_report_profiles[self.ue_group_csi_mapping[str(
                    ue_group)]]
            except KeyError as e:
                logging.error(
                    "the csi_report_profile %s is not configured. check json", e)
                return {}
            report_profile_dict.update({str(ue_group): {"profile_id": index+2,
                                                        "cqi_params": cqi_params,
                                                        "ue_ids":  ue_ids_formatted,
                                                        "scell": 5 if ue_group.nsa_ues else 0}})
        if self.ue_group_csi_mapping.get("auto_activate") == "False":
            self.ue_group_csi_mapping["auto_activate"] = "True"
            return report_profile_dict, False
        return report_profile_dict, True

    @logger
    def get_ue_attach_list(self, connection_type='all', with_auto_attach=False):
        if not self.attach_dict['generation_complete']:
            self.generate_ue_attach_list()
        return self.get_params_for_ue_attach(connection_type, with_auto_attach)

    def get_params_for_ue_attach(self, connection_type, auto_attach):
        auto_attach_list_key = 'auto_attach' if auto_attach else 'not_auto_attach'
        if connection_type == 'all':
            return {'nsa': self.attach_dict[auto_attach_list_key]['nsa'],
                    'sa': self.attach_dict[auto_attach_list_key]['sa']}
        if connection_type == 'nsa':
            return self.attach_dict[auto_attach_list_key]['nsa']
        if connection_type == 'sa':
            return self.attach_dict[auto_attach_list_key]['sa']
        logging.error("Invalid UE Type chosen")

    def generate_ue_attach_list(self):
        for ue_group in self.ue_groups:
            auto_attach, not_auto_attach = ue_group.get_configuration_parameters()
            self.attach_dict['auto_attach'][ue_group.connection_type].update(auto_attach)
            self.attach_dict['not_auto_attach'][ue_group.connection_type].update(not_auto_attach)
        self.attach_dict['generation_complete'] = True

    def _find_unique_values(self, bearer_stats, key):
        bearer_stats[key] = ",".join((sorted(list(set(bearer_stats[key])))))

    def extract_bearer_stat_params(self):
        bearer_stats_nsa = {'ues': [], 'trf_ids': [], 'bearers': []}
        bearer_stats_sa = {'ues': [], 'trf_ids': [], 'qfis': [], 'pdus': []}
        for traffic_command in self.traffic_commands:
            if 'qfi' in traffic_command.keys() and traffic_command.get('qfi') != 3:
                bearer_stats_sa['qfis'].append(str(traffic_command['qfi']))
                bearer_stats_sa['pdus'].append(str(traffic_command['pdu']))
                bearer_stats_sa['ues'].append(traffic_command['ue_id'])
                bearer_stats_sa['trf_ids'].append(
                    str(traffic_command['trf_id']))
            elif 'qfi' in traffic_command.keys() and traffic_command['qfi'] == 3:
                pass
            else:
                bearer_stats_nsa['ues'].append(traffic_command['ue_id'])
                bearer_stats_nsa['bearers'].append(str(traffic_command['id']))
                bearer_stats_nsa['trf_ids'].append(
                    str(traffic_command['trf_id']))
        self._find_unique_values(bearer_stats_nsa, 'ues')
        self._find_unique_values(bearer_stats_nsa, 'bearers')
        self._find_unique_values(bearer_stats_nsa, 'trf_ids')
        self._find_unique_values(bearer_stats_sa, 'ues')
        self._find_unique_values(bearer_stats_sa, 'qfis')
        self._find_unique_values(bearer_stats_sa, 'pdus')
        self._find_unique_values(bearer_stats_sa, 'trf_ids')
        return [bearer_stats_nsa, bearer_stats_sa]

    def get_commissioned_object_list(self, scf_content):
        scf_changes = ScfChanges(scf_content)
        for scf_change in self.scenario_modifications.values():
            scf_changes.add_change(scf_change)
        modifications = scf_changes.get_modifications_for_commissioning(self.is_classical)
        if self.is_classical:
            modifications = sorted(modifications, key=lambda d: d['distName'])
        return modifications

    @logger
    def get_traffic_commands(self):
        if not self.traffic_commands:
            max_trf_id_used = 1
            for traffic_profile, associated_ues in self.traffic_profiles_mapping.items():
                max_trf_id_used = self.generate_traffic_params_for_each_ue(
                    self.traffic_commands, traffic_profile,
                    associated_ues,
                    max_trf_id_used)
        return self.traffic_commands

    @logger
    def get_bearer_stat_parameters(self):
        return self.extract_bearer_stat_params()

    @logger
    def get_bearer_pdu_details(self, ue_group, default_traffic_params):
        if ue_group.pdu:
            qfi = default_traffic_params.pop('qfi')
            return {'pdu': ue_group.pdu, 'qfi': qfi}
        if ue_group.bearer:
            return {'id': ue_group.bearer}

    @logger
    def remove_qfi_for_nsa_traffic(self, traffic_param):
        if 'id' in traffic_param.keys():
            traffic_param.pop('qfi')

    @logger
    def generate_traffic_params_for_each_ue(self, traffic_commands,
                                            traffic_profile, associated_ue_groups,
                                            max_trf_id_used):
        for ue_group in associated_ue_groups:
            ue_ids = ue_group.get_comma_separated_ue_ids()
            for default_traffic_param in traffic_profile.get_traffic_parameters(max_trf_id_used):
                traffic_parms = {}
                traffic_parms.update(ue_group.all_ues[0].get_bearer_pdu_details(default_traffic_param))
                """default traffic params are appended to traffic params because pdu is expected before qfi
                this helps to maintain the desired order of the parameters"""
                default_traffic_param.update({'ue_id': ue_ids})
                traffic_parms.update(default_traffic_param)
                self.remove_qfi_for_nsa_traffic(traffic_parms)
                traffic_commands.append(traffic_parms)
        return traffic_profile.max_traffic_id_used

    @logger
    def get_max_traffic_length(self):
        try:
            return max([traffic_profile.traffic_duration for traffic_profile in self.traffic_profiles_mapping.keys()])
        except ValueError:
            logging.warning("The traffic length could not be determined. "
                            "Maybe you did not configure a traffic profile for %s "
                            "returning a traffic length of 0 (seconds)", self.name)
            return 0

    @logger
    def get_max_num_of_ues(self):
        num_ues_sa = 0
        num_ues_nsa = 0
        for ue_group in self.ue_groups:
            num_ues_nsa += len(ue_group.configured_nsa_ues)
            num_ues_sa += len(ue_group.configured_sa_ues)
        return num_ues_nsa, num_ues_sa

    @logger
    def save_rnti_for_ue_id(self, rnti, ue_id):
        self.ue_id_rnti_mapping.update({ue_id: rnti})

    @logger
    def save_rnti_lte_for_ue_id(self, rnti_lte, ue_id):
        self.ue_id_rnti_lte_mapping.update({ue_id: rnti_lte})

    @logger
    def get_rntis_for_ue_group(self, ue_group_name):
        if not ue_group_name:
            return self.ue_id_rnti_mapping
        ue_group = [ue_group for ue_group in self.ue_groups if ue_group.group_name == ue_group_name][0]
        ue_ids = [ue.id for ue in ue_group.all_ues]
        ues_in_group = {ue_id: self.ue_id_rnti_mapping[ue_id]
                        for ue_id in ue_ids if ue_id in self.ue_id_rnti_mapping}
        return ues_in_group

    @logger
    def get_rntis_lte_for_ue_group(self, ue_group_name):
        if not ue_group_name:
            return self.ue_id_rnti_mapping
        ue_group = [ue_group for ue_group in self.ue_groups if ue_group.group_name == ue_group_name][0]
        ue_ids = [ue.id for ue in ue_group.all_ues]
        ues_in_group = {ue_id: self.ue_id_rnti_lte_mapping[ue_id]
                        for ue_id in ue_ids if ue_id in self.ue_id_rnti_lte_mapping}
        return ues_in_group

    @logger
    def get_ue_ids_configured_for_scenario(self):
        ue_ids_configured_for_scenario = []
        for ue_group in self.ue_groups:
            [ue_ids_configured_for_scenario.append(
                ue_ids) for ue_ids in ue_group.get_list_of_configured_ue_ids()]
        return ue_ids_configured_for_scenario

    def get_expected_throughput_per_cell(self):
        average_cell_throughput = {}
        for ue_group in self.ue_groups:
            average_cell_throughput.update({ue_group.cell: {'dl': 0, 'ul': 0}})
        for traffic_profile, ue_groups in self.traffic_profiles_mapping.items():
            for ue_group in ue_groups:
                num_ues = len(ue_group.all_ues)
                cell = ue_group.cell
                time_factor = self.get_traffic_time_factor(traffic_profile.traffic_duration)
                for direction, throughput in traffic_profile.get_traffic_dict().items():
                    average_cell_throughput[cell][direction] += throughput * num_ues * time_factor
        return average_cell_throughput

    def get_traffic_time_factor(self, traffic_duration):
        return traffic_duration / self.get_max_traffic_length()

    def get_expected_throughput_per_ue(self):
        """returns the expected udp throughput for each ue in the scenario.
        ! Warning ! Currently only returns the udp throughput and is not corrected for the total
        Traffic duration.

        Returns:
            dict: dictionary containing ue_id and tp stats: {'<ue_id>': {'ul': <ul_tp>, 'dl': '<dl_tp>'}}
            values are in mbps.
        """
        throughput_per_ue = {}
        for ue_group in self.ue_groups:
            for ue in ue_group.all_ues:
                throughput_per_ue.update({ue.id: {'ul': 0, 'dl': 0}})
        for traffic_profile, ue_groups in self.traffic_profiles_mapping.items():
            ues_for_traffic_profile = [ue_group.all_ues for ue_group in ue_groups]
            all_ue_ids = [ue.id for ue in unpack_list_of_lists(ues_for_traffic_profile)]
            traffic = traffic_profile.get_traffic_dict()
            for ue in all_ue_ids:
                throughput_per_ue[ue]['ul'] += traffic['ul']
                throughput_per_ue[ue]['dl'] += traffic['dl']
        return throughput_per_ue
