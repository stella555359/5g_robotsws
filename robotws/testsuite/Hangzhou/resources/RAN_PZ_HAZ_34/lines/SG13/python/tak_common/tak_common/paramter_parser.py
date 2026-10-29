# -*- coding: utf-8 -*-
"""
:created on: 05-12-2021
:copyright: Nokia
:author: leo wang
:contact: leo.y.wang@nokia-sbell.com
"""

import datetime
import os
import copy
import re
import lxml.etree as tree
from taf.config.scf import scf
from taf.gnb.oam.coam.admin import admin
import shutil


class DeltaParameterParser(object):
    """OAM commission parameter convert"""

    def __init__(self):
        self.coam = admin()
        self.scf_delta = scf()
        self.namespace = {'ns': 'raml21.xsd'}
        self.check_value = False
        self._scf_path = None
        self._dist_name = None

    @staticmethod
    def _get_root_dn(root_dn, dist_name=None):
        mrbts_root = root_dn['MRBTS']
        if dist_name in [None, mrbts_root]:
            return mrbts_root
        else:
            dn_root = mrbts_root
            dn_spl = str(dist_name).split('/')
            index_s = 0
            if 'MRBTS' in dist_name:
                index_s += 1
            if 'NRBTS' in dist_name:
                if root_dn['NRBTS'] is None:
                    dn_root += '/' + dn_spl[index_s]
                else:
                    dn_root += '/' + root_dn['NRBTS']
                index_s += 1
            if index_s != len(dn_spl):
                dn_root += '/' + '/'.join(dn_spl[index_s:len(dn_spl)])
            return dn_root

    def _is_parameter_list(self, dist_name, p_name):
        try:
            self.scf_delta.get_value_from_scf(dist_name=dist_name, p_name=p_name)
            return False
        except (Exception):
            return True

    def _get_delta_config(self, delta_operation, connection="cOAM", path=None):
        bts_root_dn = self._get_site_root_dist_name(connection=connection)
        delta_id = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
        if not path:
            path = os.getcwd()
        delta_file_name = os.path.join(path, '{}_{}_delta.json'.format(delta_operation, delta_id))
        self.coam.create_delta(delta_id=delta_id, connection=connection)
        return bts_root_dn, delta_id, delta_file_name

    @staticmethod
    def _check_condition(condition, description):
        if not condition:
            raise Exception(description)

    @staticmethod
    def _cond_str_value(str_a, str_b):
        """
        Check strings are matching or not
        :param str_a:
        :param str_b:
        :return: True or False
        """
        return str_a.lower() == str_b.lower()

    @staticmethod
    def _cond_set_value(set_a, set_b):
        """
        Check Set of a is subset of b
        :param set_a:
        :param set_b:
        :return: True or False
        """
        return set(set_a).issubset(set(set_b))

    def _get_param_value_from_scf(self, dist_name, p_name, p_value, p_index=0):
        if self.check_value:
            desc = 'Value should not empty for parameter[{}], if check_value is True'.format(p_name)
            self._check_condition(p_value, desc)
        if not self._is_parameter_list(dist_name, p_name):
            value = self.scf_delta.get_value_from_scf(dist_name=dist_name, p_name=p_name, index=p_index)
            value = value if value not in ['True', 'true', 'False', 'false'] else value.lower()
            if self.check_value:
                desc = 'Values are not matched[{},{}]'.format(p_value, value)
                condition = self._cond_str_value(value, p_value)
                self._check_condition(condition, desc)
            return value
        if isinstance(p_value, list):
            if isinstance(p_value[0], str):
                value = self.scf_delta.get_all_values_from_scf(dist_name=dist_name, list_name=p_name)
                if self.check_value:
                    desc = 'Values are not matched[{},{}]'.format(p_value, value)
                    condition = self._cond_set_value(p_value, value)
                    self._check_condition(condition, desc)
                return value
            else:
                for param_index, param in enumerate(p_value):
                    for ele_name, ele_value in param.items():
                        value = self.scf_delta.get_value_from_scf(dist_name=dist_name, p_name=ele_name,
                                                                  list_name=p_name, index=param_index)
                        value = value if value not in ['True', 'true', 'False', 'false'] else value.lower()
                        if self.check_value:
                            desc = 'Values are not matched[{},{}]'.format(ele_value, value)
                            condition = self._cond_str_value(value, ele_value)
                            self._check_condition(condition, desc)
                        p_value[param_index][ele_name] = value
                return p_value
        if p_value is None or not isinstance(p_value, list):
            value = self.scf_delta.get_all_values_from_scf(dist_name=dist_name, list_name=p_name)
            if self.check_value:
                desc = 'Values are not matched[{},{}]'.format(p_value, value)
                condition = self._cond_set_value(p_value, value)
                self._check_condition(condition, desc)
            return value

    def _append_list_param_items(self, parameters, bts_root_dn, connection="cOAM"):
        self._scf_path = self._get_current_scf_configuration_file(connection=connection)
        param_ret = copy.deepcopy(parameters)
        for _, param in enumerate(param_ret):
            self._dist_name = self._get_root_dn(bts_root_dn, param.get('dist_name'))
            if self._is_parameter_list(self._dist_name, param['parameter']) and isinstance(param.get('value'), list):
                items = tree.parse(self._scf_path).xpath("//ns:managedObject[@distName='{}']//ns:list[@name='{}']"
                                                         "//ns:item".format(self._dist_name, param['parameter']),
                                                         namespaces=self.namespace)
                if not items:
                    continue
                elements = {}
                for item_index, item in enumerate(items):
                    for element in item.iter():
                        if element.tag == '{' + self.namespace['ns'] + '}item':
                            continue
                        if elements.get(item_index) is None:
                            elements[item_index] = {element.attrib['name']: element.text}
                        else:
                            elements.get(item_index).update({element.attrib['name']: element.text})
                if elements:
                    for item_index, item_param in enumerate(param.get('value')):
                        for ele_name, ele_value in item_param.items():
                            elements.get(item_index).update({ele_name: ele_value})
                    param['value'] = elements.values()
        return param_ret

    def _get_site_root_dist_name(self, connection="cOAM"):
        """
        Get BTS Root Dist Name
        :param connection: AdminConnection object or if used, string name alias
        :return: Root Dist Name
        """
        bts_info = self.coam.get_bts_info(connection=connection)
        root_dist = {}
        if 'requestMessage' in bts_info:
            bts_info = bts_info['requestMessage']
        root_dist['MRBTS'] = bts_info['id']['configuration']
        try:
            root_dist['NRBTS'] = 'NRBTS-' + re.findall('/MRBTS-.*NRBTS_A-(.*)/',
                                                       bts_info['cellsGroup'][0]['id']['internal'])[0]
        except (KeyError, IndexError):
            root_dist['NRBTS'] = None

        return root_dist

    def _get_current_scf_configuration_file(self, connection="cOAM", config_type='configuration', path=None):
        """
        Get BTS Current BTS SCF file
        :param config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
        :param connection: AdminConnection object or if used, string name alias
        :return: Path to the file with current SCF content
        """
        if not path:
            path = os.getcwd()
        current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
        if config_type not in ['configuration', 'configurationAndRuntimeObjects', 'runtimeObjects']:
            raise Exception('Invalid config_type({}) type'.format(config_type))
        scf_file_path = os.path.join(path, 'scf_{}.xml'.format(current_time))
        self.coam.collect_scf(target_file_name=scf_file_path, export_type=config_type,
                              timeout=30, connection=connection)
        if not os.path.exists(scf_file_path):
            raise Exception('SCF file {} not exists'.format(scf_file_path))
        return scf_file_path

    def _get_list_values_from_scf_file(self, parameters, local_dir_path=None, connection="cOAM",
                                       config_type='configuration'):
        """
        Get values from SCF XML file
        :return: list of dicts with current values
        :param config_type: configuration, configurationAndRuntimeObjects or runtimeObjects
        :param local_dir_path: Current SCF XML file
        :param parameters: list of dicts
        examples:
            parameters = [ {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'gnbIdLength', 'value':'22'},
                           {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCgiPlmnId',
                            'value':[{'mcc':None,'mnc':None, "mncLength":'2'}]},
                           {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'nrCellId', 'value':'32765'},
                           {'dist_name': 'LNBTS-40/LNCEL-11/LNRELGNBCELL-0', 'parameter':'lteNrDualConnectAllowed',
                            value':'allowed'},
                           {'dist_name': 'MNL-1/MNLENT-2/SYNC-1/CLOCK-1/TOP-1/TOPP-1', 'parameter':'topMasterList',
                            value':[{'masterIpAddr':None}], p_index=1},
                         ]
        :param connection: AdminConnection object or if used, string name alias
        """
        if local_dir_path is None:
            local_dir_path = self._get_current_scf_configuration_file(connection=connection, config_type=config_type)
        self.scf_delta.load_scf(local_dir_path)
        bts_root_dn = self._get_site_root_dist_name(connection=connection)
        param_ret = copy.deepcopy(parameters)
        for index, param in enumerate(param_ret):
            dist_name = self._get_root_dn(bts_root_dn, param.get('dist_name'))
            param_ret[index]['value'] = self._get_param_value_from_scf(dist_name=dist_name,
                                                                       p_name=param['parameter'],
                                                                       p_value=param.get('value'),
                                                                       p_index=param.get('p_index', 0))
        return param_ret

    def _add_update_parameters_to_delta(self, parameters, delta_id, bts_root_dn=None, connection="cOAM"):
        """
        Append parameter update to delta
        :param parameters:list of dicts, examples are below.
            parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
                            {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList',
                            'value':[{'syncInputPrio':'1','syncInputType':'1pps/ToD from external GNSS receiver'}]},
                            {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
                            ]
        :param delta_id:  ID of delta JSON
        :param bts_root_dn: BTS root Dist name
        :param connection: AdminConnection object or if used, string name alias
        """
        bts_root_dn = bts_root_dn or self._get_site_root_dist_name(connection=connection)
        for param in parameters:
            dist_name = self._get_root_dn(bts_root_dn, param.get('dist_name'))
            self.coam.append_parameter_update_to_delta(dist_name=dist_name, parameter=param['parameter'],
                                                       value=param['value'], delta_id=delta_id, connection=connection)

    def create_update_parameters_delta(self, parameters, file_path=None, operation="update", connection="cOAM"):
        """
        Create JSON Delta recommission file for parameter update
        :param parameters: list of dicts, examples are below.
            parameters = [ {'dist_name': None, 'parameter':'btsName', 'value':'Automation_Testing'},
                            {'dist_name': 'MNL-1/MNLENT-1/SYNC-1/CLOCK-1', 'parameter':'syncInputList',
                            'value':[{'syncInputPrio':'1','syncInputType':'1pps/ToD from external GNSS receiver'}]},
                            {'dist_name': 'NRBTS-1/NRDU-1', 'parameter':'refNrCellGroup', 'value':['0']},
                            ]
        :param connection: AdminConnection object or if used, string name alias
        :return: dictionary which contains updated and reverse JSON Delta recommission file
        """
        self.coam.setup_admin(alias=connection)
        self.coam.connect_to()
        bts_root_dn, delta_id, delta_file_name = self._get_delta_config(delta_operation=operation,
                                                                        connection=connection)
        appended_params = self._append_list_param_items(parameters, bts_root_dn, connection=connection)
        self._add_update_parameters_to_delta(parameters=appended_params, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                             connection=connection)
        self.coam.save_delta(target_file_name=delta_file_name, delta_id=delta_id, connection=connection)
        rev_delta_file_name = delta_file_name.replace('.json', '_rev.json')
        self.coam.remove_delta(delta_id=delta_id, connection=connection)
        self.coam.create_delta(delta_id=delta_id, connection=connection)
        rev_parameters = self._get_list_values_from_scf_file(parameters=appended_params,
                                                             connection=connection)
        self._add_update_parameters_to_delta(parameters=rev_parameters, delta_id=delta_id, bts_root_dn=bts_root_dn,
                                             connection=connection)
        self.coam.save_delta(target_file_name=rev_delta_file_name, delta_id=delta_id, connection=connection)
        self.coam.teardown(connection=connection)
        self.coam.teardown_admin(alias=connection)
        delta_file = {delta_file_name: delta_file_name, rev_delta_file_name: rev_delta_file_name}
        if operation == "create":
            for file in [delta_file_name, rev_delta_file_name]:
                with open(file, "r") as fp:
                    contents = fp.read()
                    new_contents = contents.replace('"operation":"update"', '"operation":"create"', 1)
                with open(file, "w") as fp:
                    fp.write(new_contents)
        if file_path:
            for file in [delta_file_name, rev_delta_file_name]:
                shutil.move(file, file_path)
                separator = os.path.sep
                delta_file[file] = os.path.join(file_path, file.split(separator)[-1])
        delta_file_name = delta_file.get(delta_file_name)
        rev_delta_file_name = delta_file.get(rev_delta_file_name)
        return {'updated': delta_file_name, 'reverse': rev_delta_file_name}


