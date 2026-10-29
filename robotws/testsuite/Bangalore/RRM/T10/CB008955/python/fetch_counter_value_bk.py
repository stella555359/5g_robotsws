import os
import glob
import xml.etree.ElementTree as ET


def extract_timestamp_from_filename(filename):
    """
    Extract timestamp from filenames like:
    PM.BTS-1.20251106.035500.ANY.xml
    """
    try:
        parts = filename.split(".")
        date = parts[2]      # 20251106
        time = parts[3]      # 035500
        return date + time
    except Exception:
        return "0"


def get_counter_from_file(xml_file, dn_substring, counter_name):
    """
    Extract counter value from a single XML file.
    - No measurementType filter used.
    - dn_substring matches partial DN.
    """
    total = 0

    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
    except Exception:
        return 0

    # Loop through all PMMOResult blocks
    for result in root.findall(".//PMMOResult"):

        dn_node = result.find(".//DN")
        if dn_node is None:
            continue

        # Check if the DN contains required substring
        if dn_substring not in dn_node.text:
            continue

        # Search all NE-WBTS_1.0 blocks (no measurementType filter)
        for meas in result.findall(".//NE-WBTS_1.0"):
            counter_node = meas.find(counter_name)
            if counter_node is not None:
                try:
                    total += int(counter_node.text)
                except Exception:
                    pass

    return total


def get_counter_value(xml_folder, dn_substring, counter_name, all_files=False):
    """
    Returns the counter from:
        - latest XML file (default)
        - all XML files when all_files=True
    """
    xml_files = glob.glob(os.path.join(xml_folder, "*.xml"))
    if not xml_files:
        print("No XML files found.")
        return 0

    # Sort by timestamp encoded in filename
    xml_files_sorted = sorted(xml_files, key=lambda f: extract_timestamp_from_filename(os.path.basename(f)))

    if not all_files:
        latest_file = xml_files_sorted[-1]
        return get_counter_from_file(latest_file, dn_substring, counter_name)

    # Sum across all files
    total_sum = 0
    for xml_file in xml_files_sorted:
        total_sum += get_counter_from_file(xml_file, dn_substring, counter_name)
    return total_sum
