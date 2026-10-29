"""
:copyright: Nokia
:author: marcin.bednarski@nokia.com
:maintainer: marcin.bednarski@nokia.com
"""

from taf.sw.scout.exceptions import ScoutApiException
from taf.sw.scout import scout
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError
from robot.api import logger
from typing import Optional
from os import environ
import socket

REPORT_MAX_ATTEMPTS = 3
scout = scout()


def add_scout_scf_id_to_test_data(tl_name: Optional[str] = None) -> None:
    """
    Fetches the SCF ID from the Scout API and adds it to the test data.

    :param tl_name: The test line name to use for setting up Scout. If not provided, the hostname will be used.
    :type tl_name: Optional[str]

    :raises ScoutApiException: If there is an error fetching the SCF ID from the Scout API.
    """
    _import_rep_library()
    scout.setup_scout(scout_testline_name=socket.gethostname().replace('-', '_') if not tl_name else tl_name)

    for attempt in range(REPORT_MAX_ATTEMPTS):
        try:
            scout_internal_id = False if environ.get("CM_EXECUTION_ID") else True
            scout_id = scout.request_scf(use_scout_internal_id=scout_internal_id)
            logger.info("Scout fetch successful", also_console=True)
            if scout_internal_id:
                BuiltIn().run_keyword("taf.sw.reporting_portal.add_to_test_data", {"tc_execution_id": scout_id})
            break
        except ScoutApiException as fetch_err:
            logger.write(f"Attempt {attempt + 1} failed: Scout fetch failed: {fetch_err}", "WARN")
            if attempt == REPORT_MAX_ATTEMPTS - 1:
                logger.write("Config Id not added to test data after 3 attempts. Scout fetch failed", "WARN")
        finally:
            if attempt == REPORT_MAX_ATTEMPTS - 1:
                scout.teardown_scout_api()


def _import_rep_library():
    rep_library = "taf.sw.reporting_portal"
    try:
        BuiltIn().import_library(rep_library)
    except RobotNotRunningError:
        logger.error(f"Robot not running but trying to import {rep_library}.")
