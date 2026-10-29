# -*- coding: utf-8 -*-
"""
2022/05/22 first version by @author: xiang.5.li@nokia-sbell.com
"""
import json
import os


class ReadCfg(object):
    def __init__(self, json_file):
        self.json_file = json_file
        self.cfg = {}

    def is_path_exist(self):
        if os.path.exists(self.json_file):
            return True
        else:
            return False

    def is_json_file(self):
        if os.path.basename(self.json_file).endswith("json"):
            return True
        else:
            return False

    def read_json_file(self):
        with open(self.json_file) as f:
            self.cfg = json.load(f)
            # print("self.cfg:", self.cfg, type(self.cfg))

    def json_cfg(self):
        if not self.is_path_exist():
            return self.cfg
        elif not self.is_json_file():
            return self.cfg
        else:
            self.read_json_file()
            return self.cfg


if __name__ == "__main__":
    file = r'C:\et\resources\lib\json_file_example.json'
    read_cfg_obj = ReadCfg(file)
    cfg = read_cfg_obj.main()
    print(cfg)
