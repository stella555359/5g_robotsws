import os
import re
import tarfile
import tempfile
import zipfile
from collections import defaultdict, deque

# Check and install needed libraries
check_pandas = 2
while check_pandas:
    try:
        import pandas as pd
        print('pandas has been installed')
        break
    except Exception:
        print('pandas is not installed.')
        os.system("pip install pandas")
        check_pandas -= 1
        continue


def list_files_iterative(file_path):
    """
    Iteratively lists all files in a directory and its subdirectories, including files in zip and tar archives.

    Args:
        file_path (str): The path to the file or directory.

    Returns:
        dict: A dictionary containing the file names and their sizes.
    """
    file_dict = defaultdict(list)
    with tempfile.TemporaryDirectory() as temp_dir:
        queue = deque([file_path])

        while queue:
            current_file = queue.popleft()

            try:
                if zipfile.is_zipfile(current_file):
                    with zipfile.ZipFile(current_file, "r") as zip_ref:
                        for file in zip_ref.namelist():
                            file_dict[file].append(zip_ref.getinfo(file).file_size)
                            if file.endswith((".zip", ".tar", ".gz")):
                                temp_file_path = os.path.join(temp_dir, file)
                                zip_ref.extract(file, path=temp_dir)
                                queue.append(temp_file_path)

                elif tarfile.is_tarfile(current_file):
                    with tarfile.open(current_file, "r") as tar_ref:
                        for file in tar_ref.getmembers():
                            file_dict[file.name].append(file.size)
                            if file.name.endswith((".zip", ".gz", ".tar")):
                                temp_file_path = os.path.join(temp_dir, file.name)
                                tar_ref.extract(file, path=temp_dir)
                                queue.append(temp_file_path)

            except zipfile.BadZipFile:
                print(f"Bad Zip File: {current_file}")
    return file_dict


def get_rf_sw_line(rfs):
    rf_sw_line_list = []
    rf_sw_line_dict = {
        "mmimo-srm6": [],
        "5ge4": [],
        "5gh4": [],
        "5gd4": [],
        "srm7": ["avql"],
        "5gw5": [],
        "chb": [],
        "cta6": [],
        "riu40ecpri": [],
        "fru6": [],
        "erm6": [],
    }
    rfs_list = rfs.split(",") if rfs else None
    for rf in rfs_list:
        for sw_line, rf_list in rf_sw_line_dict.items():
            if rf in rf_list:
                rf_sw_line_list.append(sw_line)
    return set(rf_sw_line_list)


def get_l1sw_line(hwtype):
    l1sw_line_list = []
    l1sw_line_dict = {
        "loner-tdd-ecpri": ["loner_tdd_ecpri"],
        "loner-fdd-cpri": ["loner_fdd_cpri"],
        "loner-tdd-cpri": ["loner_tdd_cpri"],
        "l1sw": ["LOKI", "THOR"],
    }
    hwtype_list = hwtype.split(",") if hwtype else None
    for bbu in hwtype_list:
        for sw_line, bbu_list in l1sw_line_dict.items():
            if bbu in bbu_list:
                l1sw_line_list.append(sw_line)
    return set(l1sw_line_list)


def get_trbl_log_list_csv(csv_files):
    dfs = pd.read_csv(csv_files, sep=";")
    return dfs.to_dict()


def check_files_in_snapshot(file_dict, f, logs_dict):
    check_size_fail_dict = {}
    tmp_checked_key_list = []
    for id, property in logs_dict.items():
        for filename, sizelist in file_dict.items():
            if re.search(re.sub('[#*]', '.', property[2]), filename):
                tmp_checked_key_list.append(id)
                for size in sizelist:
                    if property[5] == "unlimited":
                        if int(property[4]) * 1024 <= int(size):
                            print(f"[INFO]: property: {property}", file=f)
                            print(f"[INFO]: filename: {filename}, size: {sizelist}", file=f)
                    elif int(property[4]) * 1024 <= int(size) <= int(property[5]) * 1024:
                        print(f"[INFO]: property: {property}", file=f)
                        print(f"[INFO]: filename: {filename}, size: {sizelist}", file=f)
                    else:
                        check_size_fail_dict[id] = property
                        print(
                            f"[ERROR]: {filename} size is out of range. "
                            f"{property[4]}kiB <= {size}bytes <= {property[5]}kiB"
                        )
                        print(f"[INFO]: {property}", file=f)

    log_missing_check_dict = {
        key: logs_dict[key]
        for key in logs_dict.keys() - tmp_checked_key_list
    }
    mandatory_log_missing_dict = {
        key: logs_dict[key]
        for key in log_missing_check_dict.keys()
        if log_missing_check_dict[key][3] == 1
    }

    print("::" * 33 + " log info for failed to check size " + "::" * 33, file=f)
    print("\n[ERROR]:{}\n".format(check_size_fail_dict), file=f)
    print("::" * 33 + " log info for mandatory log missing " + "::" * 33, file=f)
    print("\n[ERROR]:{}\n".format(mandatory_log_missing_dict), file=f)
    print("::" * 33 + " log info for missing logs " + "::" * 33, file=f)
    print("\n[WRN]:{}\n".format(log_missing_check_dict), file=f)
    print("::" * 33 + " l1low log info from csv " + "::" * 33, file=f)
    print("\n[INFO]:{}\n".format(logs_dict), file=f)
    assert not check_size_fail_dict, (
        f'[ERROR] the following logs size are NOT correct: {check_size_fail_dict}'
    )
    assert not mandatory_log_missing_dict, (
        f'[ERROR] the following mandatory logs are missing: {mandatory_log_missing_dict}'
    )


