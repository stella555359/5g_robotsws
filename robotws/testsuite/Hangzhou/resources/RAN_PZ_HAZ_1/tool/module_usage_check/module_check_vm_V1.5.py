#!/usr/bin/env python3

import os
import sys
import datetime
from time import sleep
import requests
import subprocess
os.system("pip install numpy")
os.system("pip install pandas")
os.system("pip install msal")
os.system("pip install sharepoint-tool")
os.system("pip install O365")
try:
    import pandas as pd
    import numpy as np
    import msal
    from sp_tool.sharepoint import SharepointConnector
    from office365.runtime.auth.authentication_context import AuthenticationContext
    from office365.sharepoint.files.file import File
    from office365.runtime.auth.user_credential import UserCredential
    from office365.runtime.auth.client_credential import ClientCredential
    from office365.sharepoint.client_context import ClientContext
    from office365.sharepoint.webs.web import Web
except ImportError:
    raise ImportError("The installed libraries are not exist!")

base_path = "/home/ute/MN/UTE"
git_path = base_path + "/robotws"
check_path = base_path + "/robotws/testsuite/Hangzhou"
module_file_path = base_path + "/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/Module"

case_file_path_rrm = base_path + "/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1"
case_file_path_oam = base_path + "/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1"
case_file_path_oam1 = base_path + "/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11"
case_file_path_oam2 = base_path + "/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ12"
case_file_path_siso = base_path + "/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1"

rrm_common_keywords = base_path + "/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/Resources"
oam1_common_keywords = base_path + "/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/resources"
oam2_common_keywords = base_path + "/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ12/OAM_SRAN/resources"
siso_common_keywords = base_path + "/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources"

csv_file_name = "module_usage.csv"
excel_file_name = "module_usage.xlsx"

dryrun_folder_t01 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ2/"
dryrun_folder_t02 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ3/"
dryrun_folder_t03 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ4/"
dryrun_folder_t04 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ5/"
dryrun_folder_t05 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_PZ_HAZ_1/HAZ7/"
dryrun_folder_siso = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/"
dryrun_folder_t08 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ11/"
dryrun_folder_t09 = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/OAM/RAN_PZ_HAZ_1/HAZ12/"
dryrun_folder_dic = {
    "Team1": dryrun_folder_t01,
    "Team2": dryrun_folder_t02,
    "Team3": dryrun_folder_t03,
    "Team4": dryrun_folder_t04,
    "Team5": dryrun_folder_t05,
    "SISO": dryrun_folder_siso,
    "Team8": dryrun_folder_t08,
    "Team9": dryrun_folder_t09
}
dryrun_cmd_part0 = 'python -m robot --dryrun -V /home/ute/testline_configuration/2_16_UTE5GCLASSICAL1845/ '
dryrun_cmd_part1 = '-L TRACE -x qttest.xml -b '
dryrun_cmd_part2 = 'debug.log'
dryrun_cmd_part3 = ' -d /home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/tool/'
dryrun_cmd_part4 = 'module_usage_check -l '
dryrun_cmd_part5 = 'dryrun-log.html '
dryrun_cmd_list = [
    dryrun_cmd_part0,
    dryrun_cmd_part1,
    dryrun_cmd_part2,
    dryrun_cmd_part3,
    dryrun_cmd_part4,
    dryrun_cmd_part5
]

module_dynamic_csv_file_name = "module_usage_dynamic.csv"
module_dynamic_excel_file_name = "module_usage_dynamic.xlsx"

rrm_ck_csv_file_name = "ck_usage_rrm.csv"
rrm_ck_excel_file_name = "ck_usage_rrm.xlsx"
oam1_ck_csv_file_name = "ck_usage_oam1.csv"
oam1_ck_excel_file_name = "ck_usage_oam1.xlsx"
oam2_ck_csv_file_name = "ck_usage_oam2.csv"
oam2_ck_excel_file_name = "ck_usage_oam2.xlsx"
siso_ck_csv_file_name = "ck_usage_siso.csv"
siso_ck_excel_file_name = "ck_usage_siso.xlsx"

