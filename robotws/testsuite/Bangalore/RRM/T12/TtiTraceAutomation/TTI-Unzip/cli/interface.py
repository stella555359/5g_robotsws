# cli/interface.py
import argparse
import textwrap

# import os
# import sys, time
# from utils.loader import load_dataframes
# DEFAULT_FILES_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)),'Files')
# print(DEFAULT_FILES_DIR)


def get_args():
    # 🧭 CLI setup
    parser = argparse.ArgumentParser(
        description="The script processes ZIP files and extract pcap files and converts them into EventCsv",
        epilog=textwrap.dedent(
            r"""
        Examples:
        python main.py --help                : to get help
        python main.py /path/to/your/file    : This can be a network path or a system path
        python main.py /path/to/your/file --destination_path /path/to/where/you/want/to/download/from/dcapserver
        [--destination_path] is optional , if not specified
        it will download in the /downloads folder in the current directory

        Valid network paths:
        //10.164.234.10/servername/foldername/<TRACE_ID>
        //10.164.123.10/servername/foldername/713


        Valid system paths:
        C:\Users\username\Documents\0511\UTFLab_2025-09-28T06_54_35.399Z.zip
        C:\Desktop\0511\UTFLab_2025-09-28T06_54_35.399Z.zip

        """
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    # parser.add_argument(
    #     '--files_dir',
    #     default=DEFAULT_FILES_DIR,
    #     help='Path to the directory containing CSV files. Defaults to ./Files'
    # )
    parser.add_argument("zip_path", help="Path to Network path or System path")
    parser.add_argument(
        "--destination_path", help="Provide the destination path.", default=None
    )
    parser.add_argument(
        "--format", help="Provide the desired format.", default="eventCsv"
    )
    # parser.add_argument('--threshold', required=True, help='Path to XML threshold file')
    # parser.add_argument('--uetype', required = True, help='Describe the type of UE
    # using redcap for RedCapUE and nonredcap for NonRedCapUE')
    # parser.add_argument('--combine', required=False,action="store_true",
    # help='Describe True or False whether you need a debugExcel file True for Yes eles False')

    # parser.add_argument('--data', required=True, help='Path to CSV or Excel file')
    return parser.parse_args()


# def blinking_cursor(duration=2):
#     end_time = time.time() + duration
#     while time.time() < end_time:
#         sys.stdout.write('\r|')
#         sys.stdout.flush()
#         time.sleep(0.5)
#         sys.stdout.write('\r ')
#         sys.stdout.flush()
#         time.sleep(0.5)


# def type_out(*args, delay=0.003, sep=' ', end='\n'):
#     text = sep.join(str(arg) for arg in args)
#     for char in text + end:
#         sys.stdout.write(char)
#         sys.stdout.flush()
#         time.sleep(delay)
