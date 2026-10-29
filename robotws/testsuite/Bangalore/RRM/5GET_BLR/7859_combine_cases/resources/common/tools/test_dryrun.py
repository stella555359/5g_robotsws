import re
import os
import sys
import getopt
import glob
import shutil
check_code_path = "./../../"
ROBOT_LINE_LIMIT = 150
PYTHON_LINE_LIMIT = 120
OTHER_FILE_LINE_LIMIT = 99999
CHECK_PYTHON_FILE_PEP8_FORMAT_LIST = ["check_code_format.py"]
LOG_FILE = "log.txt"


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


def main_func(
        search_tag="CN1_SQ",
        old_tag="5G_RAN",
        new_tag="RAN_5G",
        times=2):
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
                if os.path.split(file_name_with_path)[
                        1] in CHECK_PYTHON_FILE_PEP8_FORMAT_LIST:
                    os.system(
                        "autopep8 --in-place {}".format(file_name_with_path))
            else:
                if not (file_name_with_path.count(".idea")):
                    other_file_list.append(file_name_with_path)
    # print("robot_file_list={}".format(robot_file_list))
    robot_file_list_with_tag = check_file_with_tag(robot_file_list, search_tag)
    print("robot_file_list_with_tag={}".format(robot_file_list_with_tag))
    for file_name in robot_file_list:
        print("dryrun file_name={}".format(file_name))
        dryrun_case(file_name)

    # check_file_each_line_length(robot_file_list, ROBOT_LINE_LIMIT)
    # print("python_file_list={}".format(python_file_list))
    # check_file_each_line_length(python_file_list, PYTHON_LINE_LIMIT)
    # check_file_each_line_length(other_file_list, OTHER_FILE_LINE_LIMIT)


def dryrun_case(file_name):
    dry_run_one_file(file_name)


def dry_run_one_file(file_full_name):
    command = "robot -V /home/ute/testline_configuration/2_16_UTE5GCLASSICAL2093/ --dryrun " + file_full_name
    output = os.popen(command).read()
    regx = re.compile(r"\| FAIL \|")
    ret = regx.findall(output)
    if ret != []:
        print("{} dry run failed!!!".format(file_full_name))
        fh = open(LOG_FILE, "a+")
        fh.write("{} dry run failed!!!\n".format(file_full_name))
        fh.close()
        return "Fail"
    else:
        fh = open(LOG_FILE, "a+")
        fh.write("{} dry run pass!!!\n".format(file_full_name))
        fh.close()
        return "Pass"


def dryrun_one_file_and_collect_result(file_full_name):
    ret = dry_run_one_file(file_full_name)
    source_file = os.path.join(os.curdir, "log.html")
    dest_file = os.path.join(os.curdir, ret, file_full_name.split(".")[
                             0] + "_log_" + ret + ".html")

    print("source_file={}".format(source_file))
    print("dest_file={}".format(dest_file))
    dest_file_2 = os.path.join(os.curdir, ret, dest_file.split("/")[-1])
    print("dest_file_2={}".format(dest_file_2))
    shutil.copyfile(source_file, dest_file)
    shutil.copyfile(dest_file, dest_file_2)


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


def clear_env_for_last_run():
    os.system("rm -r Fail") if os.path.exists("Fail") else None
    os.system("rm -r Pass") if os.path.exists("Pass") else None
    os.system("mkdir Fail") if not os.path.exists("Fail") else None
    os.system("mkdir Pass") if not os.path.exists("Pass") else None


if __name__ == "__main__":
    clear_env_for_last_run()
    main_func()
    # file_name="./../../UE_Call_Setup\CB006112\CB006112_ET_C_02_test.robot"
    # replace_one_file_with_tag(file_name,"5G_RAN","RAN_5G",2)
