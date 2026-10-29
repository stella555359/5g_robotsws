from time import sleep
from taf.sw.scout import scout
from taf.sw.scout.exceptions import ScoutApiException
from robot.api import logger

SLEEP_TO_RETRY_SCOUT_FETCH = 30


class ScoutReport(object):

    def __init__(self):
        self.scout = scout()

    def scout_fetch_configuration(self, tlname, execution):
        for attempt in range(5):
            try:
                self.scout.setup_scout(scout_testline_name=tlname)
                scout_id = self.scout.request_scf(use_scout_internal_id=True)
                logger.info("ID found for {}: {}".format(tlname, scout_id))
                logger.info("Scout fetch successful. Config id: {}".format(scout_id))
                return scout_id
            except ScoutApiException as fetch_err:
                if "not exists" in str(fetch_err):
                    logger.info("{} does not exists in scout. Checking next possible name..".format(tlname))
                    break
                logger.info("Scout fetch failed {}".format(fetch_err))
                sleep(SLEEP_TO_RETRY_SCOUT_FETCH)
            finally:
                self.scout.teardown_scout_api()
