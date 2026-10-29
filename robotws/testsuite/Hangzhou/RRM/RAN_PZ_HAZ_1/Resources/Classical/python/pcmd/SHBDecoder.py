# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Xiang Liang
:contact: liang.xiang@nokia-sbell.com
"""

import requests
import json
import os
import zipfile
import re
from datetime import datetime


class SHBDecoder:

    def __init__(self):
        self.url = 'https://treasuremap.dynamic.nsn-net.net:8443/shbDecoder'
        self.uid = 'liaxiang'
        self.email = 'liang.xiang@nokia-sbell.com'

    def decode_file(self, file_path):
        files = {'file': open(file_path, 'rb')}
        data = {
            'network_type': '5G',
            'release_5g': 'TRUNK',
            'component': 'cpcl',
            'uid': self.uid,
            'mail': self.email
        }

        response = requests.post(self.url, files=files, data=data, verify=False)
        response_json = json.loads(response.text)
        decode_file_link = response_json.get('decode_file_link')

        return decode_file_link

    def download_file(self, file_path, save_path):
        url = self.decode_file(file_path)
        response = requests.get(url, stream=True, verify=False)

        if response.status_code == 200:
            content_disposition = response.headers.get('Content-Disposition')
            if content_disposition:
                filename = content_disposition.split('=')[1].strip().replace('"', '')
            else:
                filename = url.split('/')[-1]
            os.makedirs(save_path, exist_ok=True)
            filepath = os.path.join(save_path, filename)

            with open(filepath, 'wb') as file:
                for chunk in response.iter_content(chunk_size=8192):
                    file.write(chunk)

            print(f"file saved to {filepath}")
        else:
            print(f"file downloaded failed，HTTP status code：{response.status_code}")
        if os.path.exists(filepath):
            with zipfile.ZipFile(filepath, 'r') as zip_ref:
                zip_ref.extractall()
        return filepath

    def find_file(self, filepath, target_folder="runtime_shb", file_pattern="cp-rt-ue-shb-thread-1.shb5.txt"):
        directory_path, zip_file_name = os.path.split(filepath)
        print(directory_path, zip_file_name)
        folder_name = os.path.splitext(zip_file_name)[0]
        exact_folder = os.path.join(directory_path, folder_name)
        if os.path.exists(filepath):
            print(filepath)
            with zipfile.ZipFile(filepath, 'r') as zip_ref:
                zip_ref.extractall(path=exact_folder)
        target_folder_full = os.path.join(exact_folder, target_folder)
        target_file_list = self.find_tar_files(target_folder_full, file_pattern)
        print(target_file_list)
        target_file = target_file_list[0]

        for root, dirs, files in os.walk(exact_folder):
            if target_folder in dirs:
                target_dir = os.path.join(root, target_folder)
                for subdir, subdirs, subfiles in os.walk(target_dir):
                    if target_file in subfiles:
                        target_file_path = os.path.join(subdir, target_file)
                        return target_file_path
        print(f"File {target_file} not found in {filepath}")

    def get_time(self, filepath, search_string):
        timestamp_dict = {search_string: []}
        with open(filepath, 'r') as file:
            for line_number, line in enumerate(file, start=1):
                if search_string in line:
                    timestamp = self.extract_timestamp(line)
                    if timestamp:
                        timestamp = datetime.fromisoformat(timestamp[:-1])
                        timestamp_dict[search_string].append((timestamp, line_number))
        for name, timestamp in timestamp_dict.items():
            print(f" {name}: {timestamp}")

        return timestamp_dict

    @staticmethod
    def find_tar_files(tar_dir, file_pattern):
        matches = []
        for root, dirnames, filenames in os.walk(tar_dir):
            for filename in filenames:
                if file_pattern in filename:
                    matches.append(filename)
        return matches

    @staticmethod
    def extract_timestamp(line):
        match = re.search(r'<(.*?)>', line)
        return match.group(1) if match else None


if __name__ == "__main__":
    save_path = r'/home/ute/xiang/xiangliang/'
    decode = SHBDecoder()
    # file_path = decode.download_file(save_path)
    file_path = '/home/ute/xiang/xiangliang/shb_decoded.zip'
    target_file = decode.find_file(file_path)
    decode.get_time(target_file, 'TC_NrAppVendorRecordInd')
    decode.get_time(target_file, 'UEContextSetupResponse')
