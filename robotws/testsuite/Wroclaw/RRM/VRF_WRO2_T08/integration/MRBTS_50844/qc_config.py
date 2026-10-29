from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.qc_id_helper import QCIDHelper

QCID = {
    "SBTS25R1": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "106773",
        "e2e_tl_activation_reset_with_oam_kpi": "192736",
        "e2e_tl_site_reset_with_oam_kpi": "192735",
    },
    "SBTS25R2": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "157179",
        "e2e_tl_activation_reset_with_oam_kpi": "192732",
        "e2e_tl_site_reset_with_oam_kpi": "192731",
    },
    "SBTS25R3": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "214382",
        "e2e_tl_activation_reset_with_oam_kpi": "214380",
        "e2e_tl_site_reset_with_oam_kpi": "214381",
    },
    "SBTS26R1": {
        "e2e_tl_ru_reset_with_oam_kpi": "259818",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "259822",
        "e2e_tl_activation_reset_with_oam_kpi": "259821",
        "e2e_tl_site_reset_with_oam_kpi": "259823",
        "e2e_tl_cell_lock_unlock_nr_with_oam_kpi": "259817",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "259820",
        "e2e_tl_delta_commissioning_with_online_parameter_modification": "259816",
        "e2e_tl_delta_commissioning_with_site_reset_required": "259813",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi_and_l3_call": "259814",
        "e2e_tl_delta_commissioning_with_nr_rat_reset": "259815",
        "e2e_tl_cell_block_unblock_nr_with_oam_kpi": "259819",
    },
    "SBTS00": {
        "e2e_tl_ru_reset_with_oam_kpi": "45905",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "50450",
        "e2e_tl_activation_reset_with_oam_kpi": "192430",
        "e2e_tl_site_reset_with_oam_kpi": "192429",
        "e2e_tl_cell_lock_unlock_nr_with_oam_kpi": "45904",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "45907",
        "e2e_tl_delta_commissioning_with_online_parameter_modification": "45903",
        "e2e_tl_delta_commissioning_with_site_reset_required": "45902",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi_and_l3_call": "45901",
        "e2e_tl_delta_commissioning_with_nr_rat_reset": "45898",
        "e2e_tl_cell_block_unblock_nr_with_oam_kpi": "45900",
    },
}

_helper = QCIDHelper(QCID)


def set_test_id(target_sw: str | None = None) -> str | None:
    return _helper.set_test_id(target_sw)
