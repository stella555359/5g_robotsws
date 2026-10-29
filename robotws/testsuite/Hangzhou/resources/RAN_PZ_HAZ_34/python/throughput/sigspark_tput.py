import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.throughput.translator import (
    translate_percentage)


def check_sigspark_throughput(tput, direction, target_throughput,
                              target_avg_percent=0.95):
    avg_percent = translate_percentage(target_avg_percent)
    avg_target = float(target_throughput) * avg_percent
    avg_tput = get_sigspark_throughput(tput, direction)
    logging.info(
        "Validating average throughput, should not lower than {}Mbps ({}Mbps * {})".format(
            avg_target, target_throughput, avg_percent
        )
    )
    if avg_tput < avg_target:
        raise ValueError("AVG is {}Mbps, lower than{}Mbps".format(avg_tput, avg_target))
    else:
        logging.info("AVG is {}Mbps, check pass.".format(avg_tput))


def check_bi_sigspark_throughput(tput, ul_target_throughput, dl_target_throughput, target_avg_percent=0.95):
    avg_percent = translate_percentage(target_avg_percent)
    ul_avg_target = float(ul_target_throughput) * avg_percent
    dl_avg_target = float(dl_target_throughput) * avg_percent
    ul_avg_tput, dl_avg_tput = get_bi_sigspark_throughput(tput)
    result = True
    # Check UL
    logging.info(
        "Validating UL average throughput, should not lower than {}Mbps ({}Mbps * {})".format(
            ul_avg_target, ul_target_throughput, avg_percent
        )
    )
    if ul_avg_tput < ul_avg_target:
        logging.error("AVG is {}Mbps, lower than{}Mbps".format(ul_avg_tput, ul_avg_target))
        result = False
    else:
        logging.info("AVG is {}Mbps, check pass.".format(ul_avg_tput))
    # Check DL
    logging.info(
        "Validating DL average throughput, should not lower than {}Mbps ({}Mbps * {})".format(
            dl_avg_target, dl_target_throughput, avg_percent
        )
    )
    if dl_avg_tput < dl_avg_target:
        logging.error("AVG is {}Mbps, lower than{}Mbps".format(dl_avg_tput, dl_avg_target))
        result = False
    else:
        logging.info("AVG is {}Mbps, check pass.".format(dl_avg_tput))
    if not result:
        raise ValueError("Check Bi throughput failed.")


def get_sigspark_throughput(tput, direction):
    # bps -> mbps
    if direction.lower() == "ul":
        return tput[0] / 1000 / 1000
    elif direction.lower() == "dl":
        return tput[1] / 1000 / 1000
    else:
        raise AttributeError("Direction should be UL or DL, but got {}".format(direction))


def get_bi_sigspark_throughput(tput):
    # bps -> mbps
    ul = tput[0] / 1000 / 1000
    dl = tput[1] / 1000 / 1000
    return ul, dl
