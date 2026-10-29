from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB009010.resources.interanr_pm_counters import INTERANR_PM_COUNTERS
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB009010.resources.interanr_pm_counters import remote_vm_ip
from ute_admin_infomodel import ute_admin_infomodel

ho_success = [
    "HandoverRequest",
    "HandoverRequestAcknowledge",
]

ho_fail = [
    "HandoverRequest",
    "HandoverPreparationFailure",
]


def prepare_startup_values():
    cell_list_local = get_cells_identifiers(identifier="globalCellId")
    cell_list_remote = get_cells_identifiers(identifier="globalCellId", remote_host=remote_vm_ip)
    cell_list = cell_list_local + cell_list_remote
    for ne_abbr in INTERANR_PM_COUNTERS:
        if isinstance(INTERANR_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                INTERANR_PM_COUNTERS[ne_abbr]["value"].update(
                    {"NRCELL-{}".format(cell): 0}
                )
    BuiltIn().set_test_variable("${INTERANR_PM_COUNTERS}", INTERANR_PM_COUNTERS)
    return cell_list


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(INTERANR_PM_COUNTERS[ne_abbr]["value"], dict):
            INTERANR_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(multiplier)
        else:
            INTERANR_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable('${INTERANR_PM_COUNTERS}', INTERANR_PM_COUNTERS)


def verify_handover(status, pcap_file, filter='xnap'):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter=filter, ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    logger.info("\n HO {}: ".format(status.upper()), also_console=True)
    flow = ho_success if status == "success" else ho_fail
    for msg in flow:
        occurrence = filtered.find_next(pm(msg, name_line_pattern='empty'))
        assert occurrence is not None, "  No message '{}' in pcap  file".format(msg)
        logger.info("   {}: OK".format(msg), also_console=True)


def find_existing_ANR_NRADJNRCELL(nradjnrcell_id):
    def get_nrrel_id(dist_name):
        return int(dist_name.split('-')[-1])

    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        nrreles = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRADJNRCELL_A-{}'
                                              .format(nradjnrcell_id), allow_negative_result=True)
        return [get_nrrel_id(item['dist_name']) for item in nrreles]
    except IndexError:
        raise RuntimeError("There is no NRADJNRCELL for ANR")
    finally:
        admin.teardown_infomodel()


def find_existing_ANR_ADJ_NRPLMNSET_SA(nradjnrcell_id):
    def get_nrrel_id(dist_name):
        return int(dist_name.split('-')[-1])

    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        nrplmnsets = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRADJNRCELL_A-{}/ADJ_NRPLMNSET_SA_A-*'
                                           .format(nradjnrcell_id), allow_negative_result=True)
        return [get_nrrel_id(item['dist_name']) for item in nrplmnsets]
    except IndexError:
        raise RuntimeError("There is no ADJ_NRPLMNSET_SA for NRADJNRCELL-{}".format(nradjnrcell_id))
    finally:
        admin.teardown_infomodel()


def remove_adj_nrplmnset_objects(instance_number, plmn_no=2):
    with AdminSession() as admin:
        for plmn in range(plmn_no):
            admin.perform_object_recommissioning(
                dist_name='{}/NRADJNRCELL-{}/ADJ_NRPLMNSET_SA-{}'.format(bts_prefix, instance_number, plmn + 1),
                parameter=[],
                operation='delete',
            )
