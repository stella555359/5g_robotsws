import logging
import os
import subprocess
from ute_fsmaccess import ute_fsmaccess
from robot.libraries.BuiltIn import BuiltIn


class set_qc_id(object):

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.git_path = "https://gitlabe1.ext.net.nokia.com/hz_ran_l2_sw3_ta/hzl2_4g_golden_files.git"
        self.local_path = "/tmp/hzl2_casename/"
        self.qc_info_file_path = "{}lte_case_qc_info.md".format(self.local_path)

    def set_case_qc_id(self, case_name, sw_info=None):
        self._clone_qc_id_file_to_local()
        if sw_info is None:
            sw_info = self._get_enb_sw_version()
        all_case_qc_info = self._get_all_case_qc_info()
        self._log.info(case_name)
        if not self._is_case_name_in_case_qc_info_file(all_case_qc_info, case_name):
            self._log.info("This case not in case qc info file.")
            return
        qc_id = self._get_case_qc_id(all_case_qc_info, case_name, sw_info)
        BuiltIn().set_tags("QC_{}".format(qc_id))

    def _clone_qc_id_file_to_local(self):
        if os.path.isfile(self.qc_info_file_path):
            self._execute_command("rm {} -rf".format(self.local_path))
        self._execute_command('git clone --config http.proxy="" {} {}'.format(self.git_path, self.local_path))

    def _execute_command(self, cmd):
        self._log.debug(cmd)
        out2 = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        self._log.debug(out2.communicate())

    def _is_case_name_in_case_qc_info_file(self, all_case_qc_info, case_name):
        for case in all_case_qc_info:
            if case.split("|")[1].strip() == case_name:
                return True
        return False

    def _get_case_qc_id(self, all_case_qc_info, case_name, sw_info):
        branches = 'SBTS00' if sw_info.split("_")[2] == '9999' or '9990' else sw_info.split("_")[0]
        self._log.info("Branch is {}".format(branches))
        branches_index = self._get_branches_index(all_case_qc_info, branches)
        qc_id = self._get_qc_id_by_case_name(all_case_qc_info, case_name, branches_index)
        self._log.info("QC id is :{}".format(qc_id))
        if not qc_id.isdigit():
            raise Exception("QC id should be digit.Now it is {}".format(qc_id))
        return qc_id

    def _get_all_case_qc_info(self):
        if not os.path.exists(self.qc_info_file_path):
            raise Exception("QC ID file not exist!")
        with open(self.qc_info_file_path) as f:
            return f.readlines()

    def _get_branches_index(self, content, branches):
        head = content[0].split("|")
        for i in range(len(head)):
            if branches.upper() == head[i].strip().split("-")[0].strip():
                return i
        raise Exception("{} is not recorded in config file.".format(branches))

    def _get_qc_id_by_case_name(self, content, case_name, branches_index):
        for item in content:
            record = item.split("|")
            if record[1].strip() == case_name:
                self._log.info(item)
                self._log.info(record[1].strip())
                self._log.info("branches_index:{}, {}".format(branches_index, record[branches_index]))
                return record[branches_index].strip()
        return 'NULL'

    def _get_enb_sw_version(self):
        fsm = ute_fsmaccess()
        fsm.setup_enb_fsm_access(prompt=' >', fallback_prompt='#')
        sw_ver = fsm.get_enb_sw_version()
        fsm.teardown_enb_fsm_access()
        self._log.debug(sw_ver)
        return sw_ver
