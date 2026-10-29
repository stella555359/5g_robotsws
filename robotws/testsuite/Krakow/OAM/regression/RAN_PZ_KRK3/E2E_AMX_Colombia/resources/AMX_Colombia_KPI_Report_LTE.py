from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run, set_robot_suite_variable
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def get_proper_set_of_ids():
    if is_dry_run():
        return {}
    tl = get_builtin_value('tl')
    bts_build = get_builtin_value('4G_TARGET_SW')
    if bts_build is None:
        bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None and tl is not None:
        bts_build = GnbDuOperations().get_bts_sw_version()
    set_robot_suite_variable("FSMF", bts_build)
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        'SBTS23R1':
            {
                'qc_upgrade': 537399,
                'qc_site_reset': 537398,
                'qc_capacity_reset': 537401,
                'qc_ru_reset': 537400,
                'qc_cell_block_unblock': 537396,
                'qc_cell_lock_unlock': 537397,
                'qc_commision_site_reset': 537394,
                'qc_online_change': 537395,
            },
        'SBTS23R2':
            {
                'qc_upgrade': 585141,
                'qc_site_reset': 585143,
                'qc_capacity_reset': 531373,
                'qc_ru_reset': 531372,
                'qc_cell_block_unblock': 531368,
                'qc_cell_lock_unlock': 531369,
                'qc_commision_site_reset': 531366,
                'qc_online_change': 531367,
            },
        'SBTS23R3':
            {
                'qc_upgrade': 624074,
                'qc_site_reset': 624059,
                'qc_capacity_reset': 564761,
                'qc_ru_reset': 564762,
                'qc_cell_block_unblock': 564764,
                'qc_cell_lock_unlock': 564763,
                'qc_commision_site_reset': 672036,
                'qc_online_change': 672037
            },
        'SBTS23R4':
            {
                'qc_upgrade': 630654,
                'qc_site_reset': 630647,
                'qc_capacity_reset': 630650,
                'qc_ru_reset': 630651,
                'qc_cell_block_unblock': 630653,
                'qc_cell_lock_unlock': 630652,
                'qc_commision_site_reset': 672032,
                'qc_online_change': 672033,
            },
        'SBTS24R1':
            {
                'qc_upgrade_l3call': 698233,
                'qc_upgrade': 698228,
                'qc_site_reset': 698220,
                'qc_capacity_reset': 698214,
                'qc_ru_reset': 698215,
                'qc_cell_block_unblock': 698227,
                'qc_cell_lock_unlock': 698226,
                'qc_commision_site_reset': 698221,
                'qc_online_change': 698219,
                'qc_commision_rat_reset': 698216,
            },
        'SBTS24R2':
            {
                'qc_upgrade_l3call': 698233,
                'qc_upgrade': 698228,
                'qc_site_reset': 698220,
                'qc_capacity_reset': 698214,
                'qc_ru_reset': 698215,
                'qc_cell_block_unblock': 698227,
                'qc_cell_lock_unlock': 698226,
                'qc_commision_site_reset': 698221,
                'qc_online_change': 698219,
                'qc_commision_rat_reset': 698216,
            },
        'SBTS00':
            {
                'qc_upgrade_l3call': 40731,
                'qc_upgrade': 40739,
                'qc_site_reset': 40738,
                'qc_capacity_reset': 40736,
                'qc_ru_reset': 40740,
                'qc_cell_block_unblock': 40734,
                'qc_cell_lock_unlock': 40735,
                'qc_commision_site_reset': 40726,
                'qc_online_change': 40730,
                'qc_commision_rat_reset': 40732,
            }
    }

    return qc_id_mapping[release]


kpi_qc_ids = get_proper_set_of_ids()