def get_rfs_l1low_and_trbl_dict(rf_sw_line_list, trbl_logs_dict):
    l1low_logs_dict = dict()
    scm_assembly_info = trbl_logs_dict["SCM assembly info"]
    for id, filename in trbl_logs_dict["filename"].items():
        for swline in rf_sw_line_list:
            if "l1low" in filename or 'trbl_logs' in filename and scm_assembly_info[id].startswith(swline):
                l1low_logs_dict[id] = (
                    scm_assembly_info[id],
                    trbl_logs_dict["file container"][id],
                    filename,
                    trbl_logs_dict["mandatory flag"][id],
                    trbl_logs_dict["min size in kiB"][id],
                    trbl_logs_dict["max size in kiB"][id],
                )
    for id, container in trbl_logs_dict["file container"].items():
        for swline in rf_sw_line_list:
            if (
                isinstance(container, str)
                and "l1low" in container
                and scm_assembly_info[id].startswith(swline)
            ):
                l1low_logs_dict[id] = (
                    scm_assembly_info[id],
                    container,
                    trbl_logs_dict["filename"][id],
                    trbl_logs_dict["mandatory flag"][id],
                    trbl_logs_dict["min size in kiB"][id],
                    trbl_logs_dict["max size in kiB"][id],
                )
    return l1low_logs_dict


def get_l1sw_dict(l1sw_line_list, trbl_logs_dict):
    scm_assembly_info = trbl_logs_dict["SCM assembly info"]
    l1sw_logs_dict = dict()
    for id, filename in trbl_logs_dict["filename"].items():
        for swline in l1sw_line_list:
            if scm_assembly_info[id].startswith(swline):
                l1sw_logs_dict[id] = (
                    scm_assembly_info[id],
                    trbl_logs_dict["file container"][id],
                    filename,
                    trbl_logs_dict["mandatory flag"][id],
                    trbl_logs_dict["min size in kiB"][id],
                    trbl_logs_dict["max size in kiB"][id],
                )
    return l1sw_logs_dict


def check_snapshot(rfs, snapshot_zip_path, csv_files, debug_log_path="", bbu_type=""):
    assert rfs, "[ERROR] rfs should NOT be empty. e.g. rfs = 'avql,aehc'."
    try:
        rf_sw_line_list = get_rf_sw_line(rfs)
        l1sw_line_list = get_l1sw_line(bbu_type)
        # get all files name and size in the snapshot to dictionary: file_dict
        file_dict = list_files_iterative(snapshot_zip_path)

        log_path = debug_log_path if debug_log_path else os.path.dirname(snapshot_zip_path)
        debug_log = r"{}/snapshot_checker.log".format(log_path)
        f = open(debug_log, "w+")
        print("[INFO]: {}".format(file_dict), file=f)

        # download and get all logs info from csv files to dictionary: trbl_logs_dict
        trbl_logs_dict = get_trbl_log_list_csv(csv_files)

        # get all l1sw logs info from trbl_logs_dict to dictionary: l1sw_logs_dict
        l1sw_logs_dict = dict()
        if len(l1sw_line_list) > 0:
            l1sw_logs_dict = get_l1sw_dict(l1sw_line_list, trbl_logs_dict)
            print("[l1sw logs dict]: {}".format(l1sw_logs_dict), file=f)
            # check size of l1sw logs and write to debug log
            check_files_in_snapshot(file_dict, f, l1sw_logs_dict)

        # get all l1low logs info from trbl_logs_dict to dictionary: l1low_logs_dict
        l1low_logs_dict = get_rfs_l1low_and_trbl_dict(rf_sw_line_list, trbl_logs_dict)
        print("[l1low logs dict]: {}".format(l1low_logs_dict), file=f)

        # check size of l1low logs and write to debug log
        # to return the dict of logs that failed to check size and mandatory logs missing
        check_files_in_snapshot(file_dict, f, l1low_logs_dict)

    except Exception as e:
        print(f"[ERROR]: {e}", file=f)
    finally:
        f.close()


if __name__ == "__main__":
    pass
