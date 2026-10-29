import re
from pprint import pprint

from tsharkWithLuaVerifier import TSharkCommandAssembler

# Define the threshold for 9KB (9 * 1000 bytes)
THRESHOLD_9KB = 9 * 1000


def generated_pcap_data(pcap_path):
    """Generates PCAP data using TShark."""
    tshark = TSharkCommandAssembler()
    output = (
        tshark.with_filter("dldata_pdschpayloadtbsendreq")
        .with_pcap_file(pcap_file=pcap_path)
        .inject_additional_parameters(
            "-T fields -e bip.msg.fragment.count "
            "-e bip.msg.reassembled.length"
        )
        .build()
    )
    return output


def is_payload_length_over_9kb(row, threshold=THRESHOLD_9KB):
    """Checks if PDSCH payload size exceeds the given threshold.

    Args:
        row: A string containing the number of fragments (count) and total length (length)
        threshold: The payload length threshold to compare against.

    Returns:
        True if length is greater than the threshold, False otherwise.
    """
    values = re.split(r"\t|,", row.strip())

    try:
        count, length = map(int, values)
        print(f'BIP Payload fragment count: {count}\t\tBIP Payload length: {length}')
        return length > threshold

    except ValueError:
        return False


def check_payload_size_above_9kb(pcap_path, threshold=THRESHOLD_9KB):
    """Checks if any PDSCH payload size exceeds the threshold.

    Args:
        pcap_path: The path to the PCAP file.
        threshold: Payload size threshold for comparison.

    Returns:
        True if all payload sizes exceed the threshold, False otherwise.
    """
    pcap_data = generated_pcap_data(pcap_path)
    return all(is_payload_length_over_9kb(row, threshold) for row in pcap_data if row.strip())
