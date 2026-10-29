import os
import json
import glob


def find_key(data, target_key):
    """
    Recursively search for a specific key in a nested JSON structure.
    Returns a list of all values associated with the target key.
    """
    results = []

    try:
        if isinstance(data, dict):
            for key, value in data.items():
                try:
                    if key == target_key:
                        results.append(value)
                    results.extend(find_key(value, target_key))
                except Exception as e:
                    print(f"File syntax error in key '{key}': {e}")
                    continue
        elif isinstance(data, list):
            for index, item in enumerate(data):
                try:
                    results.extend(find_key(item, target_key))
                except Exception as e:
                    print(f" {index}: {e}")
                    continue

    except Exception as global_e:
        print(f"File cannot be loaded due to wrong structure: {global_e}")

    return results


def check_physCellId_in_sCellTeoAddModList(directory_path):
    json_files = glob.glob(os.path.join(directory_path, "*.json"))
    results = False
    print("json_files", json_files)
    for file_path in json_files:
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                sCellToAddModLists = find_key(json_data, "sCellToAddModList")
                for sCellTeoAddModList in sCellToAddModLists:
                    print("sCellTeoAddModList:", sCellTeoAddModList)
                    try:
                        physCellId = sCellTeoAddModList[0].get("sCellConfigCommon", {}).get("physCellId", {})
                        if physCellId == 31:
                            results = True
                    except AttributeError:
                        continue
        except (json.JSONDecodeError, FileNotFoundError) as e:
            results = f"Error: {str(e)}"
    assert results, "No physCellId==31 in sCellTeoAddModList found!"


def check_sCellInactiveReason_rlq(directory_path):
    json_files = glob.glob(os.path.join(directory_path, "*.json"))
    results = False
    sCellIndex = 0
    print("json_files", json_files)
    for file_path in json_files:
        print("Parsing file: ", file_path)
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                SCell_Status_Lists = find_key(json_data, "SCell-Status-List")
                sCellToAddModLists = find_key(json_data, "sCellToAddModList")
                for sCellTeoAddModList in sCellToAddModLists:
                    print("sCellTeoAddModList:", sCellTeoAddModList)
                    try:
                        physCellId = sCellTeoAddModList[0].get("sCellConfigCommon", {}).get("physCellId", {})
                        if physCellId == 751:
                            sCellIndex = sCellTeoAddModList[0].get("sCellIndex", {})
                    except AttributeError:
                        continue
                for SCell_Status_List in SCell_Status_Lists:
                    print("SCell_Status_List:", SCell_Status_List)
                    try:
                        sCellIndex_rlq = SCell_Status_List[0].get("sCellIndex", {})
                        sCellInactiveReason = SCell_Status_List[0].get("sCellInactiveReason", {})
                        print("sCellIndex_rlq: ", sCellIndex_rlq)
                        print("sCellInactiveReason: ", sCellInactiveReason)
                        if sCellInactiveReason == "bad-radio-link-quality" and sCellIndex_rlq == sCellIndex:
                            results = True
                    except AttributeError:
                        continue
        except (json.JSONDecodeError, FileNotFoundError) as e:
            results = f"Error: {str(e)}"
    assert results, "Cell 751 not released with bad-radio-link-quality status"


def scell_addition_a1_event(directory_path):
    json_files = glob.glob(os.path.join(directory_path, "*.json"))
    results = False
    for file_path in json_files:
        print("file_path: ", file_path)
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                Decoded_measConfig_containers = find_key(json_data, "Decoded-measConfig-container")
                for Decoded_measConfig_container in Decoded_measConfig_containers:
                    reportConfigToAddModLists = find_key(Decoded_measConfig_container, "reportConfigToAddModList")
                    for reportConfigToAddModList in reportConfigToAddModLists:
                        for i, reportConfig in enumerate(reportConfigToAddModList):
                            if find_key(reportConfig, "eventA1"):
                                print("EventA1 found: ", i)
                                measIdToAddModLists = find_key(Decoded_measConfig_container, "measIdToAddModList")
                                for measIdToAddModList in measIdToAddModLists:
                                    measId = measIdToAddModList[i].get("measId", {})
                                measurementReports = find_key(json_data, "measurementReport")
                                print("measurementReports", measurementReports)
                                print("count_for_measId", i)
                                for measurementReport in measurementReports:
                                    measResults = find_key(measurementReport, "measResults")
                                    for measResult in measResults:
                                        if measResult.get("measId", {}) == measId:
                                            results = True
                                            return results
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Error: {str(e)}")
    assert results, "No eventA1 found"


def check_rlf(directory_path):
    json_files = glob.glob(os.path.join(directory_path, "*.json"))
    results = False
    for file_path in json_files:
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                UEContextModificationRequireds = find_key(json_data, "UEContextModificationRequired")
                for UEContextModificationRequired in UEContextModificationRequireds:
                    for msg in UEContextModificationRequired.get("protocolIEs"):
                        print("msg", msg)
                        try:
                            print("check: ", msg.get("value", {}).get("Cause", {}).get("radioNetwork", {}))
                            if msg.get("value", {}).get("Cause", {}).get("radioNetwork", {}) == "rl-failure-others":
                                return True
                        except (json.JSONDecodeError, FileNotFoundError) as e:
                            print(f"Error: {str(e)}")
        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Error: {str(e)}")
    assert results, "No Radio Link Failure log found"
