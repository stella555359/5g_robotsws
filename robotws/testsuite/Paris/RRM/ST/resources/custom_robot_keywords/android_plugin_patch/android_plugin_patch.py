#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""


class android_plugin_patch:
    """

    static class intended to patch ta-ue-plugin-android for 5G use.
    """

    def patch_android_plugin_lib(self):
        """

        @return:
        """
        import os as os
        import sys as sys

        import ta_ue_plugin_android.uepc.qmdl_decoder as qmdl_decoder
        import ta_ue_plugin_android.uepc.android_control as android_control
        import ta_ue_plugin_android.uepc.server_runner as server_runner

        loaded_modules = ['qmdl_decoder']

        dir_path = os.path.dirname(os.path.abspath(__file__))

        patch_files_path = {
            os.path.join(dir_path, 'qmdl_decoder.py'): qmdl_decoder.__file__[:],
            os.path.join(dir_path, 'android_control.py'): android_control.__file__[:],
            os.path.join(dir_path, 'server_runner.py'): server_runner.__file__[:]
        }

        for module_name in loaded_modules:
            if module_name in sys.modules:
                del sys.modules[module_name]

        err = ''
        # supp of .pyc to avoid any problem
        for key in patch_files_path.keys():
            if os.path.isfile(patch_files_path[key]) and patch_files_path[key][-3:] == 'pyc':
                command = "rm '{}'".format(patch_files_path[key])
                child_stdin, child_stdout, child_stderr = os.popen3(command)
                error = child_stderr.read()
                if bool(error):
                    err += ">>> Error while executing:\n" \
                           + command \
                           + "\n>>> Returned with error:\n" \
                           + str(error)
        # copy of patched file

        for key in patch_files_path.keys():
            command = "cp '{}' '{}'".format(key, patch_files_path[key].replace('.pyc', '.py'))
            child_stdin, child_stdout, child_stderr = os.popen3(command)
            error = child_stderr.read()
            if bool(error):
                err += ">>> Error while executing:\n" \
                       + command \
                       + "\n>>> Returned with error:\n" \
                       + str(error)
        return err

    def patch_qmdl_file(self):
        """

        @return:
        """
        import os as os
        import sys as sys

        import ta_ue_plugin_android.uepc.qmdl_decoder as qmdl_decoder

        loaded_modules = ['qmdl_decoder']

        dir_path = os.path.dirname(os.path.abspath(__file__))

        patch_files_path = {
            os.path.join(dir_path, 'qmdl_decoder.py'): qmdl_decoder.__file__[:]
        }

        for module_name in loaded_modules:
            if module_name in sys.modules:
                del sys.modules[module_name]

        err = ''
        # supp of .pyc to avoid any problem
        for key in patch_files_path.keys():
            if os.path.isfile(patch_files_path[key]) and patch_files_path[key][-3:] == 'pyc':
                command = "rm '{}'".format(patch_files_path[key])
                child_stdin, child_stdout, child_stderr = os.popen3(command)
                error = child_stderr.read()
                if bool(error):
                    err += ">>> Error while executing:\n" \
                           + command \
                           + "\n>>> Returned with error:\n" \
                           + str(error)
        # copy of patched file

        for key in patch_files_path.keys():
            command = "cp '{}' '{}'".format(key, patch_files_path[key].replace('.pyc', '.py'))
            child_stdin, child_stdout, child_stderr = os.popen3(command)
            error = child_stderr.read()
            if bool(error):
                err += ">>> Error while executing:\n" \
                       + command \
                       + "\n>>> Returned with error:\n" \
                       + str(error)
        return err

    def patch_Software_file(self):
        import os as os
        import sys as sys

        import taf.selenium.gnb.oam.coam.classical.pages.software as Software

        err = ''
        file_path = Software.__file__[:]
        if 'taf.selenium.gnb.oam.coam.classical.pages.software' in sys.modules.keys():
            del sys.modules['taf.selenium.gnb.oam.coam.classical.pages.software']
        if file_path[-2:] == 'py':
            file_path = file_path[:-2] + 'pyc'
        if os.path.isfile(file_path):
            command = "rm '{}'".format(file_path)
            child_stdin, child_stdout, child_stderr = os.popen3(command)
            error = child_stderr.read()
            if bool(error):
                err += ">>> Error while executing:\n" \
                       + command \
                       + "\n>>> Returned with error:\n" \
                       + str(error)

        file_path = file_path.replace('.pyc', '.py')

        with open(file_path, "r") as source_file:
            lines = source_file.readlines()
        next_line = False
        with open(file_path, "w") as source_file:
            for line in lines:
                if "self.select_checkbox_by_specified_status" in line:
                    if line.lstrip()[0] != '#':
                        line = "#" + line
                        next_line = True
                elif next_line:
                    line = "#" + line
                    next_line = False
                source_file.write(line)
