import re
import sys
import ssl

try:
    from urllib.request import urlopen  # Python 3
except ImportError:
    from urllib2 import urlopen  # Python 2

from robot.api import logger


def get_release(loadname):
    """
    loadname: SBTS00_ENB_9999_210308_000018
    return SBTS00
    """
    return "SBTS00" if is_trunk(loadname) else loadname.split("_")[0]


def is_trunk(loadname):
    return "ENB_9999_" in loadname


def get_wft_buildinfo(build):
    url = "https://wft.int.net.nokia.com/ext/build_content/" + build
    logger.info("Request wft buid info with URL: {}".format(url))

    lines = None
    try_times = 5
    while try_times > 0:
        try_times -= 1
        try:
            response = urlopen(url, context=ssl.SSLContext(ssl.PROTOCOL_SSLv23))
            lines = response.readlines()
            # logger.debug("Got WFT response: {}".format(lines))
            if lines is None:
                logger.error("Request WFT failed with URL: {}".format(url))
                continue
            else:
                break
        except Exception as err:
            logger.error("Cannot connect to WFT. Error message: {}".format(err))
            logger.info("Retrying ...")

    if lines is None:
        logger.error("Cannot connect to WFT.")
        sys.exit(1)

    asimgr = None
    asicli = None
    asimgr_pattern = r">(.*_ASIRMGR_.*)</baseline>"
    asicli_pattern = r">(ASIRCLI_.*)</baseline>"
    for line in lines:
        data = str(line)
        if "_ASIRMGR_" in data and asimgr is None:
            matchObj = re.search(asimgr_pattern, data)
            if matchObj is not None:
                asimgr = matchObj.groups()[0]
        elif "ASIRCLI_" in data and asicli is None:
            matchObj = re.search(asicli_pattern, data)
            if matchObj is not None:
                asicli = matchObj.groups()[0]

    return (asimgr, asicli)
