# -*- coding: utf-8 -*-
"""
:<Change Log>
:2017-10-27  Lin licai   initial creatation
:2017-10-27  Lin licai   create new kw:sftp_download/sftp_upload/read_excel/write_excel
:2018-03-09  Cao panfeng create new kw:file_should_contain/file_should_not_contain
:2018-03-30  Lin licai   create new KW "update json file"
:2018-07-05  Lin licai   create new KW "read_csv_columns"
:2018-07-20  Lin licai   create new KW "search_file"
:2018-12-19  Lin Licai   create new KW "Get_workspace_Dir"
:2019-03-01  Lin Licai   update and add UT for python3"
:2019-04-19  Lin Licai   create new KW "Get_SCFAttribute"
:
:copyright: Nokia
:author: Lin Licai
:contact: lin.licai@nokia-sbell.com.cn
"""

import os
import shutil
import pysftp
import xlrd
from xlutils.copy import copy
import re
import json
import collections
import csv

from robot.libraries.XML import XML


def Get_SCFAttribute(FilePath, MOC, AttrName):
    """This KW is to get the attribute value from managedObject..

        :param string FilePath: input the path of xml file
        :param integer MOC: input the "class" value of ManagedObject
        :param string AttrName: input the attribute name which you want to return attibute value

        examples:
        | ${DNList} | BTS Get SCFAttribute | D:/testplan.xml | com.nokia.eqm.hw:INVUNIT | distName |
    """
    xml = XML(use_lxml=True)
    xmlContent = xml.parse_xml(FilePath)
    Xpath = ".//*[@class='%s']/@%s" % (MOC, AttrName)
    print("xpath: %s" % Xpath)
    AttrValue = xml.get_elements(xmlContent, Xpath)
    print("find AttrValue: %s" % AttrValue)
    return AttrValue


def Get_workspace_Dir():
    return os.getenv('WORKSPACE', os.curdir)


def _convert_unicode_to_string(data):
    if isinstance(data, str):
        return str(data)
    elif isinstance(data, collections.Mapping):
        return dict(list(map(_convert_unicode_to_string, iter(data.items()))))
    elif isinstance(data, collections.Iterable):
        return type(data)(list(map(_convert_unicode_to_string, data)))
    else:
        return data


def search_file(TargetDir, File_pattern):
    filelist = ""
    os.chdir(TargetDir)
    for obj in os.listdir(os.curdir):
        if re.search(File_pattern, obj):
            print(("Successfully find '%s' in '%s'" % (File_pattern, obj)))
            filelist = filelist + obj + ";"
    if (len(filelist) == 0):
        print("[ERROR]Not found [%s] from %s." % (File_pattern, TargetDir))
        return False
    else:
        return filelist.rstrip(";")


def update_json_file(target_json_file, dist_operation, dist_name, parameter_operation='update', **kwargs):
    """Setup Admin API.

        :param string target_json_file: json file to be updated or created
        :param integer dist_operation: operation for distName, update|delete|create
        :param string dist_name: distName
        :param string parameter_operation: update or delete
        :param kwargs: parameter=value
    """

    if os.path.exists(target_json_file):
        with open(target_json_file) as json_file:
            delta_file_data = json.load(json_file)

    dist_dict = {}
    para_list = []
    dist_dict['distName'] = dist_name
    dist_dict['operation'] = dist_operation
    if len(kwargs) > 0:
        for parameter in kwargs:
            para_dict = {}
            para_dict["parameterName"] = parameter
            para_dict["operation"] = parameter_operation
            para_value = str(kwargs[parameter])
            if isinstance(para_value, str) or isinstance(para_value, str):
                if para_value.startswith('{') and para_value.endswith('}'):
                    para_value = [literal_eval(para_value)]
                elif para_value.startswith('[') and para_value.endswith(']'):
                    para_value = literal_eval(para_value)
            para_dict["value"] = para_value
            para_list.append(para_dict)
    dist_dict['parameters'] = para_list
    delta_file_data += [dist_dict]
    delta_file_obj = _convert_unicode_to_string(delta_file_data)

    with open(target_json_file, 'w') as json_file:
        json_file.write(json.dumps(delta_file_obj))


def sftp_download(host, port, usr, pwd, remote, local=None):
    """sftp download file or dir recursively
    :param host: such as '192.168.255.129'
    :param port: such as 22
    :param usr: username such as 'toor4nsn'
    :param pwd: password such as 'oZPS0POrRieRtu'
    :param remote: file in host such as '/tmp/rat_psconfig.xml' or folder '/tmp/'(NOT '/tmp')
    :param local: file path to save in local such as 'example/config1/rat1.xml','example/config1/', 'rat1.xml', None
    """
    if local is not None and os.path.split(local)[0] != '':
        if os.path.exists(os.path.split(local)[0]) is False:
            os.makedirs(os.path.split(local)[0])
        if os.path.split(local)[1] == '':
            local = local + '/' + os.path.split(remote)[1]
    elif local is not None and os.path.split(local)[0] == '':
        local = os.getcwd() + '/' + local
    else:
        local = os.getcwd() + '/' + os.path.split(remote)[1]
    local = os.path.normpath(local)
    with pysftp.Connection(host, username=usr, password=pwd, port=int(port)) as sftp:
        if os.path.split(remote)[1] != '':
            sftp.get(remote, local)
        else:
            localpath = os.path.join(local, remote.split('/')[-2])
            if os.path.isdir(localpath) is True:
                shutil.rmtree(localpath)
            sftp.get_r(remote, local)
        sftp.close()


