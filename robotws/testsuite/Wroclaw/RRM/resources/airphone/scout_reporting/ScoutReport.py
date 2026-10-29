from time import sleep
from taf.sw.scout import scout
from taf.sw.scout.exceptions import ScoutApiException


SLEEP_TO_RETRY_SCOUT_FETCH = 30


class ScoutReport(object):

    def fetch_scout_configuration(self, tlname, execution):
        self.scout = scout()
        for attempt in range(3):
            try:
                self.scout.setup_scout(scout_testline_name=tlname)
                scout_id = self.scout.request_scf(use_scout_internal_id=execution)
                return scout_id
            except ScoutApiException as fetch_err:
                sleep(SLEEP_TO_RETRY_SCOUT_FETCH)
            finally:
                self.scout.teardown_scout_api()
