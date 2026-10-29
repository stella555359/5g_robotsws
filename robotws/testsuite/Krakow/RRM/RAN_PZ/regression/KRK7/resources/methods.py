"""
GNB methods for HO

:copyright: Nokia Networks
:author: Wioleta Swies
:contact: wioleta.swies@nokia.com
"""
import copy
import json
import time
from functools import wraps

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn

from taf.internal.sbts.admin.exceptions import (AdminApiConnectionClosedException,
                                                AdminApiProcedureFailureException,
                                                AdminApiProcedureTimeoutException)
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.sbts.oam.coam.admin import admin
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue


def admin_connect(web_fun):
    @wraps(web_fun)
    def wrapper(self, *args, **kwargs):
        try:
            self.connect()
            result = web_fun(self, *args, **kwargs)
            return result
        finally:
            self.disconnect()

    return wrapper


class GnbWeb:
    def __init__(self, ip=None, username=None, password=None, mrbts_id=None):
        self.tl = BuiltIn().get_variable_value("${{{}}}".format("tl"), None)
        self.ip = ip if ip else self.tl.gnbs[0].cu.backhaul_site_oam_ip.v4.split("/")[0]
        self.username = username if username else self.tl.gnbs[0].cu.oam_http_connection_details.username
        self.password = password if password else self.tl.gnbs[0].cu.oam_http_connection_details.password
        self.mrbts_id = mrbts_id if mrbts_id else self.tl.gnbs[0].instance_id
        self.admin = admin()
        self._already_connected = False

    def connect(self):
        if self._already_connected:
            return
        logger.debug('Connect to {} ...'.format(self.ip, self.username, self.password))
        self.admin.connect_to(bts_host=self.ip,
                              username=self.username,
                              password=self.password)

        self._already_connected = True

    def disconnect(self):
        if not self._already_connected:
            return
        self.admin.teardown_admin()
        self._already_connected = False

    @staticmethod
    def get_testline_configuration_from_robot_command(self):
        return BuiltIn().get_variable_value("${{{}}}".format("tl"), None)

    @admin_connect
    def get_parameters(self, dist_name, pattern=None, parameter=None):
        if parameter:
            param = self.admin.get_parameters(dist_name=dist_name)
            return param[parameter]
        elif pattern:
            param = self.admin.get_parameters(dist_name=dist_name, pattern=pattern)
            return param[pattern]
        else:
            return self.admin.get_parameters(dist_name=dist_name)

    @admin_connect
    def get_managed_objects(self, class_name, cell_id=None, parameter=None, timeout=30):
        output = self.admin.get_managed_objects(class_name=class_name, timeout=timeout)
        if cell_id:
            for nr in output:
                if str(cell_id) in nr['distName']:
                    logger.debug(nr['parameters'][parameter])
                    return nr['parameters'][parameter] if parameter else output
        return output[0]['parameters'][parameter] if parameter else output

    @admin_connect
    def get_cells_info(self):
        output = self.admin.get_managed_objects(class_name="NRCELL_A", timeout=30)
        return output

    @admin_connect
    def prepare_dist_name_for_nr_cell(self, internal=None, cell_id=None):
        bts_info = self.admin.get_bts_info()
        cells_distname = bts_info['cells']['nr']
        if cell_id:
            for nr in cells_distname:
                if str(cell_id) in nr['id']['internal']:
                    return nr['id']['internal']
        if internal:
            return bts_info['cells']['nr'][0]['id']['internal']
        return bts_info['cells']['nr'][0]['id']['configuration']

    @staticmethod
    def prepare_distname_basing_on_configured_distname(distname, mode='A'):
        """
        Parses distname returned from taf.sbts.coam.oam.admin.Admin.get_managed_object_method

        :param str distname
        :param str mode: supported two types:
                - A: NIDD-based operator configuration (ending _A)
                - R: NIDD-based runtime BTS representation (ending: _R)
        """
        if mode not in ['A', 'R']:
            raise Exception(f"Unsupported mode '{mode}'! Currently supported modes are 'A' and 'R'.")

        distname_elements = distname.split('/')

        mode_specific_distname_elem_delimiter = {
            'A': "SCF-",
            'R': "RUNTIME_VIEW-",
        }

        beginning_index = 0
        for i, elem in enumerate(distname_elements):
            if mode_specific_distname_elem_delimiter[mode] in elem:
                beginning_index = i
                break

        distname_elements = distname_elements[beginning_index + 1:]
        for i, elem in enumerate(distname_elements):
            elem_with_mode = elem.split('_')
            elem_id = elem_with_mode[1].split('-')[-1]
            parsed_elem = elem_with_mode[0] + '-' + elem_id
            distname_elements[i] = parsed_elem
        return '/'.join(distname_elements)

    @admin_connect
    def get_commissioning_distanmes_by_managed_class(self, managed_class):
        mode = 'A'  # only configuration (not runtime) NIDD objects can be properly used for recommissioning
        managed_objects = self.admin.get_managed_objects(class_name=f"{managed_class}_{mode}")
        raw_distnames = [managed_object['distName'] for managed_object in managed_objects]
        parsed_distnames = [self.prepare_distname_basing_on_configured_distname(distname, mode)
                            for distname in raw_distnames]
        return parsed_distnames

    @admin_connect
    def get_current_value_of_commisoning_parameter(self, distname, parameter):
        nidd_class_with_id = distname.split('/')[-1]
        nidd_class, nidd_id = nidd_class_with_id.split('-')
        nidd_class += "_A"
        managed_objects = self.admin.get_managed_objects(class_name=str(nidd_class), timeout=30)
        logger.debug(f"The managed_objects of NIDD Class {nidd_class} are: {managed_objects}")
        desired_current_object = None
        for managed_object in managed_objects:
            if managed_object['distName'].split('/')[-1].split('-')[-1] == nidd_id:
                desired_current_object = managed_object
                break
        logger.debug(f"get_current_value_of_commisoning_parameter has found desired_object: {desired_current_object}")
        return desired_current_object['parameters'][parameter]

    @admin_connect
    def perform_parameter_recommissioning_with_parameter_value_check(self,
                                                                     dist_name,
                                                                     parameter,
                                                                     operation,
                                                                     value,
                                                                     skip_parameter_relation_errors=True,
                                                                     should_activate=True):
        current_parameter_value = self.get_current_value_of_commisoning_parameter(distname=dist_name,
                                                                                  parameter=parameter)
        logger.debug(f"Checking value of parameter {parameter} at {dist_name}")
        logger.debug(f"Current value: {current_parameter_value, type(current_parameter_value)}")
        logger.debug(f"Desired value: {value, type(value)}")
        if str(current_parameter_value) == str(value):
            logger.debug(f"Current value of {dist_name}:{parameter} is {current_parameter_value}, same as desired."
                         f" Aborting operation")
            return
        self.perform_parameter_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            value=value,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate,
        )

    def prepare_dist_name_for_nr_hoif(self, nrhoif_id, cell_id):
        nr_hoif = 'NRHOIF-{}'.format(str(nrhoif_id))
        dist_name = 'MRBTS-{0}/NRBTS-{0}/NRCELL-{1}/{2}'.format(self.mrbts_id, cell_id, nr_hoif)
        logger.info('NRHOIF distname {}'.format(dist_name))
        return dist_name

    @admin_connect
    def perform_object_recommissioning(self,
                                       dist_name,
                                       parameter,
                                       operation,
                                       skip_parameter_relation_errors=True,
                                       should_activate=True):
        status = self.admin.perform_object_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate)
        self.check_commissioning_results(status)

    @admin_connect
    def perform_parameter_recommissioning(self,
                                          dist_name,
                                          parameter,
                                          operation,
                                          value,
                                          skip_parameter_relation_errors=True,
                                          should_activate=True):
        self.admin.perform_parameter_recommissioning(
            dist_name=dist_name,
            parameter=parameter,
            operation=operation,
            value=value,
            skip_parameter_relation_errors=skip_parameter_relation_errors,
            should_activate=should_activate,
        )

    @admin_connect
    def perform_delta_recommissioning(self,
                                      delta_file,
                                      skip_parameter_relation_errors=True,
                                      should_activate=True,
                                      timeout=300):
        delta_file = json.dumps(delta_file)
        self.admin.perform_delta_recommissioning(delta_file=delta_file,
                                                 skip_parameter_relation_errors=skip_parameter_relation_errors,
                                                 should_activate=should_activate,
                                                 timeout=timeout)

    @admin_connect
    def save_site_commissioning_file(self, path, file_name):
        self.admin.get_current_scf_file(local_dir_path=path, file_name=file_name, export_type="configuration")

    @staticmethod
    def check_commissioning_results(result):
        nidd_result = result["validationResult"]["niddValidationResult"]["status"]
        status = result["commissioningResult"]["activationResult"]["resultNode"][
            "parameters"
        ]["result"]
        if nidd_result != "OK" and status != "Success":
            raise Exception(
                "Recommission failed. Result {}, {}".format(nidd_result, status)
            )

    @staticmethod
    def prepare_parameters(param_name, value, operation='update'):
        parameter = [{
            "parameterName": param_name,
            "operation": operation,
            "value": value}]
        logger.info('Param: {}'.format(parameter))
        return parameter

    def parse_nrhoif_distname(self, nrhoif_distname_from_get_managed_objects):
        """
        Distnames of NRHOIF_A get from admin().get_managed_objects are improper in use for commisioning.
        """
        nidd = nrhoif_distname_from_get_managed_objects.split('/')
        nrcell_id = nidd[-2].split('-')[1]
        nrhoif_id = nidd[-1].split('-')[1]
        return "MRBTS-{}/NRBTS-{}/NRCELL-{}/NRHOIF-{}".format(self.mrbts_id, self.mrbts_id, nrcell_id, nrhoif_id)

    def get_all_nrhoif_distname_list(self):
        all_nrhoifs = self.get_managed_objects(class_name='NRHOIF_A')
        all_nrhoifs_get_managed_objects_distnames = [nr['distName'] for nr in all_nrhoifs]
        all_nrhoifs_distnames = []
        for nrhoif in all_nrhoifs_get_managed_objects_distnames:
            all_nrhoifs_distnames.append(self.parse_nrhoif_distname(nrhoif))
        logger.debug(all_nrhoifs_distnames)
        return all_nrhoifs_distnames

    @staticmethod
    def filter_distname_by_id_of_nidd_class(distnames, nidd_class, id):
        filtered_distnames = []
        for distname in distnames:
            distname_path = distname.split('/')
            for nidd in distname_path:
                if nidd_class in nidd and id in nidd.split('-')[-1]:
                    filtered_distnames.append(distname)
                    break
        return filtered_distnames

    def get_all_nrhoif_distname_list_filtered_by_nrcell(self, nrcell_id):
        all_nrhoifs = self.get_managed_objects(class_name='NRHOIF_A')
        all_nrhoifs_get_managed_objects_distnames = [nr['distName'] for nr in all_nrhoifs]
        all_nrhoifs_distnames = []
        for nrhoif in all_nrhoifs_get_managed_objects_distnames:
            all_nrhoifs_distnames.append(self.parse_nrhoif_distname(nrhoif))
        filtered_nrhoif_distnames = self.filter_distname_by_id_of_nidd_class(distnames=all_nrhoifs_distnames,
                                                                             nidd_class="NRCELL",
                                                                             id=nrcell_id)
        return filtered_nrhoif_distnames

    def toggle_event_on_nrhoifs(self, nrhoifs_distnames, event, enabled):
        if event not in ['A3', 'A4', 'A5']:
            raise Exception('Event should equal A3, A4 or A5, but {} given!'.format(event))

        desired_parameter_of_event = {
            'A3': 'a3MeasEnabled',
            'A4': 'a4MeasHigherPrioFreqEnabled',
            'A5': 'a5MeasEnabled',
        }

        desired_value = {
            True: 'rsrp',
            False: 'none',
        }

        for nrhoif in nrhoifs_distnames:
            logger.debug('\n\n{} {} {}'.format(nrhoif, desired_parameter_of_event[event], desired_value[enabled]))
            self.perform_parameter_recommissioning(dist_name=nrhoif,
                                                   parameter=desired_parameter_of_event[event],
                                                   operation="update",
                                                   value=desired_value[enabled])

    def get_all_nrhoif_configuration_list(self, mode='A'):
        supported_modes = ['A', 'R']

        if mode.upper() not in supported_modes:
            return Exception(f"The argument 'mode' of method get_all_nrhoif_configuration_list requires one of"
                             f" supported values: {supported_modes}, but {mode} was given!")

        nrhoif_class_name = "NRHOIF_" + mode

        all_nrhoifs = self.get_managed_objects(class_name=nrhoif_class_name)
        return all_nrhoifs

    def get_fr1_nrhoif_list(self, mode='A'):
        all_nrhoifs = self.get_all_nrhoif_configuration_list(mode=mode)
        fr1_band_indicators = [i for i in range(1, 105)]
        fr1_nrhoif_list = [nrhoif for nrhoif in all_nrhoifs if
                           nrhoif['parameters']['freqBandIndicatorNR'] in fr1_band_indicators]
        return fr1_nrhoif_list

    def get_fr2_nrhoif_list(self, mode='A'):
        all_nrhoifs = self.get_all_nrhoif_configuration_list(mode=mode)
        fr2_band_indicators = [i for i in range(257, 264)]
        fr2_nrhoif_list = [nrhoif for nrhoif in all_nrhoifs if
                           nrhoif['parameters']['freqBandIndicatorNR'] in fr2_band_indicators]
        return fr2_nrhoif_list

    def get_fr1_nrhoif_distname_list(self, mode='A'):
        fr1_nrhoif_list = self.get_fr1_nrhoif_list(mode=mode)
        fr1_nrhoif_distname_list = [self.parse_nrhoif_distname(nr['distName']) for nr in fr1_nrhoif_list]
        logger.debug(fr1_nrhoif_distname_list)
        return fr1_nrhoif_distname_list

    def get_fr2_nrhoif_distname_list(self, mode='A'):
        fr2_nrhoif_list = self.get_fr2_nrhoif_list(mode=mode)
        fr2_nrhoif_distname_list = [self.parse_nrhoif_distname(nr['distName']) for nr in fr2_nrhoif_list]
        return fr2_nrhoif_distname_list

    def toggle_event_a_on_desired_nrhoif(self, fr, event, enabled):
        if fr not in ['FR1', 'FR2']:
            raise Exception('Frequency Range should equal FR1 or FR2, but {} given!'.format(fr))

        if event not in ['A3', 'A4', 'A5']:
            raise Exception('Event should equal A3, A4 or A5, but {} given!'.format(event))

        if type(enabled) != bool:
            raise Exception('Enabled argument type should bool, but {} given!'.format(type(enabled)))

        dist_names_of_desired_nrhoifs = self.get_fr1_nrhoif_distname_list() if fr == 'FR1' else \
            self.get_fr2_nrhoif_distname_list()

        desired_parameter_of_event = {
            'A3': 'a3MeasEnabled',
            'A4': 'a4MeasHigherPrioFreqEnabled',
            'A5': 'a5MeasEnabled',
        }

        desired_value = {
            True: 'rsrp',
            False: 'none',
        }

        for nrhoif in dist_names_of_desired_nrhoifs:
            self.perform_parameter_recommissioning(dist_name=nrhoif,
                                                   parameter=desired_parameter_of_event[event],
                                                   operation="update",
                                                   value=desired_value[enabled])

    @staticmethod
    def generate_meas_enabled_parameters_for_delta_commissioning(dist_name, event_list):

        desired_parameter_of_event = {
            'A3': 'a3MeasEnabled',
            'A4': 'a4MeasHigherPrioFreqEnabled',
            'A5': 'a5MeasEnabled',
        }

        desired_value = {
            True: 'rsrp',
            False: 'none',
        }

        return {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": desired_parameter_of_event['A3'],
                    "value": desired_value[True] if 'A3' in event_list else desired_value[False],
                    "operation": "update"
                },
                {
                    "parameterName": desired_parameter_of_event['A4'],
                    "value": desired_value[True] if 'A4' in event_list else desired_value[False],
                    "operation": "update"
                },
                {
                    "parameterName": desired_parameter_of_event['A5'],
                    "value": desired_value[True] if 'A5' in event_list else desired_value[False],
                    "operation": "update"
                },
            ]
        }

    def toggle_events_a_on_desired_nrhoifs(self, mapping, filter_by_nrcell_id=None):
        """
        Toggle desired A events (A3/A4/A5) on all NRHOIF basing on their FR - FR1 or FR2
        args:
            mapping - dictionary describing mapping; the required keys are 'FR1' and 'FR2', values
            of each key are lists containing string ('A3', 'A4', 'A5') which determines type of events that should
            be turn on of all NRHOIFs of desired type.
        """

        full_delta_object = []
        dist_names_of_nrhoifs_fr1 = self.get_fr1_nrhoif_distname_list()
        if filter_by_nrcell_id:
            dist_names_of_nrhoifs_fr1 = self.filter_distname_by_id_of_nidd_class(distnames=dist_names_of_nrhoifs_fr1,
                                                                                 nidd_class="NRCELL",
                                                                                 id=filter_by_nrcell_id)

        for fr1_nrhoif in dist_names_of_nrhoifs_fr1:
            full_delta_object.append(
               self.generate_meas_enabled_parameters_for_delta_commissioning(dist_name=fr1_nrhoif,
                                                                             event_list=mapping['FR1'])
            )

        dist_names_of_nrhoifs_fr2 = self.get_fr2_nrhoif_distname_list()
        if filter_by_nrcell_id:
            dist_names_of_nrhoifs_fr2 = self.filter_distname_by_id_of_nidd_class(distnames=dist_names_of_nrhoifs_fr2,
                                                                                 nidd_class="NRCELL",
                                                                                 id=filter_by_nrcell_id)

        for fr2_nrhoif in dist_names_of_nrhoifs_fr2:
            full_delta_object.append(
               self.generate_meas_enabled_parameters_for_delta_commissioning(dist_name=fr2_nrhoif,
                                                                             event_list=mapping['FR2'])
            )
        self.perform_delta_recommissioning(delta_file=full_delta_object)

    def toggle_a2MeashoEnabled(self, enabled=True):
        parameter = 'a2MeashoEnabled'
        dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-1'.format(self.mrbts_id, self.mrbts_id)
        desired_value = {
            True: 'rsrp',
            False: 'none',
        }
        self.perform_parameter_recommissioning(dist_name=dist_name,
                                               parameter=parameter,
                                               operation="update",
                                               value=desired_value[enabled])

    def get_parameters_for_nrhoif(self, nrhoif_id, cell_id, parameter=None):
        nrhoif_name = 'NRHOIF_A-{}'.format(nrhoif_id)
        cell_name = 'NRCELL_A-{}'.format(cell_id)
        all_nrhoifs = self.get_managed_objects(class_name='NRHOIF_A')
        for nr in all_nrhoifs:
            if nrhoif_name in nr['distName'] and cell_name in nr['distName']:
                return nr['parameters'][parameter] if parameter else nr['parameters']
        raise Exception('Not found parameter')

    def prepare_distname_for_enb_endcmeasconf(self, carrier_freq):
        param = self.get_managed_objects(class_name='ENDCDMEASCONF_A')
        for nr in param:
            if int(carrier_freq) == nr['parameters']['carrierFreqNrCell']:
                dist_name_endc_meas_conf = nr['distName']
                logger.info(
                    'Dedicated distname for ENDCDMEASCONF based on carrier_freq {}'.format(dist_name_endc_meas_conf))
                return dist_name_endc_meas_conf

    def get_parameter_for_enb_endcmeas_conf(self, carrier_freq, parameter=None):
        distname = self.prepare_distname_for_enb_endcmeasconf(carrier_freq)
        endc_params = self.get_managed_objects(class_name='ENDCDMEASCONF_A')
        parameters = [nr['parameters'] for nr in endc_params if nr['distName'] == distname]
        return parameters[0][parameter] if parameter else parameters[0]

    def set_a4_periodic_meas_control_nsa(self,
                                         fr1_supervision_timer,
                                         fr2_supervision_timer,
                                         meas_max_number,
                                         retry_timer,
                                         cell_id):
        param = self.get_managed_objects(class_name='NRCELL_A',
                                         parameter='a4PeriodicMeasControlNSA',
                                         cell_id=cell_id)
        control_nsa_param = copy.deepcopy(param)
        if control_nsa_param['a4Fr1SupervisionTimer'] != int(fr1_supervision_timer):
            control_nsa_param['a4Fr1SupervisionTimer'] = int(fr1_supervision_timer)

        if control_nsa_param['a4Fr2SupervisionTimer'] != int(fr2_supervision_timer):
            control_nsa_param['a4Fr2SupervisionTimer'] = int(fr2_supervision_timer)

        if control_nsa_param['a4MeasMaxNumber'] != int(meas_max_number):
            control_nsa_param['a4MeasMaxNumber'] = int(meas_max_number)

        if control_nsa_param['a4RetryTimer'] != int(retry_timer):
            control_nsa_param['a4RetryTimer'] = int(retry_timer)

        if param != control_nsa_param:
            full_param = self.prepare_parameters(param_name='a4PeriodicMeasControlNSA', value=[control_nsa_param])
            dist_name = 'MRBTS-{0}/NRBTS-{0}/NRCELL-{1}'.format(self.mrbts_id, cell_id)
            logger.info('Value to update: {} distname {}'.format(control_nsa_param, dist_name))
            self.perform_object_recommissioning(dist_name=dist_name,
                                                parameter=full_param,
                                                operation='update')

    def set_a4_measurement_ssb_rsrp(self,
                                    hysteresis_rsrp,
                                    threshold_rsrp,
                                    time_to_trigger_rsrp,
                                    nrhoif_id,
                                    cell_id):
        param = self.get_parameters_for_nrhoif(parameter='a4MeasSsbRsrp', nrhoif_id=nrhoif_id, cell_id=cell_id)
        dict_parameters = copy.deepcopy(param)
        if dict_parameters['a4HysteresisSsbRsrp'] != int(hysteresis_rsrp):
            dict_parameters['a4HysteresisSsbRsrp'] = int(hysteresis_rsrp)

        if dict_parameters['a4ThresholdSsbRsrp'] != int(threshold_rsrp):
            dict_parameters['a4ThresholdSsbRsrp'] = int(threshold_rsrp)

        if dict_parameters['a4TimeToTriggerSsbRsrp'] != str(time_to_trigger_rsrp):
            dict_parameters['a4TimeToTriggerSsbRsrp'] = str(time_to_trigger_rsrp)

        if param != dict_parameters:
            full_param = self.prepare_parameters(param_name='a4MeasSsbRsrp', value=[dict_parameters])
            dist_name = self.prepare_dist_name_for_nr_hoif(nrhoif_id=nrhoif_id, cell_id=cell_id)
            logger.info('Value to update: {} distname: {}'.format(dict_parameters, dist_name))
            self.perform_object_recommissioning(dist_name=dist_name,
                                                parameter=full_param,
                                                operation='update')

    def prepare_delta_commisioning(self, result, operation):
        detla_list = []
        for param in result:
            for k, v in param.items():
                param = {
                    "distName": k,
                    "operation": operation,
                    "parameters": v,
                }
                detla_list.append(param)
        return detla_list

    def prepare_list_of_distname_value(self, result, param_name, cell_id):
        new_result = []
        dict_value = {}
        for value in result:
            distname = self.prepare_dist_name_for_nr_hoif(value[0], cell_id)
            parametrs = self.prepare_parameters(param_name=param_name, value=int(value[1]))
            dict_value.update({distname: parametrs})
            new_result.append(dict_value)
        logger.info('Prepare list {}'.format(new_result))
        return new_result

    def set_a4_higher_priority(self, nrhoif_id_prio_list, cell_id):
        """
        Sets priority for desired NRHOIF List
        List of parameters has structure: ['nrhoif_id', 'priority value']
        :param str distname
        :param str mode: supported two types:
                - A: NIDD-based operator configuration (ending _A)
                - R: NIDD-based runtime BTS representation (ending: _R)
        """
        output = self.prepare_list_of_distname_value(result=nrhoif_id_prio_list,
                                                     param_name='a4PriorityForHigherPrioFreqHo',
                                                     cell_id=cell_id)
        delta = self.prepare_delta_commisioning(output, operation='update')
        logger.info('Value to update: {}'.format(delta))
        self.perform_delta_recommissioning(delta)

    def set_a4_meas_higher_prio_freq_disabled(self, a4_prio_freq_enabled, nrhoif_id, cell_id):
        param = self.get_parameters_for_nrhoif(nrhoif_id=nrhoif_id, cell_id=cell_id)
        if a4_prio_freq_enabled != param['a4MeasHigherPrioFreqEnabled']:
            full_param = self.prepare_parameters(param_name='a4MeasHigherPrioFreqEnabled',
                                                 value=a4_prio_freq_enabled)

            dist_name = self.prepare_dist_name_for_nr_hoif(nrhoif_id=nrhoif_id, cell_id=cell_id)
            logger.debug('Value to update: {} distname {}'.format(full_param, dist_name))
            self.perform_object_recommissioning(dist_name=dist_name,
                                                parameter=full_param,
                                                operation='update')

    def set_a4_meas_higher_prio_freq_max_react(self, max_react, cell_id):
        param = self.get_managed_objects(class_name='NRCELL_A',
                                         parameter='a4MeasHigherPrioFreqMaxReact',
                                         cell_id=cell_id)

        if param != max_react:
            logger.info('Value to update: {}'.format(max_react))
            full_param = self.prepare_parameters(param_name='a4MeasHigherPrioFreqMaxReact', value=max_react)
            dist_name = 'MRBTS-{0}/NRBTS-{0}/NRCELL-{1}'.format(self.mrbts_id, cell_id)
            logger.debug(dist_name)
            self.perform_object_recommissioning(dist_name=dist_name,
                                                parameter=full_param,
                                                operation='update')

    def get_arfcn_ssb_pbch(self, cell_id):
        arfcn = self.get_managed_objects(class_name='NRCELL_R', cell_id=cell_id, parameter='arfcnSsbPbch')
        logger.info('Frequency: {}'.format(arfcn))
        return arfcn

    def get_physical_cell_identifier(self, cell_num):
        param = self.get_managed_objects(class_name='NRCELL_A')
        for nr in param:
            dist_name = '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-{0}/NRBTS_A-{0}/NRCELL_A-{1}'.format(
                self.mrbts_id, cell_num)
            if nr['distName'] == dist_name:
                parameter = nr['parameters']['physCellId']
                logger.info('PCI: {}'.format(parameter))
                return parameter
        raise Exception('Not found PCI')

    def get_ssb_frequency_and_rsrp(self, nrhoif_id, cell_id):
        param = self.get_parameters_for_nrhoif(nrhoif_id=nrhoif_id, cell_id=cell_id)
        freq = param['ssbFrequency']
        rsrp = param['a4MeasSsbRsrp']['a4ThresholdSsbRsrp']
        return [(str(freq), str(rsrp))]

    def get_ssb_frequency(self, nrhoif_id, cell_id):
        freq = self.get_parameters_for_nrhoif(parameter='ssbFrequency', nrhoif_id=nrhoif_id, cell_id=cell_id)
        return freq

    def get_target_pci_from_nr_adj_object(self, cell_num):
        param = self.get_managed_objects(class_name='NRADJNRCELL_A')
        for nr in param:
            dist_name = nr['distName'].split('/')[-1]
            if str(cell_num) in dist_name:
                pci = nr['parameters']['physCellId']
                logger.debug('Target PCI: {}'.format(pci))
                return pci
        raise Exception('Not found target PCI')

    def get_enb_b1_threshold_nr_rsrp(self, carrier_freq):
        return self.get_parameter_for_enb_endcmeas_conf(carrier_freq, parameter='b1ThresholdNrRsrp')

    def set_enb_b1_threshold_nr_rsrp(self, carrier_freq, b1_threshold_rsrp):
        param = self.get_parameter_for_enb_endcmeas_conf(carrier_freq, parameter='b1ThresholdNrRsrp')
        if param != int(b1_threshold_rsrp):
            b1_threshold_rsrp_value = int(b1_threshold_rsrp) + 156
            distname_endc = self.prepare_distname_for_enb_endcmeasconf(carrier_freq).split('/')[-1]
            endc_num = distname_endc.split('-')[-1]
            distname = 'MRBTS-{0}/LNBTS-{0}/NRDCDPR-0/ENDCDMEASCONF-{1}'.format(self.mrbts_id, endc_num)
            full_param = self.prepare_parameters(param_name='b1ThresholdNrRsrp', value=int(b1_threshold_rsrp_value))
            logger.info('Value to update: {}'.format(full_param))
            self.perform_object_recommissioning(dist_name=distname,
                                                parameter=full_param,
                                                operation='update')

    def set_treshold_ho_ssb_rsrp(self, event, value):
        event_paramter = {
            'A1': 'a1ThresholdhoSsbRsrp',
            'A2': 'a2ThresholdhoSsbRsrp',
        }
        parameter = event_paramter.get(event)

        if not parameter:
            raise ValueError('There is not a {} event to change ThresholdhoSsbRsrp'.format(event))

        min_value, max_value = 0, 127
        if not min_value <= int(value) <= max_value:
            logger.warn("Cannot set {} to {}!".format(parameter, value))

        dist_name = self.prepare_dist_name_for_nr_cell()
        self.perform_parameter_recommissioning(dist_name=dist_name,
                                               parameter=event_paramter[event],
                                               operation='update',
                                               value=value)

    def set_a1MeashoSsbRsrp(self,
                            a1HysteresishoSsbRsrp,
                            a1ThresholdhoSsbRsrp,
                            a1TimeToTriggerhoSsbRsrp,
                            nrcell="1"):

        dict_paramters = {
            "a1HysteresishoSsbRsrp":    a1HysteresishoSsbRsrp,
            "a1ThresholdhoSsbRsrp":     a1ThresholdhoSsbRsrp,
            "a1TimeToTriggerhoSsbRsrp": a1TimeToTriggerhoSsbRsrp,
        }

        full_param = self.prepare_parameters(param_name="a1MeashoSsbRsrp", value=[dict_paramters])
        dist_name = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(self.mrbts_id, self.mrbts_id, nrcell)

        self.perform_object_recommissioning(dist_name=dist_name, parameter=full_param, operation="update")

    def set_a1MeashoPrefNRLayerSsbRsrp(self, a1HysteresishoSsbRsrp, a1ThresholdhoSsbRsrp, a1TimeToTriggerhoSsbRsrp):

        dict_paramters = {
            "a1HysteresisSsbRsrp":      a1HysteresishoSsbRsrp,
            "a1ThresholdhoSsbRsrp":     a1ThresholdhoSsbRsrp,
            "a1TimeToTriggerhoSsbRsrp": a1TimeToTriggerhoSsbRsrp,
        }

        full_param = self.prepare_parameters(param_name="a1MeashoPrefNRLayerSsbRsrp", value=[dict_paramters])
        dist_name = "MRBTS-{}/NRBTS-{}/NRCELL-1".format(self.mrbts_id, self.mrbts_id)

        self.perform_object_recommissioning(dist_name=dist_name, parameter=full_param, operation="update")

    def set_a2MeashoSsbRsrp(self,
                            a2HysteresishoSsbRsrp,
                            a2ThresholdhoSsbRsrp,
                            a2TimeToTriggerhoSsbRsrp,
                            nrcell_id=1):

        dict_paramters = {
            "a2HysteresishoSsbRsrp":    a2HysteresishoSsbRsrp,
            "a2ThresholdhoSsbRsrp":     a2ThresholdhoSsbRsrp,
            "a2TimeToTriggerhoSsbRsrp": a2TimeToTriggerhoSsbRsrp,
        }

        full_param = self.prepare_parameters(param_name="a2MeashoSsbRsrp", value=[dict_paramters])
        dist_name = "MRBTS-{}/NRBTS-{}/NRCELL-{}".format(self.mrbts_id, self.mrbts_id, nrcell_id)
        self.perform_object_recommissioning(dist_name=dist_name, parameter=full_param, operation="update")

    def set_a1_meas_ho_pref_nr_layer_enabled(self, a1_enabled, cell_id):
        param = self.get_managed_objects(class_name='NRCELL_A',
                                         parameter='a1MeashoPrefNRLayerEnabled',
                                         cell_id=cell_id)
        if param != a1_enabled:
            dict_paramters = {
                "a1MeashoPrefNRLayerEnabled": a1_enabled,
            }
            full_param = self.prepare_parameters(param_name="a1MeashoSsbRsrp", value=[dict_paramters])
            dist_name = "MRBTS-{}/NRBTS-{}/NRCELL-1".format(self.mrbts_id, self.mrbts_id)

            self.perform_object_recommissioning(dist_name=dist_name, parameter=full_param, operation="update")

    def set_act_a1_ho_pref_nr_layer(self, actA1HoPrefNRLayer, cell_id):
        available_value = ['NSA', 'SA', 'SA+NSA']
        if actA1HoPrefNRLayer in available_value:
            param = self.get_managed_objects(class_name='NRBTS_A',
                                             parameter='actA1HoPrefNRLayer',
                                             cell_id=cell_id)
            logger.debug(param)
            if param != actA1HoPrefNRLayer:
                dist_name = "MRBTS-{}/NRBTS-{}".format(self.mrbts_id, self.mrbts_id)
                self.perform_parameter_recommissioning(dist_name=dist_name,
                                                       parameter='actA1HoPrefNRLayer',
                                                       operation="update",
                                                       value=actA1HoPrefNRLayer)
        raise IncorrectParameterValue('{} should be one of {}'.format(actA1HoPrefNRLayer, available_value))

    def get_report_interval_ho_nsa(self):
        param = self.get_managed_objects(class_name='NRCELL_A', parameter='reportIntervalHoPrefNRLayer')
        if param:
            logger.info('Report interval ho nas: {}'.format(param))
            return param
        raise Exception('Not found value')

    def get_report_amount_ho_nsa(self):
        param = self.get_managed_objects(class_name='NRCELL_A', parameter='reportAmountHoPrefNRLayer')
        if param:
            logger.info('Report amount ho nas: {}'.format(param))
            return param
        raise Exception('Not found value')

    @staticmethod
    def download_package(sw_version, target_dir):
        pkg_path = GnbSwUpdate().download_sw_package(sw_version=sw_version, target_dir=target_dir, by_nominal=True)
        logger.debug("Path to the download sw package: {}".format(pkg_path))
        return pkg_path

    @admin_connect
    def update_software(self, sw_package, timeout=3600):
        self.get_active_software()
        status = self.admin.update_software(sw_package=sw_package, should_activate=True, timeout=timeout)
        assert status == "Software update has been completed", f"Current status {status}"
        self.wait_for_synchronization(30)

    @admin_connect
    def verify_bts_in_state(self, state):
        bts_state = self.admin.get_mrbts_state()
        if bts_state != state:
            raise IncorrectParameterValue(
                "Bts is not in {} state. Current unexpected state is: {}".format(state, bts_state))
        else:
            logger.info("Bts is {} as expected.".format(state))

    def verify_bts_is_onair(self, state, timeout, interval):
        start_time = time.time()
        while time.time() < start_time + timeout:
            try:
                self.verify_bts_in_state(state=state)
                logger.debug("Bts is OnAir")
                break
            except IncorrectParameterValue:
                time.sleep(interval)
            except (AdminApiConnectionClosedException, AdminApiProcedureFailureException,
                    AdminApiProcedureTimeoutException):
                time.sleep(interval)
        else:
            raise Exception("Timeout passed. Bts status in not onAir")

    @admin_connect
    def perform_commissioning(self, scf_file, skip_parameter_relation_errors, should_activate, timeout):
        self.admin.perform_commissioning(scf_file=scf_file,
                                         skip_parameter_relation_errors=skip_parameter_relation_errors,
                                         should_activate=should_activate,
                                         timeout=timeout)

    @admin_connect
    def get_active_software(self):
        sw_info = self.admin.get_software_info()
        active_sw = sw_info["Active SW version"]
        if active_sw:
            logger.info('Active software pkg: {}'.format(active_sw))
            return active_sw
        raise Exception('Not found active software')

    @staticmethod
    def wait_for_synchronization(delay):
        time.sleep(delay)
