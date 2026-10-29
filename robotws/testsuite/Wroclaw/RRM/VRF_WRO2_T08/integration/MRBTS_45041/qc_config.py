from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.qc_id_helper import QCIDHelper

QCID = {
    "SBTS00": {
        "e2e_tl_ru_reset_with_oam_kpi": "",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "106311",
        "e2e_tl_site_reset_with_oam_kpi": "184224",
        "e2e_tl_cell_lock_unlock_nr_with_oam_kpi": "",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "",
        "e2e_tl_delta_commissioning_with_online_parameter_modification": "",
        "e2e_tl_delta_commissioning_with_site_reset_required": "",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi_and_l3_call": "",
        "e2e_tl_delta_commissioning_with_nr_rat_reset": "",
        "e2e_tl_cell_block_unblock_nr_with_oam_kpi": "",
        "e2e_tl_activation_reset_with_oam_kpi": "219438",
    },
}

_helper = QCIDHelper(QCID)


def set_test_id(target_sw: str | None = None) -> str | None:
    return _helper.set_test_id(target_sw)
