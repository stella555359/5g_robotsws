# #####################################################################################
# QcFilesCleaner.py
# ------------------
#
# _____________________________________________________________________________________
# 09-Sep-2021 | Richard DUTHU       | V1.0 | Initial Release
# _____________________________________________________________________________________
#  This tool needs some environment preparation:
#  1-  You need to use Python 3
#      You need to clone the robotws5g master branch onto your local computer
#
#  2-  You need to customise these parameters:
#      a-  list_path   : repository pathname to be scanned. It should be coherent with the tool installation,
#                        i.e.: it is the relative path from where you will launch the QcFilesParser.py
#      b-  key_pattern : It allows to select specific robot files
#                        example:
#                        if set to "CA_5G_SW_FR-Villarceaux", only Nokia Paris Saclay robot files will be scanned
#      c-  old_pattern_list : it is the list of load name to be deleted in the selected .qc files
#
#  4-  To launch the tool:
#      a- go to the directory where QcFilesCleaner is installed
#      b- type this command :  python3 QcFilesCleaner.py
#      In the created Results direcotory, you will find:
#         - files with .qc.ori extension : it is the original .qc files
#         - files with .qc     extension : it is the modified .qc files
#
#  For any support, please contact the author or the AF Team in Nokia Paris Saclay
# _____________________________________________________________________________________
import subprocess
import shlex
import os
import json
import codecs
import sys


