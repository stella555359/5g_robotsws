from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS25R2':
            {
                'qc_upgrade': 184798,
                'qc_activ_reset': 184799,
            },
        'SBTS26R1':
            {
                'qc_upgrade': 254163,
                'qc_activ_reset': 254162,
            },
        'SBTS00':
            {
                'qc_upgrade': 184794,
                'qc_activ_reset': 184796,
            }
    }
    return qc_id_mapping[release]


def get_variables():
    if is_dry_run():
        return {'kpi_qc_ids': {'qc_upgrade': 0, 'qc_activ_reset': 0}}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    variables = {}
    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    variables['kpi_qc_ids'] = kpi_qc_ids

    return variables
