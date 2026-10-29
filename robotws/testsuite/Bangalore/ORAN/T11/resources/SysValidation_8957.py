import zipfile
import tarfile
import os
from taf.analyzer.syslog import BtslogReader


def validate_syslog_file_contents(search_string,   dir_path=".",  file_pattern="SYSLOG*.LOG"):
    matching_dicts = []
    results = [log_entry.asdict() for log_entry in BtslogReader.from_dir(
        dir_path=dir_path, file_pattern=file_pattern) if log_entry.line]

    for item in results:
        line = item["line"]
        if search_string and search_string.encode() in item["line"]:
            matching_dicts.append(item["line"])
    return matching_dicts


def Check_bts_logs(path):
    my_tar = tarfile.open(os.path.join(path, 'syslog_files.tgz'))
    my_tar.extractall(path)
    my_tar.close()
