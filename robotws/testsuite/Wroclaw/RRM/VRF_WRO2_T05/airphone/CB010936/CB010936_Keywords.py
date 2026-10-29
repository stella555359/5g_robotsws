from robot.api import logger


def read_iperf_log_file(filename: str):
    with open(filename, "r") as iperf_file:
        ret = []
        for line_number, line in enumerate(iperf_file):
            if "out-of-order" in line:
                continue
            if line_number > 8 and "] 0.00-" in line:
                continue
            if line_number > 7:
                single_measurement = line.split("  ")
                # print(single_measurement)
                ret.append(single_measurement)
        return ret


def get_average_throughput(measurement_list: list):
    lines = 0
    value = 0
    for line in measurement_list:
        print(line[3])
        if line[3][0] != " ":
            val = line[3]
        else:
            val = line[3][1::]
        thpt = float(val[0:val.find(" ")])

        if "Kbits/sec" in line[3]:
            thpt = thpt / 1000
        if thpt != 0:
            lines += 1
            value += thpt
        else:
            pass
    return value / lines


def get_average_latency(latency_type: str, measurement_list: list):
    if latency_type == "avg":
        latency_field_index = 0
    elif latency_type == "min":
        latency_field_index = 1
    elif latency_type == "max":
        latency_field_index = 2
    elif latency_type == "stdev":
        latency_field_index = 3
    else:
        latency_field_index = 0

    lines = 0
    value = 0
    for line in measurement_list:
        new_line = line[4].strip().split(" ")
        latencies = new_line[4].split("/")
        if latencies[latency_field_index] != "-":
            lines += 1
            value += float(latencies[latency_field_index])
    return value / lines


def check_average_throughput(port: int,  direction: str, log_directory: str):
    file_name = f"iperf_{port}_{direction}.txt"
    file_directory = f"{log_directory}/" + file_name

    log_list = read_iperf_log_file(file_directory)

    logger.info(
        "\nAverage Throughput is {} Mbits/sec on port {}. ".format(
            get_average_throughput(log_list), port
        ),
        also_console=True,
    )
    return get_average_throughput(log_list)


def check_average_latency(port: int, direction: str, log_directory: str):
    file_name = f"iperf_{port}_{direction}.txt"
    file_directory = f"{log_directory}/" + file_name

    log_list = read_iperf_log_file(file_directory)

    logger.info(
        "\nAverage latency is {} ms on port {}. ".format(
            get_average_latency("avg", log_list), port
        ),
        also_console=True,
    )
    return get_average_latency("avg", log_list)


if __name__ == "__main__":
    pass
