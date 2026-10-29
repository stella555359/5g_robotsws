import os
import sys
import getopt
import glob

check_code_path = "./../../"
ROBOT_LINE_LIMIT = 150
PYTHON_LINE_LIMIT = 120
OTHER_FILE_LINE_LIMIT = 99999
CHECK_PYTHON_FILE_PEP8_FORMAT_LIST = ["check_code_format.py"]


def check_file_with_tag(check_files_list, tag):
    robot_file_list_with_tag = []
    for foo in check_files_list:
        try:
            fh = open(foo, 'r', encoding='UTF-8')
            content = fh.read()
            fh.close()
            if content.count(tag):
                robot_file_list_with_tag.append(foo)
            else:
                pass
        except IOError:
            print("file name[{}] is too long.".format(foo))
        except UnicodeDecodeError:
            print("file name=[{}] has UnicodeDecodeError error".format(foo))
    return robot_file_list_with_tag


def main_func(search_tag="CN1_SQ", old_tag="5G_RAN", new_tag="RAN_5G", times=2):
    robot_file_list = []
    python_file_list = []
    other_file_list = []
    robot_file_list_with_tag = []
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
    # print("robot_file_list={}".format(robot_file_list))
    robot_file_list_with_tag = check_file_with_tag(robot_file_list, search_tag)
    print("robot_file_list_with_tag={}".format(robot_file_list_with_tag))
    for file_name in robot_file_list_with_tag:
        replace_one_file_with_tag(file_name, old_tag, new_tag, times)
    # check_file_each_line_length(robot_file_list, ROBOT_LINE_LIMIT)
    # print("python_file_list={}".format(python_file_list))
    # check_file_each_line_length(python_file_list, PYTHON_LINE_LIMIT)
    # check_file_each_line_length(other_file_list, OTHER_FILE_LINE_LIMIT)


def replace_one_file_with_tag(file_name, old_tag, new_tag, times):
    fh = open(file_name, 'r', encoding='UTF-8')
    content = fh.read()
    fh.close()
    if content.count(old_tag):
        print("Good")
        content = content.replace(old_tag, new_tag, times)
        fh = open(file_name, 'w', encoding='UTF-8', newline='\n')
        fh.write(content)
        fh.close()
    else:
        print("Bad")


if __name__ == "__main__":
    main_func()
    # file_name="./../../UE_Call_Setup\CB006112\CB006112_ET_C_02_test.robot"
    # replace_one_file_with_tag(file_name,"5G_RAN","RAN_5G",2)