rrm_ck_not_used_csv = "ck_not_used_rrm.csv"
rrm_ck_excel_not_used = "ck_not_used_rrm.xlsx"
oam1_ck_not_used_csv = "ck_not_used_oam1.csv"
oam1_ck_excel_not_used = "ck_not_used_oam1.xlsx"
oam2_ck_not_used_csv = "ck_not_used_oam2.csv"
oam2_ck_excel_not_used = "ck_not_used_oam2.xlsx"
siso_ck_not_used_csv = "ck_not_used_siso.csv"
siso_ck_excel_not_used = "ck_not_used_siso.xlsx"

log_file_prefix = "module_check_log"
log_file_extension = ".log"

# Define the Nokia Sharepoint info - sharepoint-tool
TENANT = 'nokia'
CLIENT_ID = '8e3370b0-25d0-4945-a944-2c5bcaea27d1'
CLIENT_SECRET = 'vWSv7fCTtosw4QgWtGCBtLBOsuvU6ZyMZsDZ+YciHUk='
SITE_NAME = 'mnplteverificationcsvchina2'
SP_FOLDER = 'Shared Documents/Quality/RRM&TELECO/Metrics/Power BI raw data'


def store_file_to_sharepoint(file_name):
    sharepoint = SharepointConnector(
        tenant=TENANT,
        client_id=CLIENT_ID,
        client_secret=CLIENT_SECRET,
        site_name=SITE_NAME
    )
    sp_folder = SP_FOLDER
    result = sharepoint.files(folder=sp_folder)
    sharepoint.upload_file(filename=file_name, target_file=file_name, folder=sp_folder, check_out=True)

    print("The file {} has been put to sharepoint!".format(file_name))


def create_log_file(log_file_prefix, log_file_extension):
    log_file_name = log_file_prefix + log_file_extension
    # Write the starting sentence to the log file
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        hash_line = "#" * 150
        f.write(hash_line + "\n")
        f.write(str(current_date_time) + ": START OF LOG FILE FOR MODULE USAGE CHECK!\n")
        f.write(hash_line + "\n")
        f.close()
    return log_file_name


def end_log_file(log_file_name):
    # Write the ending sentence to the log file and close the log file
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        hash_line = "#" * 150
        f.write(hash_line + "\n")
        f.write(str(current_date_time) + ": END OF LOG FILE FOR MODULE USAGE CHECK!\n")
        f.write(hash_line + "\n")
        f.close()
    print(str(current_date_time) + ": END OF LOG FILE FOR MODULE USAGE CHECK!\n")


def generate_csv_file(module_file_counter, csv_file_name):
    with open(csv_file_name, 'w') as f:
        f.write("Module,File,Count\n")
        for module in module_file_counter:
            for file in module_file_counter[module]:
                if file != "SUM":
                    f.write(module + "," + file + "," + str(module_file_counter[module][file]) + "\n")
        f.close()


def generate_csv_file_not_used(common_keywords_not_used, csv_file_name):
    with open(csv_file_name, 'w') as f:
        f.write("Common Keywords,File\n")
        for keyword in common_keywords_not_used:
            f.write(keyword + "," + common_keywords_not_used[keyword] + "\n")
        f.close()


def generate_csv_file_dynamic(module_dynamic_counter, csv_file_name):
    with open(csv_file_name, 'w') as f:
        f.write("Team,Module,Count\n")
        for team in module_dynamic_counter:
            for module in module_dynamic_counter[team]:
                f.write(team + "," + module + "," + str(module_dynamic_counter[team][module]) + "\n")
        f.close()


def csv_to_excel(csv_file_name, excel_file_name):
    df = pd.read_csv(csv_file_name)
    df.to_excel(excel_file_name, index=False)


