import time
from taf.sw.scout import scout as taf_scout
from taf.sw.scout.exceptions import ScoutApiException
from robot.api import logger
import socket
import os


SLEEP_TO_RETRY_SCOUT_FETCH = 30
RETRIES = 3


def get_testline_name():
    short_name = socket.gethostname()[10:]
    full_name = socket.gethostname().replace('-', '_')
    return short_name, full_name


def get_scout_testline_name():
    return '{}_1'.format(get_testline_name()[1])


def get_cm_execution_id():
    return os.environ.get("CM_EXECUTION_ID")


def is_it_manual_execution():
    return False if get_cm_execution_id() else True


def scout_fetch_configuration():
    scout = taf_scout()
    is_manual = is_it_manual_execution()
    possible_names = (get_testline_name()[1], get_scout_testline_name())
    for tl_name in possible_names:
        logger.info(f"Requesting scf for tl: {tl_name}")
        for attempt in range(RETRIES):
            try:
                scout.setup_scout(scout_testline_name=tl_name)
                scout_id = scout.request_scf(use_scout_internal_id=is_manual)
                logger.info(f"Scout fetch successful. TC execution id: {scout_id}")
                if is_manual:
                    return scout_id
                return
            except ScoutApiException as e:
                if "not exists" in str(e):
                    logger.info(f"{tl_name} does not exists in scout. Checking next possible name..")
                    break
                logger.info(f"Scout fetch failed {e}")

                time.sleep(SLEEP_TO_RETRY_SCOUT_FETCH)
            finally:
                scout.teardown_scout_api()
