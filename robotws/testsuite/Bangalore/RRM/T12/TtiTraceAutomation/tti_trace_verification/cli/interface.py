# cli/interface.py
import argparse
import os
import sys
import time

# from utils.loader import load_dataframes
DEFAULT_FILES_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "Files")
# print(DEFAULT_FILES_DIR)


def get_args():
    """
    Function to get the arugments from the CLI
    """
    # 🧭 CLI setup
    parser = argparse.ArgumentParser(
        description="Process CSV/Excel and XML threshold files."
    )
    # parser.add_argument(
    #     '--files_dir',
    #     default=DEFAULT_FILES_DIR,
    #     help='Path to the directory containing CSV files. Defaults to ./Files'
    # )
    parser.add_argument("zip_path", help="Path to the zip file")
    # parser.add_argument('--threshold', required=True, help='Path to XML threshold file')
    parser.add_argument(
        "--format",
        help="Enter the format you wanted defaults to EventCsv",
        default="eventCsv",
    )
    parser.add_argument(
        "--decoded",
        action="store_true",
        help="Skip unzip step if files are already unzipped",
    )
    parser.add_argument(
        "--destination_path", help="Provide the destination path.", default=None
    )
    parser.add_argument(
        "--scf_file", help="Provide the destination path.", default=None
    )
    parser.add_argument(
        "--unzipped", help="Provide the unzipped folder path.", default=None
    )

    # parser.add_argument('--uetype', required = True, help='Describe the type of UE using
    # redcap for RedCapUE and nonredcap for NonRedCapUE')
    # parser.add_argument('--combine', required=False,action="store_true",help='Describe True
    #  or False whether you need a debugExcel file True for Yes eles False')

    # parser.add_argument('--data', required=True, help='Path to CSV or Excel file')
    return parser.parse_args()


def blinking_cursor(duration=2):
    end_time = time.time() + duration
    while time.time() < end_time:
        sys.stdout.write("\r|")
        sys.stdout.flush()
        time.sleep(0.5)
        sys.stdout.write("\r ")
        sys.stdout.flush()
        time.sleep(0.5)


def type_out(*args, delay=0.001, sep=" ", end="\n"):
    text = sep.join(str(arg) for arg in args)
    for char in text + end:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(delay)
