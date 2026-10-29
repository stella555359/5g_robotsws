#!/usr/bin/python3
"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

import sys
import os
import re
import glob

RED = '\033[91m'
GREEN = '\033[92m'
NC = '\033[0m'

FEATURE_ID = sys.argv[1]
REPO_DIR = '/home/ute/robotws'
FEATURE_DIR = '{}/testsuite/Ulm/Handover/Krakow/RRM/DevKr/{}/'.format(REPO_DIR, FEATURE_ID)
CONFIGS_KRAKOW_DIR = '{}/custom-config/Krakow/'.format(REPO_DIR)
CONFIGS_DIR = '{}/custom-config/'.format(REPO_DIR)

LUA_RE = re.compile('^\${(LUA|lua).*(cfg|CFG|config|CONFIG)+.*}')  # nopep8
CONFIGS_TAG_RE = re.compile('CONFIGS_Krakow/{}.*\.(yml|yaml)'.format(FEATURE_ID))  # nopep8
FEATURE_ID_RE = re.compile('^(5GC|CB)\d{6}$')  # nopep8
ROBOT_FILES_RE = '{}/*.robot'.format(FEATURE_DIR)

FILES_VALIDATION_ERRORS = 0


def validate_user_input():
    if len(sys.argv) != 2:
        print(GREEN, 'Usage:', os.path.basename(__file__), 'FEATURE_ID', NC)
        exit()
    if not re.search(FEATURE_ID_RE, sys.argv[1]):
        print(GREEN, 'Usage:', os.path.basename(__file__), 'FEATURE_ID', NC)
        print(RED, FEATURE_ID, 'feature directory does not exist!', NC)
        exit()


def check_if_home_ute_robotws_exist():
    if not os.path.exists(REPO_DIR):
        print(RED, REPO_DIR, 'not found! Clone repo or make symbolic link to repo:', NC)
        print(RED, '\tln -s /home/ute/MN/UTE/robotws', REPO_DIR, NC)
        exit()


def print_config_specific_for_single_robot_file(config_files):
    global FILES_VALIDATION_ERRORS
    for cf in config_files:
        if cf.endswith('.robot'):
            print(GREEN, cf, NC)
        elif 'WRONG' in cf:
            print('\t', RED, cf, NC)
            FILES_VALIDATION_ERRORS += 1
        else:
            print('\t ', cf)
    print()


def print_config_files_validation_result():
    if FILES_VALIDATION_ERRORS == 0:
        print(GREEN, 'Validation OK, 0 errors found', NC)
    else:
        print(RED, 'Validation FAILURE, {} errors found'.format(
            FILES_VALIDATION_ERRORS), NC)


def find_specific_config_files_for_robot_testsuite(robot_file_path):
    cfg_files_per_testsuite = [robot_file_path]
    robot_filename = robot_file_path.split('/')[-1]
    direct_yaml_path = None

    with open(robot_file_path) as robot_file:
        for line in robot_file:
            line = line.rstrip()
            if LUA_RE.findall(line):
                curdir_lua_path = line.split()[1]
                direct_lua_path = curdir_lua_path.replace(
                    '${CURDIR}', robot_file_path)
                direct_lua_path = direct_lua_path.replace(
                    robot_filename + '/', '')

                if os.path.isfile(direct_lua_path):
                    cfg_files_per_testsuite.append(direct_lua_path)
                else:
                    cfg_files_per_testsuite.append(
                        'WRONG lua path! ' + direct_lua_path)

            if CONFIGS_TAG_RE.findall(line):
                try:
                    yaml_path_tokens = line.split('/')
                    indirect_yaml_path = yaml_path_tokens[yaml_path_tokens.index(
                        FEATURE_ID):]
                    indirect_yaml_path = "/".join(indirect_yaml_path)
                    direct_yaml_path = os.path.join(
                        CONFIGS_KRAKOW_DIR, indirect_yaml_path)
                except ValueError:
                    cfg_files_per_testsuite.append('WRONG yaml path! ' + line)

    if direct_yaml_path:
        try:
            with open(direct_yaml_path) as yaml_file:
                for line in yaml_file:
                    line = line.rstrip()
                    if re.compile(r'file_path:\s+"').search(line):
                        indirect_xml_path = line.split()[-1]
                        indirect_xml_path = indirect_xml_path.replace('"', '')
                        direct_xml_path = os.path.join(
                            CONFIGS_DIR, indirect_xml_path)

                        if os.path.exists(direct_xml_path) and direct_xml_path.split('/').count('') == 1:
                            cfg_files_per_testsuite.append(direct_xml_path)
                        else:
                            cfg_files_per_testsuite.append('WRONG xml path! {} in {}'
                                                           .format(direct_xml_path, direct_yaml_path))
        except OSError:
            cfg_files_per_testsuite.append(
                'WRONG yaml path! ' + direct_yaml_path)

    cfg_files_per_testsuite = [filename.replace(
        '/home/ute/robotws/', '') for filename in cfg_files_per_testsuite]
    return cfg_files_per_testsuite


if __name__ == "__main__":
    check_if_home_ute_robotws_exist()
    validate_user_input()

    for direct_robot_file_path in sorted(glob.glob(ROBOT_FILES_RE)):
        cfg_files = find_specific_config_files_for_robot_testsuite(
            direct_robot_file_path)
        print_config_specific_for_single_robot_file(cfg_files)

    print_config_files_validation_result()
