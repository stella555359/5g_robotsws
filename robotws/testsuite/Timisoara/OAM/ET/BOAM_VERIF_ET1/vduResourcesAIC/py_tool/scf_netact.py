# -*- coding: utf-8 -*-
import os


def modify_scf_for_netact(file, new_file_name):

    """This keyword is used to modify scf file.
    Write the replacement string to a new file, then delete the original file, and change the new file to the original
    file name
    :param file: file path
    :return: new file  path
    """
    old_str = r'distName="'
    new_str = r'distName="PLMN-PLMN/'
    _cfg_dir = os.path.dirname(file)
    tmp = os.path.join(_cfg_dir, new_file_name)
    if os.path.exists(new_file_name):
        os.remove(tmp)
    else:
        print("no such file:%s" % tmp)

    with open(file, "r") as f1, open("%s.bak" % file, "w") as f2:
        for line in f1:
            if new_str in line:
                pass
            elif old_str in line:
                line = line.replace(old_str, new_str)
            f2.write(line)

    os.rename("%s.bak" % file, tmp)


def netact_scf_convert(file, new_file_name):

    """This keyword is used to modify scf file.
    Write the replacement string to a new file, then delete the original file, and change the new file to the original
    file name
    :param file: file path
    :return: new file  path
    """
    new_str = r'distName="MRBTS'
    old_str = r'distName="PLMN-PLMN/MRBTS'

    if os.path.exists(new_file_name):
        os.remove(tmp)
    else:
        print("no such file:%s" % tmp)

    with open(file, "r") as f1, open(new_file_name, "w") as f2:
        for line in f1:
            if new_str in line:
                pass
            elif old_str in line:
                line = line.replace(old_str, new_str)
            if "<raml version=\"2.0" in line:
                line = "<raml version=\"2.1\" xmlns=\"raml21.xsd\">"

            f2.write(line)


def recover_scf(file, new_file_name):

    """This keyword is used to modify scf file.
    Write the replacement string to a new file, then delete the original file, and change the new file to the original
    file name
    :param file: file path
    :return: new file  path
    """
    new_str = r'distName="'
    old_str = r'distName="PLMN-PLMN/'
    _cfg_dir = os.path.dirname(file)
    tmp = os.path.join(_cfg_dir, new_file_name)
    if os.path.exists(new_file_name):
        os.remove(tmp)
    else:
        print("no such file:%s" % tmp)

    with open(file, "r") as f1, open("%s.bak" % file, "w") as f2:
        for line in f1:
            if old_str in line:
                line = line.replace(old_str, new_str)
            elif old_str in line:
                pass
            f2.write(line)

    os.rename("%s.bak" % file, tmp)


if __name__ == "__main__":
    scf_path1 = r"CU_SCF_0.250.xml"
    modify_scf_for_netact(scf_path1, "tmpfile.xml")
