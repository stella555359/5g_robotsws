"""
this file is used for judge whether robot and python file follows the following rules.
  * - Thou shall not use email addresses
      other than the corporate ones.
  * - Thou shall not write Robot code
      with lines longer than 150 columns.
  * - Thou shall not write Python code
      with lines longer than 120 columns.
  * - Thou shall follow PEP8.
  * - Thou shall use Unix-style line
      endings.
  * - Thou shall not toss in trash.
  * - Thou shall not use weird filenames.
  * - Thou shall use Quality Center
      configuration file format in every
      .qc file.
  * - Thou shall not touch repository
      config.
"""
import os
import sys
import getopt
import glob
check_code_path = "./../../"
ROBOT_LINE_LIMIT = 150
PYTHON_LINE_LIMIT = 120
OTHER_FILE_LINE_LIMIT = 99999
CHECK_PYTHON_FILE_PEP8_FORMAT_LIST = ["check_code_format.py"]


def check_file_each_line_length(check_files_list, limit_length):
    for foo in check_files_list:
        try:
            fh = open(foo, "rb")
            line_list = fh.readlines()
            for i, line in enumerate(line_list):
                str_number = len(line)-1
                if (str_number > limit_length):
                    print("in file:{},line:{},str_number={},over {} bytes".format(
                        foo, i+1, str_number, limit_length))
                if (int(sys.version[0]) >= 3):
                    try:
                        line = str(line, encoding="utf-8")
                    except UnicodeDecodeError:
                        print("ERROR: UnicodeDecodeError: line")
                        break
                # if (line.count("\r\n")):
                #    print("in file:{},line:{},end_str is \\r\\n".format(foo, i))
        except IOError:
            print("file name[{}] is too long.".format(foo))


def main_func():
    robot_file_list = []
    python_file_list = []
    other_file_list = []
    for root, dirs, files in os.walk(check_code_path):
        for file_name in files:
            file_name_with_path = os.path.join(root, file_name)
            if file_name_with_path.endswith(".robot"):
                robot_file_list.append(file_name_with_path)
            elif file_name_with_path.endswith(".py"):
                python_file_list.append(file_name_with_path)
                if os.path.split(file_name_with_path)[1] in CHECK_PYTHON_FILE_PEP8_FORMAT_LIST:
                    os.system(
                        "autopep8 --in-place {}".format(file_name_with_path))
            else:
                if not (file_name_with_path.count(".idea")):
                    other_file_list.append(file_name_with_path)
    # for robot_file in robot_file_list:
    #     print("robot_file={}".format(robot_file))
    check_file_each_line_length(robot_file_list, ROBOT_LINE_LIMIT)
    check_file_each_line_length(python_file_list, PYTHON_LINE_LIMIT)
    # check_file_each_line_length(other_file_list, OTHER_FILE_LINE_LIMIT)


if __name__ == "__main__":
    main_func()
