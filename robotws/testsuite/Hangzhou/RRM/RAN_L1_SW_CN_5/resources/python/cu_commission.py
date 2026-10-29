# -*- coding: utf-8 -*-
"""
Contact Mail:   yixiang.x.wang@nokia-sbell.com
Description:    This is for CU delta commission
"""

import datetime
import os
import time
import re
import logging
import xml.etree.ElementTree as ET
from taf.gnb.oam.coam.cu import cu


class XmlParser():
    def __init__(self, xmlstr):
        self.parse_xml_info(xmlstr)

    def _get_attrvalue(self, node, attrname):
        return node.get(attrname) if node is not None else ''

    def _get_nodevalue(self, node, index=0):
        return node.text if node.text else ''

    def _get_xmlnode(self, node, name):
        return node.findall(name) if node is not None else []

    def parse_xml_info(self, node):
        return


class ManagedObjectInfo(XmlParser):
    def parse_one_mo(self, mo):
        mo_p = self._get_xmlnode(mo, 'p')
        managedObject = {}
        for p in mo_p:
            p_name = self._get_attrvalue(p, 'name')
            p_value = self._get_nodevalue(p)
            managedObject[p_name] = p_value

        lists = self._get_xmlnode(mo, 'list')
        for list in lists:
            list_name = self._get_attrvalue(list, 'name')
            item_node = self._get_xmlnode(list, 'item')
            list_item = []
            for item in item_node:
                list_p = self._get_xmlnode(item, 'p')
                temp = {}
                for p in list_p:
                    p_name = self._get_attrvalue(p, 'name')
                    p_value = self._get_nodevalue(p)
                    temp[p_name] = p_value
                list_item.append(temp.copy())
            if not item_node:

                list_p = self._get_xmlnode(list, 'p')
                for p in list_p:
                    p_value = self._get_nodevalue(p)
                    list_item.append(p_value)

            managedObject[list_name] = list_item
        return managedObject

    def parse_xml_info(self, xmlstr):
        xmlstr = xmlstr.replace('xmlns', 'ABC')
        root = ET.fromstring(xmlstr)
        MOs = self._get_xmlnode(root[0], 'managedObject')
        self.mo_dict = {}
        self.plan_mo_operation_dict = {}
        for managedObject in MOs:
            class_name = self._get_attrvalue(managedObject, 'class')
            distName = self._get_attrvalue(managedObject, 'distName')
            PlanOperationType = self._get_attrvalue(managedObject, 'operation')
            mo = self.parse_one_mo(managedObject)
            self.mo_dict[distName] = mo


