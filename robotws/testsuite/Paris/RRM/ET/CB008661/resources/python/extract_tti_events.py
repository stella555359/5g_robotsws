import json
import os
import sys
from io import BytesIO
from zipfile import ZipFile


def get_matching_file_name(pattern, name_list):
    zip_file_name = None
    matching_file_name = None
    for file_name in name_list:
        file_name_str = file_name.decode("utf-8")
        if ".zip:" in file_name_str:
            zip_file_name = file_name_str.strip().replace(":", "")
        if ("L2TtiTrace_EventsSnapshot" in file_name_str) and (pattern in file_name_str):
            matching_file_name = file_name_str.strip().replace(".xz", "")
            break
    print(f"Found {matching_file_name} in {zip_file_name}")
    return zip_file_name, matching_file_name


def process_tti_events(snapshot_file, file_pattern, path, step_name):
    with snapshot_file.open("snapshot_file_list.txt") as snapshot_file_list:
        snapshot_file_list_lines = snapshot_file_list.readlines()
        snapshot_file_list.close()
        zip_name, tti_name = get_matching_file_name(
            file_pattern, snapshot_file_list_lines)
        board_zip = BytesIO(snapshot_file.read(zip_name))
        with ZipFile(board_zip) as board_file:
            tti_path = path + "/" + step_name
            board_file.extract(f"{tti_name}.xz", path=tti_path)
            os.system(f"xz -d {tti_path}/{tti_name}.xz")
            os.system(f"python3 /opt/tti-dec/tti-dec-bin/TtiTraceDecoder.py -o {tti_path}/{step_name} " +
                      f"{tti_path}/{tti_name} json")


def extract_tti_events(snapshot_file_name, path, step_name):
    split_step_name = step_name.split("_")
    frequency_range = split_step_name[3]
    with ZipFile(snapshot_file_name) as snapshot_file:
        if frequency_range == "FR2":
            process_tti_events(snapshot_file, "L2RT_FR2a0", path, step_name)
        #     process_tti_events(snapshot_file, "L2RTa0", path, step_name)


if __name__ == '__main__':
    extract_tti_events(sys.argv[1], sys.argv[2], sys.argv[3])
