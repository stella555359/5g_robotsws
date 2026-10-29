import yaml
import sys


def parse_yaml(file_name, duplex="", FH_mode="", RF_mode="", RU_type="", gNB_common_unit="", gNB_capacity_unit=""):
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
            for item in test["configs"]:
                if all(item.get(key, None) == val for key, val in keys_values.items()):
                    return dict((item['paths']))
                if any(item.get("gNB_common_unit", None) == "ASOE" for key, val in keys_values.items()):
                    return dict((item['paths']))
        except yaml.YAMLError as exc:
            print(exc)


def print_parser(file_name, duplex="", FH_mode="", RF_mode="", RU_type="", gNB_common_unit="", gNB_capacity_unit=""):
    """
    Ex: parse_yaml("config.yaml", "FDD", "CPRI", "cmwv", "AEQA", "ASIK", "ABIL")
    """
    for key, value in parse_yaml(file_name, duplex, FH_mode, RF_mode, RU_type,
                                 gNB_common_unit, gNB_capacity_unit).items():
        print(key + "=" + str(value))


if __name__ == "__main__":
    print_parser(*sys.argv[1:])
