# -*- coding: utf-8 -*-
# Author: johnson.zhou@nokia-sbell.com

import zipfile
import shutil
import os
from robot.api.deco import keyword


class BboxCheck(object):
    ROBOT_AUTO_KEYWORDS = False

    def __init__(self):
        self.snapshot_file = 'snapshot_file_list.txt'
        # self.file_path = file_path
        self.snapshot_path = None
        self.bbox_file_name = ""

    def close_snapshot_handler(self):
        self.snapshot_zip.close()

    def remove_blank_and_colon_in_file_path(self, file_path):
        for i in range(len(file_path)):
            file_path[i] = str(file_path[i])
            file_path[i] = file_path[i].replace(":", "").strip()
        return file_path

    def get_file_path(self, all_files_list):
        for i, item in enumerate(all_files_list):
            if isinstance(item, bytes):
                item = item.decode()
                all_files_list[i] = item
            if 'BBOX5.xz' in item:
                file_path = [item]
                while i > 0:
                    i = i - 1
                    if '.zip:' in all_files_list[i]:
                        file_path.append(all_files_list[i])
                        return self.remove_blank_and_colon_in_file_path(file_path)
                break

    def extract_bbox_file(self):
        snapshot_zip = zipfile.ZipFile(self.snapshot_path, 'r')
        if self.snapshot_file in snapshot_zip.namelist():
            all_files_list = snapshot_zip.open("snapshot_file_list.txt").readlines()
            file_path = self.get_file_path(all_files_list)
            snapshot_zip.extract(file_path[1])
            snapshot_zip.close()
            with zipfile.ZipFile(file_path[1], 'r') as bboxZip:
                bboxZip.extract(file_path[0], path="/tmp")
                self.bbox_file_name = file_path[0]
                self.extract_xz_file()

    def extract_xz_file(self):
        os.system("xz -dk %s" % ("/tmp/" + self.bbox_file_name))
        self.bbox_file_name = self.bbox_file_name.replace('.xz', "")

    @keyword
    def check_bbox_file_contents(self, snapshot_path):
        self.snapshot_path = snapshot_path
        self.extract_bbox_file()

        with open(("/tmp/" + self.bbox_file_name), 'r') as f:
            events_check = 0
            isti_check = 0
            reset_counter_check = 0
            voltage_check = 0
            memory_load_check = 0
            cpu_load_check = 0
            temperature_check = 0
            optical_lvl_signal_check = 0
            sw_version_check = 0
            file_content = f.readline()
            while file_content:
                file_content = f.readline()

                if "List of events" in file_content:
                    events_check = 1
                    continue
                if "Item type: Isti" in file_content:
                    isti_check = 1
                    continue
                if "Item type: reset" in file_content:
                    reset_counter_check = 1
                    continue
                if "Item type: memory_load" in file_content:
                    memory_load_check = 1
                    continue
                if "Item type: cpu_load" in file_content:
                    cpu_load_check = 1
                    continue
                if "Item type: Temperature" in file_content:
                    temperature_check = 1
                    continue
                if "Item type: Voltage" in file_content:
                    voltage_check = 1
                    continue
                if "Item type: Optical_lvl_signal" in file_content:
                    optical_lvl_signal_check = 1
                    continue
                if "Item type: SW_version" in file_content:
                    sw_version_check = 1
                    continue

                if events_check > 0 and isti_check > 0 and \
                        reset_counter_check > 0 and voltage_check > 0 and memory_load_check > 0 \
                        and cpu_load_check > 0 and temperature_check > 0 and \
                        optical_lvl_signal_check > 0 and sw_version_check > 0:
                    print("BBOX file content check pass!")
                    os.system("cd /tmp; rm *BBOX5*")
                    return "PASS"

            if events_check < 1:
                return "No faults/events exists in BBOX5 file! BBOX file content check Fail !!!"
            if isti_check < 1:
                return "No In Service Time Indicator exists in BBOX5 file! BBOX file content check Fail !!!"
            if reset_counter_check < 1:
                return "No BTS resets statistics exists in BBOX5 file! BBOX file content check Fail !!!"
            if voltage_check < 1:
                return "No Voltage exists in BBOX5 file! BBOX file content check Fail !!!"
            if memory_load_check < 1:
                return "No memory load exists in BBOX5 file! BBOX file content check Fail !!!"
            if cpu_load_check < 1:
                return "No CPU load exists in BBOX5 file! BBOX file content check Fail !!!"
            if temperature_check < 1:
                return "No Temperature exists in BBOX5 file! BBOX file content check Fail !!!"
            if optical_lvl_signal_check < 1:
                return "No optical port info exists in BBOX5 file! BBOX file content check Fail !!!"
            if sw_version_check < 1:
                return "No SW version exists in BBOX5 file! BBOX file content check Fail !!!"

            return "Logic fault! Code can't be executed to here!"
