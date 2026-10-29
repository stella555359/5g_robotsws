import configparser


class ConfigClass():
    def __init__(self):
        self.conf_obj = configparser.ConfigParser()
        self.conf_obj.read("./RobotFilesParser.ini")

        # Define global variables
        self.robot_pathname = ""
        self.testcase_name = []
        self.trunk_load = ""
        self.sbts_N0_load = ""
        self.sbts_N1_load = ""
        self.sbts_N2_load = ""
        self.local_trunk_load = ""
        self.local_sbts_N0 = ""
        self.local_sbts_N1 = ""
        self.local_sbts_N2 = ""
        self.local_cloud_load = ""
        self.global_trunk_load = ""
        self.global_sbts_N0 = ""
        self.global_sbts_N1 = ""
        self.global_sbts_N2 = ""
        self.cloud_load = ""
        self.master_load = ""
        self.new_global_scope = ""
        self.old_global_scope = ""
        self.forced_tags_cit = ""
        self.forced_tags_crt = ""
        self.forced_tags_cdrt = ""
        self.global_topology = ""
        self.local_topology = ""
        self.local_cit = ""
        self.local_crt = ""
        self.local_cdrt = ""
        self.global_cit = ""
        self.global_crt = ""
        self.global_cdrt = ""
        self.settings_found = False
        self.force_tags_found = False
        self.test_cases_found = False
        self.global_python = ""
        self.global_py27 = ""
        self.global_py3x = ""

        # Get Mandatory Parameters
        self.list_path = self.conf_obj.get("INPUT_PARAMETERS", "list_path")
        self.key_pattern = self.conf_obj.get("INPUT_PARAMETERS", "key_pattern")
        self.result_filename = self.conf_obj.get("INPUT_PARAMETERS", "result_filename")

        # Get all patterns to be searched in Robot files
        self.pattern_trunkload = self.conf_obj.get("PATTERN", "pattern_trunkload")
        self.pattern_sbts_N0 = self.conf_obj.get("PATTERN", "pattern_sbts_N0")
        self.pattern_sbts_N1 = self.conf_obj.get("PATTERN", "pattern_sbts_N1")
        self.pattern_sbts_N2 = self.conf_obj.get("PATTERN", "pattern_sbts_N2")
        self.pattern_masterload = self.conf_obj.get("PATTERN", "pattern_masterload")
        self.pattern_cloudload = self.conf_obj.get("PATTERN", "pattern_cloudload")
        self.pattern_testname = self.conf_obj.get("PATTERN", "pattern_testname")
        self.pattern_topology1 = self.conf_obj.get("PATTERN", "pattern_topology1")
        self.pattern_topology2 = self.conf_obj.get("PATTERN", "pattern_topology2")
        self.pattern_test_cit = self.conf_obj.get("PATTERN", "pattern_test_cit")
        self.pattern_test_crt = self.conf_obj.get("PATTERN", "pattern_test_crt")
        self.pattern_test_cdrt = self.conf_obj.get("PATTERN", "pattern_test_cdrt")
        self.pattern_testscope1 = self.conf_obj.get("PATTERN", "pattern_testscope1")
        self.pattern_testscope2 = self.conf_obj.get("PATTERN", "pattern_testscope2")
        self.pattern_testscope3 = self.conf_obj.get("PATTERN", "pattern_testscope3")
        self.pattern_testscope4 = self.conf_obj.get("PATTERN", "pattern_testscope4")
        self.pattern_python27 = self.conf_obj.get("PATTERN", "pattern_python27")
        self.pattern_python3x = self.conf_obj.get("PATTERN", "pattern_python3x")

        # Get all Excel columns names
        self.robot_pathname = self.conf_obj.get("EXCEL_HEADER", "robot_pathname")
        self.robot_testname = self.conf_obj.get("EXCEL_HEADER", "robot_testname")
        self.utetl_topology = self.conf_obj.get("EXCEL_HEADER", "utetl_topology")
        self.cit_test = self.conf_obj.get("EXCEL_HEADER", "cit_test")
        self.crt_test = self.conf_obj.get("EXCEL_HEADER", "crt_test")
        self.cdrt_test = self.conf_obj.get("EXCEL_HEADER", "cdrt_test")
        self.new_global_scope = self.conf_obj.get("EXCEL_HEADER", "new_global_scope")
        self.old_global_scope = self.conf_obj.get("EXCEL_HEADER", "old_global_scope")
        self.mandatory_pattern = self.conf_obj.get("EXCEL_HEADER", "mandatory_pattern")
        self.trunk_name = self.conf_obj.get("EXCEL_HEADER", "trunk_name")
        self.br_N0_name = self.conf_obj.get("EXCEL_HEADER", "br_N0_name")
        self.br_N1_name = self.conf_obj.get("EXCEL_HEADER", "br_N1_name")
        self.br_N2_name = self.conf_obj.get("EXCEL_HEADER", "br_N2_name")
        self.l_trunk_name = self.conf_obj.get("EXCEL_HEADER", "l_trunk_name")
        self.l_br_N0_name = self.conf_obj.get("EXCEL_HEADER", "l_br_N0_name")
        self.l_br_N1_name = self.conf_obj.get("EXCEL_HEADER", "l_br_N1_name")
        self.l_br_N2_name = self.conf_obj.get("EXCEL_HEADER", "l_br_N2_name")
        self.g_trunk_name = self.conf_obj.get("EXCEL_HEADER", "g_trunk_name")
        self.g_br_N0_name = self.conf_obj.get("EXCEL_HEADER", "g_br_N0_name")
        self.g_br_N1_name = self.conf_obj.get("EXCEL_HEADER", "g_br_N1_name")
        self.g_br_N2_name = self.conf_obj.get("EXCEL_HEADER", "g_br_N2_name")
        self.cloud_name = self.conf_obj.get("EXCEL_HEADER", "cloud_name")
        self.master_classical = self.conf_obj.get("EXCEL_HEADER", "master_classical")
        self.robot_filename = self.conf_obj.get("EXCEL_HEADER", "robot_filename")
        self.link_to_reporting = self.conf_obj.get("EXCEL_HEADER", "link_to_reporting")
        self.python_version = self.conf_obj.get("EXCEL_HEADER", "python_version")
        self.link_to_qc_site = self.conf_obj.get("EXCEL_HEADER", "link_to_qc_site")

        # CSV file Header Creation
        self.h1 = self.robot_pathname + ";" + self.robot_testname + ";" + self.utetl_topology + ";"
        self.h2 = self.cit_test + ";" + self.crt_test + ";" + self.cdrt_test + ";"
        self.h3 = self.new_global_scope + ";" + self.old_global_scope + ";"
        self.h4 = self.l_trunk_name + ";" + self.l_br_N0_name + ";" + self.l_br_N1_name + ";" + self.l_br_N2_name + ";"
        self.h5 = self.trunk_name + ";" + self.br_N0_name + ";" + self.br_N1_name + ";" + self.br_N2_name + ";"
        self.h6 = self.g_trunk_name + ";" + self.g_br_N0_name + ";" + self.g_br_N1_name + ";" + self.g_br_N2_name + ";"
        self.h7 = self.cloud_name + ";" + self.master_classical + ";" + self.mandatory_pattern + ";"
        self.h8 = self.python_version + ";" + " "
        self.file_header = self.h1 + self.h2 + self.h3 + self.h4 + self.h5 + self.h6 + self.h7 + self.h8

        # Get all Excel sheet names
        self.sheet1_name = self.conf_obj.get("EXCEL_FOOTER", "sheet_1")
        self.sheet2_name = self.conf_obj.get("EXCEL_FOOTER", "sheet_2")
        self.sheet3_name = self.conf_obj.get("EXCEL_FOOTER", "sheet_3")
        self.sheet4_name = self.conf_obj.get("EXCEL_FOOTER", "sheet_4")

    def _reset_data(self):
        self.testcase_name = []
        self.trunk_load = ""
        self.sbts_N0_load = ""
        self.sbts_N1_load = ""
        self.sbts_N2_load = ""
        self.local_trunk_load = ""
        self.local_sbts_N0 = ""
        self.local_sbts_N1 = ""
        self.local_sbts_N2 = ""
        self.local_cloud_load = ""
        self.global_trunk_load = ""
        self.global_sbts_N0 = ""
        self.global_sbts_N1 = ""
        self.global_sbts_N2 = ""
        self.cloud_load = ""
        self.master_load = ""
        self.new_global_scope = ""
        self.old_global_scope = ""
        self.forced_tags_cit = ""
        self.forced_tags_crt = ""
        self.forced_tags_cdrt = ""
        self.global_topology = ""
        self.local_topology = ""
        self.local_cit = ""
        self.local_crt = ""
        self.local_cdrt = ""
        self.global_cit = ""
        self.global_crt = ""
        self.global_cdrt = ""
        self.global_python = ""
        self.global_py27 = ""
        self.global_py3x = ""
