from robot.libraries.BuiltIn import BuiltIn
from taf.sw.reporting_portal import reporting_portal as ute_reporting_portal
from common_utilities import get_builtin_value


class ReportHandle(Exception):
    pass


def send_report_to_rep(tc_name, report, sw_version, tc_status=None, tc_counters=None, tc_kpi=None, qc_id=None,
                       tool='Robot', hw_id=""):
    """
    Reports TC result to reporting portal and QC
    :param qc_id: Test case QC id, not mandatory if tc_name is same as test case instance name in QC.
    :param tool: name of tool used in testsuite.
    :param hw_id: hw used in testline
    :param tc_name: name should be same as test case instance name in QC.
    :param tc_status: Passed or Failed, default None, status will read from ${TEST STATUS}
    :param report:Contains below parameters with example.
                {'qc_project': '5G', 'qc_domain': 'MN_5G', 'squad': '5G_SW_IND-Bangalore', 'username': 'owner',
                suite_path': '/robotws5g/tree/master/testsuite/RRM/ECE/UE_Call_Setup/5GC000341/5GC000341.robot',
                'qc_test_set_name': '5GC000341_5gNB_Reconfiguration_with_Site_Outage',
                'features_covered': ["5GC000341-A", "5GC000341-B"],
                'qc_testlab_paths': ['Root\\Test_Sets\\Trunk\\0.135\\5G_SW\\UE_Call_Setup',
                             'Root\\Test_Sets\\Trunk\\0.835\\5G_SW\\UE_Call_Setup']}
    :param sw_version: gNB SW version
    :param tc_counters: Test case counter list
    :param tc_kpi: Test case KPI list
    """
    try:
        tc_report = _validate_rep_arg(report, tc_status, tc_counters, tc_kpi)
    except ReportHandle as e:
        _log(e.message, 'WARN')
        return 1
    # Get sw_branch by split sw_version.
    # ex: sw_Version - 5G_0.135.1169, sw_branch is 0.135
    # remove 5G in branch.
    # sw_build = 0.135.1169
    # sw_build_split =['0', '135', '1169']
    # sw_branch = 0.135
    sw_build = sw_version.split('_')[-1]
    sw_build_split = sw_build.split('.')
    sw_branch = sw_build_split[0] + '.' + sw_build_split[1]
    rep = ute_reporting_portal()
    for qc_testlab_path in tc_report['qc_testlab_paths']:
        _log('Sending TC({}) results({}) to REP for Trunk({})'.format(tc_name, tc_status, qc_testlab_path), 'DEBUG')
        rep.report_to_rp(name=tc_name,
                         qc_test_instance_name=tc_name,
                         result=report['tc_status'],
                         links={},
                         ca=report['squad'],
                         add_info=["UTE", "TAF"],
                         build=sw_version,
                         suite_path=report['suite_path'],
                         tool=tool,
                         hw_id=hw_id,
                         username=report['username'],
                         features_covered=report['features_covered'],
                         qc_test_set_name=report['qc_test_set_name'],
                         qc_testlab_path=qc_testlab_path,
                         qc_domain=report['qc_domain'],
                         qc_project=report['qc_project'],
                         qc_id=qc_id,
                         counter_results=report['tc_counters'],
                         kpi_results=report['tc_kpi'],
                         testline=report['test_line'])
        _log('End TC results to REP', 'DEBUG')
    return 0


def _log(message, log_level='INFO'):
    BuiltIn().log('send_report_to_rep(): {}'.format(message), log_level)


def _validate_rep_arg(report, tc_status, tc_counters, tc_kpi):
    required_report_params = ['qc_project', 'qc_domain', 'squad', 'username', 'suite_path', 'qc_test_set_name',
                              'features_covered', 'qc_testlab_paths']
    if any(key not in report.keys() for key in required_report_params):
        raise ReportHandle('PreCheckError: tc_report does not contain required parameters. Required: {}, reported: {}'
                           .format(required_report_params, report.keys()))
    if any(value in report.values() for value in ["", None]):
        raise ReportHandle('PreCheckError: tc_report parameter contains None or empty value')
    tc_tags = get_builtin_value("TEST TAGS")
    if "SKIP_REPORT" in tc_tags:
        raise ReportHandle('Skip sending report to REP, TEST TAG with SKIP_REPORT')
    test_line = get_builtin_value("ute_testline")
    if test_line is None:
        raise ReportHandle('ute_testline not found, skip sending Report result to REP')
    tc_status = tc_status or get_builtin_value("TEST STATUS")
    if tc_status is None:
        raise ReportHandle('Test case result not found, skip sending Report result to REP')
    if tc_status.lower() in ['pass', 'passed']:
        tc_status = 'Passed'
    elif tc_status.lower() in ['fail', 'failed']:
        tc_status = 'Failed'
    else:
        raise ReportHandle('Invalid tc status ({}), skip sending Report result to REP'.format(tc_status))
    if isinstance(report['features_covered'], str):
        report['features_covered'] = list(report['features_covered'])
    if isinstance(report['qc_testlab_paths'], str):
        report['qc_testlab_paths'] = list(report['qc_testlab_paths'])
    report['tc_status'] = tc_status
    report['test_line'] = test_line
    report['tc_counters'] = tc_counters or []
    report['tc_kpi'] = tc_kpi or []
    return report
