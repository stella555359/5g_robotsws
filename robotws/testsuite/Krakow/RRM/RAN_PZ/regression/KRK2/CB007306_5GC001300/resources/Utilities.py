# -*- coding: utf-8 -*-
"""
Author: Mateusz Jaskot  mateusz.jaskot@nokia.com
Maintainer: Mateusz Jaskot  mateusz.jaskot@nokia.com
Description: Additional Functions for FR 5GC001300
"""
import logging
import glob
import os
import zipfile


def unpacking_and_removing_zip_file(path='./', dest_path="./", filter=None):
    try:
        file_name_list = [f for f in glob.glob(filter)]
        file_name = file_name_list[0]
    except Exception:
        logging.warning("don't exist zip file exist in {}".format(path))
        raise
    try:
        extract_file(zfile=file_name, dest=dest_path)
    except Exception as e:
        logging.warning("Zipfile: {} failed with error: {}".format(file_name, e))
        raise
    try:
        os.remove(file_name)
    except Exception as e:
        logging.warning("file: {} failed during removing with error : {}".format(file_name, e))
        raise
    return file_name[:-4]


def extract_file(zfile, dest="./"):
    with zipfile.ZipFile(zfile, 'r') as zip_ref:
        zip_ref.extractall(dest)


def looking_for_file_name(path='./', file_name=None):
    file_names = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.lower().endswith(file_name):
                file_names.append(file)

    return file_names[0]
