
import difflib
import traceback
import json
import os
import pathlib

from robot.libraries.BuiltIn import BuiltIn
import taf.ul.hanging_resources as resources
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_log_collection

resources_obj = resources.hanging_resources()
rbi = BuiltIn()


def get_resources_usage(node_id=0, node_type='gnb', detailed=False, label='default', subfolder=''):
    try:
        result_test_dir = rbi.get_variable_value("${P_resultTestDir}", '/tmp')
        os.makedirs(f"{result_test_dir}/{subfolder}", exist_ok=True)

        var_name = f"resources_usage_{label}"
        filepath = f"{result_test_dir}/{subfolder}/{var_name}.json"
        usage = resources_obj.get_resources_usage(
            node_id=node_id, node_type=node_type, detailed=detailed, filename=None)
        with open(filepath, 'w+', encoding='utf-8') as fstream:
            usage_json = json.dumps(usage, indent=4)
            fstream.write(usage_json)
        rbi.set_test_variable("${}{}{}".format('{', var_name, '}'), usage)
        rbi.set_test_variable("${}{}_json{}".format('{', var_name, '}'), usage_json)

        perf_log_collection.queue_logs_to_turandot(filepath, subfolder=subfolder,
                                                   archive_name=var_name)
        return usage
    except Exception as e:
        rbi.log(
            f"failed: get_resources_usage {label}, e={e}\n{traceback.format_exc()}", level='WARN')


def add_exclude_resources(exclude_list):
    if len(exclude_list.split(',')) > 0:
        rbi.log("Resource Usage Exclude:", level='WARN')
    for resource in exclude_list.split(','):
        resources_obj.configure_default_excluding_resource_paths(add=resource)


def verify_resource_usage(resource1, resource2, label='default', subfolder=''):
    result_test_dir = rbi.get_variable_value("${P_resultTestDir}", '/tmp')

    diff = resources_obj.resources_should_be_equal(resource1, resource2, exclude=None)
    filepath = f"{result_test_dir}/{subfolder}/resources_diff_{label}.json"
    with open(filepath, 'w+', encoding='utf-8') as fstream:
        diff_json = json.dumps(diff, indent=4)
        fstream.write(diff_json)


def generate_diff(resource1, resource2, n=0, subfolder='', label='default'):
    try:
        str1 = rbi.get_variable_value("${}resources_usage_{}_json{}".format('{', resource1, '}'), None)
        str2 = rbi.get_variable_value("${}resources_usage_{}_json{}".format('{', resource2, '}'), None)
        diff = ''
        # diff_obj = difflib.unified_diff(
        diff_obj = difflib.context_diff(
            str1.strip().splitlines(),
            str2.strip().splitlines(),
            tofile=resource2,
            fromfile=resource1,
            lineterm='',
            n=n
        )
        for line in diff_obj:
            diff = f"{diff}{line}\n"
        result_test_dir = rbi.get_variable_value("${P_resultTestDir}", None)
        filepath = f"{result_test_dir}/{subfolder}/resources_diff2_{label}.json"
        os.makedirs(f"{result_test_dir}/{subfolder}", exist_ok=True)
        with open(filepath, 'w+', encoding='utf-8') as fstream:
            diff_json = json.dumps(diff, indent=4)
            fstream.write(diff_json)

        perf_log_collection.queue_logs_to_turandot(filepath, subfolder=subfolder, archive_name='resources_usage')
    except Exception as e:
        rbi.log(f"failed: generate_diff {label}, e={e}\n{traceback.format_exc()}", level='WARN')


def check_nbOfActiveUEs(expected_nb_of_active_ues=0, label='default', subfolder=''):
    rbi.log(f"========== start: check_nbOfActiveUEs({label}) ==========")
    result_test_dir = rbi.get_variable_value("${P_resultTestDir}", None)
    resources_usage_file = f"{result_test_dir}/{subfolder}/resources_usage_{label}.json"
    if not pathlib.Path(resources_usage_file).is_file():
        rbi.fail("nbOfActiveUEs: resources usage file not found")
    with open(resources_usage_file, 'r', encoding='utf-8') as json_target:
        resources_usage_obj = json.loads(json_target.read())
    errors = []
    for l2ps_info_i, l2ps_info in enumerate(resources_usage_obj['CPRT']['l2resource']['l2psList']['l2psInfo']):
        for cell_group_resources_i, cell_group_resources in enumerate(l2ps_info['cellGroupResources']):
            for nb_ues_and_bearers in ['ulNbUesAndBearers', 'dlNbUesAndBearers']:
                nb_of_active_ues = cell_group_resources[nb_ues_and_bearers]['nbOfActiveUEs']
                path = f"l2resource/l2psList/l2psInfo[{l2ps_info_i}]"
                path = f"{path}/cellGroupResources[{cell_group_resources_i}]/{nb_ues_and_bearers}/nbOfActiveUEs"
                if int(nb_of_active_ues) != int(expected_nb_of_active_ues):
                    errors.append(f"[FAIL] nbOfActiveUEs: {nb_of_active_ues}\n    - {path}")
                else:
                    rbi.log(f"[PASS] {path}")
    if len(errors) > 0:
        rbi.fail('\n'.join(errors))
    rbi.log(f"========== end: check_nbOfActiveUEs({label}) ==========")
