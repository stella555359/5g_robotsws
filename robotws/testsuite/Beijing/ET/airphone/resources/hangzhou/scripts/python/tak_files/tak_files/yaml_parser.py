import yaml
import sys


def parse_yaml(file_name, **kwargs):
    """
    This function takes parameters as defined in argument list
    and parses config.yaml file given in argument
    and returns a dictionary with list of files from config.yaml based on config params passed.
    """
    keys_values = (locals())
    del keys_values['file_name']
    with open(file_name, 'r') as stream:
        try:
            test = yaml.safe_load(stream)
            keys_values = keys_values['kwargs']
            for item in test["configs"]:
                gNB_capacity_unit_config = item.get("gNB_capacity_unit")
                gNB_capacity_unit_param = keys_values.get("gNB_capacity_unit")

                if isinstance(gNB_capacity_unit_config, str):
                    gNB_capacity_unit_config = gNB_capacity_unit_config.split(" ")

                if isinstance(gNB_capacity_unit_config, list):
                    gNB_capacity_unit_config = gNB_capacity_unit_config

                gNB_capacity_unit_param = replace_parameters_based_config(gNB_capacity_unit_param,
                                                                          gNB_capacity_unit_config)

                if gNB_capacity_unit_config == gNB_capacity_unit_param:
                    ret_list = []
                    for key, val in keys_values.items():
                        ret = False
                        if key == "gNB_capacity_unit":
                            continue
                        if item.get(key, None) == val or val in item.get(key, None):
                            ret = True
                        ret_list.append(ret)
                    if all(ret_list):
                        return dict((item['paths']))
        except yaml.YAMLError as exc:
            print(exc)


def replace_parameters_based_config(gNB_capacity_unit_param, gNB_capacity_unit_config):
    """
      This function replace gNB_capacity_unit_param based on the gNB_capacity_unit_config
      and returns replaced gNB_capacity_unit_param.
      """
    flag = \
        [True if band_type in gNB_capacity_unit_param else False for band_type in gNB_capacity_unit_config]
    if all(flag):
        config_length = len(gNB_capacity_unit_config)
        if config_length == 3:
            gNB_capacity_unit_param = gNB_capacity_unit_param[0:3]
        if config_length == 2:
            gNB_capacity_unit_param = gNB_capacity_unit_param[0:2]
        if config_length == 1:
            gNB_capacity_unit_param = [gNB_capacity_unit_param[0]]
    return gNB_capacity_unit_param


def print_parser(file_name, duplex="", FH_mode="", RF_mode="", RU_type="", gNB_common_unit="", gNB_capacity_unit=""):
    """
    Ex: parse_yaml("config.yaml", "FDD", "CPRI", "cmwv", "AEQA", "ASIK", "ABIL")
    """
    for key, value in parse_yaml(file_name, duplex, FH_mode, RF_mode, RU_type,
                                 gNB_common_unit, gNB_capacity_unit).items():
        print(key + "=" + str(value))


if __name__ == "__main__":
    print_parser(*sys.argv[1:])
