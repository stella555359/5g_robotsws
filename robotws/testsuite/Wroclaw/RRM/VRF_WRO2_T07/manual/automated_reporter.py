from taf.sw.reporting_portal import reporting_portal
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword

api = reporting_portal()


@logged_keyword
def report_to_repo(tc_name, result, ca, testline_name, build, qc_domain, qc_project, qc_id, tc_exec_id):
    return api.report_to_rp(name=tc_name, result=result, ca=ca, testline=testline_name, build=build,
                            qc_domain=qc_domain, qc_project=qc_project, qc_id=qc_id,
                            links={}, tool="Robot", tc_execution_id=tc_exec_id)
