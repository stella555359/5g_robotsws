import os
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import (
    prepare_testline as tl_prepare,
)
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_rel_name
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_testline_name
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import (
    start_btslog_on_local_machine,
    teardown_btslog,
)

CA_AGENT_TOPOLOGY_CONFIGS_DIR = os.path.abspath(os.path.sep.join(
    [os.sep, 'home', 'ute', 'testline_init_results', 'execution', 'configs', 'topology_configs', 'node_1']))

SCF_TAG_TEMPLATE = "SCF_{}"

CONFIGURATIONS = {
    "HASTROTL77": {
        "SCF_DEFAULT": "scf_NR_9010.xml",
        "SCF_5935": "scf_NR_5935.xml",
        "SCF_NEUTRAL": "scf_NR_9010_neutral.xml",
    },
    "HASTROMUTANT3": {
        "SCF_DEFAULT": "scf_NR_LTE_GSM.xml",
        "SCF_90_15": "scf_NR_LTE_TDD_90_15.xml",
        "SCF_100_38": "scf_NR_LTE_TDD_100_38.xml",
        "SCF_100_30_15": "scf_NR_LTE_TDD_100_30_15.xml"
    }
}


def get_scf_location(filename, release):
    ca_agent_config = os.path.join(CA_AGENT_TOPOLOGY_CONFIGS_DIR, release, filename)
    logger.info(
        f"\nUsing scf from CA_AGENT dir: {filename}",
        also_console=True)
    return ca_agent_config


def get_scf_for_tag(tl_name, tag):
    sw_rel_name = get_rel_name(refresh=True)
    if tag:
        return get_scf_location(get_filename_for_tag(tl_name, tag), release=sw_rel_name)
    return get_scf_location(
        get_filename_for_tag(tl_name, SCF_TAG_TEMPLATE.format("DEFAULT")),
        release=sw_rel_name,
    )


def get_filename_for_tag(tl_name, tag):
    if tag in CONFIGURATIONS[tl_name]:
        logger.debug("\nSCF Filename found for tag: {}".format(tag))
        return CONFIGURATIONS[tl_name][tag]
    return CONFIGURATIONS[tl_name]


def prepare_testline_to_onair_state(scf_tag="SCF_DEFAULT", custom_swconfig_flags=None):
    BuiltIn().set_suite_variable("${TESTNAME}", "SuiteSetup")
    os.system("pkill btslog")
    start_btslog_on_local_machine()
    short_name, full_name = get_testline_name()
    path = get_scf_for_tag(short_name, scf_tag)
    try:
        tl_prepare(scf_path=path, custom_swconfig_flags=custom_swconfig_flags)
    finally:
        teardown_btslog()
    BuiltIn().set_suite_variable("${CURRENT_SCF}", scf_tag)
    logger.info("\nSelected SCF: {}".format(path), also_console=True)
    return path


def change_configuration_if_needed():
    tag = [tag for tag in get_robot_variable("${TEST TAGS}") if tag.startswith("SCF")]
    tag = tag[0] if tag else "SCF_DEFAULT"
    current_scf = get_robot_variable("${CURRENT_SCF}")
    if tag != current_scf:
        return prepare_testline_to_onair_state(scf_tag=tag)
    logger.info(
        "\nSCF tag for test is the same. Comissioning skipped!", also_console=True
    )


def change_variant_if_needed(force_change=False):
    tag = [tag for tag in get_robot_variable("${TEST TAGS}") if tag.startswith("VARIANT")]
    current_variant = get_robot_variable("${tl_variant}")
    if tag[0] != current_variant or force_change:
        swap_scf_to_other_variant(scf_tag=tag[0])
        return
    logger.info("\nSCF VARIANT tag for test is the same. Comissioning skipped!", also_console=True)


def swap_scf_to_other_variant(scf_tag="SCF_DEFAULT"):
    BuiltIn().set_suite_variable("${TESTNAME}", "SuiteSetup")
    os.system("pkill btslog")
    start_btslog_on_local_machine()
    path = os.path.join(CA_AGENT_TOPOLOGY_CONFIGS_DIR, scf_tag.removeprefix("VARIANT_"), 'scfc.xml')
    try:
        tl_prepare(scf_path=path)
    finally:
        teardown_btslog()
    BuiltIn().set_suite_variable("${tl_variant}", scf_tag)
    logger.info("\nSelected SCF: {}".format(path), also_console=True)
