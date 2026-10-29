# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Christophe SAMSON
:contact: christophe.samson@nokia.com
:maintainer:
:contact:
"""

import os
import re


def search_file(TargetDir, File_pattern):
    """Search_file.
    :param string TargetDir: input the absolutely path.
    :param string File_pattern: input the regex for that file
    examples:
    | search_file | /home/ute/snapshot | BTS%s_[\\d]{4}_part_[\\w]+.zip |
    """
    filelist = ""
    os.chdir(TargetDir)
    for obj in os.listdir(os.curdir):
        if re.search(File_pattern, obj):
            print("Successfully find '%s' in '%s'" % (File_pattern, obj))
            filelist = filelist + obj + ";"
    if len(filelist) == 0:
        print("[ERROR]Not found [%s] from %s." % (File_pattern, TargetDir))
        return False
    else:
        return filelist.rstrip(";")


def _check_msg_in_file(source_file_path, target_msgs):
    # lines = filec.read_file(source_file_path, 'r', 'list')
    contain_lines = []

    if not isinstance(target_msgs, list):
        target_msgs = [target_msgs]

    unfound_msgs = [msg for msg in target_msgs]
    with open(source_file_path, "r") as file_obj:
        for line in file_obj:
            for keyword in target_msgs:
                search_result = re.search(keyword, line)
                if search_result:
                    contain_lines.append(line)
                    try:
                        unfound_msgs.remove(keyword)
                    except ValueError:
                        pass
    return unfound_msgs, target_msgs, contain_lines


def file_should_contain(source_file_path, target_msgs):
    """This keyword checks whether file contains specified messages.

    | Input Parameters | Man. | Description |
    | source_file_path  | Yes  | Source file directory |
    | target_msgs      | Yes  | type as list or string |

    | Return value | lines contain given messages |

    Example
    | File Should Contain | C:\\test.txt | PBCH |  |
    | ${check_list} | create list | PBCH | Onair |
    | File Should Contain | C:\\test.txt | ${check_list} |  |
    """

    unfound_msgs, target_msgs, contain_lines = _check_msg_in_file(
        source_file_path, target_msgs
    )

    if len(unfound_msgs) != 0:  # some messages was not found
        raise Exception("Not find '%s' in '%s'" % (unfound_msgs, source_file_path))

    return contain_lines


def file_should_not_contain(source_file_path, target_msgs):
    """This keyword checks file does not contain specified messages.
    | Input Parameters | Man. | Description |
    | source_file_path  | Yes  | Source file path |
    | target_msgs      | Yes  | type as list or string |

    Example
    | File Should Not Contain | C:\\test.txt | MIMO |
    | ${check_list} | create list | PBCH | Onair |
    | File Should Not Contain | C:\\test.txt | ${check_list} |  |
    """

    unfound_msgs, target_msgs, _ = _check_msg_in_file(source_file_path, target_msgs)
    print(
        "unfounded messages are %s, target messages are %s"
        % (unfound_msgs, target_msgs)
    )
    if len(unfound_msgs) != len(target_msgs):  # some messages was found
        raise Exception(
            "Find '%s' in '%s'"
            % (list(set(target_msgs).difference(set(unfound_msgs))), source_file_path)
        )


if __name__ == "__main__":
    pass
