import zipfile
import os
import subprocess
from pathlib import Path


def resource_path(relative_path):
    """Get absolute path to resource, works for dev and for PyInstaller"""
    # base_path = getattr(sys, '_MEIPASS', os.path.dirname(os.path.abspath(__file__)))
    # return os.path.join(base_path, relative_path)
    return relative_path


def unzip_file(zip_path, extract_to):
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(extract_to)


def find_numeric_folder(base_dir):
    for entry in os.listdir(base_dir):
        full_path = os.path.join(base_dir, entry)
        if os.path.isdir(full_path) and entry.isdigit():
            return full_path
    return None


def find_pcap_subfolders(numeric_folder):
    return [
        os.path.join(numeric_folder, sub)
        for sub in os.listdir(numeric_folder)
        if os.path.isdir(os.path.join(numeric_folder, sub))
    ]


def collect_pcap_files(folder):
    return [
        os.path.join(folder, f)
        for f in os.listdir(folder)
        if f.endswith(".pcap") and os.path.isfile(os.path.join(folder, f))
    ]


# def run_bat_script(pcap_files, format):
#     if not pcap_files:
#         return
#     # command = ["TtiTraceHelper.exe"] + pcap_files + ["--format", format]
#     full_pcap = ""
#     for file in pcap_files:
#         full_pcap += file + " "
#     # command = [get_binary_path()] + pcap_files + ["--format", format]
#     command = f"{get_binary_path()} {full_pcap}--format {format}"
#     print(command)
#     subprocess.run(command, shell=True)


# target_suffixes = ['dlPdcchDciData.csv', 'ulPdcchDciData.csv']


def run_post_processing_script(output_folder):
    # Define required suffixes

    # dlPdcchDciData_dci_decode.csv
    # ulPdcchDciData_dci_decode.csv
    all_present = True
    expected_files = ["dlPdcchDciData_dci_decode.csv", "ulPdcchDciData_dci_decode.csv"]
    for expected_file in expected_files:
        found = False
        for file in os.listdir(output_folder):
            if file.endswith(expected_file):
                found = True
                break
        if not found:
            print(f"Missing expected files {expected_files}")
            print("Starting Dci Decoding...")
            all_present = False
            break
    if not all_present:
        required_suffixes = ["dlPdcchDciData.csv", "ulPdcchDciData.csv"]
        found_files = {}

        # Search for each required file
        for suffix in required_suffixes:
            for file in os.listdir(output_folder):
                if file.endswith(suffix):
                    found_files[suffix] = os.path.join(output_folder, file)
                    break

        # Check if all required files were found
        missing = [s for s in required_suffixes if s not in found_files]
        if missing:
            raise FileNotFoundError(
                f"Missing required output files: {', '.join(missing)}"
            )

        # Run decoding script one file at a time
        # Decode_PDCCH_Dciinfio
        SCRIPT_DIR = Path(__file__).parent
        decode_script = SCRIPT_DIR / "pdcch_dci_decode2_9_5.py"
        for suffix in required_suffixes:
            file_path = found_files[suffix]
            # command = [
            #     "python",
            #     resource_path("utils/pdcch_dci_decode2_9_5.py"),
            #     file_path,
            # ]
            command = f"python {decode_script} {file_path}"
            print(f"Running post-processing on: {file_path}")
            subprocess.run(command, shell=True)
    else:
        print("Skipping post processing. Since dci decode files already exists.")
        print("SSSG Verification Started......")


# we just need to get the path of the subfolder from here.
def run_validation_script(folder_path, threshold):
    command = ["python", "validation_script.py", folder_path, "--threshold", threshold]
    subprocess.run(command, shell=True)
