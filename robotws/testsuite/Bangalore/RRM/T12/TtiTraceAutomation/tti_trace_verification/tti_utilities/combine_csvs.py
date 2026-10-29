import os
import subprocess
import sys
import re
import pandas as pd

# --- Ensure required packages are installed ---
required_packages = ["pandas", "openpyxl"]
for package in required_packages:
    try:
        __import__(package)
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package])


def run(folder_path):
    # print(folder_path)
    output_excel = os.path.join(folder_path, "Combined workbook Sheet.xlsx")
    allowed_endings = [
        "dlFdSchedData.csv",
        "dlHarqRxDataArray.csv",
        "dlPdcchDciData_dci_decode.csv",
        "sssgSwitchingEvaluationData.csv",
        "sssgSwitchingState.csv",
        "ulFdSchedData.csv",
        "ulHarqRxData.csv",
        "ulPdcchDciData_dci_decode.csv`",
    ]  # Customize this list
    success = False
    with pd.ExcelWriter(output_excel, engine="openpyxl", mode="w") as writer:
        used_sheet_names = set()

        for filename in os.listdir(folder_path):
            # print(filename)
            if filename.lower().endswith(".csv") and any(
                filename.endswith(end) for end in allowed_endings
            ):
                file_path = os.path.join(folder_path, filename)

                base_name = os.path.splitext(filename)[0]
                match = re.search(r"L2Ps_(.+)", base_name)
                sheet_name = match.group(1) if match else base_name
                sheet_name = re.sub(r"[:\\/*?\[\]]", "", sheet_name)[:31]

                original_name = sheet_name
                counter = 2
                while sheet_name in used_sheet_names:
                    sheet_name = f"{original_name}_{counter}"[:31]
                    counter += 1
                used_sheet_names.add(sheet_name)

                try:
                    print(f"Processing file {filename}")
                    df = pd.read_csv(file_path, low_memory=False, chunksize=5000)
                    # print("i am here")
                    for _, chunk in enumerate(df):
                        # df.to_excel(writer, sheet_name=sheet_name, index=False)
                        chunk.to_excel(writer, sheet_name=sheet_name, index=False)
                    # print("i am after excel")
                    print(f"Successfully added sheet {sheet_name}")
                    success = True
                except Exception as e:
                    print(f"⚠️ Failed to process {file_path}: {e}")
    if success:
        print("✅ Workbook created successfully.")
    else:
        print("⚠️ No matching CSV files were processed.")
