# Code base for TTI Trace Unizpping To Event Csv
# Also decodes dci data to DCI_Decode
"""
Project Name : TTI Trace EventCsv Decoding Automation Script
Author       : Hari Somu
Created On   : November 4, 2025
Version      : 1.0.0
Description  : Initial release of TTI Trace EventCsv Decoding Automation Script.
                The script coverts the .pcap file event csv [.csv] files.
"""

from cli.interface import get_args
from tqdm import tqdm
from utils.extraction_utils import (
    unzip_file,
    find_numeric_folder,
    find_pcap_subfolders,
    collect_pcap_files,
    run_bat_script,
    run_post_processing_script,
)
from utils.input_parsing_utils import classify_path
import os
import shutil
import sys

# if '.tti-env' not in os.environ:
#     venv = '.tti-env'
#     python_bin = os.path.join(venv, 'Scripts', 'python.exe')
#     os.execv(python_bin, [python_bin] + sys.argv)


args = get_args()
ZIP_PATH = args.zip_path
# zip_file_path = os.path.join(destination_path, "raghavendra.zip")
DESTINATION_PATH = args.destination_path
FORMAT = args.format
valid_formats = [
    "legacyCsv",
    "json",
    "excelCsv",
    "eventCsv",
    "eventParquet",
    "mergedCsv",
    "parquet",
    "parquetCsv",
]
if FORMAT not in valid_formats:
    print("Invalid format")
    print("format should in one of the any", valid_formats)
    sys.exit(1)
print(FORMAT)
# if not DESTINATION_PATH:
#     rootfolder_path = os.path.dirname(os.getcwd())
#     destination_dir = os.path.join(rootfolder_path, "downloads")
#     os.makedirs(destination_dir, exist_ok=True)

# destination_path = os.getcwd()
path_flag = classify_path(ZIP_PATH)


def restart_script():
    print("🔄 Restarting script...")
    os.execv(sys.executable, ["python"] + sys.argv)


def copy2_with_progress(src, dst):
    os.makedirs(os.path.dirname(dst) or ".", exist_ok=True)

    try:
        total_size = os.path.getsize(src)
    except OSError:
        total_size = None  # Fallback for network paths

    with open(src, "rb") as src_file:
        src_wrapped = tqdm.wrapattr(src_file, "read", total=total_size)
        with open(dst, "wb") as dst_file:
            shutil.copyfileobj(src_wrapped, dst_file)

    shutil.copystat(src, dst)  # Preserve metadata like copy2


def get_extracted_files(zip_path):
    # Create a permanent folder to unzip into
    # zip_name = os.path.splitext(os.path.basename(zip_path))[0]
    # unzip_dir = os.path.join(os.getcwd(), zip_name)
    # os.makedirs(unzip_dir, exist_ok=True)

    # Unzip into the same directory where the ZIP file is located
    zip_dir = os.path.dirname(os.path.abspath(zip_path))
    zip_name = os.path.splitext(os.path.basename(zip_path))[0]

    unzip_dir = os.path.join(zip_dir, zip_name)
    os.makedirs(unzip_dir, exist_ok=True)

    unzip_file(zip_path, unzip_dir)
    print(unzip_dir)
    numeric_folder = find_numeric_folder(unzip_dir)
    if not numeric_folder:
        print("No numeric folder found.")
        return

    subfolders = find_pcap_subfolders(numeric_folder)
    for subfolder in subfolders:
        print("\nDecoding subfolder: ", subfolder)
        pcap_files = collect_pcap_files(subfolder)
        if len(pcap_files) == 0:
            print("No pcap files found in subfolder: ", subfolder)
            continue
        run_bat_script(pcap_files, FORMAT)
        run_post_processing_script(subfolder)
        # run_validation_script(subfolder)


if path_flag == "unknown":
    print("Invalid path provided. Please provide a valid Network or system path.")
    sys.exit(1)

# destination path is the path where we have to copy the zip from remote path to our local path

if path_flag == "network":
    # if the path flag is network and there is a destination path donwload the zip to that destination path
    # and pass from there
    zip_filename = os.path.basename(ZIP_PATH)
    if DESTINATION_PATH is None:
        rootfolder_path = os.path.dirname(os.getcwd())
        destination_dir = os.path.join(rootfolder_path, "downloads")
        os.makedirs(destination_dir, exist_ok=True)
        # constructing the destination zip_path
        destination_zip_path = os.path.join(destination_dir, zip_filename)
    else:
        if not os.path.exists(DESTINATION_PATH):
            print("Invalid destination path")
            sys.exit(1)
        destination_dir = DESTINATION_PATH
        destination_zip_path = os.path.join(destination_dir, zip_filename)
    try:
        print("Trying to download tti trace from remote path")
        shutil.copy2(ZIP_PATH, destination_zip_path)
        print(f"✅ File copied to: {destination_zip_path}")
        print(f"Full path of copied file: {destination_zip_path}")
        print("Starting process:..........")
        get_extracted_files(destination_zip_path)
    except OSError as e:
        error_message = str(e).lower()
        print(error_message)
        if "access is denied" in error_message or "permission denied" in error_message:
            print(
                "🔒 Access issue: You don't have permission to access the network location."
            )
            print(
                "👉 Please authenticate using this link: https://authresponse.srnblr.nsn-rdnet.net/"
            )
            user_input = input(
                "Press 'r' to retry after authentication, or any other key to exit: "
            )
            if user_input.lower() == "r":
                restart_script()
        elif (
            "network path not found" in error_message
            or "no such file or directory" in error_message
        ):
            print("🌐 Network error: Unable to access the network location.")
            print(
                "⚠️ Please ensure the host is added to known hosts and the path is correct."
            )
        elif (
            "bad network name" in error_message
            or "host is unreachable" in error_message
        ):
            print("🚫 Host issue: The host may not be allowed or reachable.")
            print("🔧 Please verify that the host is added to your known hosts list.")
        else:
            print(f"❌ OSError encountered: {e}")
    except Exception as e:
        print(f"❗ Unexpected error: {e}")

# if path_flag == "system":
#     # print(DESTINATION_PATH.lower())
#     if not ZIP_PATH.lower().endswith(".zip"):
#         print("Please provide a path for a ZIP file.")
#         sys.exit(1)  # Exit with error code
#     get_extracted_files(ZIP_PATH)
if path_flag == "system":
    # if it is a system path, and destination path exists copy the zip to that path and provide the zip from there
    # and after everything completed delete the zip
    if DESTINATION_PATH is None:
        get_extracted_files(ZIP_PATH)
    else:
        if not os.path.exists(DESTINATION_PATH):
            print("Invalid destination path")
            sys.exit(1)
            # Step 2: Construct destination zip path (same filename in destination)
            zip_filename = os.path.basename(ZIP_PATH)
            destination_zip_path = os.path.join(ZIP_PATH, zip_filename)
        # Step 3: Copy zip to destination
        try:
            print("Trying to download the remote zip folder")

            # shutil.copy2(ZIP_PATH, destination_zip_path)
            copy2_with_progress(ZIP_PATH, destination_zip_path)
            print(f"Copied {ZIP_PATH} to {destination_zip_path}")
        except Exception as e:
            print(f"Error copying file: {e}")
            sys.exit(1)
        # Step 4: Process the copied zip
        get_extracted_files(destination_zip_path)
        # Step 5: Delete the copied zip from destination
        try:
            os.remove(destination_zip_path)
            print(f"Deleted {destination_zip_path}")
        except Exception as e:
            print(f"Error deleting file: {e}")
