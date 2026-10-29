import os
from jinja2 import Template
import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import mrbts_id, nrbts_id
from robot.api import logger

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "delta_files")


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


def shedulweights_sum(ues_schedulweight):
    return sum(ues_schedulweight.values())


def calculate_tput(ues_schedulweight, maxtput):
    total_weight = shedulweights_sum(ues_schedulweight)
    ues_tput = {
        key: round((value / total_weight) * float(maxtput), 1)
        for key, value in ues_schedulweight.items()
    }
    return ues_tput


def bts_reconfiguration(fiveqi_6=40, fiveqi_7=20, fiveqi_9=10):
    template = load_delta_template("bts_configuration.json")
    delta = template.render(
        mrbts_id=mrbts_id,
        nrbts_id=nrbts_id,
        schedulweight_fiveqi_6=fiveqi_6,
        schedulweight_fiveqi_7=fiveqi_7,
        schedulweight_fiveqi_9=fiveqi_9,
    )
    logger.info(json.loads(delta))
    perform_delta_plan_activation(delta)


def perform_delta_plan_activation(delta_str):
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(
            delta_file=delta_str,
            skip_parameter_relation_errors=False,
            should_activate=True,
            timeout=300,
        )
