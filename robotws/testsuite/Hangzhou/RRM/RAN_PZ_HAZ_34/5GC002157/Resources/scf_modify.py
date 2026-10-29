# -*- coding: utf-8 -*
"""
Author: Wang Yixiang
Contacts: yixiang.x.wang@nokia-sbell.com
Description:
"""
import re
import os


def remove_managedObject_NRMTRACECU(scf_path):
    """
    scf_path
    """
    with open(scf_path) as f:
        lines = f.readlines()
        content = ''
        delete_line_flag = False
        for line in lines:
            if re.search('.*managedObject.*NRMTRACECU.*', line):
                delete_line_flag = True
            if re.search('</managedObject>', line) and delete_line_flag:
                delete_line_flag = False
                continue
            if not delete_line_flag:
                content = content + line
    filepath, filename = os.path.split(scf_path)
    new_scf_path = filepath + os.path.sep + "scf_remove_NRMTRACECU.xml"
    with open(new_scf_path, 'w') as f:
        f.write(content)

    return new_scf_path


# if __name__ == '__main__':
#     scf_path = "/home/ute/Projects/robotws5g/testsuite/RRM/Hangzhou/" \
#                "5GC002157/Resources/CU_SCF_MMW1_TL417_1014_cellTrace.xml"
#     new_scf_path = remove_managedObject_NRMTRACECU(scf_path=scf_path)
#     print new_scf_path