class cm(object):
    def __init__(self):
        self.mo_dict = None
        self.root_dn = None
        self.cu_inst = cu()
        self.plan_id = ''
        self.dn_map_uuid = {}
        self.uuid_map_dn = {}
        self.nidds = []

    def delta_commission_online_update(self, parameters, cu_ip,
                                       cu_username='Nemuadmin', cu_password='nemuuser',
                                       log_dir='/home/ute'):
        """
        parameters = {'MRBTS-400/NRBTS-400/NRDRB_PDCP-1': {'tReorderingUl': 'ms100'}}

        parameters = {'MRBTS-400/NRBTS-400/NRDRB_PDCP-1': {'tReorderingUl': 'ms80'},
                  'MRBTS-400/MNL-1/MNLENT-1/PMCADM-1' : {'reportingIntervalPm': '15min'}
                  }

        :return:updated parameters
        """
        try:
            self.cu_inst.connect_to(host=cu_ip, port='443',
                                    username=cu_username, password=cu_password, secure=True)
            self.nidds = self.cu_inst.get_nidd()
            self._delete_delta_plan()
            self._create_delta_plan()
            scf_file = self._get_current_cu_scf_files(log_dir=log_dir)
            self._get_dn_mo_uuid_map(scf_file)
            paras_change = self._get_added_modified_parameters(parameters)
            if paras_change['modified'] or paras_change['added']:
                self._cu_add_replace_parameters_to_delta(paras_change['modified'])
                self._cu_add_create_parameters_to_delta(paras_change['added'])
                self._validate_delta_plan()
                self._activate_delta_plan()
        finally:
            self.cu_inst.disconnect()
        return paras_change

    def delta_commission_online_add_mo(self, parameters, cu_ip,
                                       cu_username='Nemuadmin', cu_password='nemuuser',
                                       log_dir='/home/ute'):
        """
        parameters = {'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-2': {'tacOverbookingLimit': '10'}}

        :return:updated parameters
        """
        try:
            self.cu_inst.connect_to(host=cu_ip, port='443',
                                    username=cu_username, password=cu_password, secure=True)
            self.nidds = self.cu_inst.get_nidd()
            self._delete_delta_plan()
            self._create_delta_plan()
            scf_file = self._get_current_cu_scf_files(log_dir)
            self._get_dn_mo_uuid_map(scf_file)
            self._cu_add_create_mo_to_delta(parameters)
            self._validate_delta_plan()
            self._activate_delta_plan()
        finally:
            self.cu_inst.disconnect()
        return parameters

    def delta_commission_online_delete_mo(self, parameters, cu_ip,
                                          cu_username='Nemuadmin', cu_password='nemuuser',
                                          log_dir='/home/ute'):
        """
        parameters = {'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-2': {'tacOverbookingLimit': '10'}}

        :return:updated parameters
        """
        try:
            self.cu_inst.connect_to(host=cu_ip, port='443',
                                    username=cu_username, password=cu_password, secure=True)
            self.nidds = self.cu_inst.get_nidd()
            self._delete_delta_plan()
            self._create_delta_plan()
            scf_file = self._get_current_cu_scf_files(log_dir)
            self._get_dn_mo_uuid_map(scf_file)
            self._cu_add_delete_mo_to_delta(parameters)
            self._validate_delta_plan()
            self._activate_delta_plan()
        finally:
            self.cu_inst.disconnect()
        return parameters

    def _waite_until_succeed(self, timeout, function, **args):
        interval = 5
        loop = int(timeout) / 5 + 1
        for i in range(loop):
            succeed = function(**args)
            if succeed:
                return True
            time.sleep(interval)
        return False

    def cmp_dicts(self, dict_l, dict_r):
        keys_l = set(dict_l.keys())
        keys_r = set(dict_r.keys())
        deleted = list(keys_l.difference(keys_r))
        added = list(keys_r.difference(keys_l))
        common_keys = keys_l.intersection(keys_r)
        same = []
        modified = []
        for key in common_keys:
            if dict_l[key] == dict_r[key]:
                same.append(key)
            else:
                modified.append(key)
        return {'deleted': deleted, 'added': added, 'same': same, 'modified': modified}

    def _delete_delta_plan(self):
        delta_plans = self.cu_inst.get_delta_plan_list()
        for delta in delta_plans:
            self.cu_inst.delete_delta_plan(plan_id=delta['plan_id'])

    def _create_delta_plan(self):
        status = self.cu_inst.generate_delta_plan('delta-plan')
        self.plan_id = status['plan_id']
        self._waite_until_succeed(10, self._is_delta_plan_created, action_id=status['action_id'])

    def _get_distname_by_mo(self, mo, scf_file):
        mo = mo.strip('/')
        n_mo = mo if 'MRBTS' in mo else '/' + mo
        with open(scf_file, 'r') as f:
            content = f.read()
        if '-' in mo.split('/')[-1]:
            partern = r'.*distName="(.*{})"\s+.*'.format(n_mo)
        else:
            partern = r'.*distName="(.*{}-\d+)"\s+.*'.format(n_mo)
        logging.info('find {} from {} by {}'.format(mo, scf_file, partern))
        distnames = re.findall(partern, content)
        if not distnames:
            logging.warn('not find {} at {}'.format(mo, scf_file))
        return distnames

    def _get_current_cu_scf_files(self, log_dir):
        current_time = datetime.datetime.now().strftime("%Y%m%d%H%M%S%f")
        scf_file_path = os.path.join(log_dir, 'cu_scf_{}.xml'.format(current_time))
        self.cu_inst.get_current_plan_file(path=scf_file_path, timeout='60')
        return scf_file_path

    def _add_mo_and_get_dn_mo_uuid_map(self, dns):
        dns = list(self.mo_dict.keys())
        dns.sort(key=self._count_dn_slices)
        diffs = self.cu_inst.get_delta_plan_tree_diff(self.plan_id)
        root_uuid = list(filter(lambda x: x['name'] == dns[0].strip('/'), diffs['created']))[0]
        root_uuid = root_uuid['mo_uuid']
        self.dn_map_uuid[dns[0]] = root_uuid
        self.uuid_map_dn[root_uuid] = dns[0]
        for dn in dns[1:]:
            parent_dn = '/'.join(dn.split('/')[:-1])
            dn_name = dn.split('/')[-1]
            parent_uuid = self.dn_map_uuid[parent_dn]
            dn_uuid_tmp = list(filter(lambda x: 'name' in x.keys() and
                                                'parent_mo_uuid' in x.keys() and
                                                x['name'] == dn_name.strip('/') and
                                                x['parent_mo_uuid'] == parent_uuid, diffs['created']))
            if dn_uuid_tmp == []:
                continue
            dn_uuid = dn_uuid_tmp[0]
            dn_uuid = dn_uuid['mo_uuid']
            self.dn_map_uuid[dn] = dn_uuid
            self.uuid_map_dn[dn_uuid] = dn

    def _get_dn_mo_uuid_map(self, scf_file):
        self._par_scf_file(scf_file)
        dns = list(self.mo_dict.keys())
        dns.sort(key=self._count_dn_slices)
        diffs = self.cu_inst.get_delta_plan_tree_diff(self.plan_id)
        root_uuid = list(filter(lambda x: x['name'] == dns[0].strip('/'), diffs['created']))[0]
        root_uuid = root_uuid['mo_uuid']
        self.dn_map_uuid[dns[0]] = root_uuid
        self.uuid_map_dn[root_uuid] = dns[0]
        for dn in dns[1:]:
            parent_dn = '/'.join(dn.split('/')[:-1])
            dn_name = dn.split('/')[-1]
            parent_uuid = self.dn_map_uuid[parent_dn]
            dn_uuid_tmp = list(filter(lambda x: 'name' in x.keys() and
                                      'parent_mo_uuid' in x.keys() and
                                      x['name'] == dn_name.strip('/') and
                                      x['parent_mo_uuid'] == parent_uuid, diffs['created']))
            if dn_uuid_tmp == []:
                continue
            dn_uuid = dn_uuid_tmp[0]
            dn_uuid = dn_uuid['mo_uuid']
            self.dn_map_uuid[dn] = dn_uuid
            self.uuid_map_dn[dn_uuid] = dn

    def _get_added_modified_parameters(self, parameters):
        # complex parameter handle is not completed
        added = {}
        modified = {}
        for dn in parameters:
            cmps = self.cmp_dicts(self.mo_dict[dn], parameters[dn])
            for p in cmps['added']:
                added.setdefault(dn, {})
                added[dn][p] = parameters[dn][p]
            for p in cmps['modified']:
                modified.setdefault(dn, {})
                modified[dn][p] = parameters[dn][p]
        return {'added': added, 'modified': modified}

    def _is_delta_plan_created(self, action_id):
        status = self.cu_inst.get_action_state_of_generating_delta_plan(action_id=action_id)
        if status['status'] == 'success':
            return True
        else:
            return False

    def _par_scf_file(self, scf_file):
        with open(scf_file, 'r') as f:
            xmlstr = f.read()
        mo_inst = ManagedObjectInfo(xmlstr)
        self.mo_dict = mo_inst.mo_dict
        distnames = list(mo_inst.mo_dict.keys())
        self.root_dn = distnames[0].split('/')[0]

    def _count_dn_slices(self, dn):
        return dn.count('/')

    def _cu_add_replace_parameters_to_delta(self, parameters):
        self._cu_add_update_parameters_to_delta('replace', parameters)

    def _cu_add_delete_parameters_to_delta(self, parameters):
        self._cu_add_update_parameters_to_delta('remove', parameters)

    def _cu_add_create_parameters_to_delta(self, parameters):
        self._cu_add_update_parameters_to_delta('add', parameters)

    def _cu_add_update_parameters_to_delta(self, operation, parameters):
        for dn in parameters:
            uuid = self.dn_map_uuid[dn]
            parameter_change_list = []
            for para in parameters[dn]:
                if isinstance(parameters[dn][para], list):
                    change_list = self._cu_create_delta_list_parameters(dn, para, parameters)
                    parameter_change_list.extend(change_list)
                else:
                    temp = {"operation_type": operation, "parameter_path": "", "value": ""}
                    para_path = '/' + para
                    value = parameters[dn][para]
                    temp['parameter_path'] = para_path
                    temp['value'] = value
                    parameter_change_list.append(temp)
            if parameter_change_list != []:
                status = self.cu_inst.update_parameters_of_delta_plan(plan_id=self.plan_id,
                                                                      mo_uuid=uuid,
                                                                      parameter_change_list=parameter_change_list)
                time.sleep(0.5)
                result = self._waite_until_succeed(15,
                                                   self._is_delta_parameter_updated,
                                                   action_id=status['action_id'])
                if not result:
                    status2 = self.cu_inst.get_action_state_of_updating_parameters_of_delta_plan(
                        plan_id=self.plan_id,
                        action_id=status['action_id'])
                    raise AssertionError('delta parameter adding failed for {} as {}'.format(
                        parameter_change_list, status2))

    def _cu_create_delta_list_parameters(self, dn, para, parameters):
        # self.mo_dict should not be None when call this function
        para_change_list = []
        origin_indexs = set(range(len(self.mo_dict[dn][para])))
        new_indexs = set(range(len(parameters[dn][para])))
        modified_indexs = origin_indexs.intersection(new_indexs)
        added_indexs = new_indexs.difference(origin_indexs)
        deleted_indexs = origin_indexs.difference(new_indexs)
        changes = self._cu_create_delta_list_parameters_according_to_operation(
            'replace', modified_indexs, dn, para, parameters)
        para_change_list.extend(changes)
        changes = self._cu_create_delta_list_parameters_according_to_operation(
            'add', added_indexs, dn, para, parameters)
        para_change_list.extend(changes)
        changes = self._cu_create_delta_list_parameters_according_to_operation(
            'remove', deleted_indexs, dn, para, parameters)
        para_change_list.extend(changes)
        return para_change_list

    def _cu_create_delta_list_parameters_according_to_operation(self, operation, indexs, dn, para, parameters):
        parameter_change_list = []

        for index in indexs:
            if operation == 'remove':
                temp = {"operation_type": operation, "parameter_path": "", "value": ""}
                para_path = '/' + para + '/' + str(index)
                temp['parameter_path'] = para_path
                parameter_change_list.append(temp)
                return parameter_change_list

            if not isinstance(parameters[dn][para][index], dict):
                temp = {"operation_type": operation, "parameter_path": "", "value": ""}
                para_path = '/' + para + '/' + str(index)
                temp['parameter_path'] = para_path
                temp['value'] = parameters[dn][para][index]
                parameter_change_list.append(temp)
            else:
                for ss_para in parameters[dn][para][index]:
                    temp = {"operation_type": operation, "parameter_path": "", "value": ""}
                    if 'delete:' in ss_para.lower():
                        temp['operation_type'] = 'remove'
                    para_path = '/' + para + '/' + str(index) + '/' + ss_para
                    value = parameters[dn][para][index][ss_para]
                    temp['parameter_path'] = para_path
                    temp['value'] = value
                    parameter_change_list.append(temp)
        return parameter_change_list

    def _is_delta_parameter_updated(self, action_id):
        status = self.cu_inst.get_action_state_of_updating_parameters_of_delta_plan(plan_id=self.plan_id,
                                                                                    action_id=action_id)
        if status['status'] == 'success':
            return True
        else:
            return False

    def _validate_delta_plan(self):
        status = self.cu_inst.validate_delta_plan(plan_id=self.plan_id)
        result = self._waite_until_succeed(30,
                                           self._is_delta_plan_validate_ok,
                                           action_id=status['action_id'])
        if not result:
            status2 = self.cu_inst.get_action_state_of_validating_delta_plan(plan_id=self.plan_id,
                                                                             action_id=status['action_id'])
            raise AssertionError('delta plan validate failed as {}'.format(status2))

    def _is_delta_plan_validate_ok(self, action_id):
        status = self.cu_inst.get_action_state_of_validating_delta_plan(plan_id=self.plan_id,
                                                                        action_id=action_id)
        if status['status'] == 'success':
            return True
        else:
            return False

    def _activate_delta_plan(self):
        activation_status = self.cu_inst.activate_delta_plan(self.plan_id)
        if activation_status['status'] != 'ongoing':
            raise AssertionError('plan activation failed {}'.format(activation_status))
        activation_ok = self._waite_until_succeed(180, self._is_delta_activation_ok,
                                                  action_id=activation_status['operation_id'])
        if not activation_ok:
            status = self.cu_inst.get_operation_state_of_activating_delta_plan(
                plan_id=self.plan_id,
                operation_id=activation_status['operation_id'])
            raise AssertionError('CU delta plan activation is failed as status {}'.format(status))

    def _is_delta_activation_ok(self, action_id):
        try:
            status = self.cu_inst.get_operation_state_of_activating_delta_plan(plan_id=self.plan_id,
                                                                               operation_id=action_id)
            if status['status'] == 'success':
                return True
            elif status['status'] == 'failure':
                raise AssertionError('plan activation failure {}'.format(status))
            else:
                return False
        except Exception:
            return False

    def _cu_add_create_mo_to_delta(self, parameters):
        dns = list(parameters.keys())
        dns.sort(key=self._count_dn_slices)
        for dn in dns:
            parent_dn = '/'.join(dn.split('/')[:-1])
            dn_name = dn.split('/')[-1]
            base_mo = dn_name.split('-')[0]
            mo_id = dn_name.split('-')[1]
            nidd_id = self._get_nidd_id_by_mo(base_mo)
            parent_uuid = self.dn_map_uuid[parent_dn]
            status = self.cu_inst.create_managed_object_of_delta_plan(plan_id=self.plan_id,
                                                                      parent_mo_uuid=parent_uuid,
                                                                      nidd_id=nidd_id,
                                                                      instance_id=int(mo_id),
                                                                      include_defaults=True)

            result = self._waite_until_succeed(15, self._is_mo_delta_created,
                                               action_id=status['action_id'])
            sub_dns = {dn: parameters[dn]}
            self.mo_dict.update(sub_dns)
            self._add_mo_and_get_dn_mo_uuid_map(dns=sub_dns)
            if not result:
                status2 = self.cu_inst.get_create_managed_object_action_result(plan_id=self.plan_id,
                                                                               action_id=status['action_id'])
                raise AssertionError('delta mo creation failed for {} as {}'.format(dn, status2))
        self._update_uuid_map('create', dns)
        self._cu_add_update_parameters_to_delta('add', parameters)

    def _get_nidd_id_by_mo(self, mo):
        mo_nidd = list(filter(lambda x: x['class_name'] == mo, self.nidds))
        return mo_nidd[0]['nidd_id']

    def _is_mo_delta_created(self, action_id):
        status = self.cu_inst.get_create_managed_object_action_result(plan_id=self.plan_id,
                                                                      action_id=action_id)
        if status['status'] == 'success':
            return True
        else:
            return False

    def _update_uuid_map(self, operation, dns):
        dns.sort(key=self._count_dn_slices)
        diffs = self.cu_inst.get_delta_plan_tree_diff(self.plan_id)
        if operation == 'create':
            for dn in dns:
                parent_dn = '/'.join(dn.split('/')[:-1])
                dn_name = dn.split('/')[-1]
                parent_uuid = self.dn_map_uuid[parent_dn]
                dn_uuid_tmp = list(filter(lambda x: 'name' in x.keys() and
                                                    'parent_mo_uuid' in x.keys() and
                                                    x['name'] == dn_name.strip('/') and
                                                    x['parent_mo_uuid'] == parent_uuid, diffs['created']))
                if dn_uuid_tmp == []:
                    continue
                dn_uuid = dn_uuid_tmp[0]
                dn_uuid = dn_uuid['mo_uuid']
                self.dn_map_uuid[dn] = dn_uuid
                self.uuid_map_dn[dn_uuid] = dn
        else:
            for dn in dns:
                uuid = self.dn_map_uuid.pop(dn)
                self.uuid_map_dn.pop(uuid)

    def _cu_add_delete_mo_to_delta(self, parameters):
        dns = list(parameters.keys())
        dns.sort(key=self._count_dn_slices)
        for dn in dns:
            status = self.cu_inst.delete_managed_object_of_delta_plan(plan_id=self.plan_id,
                                                                      mo_uuid=self.dn_map_uuid[dn])
            result = self._waite_until_succeed(15,
                                               self._is_delta_mo_deleted,
                                               action_id=status['action_id'])
            if not result:
                status2 = self.cu_inst.get_delete_managed_object_action_result(plan_id=self.plan_id,
                                                                               action_id=status['action_id'])
                raise AssertionError('delta mo deleted failed for {} as {}'.format(dn, status2))
        self._update_uuid_map('delete', dns)

    def _is_delta_mo_deleted(self, action_id):
        status = self.cu_inst.get_delete_managed_object_action_result(plan_id=self.plan_id,
                                                                      action_id=action_id)
        if status['status'] == 'success':
            return True
        else:
            return False

    def get_cu_single_parameter_value(self, distname, parameter, cu_ip,
                                      cu_username='Nemuadmin', cu_password='nemuuser', log_dir='/home/ute'):
        self.cu_inst.connect_to(host=cu_ip, port='443',
                                username=cu_username, password=cu_password, secure=True)
        scf_file = self._get_current_cu_scf_files(log_dir)
        distnames = self._get_distname_by_mo(distname, scf_file)
        self._par_scf_file(scf_file)
        if not distnames:
            raise AssertionError('{} distname is not found'.format(distname))
        paras = self.mo_dict[distnames[0]][parameter]
        self.cu_inst.disconnect()
        return paras

    def get_parameters_of_current_plan(self, parameter_name, cu_ip,
                                       cu_username='Nemuadmin', cu_password='nemuuser'):
        """
        parameter_name = {'cipherPrefL'}

        :return:It returns dict containing search parameters response
        {'items': [{'mo_uuid': 'fecb5dc8-e539-4645-84b0-3f51f3f35cd1',
                  'nidd_id': '199432', 'distname': 'MRBTS-247/NRBTS-1',
                  'parameter_name': 'cipherPrefL', 'state': u'unchanged',
                  'parameter': {'simple_list_parameter': None, 'simple_parameter': None,
                  'complex_parameter': {'state': u'unchanged', 'name': 'cipherPrefL',
                  'value': [{'structure_parameters': [{'complex_parameter': None,
                           'parameter_type': u'simple',
                           'simple_list_parameter': None,
                           'simple_parameter': {'name': 'nea0',
                                                'state': u'unchanged',
                                                'value': '0'}},
                          {'complex_parameter': None,
                           'parameter_type': u'simple',
                           'simple_list_parameter': None,
                           'simple_parameter': {'name': 'nea1_128',
                                                'state': u'unchanged',
                                                'value': '2'}},
                          {'complex_parameter': None,
                           'parameter_type': u'simple',
                           'simple_list_parameter': None,
                           'simple_parameter': {'name': 'nea2_128',
                                                'state': u'unchanged',
                                                'value': '4'}},
                          {'complex_parameter': None,
                           'parameter_type': u'simple',
                           'simple_list_parameter': None,
                           'simple_parameter': {'name': 'nea3_128',
                                                'state': u'unchanged',
                                                'value': '5'}}]}]}, 'parameter_type': u'complex'}}], 'total': 1}
        """

        self.cu_inst.connect_to(host=cu_ip, port='443',
                                username=cu_username, password=cu_password, secure=True)
        para_dict = self.cu_inst.search_parameters_of_current_plan(parameter_name=parameter_name)
        self.cu_inst.disconnect()
        return para_dict