class QcFilesParser(object):
    """
    Will parse the repository to find all robot files with the key_pattern
    Then will generate the CSV file with all the requested data
    """

    def __init__(self):
        pass

    def files_processing(self, list_path, key_pattern, old_pattern_list):
        """"
        Step1 : search all .robot files containing the key_pattern
        Step2 : from files list created in step 1, create the list of the "key_pattern" directory
        Step3 : from files list created in step 2, create the list of the .qc files to be modified
        Step4 : duplicate the .qc files into a loacal directory in order to not modified original files
        Step5 : open each .qc file and set the new QC pathname and update data
        """
        print("===========================================================================")
        # Step1 : The temp_robotFiles.txt will contain the list of "key_pattern" robot files:
        fOut = codecs.open("temp_robotFiles.txt", "w")
        for start_path in list_path:
            # Get all robot files present in the list_path repository
            print("ROBOT files processing:")
            list_file = self._findSpecificFiles(start_path, ".robot")
            print("  Now search all Robot files containing the mandatory pattern {}:".format(key_pattern))
            nb_files = 0
            for idx, filename in enumerate(list_file):
                if len(filename) > 0:
                    found_pattern = self._is_pattern_in_file(filename, key_pattern)
                    if found_pattern:
                        fOut.write(filename + "\n")
                        nb_files += 1
            print("    {} {} files found".format(nb_files, key_pattern))
        fOut.close()

        # Step2: The temp_qcPathname.txt will contain the list of "key_pattern" directories:
        fIn = codecs.open("temp_robotFiles.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        fOut = codecs.open("temp_qcPathname.txt", "w")
        print("  Now get all QC files")
        for robot_filename in files_list:
            robot_pathname, robot_name = os.path.split(robot_filename)
            robot_pathname = robot_pathname.replace("\\", "/")
            fOut.write(robot_pathname + "/\n")
        fOut.close()
        self._keepOnlyOneItem("temp_qcPathname.txt")

        # Step3: The temp_qcFilesList.txt will contain the list of QC files to be updated:
        fIn = codecs.open("temp_qcPathname.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        fOut = codecs.open("temp_qcFilesList.txt", 'w')
        nb_files = 0
        for qc_path in files_list:
            qc_path = qc_path.replace("\n", "")
            found_file_list = self._findSpecificFiles(qc_path, ".qc")
            for idx, filename in enumerate(found_file_list):
                if len(filename) > 0:
                    fOut.write(filename + "\n")
                    nb_files += 1
        print("    {} qc files found".format(nb_files))
        fOut.close()

        # Step4: Duplicate original QC files into the tmpQcFiles directory:
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            qc_pathname, qc_filename = os.path.split(qc_file)
            cmd = 'cp {} Results/{}.ori'.format(qc_file, qc_filename)
            ret = self._exec_w_ret(cmd)

        # Step5: In new QC path update and then update load data:
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            qc_pathname, qc_filename = os.path.split(qc_file)
            ori_qc_name = "Results/{}.ori".format(qc_filename)
            new_qc_name = "Results/{}".format(qc_filename)
            self._create_new_line(new_qc_name)
            # Delete all unexpected patterns
            self._delete_patterns(ori_qc_name, new_qc_name, old_pattern_list)

            # Some cleanup:
            self._remove_last_comma(new_qc_name)
            # Next line put in comment until error is understood and fixed
            # self._remove_tmp_files()
        print("===========================================================================")
        print(" ==> New QC files are generated here: tmpQcFile ")
        print("===========================================================================")

    def _delete_patterns(self, qc_file, new_qc_file, old_pattern_list):
        """
        Open the qc file as a json file and then search and remove unwanted patterns
        Create a new purged QC file
        """
        print("    qc_file={}".format(qc_file))
        my_dict = {}
        with codecs.open(qc_file, 'r') as sourceFile:
            element = json.load(sourceFile)
            for (key, value) in element.items():
                print("    key: {}".format(key))
                rejected = False
                for old_pattern in old_pattern_list:
                    if old_pattern in key:
                        print("         ... disabled pattern => removed")
                        rejected = True
                        break
                if rejected is not True:
                    print("         ... enabled pattern => kept")
                    my_dict[key] = value
        # Result file creation
        with codecs.open(new_qc_file, 'w') as newFile:
            json.dump(my_dict, newFile, indent=4)

    def _remove_last_comma(self, new_file):
        """
        Open the QC file and remove the last comma
        """
        pattern1 = "},\n}"
        pattern2 = "}\n}"
        fOut = codecs.open(new_file, 'r')
        line = fOut.read().replace(pattern1, pattern2, 1)
        fOut.close()
        fOut = codecs.open(new_file, 'w')
        fOut.write(line)
        fOut.close()

    def _remove_tmp_files(self):
        """
        Remove the temporary files if requested by user
        PROBLEME : Les fichiers sont bien effaces mais on recoit ce mesage d erreur:
            AssertionError: Error on command: rm temp_qcFilesList.txt :
            ERR CODE=1 SDTERR=b'rm: cannot remove \xe2\x80\x98temp_qcFilesList.txt\xe2\x80\x99:
            No such file or directory\n'
        """
        cmd = 'rm temp_qcFilesList.txt'
        ret = self._exec_w_ret(cmd)
        cmd = 'rm temp_qcPathname.txt'
        ret = self._exec_w_ret(cmd)
        cmd = 'rm temp_robotFiles.txt'
        ret = self._exec_w_ret(cmd)

    def _create_new_line(self, new_file):
        """
        Open the QC file and insert the first { and last }
        """
        print("    \nqc_file={} will be created ".format(new_file))
        pattern1 = "{\n}\n"
        fOut = codecs.open(new_file, 'w')
        fOut.write(pattern1)
        fOut.close()

    def _is_pattern_in_file(self, filename, this_string):
        """
        Determine if the key_pattern is or not present in the file.
        """
        filename = filename.replace("\\", "/")
        with codecs.open(filename, encoding='utf-8', mode='r') as f:
            if this_string in f.read():
                return 1

    def _findSpecificFiles(self, path, pattern):
        """
        path : repository where to search all specified files
        pattern : file type to be searched
        """
        wantedfiles = [os.path.join(root, name)
                       for root, dirs, files in os.walk(path)
                       for name in files
                       if name.endswith(pattern)]
        return wantedfiles

    def _keepOnlyOneItem(self, filename):
        """
        Open the file, remove all duplicated lines and return the purged file
        """
        with codecs.open(filename, 'r') as file:
            lines = set(file.readlines())
        with codecs.open(filename, 'w') as file:
            file.writelines(lines)

    def _exec_w_ret(self, cmd):
        """
        Execute a system command, and retrieve and trace console result
        WARNING : do not use "|" mechanism in command
        """
        my_list = shlex.split(cmd)
        proc = subprocess.Popen(my_list, stdout=subprocess.PIPE,
                                stderr=subprocess.PIPE, shell=False)
        stdout, stderr = proc.communicate()
        ret_code = proc.returncode
        assert ret_code == 0, \
            'Error on command: {} : ERR CODE={} SDTERR={}'.format(cmd, ret_code, stderr)
        return stdout.decode('utf-8')


# ==========================================================================================
# main - To launch the tool
# ==========================================================================================
"""
"""
if __name__ == '__main__':
    # Parameters to adapt to your particular case:
    key_pattern = "CA_5G_SW_FR-Villarceaux"

    # Key Patterns to be removed in .qc files
    old_pattern_list = ["5G_",
                        "SBTS21A_",
                        "5G21B_",
                        "5G21A_",
                        "5G20B_",
                        "5G20A_"
                        ]
    # Only the list_path can be passed as input parameter
    if len(sys.argv) > 1:
        list_path = [sys.argv[1]]
    else:
        # The list_path is set to the default value:
        list_path = ["../robotws5g/testsuite/Paris"]
        # list_path = ["../robotws5g/testsuite/RRM/ECE/Cell_Throughput/TDD_MultiBW/5GC001000_20MHz"]

    QcFilesParser = QcFilesParser()
    QcFilesParser.files_processing(list_path=list_path,
                                   key_pattern=key_pattern,
                                   old_pattern_list=old_pattern_list)
