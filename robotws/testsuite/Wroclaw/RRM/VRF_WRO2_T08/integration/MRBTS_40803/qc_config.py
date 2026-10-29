from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.qc_id_helper import QCIDHelper

QCID = {
    "SBTS00": {
        "e2e_tl_sw_upgrade_rollback_with_oam_kpi": "273177",
        "e2e_tl_site_reset_with_oam_kpi": "273187",
    },
}

_helper = QCIDHelper(QCID)


def set_test_id(target_sw: str | None = None) -> str | None:
    return _helper.set_test_id(target_sw)
