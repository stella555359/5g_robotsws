from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from robot.libraries.BuiltIn import BuiltIn as robot
import os
import subprocess

CA_AGENT_LOGS_PATH = os.path.abspath(os.path.sep.join(
    [os.sep, 'home', 'ute', 'testline_init_results', 'agent.log']))


def get_tl_variant():
    variant = get_testline_variant_from_agent_log()
    if variant is not None:
        return "VARIANT_{}".format(variant)
    return variant


def get_testline_variant_from_agent_log():
    result = None
    if os.path.exists(CA_AGENT_LOGS_PATH):
        cat_process = subprocess.Popen(["cat", CA_AGENT_LOGS_PATH], stdout=subprocess.PIPE)
        grep_process = subprocess.Popen(["grep", "VARIANT"], stdin=cat_process.stdout, stdout=subprocess.PIPE)
        sed_process = subprocess.Popen(["sed", r's/.*VARIANT\s*:\s*//g'],
                                       stdin=grep_process.stdout, stdout=subprocess.PIPE)
        cat_process.stdout.close()
        grep_process.stdout.close()
        result = sed_process.communicate()[0].strip().decode("utf-8")
    return result


# common variables
mrbts_id = str(tl.gnbs[0].instance_id)
nrbts_id = str(tl.gnbs[0].global_bts_id)
bts_prefix = "MRBTS-" + mrbts_id + "/NRBTS-" + nrbts_id
tl_variant = get_tl_variant()


# variables related to lte
x2_gnb_ip = robot().get_variable_value("${tl.gnbs[0].cu.x2c.v4[:-3]}")
x2_enb_ip = robot().get_variable_value("${tl.enbs[0].x2_link_addr.v4[:-3]}")