def list_robot_files(path, log_file_name):
    # List all the robot case files!
    robot_file_list = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".robot"):
                full_path = os.path.join(root, file)
                robot_file_list.append(full_path)
                # # Fetch the current system date time
                # current_date_time = datetime.datetime.now()
                # # Write to the log file
                # with open(log_file_name, 'a') as f:
                #     f.write(str(current_date_time) + ": " + full_path + "\n")
    return robot_file_list


###################################################################################################
# Define the functions for the module usage check in static method                                #
###################################################################################################

def get_all_robot_files(log_file_name):
    # Get all the robot files from the list of paths!
    case_path = [case_file_path_rrm, case_file_path_oam, case_file_path_siso]
    total_counter = 0
    rrm_counter = 0
    oam_counter = 0
    siso_counter = 0

    robot_file_list_all = []
    for path in case_path:
        file_list = list_robot_files(path, log_file_name)
        for file in file_list:
            robot_file_list_all.append(file)
            total_counter += 1
            if path == case_file_path_rrm:
                rrm_counter += 1
            elif path == case_file_path_oam:
                oam_counter += 1
            elif path == case_file_path_siso:
                siso_counter += 1

    # Create a list named as counter_list, and put total_counter, rrm_counter, oam_counter, siso_counter into it
    counter_list = [total_counter, rrm_counter, oam_counter, siso_counter]

    # Print the counter list one by one in each line
    solid_line = "-" * 150
    print(solid_line)
    print("Total number of robot files: ", counter_list[0])
    print(solid_line)
    print("RRM robot files: ", counter_list[1])
    print("OAM robot files: ", counter_list[2])
    print("SISO robot files: ", counter_list[3])

    # Write the current date time and counter list to the log file
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": Total number of robot files: " + str(counter_list[0]) + "\n")
        f.write(str(current_date_time) + ": RRM robot files: " + str(counter_list[1]) + "\n")
        f.write(str(current_date_time) + ": OAM robot files: " + str(counter_list[2]) + "\n")
        f.write(str(current_date_time) + ": SISO robot files: " + str(counter_list[3]) + "\n")

    return robot_file_list_all, counter_list


def get_module_name():
    # Get the module name from the module file!
    module_file_list = [f for f in os.listdir(module_file_path) if f.endswith('.robot') or f.endswith('.py')]
    # print("The module file list is: ", module_file_list)

    # Get the module name from the file!
    module_name = []
    for file in module_file_list:
        # If the file ends with robot, then open the file and get the module name
        if file.endswith('.robot'):
            with open(module_file_path + "/" + file, 'r') as f:
                for line in f:
                    if line.startswith("*** Keywords ***"):
                        module_name.append(next(f).strip())
        # If the file ends with py, then get the module name from the file name
        elif file.endswith('.py'):
            module_name.append(file.replace(".py", "").replace("_", " "))
    return module_name


