import yaml
import sys
import re


def validate_str_or_list_instance(key, val):
    if isinstance(val, str) or isinstance(val, unicode):
        value = val.strip("[").strip("]").strip("\"[").strip("]\"").strip("'[").strip("]'")
        return re.split(",\\s*", value)
    else:
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
        if (key == "gNB_capacity_unit" or key == "AP_capacity_unit"):
            keys_values[key] = validate_str_or_list_instance(key, val)
    with open(file_name, 'r') as stream:
        try:
            test = yaml.safe_load(stream)
            for item in test["configs"]:
                config_found = True
                for key, val in keys_values.items():
                    config_value = item.get(key, None)
                    if (key == "gNB_capacity_unit" or key == "AP_capacity_unit"):
                        config_value = validate_str_or_list_instance(key, config_value)
                    if config_value != val:
                        config_found = False
                        break
                if config_found:
                    return dict((item['paths']))

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
    print_parser(*sys.argv[1:])
