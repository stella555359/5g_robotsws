# #####################################################################################
# QcFilesParser.py
# ------------------
#
# _____________________________________________________________________________________
# 19/05/2021 | R. Duthu       | V1.0 | Initial Release
# 09/09/2021 | R. Duthu       | V2.0 | Duplicate the SBTS21B into SBTS22R1
# _____________________________________________________________________________________
#  This tool need some environment preparation:
#  1-  You need to clone the robotws5g master branch onto your local computer
#  2-  You need to customise these parameters:
#      a-  list_path   : repository pathname to be scanned. It should be coherent with the tool installation,
#                        i.e.: it is the relative path from where you will launch the QcFilesParser.py
#      b-  key_pattern : It allows to select specific robot files
#                        example:
#                        if set to "CA_5G_SW_FR-Villarceaux", only Nokia Paris Saclay robot files will be scanned
#      c-  csv_filename : the CSV filename will start with this param and end with a timestamp yyyymmdd_hhmmss
#      d-  create_new_item : if true, then create the sbts21b item in QC file
#  4-  To launch the tool, just type : python QcFilesParser.py
#
#  For any support, please contact me or the AF Team in Nokia Paris Saclay
# _____________________________________________________________________________________
import subprocess
import shlex
import re
from datetime import datetime
import os
import json
import codecs
import time


class qc_files_parser(object):
    """
    Will parse the repository to find all robot files with the key_pattern
    Then will generate the CSV file with all the requested data
    """
    # Parameters to adapt to your particular case:
    list_path = ["../robotws5g/testsuite/Paris/RRM/ET/"]
    # list_path = ["../robotws5g/testsuite/RRM/ECE/"]
    key_pattern = "CA_5G_SW_FR-Villarceaux"
    csv_filename = "NPS_QcFiles"
    create_new_item = "True"
    transfert_file = "True"
    debug = "False"

    # Pattern to search or to create in .qc files
    ref_pattern = "SBTS00_"
    new_pattern = "SBTS22R1_"

    # Some counters
    nb_files = 0
    nb_qc_files = 0
    nb_modified_files = 0
    nb_not_modified_files = 0

    def __init__(self):
        pass

    def _files_processing(self):
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
        for start_path in self.list_path:
            # Get all robot files present in the list_path repository
            print("ROBOT files processing:")
            list_file = self._findSpecificFiles(start_path, ".robot")
            print("  Now search all Robot files containing the mandatory pattern {}:".format(self.key_pattern))
