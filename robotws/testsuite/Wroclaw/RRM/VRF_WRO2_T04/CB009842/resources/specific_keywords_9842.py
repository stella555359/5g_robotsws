import json
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.pcap_verification.message_to_tree import message_to_tree
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.resources.preconditions_py import bts_prefix
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB009842.resources.ecid_pm_counters import (
    ECID_PM_COUNTERS,
)

msg_call_flow = [
    "DownlinkUEAssociatedNRPPaTransport",
    "E-CIDMeasurementInitiationRequest",
    "E-CIDMeasurementInitiationResponse",
    "UplinkUEAssociatedNRPPaTransport",
]


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in ECID_PM_COUNTERS:
        if isinstance(ECID_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                ECID_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${ECID_PM_COUNTERS}", ECID_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(ECID_PM_COUNTERS[ne_abbr]["value"], dict):
            ECID_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(
                multiplier
            )
        else:
            ECID_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable("${ECID_PM_COUNTERS}", ECID_PM_COUNTERS)


def check_timing_advance_value(pcap_file):
    filter = 'f1ap.E_CIDMeasurementInitiationResponse_element'
    output = TSharkCommandAssembler()\
        .with_filter(filter) \
        .with_pcap_file(pcap_file) \
        .build()
    return message_to_tree(output).find('NR-TADV').filter('E-CID-MeasurementResult').first()['val']


def verify_ecid_trigger_call_flow(pcap_file, filter='ngap or f1ap'):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    logger.info("\n Call flow from AMF(LMF)-gNB-AMF(LMF)", also_console=True)
    for msg in msg_call_flow:
        occurrence = filtered.find_next(pm(msg, name_line_pattern='empty'))
        assert occurrence is not None, "  No message '{}' in pcap  file".format(msg)
        logger.info("   {}: OK".format(msg), also_console=True)


def create_delta(distname, parameter_name, parameter_value):
    parameter_delta = {
        "distName": distname,
        "operation": "update",
        "parameters": [
            {
                "parameterName": parameter_name,
                "value": parameter_value,
                "operation": "update",
            }
        ],
    }
    return parameter_delta


def change_timingAdvanceOffset_param(value):
    with AdminSession() as admin:
        cell_list = [100, 110, 200, 210, 300, 310, 700, 800, 900]   # for all FDD NRCELLs
        delta_list = []
        for cell in cell_list:
            distname = "{}/NRCELL-{}".format(bts_prefix, cell)
            delta_list.append(create_delta(distname, "timingAdvanceOffset", value))
            delta = json.dumps(delta_list)
        admin.perform_delta_recommissioning(delta_file=delta)
