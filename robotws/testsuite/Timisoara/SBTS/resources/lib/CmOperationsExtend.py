#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Author:li ya nan

from future.utils import raise_with_traceback, iteritems
from lxml import etree
from taf.nms.netact.cm_operations import CmOperations
from taf.nms.netact.facade import Netact
import string


class CmOperationsExtend(CmOperations):

    def __init__(self, dist_name=None, hostname=None, username=None, password=None):
        self.dist_name = dist_name
        self.hostname = hostname
        self.username = username
        self.password = password

    def check_actual_configuration_parameters(self, dist_name, hostname,
                                              username, password, ui_values=True, **expected_values):
        """

        Checks if given parameters have expected values in actual configuration.

        :param string dist_name: distName of element
        :param bool ui_values: Specifies if the file should be exported with UI parameters' values.
        :param expected_values: Parameters with expected values (parameter name should be given as argument name,
                                                                expected value should be given as argument value).
        """
        netact = Netact()
        netact.add_node('cmwas', hostname, username, password)
        cmwas_node = netact.get_node('cmwas')
        local_dir = '/tmp/'
        with cmwas_node:
            netact.upload_configuration(dist_names=dist_name)
            source = netact.export_configuration('ta_check-actual.xml', local_dir='/tmp/', dist_names=dist_name,
                                                 ui_values=ui_values)
            print(type(source))
            print(source)
            xml = self._convert_plan_to_xml('/tmp/ta_check-actual.xml')
            # xml = '/tmp/ta_check-actual.xml'
            print('XML:%s' % xml)
            try:
                mo_element = xml.xpath(".//managedObject[@distName='{}']".format(dist_name))[0]
            except IndexError:
                raise ElementNotFound('Managed object "{}" not found in actual configuration. Actual configuration:\n'
                                      '{}'.format(dist_name, source))
            for name, expected_value in iteritems(expected_values):
                if isinstance(expected_value, (dict, list)):
                    self._check_list(mo_element, source, name, expected_value)
                else:
                    self._check_parameter_value(mo_element,
                                                source, name, expected_value, 'managed object "{}"'.format(dist_name))
            netact.delete_node('cmwas')
            netact.clean_all()

    def _check_list(self, element, source, list_name, expected_values):
        try:
            list_element = element.xpath(".//list[@name='{}']".format(list_name))[0]
        except IndexError:
            raise ElementNotFound('List "{}" not found in actual configuration. Actual configuration:\n'
                                  '{}'.format(list_name, source))
        if isinstance(expected_values, dict):
            self._check_items_parameters_values(list_element, source, list_name, expected_values)
        elif isinstance(expected_values, list):
            self._check_list_parameters_values(list_element, source, list_name, expected_values)

    @staticmethod
    def _check_list_parameters_values(list_element, source, list_name, expected_values):
        parameters = list_element.xpath(".//p/text()")
        for expected_value in expected_values:
            if expected_value not in parameters:
                raise AssertionError('Expected value "{}" not found in list "{}" in actual configuration. '
                                     'Actual configuration:\n{}'
                                     .format(expected_value, list_name, source))

    def _check_items_parameters_values(self, list_element, source, list_name, expected_values):
        items = list_element.xpath(".//item")
        if items is None:
            raise ElementNotFound('List "{}" does not have any items in actual configuration.\n'
                                  'If it contains parameters directly (not inside the <item> tag), '
                                  'the expected values should be given as a list - not as a dictionary.\n'
                                  'Actual configuration:\n{}'.format(list_name, source))
        for item in items:
            try:
                for parameter_name, expected_value in iteritems(expected_values):
                    self._check_parameter_value(item, source, parameter_name,
                                                expected_value, 'list "{}"'.format(list_name))
            except AssertionError:
                pass
            else:
                return
        raise AssertionError('No item with expected values "{}" found in list "{}" in actual configuration. '
                             'Actual configuration:\n{}'
                             .format(expected_values, list_name, source))

    @staticmethod
    def _check_parameter_value(element, source, parameter_name, expected_value, element_description):
        try:
            actual_value = element.xpath(".//p[@name='{}']".format(parameter_name))[0].text
#            print('actual_value:%s'% actual_value)
        except IndexError:
            raise ElementNotFound('Parameter "{}" not found in {} in actual configuration. Actual configuration:\n{}'
                                  .format(parameter_name, element_description, source))
        else:
            if actual_value != expected_value:
                raise AssertionError('Actual value {} for parameter "{}" in {} does not match with expected value {}. '
                                     'Actual configuration:\n{}'.format(
                                                                        actual_value, parameter_name,
                                                                        element_description, expected_value, source))

    @staticmethod
    def _convert_plan_to_xml(sourcepath):
        with open(sourcepath) as f:
            xml_content = f.read()
            print(type(xml_content))
            xml_str = xml_content.replace('xmlns="raml20.xsd"', '')
            xml_str = xml_str.encode()
        return etree.fromstring(xml_str)


class CmError(Exception):
    pass


class ElementNotFound(CmError):
    pass