# if __name__ == '__main__':
#     cm_inst = cm()
#     parameters = {'MRBTS-400/NRBTS-400/NRDRB_PDCP-1': {'tReorderingUl': 'ms80'},
#                   }
#     cm_inst.delta_commission_online_update(parameters=parameters, cu_ip='10.57.177.6')
#
#     parameters0 = {
#        'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-2': {'tacOverbookingLimit': '20'},
#        'MRBTS-400/MNL-1/MNLENT-1/TAC-1/LTAC-3': {'tacOverbookingLimit': '30'}
#                   }
#     parameters1 = {
#       'MRBTS-400/MNL-1/TCEADM-1': {},
#       'MRBTS-400/MNL-1/TCEADM-1/TCE-1':{'tceIdentifier':'0', 'tceIpAddress':'10.57.167.186', 'tcePortNumber':'49151'}
#     }
#     parameters2 = {'MRBTS-400/NRBTS-400/NRDRB_QCI-9':
#                   {'nrDrbDN': 'MRBTS-1/NRBTS-1/NRDRB-9', 'qciValueList': ['79']}
#     }
#     parameters3 = {
#         'MRBTS-400/MNL-1/TCEADM-1': {},
#         'MRBTS-400/MNL-1/TCEADM-1/TCE-1': {'tceIdentifier': '1', 'tceIpAddress':
#                      '10.57.167.186', 'tcePortNumber': '49151'},
#         'MRBTS-400/NRBTS-400/NRCTRLTS-1': {},
#         'MRBTS-400/NRBTS-400/NRCTRLTS-1/NRMTRACECU-1': {'actCellTraceReportingCU': 'true',
#                      'actPCMDReporting': 'true', 'cellMaxActiveUEsTraced': '100',
#                      'jobType': 'TraceOnly', 'nrMtraceCuId': '1',
#                      'nrRanTraceReference':[{'mcc':'262', 'mnc': '3', 'mncLength': '2', 'traceId': '1'}],
#                      'nrTceIdentifier': '1', 'scope': 'specificResources',
#                      'traceNGAPSetting': 'all', 'traceNRRRCSetting': 'all', 'traceX2Setting': 'all',
#                      'traceXNSetting': 'all'},
#         'MRBTS-400/NRBTS-400/NRCTRLTS-1/NRMTRACECU-1/NRRESOURCECU-1': {'resourceDN': 'MRBTS-400/NRBTS-400/NRCELL-1',
#                                                                        'typeNrCu': 'cell', 'nrResourceCuId': '1'}
#     }
#     cm_inst.delta_commission_online_add_mo(parameters=parameters3, cu_ip='10.57.177.6')
#
#     # get parameter value of testline
#     para_dict = cm_inst.get_parameters_of_current_plan(parameter_name='miNrCaCu', cu_ip='10.57.177.6')
#     ret = cm_inst.get_cu_single_parameter_value(cu_ip='10.57.177.6', distname='MRBTS-400/NRBTS-400/NRPMRNL-1',
#     parameter='miNrCaCu')
#     print ret
