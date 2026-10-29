import re
import csv
from pathlib import Path


class TddParser:
    """Custom Robot Framework library to extract TDD UL/DL Configuration blocks from text files."""

    def __init__(self):
        # Define the block regex and field patterns
        self.block_pattern = re.compile(
            r"(?s)tdd-UL-DL-ConfigurationCommon\s*{.*?nrofUplinkSymbols\s+\d+\s*}",
            re.MULTILINE
        )
        self.fields = [
            "referenceSubcarrierSpacing",
            "dl-UL-TransmissionPeriodicity",
            "nrofDownlinkSlots",
            "nrofDownlinkSymbols",
            "nrofUplinkSlots",
            "nrofUplinkSymbols"
        ]

    def get_tdd_blocks(self, file_path):
        """Return all matching TDD configuration blocks as a list of text strings."""
        text = Path(file_path).read_text(encoding="utf-8", errors="ignore")
        return self.block_pattern.findall(text)

    def extract_tdd_values(self, block_text):
        """Extract key parameter values from a block into a dictionary."""
        values = {}
        for field in self.fields:
            m = re.search(rf"{field}\s+(\S+)", block_text)
            values[field] = m.group(1) if m else "N/A"
        return values

    def write_tdd_to_csv(self, blocks, csv_file):
        """Write extracted TDD configuration data to CSV."""
        csv_path = Path(csv_file)
        with csv_path.open("w", newline="", encoding="utf-8") as f:
            writer = csv.DictWriter(f, fieldnames=self.fields)
            writer.writeheader()
            for block in blocks:
                writer.writerow(self.extract_tdd_values(block))
        return str(csv_path)
