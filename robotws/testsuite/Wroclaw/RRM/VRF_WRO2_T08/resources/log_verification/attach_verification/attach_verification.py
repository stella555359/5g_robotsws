"""
Helper keywords providing interface for attach verification

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.robot_utils import get_robot_library
from .attach_log_parsers import BIPAttachParser, X2APAttachParser, NGAPAttachParser, QxdmAttachParser, EltAttachParser

_bip_ver = BIPAttachParser()
x2ap_ver = X2APAttachParser()
ngap_ver = NGAPAttachParser()
qxdm_ver = QxdmAttachParser()
elt_ver = EltAttachParser()


def find_attaches_in_bip_pcap(pcap_path, sw_branch="25r2"):
    return _bip_ver.parse_pcap(pcap_path, sw_branch)


def find_attaches_in_x2ap_pcap(pcap_path):
    return x2ap_ver.parse_pcap(pcap_path)


def find_attaches_in_ngap_pcap(pcap_path):
    return ngap_ver.parse_pcap(pcap_path)


def find_attaches_in_qxdm_log(qxdm_log):
    return qxdm_ver.parse_log(qxdm_log)


def find_attaches_in_elt_log(elt_log):
    return elt_ver.parse_log(elt_log)


def assert_required_number_of_successful_attaches(attaches, n):
    num_succ_attaches = len([attempt for attempt in attaches if attempt.state])
    assert num_succ_attaches >= n, "Found attaches: {} | Required minimum: {}".format(num_succ_attaches, n)


def summarize_attaches(attaches):
    report = ""
    for idx, attempt in enumerate(attaches):
        outcome = 'Success' if attempt.state else 'Failure'
        report += "Attach attempt {}:\n   Outcome: {}\n   Info: {}\n".format(idx, outcome, attempt.state_info)
    return report


def assert_attached_cell_visible_on_bts(ue_alias):
    taf_ue = get_robot_library('taf.ue')
    ue_cell_pci = taf_ue.get_ue_info(ue_alias, 'CELL_INFO:pci')
    with Admin5G() as admin_api:
        bts_pcis = [cell['physicalCellId'] for cell in admin_api.get_cells_info()
                    if _is_bts_cell_status_valid(cell['status'])]
    assert len(bts_pcis), "No active cell on bts"
    assert int(ue_cell_pci) in [int(pci) for pci in bts_pcis], \
        "Attached cell (pci={}) not visible on bts (active pci's = {})".format(ue_cell_pci, bts_pcis)
    return ue_cell_pci


def _is_bts_cell_status_valid(cell_status):
    is_valid = cell_status['usageState'] == 'Active' and cell_status['proceduralStatus'] == 'configured' \
               and cell_status['administrativeState'] == 'Unlocked' and cell_status['operationalState'] == 'enabled' \
               and cell_status['blockingState'] == 'Unblocked'
    return is_valid
