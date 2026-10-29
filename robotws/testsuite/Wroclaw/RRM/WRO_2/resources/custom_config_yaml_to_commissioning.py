from robot.libraries.BuiltIn import BuiltIn
import yaml
from yaml.loader import SafeLoader
import shutil

CC_YAML_PATH = "/home/ute/test_repository/custom-config/Wroclaw"
CC_PATH = "/home/ute/test_repository/custom-config/"
org_basic_cfg_path = "/opt/wts/latest/basic_setup.cfg"
org_basic_cfg_path_bk = "/opt/wts/latest/basic_setup.cfg_bk"


def get_filepaths_from_custom_config_yaml():
    with open(BuiltIn().get_variable_value('${SUITE_SOURCE}'), 'r') as f:
        for line in f:
            if "CONFIGS_Wroclaw" in line:
                yaml_file = "{}{}".format(CC_YAML_PATH,
                                          line[line.find("CONFIGS_Wroclaw")+len("CONFIGS_Wroclaw"):].lstrip())
    with open(yaml_file.strip()) as f:
        swconfig_path = scfc_path = iphy_path = None
        data = yaml.load(f, Loader=SafeLoader)
        for node in data['nodes']:
            for file in node['files']:
                if file["file_type"] == 'scfc':
                    scfc_path = "{}{}".format(CC_PATH, file["file_path"])
                if file["file_type"] == 'iphy_xml':
                    iphy_path = "{}{}".format(CC_PATH, file["file_path"])
                if file["file_type"] == 'wts_cfg':
                    new_cfg_path = "{}{}".format(CC_PATH, file["file_path"])
                    shutil.copyfile(org_basic_cfg_path, org_basic_cfg_path_bk)
                    shutil.copyfile(new_cfg_path, org_basic_cfg_path)
                if file["file_type"] == 'swconfig':
                    swconfig_path = "{}{}".format(CC_PATH, file["file_path"])

    return scfc_path, iphy_path, swconfig_path
