import os
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_testline_name
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.python_functions import get_scf_location, SCF_TAG_TEMPLATE
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VduSession import VduAdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VcuSession import VcuAdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_utilities import get_sw_release_vdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import wait_until_function_succeeds


CONFIGURATIONS = {
    "HASTROAIC01": {
        "SCF_DEFAULT": {"vdu": "scf_NR_vDU.xml", "vcu": "scf_NR_vCU.xml"},
        "SCF_6733": {"vdu": "scf_NR_6733_vDU.xml", "vcu": "scf_NR_6733_vCU.xml"},
        "SCF_6CC": {"vdu": "scf_NR_6CC_vDU.xml", "vcu": "scf_NR_6CC_vCU.xml"},
        "SCF_8152": {"vdu": "scf_NR_8152_vDU.xml", "vcu": "scf_NR_8152_vCU.xml"},
        "SCF_12219": {"vdu": "scf_NR_12219_vDU.xml", "vcu": "scf_NR_12219_vCU.xml"},
        "SCF_13438": {"vdu": "scf_NR_13438_vDU.xml", "vcu": "scf_NR_13438_vCU.xml"},
        "SCF_6449": {"vdu": "scf_NR_6449_vDU.xml", "vcu": "scf_NR_6449_vCU.xml"}
    },
    "HASTROAIC02": {
        "SCF_DEFAULT": {"vdu": "scf_NR_vDU.xml", "vcu": "scf_NR_vCU.xml"},
        "SCF_6733": {"vdu": "scf_NR_6733_vDU.xml", "vcu": "scf_NR_6733_vCU.xml"},
        "SCF_13438": {"vdu": "scf_NR_13438_vDU.xml", "vcu": "scf_NR_13438_vCU.xml"}
    }
}


def get_filename_for_tag(tl_name, tag, unit):
    if tag in CONFIGURATIONS[tl_name]:
        logger.debug("\nSCF Filename found for tag: {}".format(tag))
        return CONFIGURATIONS[tl_name][tag][unit]
    return CONFIGURATIONS[tl_name][unit]


def get_scf_for_tag(tl_name, tag, unit):
    sw_rel_name = get_sw_release_vdu()
    if tag:
        return get_scf_location(get_filename_for_tag(tl_name, tag, unit), release=sw_rel_name)
    return get_scf_location(
        get_filename_for_tag(tl_name, SCF_TAG_TEMPLATE.format("DEFAULT"), unit),
        release=sw_rel_name,
    )


def prepare_aic_testline_to_onair_state(scf_tag="SCF_DEFAULT"):
    BuiltIn().set_suite_variable("${TESTNAME}", "SuiteSetup")
    short_name, full_name = get_testline_name()
    vdu_filepath = get_scf_for_tag(short_name, scf_tag, 'vdu')
    vcu_filepath = get_scf_for_tag(short_name, scf_tag, 'vcu')

    perform_full_commissioning_on_vcu(vcu_filepath)
    perform_full_commissioning_on_vdu(vdu_filepath)
    wait_for_all_cells_onair()

    BuiltIn().set_suite_variable("${CURRENT_SCF}", scf_tag)
    logger.info("\n<< Selected SCFs >>\n-VDU: {}\n-VCU: {}".format(vdu_filepath, vcu_filepath), also_console=True)
    return vdu_filepath, vcu_filepath


def change_vdu_vcu_configuration_if_needed():
    tag = [tag for tag in get_robot_variable("${TEST TAGS}") if tag.startswith("SCF")]
    tag = tag[0] if tag else "SCF_DEFAULT"
    current_scf = get_robot_variable("${CURRENT_SCF}")
    if tag != current_scf:
        return prepare_aic_testline_to_onair_state(scf_tag=tag)
    logger.info(
        "\nSCF tag for test is the same. Comissioning skipped!", also_console=True
    )


def perform_full_commissioning_on_vdu(scf_filepath, vdu_id=0):
    with VduAdminSession(vdu_id) as admin:
        admin.perform_commissioning(scf_filepath)


def perform_full_commissioning_on_vcu(scf_filepath):
    with VcuAdminSession() as admin:
        admin.perform_commissioning(scf_filepath)


@wait_until_function_succeeds(retry_time_in_seconds=1200, retry_interval_in_seconds=30)
def wait_for_all_cells_onair():
    with VduAdminSession(vdu_id=0) as admin:
        cells = [cell['availability_status'].lower() == 'on line' for cell in admin.get_vdu_cells_status()]
    logger.info(cells, also_console=True)
    assert all(cells), "Not all cells are online!"
    logger.info("All cells are onair!", also_console=True)
