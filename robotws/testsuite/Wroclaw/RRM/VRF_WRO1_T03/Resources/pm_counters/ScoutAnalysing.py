from taf.sw.scout import scout
import logging
from taf.sw.scout.exceptions import ConnectionException
from testsuite.Wroclaw.RRM.VRF_WRO1_T03.Resources.cm_operations.AdminOperations import AdminOperations

log = logging.getLogger()


class ScoutAnalysing(scout, AdminOperations):
    def __init__(self):
        super().__init__()
        self.bts = self.get_bts_main_info()
        log.info(self.bts)

    def login_logout_scout(self, scout_fun):
        def scout_operation(*args):
            try:
                self.setup_scout(scout_testline_name='10_16_MRBTS-50560')
                return scout_fun(self, *args)
            except ConnectionException:
                raise ConnectionException
            finally:
                self.teardown_scout_api()
        return scout_operation

    @login_logout_scout
    def get_kpi_from_scout(self, start_time, end_time, *kpis):
        for kpi in kpis:
            kpi_report = self.get_kpi(kpi, start_time, end_time)
            log.info(kpi_report)


# def login_logout_scout(scout):
#     taf.sw.scout.setup_scout()
#     def scout_operation():
#         scout
#     return scout
