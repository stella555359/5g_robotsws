from os import walk
from os.path import join, dirname, abspath, splitext
from pprint import pprint
from robot.libdoc import libdoc
import datetime
import fnmatch
import os

THIS_DIR = dirname(abspath(__file__))


INCLUDED_COMMON_LIB_DIRS = [
    THIS_DIR + '/testsuite/Ulm/resources/Common/python',
    ]
EXCLUDED_COMMON_LIB_DIRS = [
    THIS_DIR + '/testsuite/Ulm/resources/Common/python/kw_doc_generator',
    THIS_DIR + '/testsuite/Ulm/resources/Common/python/test',
    THIS_DIR + '/testsuite/Ulm/resources/Common/python/__pycache__',
    THIS_DIR + '/testsuite/Ulm/resources/Common/python/tti_analyzer_framework/__pycache__',
    THIS_DIR + '/testsuite/Ulm/resources/Common/python/test/__pycache__'
    ]

INCLUDED_SYVE_LIB_DIRS = [
    THIS_DIR + '/testsuite/Ulm/SyVe/resources/python_libs',
    THIS_DIR + '/testsuite/Ulm/SyVe/resources/sqd63'
    ]
EXCLUDED_SYVE_LIB_DIRS = [
    THIS_DIR + '/testsuite/Ulm/SyVe/resources/python_libs/__pycache__',
    ]

INCLUDED_ET_LIB_DIRS = [
    THIS_DIR + '/testsuite/Ulm/ET/resources/'
    ]
EXCLUDED_ET_LIB_DIRS = [
    THIS_DIR + '/testsuite/Ulm/ET/resources/tti_analysis/__pycache__'
    ]


INCLUDED_COMMON_RES_DIRS = [
    THIS_DIR + '/testsuite/Ulm/resources/Common'
    ]
EXCLUDED_COMMON_RES_DIRS = [
    THIS_DIR + '/testsuite/Ulm/resources/Common/config',
    THIS_DIR + '/testsuite/Ulm/resources/Common/config/__pycache__',
    THIS_DIR + '/testsuite/Ulm/resources/Common/test',
    THIS_DIR + '/testsuite/Ulm/resources/Common/test',
    THIS_DIR + '/testsuite/Ulm/resources/Common/jupyter',
    THIS_DIR + '/testsuite/Ulm/resources/Common/__pycache__',
    THIS_DIR + '/testsuite/Ulm/resources/Common/bash',
    THIS_DIR + '/testsuite/Ulm/resources/Common/ResourceCI',
    THIS_DIR + '/testsuite/Ulm/resources/Common/ResourceCI_AIC',
    THIS_DIR + '/testsuite/Ulm/resources/Common/Examples',
    THIS_DIR + '/testsuite/Ulm/resources/Common/NIDD'
    ]
EXCLUDED_COMMON_RES_DIRS = list(set(EXCLUDED_COMMON_RES_DIRS + EXCLUDED_COMMON_LIB_DIRS + INCLUDED_COMMON_LIB_DIRS))

INCLUDED_SYVE_RES_DIRS = [
    THIS_DIR + '/testsuite/Ulm/SyVe/resources'
    ]
EXCLUDED_SYVE_RES_DIRS = [
    THIS_DIR + '/testsuite/Ulm/SyVe/resources/Examples',
    THIS_DIR + '/testsuite/Ulm/SyVe/resources/python_libs',
    THIS_DIR + '/testsuite/Ulm/SyVe/resources/python_libs/__pycache__'
    ]

INCLUDED_ET_RES_DIRS = [
    THIS_DIR + '/testsuite/Ulm/ET/resources/'
    ]
EXCLUDED_ET_RES_DIRS = [
    THIS_DIR + '/testsuite/Ulm/ET/resources/tti_analysis/__pycache__',
    THIS_DIR + 'testsuite/Ulm/ET/resources/syslog_parser'
    ]


EXCLUDED_COMMON_LIBS = [
    'generate_kw_doc',
    'testline_information',
    'check_cap',
    'ttitrace_example',
    'test_all_in_cloud',
    'reporting_example',
    'CommissioningTestSuite',
    'reporting',
    'tti_events',
    'tti_info_elements',
    'scf_keywords'
    ]
EXCLUDED_COMMON_RESOURCES = []

EXCLUDED_SYVE_LIBS = []
EXCLUDED_SYVE_RESOURCES = []

EXCLUDED_ET_LIBS = [
    'ue_cell_identification'
    ]
EXCLUDED_ET_RESOURCES = []


t = datetime.datetime.now()
version = t.strftime('%b-%d-%Y')


