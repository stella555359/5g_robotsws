import os
import re
import xml.etree.ElementTree as ET
from datetime import datetime


def get_latest_xml_file(directory):
    """
    Finds the latest PM XML file in a directory based on timestamp in filename.
    Example filename: PM.BTS-1.20251106.043000.ANY.xml
    """
    pattern = re.compile(r"PM\.BTS-\d+\.(\d{8}\.\d{6})\.ANY\.xml$")
    latest_file = None
    latest_time = None

    for filename in os.listdir(directory):
        match = pattern.search(filename)
        if match:
            timestamp_str = match.group(1)
            file_time = datetime.strptime(timestamp_str, "%Y%m%d.%H%M%S")
            if latest_time is None or file_time > latest_time:
                latest_time = file_time
                latest_file = filename

    if latest_file:
        return os.path.join(directory, latest_file)
    else:
        return None


def get_counter_value(xml_file, dn_path, counter_name):
    """
    Returns integer value of given counter for a specific DN from OMeS XML file.
    """
    tree = ET.parse(xml_file)
    root = tree.getroot()

    for result in root.findall(".//PMMOResult"):
        dn_node = result.find(".//DN")
        if dn_node is not None and dn_path in dn_node.text:
            meas_node = result.find(".//NE-WBTS_1.0")
            if meas_node is not None:
                counter_node = meas_node.find(counter_name)
                if counter_node is not None:
                    try:
                        return int(counter_node.text)
                    except (ValueError, TypeError):
                        return None
    return None


def get_latest_counter_value(directory, dn_path, counter_name):
    """
    Finds the latest PM XML file in a directory and returns the counter value
    for the given DN and counter.
    """
    latest_xml = get_latest_xml_file(directory)
    if not latest_xml:
        print("No valid XML files found in directory.")
        return None

    print(f"Latest XML file detected: {os.path.basename(latest_xml)}")

    value = get_counter_value(latest_xml, dn_path, counter_name)
    if value is not None:
        print(f"Counter '{counter_name}' for '{dn_path}' = {value}")
    else:
        print(f"Counter '{counter_name}' not found for '{dn_path}'")

    return value
