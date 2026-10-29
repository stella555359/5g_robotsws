from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS00':
            {
                'qc_upgrade': 231148,
                'qc_site_reset': 231146,
                'qc_domain': 'MN_RAN',
                'qc_project': 'RAN_VRF'
            },
        'SBTS25R3':
            {
                'qc_upgrade': 207458,
                'qc_domain': 'MN_RAN',
                'qc_project': 'RAN_VRF'
            }
    }
    return qc_id_mapping[release]


def get_variables():
    if is_dry_run():
        return {}
    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()
    variables = {}
    variables['kpi_qc_ids'] = get_proper_set_of_ids(bts_build)
    return variables
