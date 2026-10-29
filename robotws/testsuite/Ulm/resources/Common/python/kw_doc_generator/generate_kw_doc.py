"""
┌──────────────────────────────┐
│   Skriptstart (__main__)     │
└────────────┬─────────────────┘
             │
             ▼
  Für jeden Bereich (Common, SyVe, ET):
             │
             ▼
  Für jeden Typ (Library: .py, Resource: .robot):
             │
             ▼
┌──────────────────────────────┐
│ Zeige INCLUDED-Verzeichnisse │
└────────────┬─────────────────┘
             │
             ▼
┌──────────────────────────────┐
│  get_ulm_files(...) aufrufen │
│   → durchsucht Verzeichnisse │
│   → filtert EXCLUDED         │
│   → filtert Dateinamen       │
└────────────┬─────────────────┘
             │
             ▼
┌──────────────────────────────┐
│ Liste gültiger Dateien       │◄────────────┐
└────────────┬─────────────────┘             │
             │                               │
             ▼                               │
┌──────────────────────────────┐             │
│ save_docs(...) aufrufen      │             │
│   → Zielordner erstellen     │             │
│   → EXCLUDED-Dateien filtern │             │
│   → libdoc() aufrufen        │             │
│   → .html-Datei schreiben    │             │
└────────────┬─────────────────┘             │
             │                               │
             ▼                               │
  → nächster Bereich oder Typ? ──────────────┘
             │
             ▼
┌──────────────────────────────┐
│   "Documentation finished"   │
└──────────────────────────────┘

"""
from os import walk
from os.path import join, dirname, abspath, splitext
from pprint import pprint
from robot.libdoc import libdoc
import datetime
import fnmatch
import os

THIS_DIR = dirname(abspath(__file__)) + '/testsuite/Ulm/'

# filter options to include/exclude directories recursivelly
INCLUDED_COMMON_LIB_DIRS = [
    THIS_DIR + 'resources/Common/python',
    ]
EXCLUDED_COMMON_LIB_DIRS = [
    THIS_DIR + 'resources/Common/python/__pycache__',
    THIS_DIR + 'resources/Common/python/kw_doc_generator',
    THIS_DIR + 'resources/Common/python/tti_analyzer_framework/__pycache__',
    THIS_DIR + 'resources/Common/python/ltepat/__pycache__',
    THIS_DIR + 'resources/Common/LogCollectionCI',
    THIS_DIR + 'resources/Common/python/test',
    ]

INCLUDED_SYVE_LIB_DIRS = [
    THIS_DIR + 'SyVe/resources/python_libs',
    THIS_DIR + 'SyVe/CSV/libraries',
    THIS_DIR + 'SyVe/resources/sqd63'
    ]
EXCLUDED_SYVE_LIB_DIRS = [
    THIS_DIR + 'SyVe/resources/python_libs/__pycache__',
    THIS_DIR + 'SyVe/resources/sqd63/__pycache__'
    ]

INCLUDED_ET_LIB_DIRS = [
    THIS_DIR + 'ET/resources/'
    ]
EXCLUDED_ET_LIB_DIRS = [
    THIS_DIR + 'ET/resources/tti_analysis/__pycache__',
    THIS_DIR + 'ET/resources/SQD66/__pycache__',
    THIS_DIR + 'ET/resources/SQD68/__pycache__'
    ]

INCLUDED_COMMON_RES_DIRS = [
    THIS_DIR + 'resources/Common'
    ]
EXCLUDED_COMMON_RES_DIRS = [
    THIS_DIR + 'resources/Common/config',
    THIS_DIR + 'resources/Common/test',
    THIS_DIR + 'resources/Common/tools',
    THIS_DIR + 'resources/Common/jupyter',
    THIS_DIR + 'resources/Common/bash',
    THIS_DIR + 'resources/Common/LogCollectionCI',
    THIS_DIR + 'resources/Common/ResourceCI',
    THIS_DIR + 'resources/Common/Examples',
    THIS_DIR + 'resources/Common/NIDD',
    THIS_DIR + 'resources/Common/syslog_parser'
    ]
EXCLUDED_COMMON_RES_DIRS = list(set(EXCLUDED_COMMON_RES_DIRS + EXCLUDED_COMMON_LIB_DIRS + INCLUDED_COMMON_LIB_DIRS))

INCLUDED_SYVE_RES_DIRS = [
    THIS_DIR + 'SyVe/resources',
    THIS_DIR + 'SyVe/CSV/resources'
    ]

EXCLUDED_SYVE_RES_DIRS = [
    THIS_DIR + 'SyVe/resources/Examples',
    THIS_DIR + 'SyVe/resources/IPSL_with_ONE_QCI_for_2IMSI',
    THIS_DIR + 'SyVe/resources/IPSL_2Diff_QCI_for_2IMSI',
    THIS_DIR + 'SyVe/resources/IPSL_with_3QCI_and_2IMSI',
    THIS_DIR + 'SyVe/resources/python_libs',
    THIS_DIR + 'SyVe/resources/python_libs/__pycache__',
    THIS_DIR + 'SyVe/resources/SW_installation_on_SM',
    THIS_DIR + 'SyVe/resources/SW_installation_on_SM/__pycache__',
    THIS_DIR + 'SyVe/resources/sqd63/__pycache__'
    ]

INCLUDED_ET_RES_DIRS = [
    THIS_DIR + 'ET/resources/'
    ]
EXCLUDED_ET_RES_DIRS = [
    THIS_DIR + 'ET/resources/tti_analysis/__pycache__',
    THIS_DIR + 'ET/resources/SQD66/__pycache__',
    THIS_DIR + 'ET/resources/SQD68/__pycache__'
    ]

# filter options to exclude specific files only
# some of the files have direct dependencies to robot resources
# as their execution context isn't available we filter these files
EXCLUDED_COMMON_LIBS = [
    'generate_kw_doc',
    'testline_information',
    'tti_events',
    'tti_info_elements',
    'tti_dataframe',
    ]
EXCLUDED_COMMON_RESOURCES = []

EXCLUDED_SYVE_LIBS = []
EXCLUDED_SYVE_RESOURCES = []

EXCLUDED_ET_LIBS = []
EXCLUDED_ET_RESOURCES = []


t = datetime.datetime.now()
version = t.strftime('%b-%d-%Y')


def get_ulm_files(included_dirs, incl_extention, excluded_dirs):
    matches = []
    excluded_dirs = [os.path.normpath(os.path.abspath(d)) for d in excluded_dirs]

    for dir_ in included_dirs:
        for root, _, filenames in walk(dir_):
            root_path = os.path.normpath(os.path.abspath(root))
            if any(root_path.startswith(ex) for ex in excluded_dirs):
                print("--- Ignore directory {}".format(root_path))
                continue
            print("+++ Add directory {}".format(root_path))
            for filename in fnmatch.filter(filenames, '[!_]*.' + incl_extention):
                print("+++ Add filename {}".format(filename))
                matches.append(join(root_path, filename))
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
        out_file = os.path.join(dirname(abspath(__file__)), target, filename_no_ext + '.html')
        # print("!!! path:{0} out_file:{1}".format(path, out_file))
        try:
            libdoc(library_or_resource=path, outfile=out_file, name=filename_no_ext, version=version)
            os.chmod(out_file, 0o666)
            print(f"+++ Successfully documented: {filename_no_ext}")
        except Exception as e:
            print(f"--- Skipped '{filename_no_ext}': {type(e).__name__}: {e}")


if __name__ == '__main__':
    # COMMON Libs + Resources
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

    # SyVe Libs + Resources
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

    # ET Libs + Resources
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
