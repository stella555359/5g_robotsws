from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import get_cells_identifiers
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB009009.resources.anr_pm_counters import ANR_PM_COUNTERS
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix
from ute_admin_infomodel import ute_admin_infomodel


def prepare_startup_values():
    cell_list = get_cells_identifiers(identifier="globalCellId")
    for ne_abbr in ANR_PM_COUNTERS:
        if isinstance(ANR_PM_COUNTERS[ne_abbr]["value"], dict):
            for cell in cell_list:
                ANR_PM_COUNTERS[ne_abbr]["value"].update({"NRCELL-{}".format(cell): 0})
    BuiltIn().set_test_variable('${ANR_PM_COUNTERS}', ANR_PM_COUNTERS)


def increase_counters(*args, cell=None, multiplier=1):
    for ne_abbr in args:
        if isinstance(ANR_PM_COUNTERS[ne_abbr]["value"], dict):
            ANR_PM_COUNTERS[ne_abbr]["value"]["NRCELL-{}".format(cell)] += 1 * int(multiplier)
        else:
            ANR_PM_COUNTERS[ne_abbr]["value"] += 1 * int(multiplier)
    BuiltIn().set_test_variable('${ANR_PM_COUNTERS}', ANR_PM_COUNTERS)


def remove_relation_object(cell_id, instance_number, rel_to_cell='5G'):
    object_name = 'NRREL' if rel_to_cell == '5G' else 'NRRELE'
    with AdminSession() as admin:
        admin.perform_object_recommissioning(
            dist_name='{}/NRCELL-{}/{}-{}'.format(bts_prefix, cell_id, object_name, instance_number),
            parameter=[],
            operation='delete',
        )


def find_nrrele_id(from_cell, to_cell):
    admin = ute_admin_infomodel()
    try:
        admin.setup_infomodel()
        admin.connect_infomodel()
        nrrel = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRCELL_A-{}/NRRELE_A-* is [lcrId={}]'
                                      .format(from_cell, to_cell), allow_negative_result=True)
        return nrrel[0]['dist_name'].split('-')[-1]
    except IndexError:
        raise RuntimeError("NRRELE from cell {} to cell {} was not found!".format(from_cell, to_cell))
    finally:
        admin.teardown_infomodel()
