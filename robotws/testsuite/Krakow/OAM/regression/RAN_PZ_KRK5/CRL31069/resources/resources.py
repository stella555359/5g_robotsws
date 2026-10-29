import os
import re
import zipfile
import xml.etree.ElementTree as ET
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.utilities.logger.custom_logger import log_info_to_console
from taf.rfrl.bts.devices.exceptions import AsirOperationFailed
from taf.sbts.oam.coam.admin.exceptions import IncorrectParameterValue, DataNotAvailable
from taf.rfrl.utilities.robot.general import get_builtin_value


def generate_delta_file_to_check(dist_name, parameter,  param_value):
    return {
        dist_name: {
            parameter: param_value
        }
    }


def generate_delta_file_to_update(dist_name, parameter,  param_value):
    return [
        {
            "distName": dist_name,
            "operation": "update",
            "parameters": [
                {
                    "parameterName": parameter,
                    "value": param_value,
                    "operation": "update"
                }
            ]
        }
    ]


def iterate_through_list_in_dictionary(list, dicti, parameter):
    for element in range(len(list)):
        dicti[parameter] = list[element]
    return dicti


def generate_delta_file_for_list_of_parameters(list_of_parameters):
    delta_file = list()
    for parameter in list_of_parameters:

        delta_file.append(
            {
                "distName": parameter["dist_name"],
                "operation": parameter["operation"],
                "parameters": [
                    {
                        "parameterName": parameter["param_name"],
                        "value": parameter["value"],
                        "operation": parameter["operation"],
                    }
                ]
            }
        )
    return delta_file


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def get_ids_from_cell_list(cell):
    return cell[cell.index('-') + 1:]


def prepare_ru_id_for_checking_ip(ru_id):
    return int(ru_id) - 1


def unpack_given_log_hub_from_snapshot(snapshot_path, file_name):
    path_to_unzip = '/'.join(snapshot_path.split('/')[:-1]) + '/'
    if os.path.isfile(snapshot_path):
        with zipfile.ZipFile(snapshot_path) as zip_file:
            for file in zip_file.namelist():
                filename = os.path.basename(file)
                if file_name in filename:
                    return zip_file.extract(file, path_to_unzip)
    else:
        raise Exception("The given zip file doesn't exist. Please check the path: %s" % len(snapshot_path))


def change_and_activate_asirhub_parameter(dn, name, value):
    gnb_asir_hub = GnbAsirHubOperations()
    if gnb_asir_hub.get_staged_delta_plans():
        log_info_to_console('Update Plan')
        delta_plan_id = gnb_asir_hub.get_staged_delta_plans()[0]['eid']
    else:
        log_info_to_console('Create Plan')
        delta_plan_id = gnb_asir_hub.create_new_delta_plan(source_plan='active')['eid']

    try:
        log_info_to_console('Create Value')
        gnb_asir_hub.update_parameter_of_delta_plan(delta_plan_id=delta_plan_id,
                                                    operation='create',
                                                    dn=dn,
                                                    name=name,
                                                    value=value)
        gnb_asir_hub.activate_delta_plan(delta_plan_id=delta_plan_id)
        gnb_asir_hub.delete_delta_plan(delta_plan_id=delta_plan_id)
    except AsirOperationFailed:
        try:
            log_info_to_console('Update Value')
            gnb_asir_hub.update_parameter_of_delta_plan(delta_plan_id=delta_plan_id,
                                                        operation='update',
                                                        dn=dn,
                                                        name=name,
                                                        value=value)
            gnb_asir_hub.activate_delta_plan(delta_plan_id=delta_plan_id)
            gnb_asir_hub.delete_delta_plan(delta_plan_id=delta_plan_id)
        except AsirOperationFailed as exception:
            raise exception


def verify_asirhub_parameter(dist_name, parameter, expected_value):
    value = get_asirhub_parameter(dist_name, parameter)
    if value != expected_value:
        raise IncorrectParameterValue("Parameter '{}' should be '{}' but is '{}'".format(parameter, expected_value,
                                                                                         value))


def get_asirhub_parameter(dist_name, parameter):
    gnb_asir_hub = GnbAsirHubOperations()
    gnb_asir_hub.get_current_scf_file(local_dir_path='/tmp', file_name='temp_asir_scf.xml')
    asir_scf = ET.parse("/tmp/temp_asir_scf.xml")

    if asir_scf.find(".//*[@distName='{}']".format(dist_name)) is not None:
        obj = asir_scf.find(".//*[@distName='{}']".format(dist_name))
        if obj.find(".//*[@name='{}']".format(parameter)) is not None:
            log_info_to_console(asir_scf.find(".//*[@name='{}']".format(parameter)))
            return asir_scf.find(".//*[@name='{}']".format(parameter)).text
        else:
            raise DataNotAvailable(
                "Parameter '{}' doesn't exist in ASiR configuration, check if parameter name is"
                " correct".format(parameter))
    else:
        raise DataNotAvailable(
            "Parameter '{}' doesn't exist in ASiR configuration, check if parameter name is correct".format(parameter))


def change_asirhub_parameter_for_band_25(dict_of_parameters_to_change, path_to_xml):
    asir_scf = ET.parse(
        "".format(path_to_xml))
    dist = asir_scf.find(".//*[@distName='{}']".format("ASI-1/BTS-1"))
    for key, value in dict_of_parameters_to_change.items():
        dist_name = key
        parameter = value
        dist = asir_scf.find(".//*[@distName='{}']".format(dist_name))
        if dist is not None:
            for i in dist:
                if i.tag.__contains__("list"):
                    if i.find("*").text == "ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-1" or i.find(
                            "*").text == "ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-2":
                        i.find("*").text = "{}".format(parameter)
                    else:
                        raise Exception(
                            "Parameter ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-1 or ASI-1/ANTMODPR-1/ANTRFSMPR-2"
                            "/ANTANTLPR-2 doesn't exist in ASiR configuration, check if parameter name is correct")
        else:
            raise Exception(
                "Parameter '{}' doesn't exist in ASiR configuration, check if parameter name is correct".format(
                    parameter))
    asir_scf.write("output2.xml")


def get_allowed_alarms(custom_alarms=None):
    from common_variable import DEFAULT_ALARMS
    allowed_alarms = DEFAULT_ALARMS
    if custom_alarms and allowed_alarms:
        for custom_alarm in custom_alarms:
            if custom_alarm not in allowed_alarms:
                allowed_alarms.append(custom_alarm)
    return allowed_alarms


def check_scout_scf_id_is_present():
    debug_file_path = os.path.join(get_builtin_value('OUTPUT_DIR'), "debug.log")
    scout_scf_id_pattern = r'\-\s+INFO\s+-\s+SCOUT_SCF_ID\:\s\d+'
    test_start_pattern = r'\-\s+INFO\s+-\s+\+\-\s+START\sTEST'
    with open(debug_file_path, 'r') as debug_file:
        file_content = debug_file.read()
        nr_of_tests = len(re.findall(test_start_pattern, file_content))
        scout_scf_ids = len(re.findall(scout_scf_id_pattern, file_content))
        if int(nr_of_tests) != int(scout_scf_ids):
            log_info_to_console("Not all tests get SCOUT_SCF_ID, verify it in debug.log")
