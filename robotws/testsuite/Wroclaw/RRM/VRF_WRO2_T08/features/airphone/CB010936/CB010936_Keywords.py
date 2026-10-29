import re


def check_if_average_latency_lower_then_threshold(expected_latency: float, output_file: str) -> None:
    """
    :param expected_latency: The expected latency threshold in milliseconds.
    :param output_file: The path to the file containing iperf output.
    :raises FileNotFoundError: If the output file is not found.
    :raises ValueError: If the output file does not contain valid latency data.
    """
    latency_pattern = r"(\d+\.\d+)/(\d+\.\d+)/(\d+\.\d+)/(\d+\.\d+)\s+ms"
    is_latency_lower = False
    average_latencies = []

    try:
        with open(output_file, 'r') as file:
            stdout_content = file.read()
        latency_results = re.findall(latency_pattern, stdout_content)
        if not latency_results:
            raise ValueError("No latency data found in the output file.")
        for result in latency_results:
            average_latencies.append(float(result[0]))

        is_latency_lower = all(latency < float(expected_latency) for latency in average_latencies)
        average_latencies_strings = ", ".join([str(num) for num in average_latencies])
        if not is_latency_lower:
            raise Exception(f"Latencies {average_latencies_strings} higher then {expected_latency}ms.")

    except FileNotFoundError:
        raise FileNotFoundError(f"The output file '{output_file}' was not found.")
    except (ValueError, AttributeError) as e:
        raise ValueError(f"Invalid latency data in the output file: {e}")


def get_average_bandwidth(filepath: str) -> float:
    """
    Reads the file at the given filepath, extracts the average bandwidth from the last row, and returns it as a float.
    The function expects that the last row contains a field with the format:
       "<number> Mbits/sec"
    For example: "15.3 Mbits/sec"

    :param: filepath (str) - file from iperf command
    :returns: (float) - average bandwidth from iperf traffic
    """
    with open(filepath, 'r') as f:
        lines = [line.strip() for line in f if line.strip()]
        if not lines:
            raise ValueError("The file is empty.")

    last_line = lines[-1]

    match = re.search(r'(\d+(?:\.\d+)?)\s*Mbits/sec', last_line)
    if match:
        value = float(match.group(1))
        return value
    raise ValueError("Average bandwidth not found in the last line.")


def check_average_bandwidth_condition(*args: str) -> None:
    """
        Check if lowest bandwidth from provided list is at least five times higher
        than the biggest bandwidth.

        :param: *args str - list of bandwidths
        :returns: None
        """
    bandwidths = []
    for thrpt in args:
        bandwidths.append(float(thrpt))
    bandwidths.sort()
    assert bandwidths[0] * 5 > bandwidths[-1]
