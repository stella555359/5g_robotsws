import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.throughput.translator import (
    translate_percentage,
)
from taf.analyzer.iperf_throughput import iperf_throughput

ipt = iperf_throughput()

__all__ = ["check_iperf_throughput"]


def check_iperf_throughput(
    direction, log, target_throughput, target_avg_percent=0.95, min_percent=0.85
):
    tput = get_iperf_throughput(direction=direction, log=log)[0]
    if tput["average"]["unit"][0] == "M":
        transfer_unit = 1
    elif tput["average"]["unit"][0] == "K":
        transfer_unit = 1000
    elif tput["average"]["unit"][0] == "G":
        transfer_unit = 0.001
    else:
        transfer_unit = 1000 * 1000
    average = tput["average"]["value"] / transfer_unit
    minimum = tput["minimum"]["value"] / transfer_unit
    avg_percent = translate_percentage(target_avg_percent)
    min_percent = translate_percentage(min_percent)
    min_target = float(target_throughput) * min_percent
    avg_target = float(target_throughput) * avg_percent
    logging.info(
        "Validating iperf average throughput, should not lower than {}Mbps ({}Mbps * {})".format(
            avg_target, target_throughput, avg_percent
        )
    )
    if not average >= avg_target:
        raise ValueError("AVG is {}Mbps, lower than{}Mbps".format(average, avg_target))
    else:
        logging.info("AVG is {}Mbps, check pass.".format(average))

    logging.info(
        "Validating iperf minimum tput, should not lower than {}Mbps ({}Mbps * {})".format(
            min_target, target_throughput, min_percent
        )
    )
    if not minimum >= min_target:
        raise ValueError("min is {}Mbps, lower than {}Mbps".format(minimum, min_target))
    else:
        logging.info("min is {}Mbps, check pass.".format(minimum))


def get_iperf_throughput(direction, log):
    if direction.lower() == "dl":
        ipt.create_iperf_client_udp_throughput(log=log, alias="iperf_client")
        ipt.analyze(throughputs=["iperf_client"])
        return ipt.get_throughput(throughput="iperf_client")
    elif direction.lower() == "ul":
        ipt.create_iperf_client_udp_throughput(log=log, alias="iperf_server")
        ipt.analyze(throughputs=["iperf_server"])
        return ipt.get_throughput(throughput="iperf_server")
    else:
        raise ValueError("Wrong direction value: {}".format(direction))
