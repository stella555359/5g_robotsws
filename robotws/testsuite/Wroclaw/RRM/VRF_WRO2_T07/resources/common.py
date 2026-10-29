from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from taf.sw.scout import scout
from taf.sw.scout.exceptions import ScoutApiException
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
import taf.hw.pdu as tafpdu
from time import sleep

au = AdminUtils()


def power_on_testline():
    tl = BuiltIn().get_variable_value("${tl}")
    p = tafpdu.pdu()
    for pdu in tl.pdus:
        p.setup_pdu(pdu.model, host=pdu.addr, version=pdu.version)
        for port in pdu.port_numbers:
            p.power_on(port)
    sleep(300)


def power_off_testline():
    tl = BuiltIn().get_variable_value("${tl}")
    p = tafpdu.pdu()
    for pdu in tl.pdus:
        p.setup_pdu(pdu.model, host=pdu.addr, version=pdu.version)
        for port in pdu.port_numbers:
            p.power_off(port)


def fetch_scout_id(testline_name, execution=False):
    scout_obj = scout()

    try:
        scout_obj.setup_scout(scout_testline_name=testline_name)
        scout_id = scout_obj.request_scf(use_scout_internal_id=execution)
        return scout_id

    except ScoutApiException as scout_err:
        logger.console("Error occurred while fetching for scout ID: {}".format(scout_err))

    finally:
        scout_obj.teardown_scout_api()


@logged_keyword
def backup_current_scf(name='pre_change_scf_file.xml'):
    return au.download_current_scf(file_name=name)


@logged_keyword
def revert_scf(scf):
    au.perform_commissioning(scf_file=scf, skip_parameter_relation_errors=True)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def get_cell_dist(nrcell_id):
    mrbts_id, nrbts_id = au.get_bts_ids()
    return 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'.format(mrbts_id=mrbts_id,
                                                                       nrbts_id=nrbts_id,
                                                                       cell_id=str(nrcell_id))
