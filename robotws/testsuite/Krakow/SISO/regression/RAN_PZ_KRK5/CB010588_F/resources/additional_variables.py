from resources import generate_attenuator_matrix
from common_variables import ATTENUATOR_MAP
from common_variables import QRXLEV
from common_variables import ATTENUATOR_VALUES
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.utilities.robot.general import is_dry_run
import os
import json


def get_variables():
    if is_dry_run():
        return {}

    ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)
    os.environ["attenuator_matrix"] = json.dumps(ATTENUATOR_MATRIX)
    os.environ["ATTENUATOR_VALUES"] = json.dumps(ATTENUATOR_VALUES)
    return {"Expected 'get_variables' to return dict-like value, got None.": "Hello"}
