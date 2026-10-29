"""
:copyright: Nokia Networks
:author: Dawid Chuchnowski  <dawid.chuchnowski@nokia.com>
:maintainer: Dawid Chuchnowski <dawid.chuchnowski@nokia.com>
"""
import ast
import os
import pathlib
import pkg_resources
import re
import sys
import time


# List of imports that should be excluded from usage check
exclude_import_list = ['taf.ul.hanging_resources.listener', 'ute_fsmaccess']


def help():
    help_msg = """
    LUKAI - List Unused Keywords And Imports

    Script for listing unused keywords and imports. Requires one argument with path to single robot
    file or path to directory with test suites and resources.

    Step 1) - run dryruns for provided robot file / directory
    Step 2) - fetches imports and keywords from robot files
    Step 3) - fetches imports and keywords from output.xml files
    Step 4) - compares imports and keywords from steps 2 and 3
    Step 5) - displays results and saves it to /tmp/lukai.log
    """
    print(help_msg)


def validate_input():
    """
    Check if provided path is a path of robot file or directory containing robot testsuite files
    """
    arg = sys.argv[1]
    path = pathlib.Path(arg)
    if arg in ['-h', '--help', 'help']:
        help()
        sys.exit()
    else:
        assert (path.is_dir() and list(path.glob('*.robot'))) or (path.is_file() and arg.endswith('.robot')), \
            'Incorrect input: Only .robot files or directory containing .robot testsuite files are allowed'


def get_abs_filepaths_for_robot_files(input_path):
    """
    Return two lists with absolute paths for robot test suites and robot resources
    :param input_path: path to robot file or directory with robot files
    """
    file_list = []
    path = pathlib.Path(input_path)
    if path.is_dir():
        test_suites = list(path.glob('*.robot'))
        resources = list(path.glob('resources/*.robot'))
        resources_py = list(path.glob('resources/*.py'))
        return test_suites, resources, resources_py
    elif path.is_file():
        file_list.append(path)
        return file_list, [], []


def get_imports_for_file(file):
    """
    Return list of imports used in provided robot file

    Function searches for lines like these:
        Library     taf.converters.eventdecoder  WITH NAME  tce
        Library     ./resources/CB007459_tti_trace_keywords.py
        Resource    ./resources/CB007459.robot

    And returns list ['tce', 'CB007459_tti_trace_keywords', 'CB007459']
    :param file: PosixPath object from pathlib with path to robot file
    """
    imports = []
    with open(file, 'r') as f:
        content = f.readlines()
    lines = [line for line in content if (line.lower().startswith('library') or line.lower().startswith('resource'))]
    for line in lines:
        lib = line[9:].strip()
        if 'WITH NAME' in lib:
            library = lib.split('WITH NAME')[1].strip()
        elif '.robot' in lib:
            library = lib[:-6]
        elif '.py' in lib:
            library = lib[:-3]
        else:
            library = lib.split(' ')[0]
        library_no_path = library.split('/')[-1]
        imports.append(library_no_path)
    return imports


def get_output_xml_path(file):
    """
    Return str with path to output.xml
    :param file: PosixPath object from pathlib with path to robot file
    """
    return '/home/ute/results/' + file.stem + '/output.xml'


def get_libraries_for_output_xml(file):
    """
    Return list of libraries found in output.xml of provided test

    Searches for lines like these:
    <kw name="Execute Egate Command" library="ute_wtssim">
    <kw name="Verify Csi Reports Dtx Ratio" library="CB008053_tti_trace_keywords">

    and returns list ['ute_wtssim', 'CB008053_tti_trace_keywords']
    :param file: PosixPath object from pathlib with path to robot file
    """
    path = get_output_xml_path(file)
    with open(path, 'r') as output_xml:
        content = output_xml.read()
    libraries = [lib[9:-1] for lib in set(re.findall('(library=\".*?\")', content))]
    return libraries