def get_ulm_files(included_dirs, incl_extention, excluded_dirs):
    matches = []
    for dir_ in included_dirs:
        path_without_ext = splitext(dir_)[0]
        for root, _, filenames in walk(dir_):
            if root in excluded_dirs:
                print("--- Ignore directory {}".format(root))
                continue
            else:
                print("+++ Add directory {} for documentation".format(root))
                print("+++ filenames to filter:")
                pprint(filenames)
                for filename in fnmatch.filter(filenames, '[!_]*.' + incl_extention):
                    print("+++ Add filename {} to documentation list".format(filename))
                    matches.append(join(root, filename))
    return matches


def save_docs(paths, excluded_files, target):
    if not os.path.exists(target):
        os.makedirs(target)
    for path in paths:
        path_without_ext, file_extension = splitext(path)
        filename_no_ext = os.path.split(path_without_ext)[1]
        if filename_no_ext in excluded_files:
            print("--- Ignore file {}".format(path))
            # print("--- filename_no_ext {0} is in excluded_files {1}".format(filename_no_ext, excluded_files))
            continue
        else:
            # print("+++ filename_no_ext {0} isn't in excluded_files {1}".format(filename_no_ext, excluded_files))
            print("+++ Process file {}".format(path))
        out_file = os.path.join(THIS_DIR, target, filename_no_ext + '.html')
        # print("!!! path:{0} out_file:{1}".format(path, out_file))
        libdoc(library_or_resource=path, outfile=out_file, name=filename_no_ext, version=version)
        os.chmod(os.path.join(path, out_file), 0o666)


if __name__ == '__main__':

    print("\n\nSearch Common library files in these directories:".upper())
    pprint(INCLUDED_COMMON_LIB_DIRS)
    paths = get_ulm_files(INCLUDED_COMMON_LIB_DIRS, 'py', EXCLUDED_COMMON_LIB_DIRS)
    print("\nFound Common libraries:".upper())
    pprint(paths)
    print("\nCreate documentation for Common libraries:".upper())
    save_docs(paths, EXCLUDED_COMMON_LIBS, 'Common/python')
    print("\nSearch Common resource files in these directories:".upper())
    pprint(INCLUDED_COMMON_RES_DIRS)
    paths = get_ulm_files(INCLUDED_COMMON_RES_DIRS, 'robot', EXCLUDED_COMMON_RES_DIRS)
    print("\nFound Common resources:".upper())
    pprint(paths)
    print("\nCreate documentation for Common resources:".upper())
    save_docs(paths, EXCLUDED_COMMON_RESOURCES, 'Common/robot')

    print("\n\nSearch SyVe library files in these directories:".upper())
    pprint(INCLUDED_SYVE_LIB_DIRS)
    paths = get_ulm_files(INCLUDED_SYVE_LIB_DIRS, 'py', EXCLUDED_SYVE_LIB_DIRS)
    print("\nFound SyVe libraries:".upper())
    pprint(paths)
    print("\nCreate documentation for SyVe libraries:".upper())
    save_docs(paths, EXCLUDED_SYVE_LIBS, 'SyVe/python')
    print("\nSearch SyVe resource files in these directories:".upper())
    pprint(INCLUDED_SYVE_RES_DIRS)
    paths = get_ulm_files(INCLUDED_SYVE_RES_DIRS, 'robot', EXCLUDED_SYVE_RES_DIRS)
    print("\nFound SyVe resources:".upper())
    pprint(paths)
    print("\nCreate documentation for SyVe resources:".upper())
    save_docs(paths, EXCLUDED_SYVE_RESOURCES, 'SyVe/robot')

    print("\n\nSearch ET library files in these directories:".upper())
    pprint(INCLUDED_ET_LIB_DIRS)
    paths = get_ulm_files(INCLUDED_ET_LIB_DIRS, 'py', EXCLUDED_ET_LIB_DIRS)
    print("\nFound ET libraries:".upper())
    pprint(paths)
    print("\nCreate documentation for ET libraries:".upper())
    save_docs(paths, EXCLUDED_ET_LIBS, 'ET/python')
    print("\nSearch ET resource files in these directories:".upper())
    pprint(INCLUDED_ET_RES_DIRS)
    paths = get_ulm_files(INCLUDED_ET_RES_DIRS, 'robot', EXCLUDED_ET_RES_DIRS)
    print("\nFound ET resources:".upper())
    pprint(paths)
    print("\nCreate documentation for ET resources:".upper())
    save_docs(paths, EXCLUDED_ET_RESOURCES, 'ET/robot')

    print("\n\nDocumentation generation finished.".upper())
