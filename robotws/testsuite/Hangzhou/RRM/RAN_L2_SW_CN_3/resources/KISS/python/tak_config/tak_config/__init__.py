# -*- coding: utf-8 -*-
"""
:created on: 21-03-2017

:copyright: Nokia
:author: leo
:contact: leo.y.wang@nokia.com
"""
from .interface import test_log_directory, kiss_debug_log_directory, configuration, TA_CONFIG, PA, UE
from ute_testline_configuration.loader import Loader
import logging
import traceback
from robot.libraries.BuiltIn import BuiltIn


USAGE = """\n\n--------------------------- REMINDER!!!---------------------------------------
When you use ta-kiss-config variable, please make sure the testline is correctly configured
under /home/ute/robotlte/config/site-name/testline-name/__init_.py,
eg: site-name is "Shanghai" etc.
    testline-name is "IAV-SHTA-TL100" etc.

About how to define the __init__.py, please refer to:
http://doc.ute.nsn-rdnet.net/packages/ute_testline_configuration/interfaces/ute_testline_configuration.html
#general-rules
------------------------------------------------------------------------------
"""


try:
    tl_obj = BuiltIn().get_variable_value("${tl}")
    if not tl_obj:
        loader = Loader()
        module_name = "{}".format(configuration("/home/ute/testline_configuration/"))
        if module_name and module_name[0] == ".":
            tl = BuiltIn().import_variables(module_name[1:])
        else:
            config_module = loader.load_config_module(module_name)
            tl = loader.import_tl_config(config_module)
        ta_kiss_config = tl
except Exception as e:
    logging.warn(traceback.format_exc())
    logging.info(USAGE)
