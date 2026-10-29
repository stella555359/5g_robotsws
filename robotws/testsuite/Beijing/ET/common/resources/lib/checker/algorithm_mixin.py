# -*- coding: utf-8 -*-
"""
2022/08/09 first version by @author: sheng.1.ye@nokia-sbell.com
           this is algorithm file for Checker class
2022/08/23 add function create_robot_file, by Ye Sheng
"""

from math import ceil, floor
import inspect
import os

ROBOT_TEMPLATE = """#!/usr/bin/sh
root=/home/ute/MN/UTE/robotws
robot_file=`readlink -f $0`
cd ${root} && robot --pythonpath ${root} $robot_file; exit


*** Settings ***

Library           ${EXECDIR}/{{module_name}}

*** Variables ***

${TEST_LOG_DIRECTORY}   ${EXECDIR}/{{module_name}}
${log_path}          ${TEST_LOG_DIRECTORY}
{{params}}

*** Keywords ***

{{keyword_name}}
    Log To Console                                starting {{func_name}}
    {{func_name}}        log_path=${log_path}    {{params_list}}
    Log To Console                                {{func_name}}  passed

*** Test Cases ***

MY TEST CASE {{test_name}}

    {{keyword_name}}
"""


class AlgorithmMixin:
    @staticmethod
    def ceil_4(x):
        return ceil(x / 4) * 4

    @staticmethod
    def floor_4(x):
        return floor(x / 4) * 4

    @staticmethod
    def func_name():
        return inspect.currentframe().f_back.f_code.co_name

    @staticmethod
    def create_robot_file():
        caller_frame = inspect.currentframe().f_back
        caller_name = caller_frame.f_code.co_name
        caller_arginfo = inspect.getargvalues(caller_frame)
        caller_args = {k: v for k, v in caller_arginfo.locals.items() if k in caller_arginfo.args}
        if caller_args.pop('log_level', None) is not None:
            test_name = caller_frame.f_back.f_code.co_name
            caller_module = inspect.getmodule(caller_frame)
            caller_module_name = caller_module.__name__.replace('.', '/')
            caller_base_path = os.path.dirname(caller_module.__file__)
            caller_log_path = os.path.join(caller_base_path, 'logs')
            caller_args_formatted = {
                k: '${TEST_LOG_DIRECTORY}/logs/' + os.path.relpath(v, caller_log_path).replace('\\', '/')
                   if type(v) is str and os.path.exists(v)
                else '${%d}' % v if type(v) is int
                else '${None}' if v is None
                else v
                for k, v in caller_args.items() if k not in 'log_path'
            }
            params = '\n'.join(["${%s}  %s" % (k, v) for k, v in caller_args_formatted.items()])
            params_list = "    ".join("%s=${%s}" % (k, k) for k in caller_args_formatted)

            keyword_name = caller_name.lstrip("verify_") + "_checker"
            replace_list = (
                ('{{module_name}}', caller_module_name),
                ('{{keyword_name}}', keyword_name),
                ('{{func_name}}', caller_name),
                ('{{test_name}}', test_name),
                ('{{params}}', params),
                ('{{params_list}}', params_list),
            )
            template = ROBOT_TEMPLATE
            for search, replace in replace_list:
                template = template.replace(search, replace)
            with open(os.path.join(caller_base_path, test_name + '.robot'), "w", newline="\n") as wf:
                wf.write(template)
