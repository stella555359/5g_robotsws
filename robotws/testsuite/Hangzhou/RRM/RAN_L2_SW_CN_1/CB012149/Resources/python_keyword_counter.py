import os
import gzip
import re
from xml.etree import ElementTree as ET


def find_non_zero_acc_num_in_gz_files(directory, tag_name):
    # Dictionary to store results
    results = {}

    # Pattern to find the specific value as a fallback
    pattern = re.compile(rf'<{tag_name}>(\d+)</{tag_name}>')

    # Iterate over all files in the directory
    for dirpath, dirs, files in os.walk(directory):
        for file in files:
            if file.startswith('RD') and file.endswith('.gz'):
                file_path = os.path.join(dirpath, file)
                with gzip.open(file_path, 'rt', encoding='utf-8') as f:
                    file_content = f.read()
                    non_zero_values = []

                    # Try to parse XML content
                    try:
                        xml_root = ET.fromstring(file_content)
                        # Find all specific tags with non-zero values
                        for elem in xml_root.iter():
                            if elem.tag == tag_name and int(elem.text) != 0:
                                non_zero_values.append(elem.text)
                    except ET.ParseError:
                        # If XML parsing fails, use regex as a fallback
                        print(f"XML parsing failed for file: {file_path}. Trying regex...")
                        matches = pattern.findall(file_content)
                        for match in matches:
                            if int(match) != 0:
                                non_zero_values.append(match)

                    if non_zero_values:
                        results[file] = non_zero_values

    return results
