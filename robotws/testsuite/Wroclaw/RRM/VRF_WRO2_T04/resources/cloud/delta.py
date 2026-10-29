import json
from jinja2 import Template
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VduSession import VduAdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VcuSession import VcuAdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id


def load_delta_template(delta_filepath):
    with open(delta_filepath) as f:
        return Template(f.read())


def activate_delta_on_vdu(delta, vdu_id=0):
    """
    :param delta: json string
    :param vdu_id: id of vdu to perform delta
    """
    with VduAdminSession(vdu_id) as admin:
        delta = json.loads(delta)
        logger.debug(delta)
        admin.perform_delta_recommissioning(json.dumps(delta))


def activate_delta_on_vcu(delta):
    """
    :param delta: json string
    """
    with VcuAdminSession() as admin:
        delta = json.loads(delta)
        logger.debug(delta)
        admin.perform_delta_recommissioning(json.dumps(delta))


def update_parameter_on_vcu(parameter, value, dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}', operation='update'):
    with VcuAdminSession() as admin:
        admin.perform_parameter_recommissioning(dist_name=dist_name,
                                                parameter=parameter,
                                                operation=operation,
                                                value=value)


def update_parameter_on_vdu(parameter, value, dist_name=f'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}', operation='update'):
    with VduAdminSession(vdu_id=0) as admin:
        admin.perform_parameter_recommissioning(dist_name=dist_name,
                                                parameter=parameter,
                                                operation=operation,
                                                value=value)
