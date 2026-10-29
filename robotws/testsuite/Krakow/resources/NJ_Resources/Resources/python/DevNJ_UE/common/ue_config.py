# -*- coding: utf-8 -*-
import os
import yaml
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


class UeYamlConfiguration(object):
    def __init__(self):
        self.ue_config = UeYamlConfiguration._load_ue_config_file()
        logger.info(self.ue_config)

    @staticmethod
    def _load_ue_config_file():
        ue_config_in_tl = BuiltIn().get_variable_value("${ue_config}")

        if ue_config_in_tl is not None:
            return ue_config_in_tl

        tl = BuiltIn().get_variable_value("${tl}")
        if hasattr(tl, "ue_config"):
            return tl.ue_config

        config_in_cmd = BuiltIn().get_variable_value("${CONFIGURATION}")
        if config_in_cmd is None:
            logger.info("Please config ue_config.yaml info in __init__.py or "
                        "give CONFIGURATION input in robot cmd line, such as: "
                        "-v CONFIGURATION:/home/ute/testline_configuration/7_21_UTE5G031TL072")
            return None

        testline = config_in_cmd.split("/")[-1]
        testline_dir = ""
        if os.path.exists(os.path.join("/home/ute/Auto5G/config", testline)):
            testline_dir = os.path.join("/home/ute/Auto5G/config", testline)
        elif os.path.exists(os.path.join("/home/ute/testline_configuration", testline)):
            testline_dir = os.path.join("/home/ute/testline_configuration", testline)
        elif os.path.exists(os.path.join("/home/ute/testline_configuration_5G", testline)):
            testline_dir = os.path.join("/home/ute/testline_configuration_5G", testline)
        else:
            logger.info("Please config there is your testline in: /home/ute/Auto5G/config or"
                        "/home/ute/testline_configuration or /home/ute/testline_configuration_5G")
            return None

        ue_yaml = os.path.join(testline_dir, "ue_config.yaml")
        if not os.path.exists(ue_yaml):
            logger.info("Please config ue_config.yaml info in __init__.py or "
                        "give CONFIGURATION input in robot cmd line, such as: "
                        "-v CONFIGURATION:/home/ute/testline_configuration/7_21_UTE5G031TL072")
            return None

        with open(ue_yaml) as ta_ue_config:
            ue_config = yaml.safe_load(ta_ue_config)

        os.environ["ABSTRACT_LIB_CONFIG"] = testline_dir

        return ue_config

    def setup_ue_variables(self):
        # ue_config = self._load_ue_config_file()
        # with open("/home/ute/ue_config.json", "w+") as f:
        #     json.dump(self.ue_config, f)

        ue_info_dict = self.ue_config.get("UE_POOLS").get("AndroidUePool").get("inline_config")
        return ue_info_dict

    def ue_num(self):
        ue_info_dict = self.setup_ue_variables()
        return len(ue_info_dict.keys())

    def ue_capabilities(self, ue_index):
        ue_info_dict = self.setup_ue_variables()
        return ue_info_dict.get("UE_{}".format(ue_index)).get("CAPABILITIES")

    def ue_constructor_parameters(self, ue_index):
        ue_info_dict = self.setup_ue_variables()
        return ue_info_dict.get("UE_{}".format(ue_index)).get("CONSTRUCTOR_PARAMETERS")
