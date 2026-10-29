# -*- coding: utf-8 -*-
# Author: johnson.zhou@nokia-sbell.com

import zipfile
import re
import gzip
import xml.etree.ElementTree as ET
import base64


class Bbox5Check(object):

    def __init__(self):
        self.snapshot_file = "snapshot_file_list.txt"
        # self.file_path = file_path
        self.sn = None
        self.snapshot_path = None
        self.bbox_file_name = ""

    def remove_blank_and_colon_in_file5_path(self, file_path):
        for i in range(len(file_path)):
            file_path[i] = str(file_path[i])
            file_path[i] = file_path[i].replace(":", "").strip()
        return file_path

    def get_file5_path(self, all_files_list):
        for i, item in enumerate(all_files_list):
            if isinstance(item, bytes):
                item = item.decode()
                all_files_list[i] = item
            strings = [self.sn, 'BBOX5_all.zip']
            if all(s in item for s in strings):
                file_path = [item]
                while i > 0:
                    i = i - 1
                    if ".zip:" in all_files_list[i]:
                        file_path.append(all_files_list[i])
                        return self.remove_blank_and_colon_in_file5_path(file_path)
                break

    def get_permanent_path(self, all_files_list):
        for i, item in enumerate(all_files_list):
            if isinstance(item, bytes):
                item = item.decode()
                all_files_list[i] = item
            strings = [self.sn, 'permanent.xml.gz']
            if all(s in item for s in strings):
                file_path = [item]
                while i > 0:
                    i = i - 1
                    if ".zip:" in all_files_list[i]:
                        file_path.append(all_files_list[i])
                        return self.remove_blank_and_colon_in_file5_path(file_path)
                break

    def extract_permanent_info(self, sn, snapshot_path):
        self.sn = sn
        self.snapshot_path = snapshot_path
        snapshot_zip = zipfile.ZipFile(self.snapshot_path, "r")
        if self.snapshot_file in snapshot_zip.namelist():
            all_files_list = snapshot_zip.open("snapshot_file_list.txt").readlines()
            file_path = self.get_permanent_path(all_files_list)
            snapshot_zip.extract(file_path[1])
            snapshot_zip.close()
            with zipfile.ZipFile(file_path[1], "r") as bboxZip:
                permanent = bboxZip.extract(file_path[0], path="/tmp")
            with gzip.open(permanent, "rb") as f:
                file_content = f.read()

            root = ET.fromstring(file_content)
            if root[1][0][0][3][0].text == "BtsId":
                info = root[1][0][0][3][1].text
                deinfo = base64.b64decode(info)
                return deinfo
            else:
                return "no BtsId info"

    def extract_bbox5_file(self):
        snapshot_zip = zipfile.ZipFile(self.snapshot_path, "r")
        if self.snapshot_file in snapshot_zip.namelist():
            all_files_list = snapshot_zip.open("snapshot_file_list.txt").readlines()
            file_path = self.get_file5_path(all_files_list)
            snapshot_zip.extract(file_path[1])
            snapshot_zip.close()
            with zipfile.ZipFile(file_path[1], "r") as bboxZip:
                BBOX5 = bboxZip.extract(file_path[0], path="/tmp")
            with zipfile.ZipFile(BBOX5, "r") as bboxZip1:
                bboxZip1.extractall(path="/tmp")
                self.bbox_file_name = "/tmp/BBOX5"

    def check_bbox5_file_contents(self, sn, snapshot_path, patt):
        self.sn = sn
        self.snapshot_path = snapshot_path
        self.extract_bbox5_file()
        self.message = []

        with open((self.bbox_file_name), "r") as f:
            for line in f.readlines():
                pattern = re.compile(patt)
                result = pattern.findall(line)
                if len(result) > 0:
                    self.message.append(line)
        return self.message


# def check_bbox5(sn, snapshot_path, patt):
#     instance = Bbox5Check()
#     return instance.check_bbox5_file_contents(sn,snapshot_path, patt)
