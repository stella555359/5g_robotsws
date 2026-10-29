from taf.rfrl.utilities.robot.general import get_builtin_value, is_dry_run
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


def get_proper_set_of_ids():
    if is_dry_run():
        return {}

    tl = get_builtin_value('tl')
    bts_build = get_builtin_value('ENB_BUILD')
    if bts_build is None and tl is not None:
        bts_build = GnbDuOperations().get_bts_sw_version()
    release = SbtsSwVersion(bts_build).release
    qc_id_mapping = {
        "SBTS23R2": {
            "qc_upgrade": 584814,
            "qc_site_reset": 584812,
        },
        "SBTS23R3": {
            "qc_upgrade": 624530,
            "qc_site_reset": 624520,
        },
        "SBTS23R4": {
            "qc_upgrade": 717183,
            "qc_site_reset": 717184,
            "qc_capacity_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_lock_unlock": None,
            "qc_commisioning_online": None,
            "qc_comissioning_reset": None,
        },
        "SBTS24R1": {
            "qc_upgrade": 791663,
            "qc_site_reset": 791661,
            "qc_capacity_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_lock_unlock": None,
            "qc_commisioning_online": None,
            "qc_comissioning_reset": None,
        },
        "SBTS24R2": {
            "qc_upgrade": 830471,
            "qc_site_reset": 830472,
            "qc_capacity_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_lock_unlock": None,
            "qc_commisioning_online": None,
            "qc_comissioning_reset": None,
        },
        "SBTS24R3": {
            "qc_upgrade": 846480,
            "qc_site_reset": 830479,
            "qc_capacity_reset": None,
            "qc_cell_block_unblock": None,
            "qc_cell_lock_unlock": None,
            "qc_commisioning_online": None,
            "qc_comissioning_reset": None,
        },
        "SBTS25R1": {
            "qc_upgrade": 88235,
            "qc_activation_reset": 88236,
            "qc_capacity_reset": 88248,
            "qc_cell_block_unblock": 88244,
            "qc_cell_lock_unlock": 88245,
            "qc_commisioning_online": 88246,
            "qc_comissioning_reset": 88247,
            "qc_commisioning_rat": 88243,
        },
        "SBTS25R2": {
            "qc_upgrade": 149450,
            "qc_activation_reset": 149460,
            "qc_capacity_reset": 149473,
            "qc_cell_block_unblock": 149469,
            "qc_cell_lock_unlock": 149470,
            "qc_commisioning_online_v2": 149471,
            "qc_comissioning_reset_v2": 149472,
            "qc_commisioning_rat": 149468,
        },
        "SBTS25R3": {
            "qc_upgrade": 207989,
            "qc_activation_reset": 220988,
            "qc_site_reset": 220989,
            "qc_capacity_reset": 207984,
            "qc_cell_block_unblock": 207982,
            "qc_cell_lock_unlock": 207987,
            "qc_commisioning_online_v2": 207983,
            "qc_comissioning_reset_v2": 207986,
            "qc_commisioning_rat": 207985,
        },
        "SBTS26R1": {
            "qc_upgrade": 254759,
            "qc_activation_reset": 254758,
            "qc_site_reset": 254747,
            "qc_capacity_reset": 254744,
            "qc_cell_block_unblock": 254743,
            "qc_cell_lock_unlock": 254749,
            "qc_commisioning_online_v2": 254745,
            "qc_comissioning_reset_v2": 254742,
            "qc_commisioning_rat": 254746,
        },
        "SBTS26R2": {
            "qc_upgrade": 298669,
            "qc_activation_reset": 298668,
            "qc_site_reset": 298667,
            "qc_capacity_reset": 298671,
            "qc_cell_block_unblock": 298674,
            "qc_cell_lock_unlock": 298670,
            "qc_commisioning_online_v2": 298675,
            "qc_comissioning_reset_v2": 298673,
            "qc_commisioning_rat": 298672,
        },
        "SBTS00": {
            "qc_upgrade": 243579,
            "qc_activation_reset": 243573,
            "qc_site_reset": 243571,
            "qc_capacity_reset": 243578,
            "qc_cell_block_unblock": 243587,
            "qc_cell_lock_unlock": 243586,
            "qc_commisioning_online_v2": 243589,
            "qc_comissioning_reset_v2": 243585,
            "qc_commisioning_rat": 243588,
        },
    }

    return qc_id_mapping[release]


kpi_qc_ids = get_proper_set_of_ids()