def sftp_upload(host, port, usr, pwd, local, remote=None):
    """sftp upload file
    :param host: such as '192.168.255.129'
    :param port: such as 22
    :param usr: username such as 'toor4nsn'
    :param pwd: password such as 'oZPS0POrRieRtu'
    :param local: file in local such as '/tmp/rat_psconfig.xml'
    """

    with pysftp.Connection(host, username=usr, password=pwd, port=int(port)) as sftp:
        current_path = ['', sftp.getcwd()][sftp.getcwd() is not None]
        if remote is not None and os.path.split(remote)[0] != '':
            if sftp.exists(os.path.split(remote)[0]) is not True:
                sftp.makedirs(os.path.split(remote)[0])
#               print("make dir: %s " % os.path.split(remote)[0])
        elif remote is not None and os.path.split(remote)[0] == '':
            remote = current_path + '/' + remote
        else:
            remote = current_path + '/' + os.path.split(local)[1]
        if remote is not None and os.path.split(remote)[1] == '':
            remote = remote + '/' + os.path.split(local)[1]
        local = os.path.normpath(local)
        remote = os.path.normpath(remote)
        sftp.put(local, remote)
        sftp.close()


def read_excel(source_file, sheet_name, x_cell, y_cell):
    """read_excel_cell to read excel specific cell.

   +--------------------+------+-------------------------------------------+
   | Input Paramaters   | Man. | Description                               |
   +--------------------+------+-------------------------------------------+
   | source_file        | yes  | Absolute path of excel file               |
   +--------------------+------+-------------------------------------------+
   | sheet_name         | yes  | sheet name in excel file                  |
   +--------------------+------+-------------------------------------------+
   | x_cell             | yes  | the number of row(start value is zero)    |
   +--------------------+------+-------------------------------------------+
   | y_cell             | yes  | the number of column(start value is zero) |
   +--------------------+------+-------------------------------------------+

   Example:

   +--------------------+--------------+---------+----+----+
   |read_excel_cell     |/opt/xxx.xls  |Sheet1   |1   |2   |
   +--------------------+--------------+---------+----+----+

   """
    sheet_names = []
    sheet_index = None
    try:
        exist_file = xlrd.open_workbook(source_file)
        sheet_names = exist_file.sheet_names()
        if sheet_name in sheet_names:
            sheet_index = exist_file.sheet_by_name(sheet_name)
    except IOError as error:
        raise Exception("open %s failed for %s" % (source_file, error))
    #     return 0

    excel_object = copy(exist_file)

    return sheet_index.cell(int(x_cell), int(y_cell)).value


def write_excel(source_file, sheet_name, x_cell, y_cell, in_value):
    """write_excel_cell to write or modify excel specific cell.
        make sure the excel file is closed when you use this keyword.

     +--------------------+------+-------------------------------------------+
    | Input Paramaters   | Man. | Description                               |
    +--------------------+------+-------------------------------------------+
    | source_file        | yes  | Absolute path of excel file               |
    +--------------------+------+-------------------------------------------+
    | sheet_name         | yes  | sheet name in excel file                  |
    +--------------------+------+-------------------------------------------+
    | x_cell             | yes  | the number of row(start value is zero)    |
    +--------------------+------+-------------------------------------------+
    | y_cell             | yes  | the number of column(start value is zero) |
    +--------------------+------+-------------------------------------------+
    | in_value           | yes  | new value need to write or modify         |
    +--------------------+------+-------------------------------------------+
    Example:

    +--------------------+--------------+--------+---+---+-----+
    |modify_excel_cell   |/opt/xxx.xls  |Sheet1  |1  |2  |333  |
    +--------------------+--------------+--------+---+---+-----+

    """
    # file operation, if exist, copy and
    if not os.path.isfile(source_file):
        raise Exception("%s not found!!!" % source_file)
    #   return 0
    sheet_object = None
    sheet_names = []
    sheet_index = None
    try:
        exist_file = xlrd.open_workbook(source_file)
        sheet_names = exist_file.sheet_names()
        if sheet_name in sheet_names:
            sheet_index = exist_file.sheet_by_name(sheet_name)
    except IOError as error:
        raise Exception("open %s failed for %s" % (source_file, error))
    #     return 0

    excel_object = copy(exist_file)

    if sheet_names and (sheet_name in sheet_names):
        sheet_index = sheet_names.index(sheet_name)
        sheet_object = excel_object.get_sheet(sheet_index)
    else:
        sheet_object = excel_object.add_sheet(sheet_name, cell_overwrite_ok=True)

    sheet_object.write(int(x_cell), int(y_cell), in_value)
    excel_object.save(source_file)


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
        source_file_path, target_msgs)

    if len(unfound_msgs) != 0:  # some messages was not found
        raise Exception(
            "Not find '%s' in '%s'" %
            (unfound_msgs, source_file_path))

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

    unfound_msgs, target_msgs, _ = _check_msg_in_file(
        source_file_path, target_msgs)
    # print(unfound_msgs, target_msgs)
    if len(unfound_msgs) != len(target_msgs):  # some messages was found
        raise Exception(
            "Find '%s' in '%s'" %
            (list(
                set(target_msgs).difference(
                    set(unfound_msgs))),
                source_file_path))


