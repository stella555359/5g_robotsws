# -*- coding: utf-8 -*-
import logging
import os
import yaml
from robot.libraries.BuiltIn import BuiltIn


def load_ue_config(tl):
    for ue in tl.ues:
        if 'UE_POOLS' in ue:
            logging.info("UE_POOLS is %s." % ue)
            tl_ue_config = ue
    if tl_ue_config is not None:
        return tl_ue_config

    if hasattr(tl, "ue_config"):
        return tl.ue_config

    config = BuiltIn().get_variable_value("${CONFIGURATION}")
    logging.debug("${CONFIGURATION}", config)
    if config is None:
        return None

    testline = config.split("/")[-1]
    testline_dir = ""
    if os.path.exists(os.path.join("/home/ute/Auto5G/config", testline)):
        testline_dir = os.path.join("/home/ute/Auto5G/config", testline)
    elif os.path.exists(os.path.join("/home/ute/testline_configuration", testline)):
        testline_dir = os.path.join("/home/ute/testline_configuration", testline)
    elif os.path.exists(os.path.join("/home/ute/testline_configuration_5G", testline)):
        testline_dir = os.path.join("/home/ute/testline_configuration_5G", testline)
    else:
        return None

    ue_yaml = os.path.join(testline_dir, "ue_config.yaml")
    if not os.path.exists(ue_yaml):
        return None

    with open(ue_yaml) as ta_ue_config:
        ue_config = yaml.safe_load(ta_ue_config)

    os.environ["ABSTRACT_LIB_CONFIG"] = testline_dir

    return ue_config
