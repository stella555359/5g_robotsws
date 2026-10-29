from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from testsuite.Krakow.resources.UUF.get_uuf_builds import get_proper_set_of_qc_ids

_qc_id_mapping = {
    'SBTS24R2':
        {
            'qc_upgrade': 778019,
            'qc_site_reset': 778020,
        },
    'SBTS00':
        {
            'qc_upgrade': 732919,
            'qc_site_reset': 732918,
            'upgrade_paths': {
                'n2': 2,
                'n1': 1,
                'n0': 0,
                'customer': 9,

            }
        }
}


def get_variables():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    variables = {}
    kpi_qc_ids = get_proper_set_of_qc_ids(bts_build, _qc_id_mapping)
    variables['kpi_qc_ids'] = kpi_qc_ids
    return variables
