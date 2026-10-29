from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS25R3':
            {
                'qc_upgrade': 206732,
                'qc_activation_reset': 206724,
                'qc_ru_reset': 206733,
                'qc_cell_block': 206728,
                'qc_cell_lock': 206731,
                'qc_online_commissioning': 206725,
                'qc_delta_commissioning': 206730,
                'qc_site_reset_commissioning': 206726
            },
        'SBTS00':
            {
                'qc_upgrade': 192320,
                'qc_activation_reset': 192328,
                'qc_ru_reset': 192319,
                'qc_cell_block': 192324,
                'qc_cell_lock': 192321,
                'qc_online_commissioning': 192326,
                'qc_delta_commissioning': 192322,
                'qc_site_reset_commissioning': 192325
            }
    }
    return qc_id_mapping[release]


def get_variables_Bharti():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    variables = {}
    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    variables['kpi_qc_ids'] = kpi_qc_ids
    return variables
