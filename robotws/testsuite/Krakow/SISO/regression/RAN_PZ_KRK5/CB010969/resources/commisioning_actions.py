import time
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.exceptions import InvalidParameterValue
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.commissioning import perform_commissioning_on_gnb_to_onair_state
import xml.etree.ElementTree as ET
from taf.rfrl.procedures.resources.python.config_operations import ConfigOperations


def get_parameter_value_from_bts(params):
    obj = ConfigOperations()
    try:
        obj.connect(alias="al")
        for param in params:
            param['act_param_val'] = obj.get_parameter_value(dist_name=param['dist_name'], param_name=param['abbr'])
            logger.log_info_to_console(f"Getting {param['dist_name']} with value "
                                       f"{param['act_param_val']}", log_hierarchy=3)
    finally:
        obj.disconnect()
    return params


def get_runtime_parameter_value_from_bts(params, field="act_param_val"):
    gnb_du = GnbDuOperations()
    gnb_du.get_bts_configuration_file(filename="initial_configuration.xml", config_type="runtimeObjects")
    runtime_file = get_runtime_params_for_specific_class(config_path="/tmp/initial_configuration.xml",
                                                         class_name="com.nokia.srbts.eqmr:ASIRMOD_R")
    for param in params:
        logger.log_info_to_console(f"Getting {param['param_name']} value from gNB", log_hierarchy=3)

        param[field] = find_param_for_passing_distname(runtime_file, param["dist_name"], param["abbr"])
    return params


def find_param_for_passing_distname(param_list, dist_name, abbr):
    for param in param_list:
        if param["dist_name"] == dist_name:
            return param["params"][abbr]
    return None


def get_runtime_params_for_specific_class(config_path, class_name):
    with open(config_path, "r") as file:
        runtime_params = get_all_params_under_class_name(scf_file_content=file.read(),
                                                         class_name=class_name)

    return runtime_params


def get_all_params_under_class_name(scf_file_content, class_name):
    logger.log_info_to_console("XXX")
    scf_xml = ET.fromstring(scf_file_content)
    all_params = []
    all_classes = scf_xml.findall(".//*[@class='{}']".format(class_name))
    for class_item in all_classes:
        class_params = {}
        for param in class_item:
            if 'list' in param.tag:
                class_params[param.attrib['name']] = []
                item_results = []
                for item in param:
                    item_results.append(item.text)
                class_params[param.attrib['name']].append(item_results)
            else:
                class_params[param.attrib['name']] = param.text
        all_params.append({'dist_name': class_item.attrib['distName'], 'params': class_params})
    return all_params


def get_pmax_value_from_bts(params=None, cell_id=None):
    logger.log_info_to_console("Getting actual params value from gNB", log_hierarchy=2)
    gnb_cell = GnbCellOperations()
    if cell_id is None:
        for param in params:
            logger.log_info_to_console(f"Getting {param['param_name']} value from gNB", log_hierarchy=3)
            param["act_param_val"] = gnb_cell.get_pmax_value(cell_id=param["cell_id"])["value"]
        return params
    elif params is None:
        return gnb_cell.get_pmax_value(cell_id=cell_id)["value"]


def perform_parameter_recommisioning(params_to_change, value_name):
    logger.log_info_to_console("Changing parameters value", log_hierarchy=2)
    gnb_scf = GnbCommissioning()
    for param in params_to_change:
        logger.log_info_to_console(f"Changing parameter {param['param_name']} value to {int(param[value_name])}",
                                   log_hierarchy=3)
        gnb_scf.perform_configuration_parameter_recommissioning(dist_name=param["dist_name"],
                                                                parameter=param["abbr"],
                                                                operation="update", timeout=300,
                                                                value=param[value_name])


def verify_if_parameters_changed(params_to_change, value_name):
    for param in params_to_change:
        logger.log_info_to_console(f"Verifying param {param['param_name']} value", log_hierarchy=3)
        param_value = get_pmax_value_from_bts(cell_id=int(param["cell_id"]))
        if str(param_value) != str(param[value_name]):
            raise InvalidParameterValue(f"Value of param {param['abbr']} was not change.")


def verify_if_parameters_not_changed(params_to_change):
    for param in params_to_change:
        logger.log_info_to_console(f"Verifying param {param['param_name']} value", log_hierarchy=3)
        if param["act_param_val"] != param["new_param_val"]:
            raise InvalidParameterValue(f"Value of param {param['abbr']} was not change.")
        else:
            logger.log_info_to_console(f"Parameter {param['param_name']} not changed what is expected", log_hierarchy=4)


def perform_setup_reconfiguration(prefix_tag=None):
    perform_commissioning_on_gnb_to_onair_state(prefix_tag=prefix_tag, asir_hub=True)
