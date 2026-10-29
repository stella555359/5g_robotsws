import yaml
import sys
import re
import os
import copy
AGENT_CONFIG_FILE = "config.yaml"
SPECIAL_KEYS = ["gNB_common_unit", "gNB_capacity_unit", "AP_capacity_unit", "RU_type"]


def get_value_from_list(val):
    value = val.strip("[").strip("]").strip("\"[").strip("]\"").strip("'[").strip("]'")
    value = value.replace("\'", "").replace("\"", "")
    return re.split(",\\s*", value)


def validate_str_or_list_instance(key, val):
    if sys.version_info[0] > 2:
        if isinstance(val, str):
            return get_value_from_list(val)
    else:
        if isinstance(val, str) or isinstance(val, unicode):
            return get_value_from_list(val)
    return val


def parse_yaml(file_name, duplex="", FH_mode="", RF_mode="", RU_type="",
               gNB_common_unit="", gNB_capacity_unit="", AP_common_unit="", AP_capacity_unit="",
               component_carrier=1):
    """
    This function takes parameters as defined in argument list
    and parses config.yaml file given in argument
    and returns a dictionary with list of files from config.yaml based on config params passed.
    """
    keys_values = (locals())
    del keys_values['file_name']
    for key, val in keys_values.items():
        if (key == "gNB_capacity_unit" and val == "[]"):
            keys_values[key] = []
        elif (key in SPECIAL_KEYS):
            keys_values[key] = validate_str_or_list_instance(key, val)
    with open(file_name, 'r') as stream:
        try:
            test = yaml.safe_load(stream)
            for item in test["configs"]:
                config_found = True
                for key, val in keys_values.items():
                    config_value = item.get(key, None)
                    if (key in SPECIAL_KEYS):
                        config_value = validate_str_or_list_instance(key, config_value)
                    if config_value != val:
                        config_found = False
                        break
                if config_found:
                    return dict((item['paths']))

        except yaml.YAMLError as exc:
            print(exc)


def get_file_paths(varients):
    sm_files_list, sim_files_list, vm_files_list = list(), list(), list()
    for each_node_id in varients['nodes']:
        for each_file in each_node_id['files']:
            if each_file['hw_type'] == 'sm':
                sm_files_list.append(each_file['file_path'])
            elif each_file['hw_type'] == 'sim':
                sim_files_list.append(each_file['file_path'])
            elif each_file['hw_type'] == 'vm':
                vm_files_list.append(each_file['file_path'])
    print("sm_files_list=("+str(" ".join(str(x) for x in sm_files_list)) + ")")
    print("sim_files_list=("+str(" ".join(str(x) for x in sim_files_list)) + ")")
    print("vm_files_list=("+str(" ".join(str(x) for x in vm_files_list)) + ")")
    return vm_files_list


def create_custom_yaml_file(matched_yaml):
    with open(AGENT_CONFIG_FILE, 'w') as outfile:
        yaml.dump(matched_yaml, outfile, default_flow_style=False, sort_keys=False)


def update_yaml_structure(yaml_data, variant_name):
    if variant_name is None:
        for each_varient in range(len(yaml_data['variants'])):
            if yaml_data['variants'][each_varient]['default'] is True:
                variant_name = yaml_data['variants'][each_varient]['name']
    if variant_name is None:
        return yaml_data

    for each_varient in range(len(yaml_data['variants'])):
        if yaml_data['variants'][each_varient]['name'] == variant_name.strip():
            yaml_data['variants'][each_varient]['default'] = True
        else:
            yaml_data['variants'][each_varient]['default'] = False

    """
    Currently agent-sim is supporting only one structure in config.yaml
    """
    yaml_data_filtered = copy.deepcopy(yaml_data)
    for each_varient in range(len(yaml_data['variants'])):
        if yaml_data['variants'][each_varient]['name'] != variant_name.strip():
            yaml_data_filtered['variants'].pop(each_varient)
    return yaml_data_filtered


def print_yaml_config(file_name, variant_name=None):
    """
    Ex: print_yaml_config("config.yaml", "4G5G_Combo")
    Ex: print_yaml_config("config.yaml")
    """
    with open(file_name, 'r') as stream:
        try:
            files_list = None
            yaml_data = yaml.load(stream, Loader=yaml.FullLoader)
            yaml_data = update_yaml_structure(yaml_data, variant_name)
            for each_varient in yaml_data['variants']:
                if variant_name and each_varient['name'] == variant_name.strip():
                    files_list = get_file_paths(each_varient)
                elif (variant_name is None) and (each_varient['default'] is True):
                    files_list = get_file_paths(each_varient)

            if not files_list:
                raise Exception("No matching config found with varient name and no config is set default:true")
            create_custom_yaml_file(yaml_data)
            return files_list
        except yaml.YAMLError as exc:
            print(exc)


def print_parser(file_name, duplex="", FH_mode="", RF_mode="", RU_type="",
                 gNB_common_unit="", gNB_capacity_unit="", AP_common_unit="", AP_capacity_unit="",
                 component_carrier=1):
    """
    Ex: parse_yaml("config.yaml", "FDD", "CPRI", "cmwv", "AEQA", "ASIK", "ABIL", "ASIK", "ABIL", "1")
    Ex: parse_yaml("config.yaml", "FDD", "CPRI", "cmwv", "AEQA", "ASIK", "[ABIL]", "ASIK", "[ABIL]", "1")
    Ex: parse_yaml("config.yaml", "FDD", "CPRI", "cmwv", "AEQA", "ASIK", ['ABIL','ABIL'], "ASIK", ['ABIL','ABIL'], "1")
    """
    for key, value in parse_yaml(file_name, duplex, FH_mode, RF_mode, RU_type,
                                 gNB_common_unit, gNB_capacity_unit, AP_common_unit, AP_capacity_unit,
                                 int(component_carrier)).items():
        print(key + "=" + str(value))


if __name__ == "__main__":
    if len(sys.argv) == 2 or len(sys.argv) == 3:
        print_yaml_config(*sys.argv[1:])
    else:
        print_parser(*sys.argv[1:])
