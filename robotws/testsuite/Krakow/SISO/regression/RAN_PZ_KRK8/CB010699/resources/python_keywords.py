import os
import re
import logging
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.util.moler_test import MolerTest
from pathlib import Path

path_to_unzip = "/home/ute/srcel/UNZIPSCREL"
file_path = "/home/ute/srcel"


class MissingFileException(Exception):
    pass


@load_moler_configuration_from_tl()
def unpack_screll(file_path):
    vm = DeviceFactory.get_device(name="TEST_PC")
    zip_directory = file_path
    path_to_unpack = zip_directory

    ls_screl_cmd = vm.get_cmd(
        cmd_name="ls",
        cmd_params={
            "options": "-la srcel",
        },
    )
    ls_screl_cmd()

    unzip_screl_cmd = vm.get_cmd(
        cmd_name="unzip",
        cmd_params={"zip_file": file_path, "extract_dir": path_to_unzip},
    )
    unzip_screl_cmd()

    cd_to_folder_cmd = vm.get_cmd(cmd_name="cd", cmd_params={"path": path_to_unzip})
    cd_to_folder_cmd()

    find_zip_cmd = vm.get_cmd(
        cmd_name="find",
        cmd_params={
            "options": ". -name '*.zip' -exec sh -c 'unzip -o -d \"${1%.*}\" \"$1\"' _ {} \\;"
        },
    )
    find_zip_cmd()


@load_moler_configuration_from_tl()
def get_files_list():
    vm = DeviceFactory.get_device(name="TEST_PC")

    cd_cmd = vm.get_cmd(cmd_name="cd", cmd_params={"path": path_to_unzip})
    cd_cmd()

    rm_zip_files_cmd = vm.get_cmd(
        cmd_name="find",
        cmd_params={
            "options": '{} -name "BTS*_*_part_*.zip" -exec rm {} \\;'.format(
                path_to_unzip, "{}"
            )
        },
    )
    rm_zip_files_cmd()

    ls_la_cmd = vm.get_cmd(
        cmd_name="ls",
        cmd_params={"path": path_to_unzip, "options": "-la"},
    )

    output_path_to_unzip = ls_la_cmd()
    MolerTest.info(output_path_to_unzip)

    unzip_zip_cmd = vm.get_cmd(
        cmd_name="find",
        cmd_params={
            "options": ". -name '*.zip' -exec sh -c 'unzip -o -d \"${1%.*}\" \"$1\"' _ {} \\;"
        },
    )
    unzip_zip_cmd()

    ls_unpacked = vm.get_cmd(
        cmd_name="ls",
        cmd_params={"path": path_to_unzip, "options": "-d */"},
    )
    ls_unpacked_parent_dirs = ls_unpacked()
    MolerTest.info("ls unpacked: {}".format(ls_unpacked))
    logging.info("ls unpacked: {}".format(ls_unpacked))

    list_unpacked_files = []
    for directory, value in ls_unpacked_parent_dirs["files"].items():
        print("directory: {}".format(directory))
        ls_unpacked_dir = vm.get_cmd(
            cmd_name="ls",
            cmd_params={
                "path": "{}/*".format(path_to_unzip),
                "options": "-la".format(directory),
            },
        )
        ls_unpacked_output = ls_unpacked_dir()

        list_unpacked_files.append({directory: ls_unpacked_output["files"]})

        MolerTest.info("File list:{}".format(list_unpacked_files))

    for subdir, dirs, files in os.walk(
            "{}/*".format(path_to_unzip, ls_unpacked_output)
    ):
        if "*runtime.zip" in files:
            rm_cmd = vm.get_cmd(
                cmd_name="find",
                cmd_params={"options": '-name "*runtime.zip" -exec rm {} \\;'},
            )
            rm_cmd()
        else:
            continue
    MolerTest.info("Runtime zip unpacked")


def traverse_directories(path: Path):
    if not isinstance(path, Path):
        path = Path(path)
    files = []
    for item in path.iterdir():
        if item.is_dir():
            files.append(item)
            files.extend(traverse_directories(item))
        else:
            files.append(item)
    return files


def convert_paths_to_str(paths: list[Path]) -> list[str]:
    return [str(path) for path in paths]


def load_expected_names_file(filepath: str) -> list[str]:
    with open(filepath, "r") as f:
        return f.readlines()


def check_files(files, expected_files):
    missing_files = []
    for expected_filename in expected_files:
        print(expected_filename)
        file_found = False
        for file in files:
            if expected_filename in file.name:
                file_found = True
                print(f"file: {file}")
                break
            if expected_filename == "swupdate.log":
                print("File swupdate.log is present")
        if not file_found:
            missing_files.append(expected_filename)

    for item in files:
        check_pm_counters(item)

    if missing_files:
        print("Missing files:")
        for file in missing_files:
            print(file)
        raise MissingFileException("Missing files list: {}".format(missing_files))
    else:
        print("All required files are present.")


def check_pm_counters(potential_pm_counter):

    pm_list = re.findall("PM.", "pm")

    list = len(pm_list)
    logging.info(
        "POTENTIAL PM counter to check by regex: {}".format(potential_pm_counter)
    )
    if re.search(
            r"PM.*BTS\-\d+\.([1-9][0-9][0-9]{2})([0][1-9]|[1][0-2])([1-2][0-9]|[0][1-9]|[3][0-1])",
            str(potential_pm_counter),
    ):
        logging.info("Found PM counters{}".format(list))
    else:
        logging.info("NO PM counters found")