def check_module_in_robot_file(module_name_list, robot_file_list, log_file_name):
    # Create the counters for each module
    module_file_counter = {}
    for module in module_name_list:
        module_file_counter[module] = {}
        for file in robot_file_list:
            module_file_counter[module][file] = 0

    # Check the module name usage in the robot file!
    for module in module_name_list:
        # print("Module name: ", module)
        for file in robot_file_list:
            with open(file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    # Remove all the space fore the 1st non-space character
                    line = line.lstrip()
                    # Check if the line is a comment line
                    if line.startswith("#"):
                        continue
                    # Check if the module name is in the line
                    if module in line:
                        current_date_time = datetime.datetime.now()
                        module_file_counter[module][file] += 1

    # Remove the value=0 elements in module_name_list
    for module in module_name_list:
        for file in robot_file_list:
            if module_file_counter[module][file] == 0:
                del module_file_counter[module][file]

    # Calculate the sumary usage of each module
    for module in module_name_list:
        sum = 0
        for file in module_file_counter[module]:
            sum += module_file_counter[module][file]
        module_file_counter[module]["SUM"] = sum

    return module_file_counter


def print_module_counter(module_file_counter, log_file_name):
    for module in module_file_counter:
        current_date_time = datetime.datetime.now()

        # Define the solid line and dot line
        solid_line = "-" * 150

        count = str(module_file_counter[module]["SUM"]).rjust(5)
        print(solid_line)
        print("MODULE COUNT :", count, ":", module)
        # print(solid_line)
        with open(log_file_name, 'a') as f:
            f.write(solid_line + "\n")
            f.write(str(current_date_time) + ": MODULE COUNT: " + count + ": " + module + "\n")
            # f.write(solid_line + "\n")
            f.close()

        for file in module_file_counter[module]:
            if file != "SUM":
                count = str(module_file_counter[module][file]).rjust(5)
                print("Count ", count, ": ", file)
                with open(log_file_name, 'a') as f:
                    f.write(str(current_date_time) + ": Count " + count + ": " + file + "\n")
                    f.close()


def module_check(log_file_name):
    # List all the robot case files!
    robot_file_list_all, counter_list = get_all_robot_files(log_file_name)

    # List all the modules from the module file!
    module_name_list = get_module_name()
    # print("The module name list is: ", module_name_list)

    # Check the module name usage in the robot file!
    module_file_counter = check_module_in_robot_file(module_name_list, robot_file_list_all, log_file_name)

    # Print the module counter list
    print_module_counter(module_file_counter, log_file_name)

    return module_file_counter


###################################################################################################
# Define the functions for the module usage check in dynamic method                               #
###################################################################################################

def dryrun_cases(dryrun_cmd_list, dryrun_folder, log_file_name):
    # Fill the logfile to record the starting of dryrun
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": Start to dryrun the RAN_PZ_HAZ_1 test suite!\n")
        f.close()

    # Remove the "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/" from dryrun_folder
    dryrun_folder_string = dryrun_folder.replace("/home/ute/MN/UTE/robotws/testsuite/Hangzhou/", "")
    # Replace the "/" with "_" in the dryrun_folder_string
    dryrun_folder_string = dryrun_folder_string.replace("/", "_")

    # Dryrun the RAN_PZ_HAZ_1 test suite!
    dryrun_cmd = dryrun_cmd_list[0] + dryrun_cmd_list[1] + dryrun_folder_string + \
        dryrun_cmd_list[2] + dryrun_cmd_list[3] + dryrun_cmd_list[4] + \
        dryrun_folder_string + dryrun_cmd_list[5] + dryrun_folder
    print("The dryrun command is: ", dryrun_cmd)

    # Run the command and read the output in real-time
    process = subprocess.Popen(dryrun_cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            print(output.strip())
    rc = process.poll()

    # Check the output of the dryrun command whether the dryrun gets debug file
    dryrun_local_folder = "/home/ute/MN/UTE/robotws/testsuite/Hangzhou/resources/RAN_PZ_HAZ_1/tool/module_usage_check"
    while True:
        print("Checking whether the debug file is generated!")
        if os.path.exists(dryrun_local_folder + "/" + dryrun_folder_string + dryrun_cmd_list[2]):
            break
        else:
            sleep(5)

    # Fill the logfile to record the ending of dryrun "dryrun_folder"
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": End to dryrun the dryrun_folder: " + dryrun_folder + "\n")
        f.write(str(current_date_time) + ": The " + dryrun_folder_string +
                "_debug.log file have been downloaded to the local folder: " + dryrun_local_folder + "\n")
        f.close()

    # Create the result dictionary
    result_debug_file = dryrun_local_folder + "/" + dryrun_folder_string + "debug.log"
    result = result_debug_file

    return result


