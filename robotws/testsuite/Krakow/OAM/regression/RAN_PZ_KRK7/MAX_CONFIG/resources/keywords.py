import random
import json
import time
from robot.libraries.BuiltIn import BuiltIn, logger
from testsuite.Krakow.resources.RAN_PZ_KRK7.tools.keywords import use_admin_connection


def get_all_cells_ids():
    nrcells_ids = []
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                nrcells_ids.append(nrcell_conf_id)
    return nrcells_ids


def get_random_cell_id():
    random_cell_id = random.choice(get_all_cells_ids())
    return random_cell_id


def prepare_delta_pmax(path, cell_id="random"):
    if cell_id == "random":
        cell_id = get_random_cell_id()

    delta_pmax_update = []
    with use_admin_connection() as connection:
        bts_info = connection.get_bts_info(timeout=600)
        nrcells = bts_info["cells"]["nr"]
        for nrcell in nrcells:
            configuration_id = nrcell["id"].get("configuration")
            if configuration_id:
                nrcell_conf_id = configuration_id.split("/")[-1].split("-")[-1]
                if nrcell_conf_id == str(cell_id):
                    pmax = nrcell.get("maximumOutputPower")
                    logger.console(f"Current NRCELL-{cell_id} pMax value: {pmax}")
                    new_pmax_value_list = [pmax - 0.1, pmax - 0.1]
                    new_pmax_value = random.choice(new_pmax_value_list)
                    logger.console(f"New NRCELL-{cell_id} pMax value: {new_pmax_value}")
                    delta_pmax = {
                        "distName": f"{configuration_id}",
                        "operation": "update",
                        "parameters": [
                            {
                                "parameterName": "pMax",
                                "value": f"{int(new_pmax_value*10)}",
                                "operation": "update",
                            }
                        ],
                    }
                    delta_pmax_update.append(delta_pmax)

    with open(f"{path}", "w") as delta:
        json.dump(delta_pmax_update, delta, separators=(',', ':'))
