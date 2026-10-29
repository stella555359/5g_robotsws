from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from testsuite.Wroclaw.OAM.VRF_WRO3_T02.common_resources.qc_id_csv.variables import qc_id_mapping
from robot.libraries.BuiltIn import BuiltIn


def get_qc_ids():
    if is_dry_run():
        return {}
    if '5G_W_O_UPGRADE' in BuiltIn().get_variable_value("${TECHNOLOGY}"):
        bts_build = GnbDuOperations().get_bts_sw_version()
    else:
        bts_build = get_builtin_value('TARGET_SW')
    release = SbtsSwVersion(bts_build).release
    return qc_id_mapping[release]


qc_ids = get_qc_ids()
