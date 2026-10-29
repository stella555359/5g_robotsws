import glob
import os
from robot.libraries.BuiltIn import BuiltIn
import xml.etree.ElementTree as ET


ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def find_latest_pcapng_file(folder_path, file_pattern="*.pcapng"):
    matching_files = glob.glob(os.path.join(folder_path, file_pattern))
    if not matching_files:
        return None

    return max(matching_files, key=os.path.getmtime)


def verify_pcmd_records_presence_for_ri(pdml_file):
    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()

        required_records = ["nsetapx.ulSymbolRiDataList", "nsetapx.recordCollectionDuration",
                            "nsetapx.ulDropHeightDataList", "nsetapx.minDropHeight", "nsetapx.maxDropHeight",
                            "nsetapx.UlSymbolRiDataItem_element", "nsetapx.numOfDropHeightSamples",
                            "nsetapx.sumOfDropHeight", "nsetapx.ulSymbolRiDataList", "nsetapx.slotNumber",
                            "nsetapx.symbolNumber", "nsetapx.minPowerLevel", "nsetapx.maxPowerLevel",
                            "nsetapx.avgPowerLevel_element", "nsetapx.numOfPowerLevelSamples",
                            "nsetapx.sumOfPowerLevel"]

        found_records = set()
        for elem in root.iter():
            if 'name' in elem.attrib and elem.attrib['name'] in required_records:
                found_records.add(elem.attrib['name'])

        missing_records = set(required_records) - found_records
        if missing_records:
            raise AssertionError(f"Required records not found in the PCMD report: {', '.join(missing_records)}")

        print("All required records regarding RI are present in the PCMD report.")
    except Exception as e:
        raise AssertionError(f"Error occurred while verifying PCMD report: {str(e)}")


def verify_pcmd_records_presence_for_rim_rs(pdml_file):
    try:
        tree = ET.parse(pdml_file)
        root = tree.getroot()

        required_records = ["nsetapx.rimRsDataList", "nsetapx.rimRsSetId",
                            "nsetapx.propagationDelayInSymbol", "nsetapx.rimRsNearFarIndicator",
                            "nsetapx.rimRsAvgPowerLevel", "nsetapx.repetitionIndex"]

        found_records = set()
        for elem in root.iter():
            if 'name' in elem.attrib and elem.attrib['name'] in required_records:
                found_records.add(elem.attrib['name'])

        missing_records = set(required_records) - found_records
        if missing_records:
            raise AssertionError(f"Required records for RIMRS not found in PCMD report: {', '.join(missing_records)}")

        print("All required records regarding RIMRS are present in the PCMD report.")
    except Exception as e:
        raise AssertionError(f"Error occurred while verifying PCMD report: {str(e)}")
