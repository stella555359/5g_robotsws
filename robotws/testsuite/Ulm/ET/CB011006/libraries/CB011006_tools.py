# ====================================================================================================[120 characters]
# This is a Python File, which helps to implement the Private Robot Keywords used in Sqd68 for CB011006 Feature
# Team: 'SqdGp68'
# Email: 'I_MN_5GSC_SW_ENG_ULM_SQD_68@internal.nsn.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import logging
import xml.etree.ElementTree as ET
import json

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
import pandas as pd

from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]
rbi = BuiltIn()

# ====================================================================================================[120 characters]
#   Keywords
# ====================================================================================================[120 characters]


@log_begin_end_func_name
def get_values_from_targetbd(targetbd_path, radio_name='AHEGHA'):
    tree_targetbd = ET.parse(targetbd_path)
    logging.info("tree_targetbd = %s" % tree_targetbd)
    root_targetbd = tree_targetbd.getroot()
    logging.info("root_targetbd = %s" % root_targetbd)
    target_bd_values = {}

    desired_element = root_targetbd.find('.//hwResource[@resourceBuildKey="LTX_%s"]' % radio_name)
    logging.info("desired_element = %s" % desired_element)
    target_bd_values['resourceSWVersion'] = desired_element.attrib['resourceSWVersion']
    for grandchild in desired_element:
        if grandchild.tag == 'swFileKey':
            target_bd_values['swFileKey'] = grandchild.text.replace("LTX_%s_" % radio_name, "")
    logging.info("target_bd_values = %s" % target_bd_values)
    return (target_bd_values['resourceSWVersion'], target_bd_values['swFileKey'])


@log_begin_end_func_name
def load_pmc_dataframe():
    pmc_csv_file = rbi.get_variable_value("${pm_counters_dir}") + "pmCounters.csv"
    df = pd.read_csv(pmc_csv_file, sep=";")
    # df = df.reset_index(drop=True)

    return df


@log_begin_end_func_name
def load_tput_dict():
    pm_counters_dir = rbi.get_variable_value("${pm_counters_dir}")
    tput_file_path = pm_counters_dir + "pmc_average_tp_per_scenario_per_cell.json"

    with open(tput_file_path, 'r') as f:
        tput_dict = json.load(f)

    return tput_dict


# ====================================================================================================[120 characters]
def log_exception(functionNameStr, e, silent=False):
    logging.info("%s(): Exception = <%s>" % (functionNameStr, str(e)))
    if not silent:
        rbi.log_to_console("" + RED + "  %s: exception happend (see log.html)" % functionNameStr + RESET + "")
