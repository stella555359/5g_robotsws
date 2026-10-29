from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.qc_id_helper import QCIDHelper

QCID = {
    "SBTS25R1": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "95184",
        "e2e_tl_activation_reset_with_oam_kpi": "192734",
        "e2e_tl_site_reset_with_oam_kpi": "192733",
    },
    "SBTS25R2": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "157061",
        "e2e_tl_activation_reset_with_oam_kpi": "192730",
        "e2e_tl_site_reset_with_oam_kpi": "192729",
    },
    "SBTS25R3": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "214262",
        "e2e_tl_activation_reset_with_oam_kpi": "214263",
        "e2e_tl_site_reset_with_oam_kpi": "214261",
    },
    "SBTS26R1": {
        "e2e_tl_ru_reset_with_oam_kpi": "275814",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "259723",
        "e2e_tl_activation_reset_with_oam_kpi": "259721",
        "e2e_tl_site_reset_with_oam_kpi": "259722",
        "e2e_tl_cell_lock_unlock_nr_with_oam_kpi": "275813",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "275815",
        "e2e_tl_delta_commissioning_with_online_parameter_modification": "275812",
        "e2e_tl_delta_commissioning_with_site_reset_required": "275811",
        "e2e_tl_delta_commissioning_with_nr_rat_reset": "275809",
        "e2e_tl_cell_block_unblock_nr_with_oam_kpi": "275810",
    },
    "SBTS26R2": {
        "e2e_tl_ru_reset_with_oam_kpi": "318352",
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "309315",
        "e2e_tl_activation_reset_with_oam_kpi": "309314",
        "e2e_tl_site_reset_with_oam_kpi": "309313",
        "e2e_tl_cell_lock_unlock_nr_with_oam_kpi": "318353",
        "e2e_tl_capacity_module_reset_with_oam_kpi": "318351",
        "e2e_tl_delta_commissioning_with_online_parameter_modification": "318356",
        "e2e_tl_delta_commissioning_with_site_reset_required": "318354",
        "e2e_tl_delta_commissioning_with_nr_rat_reset": "318355",
        "e2e_tl_cell_block_unblock_nr_with_oam_kpi": "318357",
    },
    "SBTS00": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "50448",
        "e2e_tl_activation_reset_with_oam_kpi": "192469",
        "e2e_tl_site_reset_with_oam_kpi": "192468",
    },
}

_helper = QCIDHelper(QCID)


def set_test_id(target_sw: str | None = None) -> str | None:
    return _helper.set_test_id(target_sw)
