import re
from robot.api import logger


def match_string(string):
    pattern = (
        r"--- \d+.\d+.\d+.\d+ hping statistic ---\n\d+ packets transmitted, "
        r"\d+ packets received, \d+% packet loss\nround-trip min/avg/max = "

        r"\d+\.\d+/\d+\.\d+/\d+\.\d+ ms(\s*\(.*\))?$")
    trimmed_string = string.strip()
    match = re.match(pattern, trimmed_string)
    if match:
        logger.info("The string matches the pattern.")
    else:
        logger.error("The string does not match the pattern.")
        raise Exception(f"The string:\n {trimmed_string} does not match the pattern:\n {pattern}")
