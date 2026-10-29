import os
import traceback
import requests
import json
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.uuf_utils import get_current_sw
from taf.rfrl.utilities.wft_api import WftApi, WftUrlBuilder
from robot.api import logger


EXPECTED_STREAM = 'SBTS00'
PARAMS_FILEPATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'params.json')


def get_released_builds_from_wft():
    url_builder = WftUrlBuilder()
    base_url = url_builder.get_base_api_url()
    headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    with open(PARAMS_FILEPATH) as f:
        builds = requests.get(base_url, json=json.load(f), headers=headers).json()
    return builds


def get_newest_build():
    released_builds = get_released_builds_from_wft()
    newest_build = [build['version'] for build in released_builds['items']][0]
    logger.info(newest_build)
    return newest_build


def verify_if_newer_build_appeared():
    try:
        current_build = get_current_sw()
        newest_build = get_newest_build()
        if current_build != newest_build:
            return newest_build
    except Exception:
        logger.warn("Could not check newest build..")
        print(traceback.format_exc())
    return False


def clean_builds():
    os.system('rm -rf /home/ute/.ute-ca/cache/bts/*')
    os.system('rm -rf /home/ute/UUF_SW/SBTS/SBTS00/*')
