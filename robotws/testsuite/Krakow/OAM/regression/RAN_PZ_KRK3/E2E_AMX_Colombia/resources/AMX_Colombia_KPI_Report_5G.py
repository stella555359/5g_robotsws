from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def get_proper_set_of_ids():
    if is_dry_run():
        return {}
    tl = get_builtin_value('tl')
    bts_build = get_builtin_value('5G_TARGET_SW')
    if bts_build is None:
        bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None and tl is not None:
        bts_build = GnbDuOperations().get_bts_sw_version()
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS23R1':
            {
                'qc_upgrade': 528418,
                'qc_site_reset': 528419,
                'qc_bbmod_reset': 528425,
                'qc_ru_reset': 528423,
                'qc_cell_block_unblock': 528424,
                'qc_cell_lock_unlock': 528420,
                'qc_commision_site_reset': 528422,
                'qc_online_change': 528421,
            },
        'SBTS23R2':
            {
                'qc_upgrade': 585154,
                'qc_site_reset': 585155,
                'qc_bbmod_reset': 504341,
                'qc_ru_reset': 504337,
                'qc_cell_block_unblock': 504338,
                'qc_cell_lock_unlock': 504342,
                'qc_commision_site_reset': 504340,
                'qc_online_change': 504339,
            },
        'SBTS23R3':
            {
                'qc_upgrade': 624061,
                'qc_site_reset': 624075,
                'qc_bbmod_reset': 586701,
                'qc_ru_reset': 586700,
                'qc_cell_block_unblock': 670520,
                'qc_cell_lock_unlock': 564769,
                'qc_commision_site_reset': 670518,
                'qc_online_change': 670519,
            },
        'SBTS23R4':
            {
                'qc_upgrade': 630646,
                'qc_site_reset': 630645,
                'qc_bbmod_reset': 630659,
                'qc_ru_reset': 630658,
                'qc_cell_block_unblock': 670515,
                'qc_cell_lock_unlock': 630656,
                'qc_commision_site_reset': 670513,
                'qc_online_change': 670514
            },
        'SBTS24R1':
            {
                'qc_upgrade_l3call': 698211,
                'qc_upgrade': 698207,
                'qc_site_reset': 698208,
                'qc_bbmod_reset': 698212,
                'qc_ru_reset': 698213,
                'qc_cell_block_unblock': 698223,
                'qc_cell_lock_unlock': 698229,
                'qc_commision_site_reset': 698221,
                'qc_online_change': 698222,
                'qc_commision_rat_reset': 698217,
            },
        'SBTS24R2':
            {
                'qc_upgrade_l3call': 698211,
                'qc_upgrade': 698207,
                'qc_site_reset': 698208,
                'qc_bbmod_reset': 698212,
                'qc_ru_reset': 698213,
                'qc_cell_block_unblock': 698223,
                'qc_cell_lock_unlock': 698229,
                'qc_commision_site_reset': 698221,
                'qc_online_change': 698222,
                'qc_commision_rat_reset': 698217,
            },
        'SBTS24R3':
            {
                'qc_upgrade_l3call': 698211,
                'qc_upgrade': 698207,
                'qc_site_reset': 845556,
            },
        'SBTS25R3':
            {
                'qc_upgrade_l3call': 207204,
                'qc_upgrade': 207207,
                'qc_activation_reset': 207205,
            },
        'SBTS00':
            {
                'qc_upgrade_l3call': 222031,
                'qc_upgrade': 222035,
                'qc_activation_reset': 222037,
            }
    }

    return qc_id_mapping[release]


kpi_qc_ids = get_proper_set_of_ids()
