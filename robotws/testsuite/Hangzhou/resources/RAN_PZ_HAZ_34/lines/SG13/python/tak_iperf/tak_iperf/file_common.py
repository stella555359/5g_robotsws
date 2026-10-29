# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS_GMS
:contact: I_EXT_MBB_GLOBAL_LTE_TDD_CITA_KISS@internal.nsn.com
"""
import contextlib
import mmap
import os
import re
import six
import logging as log


class FileCommon(object):
    """A base file class which realizes common operation on file.
       All operations are realized through static class methods.
    """

    def __init__(self):
        super(FileCommon, self).__init__()

    @staticmethod
    @contextlib.contextmanager
    def open_file(file_name, open_mode="r"):
        """Open a file safely, with exception handling and cleanup(close).
           @return: yields a File Object, or None when fail.
           @attention: Please use this method by "with" statement like this:
        """
        file_obj = None
        try:
            file_obj = open(file_name, open_mode)
            yield file_obj
        except IOError as err_info:
            raise Exception('Open file "%s" failed with exception: %s'
                            % (file_name, err_info))
        finally:
            if file_obj:
                file_obj.close()

    @staticmethod
    def read_file(file_name, read_mode="r", return_mode='string'):
        """Open a file safely, return its all content in a string.
           @param return_mode: "string" / "list" ->
           @return: string of file content / list of file lines
           @attention:
        """
        if return_mode not in ["string", "list"]:
            raise Exception('Failed to read file "%s", ' % file_name +
                            '"return_mode" must be "string" or "list", ' +
                            'but now it is "%s"' % return_mode)
        with FileCommon.open_file(file_name, read_mode) as file_obj:
            if return_mode == "string":
                return file_obj.read()
            elif return_mode == "list":
                return file_obj.readlines()

    @staticmethod
    def write_file(file_name, content_to_write="", write_mode="w"):
        """Write "content_to_write"(string, list or tuple) to a file.
        """
        type_of_content = type(content_to_write)
        dir_name = os.path.dirname(file_name)
        if not os.path.isdir(dir_name):
            log.debug(
                'Parent dir of file "%s" does not exist, try to create it' %
                file_name)
            os.makedirs(dir_name)

        with FileCommon.open_file(file_name, write_mode) as file_obj:
            if type_of_content in (str, six.text_type):
                file_obj.write(content_to_write)
            elif type_of_content in (list, tuple):
                file_obj.writelines(content_to_write)
            log.info('Write file "%s" succeeded' % file_name)
        return True


def file_match_all(file_name, regexp, read_mode='r+'):
    """This keyword match all

    | Input Parameters | Man. | Description |
    | file_name        | Yes  | Source file path name |
    | regexp           | Yes  | match regexp |
    | read_mode        | No   | Read mode, default is 'r+' |

    | Output Parameters| Man. | Description |
    | match_content     | Yes  | file match content list, [] if match nothing. |

    Example
    | file_match_all | D:\\1.txt | #\\s*(\\d+) | 'r+' |
    """
    with FileCommon.open_file(file_name, read_mode) as file_obj:
        result = re.findall(regexp, file_obj.read())
        return result
