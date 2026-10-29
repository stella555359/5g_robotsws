import os
import xml.etree.ElementTree as ET
import re


def extract_timestamp_from_filename(filename):
    """
    Extract timestamp from filenames like:
    PM.BTS-1.20251106.035500.ANY.xml
    """
    try:
        parts = filename.split(".")
        date = parts[2]  # 20251106
        time = parts[3]  # 035500
        return date + time
    except Exception:
        return "0"


def get_xml_files(xml_folder):
    """
    Bulletproof XML file finder.
    - Case-insensitive
    - Handles hidden characters
    - Handles trailing spaces
    """
    try:
        files = os.listdir(xml_folder)
    except Exception as e:
        print("ERROR reading folder:", xml_folder, e)
        return []

    xml_files = []
    for f in files:
        # Strip spaces and check extension safely
        if f.strip().lower().endswith(".xml"):
            xml_files.append(os.path.join(xml_folder, f.strip()))

    print(">>>> XML files detected:", xml_files)
    return xml_files


def get_counter_from_file(xml_file, dn_substring, counter_name):
    """
    Extract counter value from a single XML file.
    - No measurementType filter.
    - Partial DN matching.
    """
    total = 0

    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
    except Exception as e:
        print(f"ERROR parsing XML file {xml_file}: {e}")
        return 0

    for result in root.findall(".//PMMOResult"):

        dn_node = result.find(".//DN")

        if dn_node is None:
            continue

        if not dn_node.text.strip().endswith("/" + dn_substring):
            continue

        # Search all NE-WBTS_1.0 blocks
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
    Returns counter from:
    - latest XML file (default)
    - OR sum across all XMLs (all_files=True)
    """
    xml_files = get_xml_files(xml_folder)
    if not xml_files:
        print("No XML files found after scanning.")
        return 0

    # Sort XML files by timestamp inside filename
    xml_files_sorted = sorted(
        xml_files,
        key=lambda f: extract_timestamp_from_filename(os.path.basename(f))
    )

    if not all_files:
        latest_file = xml_files_sorted[-1]
        print(">>> Using latest XML file:", latest_file)
        return get_counter_from_file(latest_file, dn_substring, counter_name)

    # Sum across all XML files
    total_sum = 0
    for xml_file in xml_files_sorted:
        total_sum += get_counter_from_file(xml_file, dn_substring, counter_name)
    return total_sum