def check_all_imports_are_used(file_path, imports, libraries, exclude_list):
    """
    Compares lists of imports and logs results to /tmp/lukai.log

    :param file_path: PosixPath object from pathlib with path to robot file
    :param imports: list of imports from robot file
    :param libraries: list of libraries from output.xml file
    """
    file_name = os.path.basename(file_path)
    unused_imports = sorted(set(imports) - set(libraries) - set(exclude_list))
    if unused_imports:
        with open('/tmp/lukai.log', 'a') as report:
            report.write(f'\n\033[1m{file_name}\033[0m - not used \033[1mimports\033[0m:\n')
            for lib in unused_imports:
                report.write(f"\033[0;31m{lib}\033[0m\n")


def run_dryrun_for_test(file_path, suite_number, test_suites):
    """
    Run dryrun for test
    :param file_path: PosixPath object from pathlib with path to robot file
    """
    longest_suite_name_len = len(max(map(os.path.basename, test_suites), key=len))
    file_name = os.path.basename(file_path)
    os.system(f"/home/ute/MN/UTE/robotlte/resources/DevKr/run_5g_ute_test.sh {file_path} --dryrun > /dev/null 2>&1")
    result, result_msg = get_dryrun_result(file_path)
    print(f"{f'{suite_number}/{len(test_suites)}'.ljust(6)} {file_name.ljust(longest_suite_name_len)} - {result_msg}")
    time.sleep(1)
    return result


def get_dryrun_result(file_path):
    output_xml_path = '/home/ute/results/' + os.path.splitext(os.path.basename(file_path))[0] + '/output.xml'
    with open(output_xml_path, 'r') as f:
        lines = f.readlines()
    for line in lines:
        if '>All Tests</stat>' in line:
            results = [int(x) for x in re.findall(r'\d+', line)]
            passes = results[0]
            fails = results[1]
            total = sum(results)
    if fails == 0:
        return 'pass', f"\033[1;32mPASS\033[0m - {passes}/{total} tests passed"
    else:
        return 'fail', f"\033[1;31mFAIL\033[0m - {passes}/{total} tests passed"


def display_dryrun_list(test_suites):
    """
    Prints out list of robot testsuites to be dryrun

    :param test_suites: list of absolute paths of robot testsuites
    """
    print(f"{'-' * 60}\nRun dryruns in background for {len(test_suites)} test suites:\n")


def clean_lukai_log():
    """
    Clears log file
    """
    with open('/tmp/lukai.log', 'w') as report:
        report.write('')


def display_results():
    """
    Prints out /tmp/lukai.log or 'All Correct!'
    """
    print(f"\n{'-' * 60}\nOutput:")
    with open('/tmp/lukai.log', 'r') as lukai_log:
        lines = lukai_log.readlines()
    if not lines:
        print("\033[1;32m\nAll Correct!\n\033[0m")
    for line in lines:
        print(line, end='')


def get_keywords_for_output_xml(file):
    """
    Return list of keywords from output.xml for provided test

    :param file: absolute file path of robot testsuite (str)
    :return: list of keywords found in output.xml
    """
    path = get_output_xml_path(file)
    with open(path, 'r') as output_xml:
        content = output_xml.read()
    keywords = [kw[9:-1].lower() for kw in set(re.findall('(kw name=\".*?\")', content))]
    source_keywords = [kw[12:-1].lower() for kw in set(re.findall('(sourcename=\".*?\")', content))]
    return keywords + source_keywords


def get_keywords_from_robot_file(file):
    """
    Return list of keywords from *** Keywords *** section from provided file

    :param file: PosixPath object from pathlib with path to robot file
    :return: list of keywords found in *** Keywords *** section
    """
    with open(file, 'r') as f:
        content = f.read()
    if '*** Keywords ***' in content:
        keywords_content = content.split('*** Keywords ***')[1]
    else:
        return []
    keywords_with_definitions = keywords_content.split('\n')
    keywords_and_subkeywords = [kw.lower() for kw in keywords_with_definitions if kw != '']
    suite_keywords = []
    for keyword in keywords_and_subkeywords:
        if keyword[0].isalpha():
            suite_keywords.append(keyword)
    return suite_keywords