def check_module_in_debug_file(module_name_list, debug_file, log_file_name):
    # Create the counter for each module
    module_dynamic_usage_counter = {}
    for module in module_name_list:
        module_dynamic_usage_counter[module] = 0

    # Check the module name usage in the debug file!
    with open(debug_file, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            # Check if the module name is in the line
            for module in module_name_list:
                # Replace the space with the underscore in the module name
                module_string = module.replace(" ", "_")
                # Add "START KW: " before the module name
                module_string = "START KW: " + module_string
                # If the module name (ignore the upper and lower case) is in the line, then add the counter by 1
                if module_string.lower() in line.lower():
                    current_date_time = datetime.datetime.now()
                    module_dynamic_usage_counter[module] += 1

                    print("Module name: ", module, " is used in ", debug_file, " for ",
                          module_dynamic_usage_counter[module], " times!\n")
                    print("The line is: ", line, "\n")

    # Print the module_dynamic_usage_counter
    current_date_time = datetime.datetime.now()
    print(current_date_time, ": Calculate the module usage in the debug file: ", debug_file, "\n")
    for module in module_dynamic_usage_counter:
        current_date_time = datetime.datetime.now()
        print(current_date_time, ": Module name: ", module, "; Count: ", module_dynamic_usage_counter[module], "\n")
        with open(log_file_name, 'a') as f:
            f.write(str(current_date_time) + ": Module name: " + module + "; Count: " +
                    str(module_dynamic_usage_counter[module]) + "\n")
            f.close()

    return module_dynamic_usage_counter


def module_check_dynamic(dryrun_cmd_list, dryrun_folder_dic, log_file_name):
    # Get all the module names
    module_name_list = get_module_name()

    # Create the list of teams names
    team_name_list = ["Team1", "Team2", "Team3", "Team4", "Team5", "SISO", "Team8", "Team9"]

    # Create the empty dictionary of result
    result = {}

    # For each team, run the dryrun and check the module usage in the debug file
    for team in team_name_list:
        dryrun_result_team = dryrun_cases(dryrun_cmd_list, dryrun_folder_dic[team], log_file_name)
        print("The dryrun result of ", team, " is: ", dryrun_result_team)
        module_dynamic_usage_counter_team = check_module_in_debug_file(module_name_list,
                                                                       dryrun_result_team, log_file_name)

        # Add module_dynamic_usage_counter_team to result with team
        result[team] = module_dynamic_usage_counter_team
        print("The module dynamic usage counter of ", team, " is: ", module_dynamic_usage_counter_team)

    # Print and store the result list to logfile
    current_date_time = datetime.datetime.now()
    print(current_date_time, ": The module dynamic usage counter is: ", result)
    with open(log_file_name, 'a') as f:
        f.write(str(current_date_time) + ": The module dynamic usage counter is: " + str(result) + "\n")
        f.close()

    return result


###################################################################################################
# Define the functions for the RRM/OAM/SISO Common Keywords usage check                           #
###################################################################################################

def get_keywords_name(common_keywords_file_path, log_file_name):
    common_keywords_file_list = list_robot_files(common_keywords_file_path, log_file_name)
    common_keywords_list = []
    common_keywords_and_files_dict = {}
    for file in common_keywords_file_list:
        with open(file, 'r', encoding='utf-8', errors='ignore') as f:
            keyword_line_number = 999999
            current_line_number = 0
            for line in f:
                # Each line 1. After the *** Keywords *** line, 2. Start from the first column, 3. Start from a letter
                current_line_number += 1
                if line.startswith("*** Keywords ***"):
                    keyword_line_number = current_line_number
                    continue
                if current_line_number > keyword_line_number and line[0].isalpha():
                    ck_name = line.strip()
                    ck_name = ck_name.replace(",", "")
                    if "#" in ck_name:
                        ck_name = ck_name.split("#")[0].strip()
                    common_keywords_list.append(ck_name)
                    common_keywords_and_files_dict[ck_name] = file

    # Sort the common keywords list
    common_keywords_list.sort()
    # Remove the duplicated elements in the common keywords list
    common_keywords_list = list(set(common_keywords_list))

    # Remove the duplicated elements in the common keywords and files dict
    common_keywords_and_files_dict = {k: v for k, v in common_keywords_and_files_dict.items()
                                      if k in common_keywords_list}

    # Write the common keywords list to the log file
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": The common keywords list is: " + "\n")
        for keyword in common_keywords_list:
            f.write(keyword + "\n")
        f.close()

    return common_keywords_list, common_keywords_and_files_dict


