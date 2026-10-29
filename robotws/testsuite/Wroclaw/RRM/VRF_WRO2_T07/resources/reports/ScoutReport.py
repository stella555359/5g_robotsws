from time import sleep
from taf.sw.scout import scout
from taf.sw.scout.exceptions import ScoutApiException
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog


SLEEP_TO_RETRY_SCOUT_FETCH = 30


class ScoutReport(object):

    def __init__(self):
        self.scout = scout()

    def scout_fetch_configuration(self, tlname, execution):
        for attempt in range(3):
            try:
                self.scout.setup_scout(scout_testline_name=tlname)
                scout_id = self.scout.request_scf(use_scout_internal_id=execution)
                blog("Scout fetch successful")
                return scout_id
            except ScoutApiException as fetch_err:
                blog(f"Scout fetch failed {fetch_err}")
                sleep(SLEEP_TO_RETRY_SCOUT_FETCH)
            finally:
                self.scout.teardown_scout_api()
