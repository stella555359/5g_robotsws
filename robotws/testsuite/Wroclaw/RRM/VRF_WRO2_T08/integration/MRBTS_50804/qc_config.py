from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.qc_id_helper import QCIDHelper

QCID = {
    "SBTS00": {
        "mrbts-50804_oam_uuf_exploratory_robustness_test_case": "65998",
        "e2e_tl_ru_reset_with_oam_kpi": "72537",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "68936",
        "e2e_tl_site_reset_with_oam_kpi": "178428",
        "e2e_tl_cell_lock_unlock_nr_with_oam_kpi": "72539",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "72538",
        "e2e_tl_delta_commissioning_with_online_parameter_modification": "72542",
        "e2e_tl_delta_commissioning_with_site_reset_required": "72540",
        "e2e_tl_delta_commissioning_with_nr_rat_reset": "72541",
        "e2e_tl_cell_block_unblock_nr_with_oam_kpi": "72543",
        "e2e_tl_activation_reset_with_oam_kpi": "232123",
    },
    "SBTS25R3": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "",
        "e2e_tl_site_reset_with_oam_kpi": "214271",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "214275",
    },
}

_helper = QCIDHelper(QCID)


def set_test_id(target_sw: str | None = None) -> str | None:
    return _helper.set_test_id(target_sw)
