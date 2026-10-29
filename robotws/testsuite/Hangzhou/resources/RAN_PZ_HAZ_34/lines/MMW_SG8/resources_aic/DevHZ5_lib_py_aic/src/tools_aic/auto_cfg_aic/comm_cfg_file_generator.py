# -*- coding: utf-8 -*-

"""
:author:      eric.jiang
:contact:     eric.jiang@nokia-sbell.com
:maintainer:  eric.jiang@nokia-sbell.com
"""

import os


class cfg_file_generator_aic(object):
    def __init__(self, file_path):
        self.file_path = file_path
        self.file_dir = os.path.dirname(self.file_path)
        self.file_name = os.path.basename(self.file_path)
        self.file_obj = None
        self.cfg_first_line = """# Copyright (c) 2019 Nokia. All rights reserved.\n"""

    def setup(self):
        if self.file_dir != r"/opt/wts/latest" and not os.path.exists(self.file_dir):
            os.mkdir(self.file_dir)
        name, extension = os.path.splitext(self.file_name)
        if extension != ".cfg":
            self.file_name = "{}.cfg".format(self.file_name)
        self.file_obj = open(self.file_path, 'w')
        self.file_obj.write(self.cfg_first_line + "\n")

    def write_content(self, content):
        self.file_obj.write(content + "\n")

    def teardown(self):
        self.file_obj.close()
