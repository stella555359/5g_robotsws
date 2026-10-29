# -*- coding: utf-8 -*-
"""
Author: Grzegorz Kaczor
"""
import logging
import re
import time
from dateutil import tz
from datetime import datetime
from functools import wraps
from inspect import getcallargs
from taf.rfrl.bts.devices.asir.dist_name_patterns import AsirDistNamePatterns
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.exceptions import ValidationError, AsirConnectionNotPossible
from taf.sbts.oam.sc.rest.exception import AuthenticationFailed


def _get_bts_id_arg_name(passed_args):
    if 'gnb_id' in passed_args:
        return 'gnb_id'
    elif 'enb_id' in passed_args:
        return 'enb_id'
    elif 'bts_id' in passed_args:
        return 'bts_id'
    else:
        raise ValueError("One of parameter [gnb_id, enb_id, bts_id] is required")


def login_logout_custom(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        refresh_token_threshold = 240
        passed_args = getcallargs(web_fun, self, *args, **kwargs)
        bts_id_arg_name = _get_bts_id_arg_name(passed_args=passed_args.keys())
        passed_args[bts_id_arg_name] = int(passed_args[bts_id_arg_name])
        self._connection_alias = self.rest_alias.format(passed_args[bts_id_arg_name])
        if "asir_connection_alias" in passed_args.keys():
            self._connection_alias += "_{}".format(passed_args["asir_connection_alias"])
        kw_timeout = passed_args.get('timeout')
        if kw_timeout and int(kw_timeout) > 100:
            refresh_token_threshold = 120
        self.connect(bts_id=passed_args[bts_id_arg_name], refresh_token_threshold=refresh_token_threshold)
        try:
            result = web_fun(**passed_args)
        except Exception as e:
            raise e
        finally:
            self.disconnect(bts_id=passed_args[bts_id_arg_name])
        return result

    return wrapper


class GnbAsir(GnbAsirHubOperations):

    def __init__(self):
        super(GnbAsir, self).__init__()
        self.antennas = []
        self.hubs = []

    def set_antenna_ids(self):
        self.antennas = self.get_all_antenna_ids()
        if not self.antennas:
            raise SystemError("No antennas found")

    def set_hub_ids(self):
        self.hubs = self.get_all_hub_ids()
        if not self.hubs:
            raise SystemError("No hubs found")

    def reset_all_antennas(self):
        if not self.antennas:
            self.set_antenna_ids()
        for antenna in self.antennas:
            self.reset_antenna(ant_id=antenna, timeout=300)

    def block_all_antennas(self):
        if not self.antennas:
            self.set_antenna_ids()
        for antenna in self.antennas:
            self.block_antenna(ant_id=antenna)

    def unblock_all_antennas(self):
        if not self.antennas:
            self.set_antenna_ids()
        for antenna in self.antennas:
            self.unblock_antenna(ant_id=antenna)

    def verify_all_antennas_status(self):
        expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                             'hardwareState': 'working', 'softwareState': 'detected'}
        if not self.antennas:
            self.set_antenna_ids()
        self.verify_antmod_status(ant_ids=self.antennas, expected_statuses=expected_statuses)

    def verify_all_antennas_are_blocked(self):
        expected_statuses = {'operationalState': 'disabled', 'commissioned': 'Yes', 'localState': 'blocked',
                             'hardwareState': 'working', 'softwareState': 'detected'}
        if not self.antennas:
            self.set_antenna_ids()
        self.verify_antmod_status(ant_ids=self.antennas, expected_statuses=expected_statuses)

    def reset_all_hubs(self):
        if not self.hubs:
            self.set_hub_ids()
        for hub in self.hubs:
            self.reset_hub(hub_id=hub)

    def verify_all_hubs_status(self):
        expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                             'hardwareState': 'working', 'softwareState': 'configured',
                             'activeStatusLEDColor': 'Green',
                             'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
        if not self.hubs:
            self.set_hub_ids()
        self.verify_hubmod_status(hub_ids=self.hubs, expected_statuses=expected_statuses)

    def get_all_cells_info_multi_operation(self, bts_id=0):
        """
        Checking the following parameters of all active cells: cell id, dist_name, uid

        :return list:  cells identification info. Example return value:
        [{'id': 1, 'dn': 'ASI-1/ASI_R-1/BTS_R-1/CELL_R-1', 'uid': '22'}]
        """
        _re_id = re.compile(r'(?P<ID>\d+)$')
        _re_dist_name = re.compile(AsirDistNamePatterns.re_cells_dist_name.format(r'\d+'))
        active_dist_names = self._perform_asir_operation(self.asir.get_active_dist_names)

        all_cells = []
        for record in active_dist_names:
            if _re_dist_name.search(record['dn']):
                cell_id = int(_re_id.search(record['dn']).group('ID'))
                all_cells.append({'id': cell_id, "dn": record['dn'], "uid": record["uid"]})

        return all_cells

    @login_logout_custom
    def get_all_antenna_ids(self, bts_id=0):
        _re_id = re.compile(r'(?P<ID>\d+)$')
        dist_names = self._get_all_dist_names(AsirDistNamePatterns.re_antmod_dist_name.format(r'\d+'))
        antenna_ids = []
        for dn in dist_names:
            match = _re_id.search(dn)
            if match:
                antenna_ids.append(match.group('ID'))

        return antenna_ids

    @login_logout_custom
    def get_all_hub_ids(self, bts_id=0):
        _re_id = re.compile(r'(?P<ID>\d+)$')
        dist_names = self._get_all_dist_names(AsirDistNamePatterns.re_hubmod_dist_name.format(r'\d+'))
        hub_ids = []
        for dn in dist_names:
            match = _re_id.search(dn)
            if match:
                hub_ids.append(match.group('ID'))

        return hub_ids

    @login_logout_custom
    def reset_antenna(self, bts_id=0, ant_id=1, timeout=4 * 60):
        self._reset_unit(bts_id=bts_id, unit_id=ant_id, unit_type='antenna', timeout=timeout)

    @login_logout_custom
    def block_antenna(self, bts_id=0, ant_id=1, timeout=4 * 60):
        self._block_unit(unit_id=ant_id, unit_type='antenna', timeout=timeout)

    @login_logout_custom
    def unblock_antenna(self, bts_id=0, ant_id=1, timeout=4 * 60):
        self._unblock_unit(unit_id=ant_id, unit_type='antenna', timeout=timeout)

    @login_logout_custom
    def get_unit_logical_info(self, uid, bts_id=0):
        return self._perform_asir_operation(self.asir.get_unit_logical_info, uid)

    @login_logout_custom
    def verify_hubmod_status(self, hub_ids=[1], expected_statuses=None, bts_id=0):
        hub_ids_str = [str(hub_id) for hub_id in hub_ids]
        hub_dist_names = self._get_all_dist_names_and_uids(AsirDistNamePatterns.re_hubmod_dist_name.
                                                           format(r'({})'.format('|'.join(hub_ids_str))))
        logging.debug("Checking status for DIST_NAMES: {}".format(hub_dist_names))
        expected_statuses = {status.lower(): expected_statuses[status].lower() for status in expected_statuses.keys()}
        for record in hub_dist_names:
            hub_id = self._get_id_from_dist_name(record['dn'])
            statuses = self._get_states_from_logical_info(self.get_unit_logical_info(uid=record['uid'], bts_id=bts_id))
            logging.info("Expected HUBMOD Statuses {} ".format(expected_statuses))
            logging.info("Current HUBMOD Statuses {}".format(statuses))
            self._compare_unit_statuses(statuses, hub_id, expected_statuses)

    @login_logout_custom
    def perform_asir_commissioning(self, scf_path, migrate_nidd=True, bts_id=0, timeout=180):
        staged_plans_info = self._get_staged_plans(bts_id=bts_id)
        staged_delta_plans = self._get_staged_delta_plans(bts_id=bts_id)
        if staged_plans_info:
            self._delete_staged_plan(plan_id=staged_plans_info[0]["id"], bts_id=bts_id)
        if staged_delta_plans:
            self._delete_delta_plan(delta_plan_id=staged_delta_plans[0]["eid"], bts_id=bts_id)
        if migrate_nidd:
            delta_plan_id = self._create_new_delta_plan(source_plan="none", bts_id=bts_id)["eid"]
            nidd_info = self._upload_plan_template(delta_plan_id=delta_plan_id, scf_path=scf_path, bts_id=bts_id)
            if nidd_info["migration_needed"]:
                actual_nidd = nidd_info["version"]["adaptation_versions"][0]["version"]
                supported_nidd = nidd_info["supported_versions"][0]["release_version"]
                scf_path = self._convert_scf_file_to_supported_nidd(scf_path=scf_path, actual_nidd=actual_nidd,
                                                                    supported_nidd=supported_nidd)
        plan_id = self._upload_plan(scf_path=scf_path, bts_id=bts_id)["id"]
        self._activate_plan(plan_id=plan_id, timeout=timeout, bts_id=bts_id)

    @login_logout_custom
    def verify_antmod_status(self, ant_ids=[1], expected_statuses=None, bts_id=0):
        ant_ids_str = [str(ant_id) for ant_id in ant_ids]
        ant_dist_names = self._get_all_dist_names_and_uids(AsirDistNamePatterns.re_antmod_dist_name.
                                                           format(r'({})'.format('|'.join(ant_ids_str))))
        logging.debug("Checking status for DIST_NAMES: {}".format(ant_dist_names))
        expected_statuses = {status.lower(): expected_statuses[status].lower() for status in expected_statuses.keys()}
        for record in ant_dist_names:
            ant_id = self._get_id_from_dist_name(record['dn'])
            logging.info("Checking status for antenna: {}".format(ant_id))
            statuses = self._get_states_from_logical_info(self.get_unit_logical_info(uid=record['uid'], bts_id=bts_id))
            logging.info("Expected AntMod Statuses {} ".format(expected_statuses))
            logging.info("Current AntMod Statuses {}".format(statuses))
            self._compare_unit_statuses(statuses, ant_id, expected_statuses)
            logging.info("Status for antenna: {} is as expected".format(ant_id))

    def _refresh_token(self):
        try:
            super()._refresh_token()
        except AuthenticationFailed:
            self._connect()

    def _perform_asir_operation(self, rest_api_method, *args, **kwargs):
        try:
            return super()._perform_asir_operation(rest_api_method, *args, **kwargs)
        except AsirConnectionNotPossible:
            return super()._perform_asir_operation(rest_api_method, *args, **kwargs)

    @login_logout_custom
    def check_asir_active_alarm(self, allowed_fault_id_list=None, forbidden_fault_id_list=None,
                                required_fault_id_list=None, bts_id=0):
        active_alarm_list = self._perform_asir_operation(self.asir.get_active_alarms)
        logging.debug("Active alarms: {}".format(active_alarm_list))
        active_alarm_id_list = [str(alarm['fault_id']) for alarm in active_alarm_list]
        logging.debug("Processed active alarms ID's: {}".format(active_alarm_id_list))

        verify_dict = self.verify_faults(active_alarm_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                         required_fault_id_list)

        if not verify_dict['check_result']:
            raise ValidationError("ASIR active alarm check result: {}".format(verify_dict))

    @login_logout_custom
    def check_asir_history_alarm(self, appeared_time_later_than, allowed_fault_id_list=None,
                                 forbidden_fault_id_list=None, required_fault_id_list=None, bts_id=0):
        historic_alarm_list = self._perform_asir_operation(self.asir.get_cleared_alarms)
        logging.debug("Active alarms: {}".format(historic_alarm_list))
        cleared_alarm_list = [elem for elem in historic_alarm_list if elem.get("fault_state") == "cleared"]
        logging.debug("Processed historic alarms after selecting only cleared alarms: {}".format(cleared_alarm_list))
        delta_alarm_list = [elem for elem in cleared_alarm_list
                            if self.convert_utc_to_local_timezone(elem.get("time_started")) >= appeared_time_later_than]
        logging.debug("Processed historic alarms after selecting only alarms started after {} alarms: {}".format(
            appeared_time_later_than, cleared_alarm_list))
        historic_alarm_id_list = [str(alarm['fault_id']) for alarm in delta_alarm_list]
        logging.debug("Processed historic alarms ID's: {}".format(historic_alarm_id_list))

        verify_dict = self.verify_faults(historic_alarm_id_list, forbidden_fault_id_list, allowed_fault_id_list,
                                         required_fault_id_list)

        if not verify_dict['check_result']:
            raise ValidationError("ASIR active alarm check result: {}".format(verify_dict))

    @staticmethod
    def verify_faults(all_fault_id_list, forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list):
        result_dict = {'all_fault_id_list': all_fault_id_list}
        all_fault_id_set = set(all_fault_id_list)
        prefixes = ['forbidden', 'allowed', 'required']
        result_dict['check_result'] = True

        if allowed_fault_id_list:
            allowed_fault_id_list = (allowed_fault_id_list if type(allowed_fault_id_list) is list
                                     else str(allowed_fault_id_list).split()) + \
                                    (required_fault_id_list if type(required_fault_id_list) is list
                                     else str(required_fault_id_list).split())

        for i, v in enumerate([forbidden_fault_id_list, allowed_fault_id_list, required_fault_id_list]):
            if v is not None:
                v = v if type(v) is list else str(v).split()
                set_v = set(v)
                if prefixes[i] == 'forbidden':
                    result_dict[prefixes[i] + '_failures'] = list(all_fault_id_set.intersection(set_v))
                elif prefixes[i] == 'allowed':
                    result_dict[prefixes[i] + '_failures'] = list(all_fault_id_set - set_v)
                elif prefixes[i] == 'required':
                    result_dict[prefixes[i] + '_failures'] = list(set_v - all_fault_id_set)

                if result_dict[prefixes[i] + '_failures']:
                    result_dict['check_result'] = False
        return result_dict

    @staticmethod
    def _extract_cell_pmax_from_info(info):
        if not info:
            raise AttributeError("Given info is empty")
        paragraphs_list = info["paragraphs"]
        for paragraph in paragraphs_list:
            paragraph_element = paragraph.get("paragraphs")
            for nested_paragraph in paragraph_element:
                element_title = nested_paragraph.get("title")
                if element_title == "Maximum output power":
                    return float(nested_paragraph.get("text").split(" ")[0])
        raise AttributeError("Maximum output power not found in given info: {}".format(info))

    @staticmethod
    def _get_cell_id(cell_dist_name):
        cell_section = cell_dist_name.split("/")[-1]
        return cell_section.split("-")[-1]

    @staticmethod
    def _get_cell_uid(cell_id, asir_cell_info):
        for cell in asir_cell_info:
            if cell_id == cell.get("id"):
                return cell.get("uid")
        raise AttributeError("Cell {} not found in given data: {}".format(cell_id, asir_cell_info))

    @staticmethod
    def convert_utc_to_local_timezone(utc_time):
        from_zone = tz.tzutc()
        to_zone = tz.tzlocal()
        utc = datetime.strptime(utc_time, "%Y-%m-%dT%H:%M:%SUTC")
        utc = utc.replace(tzinfo=from_zone)
        central = utc.astimezone(to_zone)
        return time.mktime(central.timetuple())
