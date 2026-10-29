import re
import ssl
import logging

try:  # python3
    from urllib.request import urlopen
except Exception as _:  # python2
    from urllib2 import urlopen


def get_asicli_version(build):
    """Get asicli version from wft
    Args:
        build: build package name. e.g.: 5G20A_9.1800.933
    Returns:
        asicli version, e.g.: ASIRCLI_9.1.4
        or, if raise any error, return None
    """
    url = "https://wft.int.net.nokia.com/ext/build_content/" + build
    logging.info("request wft buid info with URL: {}".format(url))

    data = None
    try_times = 5
    while try_times > 0:
        try_times -= 1
        try:
            response = urlopen(url, context=ssl.SSLContext(ssl.PROTOCOL_SSLv23))
            data = response.read()
            # logging.debug("Got WFT response: {}".format(data))
            if data is not None:
                break
        except Exception as err:
            logging.error("Cannot connect to WFT. Error message: {}".format(err))
            logging.info("Retrying ...")

    if data is None:
        logging.error("failed to get build content from WFT")
        return None

    asicli = None
    asicli_pattern = r">(ASIRCLI_.*)</baseline>"
    for line in data.splitlines():
        line_data = str(line)
        if "ASIRCLI_" in line_data and asicli is None:
            matchObj = re.search(asicli_pattern, line_data)
            if matchObj is not None:
                asicli = matchObj.groups()[0]
                break

    return asicli