#            nb_files = 0
            for idx, filename in enumerate(list_file):
                if len(filename) > 0:
                    found_pattern = self._is_pattern_in_file(filename, self.key_pattern)
                    if found_pattern:
                        fOut.write(filename + "\n")
                        qc_files_parser.nb_files += 1
            print("    {} {} files found".format(qc_files_parser.nb_files, self.key_pattern))
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
        for qc_path in files_list:
            qc_path = qc_path.replace("\n", "")
            found_file_list = self._findSpecificFiles(qc_path, ".qc")
            for idx, filename in enumerate(found_file_list):
                if len(filename) > 0:
                    fOut.write(filename + "\n")
                    qc_files_parser.nb_qc_files += 1
        fOut.close()

        # Step4: Copy QC files from Master to tmpQcFilesNew directory:
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            cmd = 'cp {} tmpQcFilesNew/.'.format(qc_file)
            ret = self._exec_w_ret(cmd)

        # Step5: Add the new branch:
        if qc_files_parser.debug == "True":
            print("    Step5: Add the new branch: {}".format(qc_files_parser.new_pattern))
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            qc_pathname, qc_name = os.path.split(qc_file)
            # save original file
            cmd = 'cp tmpQcFilesNew/{} tmpQcFilesOri/{}.ori'.format(qc_name,  qc_name)
            ret = self._exec_w_ret(cmd)
            qc_name = "tmpQcFilesNew/{}".format(qc_name)
            print("    Processing file : {}".format(qc_name))
            fIn = codecs.open(qc_name, "r")
            # Create the new pattern if requested by user:
            if qc_files_parser.create_new_item == "True":
                # search if new pattern is or not present in qc file
                found = self._is_pattern_in_file(qc_name, qc_files_parser.new_pattern)
                if not found:
                    if qc_files_parser.debug == "True":
                        print("    New pattern {} not found".format(qc_files_parser.new_pattern))
                    new_line = self._add_new_sbts(qc_name, qc_files_parser.ref_pattern, qc_files_parser.new_pattern)
                    print("    ... new pattern created : \n {}".format(new_line))
                    self._insert_new_line_in_qc_file(qc_name, new_line)
                else:
                    print("    ... WARNING File Not Modified : {} /n/n".format(qc_file))
            # Some cleanup in qc.new file:
                    qc_files_parser.nb_not_modified_files += 1
            self._someCleanUp(qc_name)

        print("===========================================================================")
        print(" ==> Number of QC files found        : {} ".format(qc_files_parser.nb_qc_files))
        print(" ==> Number of QC files modified     : {} ".format(qc_files_parser.nb_modified_files))
        print(" ==> Number of QC files Not modified : {} ".format(qc_files_parser.nb_not_modified_files))
        print(" ==> New QC files are generated here : tmpQcFile ")
        print("===========================================================================")

    def _add_new_sbts(self, qc_file, qc_ref_string, qc_new_string):
        """
        Open the qc file as a json file and then create the sbts21b item base on 5G21A item
        """
        newLine = " "
        key = 0
        print("    ... creation of {} item based on {}".format(qc_new_string, qc_ref_string))
        with codecs.open(qc_file, 'r') as jsonFile:
            qcInfo = json.load(jsonFile, strict=False)
            # qcInfo = json.load(jsonFile)
        for qcInfoKey in qcInfo.keys():
            qc_path0 = qcInfo[qcInfoKey].keys()[0]
            qc_path1 = qcInfo[qcInfoKey].keys()[1]
            qc_path2 = qcInfo[qcInfoKey].keys()[2]
            load_info = str(qcInfoKey)
            if qc_files_parser.debug == "True":
                print("      qcInfoKey={}".format(qcInfoKey))
                print("      qc_path0={}".format(qc_path0))
                print("      qc_path1={}".format(qc_path1))
                print("      qc_path2={}".format(qc_path2))
                print("      load_info={}".format(load_info))
                print("      ")
            # Create the new item
            found_trunk = qc_path0.find("Trunk")
            if qc_files_parser.debug == "True":
                print("      found-trunk 0 = {}".format(found_trunk))
            if found_trunk > 0:
                qc_path = qc_path0
                key = 0
                found_trunk = True
            found_trunk = qc_path1.find("Trunk")
            if qc_files_parser.debug == "True":
                print("      found-trunk 1 = {}".format(found_trunk))
            if found_trunk > 0:
                qc_path = qc_path1
                key = 1
                found_trunk = True
            found_trunk = qc_path2.find("Trunk")
            if qc_files_parser.debug == "True":
                print("      found-trunk 2 = {}".format(found_trunk))
            if found_trunk > 0:
                qc_path = qc_path2
                key = 2
                found_trunk = True
            if found_trunk and qc_ref_string in load_info:
                if qc_files_parser.debug == "True":
                    print("    Trunk found...")
                load_json = "\"" + qc_new_string + ".*" + "\": {"
                tmp_path = str(qcInfo[qcInfoKey].keys()[key]).replace("\\", "\\\\")
                path_json = "\"" + tmp_path + "\": {"
                test_json = qcInfo[qcInfoKey][qc_path].keys()
                file_json = ""
                nb_item = 0
                max_item = len(test_json) - 1
                if qc_files_parser.debug == "True":
                    print("    max_item={}".format(max_item))
                for item in test_json:
                    file_json = file_json + "\t\t\t\"" + test_json[nb_item] + "\": [\".*\"]"
                    if nb_item < max_item:
                        file_json = file_json + ","
                    file_json = file_json + "\n"
                    nb_item += 1
                label_json = "\"label\": \".*\","
                qc_domain = "\"qc_domain\": \"MN_RAN\","
                qc_project = "\"qc_project\": \"RAN_ET\","
                acc_json = "}"
                newLine = "\t{}\n\t\t{}\n\t\t{}\n\t\t{}\n\t\t{}\n{}\t\t{}\n\t{},\n" \
                    .format(load_json, label_json, qc_domain, qc_project, path_json, file_json, acc_json, acc_json)
                qc_files_parser.nb_modified_files += 1
                break
        newLine = newLine.replace("Trunk", "22R1\\\\Regression")
        return newLine

    def _someCleanUp(self, new_file):
        """
        Open the QC file and remove the last comma, replace tab with 4 spaces
        """
        fOut = codecs.open(new_file, 'r')
        line = fOut.read()
        line = re.sub(r'},\n\s*}', '}\n}', line)
        line = re.sub("\t", "    ", line)
        fOut.close()
        fOut = codecs.open(new_file, 'w')
        fOut.write(line)
        fOut.close()

    def _insert_new_line_in_qc_file(self, new_file, new_line):
        """
        Open the QC file and replace the first { with the new created line
        """
        if qc_files_parser.debug == "True":
            print("      ==> {} will receive this new Item :\n{}\n".format(new_file, new_line))
        pattern1 = "{\n"
        pattern2 = "{\n" + new_line
        fOut = codecs.open(new_file, 'r')
        line = fOut.read().replace(pattern1, pattern2, 1)
        fOut.close()
        fOut = codecs.open(new_file, 'w')
        fOut.write(line)
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
        time.sleep(0.1)
        assert ret_code == 0,\
            "Error on command: {} : ERR CODE={} SDTERR={}".format(cmd, ret_code, stderr)
        return stdout.decode('utf-8')

    def _rename_original_files(self):
        # Copy original QC files into .ori:
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            cmd = 'cp {} {}.ori'.format(qc_file, qc_file)
            print("rename_original_files: {}".format(cmd))
            # ret = self._exec_w_ret(cmd)

    def _transfer_new_qc_files(self):
        # Transfer new QC files into the source directory:
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            qc_pathname, qc_name = os.path.split(qc_file)
            cmd = 'cp tmpQcFilesNew/{} {}/{}'.format(qc_name, qc_pathname, qc_name)
            print("transfer_new_qc_files: {}".format(cmd))
            # ret = self._exec_w_ret(cmd)

    def _create_working_directories(self):
        # Copy original QC files into .ori:
        cmd = 'mkdir -p tmpQcFilesNew'
        ret = self._exec_w_ret(cmd)
        cmd = 'mkdir -p tmpQcFilesOri'
        ret = self._exec_w_ret(cmd)
        time.sleep(1)
        cmd = 'rm -f tmpQcFilesNew/*.qc'
        ret = self._exec_w_ret(cmd)
        time.sleep(1)
        cmd = 'rm -f tmpQcFilesOri/*.qc.ori'
        ret = self._exec_w_ret(cmd)


# ==========================================================================================
# main - To launch the tool
# ==========================================================================================
"""
"""
if __name__ == '__main__':
    qc_files_parser = qc_files_parser()
    qc_files_parser._create_working_directories()
    qc_files_parser._files_processing()

    if qc_files_parser.transfert_file == "True":
        qc_files_parser._rename_original_files()
        qc_files_parser._transfer_new_qc_files()
