"""
Helping Python Resource for tti trace collection.
"""
import re
import os
import logging
import json
import yaml


logger = logging.getLogger()


_MISSING_STREAM_COMPONENT_IND_PATTERN = re.compile(
    r"\[EventParser\]\s+Total number of missing StreamComponentInd msgs:\s*(\d+)",
    re.IGNORECASE,
)

_SUCCESSFULLY_DECODED_MESSAGES_PATTERN = re.compile(
    r"Count of successfully decoded messages:\s*(\d+)",
    re.IGNORECASE,
)


def add_file_ending_if_missing(file_path, file_ending):
    """This file adds to the given file_path the file_ending if it does not exist

    :param file_path: The path to the file
    :param file_ending: The file extension to be added, if missing.
    """
    if file_ending not in file_path:
        file_path += file_ending
    return file_path


def get_source_ip_address(raw_ip):
    """Retrieves the source ip address of the given raw_ip address
    """
    try:
        search_object = re.search("inet [0-9,.]*", raw_ip)
        source_ip = search_object.string[search_object.span()[
            0]+5:search_object.span()[1]]
    except AttributeError:
        logging.warning(
            "Did not recieve usable input -AttributeError-, defaulting to ip 10.0.1.2")
        source_ip = "10.0.1.2"
    except TypeError:
        logging.warning("Wrong Input Type was given. setting IP to 10.0.1.2")
        source_ip = "10.0.1.2"
    return source_ip


def get_static_routes_from_iprt(iprt_data):
    """From the iprt data given by vdu oam, this function extracts the information
    about the currently set list "staticRoutes"

    :param iprt_data: content returned by vdu oam for the managed object IPRT
    """
    try:
        for parameter in iprt_data['parameters']:
            if parameter['complex_parameter']['name'] == 'staticRoutes':
                return parameter['complex_parameter']['value']
    except KeyError:
        return []
    return []


def get_static_route_parameters(iprt_data):
    """This function reads the data from the oam retrieved iprt object
    The staticRoutes element is extracted and translated to a dictionary in the form {param_name: param_value},
    to be easier processed in the robot code
    :param iprt_data: content returned by vdu oam for the managed object IPRT
    """
    routes = get_static_routes_from_iprt(iprt_data)
    data = []
    for route in routes:
        data.append(
            {item.simple_parameter.name: item.simple_parameter.value for item in route.structure_parameters})
    return data


def create_json_commissioning_file_for_static_route(dist_name, gateway, dest_ip_addr):
    """This function creates the commissioning file to set or update the staticRoute item field
    inside of the managed object IPRT.

    :param dist_name: The full dist name for the managed object IPRT
    :param gateway: The gateway ip address
    :param dest_ip_addr: The destination ip address for the static route
    """
    data = [{
        "distName": dist_name,
        "operation": "update",
        "parameters": [
            {
                "parameterName": "staticRoutes",
                "value": [
                    {
                        "destIpAddr": dest_ip_addr,
                        "destinationIpPrefixLength": "32",
                        "gateway": gateway,
                        "preference": "1"
                    }
                ],
                "operation": "update"
            }
        ]
    }]

    filename = "/tmp/commission_static_route.json"
    with open(filename, 'w') as commissioning_file:
        json.dump(data, commissioning_file)

    return filename


def _get_missing_stream_component_ind_count(eventdecoder_stdout: str):
    """Parse missing StreamComponentInd message count from eventDecoder stdout.

    GHC: AI-generated/modified on 2026-01-14.

    Args:
        eventdecoder_stdout: Full stdout text produced by eventDecoder.

    Returns:
        int | None: Parsed count, or None if the line is not present.
    """
    if not isinstance(eventdecoder_stdout, str) or not eventdecoder_stdout.strip():
        return None

    match = _MISSING_STREAM_COMPONENT_IND_PATTERN.search(eventdecoder_stdout)
    if not match:
        return None

    return int(match.group(1))


def _get_total_successfully_decoded_messages(eventdecoder_stdout: str):
    """Sum all successfully decoded message counts from eventDecoder stdout.

    GHC: AI-generated/modified on 2026-01-14.

    Args:
        eventdecoder_stdout: Full stdout text produced by eventDecoder.

    Returns:
        int | None: Sum of all counts, or None if no counts are present.
    """
    if not isinstance(eventdecoder_stdout, str) or not eventdecoder_stdout.strip():
        return None

    matches = _SUCCESSFULLY_DECODED_MESSAGES_PATTERN.findall(eventdecoder_stdout)
    if not matches:
        return None

    return sum(int(value) for value in matches)


def analyze_eventdecoder_stdout(eventdecoder_stdout_or_path: str):
    """Analyze eventDecoder stdout and warn about missing StreamComponentInd messages.

    The function accepts either:
    - the stdout text directly, or
    - a filesystem path to a file containing that stdout.

    Args:
        eventdecoder_stdout_or_path: Stdout text or path to a log file.

    Returns:
        None
    """
    if isinstance(eventdecoder_stdout_or_path, str) and os.path.exists(eventdecoder_stdout_or_path):
        with open(eventdecoder_stdout_or_path, "r", encoding="utf-8") as log_file:
            stdout_text = log_file.read()
        return analyze_eventdecoder_stdout(stdout_text)

    missing_count = _get_missing_stream_component_ind_count(eventdecoder_stdout_or_path)
    if missing_count is not None and missing_count != 0:
        warning_msg = (
            "Missing StreamComponentInd messages detected: "
            "{} (expected 0).".format(missing_count)
        )
        logger.warning(warning_msg)

    total_successfully_decoded = _get_total_successfully_decoded_messages(eventdecoder_stdout_or_path)
    if total_successfully_decoded is not None and total_successfully_decoded == 0:
        warning_msg = (
            "Total count of successfully decoded messages is 0. "
            "Check eventDecoder input and configuration."
        )
        logger.warning(warning_msg)
