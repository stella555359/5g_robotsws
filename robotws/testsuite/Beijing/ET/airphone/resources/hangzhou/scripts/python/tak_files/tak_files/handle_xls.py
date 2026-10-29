# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
import xlrd
import xlwt
from xlutils.copy import copy
from .exception import KissFileException


class XlsHandler(object):
    """find and modify value in  excel file
    """
    def __init__(self, file_path, sheet_name):
        self.xls_name = file_path
        self.sheet_name = sheet_name
        self.excel_object = None
        self.sheet_object = None
        self.sheet_names = []
        self.sheet_index = None
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)

    def open_excel(self):
        """open an excel file
        """
        try:
            exist_file = xlrd.open_workbook(self.xls_name)
            self.sheet_names = exist_file.sheet_names()
            if self.sheet_name in self.sheet_names:
                self.sheet_index = exist_file.sheet_by_name(self.sheet_name)
        except IOError as error:
            self._log.info("open %s failed for '%s'\n", self.xls_name, error)

        self.excel_object = copy(exist_file)

    def create_excel(self):
        """create an excel file
        """
        self.excel_object = xlwt.Workbook(encoding='utf-8')

    def get_sheet_index(self, sheet_name):
        """get sheet index according to sheet name
        """
        if self.sheet_names and (sheet_name in self.sheet_names):
            sheet_index = self.sheet_names.index(sheet_name)
            self.sheet_object = self.excel_object.get_sheet(sheet_index)
        else:
            self.sheet_object = self.excel_object.add_sheet(sheet_name, cell_overwrite_ok=True)

    def read_cell(self, x_cell, y_cell):
        """get the value of a specified cell
        """
        return self.sheet_index.cell(int(x_cell), int(y_cell)).value

    def write_cell(self, x_cell, y_cell, in_value):
        """put the value in a specified cell
        """
        return self.sheet_object.write(int(x_cell), int(y_cell), in_value)

    def save(self):
        """save an excel file
        """
        self.excel_object.save(self.xls_name)


if __name__ == '__main__':
    pass
