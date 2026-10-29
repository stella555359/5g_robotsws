import os
import sys
import pytest

# reactivate to test, comment out to pass sanity checks

# # Align import path to reach Topology.py (sibling of pytest/ directory)
# PYTHON_DIR = os.path.dirname(os.path.dirname(__file__))          # .../python
# sys.path.insert(0, PYTHON_DIR)

# from Topology import GnbHw  # getAps is a @staticmethod on GnbHw

# cases content: (topoStr, expected_count, description)
CASES = [
    ("CLOUD_5G_I_MP_AP_LOOO_PRIVATE_SANSA_FS_ECPRI_CMWV_TDD_6CC_8DL8UL_AEQE_RIM_RS_FW03", 1, "Fallback AP at middle"),
    ("CLOUD_5G_AP_3[LOOO]_FS", 3, "Number + single bracket token"),
    ("CLOUD_5G_AP_6[LOOO]_EXTRA", 6, "Number + single bracket token (6)"),
    ("CLOUD_5G_AP_[LOOO][LOOO]_TAIL", 2, "Two bracket tokens"),
    ("CLOUD_5G_AP_[LOOO][LOOO][LOOO]_TAIL", 3, "Three bracket tokens"),
    ("CLOUD_5G_AP_[L][OO][O]_MIXED", 3, "Multiple short bracket tokens"),
    ("CLOUD_5G_3xAP_LOOO_MISC", 3, "Legacy 3xAP_ pattern"),
    ("CLOUD_5G_AP_LOOO_MISC", 1, "Fallback AP without brackets / number"),
    ("CLOUD_5G_LO_AP_LO", 1, "Fallback AP at end"),
    ("PREFIX_AP_3[LOOO]_SUFFIX", 3, "Edge: number + bracket without CLOUD prefix"),
    ("PREFIX_AP_[LOOO][LOOO]", 2, "Edge: two bracket tokens without trailing underscore"),
    ("X_3xAP_LOOO_AP_[LOOO][LOOO]", 2, "Prefer bracket count after last _AP_ segment (ignore earlier 3xAP_)"),
    ("X_AP_[LOOO]Y_AP_4[LOOO]", 4, "Use segment after last _AP_ (4)"),
]


@pytest.mark.parametrize("topo, expected, comment", CASES)
def test_getAps(topo, expected, comment):
    result = GnbHw.getAps(topo)
    print(f"Topo: {topo:45} => getAps: {result} (expected {expected}) | {comment}")
    assert result == expected, f"Mismatch for '{topo}': got {result}, expected {expected}"


def test_consistency_bracket_vs_number_priority():
    topo = "CLOUD_5G_AP_5[LOOO][LOOO]"
    # According to implementation: first pattern matches 5[LOOO] (return 5), extra brackets ignored.
    result = GnbHw.getAps(topo)
    print(f"Topo: {topo} => getAps: {result} (expected 5) | Number has priority over subsequent brackets")
    assert result == 5


def test_last_segment_used_with_multiple_AP_sections():
    topo = "A_AP_[LOOO][LOOO]_MID_AP_7[LOOO]_END"
    # Split at last _AP_, right = '7[LOOO]_END' -> number pattern => 7
    result = GnbHw.getAps(topo)
    print(f"Topo: {topo} => getAps: {result} (expected 7) | Last _AP_ segment governs extraction")
    assert result == 7
