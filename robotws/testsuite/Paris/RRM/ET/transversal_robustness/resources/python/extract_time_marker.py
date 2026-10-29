import json
import os
import sys
from io import BytesIO
from zipfile import ZipFile


def get_sw_version(name_list):
    sw_version = "unknown"
    for file_name in name_list:
        if ".ims2" in file_name:
            sw_version = file_name[
                         -len("SBTS22R3_ENB_9999_220129_000004_20220131-0557.ims2"):-len("_20220131-0557.ims2")]
    return sw_version.strip()


def get_board_type(name_list):
    board_type = "unknown"
    for file_name in name_list:
        file_name_str = file_name.decode("utf-8")
        if "ASPA" in file_name_str:
            board_type = "ABIL"
        elif "ASPC" in file_name_str:
            board_type = "ABIN"
        elif "ASPD" in file_name_str:
            board_type = "ABIO"
        elif "ASCB" in file_name_str:
            board_type = "ASOD"
    return board_type


def get_matching_file_name(pattern, name_list):
    zip_file_name = None
    matching_file_name = None
    for file_name in name_list:
        file_name_str = file_name.decode("utf-8")
        if ".zip:" in file_name_str:
            zip_file_name = file_name_str.strip().replace(":", "")
        if ("TimeMarkerSnapshot" in file_name_str) and (pattern in file_name_str):
            matching_file_name = file_name_str.strip().replace(".xz", "")
            break
    print(f"Found {matching_file_name} in {zip_file_name}")
    return zip_file_name, matching_file_name


def get_commit_sha(tm_name):
    with open(tm_name) as tm_file:
        json_data = json.load(tm_file)
        tm_file.close()
        return json_data["snapshotData"]["moduleData"]["5gnbSwVersion"].split("git-commit:")[1]


def add_to_description_json(perf_portal_info, tm_name, test_name, variant_prefix, techno, board_type, variant_suffix):
    print(f"Adding entry for {tm_name}")
    test_entry = {
        "TestName": test_name,
        "VariantName": f"{variant_prefix}_{techno}_CFG_{variant_suffix}",
        "Board": board_type,
        "timeMarkerSnapshotPresent": True,
        "timeMarkerSnapshotPath": tm_name,
        "etracerPresent": False,
        "etracerPath": "",
        "Iteration": "0_0_0",
        "Verdict": "PASSED",
        "Last": True}
    perf_portal_info.append(test_entry)


def process_time_marker(snapshot_file, ori_tm_pattern, path, test_name, variant_prefix,
                        techno, variant_suffix, perf_portal_info):
    with snapshot_file.open("snapshot_file_list.txt") as snapshot_file_list:
        snapshot_file_list_lines = snapshot_file_list.readlines()
        snapshot_file_list.close()
        board_type = get_board_type(snapshot_file_list_lines)
        zip_name, ori_tm_name = get_matching_file_name(ori_tm_pattern, snapshot_file_list_lines)
        board_zip = BytesIO(snapshot_file.read(zip_name))
        with ZipFile(board_zip) as board_file:
            variant_path = test_name + "_" + variant_prefix + "_" + variant_suffix
            time_marker_path = path + "/" + variant_path
            board_file.extract(f"{ori_tm_name}.xz", path=time_marker_path)
            os.system(f"xz -d {time_marker_path}/{ori_tm_name}.xz")
            pbi_tm_name = \
                f"TimeMarkerSnapshot_L2RT_{test_name}_{variant_prefix}_{techno}_{board_type}_CFG_{variant_suffix}.json"
            os.system(f"mv {time_marker_path}/{ori_tm_name} {time_marker_path}/{pbi_tm_name}")
            add_to_description_json(perf_portal_info, pbi_tm_name, test_name,
                                    variant_prefix, techno, board_type, variant_suffix)


def write_perf_portal_info(path, step_name, test_name, variant_prefix, variant_suffix, perf_portal_info):
    variant_path = test_name + "_" + variant_prefix + "_" + variant_suffix
    with open(f"{path}/{variant_path}/perf_portal.json", "w") as perf_portal_json:
        json.dump(perf_portal_info, perf_portal_json, indent=1)
        perf_portal_json.close()
    with open(f"{path}/{step_name}_to_portal.sh", "w") as perf_portal_sh:
        commit_sha = get_commit_sha(f"{path}/{variant_path}/{perf_portal_info[0]['timeMarkerSnapshotPath']}")
        # BHR begin 18/10/2024 : Add line in sh to copy "CrtRoot/robotws/tranversal_robustness/resources/perf_portal/"
        # to "CrtRoot/logs/TimeMarker/"
        # perf_portal_sh.writ e(f"cp -pr /home/ute/CrtRoot/robotws/testsuite/Paris/RRM/ET/")
        # perf_portal_sh.write(f"transversal_robustness/resources/perf_portal .\n")
        # BHR end
        perf_portal_sh.write(f"python3 perf_portal.py --softwareCommit {commit_sha} --testType ET ")
        # perf_portal_sh.write(f"--dirKpi ../../TimeMarker/{variant_path}/")
        perf_portal_sh.write(f"--dirKpi ../TimeMarker/{variant_path}/\n")
        perf_portal_sh.close()


def extract_time_marker(snapshot_file_name, path, feature, step_name):
    split_step_name = step_name.split("_")
    test_name = f"{feature}_{split_step_name[0]}"
    variant_prefix = f"{split_step_name[1]}_{split_step_name[2]}"
    frequency_range = split_step_name[3]
    perf_portal_info = []
    with ZipFile(snapshot_file_name) as snapshot_file:
        # sw_version = get_sw_version(snapshot_file.namelist())
        if frequency_range == "FR2":
            variant_suffix = f"{step_name.split(frequency_range + '_')[1]}_CG1"
            process_time_marker(snapshot_file, "L2RTa0",
                                path, test_name, variant_prefix, "TDD125", variant_suffix, perf_portal_info)
            # variant_suffix = f"{split_step_name[4]}_{split_step_name[5]}_CG2"
            # process_time_marker(snapshot_file, "L2RT21",
            #                     path, test_name, variant_prefix, "TDD125", variant_suffix, perf_portal_info)

        # BHR begin 16/10/2024 : new case add for new KRK TCs.
        elif frequency_range == "FR1":
            variant_suffix = f"{step_name.split(variant_prefix + '_')[1]}_CG2"
            # process_time_marker(snapshot_file, "L2RTa0",
            #                     path, test_name, variant_prefix, "FDD1000", variant_suffix, perf_portal_info)
            # process_time_marker(snapshot_file, "L2RTa1",
            #                     path, test_name, variant_prefix, "TDD500", variant_suffix, perf_portal_info)
            process_time_marker(snapshot_file, "L2RT_FDDa0",
                                path, test_name, variant_prefix, "FDD1000", variant_suffix, perf_portal_info)
            process_time_marker(snapshot_file, "L2RT_TDDa1",
                                path, test_name, variant_prefix, "TDD500", variant_suffix, perf_portal_info)
        # BHR end

        else:
            variant_suffix = f"{step_name.split(variant_prefix + '_')[1]}"
            process_time_marker(snapshot_file, "L2RTa0",
                                path, test_name, variant_prefix, "FDD1000", variant_suffix, perf_portal_info)
            process_time_marker(snapshot_file, "L2RTb0",
                                path, test_name, variant_prefix, "TDD500", variant_suffix, perf_portal_info)
    write_perf_portal_info(path, step_name, test_name, variant_prefix, variant_suffix, perf_portal_info)


if __name__ == '__main__':
    extract_time_marker(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
