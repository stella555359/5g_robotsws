from robot.api import logger
from taf.config.testline.gnb.gnb import CloudBts
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VduSession import VduAdminSession


def get_sw_release_vdu():
    with VduAdminSession(vdu_id=0) as admin:
        software_version = admin.get_vdu_state_data()['software_version']
    return software_version.split('_')[0]


def is_release_higher(release):
    current_release = get_sw_release_vdu().replace('vDUCNF', '')
    logger.debug(current_release)
    return current_release >= release


def is_cloudran_tl():
    return isinstance(tl.gnbs[0], CloudBts)
