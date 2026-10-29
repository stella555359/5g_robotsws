from decimal import *
import io
import re
import time
from taf.transport.ssh import ssh

ssh = ssh()


def parse_log(filename):
    """Parses iperf log. Used for prisma data transfer."""
    log_file = open(filename, "r")
    cnt = 0
    throughput = 0
    for line in log_file:
        cnt += 1
        data = line.replace("\n", "")
        if data != 'MBytes' and data != 'KBytes' and data != 'Bytes':
            throughput += float(data)
    try:
        average_throughput = round(throughput / cnt, 2)
    except ZeroDivisionError:
        average_throughput = 0
    return dict(throughput_time=cnt, average_throughput=average_throughput,
                average_throughput_unit='Mbits/sec', throughput_time_unit='sec')
