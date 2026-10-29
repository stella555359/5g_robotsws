import re


def check_received_packets(egateOutput: str = ""):
    # Define the regex pattern
    pattern = r"Data packets sent\s+(\d+)"

    # Search for the pattern in the input string
    match = re.search(pattern, egateOutput)

    # If a match is found, extract the number, otherwise raise an error
    if match:
        packet_count = int(match.group(1))
        return packet_count
    else:
        raise ValueError("No silence packets received count found in the input string")


def check_bytes_sent(egateOutput: str = ""):
    # Define the regex pattern
    pattern = r"Bytes sent\s+(\d+)"

    # Search for the pattern in the input string
    match = re.search(pattern, egateOutput)

    # If a match is found, extract the number, otherwise raise an error
    if match:
        packet_count = int(match.group(1))
        return packet_count
    else:
        raise ValueError("No Bytes sent count found in the input string")