class CapabilityParameterParser(object):
    """Capability Parameter Parser """

    def __init__(self):
        self.capability_file_path = "/home/ute/kiss_files/private/capability/ue_capability.md"
        self.capability_file_format = 'md'

    def _auto_search_capability_file_path(self):
        if not os.path.exists(self.capability_file_path):
            folder_path = os.path.dirname(os.path.abspath(__file__))
            capability_file_path = os.path.join(folder_path, "ue_capability.csv")
            if os.path.exists(capability_file_path):
                self.capability_file_path = capability_file_path
                self.capability_file_format = 'csv'

    def _read_content(self, catergory):
        if self.capability_file_format == 'md':
            segment_char = '|'
            head_line = 2
        else:
            segment_char = ','
            head_line = 1
        print("read capability from {}".format(self.capability_file_path))
        with open(self.capability_file_path) as f_md:
            for _ in range(head_line):
                f_md.readline()
            each_line = f_md.readline().strip()
            while each_line:
                pattern, capability, _ = each_line.lstrip(segment_char).split(segment_char)[0:3]
                pattern = pattern.strip()
                capability = capability.strip()
                if catergory == pattern:
                    print('{} ue capability is: {}'.format(catergory, pattern))
                    return capability
                each_line = f_md.readline().strip()

    def obtain_ue_capability(self, catergory, capability_file_path=None):
        """
        obtain ue capability from capability file which default file define in
        "https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/ta_kiss_golden_files.git"
        :param catergory: UE catergory which define in CSV file.
        :param capability_file_path: default None will download default file in common keyword Download All Tools
        :return: the UE capability
        """
        if not capability_file_path:
            self._auto_search_capability_file_path()
        else:
            self.capability_file_path = capability_file_path
            if capability_file_path.endswith('.csv'):
                self.capability_file_format = 'csv'
        content = self._read_content(catergory)
        return content


class Parameter_Parser(DeltaParameterParser, CapabilityParameterParser):
    """Parameter Parse Interface"""

    def __init__(self):
        DeltaParameterParser.__init__(self)
        CapabilityParameterParser.__init__(self)
