import re
import xml.etree.ElementTree as ET

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.exceptions import SCFObjectNotFound


class SCFContent:
    def __init__(self, scf_filepath=None):
        self._tree = None
        self._root = None
        self._ns = ''
        self.nrcells = None
        if scf_filepath is not None:
            self.load_scf(scf_filepath)
        self._delta_dict = {'delete': [], 'update': [], 'complex': []}
        self._reverse_delta_dict = {'delete': [], 'update': [], 'complex': []}

    def load_scf(self, scf_filepath):
        self._tree = ET.parse(scf_filepath)
        self._root = self._tree.getroot()
        self._ns = self._get_scf_namespace()
        self.nrcells = self._get_all_nrcells()

    def _get_scf_namespace(self):
        ns = re.match(r'^(\{.*?\})raml$', str(self._root.tag)).groups()
        return ns[0] if len(ns) else ''

    def get_all_managed_objects(self, class_attrib):
        return filter(lambda mo: ('class', class_attrib) in mo.attrib.items(),
                      self._root.iter(f'{self._ns}managedObject'))

    def get_managed_object(self, dist_name):
        filtered_objects = list(filter(lambda mo: ('distName', dist_name) in mo.attrib.items(),
                                self._root.iter(f'{self._ns}managedObject')))
        if not filtered_objects:
            raise SCFObjectNotFound(f"distName = {dist_name}")
        return filtered_objects[0]

    def get_all_params_from_managed_object(self, mo):
        param_dict = self.get_all_raw_params_from_managed_object(mo)
        param_dict.update(self.get_all_lists_from_managed_object(mo))
        return param_dict

    def get_all_raw_params_from_managed_object(self, mo):
        return {param.get('name'): param.text for param in mo.findall(f'{self._ns}p') if 'name' in param.attrib}

    def get_all_lists_from_managed_object(self, mo):
        return {param.get('name'): self._parse_list_param(param) for param in mo.findall(f'{self._ns}list')
                if 'name' in param.attrib}

    def _parse_list_param(self, list_param):
        items = [self.get_all_params_from_managed_object(item) for item in list_param.findall(f'{self._ns}item')]
        items.extend(self.get_nameless_params_from_managed_object(list_param))
        return items

    def get_nameless_params_from_managed_object(self, mo):
        return [param.text for param in mo.findall(f'{self._ns}p') if 'name' not in param.attrib]

    def _get_all_nrcells(self):
        nrcells = self.get_all_managed_objects(class_attrib="com.nokia.srbts.nrbts:NRCELL")
        return {nrcell.get('distName'): self.get_all_params_from_managed_object(nrcell) for nrcell in nrcells}

    def get_nrcell(self, physcellid):
        for nrcell_dn, nrcell_params in self.nrcells.items():
            if nrcell_params.get('physCellId', '') == str(physcellid):
                return nrcell_dn, nrcell_params
        raise SCFObjectNotFound(f"No NRCELL object with physCellId == {physcellid}")


class Delta:
    def __init__(self, delta_id='default_delta'):
        self._delta_dict = {'delete': [], 'update': [], 'complex': []}
        self._delta_id = delta_id

    def append_parameter_dict(self, param_dict):
        for dn, expected_parameters in param_dict.items():
            for param_name, expected_value in expected_parameters.items():
                self.append_parameter(dn, param_name, expected_value)

    def append_parameter(self, dist_name, param_name, expected_value):
        if expected_value is None:
            self._delta_dict['delete'].append({'dn': dist_name, 'name': param_name})

        elif isinstance(expected_value, list):
            if len(expected_value) and isinstance(expected_value[0], dict):
                self._delta_dict['complex'].append({'dn': dist_name, 'name': param_name, 'value': expected_value})
            else:
                self._delta_dict['update'].append({'dn': dist_name, 'name': param_name, 'value': expected_value})
        else:
            self._delta_dict['update'].append({'dn': dist_name, 'name': param_name, 'value': expected_value})

    def commission_delta(self, admin_api, admin_connection):
        admin_api.create_delta(self._delta_id)
        for param_dict in self._delta_dict['delete']:
            admin_api.append_parameter_delete_to_delta(dist_name=param_dict['dn'], parameter=param_dict['name'],
                                                       delta_id=self._delta_id)
        for param_dict in self._delta_dict['update']:
            admin_api.append_parameter_update_to_delta(dist_name=param_dict['dn'], parameter=param_dict['name'],
                                                       value=param_dict['value'], delta_id=self._delta_id)
        for param_dict in self._delta_dict['complex']:
            for item_params in param_dict['value']:
                admin_api.append_complex_item_to_delta(dist_name=param_dict['dn'], list_name=param_dict['name'],
                                                       delta_id=self._delta_id, **item_params)
        delta = admin_api.get_delta(self._delta_id)
        status = admin_connection.perform_delta_recommissioning(delta)
        admin_api.remove_delta(self._delta_id)
        return status
