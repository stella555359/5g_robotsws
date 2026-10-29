from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.qc_id_helper import QCIDHelper

QCID = {
    "SBTS00": {
        "mrbts-55140_oam_uuf_exploratory_robustness_test_case": "63394",
    },
    "SBTS26R2": {
        "basic_oam_uuf_scenario_check": "309390",
    },
    "SBTS26R1": {
        "oam_uuf_exploratory_robustness_test_case_26r1": "265338",
    },
}

_helper = QCIDHelper(QCID)


def set_test_id(target_sw: str | None = None) -> str | None:
    return _helper.set_test_id(target_sw)
