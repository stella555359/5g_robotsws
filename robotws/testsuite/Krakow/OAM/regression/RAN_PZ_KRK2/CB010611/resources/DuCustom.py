# -*- coding: utf-8 -*-
"""
Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
"""
import xml.etree.ElementTree as ET
import logging
from datetime import datetime
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.generic_bts import login_logout_GUI


class GnbDuCustom(GnbDuOperations):

    def __init__(self):
        super(GnbDuCustom, self).__init__()

    @login_logout_GUI
    def check_if_parameter_is_set_to_correct_value(self, dist_name, parameter, param_abbr, value, node_index=0,
                                                   bts_id=0, du_id=0,):

        current_value = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter,
                                                             param_abbr=param_abbr, bts_id=bts_id, du_id=du_id)
        logging.debug('Current value is: {}'.format(current_value))

        if '%' in current_value:
            current_value = current_value.split()[0]
        if current_value == value:

            logging.debug('Parameter {} is set to correct value: {}'.format(parameter, value))
        else:
            self.verify_if_parameter_changed_to_correct_value_via_gui(dist_name=dist_name, parameter=parameter,
                                                                      value=value, node_index=node_index, bts_id=bts_id,
                                                                      du_id=du_id, timeout=120)
            logging.debug('Parameter {} was changed to {} value'.format(parameter, value))

    @login_logout_GUI
    def verify_lbpsSOffTrRule_value(self, dist_name, parameter, param_abbr, bts_id=0, du_id=0,):

        current_value = self.get_gnb_parameter_value_via_gui(dist_name=dist_name, param_name=parameter,
                                                             param_abbr=param_abbr, bts_id=bts_id, du_id=du_id)
        return current_value

    def verify_lbps_parameters_and_set_to_predefined_value(self, class_name, list_name, gnb_scf_path=None):
        is_recomissioning_needed = []
        date = datetime.now()
        parameters_to_change = {'lbpsDayOfWeek': date.strftime('%a'), 'lbpsDuration': '120',
                                'lbpsStartTimeHour': date.strftime('%H'), 'lbpsStartTimeMinute': date.strftime('%M'),
                                'lbpsSuspended': 'suspended'}

        if gnb_scf_path is None:
            gnb_scf_path = self.get_bts_configuration_file()

        tree = ET.parse(gnb_scf_path)
        root = tree.getroot()

        for object in root.findall('.//*[@class="{}"]'.format(class_name)):
            param_list = object.find('.*[@name="{}"]'.format(list_name))

            for parameter, value in parameters_to_change.items():
                is_recomissioning_needed.append(self._verify_and_change_xml_value(param_list, parameter, value))

        namespace = 'raml21.xsd'

        for i in range(0, len(list(root))):
            ET.register_namespace("", namespace)

        tree.write(gnb_scf_path, xml_declaration=True, method='xml', encoding="utf8", default_namespace=None)

        if True in is_recomissioning_needed:
            logging.debug('Recommissioning needed')
            return True
        else:
            logging.debug('Recommissioning not needed')
            return False

    def _verify_and_change_xml_value(self, param_list, parameter_name, value):
        for parameter in param_list[0].findall('.*[@name="{}"]'.format(parameter_name)):

            if parameter.text == value:
                logging.debug('Parameter {} is set to correct value {}'.format(parameter_name, value))
                return False
            else:
                logging.debug(
                    'Parameter {} has incorrect value {}, value is corrected to {}'.format(parameter_name,
                                                                                           parameter.text, value))
                parameter.text = value
                return True
