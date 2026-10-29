from _socket import gethostname

from robot.api import logger

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.test.test_file_helper import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import wait_for_online_state, \
    get_sw_release_name, get_bts_id, _validate_path, load_scf
from testsuite.Wroclaw.RRM.resources.log.log import blog

from testsuite.Wroclaw.RRM.resources.decorators import logged_keyword


from pathlib import Path

from testsuite.Wroclaw.RRM.resources.syslog_checker import syslog_checker

mrbts_id = 55326


@logged_keyword
def upload_scf_uuf(testcase, config_dir=None, skip_relation_errors=False):
    if config_dir is None:
        config_dir = _validate_path("{}/testsuite/Wroclaw/RRM/VRF_WRO2_T023/uuf/Adam_Brzezinski/resources".
                                    format(robot_globals.execdir()))
    load_scf(scf_path=resolve_custom_scf_path(testcase, config_dir), skip_relation_errors=skip_relation_errors)
    wait_for_online_state()


@logged_keyword
def Check_snapshot_prints(search_folder):
    checker = syslog_checker()
    checker.find_suspicious_logs(search_folder=search_folder)


@logged_keyword
def resolve_custom_scf_path(testcase, config_dir):
    branch = get_sw_release_name()
    rat = ''
    try:
        rat = str(get_bts_id())[0]
    except Exception as e:
        blog("Error {} occured during getting bts id".format(e), level='ERROR')
        pass
    rat = rat if rat in ['4', '5'] else '5'
    file_name = '{}_{}_{}G_{}.xml'.format(gethostname().replace('-', '_'), branch, rat, testcase)
    filepath = "{config}/{branch}/{file}".format(config=config_dir, branch=branch, file=file_name)
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    blog(filepath)
    return filepath


@logged_keyword
def change_of_parameter_to_trigger_DS(bts_id=mrbts_id):
    ds = DeltaStore()
    ds.initialise_delta_store()
    nrbts_object = f'MRBTS-{bts_id}/NRBTS-{bts_id}'
    ds.add_param_to_delta(nrbts_object + '/NRCELL-100', 'actAperCsi', 'false')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------DS should be deactivated-----------------------")


@logged_keyword
def verify_deep_sleep_activation_RIJO(RU_type: str, RU_status, RU_serial: str, *RUs_info: dict) -> None:
    for Radiomodule in RUs_info:
        if Radiomodule.get("productName") == RU_type and \
           Radiomodule.get("serialNumber") == RU_serial:

            status = Radiomodule.get("status") or {}
            power_state = status.get("powerState")

            logger.info(f"Checking RU:", also_console=False)
            logger.info(f"productName  = {RU_type}", also_console=False)
            logger.info(f"serialNumber = {RU_serial}", also_console=False)
            logger.info(f"status       = {status}", also_console=False)
            logger.info(f"powerState   = {power_state}", also_console=False)
            logger.info(f"expected     = {RU_status}", also_console=False)

            if not power_state:
                raise Exception(
                    f"RU {RU_type} SN={RU_serial} does not have valid power state "
                    f"(real value '{power_state}'), expected '{RU_status}'"
                )

            if power_state != RU_status:
                raise Exception(
                    f"Expected '{RU_status}' for RU {RU_type} SN={RU_serial}, "
                    f"real state '{power_state}'"
                )
            logger.info(
                f"? RU {RU_type} SN={RU_serial} has ok power state = {RU_status}",
                also_console=False
            )
            blog(f" RU {RU_type} SN={RU_serial} has ok power state = {RU_status}")
            return
    raise Exception(
        f"RU not found {RU_type} with serialNumber = {RU_serial}")
