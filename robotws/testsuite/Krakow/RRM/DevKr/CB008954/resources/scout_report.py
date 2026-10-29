import socket
from time import sleep
from taf.sw.scout import scout as taf_scout
from taf.sw.scout.exceptions import ScoutApiException
from robot.api import logger

SLEEP_TO_RETRY_SCOUT_FETCH = 30
RETRIES = 3


def scout_fetch_configuration():
    scout = taf_scout()
    possible_names = (get_testline_name()[1], get_scout_testline_name())
    for tl_name in possible_names:
        logger.info("Requesting scf for tl: {}".format(tl_name))
        for attempt in range(RETRIES):
            try:
                scout.setup_scout(scout_testline_name=tl_name)
                scout_id = scout.request_scf(use_scout_internal_id=True)
                logger.info("ID found for {}: {}".format(tl_name, scout_id))
                logger.info("Scout fetch successful. Config id: {}".format(scout_id))
                return scout_id
            except ScoutApiException as e:
                if "not exists" in str(e):
                    logger.info("{} does not exists in scout. Checking next possible name..".format(tl_name))
                    break
                logger.info("Scout fetch failed {}".format(e))

                sleep(SLEEP_TO_RETRY_SCOUT_FETCH)
            finally:
                scout.teardown_scout_api()


def get_testline_name():
    short_name = socket.gethostname()[10:]
    full_name = socket.gethostname().replace('-', '_')
    return short_name, full_name


def get_scout_testline_name():
    return '{}_1'.format(get_testline_name()[1])
