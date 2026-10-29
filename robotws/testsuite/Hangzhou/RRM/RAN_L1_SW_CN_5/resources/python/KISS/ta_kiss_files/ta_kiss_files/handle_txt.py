# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
from .exception import KissFileException


class TxtHandler(object):
    """find and modify value in .txt file
    """
    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self._txt_data = None
        self._src_path = None
        self._save_path = None

    def setup(self, src_file, save_path, **kwargs):
        """src_file: the txt file you want parser
           save_path: where the txt file you want save after parser
        """
        self._src_path = src_file
        self._save_path = save_path

        with open(self._src_path, "r+") as fs:
            self._txt_data = fs.readlines()

    def teardown(self, **kwargs):
        """pair up the function setup
        """
        with open(self._save_path, "w+") as ft:
            for line in self._txt_data:
                ft.write(line)
        ft.close()

    def modify_node(self, *args):
        """arg should be like this:    0x10042:0x0A691892        0x10043:51015
        """
        total_line = len(self._txt_data)
        for each_node in args:
            ret_temp = each_node.split(":")
            param = ret_temp[0]
            value = ":".join(ret_temp[1:])
            self._log.debug("try to modify param:'%s', value:'%s'", param, value)
            modified = False
            comment = ''
            for i in range(total_line):
                assignment = self._txt_data[i].split("#")[0]
                comment = self._txt_data[i][self._txt_data[i].find("#")+1:]
                get_param = assignment.split("=")[0].strip()
                if param == get_param:
                    if comment == self._txt_data[i] or comment.strip() == '':
                        self._txt_data[i] = "%s = %s\n" % (param, value)
                    else:
                        self._txt_data[i] = "%s = %s #%s" % (param, value, comment)
                    modified = True
            if modified is not True:
                raise KissFileException("not found any value for param %s, please check your param!" % param)

    def add_node(self, *args):
        """arg should be like this:    0x10301:1#MAC L2
                                    0x10302:2
        """
        for each_node in args:
            ret_temp = each_node.split(":")
            param = ret_temp[0]
            other_arg = ":".join(ret_temp[1:])
            if "#" in other_arg:
                value = other_arg.split("#")[0]
                comment = other_arg.split("#")[1]
            else:
                value = other_arg
                comment = ""
            self._log.debug("add param:'%s', value:'%s', comment:'%s'", param, value, comment)
            if '\n' not in self._txt_data[-1]:
                self._txt_data.append('\n')
            if comment is not '':
                self._txt_data.append("%s = %s # %s\n" % (param, value, comment))
            else:
                self._txt_data.append("%s = %s\n" % (param, value))

    def delete_node(self, *args):
        """arg should be like this:    0x10049
        """
        total_line = len(self._txt_data)

        for each_node in args:
            param = each_node
            self._log.debug("try to delete param:'%s'", param)
            deleted = False
            for i in range(total_line):
                assignment = self._txt_data[i].split("#")[0]
                get_param = assignment.split("=")[0].strip()
                if param == get_param:
                    self._txt_data[i] = ""
                    deleted = True
            if deleted is not True:
                raise KissFileException("not found any value for param %s, please check your param!" % param)

    def get_node_text(self, *args):
        """arg should be like this:    0x10040
        """
        ret_list = []
        param = args[0]
        for line in self._txt_data:
            assignment = line.split("#")[0]
            get_param = assignment.split("=")[0].strip()
            if param == get_param:
                value = assignment.split("=")[1].strip()
                ret_list.append(value)
        if len(ret_list) == 0:
            self._log.debug("not found any param, please check your param!--%s.", param)
            return "NOT_FOUND"
        elif len(ret_list) == 1:
            return ret_list[0]
        else:
            self._log.debug("more than one value for %s is found, please check your file!", param)
            return ret_list[-1]


if __name__ == '__main__':
    pass
