import os
import re
import csv


def get_snapshot_file_orgnization(file_folder):
    snapshot_file = os.path.join(file_folder, "snapshot_file_list.txt")
    file_tree = {}
    with open(snapshot_file, "r") as snapshot_files:
        file_structure = snapshot_files.read().split("\n\n")
        for file in file_structure:
            if file.count(".zip") > 0:
                zip_info = re.split(":.*\n", file)
                file_tree[zip_info[0]] = []
                file_list = zip_info[1].splitlines()
                for file_name in file_list:
                    file_tree[zip_info[0]].append(file_name.strip())
            else:
                file_tree[file] = None
    return file_tree


def decode_snapshot(file_folder, str):
    snapshot_file = os.path.join(file_folder, "snapshot_file_list.txt")
    with open(snapshot_file, "r") as snapshot_files:
        lines = snapshot_files.readlines()
        for line in lines:
            if line.count(str) > 0:
                break
        raise Exception("snapshot_file_list cannot find %s!" % str)
    return line


def get_file_from_snapshot_by_key(key_name, snapshot_structure):
    for key, value in snapshot_structure.items():
        if key.count(".zip") > 0:
            for name in value:
                if name.count(key_name) > 0:
                    return key, name
        else:
            if key.count(key_name) > 0:
                return file_folder, key


def decode_csv(csv_filename):
    with open(csv_filename, 'rb') as csvfile:
        lines = csvfile.readlines()
        count = len(lines)
    if count <= 10:
        raise Exception("file is invalid")


def filter_new_snapshot_file_by_btsid(old_file_list, new_file_list, bts_id):
    new_files = []
    for item in new_file_list:
        if item not in old_file_list:
            new_files.append(item)
    for snapshot in new_files:
        if snapshot.count("MRBTS-%d" % int(bts_id)):
            return snapshot


def get_faults_list(fault_file_path):
    fault_dict = {}
    with open(fault_file_path, "r") as fault_file:
        faults_lines = fault_file.readlines()
        key = None
        for line in faults_lines:
            if line.count("ctive faults") > 0:
                key = line.strip()
                fault_dict[key] = []
            if key:
                if line.strip().startswith("20"):
                    fault_id = line.split()[2].replace("(", "").replace(")", "")
                    fault_dict[key].append(fault_id)
    return fault_dict


def get_one_row_as_defined_str(csv_filename, str):
    with open(csv_filename)as f:
        f_csv = csv.reader(f)
        for row in f_csv:
            row = "".join(row)
            if row.find(str) >= 0:
                return row
                break
        raise Exception("file cannot find defined info!")


def get_all_row_as_defined_str(csv_filename, str):
    with open(csv_filename)as f:
        f_csv = csv.reader(f)
        row_list = []
        for row in f_csv:
            row = "".join(row)
            if row.find(str) >= 0:
                row_list.append(row)
        if row_list:
            return row_list
        else:
            raise Exception("file cannot find defined info!")
