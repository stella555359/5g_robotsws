import re


def check_received_packets(egateOutput: str = ""):
    # Define the regex pattern
    pattern = r"Total packets received\s+(\d+)"

    # Search for the pattern in the input string
    match = re.search(pattern, egateOutput)

    # If a match is found, extract the number, otherwise raise an error
    if match:
        packet_count = int(match.group(1))
        return packet_count
    else:
        raise ValueError("No silence packets received count found in the input string")


# Example usage
# egateOutput = "Some text... Silence packets received 123 ... Some more text"
# try:
#     count = create_received_packet_table(egateOutput)
#     print("Silence packets received:", count)
# except ValueError as e:
#     print(e)
