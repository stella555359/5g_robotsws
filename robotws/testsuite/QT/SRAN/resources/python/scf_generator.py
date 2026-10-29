# -*- coding: utf-8 -*-
"""
:description: Functions to generate SCF files based on .j2 scf template for each product and definded,
              individual scf_variables for testline from testline configuration.
:copyright: Nokia Networks
:author: Mateusz Porzucek
:contact: mateusz.porzucek@nokia.com
"""

from jinja2 import Template, Environment, FileSystemLoader, StrictUndefined, exceptions
from robot.libraries.BuiltIn import BuiltIn
import importlib.util
import yaml
import json
import os
import sys
import argparse


def get_products_for_scf_template(list_of_branches):
    '''
    Get products from RELEASERS.json for branches definded in list 'list_of_branches' to generate SCF's.
    :param list_of_branches: list of branches used to generate SCF's, i.e. SBTS00, vDUCNF00.
    :return: a dictionary with branches and products used to generate SCF's
    '''
    with open('/home/ute/DSL-QT/text_files/RELEASERS.json', 'r') as file:
        branches_with_products = {}
        releaser = json.load(file)
        for item in releaser:
            for branch in item["branches"]:
                if branch in list_of_branches:
                    list_of_products = []
                    for product in item["products"]:
                        if "Airphone" not in product:
                            list_of_products.append(product)
                        branches_with_products[branch] = list_of_products
        return branches_with_products


def get_dict_with_testlines_parameters_for_scf_template(list_of_branches):
    '''
    Get list with the info of testlines from jenkins-cloud.yaml to generate SCF's based on products
    from func get_products_for_scf_template().
    :param tl_name: name of tl label fro jenkins-cloud.yaml, i.e. "QT-eCPRI_TDD_NSA_ASIM_cmw-WRO-4010".
    :param scf_suffix: parameter will be added to 'template_name' and 'output_scf_name',
                       if it is defined for testline in jenkins-cloud.yaml, e.g. if product has different hardware.
    :return: a dict with testlines parameters used to generate SCF's, such as: tl_name, tl_config,
            template_name, output_scf_name.
    '''
    dict_with_branches_and_products = get_products_for_scf_template(list_of_branches)
    with open('/home/ute/DSL-QT/jenkins-cloud.yaml', 'r') as file:
        jenkins_cloud = yaml.safe_load(file)
        dict_with_testlines_parameters = {}
        for branch in dict_with_branches_and_products:
            for product in dict_with_branches_and_products[branch]:
                testline_dictionary = {}
                for permanent in jenkins_cloud["jenkins"]["nodes"]:
                    for item in permanent["permanent"]:
                        if ("labelString" in item and
                            branch in permanent["permanent"][item] and
                            "PROD" in permanent["permanent"][item] and
                                " " + product + " " in permanent["permanent"][item]):
                            tl_name = permanent["permanent"]["name"]
                            output_scf_name = tl_name
                            template_name = product
                            tl_params = {}
                            for envVars in permanent["permanent"]["nodeProperties"]:
                                for key in (envVars["envVars"]["env"]):
                                    if key["key"] == "scf_suffix":
                                        scf_suffix = "_" + key["value"]
                                        template_name = product + scf_suffix
                                        output_scf_name = tl_name + scf_suffix
                                    if key["key"] == "config_path":
                                        tl_config = key["value"]
                                tl_params = {
                                    "tl_config": tl_config,
                                    "template_name": template_name,
                                    "output_scf_name": output_scf_name
                                }
                            testline_dictionary[tl_name] = tl_params
                dict_with_testlines_parameters[product] = testline_dictionary
    return dict_with_testlines_parameters


def generate_scf(template_path, scf_variables, output_scf_path):
    '''
    Generate SCF file based on .j2 template for product and scf_variables from testline configuration.
    :param template_path: path to the .j2 SCF template
                          e.g. robotws/testsuite/QT/SRAN/configs/scf_templates/eCPRI_TDD_NSA_ASIM_cmw.xml.j2
    :param scf_variables: dict with individual parameters for each testline from __init.py__ to genereta SCF file.
    :param output_scf_path: path to the generated SCF file e.g. /tmp/
    :return: Generated SCF file.
    '''
    if not os.path.exists(template_path):
        BuiltIn().log_to_console(
            f"--> FAIL: template {template_path} not found\n")
        raise FileNotFoundError()
    template_name = os.path.basename(template_path)
    template_dir = os.path.dirname(template_path)
    output_scf_dir = os.path.dirname(output_scf_path)
    env = Environment(
        loader=FileSystemLoader(template_dir),
        undefined=StrictUndefined
    )
    template = env.get_template(template_name)
    data = dict(
        conf=scf_variables,
    )
    try:
        scf_out = template.render(data)
    except exceptions.UndefinedError as e:
        BuiltIn().log_to_console(
            f"--> FAIL: SCF creation failed because of: {e}, please check tl.scf_variables in testline_configuration\n"
        )
    else:
        with open(output_scf_path, 'w') as f:
            f.write(scf_out)
            return output_scf_dir


def generate_all_scfs(list_of_branches):
    '''
    Generate all SCF files for testlines from func 'get_dict_with_testlines_parameters_for_scf_template()'
    :param output_scf_name: name of generated SCF file e.g. "QT-eCPRI_TDD_NSA_ASIM_cmw-WRO-4010"
    :param template_name: name of template SCF file name e.g. "eCPRI_TDD_NSA_ASIM_cmw"
    :param testline_config: name of tetline config to the testline configuration path e.g. "7_16_QT_4010"
    :param scf_variables: dict with individual parameters for each testline from __init.py__ to genereta SCF file.
    :return: Generated SCF files.
    '''
    list_of_testlines_for_scf = get_dict_with_testlines_parameters_for_scf_template(list_of_branches)
    for product in list_of_testlines_for_scf:
        for testline in list_of_testlines_for_scf[product]:
            output_scf_name = list_of_testlines_for_scf[product][testline]["output_scf_name"]
            template_name = list_of_testlines_for_scf[product][testline]["template_name"]
            testline_config = list_of_testlines_for_scf[product][testline]["tl_config"]
            template_path = "/home/ute/robotws/testsuite/QT/SRAN/configs/scf_templates/" + \
                template_name + ".xml.j2"
            testline_config_path = "/home/ute/testline_configuration/" + \
                testline_config + "/__init__.py"
            output_scf_path = "/home/ute/scf_minimal/" + output_scf_name + ".xml"
            scf_variables = import_scf_variables_from_init_py(
                'tl', testline_config_path, product)
            try:
                generate_scf(template_path, scf_variables, output_scf_path)
            except BaseException:
                print(
                    f'FAIL: SCF for testline "{output_scf_name}" can not be created \n')


def import_scf_variables_from_init_py(module_name, file_path, product):
    '''
    Import SCF variables from __init__py module
    :return: dictionary with scf variables from __init__py if exist, else: return None
    '''
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    spec.loader.exec_module(module)
    try:
        if 'Thor' in product:
            scf_variables = module.tl.du_scf_variables
        elif product == 'SA' or product == 'NSA':
            scf_variables = module.tl.cu_scf_variables
        else:
            scf_variables = module.tl.scf_variables
        return scf_variables
    except BaseException:
        return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-b', '--branch',
                        nargs="*", default=[],
                        help='List of branches')
    args = parser.parse_args()
    list_of_branches = (args.branch)
    generate_all_scfs(list_of_branches)