def get_case_files(case_file_path, rrm_common_keywords, log_file_name):
    # List all the robot case files
    robot_file_list = list_robot_files(case_file_path, log_file_name)

    # # List all the common keywords files
    # common_keywords_file_list = list_robot_files(rrm_common_keywords, log_file_name)

    # # Should not be removed, but need to check the count for the kw itself
    # for file in common_keywords_file_list:
    #     if file in robot_file_list:
    #         robot_file_list.remove(file)

    # Write the robot file list to the log file
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": The robot file list is: " + "\n")
        for file in robot_file_list:
            f.write(file + "\n")
        f.close()

    return robot_file_list


def check_keywords_in_robot_file(ca, common_keywords_list, common_keywors_and_files_dict,
                                 robot_file_list, log_file_name):
    # Write log file of start the check
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": Start to check the common keywords usage in the robot file!\n")
        f.close()

    # Create the counters for each common keywords
    common_keywords_counter = {}
    for keyword in common_keywords_list:
        common_keywords_counter[keyword] = {}
        for file in robot_file_list:
            common_keywords_counter[keyword][file] = 0

    # Check the common keywords usage in the robot file!
    kw_check_counter = 0
    total_files_number = len(robot_file_list) * len(common_keywords_list)

    for keyword in common_keywords_list:
        # print("Common keyword: ", keyword)
        for file in robot_file_list:
            kw_check_counter += 1
            print(ca, " KW usage checking is ongoing: ", kw_check_counter, "/", total_files_number)
            with open(file, 'r', encoding='utf-8', errors='ignore') as f:
                for line in f:
                    # Remove all the space fore the 1st non-space character
                    line = line.lstrip()
                    # Check if the line is a comment line
                    if line.startswith("#"):
                        continue
                    # Check if the common keyword is in the line, and should not start from beginning of the line
                    if keyword in line and not line.startswith(keyword):
                        current_date_time = datetime.datetime.now()
                        common_keywords_counter[keyword][file] += 1

    # Write log file of end the check, and start to calculate the sumary usage of each common keyword
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": End to check the common keywords usage in the robot file!\n")
        f.write(str(current_date_time) + ": Start to calculate the sumary usage of each common keyword!\n")
        f.close()

    # Calculate the sumary usage of each common keyword
    for keyword in common_keywords_list:
        sum = 0
        for file in common_keywords_counter[keyword]:
            sum += common_keywords_counter[keyword][file]
        common_keywords_counter[keyword]["SUM"] = sum

    # List the common keyword names and their according file search from common_keywors_and_files_dict with sum=0
    # and move them to another dictionary named as common_keywords_not_used
    common_keywords_not_used = {}
    for keyword in common_keywords_list:
        if common_keywords_counter[keyword]["SUM"] == 0:
            common_keywords_not_used[keyword] = common_keywors_and_files_dict[keyword]
            del common_keywords_counter[keyword]
            common_keywords_list.remove(keyword)

    # Remove the value=0 elements in common_keywords_counter
    for keyword in common_keywords_list:
        for file in robot_file_list:
            if common_keywords_counter[keyword][file] == 0:
                del common_keywords_counter[keyword][file]

    # Write log file of end the calculate
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": End to calculate the sumary usage of each common keyword!\n")
        f.write(str(current_date_time) + ": End to calculate the common keywords not used.\n")
        f.close()

    return common_keywords_counter, common_keywords_not_used


