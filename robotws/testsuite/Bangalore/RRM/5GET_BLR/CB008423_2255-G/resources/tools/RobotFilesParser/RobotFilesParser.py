# #####################################################################################
# RobotTestParser.py
# ------------------
#
# ---------------------------------------------------------------------------------------------------------------------
# 05-May-2021 | Richard DUTHU       | V1.0 | Initial Release
# 02-Jun-2021 | Richard DUTHU       | V1.1 | Add "SBTSxxx branch load" column
# 14-Jun-2021 | Richard DUTHU       | V1.2 | New TAGS
# 16-Jun-2021 | Richard DUTHU       | V1.3 | Hyperlink addition
# 21-Jun-2021 | Richard DUTHU       | V1.4 | Generate directly an Excel file with several sheets
# 29-Sep-2021 | Richard DUTHU       | V1.5 | Create a zip file containing all Robot and Qc files
# 05-Oct-2021 | Richard DUTHU       | V1.6 | Create a new sheets to have TC with or without 22R1 files
# 18-Oct-2021 | Richard DUTHU       | V1.7 | Fix for issue about the CIT tag not well detected.
# ---------------------------------------------------------------------------------------------------------------------
#  This tool needs some environment preparation:
#  1-  You need to use Python 3
#      You need to clone the robotws master branch onto your local computer
#      You need to install pandas   : pip3 install pandas
#      You need to install openpyxl : pip3 install openpyxl
#
#  2-  You need to customise these parameters in the RobotFilesParser.ini file :
#      a-  list_path   : repository pathname to be scanned. It should be coherent with the tool installation,
#                        i.e.: it is the relative path from where you will launch the RobotFilesParser.py
#      b-  key_pattern : It allows to select specific robot files
#                        example:
#                        if set to "CA_5G_SW_FR-Villarceaux", only Nokia Paris Saclay robot files will be scanned
#      c-  result_filename : the CSV filename will start with this param and end with a timestamp yyyymmdd_hhmmss
#
#  3-  To launch the tool:
#      a-  Open and customize the shell script named Launch_RobotFilesParser_On_EspooVM.sh script
#      b-  Add executable right on the shell scrpit
#      c-  Launch the shell script : ./Launch_RobotFilesParser_On_EspooVM.sh
#      Three files will be generated: a .csv file, a .xlsx file and a .zip file (all .robot and .qc files)
#
#  For any support, please contact the author or the AF Team in Nokia Paris Saclay
# ---------------------------------------------------------------------------------------------------------------------
import subprocess
import shlex
import re
from datetime import datetime
import os
import pandas as pd
import sys
import codecs
from RobotFilesParser_config import *
from openpyxl import load_workbook
from openpyxl import Workbook

# PARSE CONFIG FILE:
Config = ConfigClass()


