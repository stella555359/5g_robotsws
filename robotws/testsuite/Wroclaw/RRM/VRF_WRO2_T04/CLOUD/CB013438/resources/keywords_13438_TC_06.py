import os
import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.delta import activate_delta_on_vcu, load_delta_template, \
    activate_delta_on_vdu
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CLOUD.CB013438.resources.variables_13438_TC_06 import ues_schedulweight
from robot.api import logger

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_files')


def shedulweights_sum(ues_schedulweight):
    return sum(ues_schedulweight.values())


def calculate_tput(ues_schedulweight, maxtput):
    total_weight = shedulweights_sum(ues_schedulweight)
    ues_tput = {
        key: round((value / total_weight) * float(maxtput)/1000, 1)
        for key, value in ues_schedulweight.items()
    }
    return ues_tput


def update_ues_schedulweight(**kwargs):
    for key, value in kwargs.items():
        if key in ues_schedulweight:
            ues_schedulweight[key] = value
    return ues_schedulweight


def vcu_reconfiguration(fiveqi_7=ues_schedulweight['UE_1'], fiveqi_8=ues_schedulweight['UE_2'],
                        fiveqi_9=40, algo='disabled'):
    template = load_delta_template(f'{DELTA_DIR}/nrdrb_configuration.json')
    delta = template.render(schedulweight_fiveqi_7=fiveqi_7, schedulweight_fiveqi_8=fiveqi_8,
                            schedulweight_fiveqi_9=fiveqi_9, algorithmtype=algo, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    logger.info(json.loads(delta))
    activate_delta_on_vcu(delta)


def vdu_reconfiguration(fiveqi_7=ues_schedulweight['UE_1'], fiveqi_8=ues_schedulweight['UE_2'],
                        fiveqi_9=40, algo='disabled'):
    template = load_delta_template(f'{DELTA_DIR}/nrdrb_configuration.json')
    delta = template.render(schedulweight_fiveqi_7=fiveqi_7, schedulweight_fiveqi_8=fiveqi_8,
                            schedulweight_fiveqi_9=fiveqi_9, algorithmtype=algo,
                            mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    logger.info(json.loads(delta))
    activate_delta_on_vdu(delta)


def vdu_reinitprohibittimer_reconfiguration(timer=10):
    template = load_delta_template(f'{DELTA_DIR}/vdu_reinitprohibittimer.json')
    delta = template.render(timer=timer, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    logger.info(json.loads(delta))
    activate_delta_on_vdu(delta)
