import xml.etree.ElementTree as ET
import re
import os
import pandas as pd
import json
import tti_utilities.config as config

_config_cache = {}


def LoadThresholdsFromConfigFile(XML_THRESHOLD_FILE, TARGET_LIST_NAME):
    # 📥 Parse XML and extract thresholds from list named "sssfSwitchingRedCap"
    if TARGET_LIST_NAME in _config_cache:
        print("Using threshold from cache")
        return _config_cache[TARGET_LIST_NAME]
    tree = ET.parse(XML_THRESHOLD_FILE)
    root = tree.getroot()
    match = re.match(r"\{(.*)\}", root.tag)
    namespace_uri = match.group(1) if match else None
    ns = {"ns": namespace_uri}

    thresholds = {}
    # target_list = root.find(f".//list[@name='{TARGET_LIST_NAME}']")
    # target_list = root.find(
    # "ns:managedObject[@class='Na list name']/ns:list[@name='TARGET_LIST_NAME']", namespaces=ns)
    target_list = root.find(
        f".//ns:managedObject[@class='com.nokia.srbts.nrbts:NRBTS']/ns:list[@name='{TARGET_LIST_NAME}']",
        namespaces=ns,
    )
    # print(target_list)
    if target_list is not None:
        for item in target_list.findall("ns:item", namespaces=ns):
            for p in item.findall("ns:p", namespaces=ns):
                name = p.attrib.get("name")
                # print(name)
                if name:
                    try:
                        thresholds[name] = float(p.text.strip())
                    except (ValueError, AttributeError):
                        continue
        # print("found")
        _config_cache[TARGET_LIST_NAME] = thresholds
        return thresholds
    else:
        return None


def load_csv_files(CSV_INPUT_FILE):
    # 📥 Load CSV or Excel
    if CSV_INPUT_FILE.endswith(".xlsx"):
        df = pd.read_excel(CSV_INPUT_FILE, low_memory=False)
    else:
        df = pd.read_csv(CSV_INPUT_FILE, low_memory=False)
    return df


# def color_text(text, status):
#     if status == "pass":
#         return f"\033[92m✅ {text}\033[0m"
#     else:
#         return f"\033[91m❌ {text}\033[0m"


def color_text(text, status, use_color=False):
    if status == "pass":
        return f"\033[92m✅ {text}\033[0m" if use_color else f"✅ {text}"
    else:
        return f"\033[91m❌ {text}\033[0m" if use_color else f"❌ {text}"


# names of all the files i am using
# sssgSwitchingEvaluationData
# ulPdcchDciData_dci_decode
# ulFdSchedData
# ulHarqRxData
# dlPdcchDciData_dci_decode
# dlFdSchedData
# dlHarqRxDataArray


def load_dataframes(rnti=None):
    dataframes = {}
    load_log = {}
    files_directory = config.FILES_DIRECTORY

    if not os.path.exists(files_directory):
        raise FileNotFoundError(f"Directory not found: {files_directory}")

    for filename in os.listdir(files_directory):
        # print("Found file:", filename)  # Debug print

        if filename.lower().endswith(".csv"):
            filepath = os.path.join(files_directory, filename)
            try:
                if filename.lower().endswith("sssgSwitchingEvaluationData.csv".lower()):
                    key = "ssgEvaluation"
                    # print("Matched:", filename)
                elif filename.lower().endswith("sssgSwitchingState.csv".lower()):
                    key = "sssgSwitchingState"
                    # print("Matched:", filename)
                elif filename.lower().endswith("ulPdcchDciData_dci_decode.csv".lower()):
                    key = "ulPdcchDci"
                    # print("Matched:", filename)
                elif filename.lower().endswith("ulFdSchedData.csv".lower()):
                    key = "ulFdSched"
                    # print("Matched:", filename)
                elif filename.lower().endswith("ulHarqRxData.csv".lower()):
                    key = "ulHarqRx"
                    # print("Matched:", filename)
                elif filename.lower().endswith("dlPdcchDciData_dci_decode.csv".lower()):
                    key = "dlPdcchDci"
                    # print("Matched:", filename)
                elif filename.lower().endswith("dlFdSchedData.csv".lower()):
                    key = "dlFdSched"
                    # print("Matched:", filename)
                elif filename.lower().endswith("dlHarqRxDataArray.csv".lower()):
                    key = "dlHarqRx"
                elif filename.lower().endswith("voipStateData.csv".lower()):
                    key = "voipStateData"
                    # print("Matched:", filename)
                else:
                    key = None

                if key:
                    df = load_csv_files(filepath)
                    df.insert(0, "excel_row", range(2, len(df) + 2))
                    if rnti:
                        # print(f"for key {key}")
                        if key == "dlHarqRx":
                            #    dataframes[key] = df[df['rnti.1']==rnti]
                            #    print(dataframes[key]['hfnTickCount','sfn','slot'])
                            dataframes[key] = df
                        else:
                            dataframes[key] = df[df["rnti"] == rnti]
                        # for key in dataframes:
                        #     print(key)
                    else:
                        dataframes[key] = df
                    load_log[filename] = key

            except Exception as e:
                load_log[filename] = f"error loading file: {str(e)}"
    required_keys = [
        "ssgEvaluation",
        "ulPdcchDci",
        "ulFdSched",
        "ulHarqRx",
        "dlPdcchDci",
        "dlFdSched",
        "dlHarqRx",
    ]
    missing_keys = [key for key in required_keys if key not in dataframes]

    # Save log
    log_path = os.path.join(config.LOG_FOLDER, "fileLoadLog.json")
    with open(log_path, "w") as f:
        json.dump(load_log, f, indent=4)
    if missing_keys:
        print(f"[FATAL] Missing required eventFiles: {', '.join(missing_keys)}")
        # sys.exit(1)  # Abort the script
        return "fatal"
    return dataframes


def process_dataframes(dfs):
    for key, df in dfs.items():
        print(f"\n--- {key.upper()} ---")
        print(df.head())


def format_aligned(left, right=None, width=30):
    if right is None:
        return f"  {str(left)}\n"
    return f"  {str(left):<{width}} : {right}\n"
