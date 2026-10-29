# -*- coding: utf-8 -*-
# @Time    : 2023/9/25 20:23
# @Author  : Jian.1.Chen
# @Email   : jian.1.chen@nokia-sbell.com
# @File    : analysis_snapshot.py
# @Software: PyCharm
import zipfile
import os
import lzma
import shutil
import tarfile
from csvanalyzer import get_all_items_value


def my_uncsvxz(csv_xz_file):
    tar_file_path = csv_xz_file.replace(".csv.xz", ".csv")
    with lzma.open(csv_xz_file, "rb") as input_:
        with open(tar_file_path, "wb") as f:
            shutil.copyfileobj(input_, f)
    return tar_file_path


def my_unzip(zip_file):
    zip_folder = zip_file.replace(".zip", "")
    with zipfile.ZipFile(zip_file, "r") as zip_ref:
        if not os.path.exists(zip_folder):
            os.mkdir(zip_folder)
            zip_ref.extractall(zip_folder)
    return zip_folder


def my_untar(tar_file):
    try:
        with tarfile.open(tar_file, mode="r:*") as tar:
            tar_folder = tar_file.replace(".tar", "")
            tar.extractall(path=tar_folder)
    except tarfile.ReadError:
        pass


def decompression_folder(folder):
    for root, dirs, files in os.walk(folder):
        for file in files:
            try:
                if file.endswith(".zip"):
                    zip_file = root + "//" + file
                    my_unzip(zip_file)
                    os.remove(zip_file)
                elif file.endswith(".tar"):
                    tar_file = root + "//" + file
                    my_untar(tar_file)
                    os.remove(tar_file)
            except zipfile.BadZipFile:
                pass


def find_special_file_from_folder(folder, special_file):
    file_list = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            try:
                if special_file in file:
                    file_list.append(root + "/" + file)
            except zipfile.BadZipFile:
                pass
    return file_list


def get_file_path_from_snapshot_file_list(file_name, snapshot_file):
    snapshot_folder = my_unzip(snapshot_file)
    with open(snapshot_folder + "//" + "snapshot_file_list.txt", "r") as fr:
        lines = fr.readlines()
        for line in lines:
            if line.startswith("BTS"):
                sub_zip = line.replace("\n", "")
            if line.find(file_name) != -1:
                target_sub_zip = snapshot_folder + "//" + sub_zip.split(":")[0]
                target_file_name = line.replace(" ", "").replace("\n", "")
    return target_sub_zip, target_file_name


def get_file_size_from_zip(file_name, zip_file):
    zip_folder = my_unzip(zip_file)
    file_sizes = {}
    for root, dirs, files in os.walk(zip_folder):
        for file in files:
            if file_name in file:
                file_size = os.path.getsize(root + "//" + file)
                file_sizes[file] = file_size
    return file_sizes


def get_file_size_from_snapshot_file_list(file_name, snapshot_file):
    snapshot_folder = my_unzip(snapshot_file)
    decompression_folder(snapshot_folder)
    decompression_folder(snapshot_folder)
    file_sizes = {}
    with open(snapshot_folder + "//" + "snapshot_file_list.txt", "r") as fr:
        lines = fr.readlines()
        for line in lines:
            if line.find(":") != -1:
                sub_zip = line.replace("\n", "").replace(" ", "").replace(".zip", "")
                sub_zip = sub_zip.split(":")[0]
            if line.find(file_name) != -1:
                target_sub_zip = snapshot_folder + "//" + sub_zip + "//"
                target_file_name = target_sub_zip + line.replace(" ", "").replace("\n", "")
                file_size = os.path.getsize(target_file_name)
                file_sizes[line.replace(" ", "").replace("\n", "")] = file_size
                print(target_file_name)
                print(file_size)
    return file_sizes


def get_diagnostic_report_from_snapshot(file_name, snapshot_file):
    sub_zip, file_name = get_file_path_from_snapshot_file_list(file_name, snapshot_file)
    sub_zip_folder = my_unzip(sub_zip)
    target_csv = my_uncsvxz(sub_zip_folder + "//" + file_name)
    return get_all_items_value(target_csv)
