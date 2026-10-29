# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:in case of changes please contact author,
:do not modify without permission
"""
import os
import yaml
from taf.rfrl.utilities.robot.general import get_builtin_value


__all__ = ['get_l3_avg_rate', 'get_l3_min_rate', 'get_frame_structure_info']


class GetCaseVariables(object):
    def __init__(self, suite_name='default', test_name='default'):
        test_path = get_builtin_value('SUITE SOURCE')
        dir = os.path.dirname(test_path)
        self.path = os.path.join(dir, 'TestData/case_variables.yml')
        self.suite_name = suite_name
        self.test_name = test_name
        self.exist_yml, self.content = self._load_file()

    def _load_file(self):
        try:
            with open(self.path) as f:
                content_read = f.read()
                content = yaml.load(content_read, Loader=yaml.FullLoader)
                exist_yml = True
        except Exception:
            content = None
            exist_yml = False
        return exist_yml, content

    def get_all_varibles(self):
        print('suite_name: {}, test_name: {}'.format(self.suite_name, self.test_name))
        variables_for_cases = self.content['variables_for_cases']
        suite_key_default = 'suite_name-{}'.format('default')
        suite_value_default = variables_for_cases[suite_key_default]
        test_value_default = 'test_name-{}'.format('default')
        default_value = suite_value_default[test_value_default]
        suite_key = 'suite_name-{}'.format(self.suite_name)
        test_key = 'test_name-{}'.format(self.test_name)
        get_suite_key = suite_key if suite_key in variables_for_cases.keys() else suite_value_default
        suite_value = variables_for_cases[get_suite_key]
        if test_value_default in suite_value.keys():
            default_value.update(suite_value[test_value_default])
        if test_key in suite_value.keys():
            default_value.update(suite_value[test_key])
        print('get value: {}'.format(default_value))
        return default_value


def get_l3_avg_rate(release='master', suite_name='default', test_name='default', l3_avg_rate=None):
    rate = 0.9
    gcv = GetCaseVariables(suite_name=suite_name, test_name=test_name)
    if l3_avg_rate is not None:
        rate = l3_avg_rate
    elif gcv.exist_yml:
        l3_avg_rate_dict = gcv.get_all_varibles()['l3_avg_rate']
        if release in l3_avg_rate_dict.keys():
            rate = l3_avg_rate_dict[release]
        elif 'default' in l3_avg_rate_dict.keys():
            rate = l3_avg_rate_dict['default']
        else:
            rate = rate
    return rate


def get_l3_min_rate(release='master', suite_name='default', test_name='default', l3_min_rate=None):
    rate = 0.8
    gcv = GetCaseVariables(suite_name=suite_name, test_name=test_name)
    if l3_min_rate is not None:
        rate = l3_min_rate
    elif gcv.exist_yml:
        l3_min_rate_dict = gcv.get_all_varibles()['l3_min_rate']
        if release in l3_min_rate_dict.keys():
            rate = l3_min_rate_dict[release]
        elif 'default' in l3_min_rate_dict.keys():
            rate = l3_min_rate_dict['default']
        else:
            rate = rate
    return rate


def get_frame_structure_info(suite_name='default', test_name='default'):
    gcv = GetCaseVariables(suite_name=suite_name, test_name=test_name)
    frame_structure_info = gcv.get_all_varibles()['frame_structure_info']
    return frame_structure_info
