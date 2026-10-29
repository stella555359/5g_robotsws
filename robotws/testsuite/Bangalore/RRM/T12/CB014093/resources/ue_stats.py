import re


def check_avg_rate(output: str) -> float:
    """
    Extracts the Average throughput (Mbps) from PDSCH/PUSCH throughput tables.
    Works for lines like:
      CellIndex-0  51.4 Mbps 51.3 Mbps 102.9 Mbps 58.8 Mbps
      1 cell       175.149 Mbps 174.915 Mbps 175.482 Mbps 175.180 Mbps
    Returns float value of the last Mbps (Average column).
    """

    # Regex to extract last Mbps numerical value on a valid throughput row
    pattern = r"([0-9]+\.[0-9]+)\s*Mbps\s*$"

    for line in output.splitlines():
        line = line.strip()

        # Skip separators
        if line.startswith("-") or not line:
            continue

        # Process only lines containing Mbps
        if "Mbps" in line:
            match = re.findall(pattern, line)
            if match:
                # Return the LAST Mbps value (Average column)
                return float(match[-1])

    raise ValueError("Average throughput not found in output.")