class robot_parser(object):
    """
    Will parse the repository to find all robot files with the key_pattern
    Then will generate the CSV file with all the requested data
    """

    def __init__(self):
        self.testcase_name = []
        self.trunk_load = ""
        self.master_load = ""
        self.branch_load = ""
        self.sbtsbranch_load = ""
        self.cloud_load = ""
        self.global_scope = ""
        self.global_old_scope = ""
        self.global_cit_crt_cdrt = ""
        self.forced_tags_cit = ""
        self.forced_tags_crt = ""
        self.forced_tags_cdrt = ""
        self.global_topology = ""
        self.local_topology = ""
        self.local_cit = ""
        self.local_crt = ""
        self.local_cdrt = ""
        self.local_cit_crt_cdrt = ""
        self.global_cit = ""
        self.global_crt = ""
        self.global_cdrt = ""
        self.settings_found = False
        self.force_tags_found = False
        self.test_cases_found = False
        pass

    def files_processing(self,
                         list_path=Config.list_path,
                         key_pattern=Config.key_pattern,
                         result_filename=Config.result_filename):
        """"
        Create the CSV result file and open it
        Search and process all .robot files discovered in selected directories
        """
        print("===========================================================================")
        # Create the CSV result file and open it:
        result_file = self._create_filename(result_filename)
        fCsv = open(result_file, "w")
        fCsv.write(Config.file_header + "\n")

        # Create a temporary file which will contain all robot files having the key pattern:
        self._create_robot_files_list("temp_robotFilesList.txt", list_path, key_pattern)

        print("  Now search All TestCase Name in selected Robot files")
        fIn = open("temp_robotFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        # For each robot file in the temporary file:
        for robot_filename in files_list:
            robot_filename = robot_filename.replace("\n", "")
            print("    scan of : {}".format(robot_filename))
            self._analyze_the_robot_file(robot_filename)

            # Group data by theme:
            new_line_part1 = "{};".format(robot_filename.replace("../robotws/", ""))
            new_line_part3 = "{};{};{};".format(self.global_scope,
                                                self.global_old_scope,
                                                key_pattern)
            new_line_part4 = "{};{};{};{};{};".format(self.trunk_load,
                                                      self.sbtsbranch_load,
                                                      self.cloud_load,
                                                      self.master_load,
                                                      self.branch_load)
            # For each QC testcase, search the local tags
            for tc_item in self.testcase_name:
                self._get_local_tags(robot_filename, tc_item)
                self.global_cit = self.local_cit + self.forced_tags_cit
                self.global_crt = self.local_crt + self.forced_tags_crt
                self.global_cdrt = self.local_cdrt + self.forced_tags_cdrt
                new_line_part2 = "{};{};{};{};{};".format(tc_item,
                                                          self.local_topology,
                                                          self.global_cit,
                                                          self.global_crt,
                                                          self.global_cdrt)
                # Now, as all new line parts are setup, we write the new line in the CSV file
                fCsv.write(new_line_part1 + new_line_part2 + new_line_part3 + new_line_part4 + "\n")
                self.local_cit = ""
                self.local_crt = ""
                self.local_cdrt = ""
            # reset stored data
            ConfigClass._reset_data(self)

        # Save and close the CSV file
        fCsv.close()

        # Format the CSV file into XLSX format
        xlsfilename = self._create_xlsx_file(result_file)

        # Get a local copy of all Robot and QC files then zip
        temp_dir = self._create_result_directory()
        self._get_robot_files("temp_robotFilesList.txt", temp_dir)
        self._get_qc_files("temp_robotFilesList.txt", temp_dir)
        zipfilename = self._zip_result_directory(result_file, temp_dir)

        # Some cleanup
        self._some_cleanup(temp_dir)

        print("===========================================================================")
        print(" ==> The generated XLSX file is: {}".format(xlsfilename))
        print(" ==> The generated ZIP  file is: {}".format(zipfilename))
        print("===========================================================================")

    def _create_robot_files_list(self, robotFile, listPath, keyPattern):
        """
        Create a temporary file which will contain all Robot files havinf the key pattern
        """
        fOut = open(robotFile, "w")
        for start_path in listPath:
            print("ROBOT files processing:")
            list_file = self._find_specific_files(start_path, ".robot")
            print("  Now search all Robot files containing the mandatory pattern {}:".format(keyPattern))
            nb_files = 0
            for idx, filename in enumerate(list_file):
                if len(filename) > 0:
                    found_pattern = self._is_pattern_in_file(filename, keyPattern)
                    if found_pattern:
                        fOut.write(filename + "\n")
                        nb_files += 1
                    # time.sleep(0.1)
            print("      {} files found containing the mandatory pattern {}".format(nb_files, keyPattern))
        fOut.close()

    def _analyze_the_robot_file(self, robot_filename):
        """
        Analyze each line of the robot file in order to find and set requested items
        """
        fIn = open(robot_filename, "r")
        lines = fIn.readlines()
        for line in lines:
            # Search of Topology tag:
            found_topology = self._search_global_tag(Config.pattern_topology1, line)
            if len(found_topology) > 0:
                self.global_topology = found_topology.replace("\n", "").replace(" ", "")
            found_topology = self._search_global_tag(Config.pattern_topology2, line)
            if len(found_topology) > 0:
                self.global_topology = found_topology.replace("\n", "").replace(" ", "")

            # Search of the Load tag:
            found_trunkload = self._search_global_tag(Config.pattern_trunkload, line)
            if len(found_trunkload) > 0:
                self.trunk_load = found_trunkload.replace("\n", "").replace(" ", "")
            found_masterload = self._search_global_tag(Config.pattern_masterload, line)
            if len(found_masterload) > 0:
                self.master_load = found_masterload.replace("\n", "").replace(" ", "")
            found_branchload = self._search_global_tag(Config.pattern_branchload, line)
            if len(found_branchload) > 0:
                self.branch_load = found_branchload.replace("\n", "").replace(" ", "")
            found_sbtsload = self._search_global_tag(Config.pattern_sbtsload, line)
            if len(found_sbtsload) > 0:
                self.sbtsbranch_load = found_sbtsload.replace("\n", "").replace(" ", "")
            found_cloudload = self._search_global_tag(Config.pattern_cloudload, line)
            if len(found_cloudload) > 0:
                self.cloud_load = found_cloudload.replace("\n", "").replace(" ", "")

            # Search of Scope of test tag:
            found_testscope1 = self._search_global_tag(Config.pattern_testscope1, line)
            found_testscope2 = self._search_global_tag(Config.pattern_testscope2, line)
            if len(found_testscope1) > 0 or len(found_testscope2) > 0:
                tmp1 = found_testscope1.replace("\n", "").replace(" ", "")
                tmp2 = found_testscope2.replace("\n", "").replace(" ", "")
                self.global_old_scope = tmp1 + "  " + tmp2
            found_testscope3 = self._search_global_tag(Config.pattern_testscope3, line)
            found_testscope4 = self._search_global_tag(Config.pattern_testscope4, line)
            if len(found_testscope3) > 0 or len(found_testscope4) > 0:
                tmp3 = found_testscope3.replace("\n", "").replace(" ", "")
                tmp4 = found_testscope4.replace("\n", "").replace(" ", "")
                self.global_scope = tmp3 + "  " + tmp4

            # Search of the CIT/CRT/CDRT tags :
            found_test_cit = self._search_global_tag(Config.pattern_test_cit, line)
            if len(found_test_cit) > 0:
                self.forced_tags_cit = found_test_cit.replace("\n", "").replace("  ", " ")
            found_test_crt = self._search_global_tag(Config.pattern_test_crt, line)
            if len(found_test_crt) > 0:
                self.forced_tags_crt = found_test_crt.replace("\n", "").replace("  ", " ")
            found_test_cdrt = self._search_global_tag(Config.pattern_test_cdrt, line)
            if len(found_test_cdrt) > 0:
                self.forced_tags_cdrt = found_test_cdrt.replace("\n", "").replace("  ", " ")

            # Search of the TestCase QC Name:
            found_testcase = re.search(r"{}".format(Config.pattern_testname), line)
            if found_testcase:
                self.testcase_name.append(line.replace("\n", ""))
        # Close the robot file
        fIn.close()

    def _get_robot_files(self, source_file, result_dir):
        """
        Create a local copy of all processed Robot files
        """
        # Get all processed robot files
        fIn = open(source_file, "r")
        files_list = fIn.readlines()
        fIn.close()
        for original_file in files_list:
            original_file = original_file.replace("\n", "")
            pathname, filename = os.path.split(original_file)
            # Copy the file in Result directory
            cmd = 'cp {} {}/{}'.format(original_file, result_dir, filename)
            self._exec_w_ret(cmd)

    def _get_qc_files(self, source_file, result_dir):
        """
        Create a local copy of QC files
        """
        print("  Now search All QC Files associated to the selected Robot files")
        # Step1: The temp_qcPathname.txt will contain the list of "key_pattern" directories:
        fIn = open(source_file, "r")
        files_list = fIn.readlines()
        fIn.close()
        fOut = codecs.open("temp_qcPathname.txt", "w")
        for robot_filename in files_list:
            robot_pathname, robot_name = os.path.split(robot_filename)
            robot_pathname = robot_pathname.replace("\\", "/")
            fOut.write(robot_pathname + "/\n")
        fOut.close()
        self._keepOnlyOneItem("temp_qcPathname.txt")

        # Step2: The temp_qcFilesList.txt will contain the list of QC files to be updated:
        fIn = codecs.open("temp_qcPathname.txt", "r")
        path_list = fIn.readlines()
        fIn.close()
        fOut = codecs.open("temp_qcFilesList.txt", 'w')
        nb_files = 0
        for qc_path in path_list:
            qc_path = qc_path.replace("\n", "")
            found_file_list = self._find_specific_files(qc_path, ".qc")
            for idx, filename in enumerate(found_file_list):
                if len(filename) > 0:
                    fOut.write(filename + "\n")
                    nb_files += 1
        print("    {} qc files found".format(nb_files))
        fOut.close()

        # Step3: Duplicate original QC files into the Result directory:
        fIn = codecs.open("temp_qcFilesList.txt", "r")
        files_list = fIn.readlines()
        fIn.close()
        for qc_file in files_list:
            qc_file = qc_file.replace("\n", "")
            qc_pathname, qc_filename = os.path.split(qc_file)
            cmd = 'cp {} {}/{}'.format(qc_file, result_dir, qc_filename)
            self._exec_w_ret(cmd)

    def _find_specific_files(self, path, pattern):
        """
        path : repository where to search all specified files
        pattern : file type to be searched
        """
        wantedFiles = [os.path.join(root, name)
                       for root, dirs, files in os.walk(path)
                       for name in files
                       if name.endswith(pattern)]
        return wantedFiles

    def _keepOnlyOneItem(self, filename):
        """
        Open the file, remove all duplicated lines and return the purged file
        """
        with codecs.open(filename, 'r') as file:
            lines = set(file.readlines())
        with codecs.open(filename, 'w') as file:
            file.writelines(lines)

    def _create_result_directory(self):
        """
        Create the Results directory and return its name
        """
        result_dir = "Results"
        cmd = 'mkdir -p {}'.format(result_dir)
        self._exec_w_ret(cmd)
        return result_dir

    def _zip_result_directory(self, result_file, result_dir):
        """
        Zip the Results directory
        """
        zip_name = str(result_file).replace("csv", "zip")
        cmd = 'zip -r {} {}'.format(zip_name, result_dir)
        self._exec_w_ret(cmd)
        return zip_name

    def _some_cleanup(self, result_dir):
        """
        Remove temporary files and directories
        """
        cmd = 'rm temp_robotFilesList.txt'
        self._exec_w_ret(cmd)
        cmd = 'rm temp_qcFilesList.txt'
        self._exec_w_ret(cmd)
        cmd = 'rm temp_qcPathname.txt'
        self._exec_w_ret(cmd)
        cmd = 'rm -r {}'.format(result_dir)
        self._exec_w_ret(cmd)

    def _create_filename(self, result_file):
        """
        Get the date and time to create the CSV result filename
        """
        return result_file + "_" + self._get_date_timestamp() + ".csv"

    def _format_filename(self, filename):
        """
        Remove robotws info in the pathname
        """
        new_filename = filename.replace("^()/robotws/", "")
        return new_filename

    def _get_date_timestamp(self):
        """
        return a formatted string with date and time
        """
        return datetime.now().strftime("%Y%m%d_%H%M%S")

    def _is_pattern_in_file(self, filename, this_string):
        """
        Returns 1 if the key_pattern is present in the file
        """
        filename = filename.replace("\\", "/")
        with open(filename, encoding='utf-8', mode='r') as f:
            if this_string in f.read():
                return 1

    def _link_to_reporting_portal(self, testname, shortname):
        """
        Create the link to the Reporting Portal
        """
        item1 = '"=HYPERLINK(""'
        item2 = 'https://cloud.ute.nsn-rdnet.net/execution/search/?test_path='
        item3 = testname
        # item4 = '"";""RP Link"")"'
        item4 = '"";""' + shortname + '"")"'
        RP_link = item1 + item2 + item3 + item4
        return RP_link

    def _search_global_tag(self, global_tag, line):
        """
        A global tags is present between the "*** settings ***" and the "*** test cases ***" patterns
        Then, while we have not found the "settings" line, we skip the line
        When "settings" pattern is found,
            - while we have not found the "Force Tags" line, we skip the line
        When "settings" pattern is found,
            - we analyze the line while "test cases" pattern is not found
            - we search either "Force Tags   global_tag" or "...   global_tag"
        When "test cases" pattern is found, we skip the line
        """
        lineStrip = line.strip()
        if "*** Settings ***" in lineStrip:
            self.settings_found = True
            self.test_cases_found = False
            self.force_tags_found = False
        if "*** Test Cases ***" in lineStrip:
            self.test_cases_found = True
            self.settings_found = False
            self.force_tags_found = False
        if "Force Tags" in lineStrip:
            self.force_tags_found = True
        if self.settings_found is True and self.force_tags_found is True and self.test_cases_found is False:
            # Line analysis to search Force Tags can start:
            if "Force Tags" in lineStrip or "..." in lineStrip:
                # Search strings like : spaces words global_tag
                found_global_tag_case = re.search(r"\s+(\w+{})".format(global_tag), line)
                if found_global_tag_case:
                    return found_global_tag_case.group(1)
                # Search strings like : spaces global_tag words spaces
                found_global_tag_case = re.search(r"(\s+{}\w+\s+)".format(global_tag), line)
                if found_global_tag_case:
                    return found_global_tag_case.group(1)
                # Search strings like : spaces global_tag
                found_global_tag_case = re.search(r"(\s+{})".format(global_tag), line)
                if found_global_tag_case:
                    return found_global_tag_case.group(1)
                # Search strings like : spaces global_tag eol
                found_global_tag_case = re.search(r"(\s+{}\n)".format(global_tag), line)
                if found_global_tag_case:
                    return found_global_tag_case.group(1)
        return ""

    def _get_local_tags(self, filename, testcasename):
        """
        Get all local [Tags] definition and parse them
        """
        # Get all patterns defined in [Tags] of the selected testcase
        tags_patterns = self._get_tags(filename, testcasename)
        # Search CIT pattern:
        local_cit = re.search(r"({})".format(Config.pattern_test_cit), tags_patterns)
        if local_cit:
            self.local_cit = local_cit.group(1).replace("\n", "").replace("  ", " ")
        # Search CRT pattern:
        local_crt = re.search(r"({})".format(Config.pattern_test_crt), tags_patterns)
        if local_crt:
            self.local_crt = local_crt.group(1).replace("\n", "").replace("  ", " ")
        # Search CDRT pattern:
        local_cdrt = re.search(r"({})".format(Config.pattern_test_cdrt), tags_patterns)
        if local_cdrt:
            self.local_cdrt = local_cdrt.group(1).replace("\n", "").replace("  ", " ")
        # Search topology pattern.
        # By default, local topology is set to the one previously discovered in [Force Tags]
        self.local_topology = self.global_topology
        # If a local topology is defined at testcase level, we need to update it:
        # print("tags: {}".format(tags_patterns))
        local_topology = re.search(r"({}\w+)".format(Config.pattern_topology1), tags_patterns)
        if local_topology:
            self.local_topology = local_topology.group(1).replace("\n", "").replace(" ", "")
        local_topology = re.search(r"({}\w+)".format(Config.pattern_topology2), tags_patterns)
        if local_topology:
            self.local_topology = local_topology.group(1).replace("\n", "").replace(" ", "")

    def _get_tags(self, file, testName):
        """
        Search first a line beginning with the testcase name
        If found, search a line beginning with [Tags]
            If a line  beginning with [Tags] is found:
                Store the line into the tagStr variable
                While the next line contains "...", add the contain to tagStr variable
        Return the tagStr variable after some cleaning
        """
        pattern = testName.replace('[', r'\[').replace(r']', r'\]')
        f = open(file, "r")
        inTest = inTag = False
        tagStr = ""
        for line in f.readlines():
            lineNoSpace = line.strip()
            if re.search(r"^{}".format(pattern), lineNoSpace):
                inTest = True
                continue
            if inTest:
                upper = lineNoSpace.upper()
                if re.search(r"^\[TAGS\]", upper):
                    tagStr = upper
                    inTag = True
                elif upper.startswith("..."):
                    if inTag:
                        tagStr = tagStr + upper
                else:
                    inTag = False
                if line[0] != " " and line[0] != "\t" and line[0] != "\n":
                    inTest = False
        f.close()
        # print("tagStr: {}".format(tagStr.replace("[TAGS]", "").replace("...", "").strip()))
        return tagStr.replace("[TAGS]", "").replace("...", "")

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
        assert ret_code == 0,\
            "Error on command: {} : ERR CODE={} SDTERR={}".format(cmd, ret_code, stderr)
        return stdout.decode('utf-8')

    def _create_xlsx_file(self, filename):
        """
        read the CSV file using ";" as separator and translate it into XLSX format
        create a new sheet1 with the desired info : CIT and link to Reporting Portal
        create a new sheet2 with the desired info : SBTS22R1 Testcase and link to Reporting Portal
        """
        newfilename = filename.replace(".csv", ".xlsx")
        # Read the CSV file using the ';' character as separator :
        dataframe = pd.read_csv(filename,
                                header=0,
                                delimiter=';')
        # Sort dataframe alphabetically:
        df_ordered = dataframe.sort_values("CIT")
        # Read the ordered dataframe and remove all duplicated lines based in "Robot filename" column :
        df_wo_duplicate = df_ordered.drop_duplicates(subset=["Robot pathname"]).sort_values("Robot pathname")
        # Filter the df_wo_duplicate by removing rows having "_22R1" in Robot pathname:
        df_trunk_pattern = df_wo_duplicate[~df_wo_duplicate['Robot pathname'].str.contains('_22R1')]
        # Filter the df_wo_duplicate by keeping rows having "_22R1" in Robot pathname:
        df_22R1_pattern = df_wo_duplicate[df_wo_duplicate['Robot pathname'].str.contains('_22R1')]
        # Create the XLS file:
        with pd.ExcelWriter(newfilename) as writer:
            # The first sheet will contain all CSV data and is renamed 'Robot'
            df_ordered = dataframe.sort_values("Robot pathname")
            df_ordered.to_excel(writer,
                                index=False,
                                freeze_panes=(1, 0),
                                sheet_name="Robot")
            # The second sheet will contain only the selected columns and is renamed 'Link to RP'
            df_wo_duplicate.to_excel(writer,
                                     index=False,
                                     freeze_panes=(1, 0),
                                     columns=["Robot pathname", "CIT"],
                                     sheet_name="RP Links")
            # The third sheet will contain only the selected columns and is renamed 'Link to RP'
            df_trunk_pattern.to_excel(writer,
                                      index=False,
                                      freeze_panes=(1, 0),
                                      columns=["Robot pathname", "CIT", "Trunk Load", "Branch Load", "Cloud Load"],
                                      sheet_name="RP Links - Trunk")
            # The forth sheet will contain only the selected columns and is renamed 'SBTS22R1'
            df_22R1_pattern.to_excel(writer,
                                     index=False,
                                     freeze_panes=(1, 0),
                                     columns=["Robot pathname", "CIT", "Trunk Load", "Branch Load", "Cloud Load"],
                                     sheet_name="RP Links - 22R1")
        # Create links to reporting portal in each worksheet:
        self._add_rp_link(newfilename, "RP Links")
        self._add_rp_link(newfilename, "RP Links - Trunk")
        self._add_rp_link(newfilename, "RP Links - 22R1")
        return newfilename

    def _add_rp_link(self, xlsfilename, sheetname):
        """
        read the first column of sheet2 and create link to Reporting Portal
        """
        rplink_part1 = 'https://cloud.ute.nsn-rdnet.net/execution/search/?test_path='
        # open the xlsx file and select the "Link to RP" sheet as working sheet
        wb = load_workbook(xlsfilename)
        ws = wb[sheetname]
        # Add a new column header for direct link to reporting portal
        ws.cell(row=1, column=ws.max_column+1).value = "Direct Link to Reporting Portal"
        # create the direct link based on first column contain
        for id, row in enumerate(ws.iter_rows(min_row=2, max_row=ws.max_row)):
            row_number = id + 2    # index for enumerate will start at 0
            rplink_part2 = row[0].value
            RP_link = rplink_part1 + str(rplink_part2)
            current_cell = ws.cell(row=row_number, column=ws.max_column)
            current_cell.hyperlink = RP_link
            current_cell.value = "RP link " + str(row_number - 1)
            current_cell.style = "Hyperlink"
        wb.save(xlsfilename)


# ==========================================================================================
# main - To launch the tool
# ==========================================================================================
"""
"""
if __name__ == '__main__':
    list_path = [Config.list_path]
    key_pattern = Config.key_pattern
    result_filename = Config.result_filename
    # Only the directory to be analyzed can be the input parameter.
    # If no param set, default values are read in the RobotFilesParser.ini file
    if len(sys.argv) > 1:
        list_path = [sys.argv[1]]
    print("You defined these Parameters: "
          "\n\tMandatory Pattern\t= {} "
          "\n\tRepository to parse\t= {}"
          "\n\tResult Filename\t\t= {}".
          format(key_pattern, list_path, result_filename))
    robot_parser = robot_parser()
    robot_parser.files_processing(list_path=list_path,
                                  key_pattern=key_pattern,
                                  result_filename=result_filename)
