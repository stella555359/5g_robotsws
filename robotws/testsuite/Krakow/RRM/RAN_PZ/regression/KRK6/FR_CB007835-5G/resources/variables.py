from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def get_proper_set_of_ids(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS22R4':
            {
                'qc_upgrade': 454564,
                'qc_site_reset': 454563,
                'qc_capacity_reset': 454566,
                'qc_ru_reset': 454565,
                'qc_cell_block_unblock': 447781,
            },
        'SBTS23R1':
            {
                'qc_upgrade': 528332,
                'qc_site_reset': 528331,
                'qc_capacity_reset': 528340,
                'qc_ru_reset': 528333,
                'qc_cell_block_unblock': 528339,
                'qc_cell_lock_unlock': 528336,
            },
        'SBTS23R2':
            {
                'qc_upgrade': 503208,
                'qc_site_reset': 503206,
                'qc_capacity_reset': 503204,
                'qc_ru_reset': 503205,
                'qc_cell_block_unblock': 503212,
                'qc_cell_lock_unlock': 503207,
            },
        'SBTS23R3':
            {
                'qc_upgrade': 564974,
                'qc_site_reset': 564983,
                'qc_capacity_reset': 564984,
                'qc_ru_reset': 564987,
                'qc_cell_block_unblock': 564989,
                'qc_cell_lock_unlock': 564985,
            },
        'SBTS23R4':
            {
                'qc_upgrade': 630835,
                'qc_site_reset': 630839,
                'qc_capacity_reset': 630841,
                'qc_ru_reset': 630838,
                'qc_cell_block_unblock': 670564,
                'qc_cell_lock_unlock': 630840,
                'qc_delta_reset': 670562,
                'qc_delta_online': 670563,
            },
        'SBTS00':
            {
                'qc_upgrade': 453345,
                'qc_site_reset': 453344,
                'qc_capacity_reset': 453347,
                'qc_ru_reset': 453346,
                'qc_cell_block_unblock': 396868,
                'qc_cell_lock_unlock': 460975,
            }
    }

    return qc_id_mapping[release]


def get_proper_set_of_ids_4g(bts_build):
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS22R4':
            {
                'qc_upgrade': 454564,
                'qc_site_reset': 454563,
                'qc_capacity_reset': 454566,
                'qc_ru_reset': 454565,
                'qc_cell_block_unblock': 447781,
            },
        'SBTS23R1':
            {
                'qc_upgrade': 528332,
                'qc_site_reset': 528331,
                'qc_capacity_reset': 528340,
                'qc_ru_reset': 528333,
                'qc_cell_block_unblock': 528339,
                'qc_cell_lock_unlock': 528336,
            },
        'SBTS23R2':
            {
                'qc_upgrade': 531083,
                'qc_site_reset': 531082,
                'qc_ru_reset': 531081,
                'qc_cell_block_unblock': 531078,
                'qc_cell_lock_unlock': 531080,
            },
        'SBTS23R3':
            {
                'qc_upgrade': 564986,
                'qc_site_reset': 564981,
                'qc_ru_reset': 564979,
                'qc_cell_block_unblock': 564990,
                'qc_cell_lock_unlock': 564982,
            },
        'SBTS23R4':
            {
                'qc_upgrade': 630836,
                'qc_site_reset': 630837,
                'qc_ru_reset': 630832,
                'qc_cell_block_unblock': 630846,
                'qc_cell_lock_unlock': 630845,
                'qc_delta_reset': 630833,
                'qc_delta_online': 630834,
            },
        'SBTS00':
            {
                'qc_upgrade': 530942,
                'qc_site_reset': 530943,
                'qc_ru_reset': 530944,
                'qc_cell_block_unblock': 530951,
                'qc_cell_lock_unlock': 530952,
            }
    }

    return qc_id_mapping[release]


def get_variables():
    if is_dry_run():
        return {}

    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None:
        bts_build = GnbDuOperations().get_bts_sw_version()

    tl_topology = BuiltIn().get_variable_value("${tl.tl_cloud_topology}")
    variables = {
        'CLOUD_5G_CLASSICAL_QC_ASIBR_ABILB1_3xAHHB_ENB': {
            'tput_dl': '430 Mbits/sec',
            'tput_ul': '75 Mbits/sec',
            'parallel_streams_ul': '4',
            'parallel_streams_dl': '4',
        },
        'CLOUD_5G_CLASSICAL_ANDROID_ASIKL_ABILB1B2B3_3xAEQB_ENB': {
            'tput_dl': '256 Mbits/sec',
            'tput_ul': '35 Mbits/sec',
            'parallel_streams_ul': '4',
            'parallel_streams_dl': '4',
        }
    }

    kpi_qc_ids = get_proper_set_of_ids(bts_build)
    kpi_qc_ids_4g = get_proper_set_of_ids_4g(bts_build)
    variables[tl_topology]['kpi_qc_ids'] = kpi_qc_ids
    variables[tl_topology]['kpi_qc_ids_4g'] = kpi_qc_ids_4g
    BuiltIn().log_to_console(variables[tl_topology])
    return variables[tl_topology]
