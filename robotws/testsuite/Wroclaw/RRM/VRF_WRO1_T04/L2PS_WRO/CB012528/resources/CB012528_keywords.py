from robot.libraries.BuiltIn import BuiltIn
from bs4 import BeautifulSoup
import re
import csv
import os
import json

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    if direction == 'dl':
        stats_type = 'pdsch'
    else:
        stats_type = 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type={} scell={}'
                                                                       .format(ue_id, stats_type, cc),
                                                                       pass_regexp='UE-{}: NR {} Throughput'
                                                                       .format(ue_id, stats_type.upper()))


def get_avg_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(ue_stats)[-1][0]
    return float(avg_tput)


def get_core_id_from_tti(file_name, nrCellIdentity, direction):    # version 1 filename ->filepath ?
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        core_id = list({int(float(line["emCoreId"]))
                        for line in csv_reader
                        if line["emCoreId"] != ''
                        and line[direction+"MetricIndData.nrCellIdentity"].replace('.', '', 1).isdigit()
                        and float(line[direction+"MetricIndData.nrCellIdentity"]) == float(nrCellIdentity)})
        if len(core_id) == 1:
            return core_id[0]


def get_optimal_ratio_for_cell_tti(file_name, physCellId):
    with open(file_name) as csv_file:
        csv_reader = csv.DictReader(csv_file)
        currentOptimalRatio = list({float(line["dlLoadControlData.measurementInfo.currentOptimalRatio"])
                                    for line in csv_reader
                                    if line["dlLoadControlData.measurementInfo.currentOptimalRatio"] != ''
                                    and int(line["physCellId"]) == int(physCellId)})
        return currentOptimalRatio


def get_cell_id_list_based_on_subpool_id(dictionary, value):
    return [key for key, val in dictionary.items() if val == value]


def modify_vendor_file_content(file_path,
                               modified_file_name,
                               actTwoCoresL2DeploymentFddFr1,
                               maxNumScheUePdschL2Sp,
                               maxNumScheUePuschL2Sp):
    with open(file_path, 'r', encoding='utf-8') as file:
        vendor_content_raw = file.read()

    vendor_content_xml = BeautifulSoup(vendor_content_raw, 'xml')
    new_values = {'actTwoCoresL2DeploymentFddFr1': actTwoCoresL2DeploymentFddFr1,
                  'maxNumScheUePdschL2Sp': maxNumScheUePdschL2Sp,
                  'maxNumScheUePuschL2Sp': maxNumScheUePuschL2Sp}

    for param_name, param_value in new_values.items():
        parameter_elements = vendor_content_xml.find_all('p', attrs={'name': param_name})
        for element in parameter_elements:
            element.string = param_value

    output_path = os.path.join(os.path.dirname(file_path), modified_file_name)
    with open(output_path, 'w', encoding='utf-8') as output_file:
        output_file.write(str(vendor_content_xml))

    return vendor_content_xml


def update_scf_vlanid(file_path, vlanId):
    with open(file_path, 'r', encoding='utf-8') as file:
        scf_content_raw = file.read()

    scf_content_xml = BeautifulSoup(scf_content_raw, 'xml')
    new_values = {'vlanId': str(vlanId)}

    for param_name, param_value in new_values.items():
        parameter_elements = scf_content_xml.find_all('p', attrs={'name': param_name})
        for element in parameter_elements:
            element.string = param_value

    output_path = file_path

    with open(output_path, 'w', encoding='utf-8') as output_file:
        output_file.write(str(scf_content_xml))


def format_json_file(input_path, output_path):

    with open(input_path, 'r', encoding='utf-8') as file:
        original_json = json.load(file)

    formatted_json = json.dumps(original_json, separators=(',', ':'), indent=None)

    with open(output_path, 'w', encoding='utf-8') as output_file:
        output_file.write(formatted_json)


def modify_json_delta(input_path, output_path, cell_id):
    with open(input_path, 'r', encoding='utf-8') as file:
        json_content_raw = json.load(file)

    for object in json_content_raw:
        if 'parameters' in object:
            for param in object['parameters']:
                if 'parameterName' in param and param['parameterName'] == 'physCellId':
                    param['value'] = str(cell_id+49)
                if 'parameterName' in param and param['parameterName'] == 'lcrId':
                    param['value'] = str(cell_id)
                prachConfigurationIndex = 12+((cell_id - 1) // 3)
                if 'parameterName' in param and param['parameterName'] == 'prachConfigurationIndex':
                    param['value'] = str(prachConfigurationIndex)
                if 'parameterName' in param and param['parameterName'] == 'refNrCellGroup':
                    refNrCellGroup = param['value']
                    refNrCellGroup.append(str(cell_id-1))
                    param['value'] = refNrCellGroup
                if 'parameterName' in param and param['parameterName'] == 'nrCellList':
                    param['value'] = [str(cell_id)]

    json_string = json.dumps(json_content_raw, ensure_ascii=False, indent=0)
    json_string_mod = re.sub(r'NRCELL-\d*\d', 'NRCELL-'+str(cell_id), json_string)
    json_string_mod = re.sub(r'NRCELLGRP-\d*\d', 'NRCELLGRP-'+str(cell_id-1), json_string_mod)
    json_string_mod = re.sub(r'LCELNR-\d*\d', 'LCELNR-'+str(cell_id), json_string_mod)
    if cell_id % 3:
        rmod_id = str(cell_id % 3)
    else:
        rmod_id = '3'
    json_string_mod = re.sub(r'RMOD-\d*\d', 'RMOD-'+rmod_id, json_string_mod)

    json_content_raw = json.loads(json_string_mod)
    with open(output_path, 'w', encoding='utf-8') as output_file:
        json.dump(json_content_raw, output_file, ensure_ascii=False, indent=2)
