from resources import generate_attenuator_matrix
from common_variables import ATTENUATOR_MAP, QRXLEV, ATTENUATOR_VALUES, UUF_QC_IDS
from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
import os
import json


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release

    return UUF_QC_IDS[release]


def get_variables():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    ATTENUATOR_MATRIX = generate_attenuator_matrix(ATTENUATOR_MAP, QRXLEV)
    os.environ["attenuator_matrix"] = json.dumps(ATTENUATOR_MATRIX)
    os.environ["ATTENUATOR_VALUES"] = json.dumps(ATTENUATOR_VALUES)
    return get_proper_set_of_ids(bts_build)