def print_common_keywords_counter(ca, common_keywords_counter, common_keywors_and_files_dict, log_file_name):
    # Define the solid line and dot line
    solid_line = "-" * 150
    for keyword in common_keywords_counter:
        current_date_time = datetime.datetime.now()

        count = str(common_keywords_counter[keyword]["SUM"]).rjust(5)
        print(solid_line)
        print(ca, " KEYWORD COUNT :", count, ":[", keyword, "] IN FILE: ", common_keywors_and_files_dict[keyword])
        # print(solid_line)
        with open(log_file_name, 'a') as f:
            f.write(solid_line + "\n")
            f.write(str(current_date_time) + ": " + ca + " KEYWORD COUNT: " + count + ":[" + keyword +
                    "] IN FILE: " + common_keywors_and_files_dict[keyword] + "\n")
            # f.write(solid_line + "\n")
            f.close()

        for file in common_keywords_counter[keyword]:
            if file != "SUM":
                count = str(common_keywords_counter[keyword][file]).rjust(5)
                print("Count ", count, ": ", file)
                with open(log_file_name, 'a') as f:
                    f.write(str(current_date_time) + ": Count " + count + ": " + file + "\n")
                    f.close()


def print_common_keywords_not_used(ca, common_keywords_not_used, common_keywors_and_files_dict, log_file_name):
    # Define the solid line and dot line
    solid_line = "-" * 150
    for keyword in common_keywords_not_used:
        current_date_time = datetime.datetime.now()
        print(solid_line)
        print(ca, " Common Keyword NOT Used: [", keyword, "] IN FILE: ", common_keywors_and_files_dict[keyword])
        with open(log_file_name, 'a') as f:
            f.write(solid_line + "\n")
            f.write(str(current_date_time) + ": " + ca + " Common Keyword NOT Used: [" + keyword + "] IN FILE: " +
                    common_keywors_and_files_dict[keyword] + "\n")
            f.close()


def common_keywords_check(ca, common_keywords_path, case_file_path, log_file_name):
    # List the common keywords from the common keywords file!
    common_keywords_list, common_keywors_and_files_dict = get_keywords_name(common_keywords_path, log_file_name)

    # List all the robot case files, except the common keywords file!
    robot_file_list = get_case_files(case_file_path, common_keywords_path, log_file_name)

    # Check the common keywords usage in the robot file!
    common_keywords_counter, common_keywords_not_used = check_keywords_in_robot_file(
        ca,
        common_keywords_list,
        common_keywors_and_files_dict,
        robot_file_list,
        log_file_name
    )

    # Print the common keywords counter list
    print_common_keywords_counter(ca, common_keywords_counter, common_keywors_and_files_dict, log_file_name)

    # Print the common keywords not used list
    print_common_keywords_not_used(ca, common_keywords_not_used, common_keywors_and_files_dict, log_file_name)

    return common_keywords_counter, common_keywords_not_used


def generate_csv_excel_file_and_store_to_sharepoint(csv_type, dic_to_be_stored, csv_file_name,
                                                    excel_file_name, log_file_name):
    # Generate the csv file for the module_file_counter
    if csv_type == "counter":
        generate_csv_file(dic_to_be_stored, csv_file_name)
    elif csv_type == "not_used":
        generate_csv_file_not_used(dic_to_be_stored, csv_file_name)
    elif csv_type == "dynamic":
        generate_csv_file_dynamic(dic_to_be_stored, csv_file_name)

    # Convert csv file to excel file
    csv_to_excel(csv_file_name, excel_file_name)

    # Store the excel file to sharepoint
    store_file_to_sharepoint(excel_file_name)

    # # Remove the csv and excel file
    # os.remove(csv_file_name)
    # os.remove(excel_file_name)

    # Write to log file that the excel file has been stored to sharepoint
    with open(log_file_name, 'a') as f:
        current_date_time = datetime.datetime.now()
        f.write(str(current_date_time) + ": Excel file [" + excel_file_name + "] has been stored to sharepoint!\n")
        f.close()
    print("Excel file [" + excel_file_name + "] has been stored to sharepoint!")


