from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import \
    start_btslog_on_local_machine, stop_and_collect_btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import SyslogMessageMatcher as Sm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_5GC007949.resources.test_specific_keywords import \
    verify_on_air
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import backup_current_scf, get_cell_dist, revert_scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.common.file_helper import get_filepaths
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pmc


swconfig_flags_8941 = {'0x600012': ('1', 'CB008941 BOAM_NRTS')}


@logged_keyword
def set_preconditions_8941_06(cells_used_in_TC):
    backup_current_scf()
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta(get_cell_dist(cells_used_in_TC[0]), 'chBw', '100MHz')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_TC[0]), 'gscnOrSsPbchArfcn', '1')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_TC[0]), 'nrarfcn', '513000')
    ds.add_param_to_delta(get_cell_dist(cells_used_in_TC[0]), 'prachConfigurationIndex', '196')
    ds.validate_scf()
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta)
    verify_on_air()
    blog("Preconditions fulfilled")


@logged_keyword
def check_dlUPlan_in_syslog(btslog_dir):
    regular_expr_UPlan = r'^[\s\S]*dlUPlaneFragmentation: CpRtCm::Definitions::SUserPlaneFragmentation[\s\S]*'
    with LogHelper() as lh:
        syslog = lh.add_syslog(get_filepaths(btslog_dir, pattern='SYSLOG_*.LOG'))
        blog('checking regular_expression: ' + str(regular_expr_UPlan))
        msg_1 = syslog.find_next(Sm(regular_expr_UPlan, regex_engine='re'))
        assert msg_1 is not None, 'No sign of SUserPlaneFragmentation in syslog: {}.'.format(str(btslog_dir))
        blog('FOUND: ' + str(msg_1))
        blog('Syslog from {} analysed successfully.'.format(str(btslog_dir)))


@logged_keyword
def check_8941_counters(counter_dir, counter_ids):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=counter_ids)
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    blog(str(value_dict))
    counter_results = []
    for counter in value_dict.values():
        counter_result = False
        values_list = list(counter.values())[0]
        for i, value in enumerate(values_list[:-1]):
            if value < values_list[i + 1]:
                counter_result = True
        counter_results.append(counter_result)

    return all(counter_results)
