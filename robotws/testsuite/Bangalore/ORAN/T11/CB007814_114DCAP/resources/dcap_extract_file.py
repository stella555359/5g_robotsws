#!/usr/bin/python
# -*- coding: utf-8 -*-
import glob
import zipfile
import shutil


def unzip_and_extract_file_name(dcap_dir, target_dir, file_pattern):
    with zipfile.ZipFile(dcap_dir, 'r') as zip_ref:
        zip_ref.extractall(target_dir)
    files = glob.glob(target_dir + file_pattern, recursive=True)
    for file in files:
        shutil.copy(file, target_dir)
