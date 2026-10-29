# -*- coding: utf-8 -*-
"""
Author: Slawomir Szopinski, slawomir.szopinski@nokia.com
"""
import logging
import os
import xml.etree.ElementTree as ET
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.exceptions import AsirOperationFailed


class GnbAsirCustom(GnbAsirHubOperations):

    def __init__(self):
        super(GnbAsirCustom, self).__init__()

    def download_asir_scf(self, asir_scf_path=None):
        asir_scf_path = self.get_current_scf_file("/tmp/", "temp_asir_scf.xml")
        return asir_scf_path

    def delete_backup_asir_scf(self, asir_scf_path):
        os.remove(asir_scf_path)

    def verify_scfc_parameters_and_set_to_value(self, class_name, param_name, expected_value, asir_scf_path=None):
        is_recomissioning_needed = False
        if asir_scf_path is None:
            asir_scf_path = self.get_current_scf_file("/tmp/", "temp_asir_scf.xml")

        tree = ET.parse(asir_scf_path)
        root = tree.getroot()

        for object in root.findall('.//*[@class="{}"]'.format(class_name)):
            if len(object.findall('.*[@name="{}"]'.format(param_name))) == 0:
                logging.debug('There is no {} parameter'.format(param_name))
                ET.SubElement(object, 'p', attrib={'name': param_name}).text = expected_value
                is_recomissioning_needed = True
            else:
                parameter = object.find('.*[@name="{}"]'.format(param_name))
                if parameter.text != expected_value:
                    logging.debug('There is {} parameter with incorrect value {}, expected value {}'.format(
                        param_name, parameter.text, expected_value))
                    parameter.text = expected_value
                    is_recomissioning_needed = True
                else:
                    logging.debug('Parameter {} has correct value'.format(param_name))

        namespace = 'raml21.xsd'
        for i in range(0, len(list(root))):
            ET.register_namespace("", namespace)
        tree.write(asir_scf_path, xml_declaration=True, method='xml', encoding="utf8", default_namespace=None)

        return is_recomissioning_needed

    def _refresh_token(self):
        try:
            super()._refresh_token()
        except AsirOperationFailed as e:
            logging.debug('Operation failed: {}'.format(str(e)))
            if '(401)' in str(e):
                self._connect()
            else:
                raise e

    def _perform_asir_operation(self, rest_api_method, *args, **kwargs):
        try:
            return super()._perform_asir_operation(rest_api_method, *args, **kwargs)
        except AsirOperationFailed as e:
            logging.debug('Operation failed: {}'.format(str(e)))
            if '(401)' in str(e):
                self._refresh_token()
                return super()._perform_asir_operation(rest_api_method, *args, **kwargs)
            else:
                raise e
