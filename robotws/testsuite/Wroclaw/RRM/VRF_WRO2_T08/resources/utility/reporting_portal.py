from robot.libraries.BuiltIn import BuiltIn

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import get_active_software


def report_to_reporting_portal(case_type, status, hostname, testline_type):
    build = get_active_software('5g')
    BuiltIn().run_keyword('taf.sw.reporting_portal.report_to_rp', 'PERF_CAP_{}_WRO8'.format(case_type), status,
                          'RAN_PZ_WRO_2', build,
                          {'testline': '5G_Wroclaw_{}'.format(hostname), 'qc_domain': None, 'qc_project': None,
                           'qc_id': None, 'comment': 'PERF_CAP_WRO8_{}'.format(build), 'label': testline_type,
                           'links': {}
                           }
                          )


def report_kpi(name, value, target, description, visible_to_db, kpi_type, category, unit):
    BuiltIn().run_keyword('taf.sw.reporting_portal.report_kpi_results', str(target), name, visible_to_db, str(value),
                          kpi_type, description, category, unit)
