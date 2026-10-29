from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import (
    mrbts_id,
    nrbts_id,
)
import json
import random

online_parameters = [
    {
        "distname": "MRBTS-mrbts_id/EQM-1/APEQM-1/CABINET-1/SMOD-1",
        "parameter_name": "moduleLocation",
        "value": "Wroclaw_WL",
    }
]
site_reset_parameters = [
    {
        "distname": "MRBTS-mrbts_id/MNL-1/MNLENT-1/SYNC-1/CLOCK-1",
        "parameter_name": "totalDelayFromSHM",
        "value": "20",
    }
]
nr_rat_reset_parameters = [
    {
        "distname": "MRBTS-mrbts_id/NRBTS-nrbts_id",
        "parameter_name": "actDDDSPeriodOptimization",
        "value": "true",
    }
]


def prepare_delta(filename, parameter_type):
    if parameter_type == "online":
        params = online_parameters
    if parameter_type == "site_reset":
        params = site_reset_parameters
    if parameter_type == "nr_rat_reset":
        params = nr_rat_reset_parameters
    random_param = random.randint(0, len(params) - 1)
    with open(filename) as f:
        delta = json.load(f)
        delta[0]["distName"] = (
            params[random_param]["distname"]
            .replace("mrbts_id", str(mrbts_id))
            .replace("nrbts_id", str(nrbts_id))
        )
        delta[0]["parameters"][0]["parameterName"] = params[random_param][
            "parameter_name"
        ]
        delta[0]["parameters"][0]["value"] = params[random_param]["value"]
    logger.info(
        "\n\n Parameter: {} will be modified during test\n".format(
            params[random_param]["parameter_name"]
        ),
        also_console=True,
    )
    with open(filename, "w") as f:
        json.dump(delta, f, indent=2)
    return delta[0]
