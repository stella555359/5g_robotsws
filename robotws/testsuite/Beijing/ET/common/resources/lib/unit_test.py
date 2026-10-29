# -*- coding: utf-8 -*-
"""
2022/08/11 first version by @author: sheng.1.ye@nokia.com
    This file is to run all modules/ut.py at once
2024/05/30 support auto zip and unzip files in logs folder, by Ye Sheng
"""

import importlib
import unittest
import os
import sys
import time
import glob
import zipfile
from collections import defaultdict


def run_ut_all(depth=2):
    results = {}
    base_path = os.getcwd()
    for path in os.listdir('.'):
        full_path = os.path.join(base_path, path)
        if os.path.isfile(os.path.join(full_path, 'ut.py')):
            print("running %s.ut" % path)
            zip_unzip_files_in_logs_folders(full_path)
            sys.path.insert(0, os.getcwd())
            ut_module = importlib.import_module(path + ".ut")
            os.chdir(full_path)
            if hasattr(ut_module, 'run_ut_all'):
                if depth:
                    results.update(ut_module.run_ut_all(depth - 1))
            else:
                r = unittest.main(module=ut_module, exit=False)
                if not r.result.wasSuccessful():
                    print('module %s Fail' % path)
                    results[path] = 'Fail', r.result
                else:
                    results[path] = 'Pass', r.result
    return results


def run_and_show_ut_all(depth=2):
    counter = defaultdict(list)
    for module_name, (result, detail) in run_ut_all(depth=depth).items():
        print(module_name, result, detail.testsRun)
        counter[result].append(detail)
    print("\n" + "=" * 80)
    time.sleep(0.5)
    for k, v in counter.items():
        print("%s = %d modules (%d cases)" % (k, len(v), sum(i.testsRun for i in v)))


def zip_unzip_files_in_logs_folders(path):
    zip_file_list = glob.glob(os.path.join(path, 'logs/*/*.zip')) + glob.glob(os.path.join(path, 'logs/*.zip'))
    for zip_filename in zip_file_list:
        if not os.path.exists(zip_filename[:-4]):
            with zipfile.ZipFile(zip_filename, 'r') as zip_ref:
                zip_ref.extractall(os.path.dirname(zip_filename))
    file_list = glob.glob(os.path.join(path, 'logs/*/*')) + glob.glob(os.path.join(path, 'logs/*'))
    for filename in file_list:
        if not filename.endswith('zip') and not os.path.exists(filename+'.zip'):
            if os.path.getsize(filename) > 2 * 1024 * 1024:
                with zipfile.ZipFile(filename+'.zip', 'w', zipfile.ZIP_DEFLATED) as zipf:
                    zipf.write(filename, arcname=os.path.basename(filename))


if __name__ == '__main__':
    os.chdir(os.path.dirname(__file__))
    run_and_show_ut_all()
