from zipfile import ZipFile
import lzma
from os import path
import re
import tarfile

""" Scripts created to unzip specific file and search for given string in snapshot files.
    This is an aproximate copy from the snapshot_check.py from clasica.
    This may not be a final solution. Better implementation can be made.
"""


def check_snapshot_content(file, string):
    content = []
    with lzma.open(file, mode='rt') as file:
        for line in file:
            if string in line:
                content.append(line)
    return content


def extract_snapshot_content(snapshot_file, content):
    extraction_path = snapshot_file[0:snapshot_file.rfind('/') + 1]
    zip_content, file_name = _check_snapshot_file_list(snapshot_file, content)
    with ZipFile(snapshot_file) as zip_snapshot:
        zip_snapshot.extract(zip_content, path=extraction_path)
    with ZipFile(str(path.join(extraction_path, zip_content))) as content_zip:
        file_content = content_zip.extract(file_name, path=extraction_path)
    if '.zip' in file_content:
        _additional_zip_extraction_needed(file_content, extraction_path)
    if '.tgz' in file_content:
        _additional_tgz_extraction_needed(file_content, extraction_path)
    return extraction_path


def _additional_zip_extraction_needed(additional_zip, path_extraction):
    with ZipFile(str(path.join(path_extraction, additional_zip))) as content_zip:
        content_zip.extractall(path=path_extraction)


def _additional_tgz_extraction_needed(additional_zip, path_extraction):
    with tarfile.open(path.join(path_extraction, additional_zip)) as content_tar:
        content_tar.extractall(path=path_extraction)


def _check_snapshot_file_list(snapshot, content):
    with ZipFile(snapshot) as zip_snapshot:
        zip_snapshot.extract('snapshot_file_list.txt')
    content_zip, file_name = _search_for_content('snapshot_file_list.txt', content)
    return content_zip.replace(':', '').strip(), file_name.strip()


def _search_for_content(snapshot_file_list, content):
    with open(snapshot_file_list) as file_list:
        for row in file_list:
            if "    " not in row:
                flag = row
            if re.search(content, row):
                return flag, row
    return None