def get_keywords_from_python_file(file):
    """
    Returns all functions names defined in specified file
    :param file: path to python file
    :return keyword_functions: list of functions names
    """
    source = open(file).read()
    keyword_functions = [f.name for f in ast.parse(source).body if isinstance(f, ast.FunctionDef)]
    keywords = [kw.replace('_', ' ') for kw in keyword_functions if source.count(kw) == 1]
    return keywords


def check_all_keywords_are_used(file_path, file_keywords, output_xml_keywords):
    """
    Compares lists of keywords and logs to /tmp/lukai.log

    :param file_path: PosixPath object from pathlib with path to robot file
    :param file_keywords: list of keywords from robot file
    :param output_xml_keywords: list of keywords from output.xml file
    """
    file_name = os.path.basename(file_path)
    unused_keywords = sorted(set(file_keywords) - set(output_xml_keywords))
    if unused_keywords:
        with open('/tmp/lukai.log', 'a') as report:
            report.write(f'\033[1m{file_name}\033[0m - not used \033[1mkeywords\033[0m:\n')
            for lib in unused_keywords:
                report.write(f"\033[0;33m{lib}\033[0m\n")


def get_current_robotframework_version():
    """
    Gets current version of robotframework package

    :return rf_version: robotframework version
    """
    rf_version = pkg_resources.get_distribution('robotframework').version
    return rf_version


def update_robotframework():
    """
    Perform update on robotframework package inside test_repo virtual environment
    """
    result_code = os.system('/home/ute/test_repo/bin/python -m pip install robotframework==5.0.1 > /dev/null')
    if result_code != 0:
        print("[ERROR] Update of robotframework library failed")
    else:
        print('\n[INFO] Updated robotframework to newer version 5.0.1 for script execution')


def downgrade_robotframework_to_old_version(rf_version):
    """
    Installs robotframework with specified version
    """
    result_code = os.system(f'/home/ute/test_repo/bin/python -m pip install robotframework=={rf_version} > /dev/null')
    if result_code != 0:
        print("[ERROR] Downgrade of robotframework library failed")
    else:
        print(f'[INFO] Downgraded robotframework to previous version {rf_version}')


if __name__ == '__main__':
    rf_version = get_current_robotframework_version()
    update_robotframework()
    input_arg = sys.argv[1]
    libs_all_output_xmls = []
    keywords_all_output_xmls = []
    dryrun_results = []

    validate_input()
    clean_lukai_log()
    test_suites, resources, resources_py = get_abs_filepaths_for_robot_files(input_arg)
    display_dryrun_list(test_suites)

    for number, test_file in enumerate(test_suites, 1):
        result = run_dryrun_for_test(test_file, number, test_suites)
        dryrun_results.append(result)
        test_file_imports = get_imports_for_file(test_file)
        output_xml_libraries = get_libraries_for_output_xml(test_file)
        test_file_keywords = get_keywords_from_robot_file(test_file)
        output_xml_keywords = get_keywords_for_output_xml(test_file)
        check_all_imports_are_used(test_file, test_file_imports, output_xml_libraries, exclude_import_list)
        check_all_keywords_are_used(test_file, test_file_keywords, output_xml_keywords)
        libs_all_output_xmls.extend(output_xml_libraries)
        keywords_all_output_xmls.extend(output_xml_keywords)

    if 'fail' in dryrun_results:
        print(f"\n{'-' * 60}\nOutput:")
        print('At least on of the testcases failed dryrun. Import/keywords check skipped.\n'
              'Fix tests and re-run the script.\n')
    else:
        for resource_file in resources:
            resource_imports = get_imports_for_file(resource_file)
            resource_keywords = get_keywords_from_robot_file(resource_file)
            check_all_imports_are_used(resource_file, resource_imports, libs_all_output_xmls, exclude_import_list)
            check_all_keywords_are_used(resource_file, resource_keywords, keywords_all_output_xmls)

        for resource_file in resources_py:
            resource_keywords = get_keywords_from_python_file(resource_file)
            check_all_keywords_are_used(resource_file, resource_keywords, keywords_all_output_xmls)

        display_results()
    downgrade_robotframework_to_old_version(rf_version)
