# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
import struct
from .exception import KissFileException


class BinHandler(object):
    """find and modify value in .bin file
    """

    def __init__(self, file_object):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self._file_object = file_object

    def find_tag_position(self, tagname):
        """location the tag lines
        """
        pos_value_list = []
        target_pos = 0
        get_tag = b''
        get_value = b''
        read_tag = False
        read_value = False
        self._file_object.seek(-990, 2)
        while True:
            try:
                ch = self._file_object.read(1)
                single = struct.unpack('c', ch)[0]
                if single == '<'.encode('utf-8'):
                    read_tag = True
                    read_value = False
                    if len(get_value) != 0:
                        target_pos = self._file_object.tell()-len(get_value)-1
                        pos_value_list.append((target_pos, get_value))
                        self._log.info("find tag '%s' at 'pos': %s", tagname, target_pos)
                        break
                elif single == '>'.encode('utf-8'):
                    read_tag = False
                    get_tag = b''
                elif read_tag is True:
                    get_tag += single
                    if get_tag == tagname.encode('utf-8'):
                        read_value = True
                    else:
                        read_value = False
                elif read_value is True and read_tag is False:
                    get_value += single
            except struct.error:
                self._log.info("end of file")
                break
        if len(pos_value_list) == 0:
            raise KissFileException("Not find tag '%s'" % tagname)
        else:
            return pos_value_list

    def write_bin_file(self, pos, strvalue):
        'write new value to bin file'
        try:
            self._file_object.seek(pos)
            new = struct.pack("%ss" % len(strvalue), str(strvalue).encode('utf-8'))
            self._file_object.write(new)
            return True
        except IOError as err:
            self._log.info(err)
            return False

    def replace_text_in_bin_file(self, tag_name, new_value):
        """replace_text_in_bin_file to modify bin file's text by tag name,
           the new value should have the same length with old one.
           <SwVersion>5912129</SwVersion>
           tag_name: SwVersion
           text: 5912129

        | Input Paramaters   | Man. | Description |
        | bin_file     | yes  | Path of bin file |
        | tag_name     | yes  | Tag name in bin file <xxx> |
        | new_value    | yes  | New value should have same length with old one |

        Example:
        | replace_text_by_tag_in_bin_file | d:\\xxx.bin | SwVersion | 5912128 | #old value 5912129 |
        """

        value_list = self.find_tag_position(tag_name)
        fail_str = ""
        for pos, value in value_list:
            if new_value == value:
                self._log.info("DO NOT need to change, same value!")
            elif len(new_value) == len(value):
                if self.write_bin_file(pos, new_value) is True:
                    self._log.info("Modify tag '%s' as '%s' successfully!", tag_name, new_value)
                else:
                    raise KissFileException("fail to modify bin file!")
            else:
                fail_str += "\nPos '%s', old-new value '%s'-'%s' is not same length." % \
                            (pos, value, new_value)
                raise KissFileException(fail_str)


if __name__ == '__main__':
    pass