def read_csv_columns(source_file, cared_title):
    """read_csv_columns to read csv specific one columns.

    +--------------------+------+------------------------------------+
    | Input Paramaters   | Man. | Description                        |
    +--------------------+------+------------------------------------+
    | source_file        | yes  | Path of csv file                   |
    +--------------------+------+------------------------------------+
    | cared_title        | yes  | column's title   |
    +--------------------+------+------------------------------------+
    | return             | [colA_list] or [[colA_list], [colB_list]] |
    +--------------------+------+------------------------------------+

    Example:
    xxx.csv
    +------------------+--------------+-------------+------------+
    | time stamp;USS [kB];PSS [kB]; | |        |            |
    +------------------+--------------+-------------+------------+
    | 2018-06-27T09:09:42Z;33840;35331;| |        |            |
    +------------------+--------------+-------------+------------+
    |                                | |        |            |
    +------------------+--------------+-------------+------------+
    | read_csv_columns | /opt/xxx.csv | Time        |            |
    +------------------+--------------+-------------+------------+
    """
    csv_raw_list = []
    valid_csv_column_list = []
    value_index = 0

    # Read the data from csv file
    with open(source_file, 'r') as file_object:
        content = csv.reader(file_object)
        for con in content:
            csv_raw_list.append(con)

    # to get the valid line lists
    for line_index in range(len(csv_raw_list)):
        Newtitle = csv_raw_list[line_index][0].split(";")
        if cared_title in Newtitle:
            value_index = Newtitle.index(cared_title)
            for row in range(line_index + 1, len(csv_raw_list)):
                line_info = csv_raw_list[row]
                if not ((line_info == []) or (len(set(line_info)) == 1) and (line_info[0] == '')):
                    value = line_info[0].split(";")[value_index].strip()
                    if re.match('^+$', value):
                        value = int(value)
                    elif re.match('^+.+$', value):
                        value = float(value)
                    valid_csv_column_list.append(value)
            break
    return valid_csv_column_list


if __name__ == "__main__":
    workspace = Get_workspace_Dir()
    print("1.KW Get_workspace_Dir() verify result: %s" % workspace)
    value = read_excel("data/TestXLS.xls", "Sheet1", 1, 1)
    print("2.KW read_excel(\"data/TestXLS.xls\", \"Sheet1\", 1, 1) verify result: %s" % value)
    write_excel("data/TestXLS.xls", "Sheet1", 1, 1, "test111")
    newvalue = read_excel("data/TestXLS.xls", "Sheet1", 1, 1)
    write_excel("data/TestXLS.xls", "Sheet1", 1, 1, value)
    print("3.KW write_excel(\"data/TestXLS.xls\", \"Sheet1\", 1, 1, \"test111\") verify result: %s" % newvalue)
    value_list = read_csv_columns("data/TestCSV.csv", "time stamp")
    print("5.KW read_csv_columns(\"data/TestCSV.csv\", \"time stamp\") verify result: %s" % value_list)
    file_should_contain("data/Test.json", "unlocked")
    print("6.KW file_should_contain(\"data/Test.json\", \"unlocked\") verify result: pass")
    file_should_not_contain("data/Test.json", "9.9.9.9")
    print("7.KW file_should_not_contain(\"data/Test.json\", \"9.9.9.9\") verify result: pass")
    sftp_download("192.168.255.129", "22", "toor4nsn", "oZPS0POrRieRtu", "/rom/swconfig.txt", "data/swconfig.txt")
    os.system("ls -l data/*")
    sftp_upload("192.168.255.129", "22", "toor4nsn", "oZPS0POrRieRtu", "data/Test.json", "/tmp/Test.json")
    filelist = search_file("data/", "Test*")
    print("10.KW search_file(\"data/\", \"Test*\") verify result: %s" % filelist)
    AttrList = Get_SCFAttribute("data/scf.xml", "com.nokia.eqm.hw:INVUNIT", "distName")
    print("11.KW Get_SCFAttribute verify result: %s" % AttrList)
    pass
