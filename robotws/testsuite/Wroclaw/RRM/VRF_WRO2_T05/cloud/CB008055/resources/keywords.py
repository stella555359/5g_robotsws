import os
import json
import glob


# Function to safely navigate nested JSON using dynamic traversal
def find_key(data, target_key):
    """
    Recursively search for a specific key in a nested JSON structure.
    Returns a list of all values associated with the target key.
    """
    results = []
    if isinstance(data, dict):
        for key, value in data.items():
            if key == target_key:
                results.append(value)
            else:
                results.extend(find_key(value, target_key))
    elif isinstance(data, list):
        for item in data:
            results.extend(find_key(item, target_key))
    return results


def count_nRCellIdentity(json_data, target_identity):
    count = 0
    # Dynamically find all "SCell-ToBeRemoved-List" blocks in the JSON
    sCellLists = find_key(json_data, "SCell-ToBeRemoved-List")
    for sCellList in sCellLists:
        print("sCellList:", sCellList)
        if isinstance(sCellList, list):  # Ensure it's a list
            for item in sCellList:
                try:
                    # Extract nRCellIdentity and compare with the target
                    nRCellIdentity = item["value"]["SCell-ToBeRemoved-Item"]["sCell-ID"]["nRCellIdentity"]
                    if nRCellIdentity == target_identity:
                        count += 1
                except KeyError:
                    continue  # Skip if keys are missing
    return count


def count_in_all_json_files(directory_path, target_identity, counter):
    results = 0
    # Find all JSON files in the directory
    json_files = glob.glob(os.path.join(directory_path, "*.json"))

    for file_path in json_files:
        try:
            # Open and load each JSON file
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                # Count occurrences of the target nRCellIdentity
                count = count_nRCellIdentity(json_data, target_identity)
                results += count
        except (json.JSONDecodeError, FileNotFoundError) as e:
            results = f"Error: {str(e)}"
    assert int(results) >= int(counter), (
        f"Value error {target_identity} should be {counter} now is {results}"
    )
    return results

# measurement_reports


def extract_physCellId(data):
    """
    Recursively traverse the data to extract all `physCellId` values.
    """
    physCellIds = []
    if isinstance(data, dict):
        for key, value in data.items():
            if key == "physCellId":
                physCellIds.append(value)
            else:
                physCellIds.extend(extract_physCellId(value))
    elif isinstance(data, list):
        for item in data:
            physCellIds.extend(extract_physCellId(item))  # Recursive call
    return physCellIds


def check_if_A2_in_user_data(user_data):
    """
    Check if the string 'A2' is present in the User_data field.

    """
    return "A2" in user_data


def check_measurementReport(json_data):
    user_datas = find_key(json_data, "User_data")
    physCellIds = []
    for user_data in user_datas:
        if check_if_A2_in_user_data(user_data):
            measurementReports = find_key(json_data, "measurementReport")
            for measurementReport in measurementReports:
                pcis = extract_physCellId(measurementReport)
                for pci in pcis:
                    if pci not in physCellIds:
                        physCellIds.append(pci)
    return physCellIds


def count_measurement_reports(directory_path):
    results = 0
    json_files = glob.glob(os.path.join(directory_path, "*.json"))
    measurement_pci = [251, 252, 661, 662, 711]
    result_pci = []
    for file_path in json_files:
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                print("file: ", file)
                results = check_measurementReport(json_data)
                result_pci.extend(results)
                print(f"Result from file {file_path}: ", results)
        except (json.JSONDecodeError, FileNotFoundError) as e:
            results = f"Error: {str(e)}S"
    print(f"Measurement_pci: {measurement_pci}\nResult_pci: {result_pci}")
    assert set(measurement_pci) <= set(result_pci), "Not all PCI found in measurement report for A2"
    return True


def DUtoCURRCInformation(json_data):
    count = 0
    DUtoCURRCInformations = find_key(json_data, "DUtoCURRCInformation")
    for DUtoCURRCInformation in DUtoCURRCInformations:
        try:
            cell_group_config = DUtoCURRCInformation.get("Decoded-cellGroupConfig", {}).get("CellGroupConfig", {})

            if "sCellToReleaseList" in cell_group_config:
                print("cell_group_config:", cell_group_config)
                count += 1
        except AttributeError:
            continue
    print("count to return: ", count)
    return count


def check_DUtoCURRCInformation(directory_path):
    results = 0
    json_files = glob.glob(os.path.join(directory_path, "*.json"))
    for file_path in json_files:
        try:
            with open(file_path, "r", encoding="utf-8") as file:
                json_data = json.load(file)
                results += DUtoCURRCInformation(json_data)
        except (json.JSONDecodeError, FileNotFoundError) as e:
            results = f"Error: {str(e)}"
    print("Counted " + str(results) + " DUtoCURRCInformation ")
    assert results >= 5, "Value error DUtoCURRCInformation should be 5 now is {}".format(results)
    return True
