import configparser


class ConfigClass():
    def __init__(self):
        self.conf_obj = configparser.ConfigParser()
        self.conf_obj.read("./RobotFilesParser.ini")

        # Define global variables
        self.testcase_name = []
        self.trunk_load = ""
        self.master_load = ""
        self.sbtsbranch_load = ""
        self.branch_load = ""
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

        # Get Mandatory Parameters
        self.list_path = self.conf_obj.get("INPUT_PARAMETERS", "list_path")
        self.key_pattern = self.conf_obj.get("INPUT_PARAMETERS", "key_pattern")
        self.result_filename = self.conf_obj.get("INPUT_PARAMETERS", "result_filename")

        # Get all columns names
        self.robot_pathname = self.conf_obj.get("EXCEL_HEADER", "robot_pathname")
        self.robot_testname = self.conf_obj.get("EXCEL_HEADER", "robot_testname")
        self.utetl_topology = self.conf_obj.get("EXCEL_HEADER", "utetl_topology")
        self.cit_test = self.conf_obj.get("EXCEL_HEADER", "cit_test")
        self.crt_test = self.conf_obj.get("EXCEL_HEADER", "crt_test")
        self.cdrt_test = self.conf_obj.get("EXCEL_HEADER", "cdrt_test")
        self.global_scope = self.conf_obj.get("EXCEL_HEADER", "global_scope")
        self.old_global_scope = self.conf_obj.get("EXCEL_HEADER", "old_global_scope")
        self.mandatory_pattern = self.conf_obj.get("EXCEL_HEADER", "mandatory_pattern")
        self.trunk_loadname = self.conf_obj.get("EXCEL_HEADER", "trunk_loadname")
        self.branch_loadname = self.conf_obj.get("EXCEL_HEADER", "branch_loadname")
        self.cloud_loadname = self.conf_obj.get("EXCEL_HEADER", "cloud_loadname")
        self.master_classical = self.conf_obj.get("EXCEL_HEADER", "master_classical")
        self.old_trunk_load = self.conf_obj.get("EXCEL_HEADER", "old_trunk_load")
        self.robot_filename = self.conf_obj.get("EXCEL_HEADER", "robot_filename")
        self.link_to_reporting = self.conf_obj.get("EXCEL_HEADER", "link_to_reporting")

        # Header Creation
        self.header1 = self.robot_pathname + ";" + self.robot_testname + ";" + self.utetl_topology + ";"
        self.header2 = self.cit_test + ";" + self.crt_test + ";" + self.cdrt_test + ";"
        self.header3 = self.global_scope + ";" + self.old_global_scope + ";" + self.mandatory_pattern + ";"
        self.header4 = self.trunk_loadname + ";" + self.branch_loadname + ";" + self.cloud_loadname + ";"
        self.header5 = self.master_classical + ";" + self.old_trunk_load + "; "
        self.file_header = self.header1 + self.header2 + self.header3 + self.header4 + self.header5

        # Get all patterns to search in Robot files
        self.pattern_trunkload = self.conf_obj.get("PATTERN", "pattern_trunkload")
        self.pattern_sbtsload = self.conf_obj.get("PATTERN", "pattern_sbtsload")
        self.pattern_branchload = self.conf_obj.get("PATTERN", "pattern_branchload")
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

    def _reset_data(self):
        self.testcase_name = []
        self.trunk_load = ""
        self.master_load = ""
        self.cloud_load = ""
        self.sbtsbranch_load = ""
        self.branch_load = ""
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