###################################################################################################
# MAIN FUNCTION                                                                                   #
###################################################################################################

def main():
    # Create the log file!
    log_file_name = create_log_file(log_file_prefix, log_file_extension)
    # Check module usage in static method (code scan)
    module_file_counter = module_check(log_file_name)
    # Generate the csv and excel file for the module_file_counter, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "counter",
        module_file_counter,
        csv_file_name,
        excel_file_name,
        log_file_name
    )
    # Check RRM Common Keywords usage
    rrm_common_keywords_counter, rrm_common_keywords_not_used = common_keywords_check(
        "RRM",
        rrm_common_keywords,
        case_file_path_rrm,
        log_file_name
    )
    # Generate the csv and excel file for the rrm_common_keywords_counter, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "counter",
        rrm_common_keywords_counter,
        rrm_ck_csv_file_name,
        rrm_ck_excel_file_name,
        log_file_name
    )
    # Generate the csv and excel file for the rrm_common_keywords_not_used, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "not_used",
        rrm_common_keywords_not_used,
        rrm_ck_not_used_csv,
        rrm_ck_excel_not_used,
        log_file_name
    )
    # Check OAM1 Common Keywords usage
    oam1_common_keywords_counter, oam1_common_keywords_not_used = common_keywords_check(
        "OAM1",
        oam1_common_keywords,
        case_file_path_oam1,
        log_file_name
    )
    # Generate the csv and excel file for the oam1_common_keywords_counter, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "counter",
        oam1_common_keywords_counter,
        oam1_ck_csv_file_name,
        oam1_ck_excel_file_name,
        log_file_name
    )
    # Generate the csv and excel file for the oam1_common_keywords_not_used, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "not_used",
        oam1_common_keywords_not_used,
        oam1_ck_not_used_csv,
        oam1_ck_excel_not_used,
        log_file_name
    )
    # Check OAM2 Common Keywords usage
    oam2_common_keywords_counter, oam2_common_keywords_not_used = common_keywords_check(
        "OAM2",
        oam2_common_keywords,
        case_file_path_oam2,
        log_file_name
    )
    # Generate the csv and excel file for the oam2_common_keywords_counter, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "counter",
        oam2_common_keywords_counter,
        oam2_ck_csv_file_name,
        oam2_ck_excel_file_name,
        log_file_name
    )
    # Generate the csv and excel file for the oam2_common_keywords_not_used, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "not_used",
        oam2_common_keywords_not_used,
        oam2_ck_not_used_csv,
        oam2_ck_excel_not_used,
        log_file_name
    )
    # Check SISO Common Keywords usage
    siso_common_keywords_counter, siso_common_keywords_not_used = common_keywords_check(
        "SISO",
        siso_common_keywords,
        case_file_path_siso,
        log_file_name
    )
    # Generate the csv and excel file for the siso_common_keywords_counter, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "counter",
        siso_common_keywords_counter,
        siso_ck_csv_file_name,
        siso_ck_excel_file_name,
        log_file_name
    )
    # Generate the csv and excel file for the siso_common_keywords_not_used, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "not_used",
        siso_common_keywords_not_used,
        siso_ck_not_used_csv,
        siso_ck_excel_not_used,
        log_file_name
    )
    # Check module usage in dynamic method (dryrun result scan)
    module_dynamic_counter = module_check_dynamic(
        dryrun_cmd_list,
        dryrun_folder_dic,
        log_file_name
    )
    # generate the csv and excel file for the module_dynamic_counter, and upload to sharepoint
    generate_csv_excel_file_and_store_to_sharepoint(
        "dynamic",
        module_dynamic_counter,
        module_dynamic_csv_file_name,
        module_dynamic_excel_file_name,
        log_file_name
    )
    # Write the ending sentence to the log file and close the log file
    end_log_file(log_file_name)


if __name__ == "__main__":
    main()
