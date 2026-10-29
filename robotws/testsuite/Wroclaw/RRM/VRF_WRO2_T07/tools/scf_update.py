from os import walk, path, listdir, system, makedirs
from sys import argv
from re import search, findall, sub
from collections import defaultdict
from shutil import copy


def create_dict_for_lines(scf_path):
    scf_to_lines = defaultdict(list)
    for file_path, subdirs, files in walk(scf_path):
        for name in files:
            if name.endswith(".xml"):
                line_id = search("[4,5][0-9][0-9][0-9][0-9]", name).group()
                if line_id:
                    scf_to_lines[line_id].append(path.join(file_path, name))
    return scf_to_lines


def get_lines_scf_paths(config_directory, scf_to_lines):
    lines_location = {}
    for file_path, subdirs, files in walk(config_directory):
        for file in files:
            with open(path.join(file_path, file), "r") as scf:
                current_file_str = str(scf.readlines())
                indexes = search("MRBTS-[4,5][0-9][0-9][0-9][0-9]", current_file_str)
                if indexes:
                    line_id = current_file_str[indexes.span()[0] + 6:indexes.span()[1]]
                    if any(line in line_id for line in scf_to_lines.keys()) and line_id not in lines_location.keys():
                        lines_location[line_id] = path.split(file_path)[0] if search("2[0-9]R[1-4]", file_path) \
                            else file_path
    return lines_location


def process_release(release, line):
    directory = [dirs for dirs in listdir(line[1]) if release in dirs]
    if directory:
        release_path = path.join(line[1], directory[0])
        scf_file_path = release_path if path.isfile(release_path) else \
            path.join(release_path, [filename for filename in listdir(release_path) if filename.endswith(".xml")
                                     and "SBTS" in filename][0])
        git_operation = "Update"
    else:
        available_dirs = [path.join(line[1], _dir) for _dir in listdir(line[1]) if path.isdir(path.join(line[1], _dir))]
        scf_base = path.join(available_dirs[0], listdir(path.join(line[1], available_dirs[0]))[0])
        scf_file_path = path.join(line[1], sub("SBTS2[0-9]R[1-4]", "SBTS" + release, scf_base))
        makedirs(path.dirname(scf_file_path), exist_ok=True)
        git_operation = "Create"
    return scf_file_path, git_operation


def process_line(line, scf):
    for version in scf[1]:
        release = findall("2[0-9]R[1-4]", version)[0]
        scf_file_path, git_operation = process_release(release, line)
        copy(version, scf_file_path)
        system("git add {}".format(scf_file_path))
        system("git commit -m '{} scf for line {} on release {}.'".format(git_operation, line[0], release))


if __name__ == "__main__":
    scf_path = path.expanduser("~/vagrant/scf") if len(argv) < 2 else argv[1]
    config_directory = path.expanduser("~/robotws/custom-config/Wroclaw") if len(argv) < 3 else argv[2]
    scf_to_lines = create_dict_for_lines(scf_path)
    lines_location = get_lines_scf_paths(config_directory, scf_to_lines)
    for line in lines_location.items():
        for scf in scf_to_lines.items():
            if line[0] == scf[0]:
                process_line(line, scf)
                scf_to_lines.pop(scf[0])
                break
