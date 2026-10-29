import os
import subprocess
from robot.libraries.BuiltIn import BuiltIn
import re
import datetime
import tarfile

from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
import logging
from pytest.GetFiles import download_package_using_git
import Airscales

BSOC_FILE = "TemporaryBsocForLabUsageOnly.tgz"
HOME_DIR = "/home/ute"
OUTPUT_FILE_TMP = '/tmp/output'
SCP_OPTIONS = '-oStrictHostKeyChecking="no" -P 22 -oUserKnownHostsFile="/dev/null" -oLogLevel="QUIET"'
SSHPASS_PREFIX = 'sshpass -p oZPS0POrRieRtu'


# =================================================================================================
# Internal services
# =================================================================================================
def currentPath():
    return os.path.dirname(os.path.abspath(__file__))


def console(str):
    logger.console(str)
    logging.info(str)


def check_bsh_file_path(bsh_file_path):
    if os.path.exists(bsh_file_path):
        BuiltIn().log(f"BSOC file {BSOC_FILE} found in {HOME_DIR}. No need to install the patch")
        return True
    else:
        BuiltIn().log(f"Downloading and Installing BSOC file {BSOC_FILE}.")
        return False


def extract_tar_with_strip(tar_path, extract_path, strip_components=2):
    """
    Extract a tar.gz file while stripping a specified number of leading components from the file paths.

    :param tar_path: Path to the tar.gz file.
    :param extract_path: Directory where the files will be extracted.
    :param strip_components: Number of leading path components to strip.
    """
    with tarfile.open(tar_path, "r:gz") as tar:
        for member in tar.getmembers():
            # Modify the member's path to strip leading components
            path_parts = member.name.split("/")
            if len(path_parts) > strip_components:
                member.name = "/".join(path_parts[strip_components:])
                tar.extract(member, path=extract_path)


class Setup(object):
    ROBOT_LISTENER_API_VERSION = 2
    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.test_status = {}
        self.automaticTeardown = False

    def print_and_log_output_file(self, path=OUTPUT_FILE_TMP):
        try:
            with open(path, "r") as f:
                content = f.read()
            print(content)
            BuiltIn().log(f"Content of {path}:\n{content}")
        except Exception as e:
            print(f"Failed to read {path}: {e}")
            BuiltIn().log(f"Failed to read {path}: {e}", "ERROR")

    def setTestTeardownFlag(self, flag):
        self.automaticTeardown = flag
        BuiltIn().run_keyword("Set Suite Variable", "${automaticTeardown}")

    def start_test(self, name, attributes):
        self.curTestName = name
        self.failDuToDepend = False
        # console("START:name={}".format(name))

    def depends(self, name):
        # console("DEPENDS:name={}".format(name))
        test_name_lower_case = name.lower()
        if test_name_lower_case not in self.test_status:
            BuiltIn().log(f'Test {self.curTestName} depends on TC {name} that was not ran', "WARN")
        elif self.test_status[test_name_lower_case] != "PASS":
            self.failDuToDepend = True
            BuiltIn().fail(f'Test {self.curTestName} depends on TC {name} that was FAILED')
        return True

    def getTcStatusByName(self, name):
        """
        :param name:
        :return: case status. Available status are: NA, PASS, FAIL
        """
        test_name_lower_case = name.lower()
        if test_name_lower_case not in self.test_status:
            BuiltIn().log(f'required TC not run during this testsuite execution: {name}', "WARN")
            return "NA"
        else:
            return self.test_status[test_name_lower_case]

    def end_test(self, name, args):
        status = args['status']
        # console("END:name={} Status={}".format(name,status))
        self.test_status[name.lower()] = status
        if not self.failDuToDepend and self.automaticTeardown in ['True', 'FirstFail']:
            if self.automaticTeardown == 'FirstFail' and status == 'FAIL':
                self.automaticTeardown = False
            BuiltIn().run_keyword("Test Teardown")

    # =================================================================================================================
    # Custom Config tools - ClassicalBTS Only
    # =================================================================================================================
    def root_to_custom_config_dir(self):
        cur_path = currentPath().split('robotws')[0]
        return f"{cur_path}robotws/custom-config"

    def get_pathname(self, pathname):
        path, filename = os.path.split(pathname)
        return path

    def check_custom_config_params(self, yamlPathname="", scfcPathname="", iphyPathname="",
                                   basicPathname="", rad_params="", vendor_params="",
                                   cuScfcPathname=""):
        """
        == Purpose ==
        Library to check consistency between all custom config parameters
        and return the type of the custom config:
        - custom config done through YAML file
        - custom config done through individual files
        - no custom config , i.e. standard case
        """
        # case Yaml file:
        if yamlPathname != "":
            return "YAML_CUSTOM_CONFIG"
        if scfcPathname == "" and vendor_params != "":
            return "ERROR"
        if cuScfcPathname != "" and vendor_params != "":
            return "ERROR"
        if cuScfcPathname != "" and rad_params != "":
            return "ERROR"
        if scfcPathname != "" \
                or cuScfcPathname != "" \
                or iphyPathname != "" \
                or basicPathname != "" \
                or rad_params != "" \
                or vendor_params != "":
            return "UNITARY_CUSTOM_CONFIG"
        return "STANDARD"

    def save_custom_config_files(self, scfc="", cuScfc="", iphy="", basic="", target="", root=""):
        BuiltIn().log(f"scfc={scfc}")
        BuiltIn().log(f"cuScfc={cuScfc}")
        BuiltIn().log(f"iphy={iphy}")
        BuiltIn().log(f"basic={basic}")
        BuiltIn().log(f"target={target}")
        BuiltIn().log(f"root={root}")
        current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        # create the target directory:
        destPathname = f'{target}_{current_time}'
        if root != "":
            root = root + "/"

        os.system(f"mkdir {destPathname}")
        if scfc != "":
            srcPath = root + scfc
            destPath = destPathname + "/scfc_du.xml"
            os.system(f"cp -pu {srcPath} {destPath}")
        if cuScfc != "":
            srcPath = root + cuScfc
            destPath = destPathname + "/scfc_cu.xml"
            os.system(f"cp -pu {srcPath} {destPath}")
        if iphy != "":
            srcPath = root + iphy
            destPath = destPathname + "/iphy.xml"
            os.system(f"cp -pu {srcPath} {destPath}")
        if basic != "":
            srcPath = root + basic
            destPath = destPathname + "/basic_setup.cfg"
            os.system(f"cp -pu {srcPath} {destPath}")

    def save_original_files_OLD(self, target=None):
        oriPathname = f"{HOME_DIR}/testline_init_results/configs"
        destPathname = target + "/."
        os.system(f"mkdir {target}")
        srcPath = oriPathname + "/scfc.xml"
        os.system(f"cp -pu {srcPath} {destPathname}")
        srcPath = oriPathname + "/iphy.xml"
        os.system(f"cp -pu {srcPath} {destPathname}")
        srcPath = oriPathname + "/basic_setup.cfg"
        os.system(f"cp -pu {srcPath} {destPathname}")
        srcPath = oriPathname + "/sm_swconfig.txt"
        os.system(f"cp -pu {srcPath} {destPathname}")

    def save_original_files(self, target=None):
        current_time = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        # create the target directory:
        destPathname = f'{target}_{current_time}'
        self.execute_command(f"mkdir {destPathname}")
        # extract variant from agent.log file:
        cmd_var = r"sed -nr 's/^\s+VARIANT:\s+([A-Za-z0-9_+]+).*/\1/p' "+f"{HOME_DIR}/testline_init_results/agent.log"
        variant = self.execute_command(cmd_var).replace("\n", "")
        BuiltIn().log(f"detected variant=>>>{variant}<<<")
        # command to list
        cmd_ls = r"ls -L /home/ute/testline_init_results/execution/configs/topology_configs"
        # save all XML files delivered with variant:
        try:
            all_xml = self.execute_command(f"{cmd_ls}/{variant}/*.xml").split("\n")
            BuiltIn().log(f"all .xml files:{all_xml}")
            for item in all_xml:
                if item != "":
                    os.system(f"cp -pu {item} {destPathname}")
        except subprocess.CalledProcessError as e:
            # Handle the exception here
            BuiltIn().log(f"WARNING: there is no XML file delivered with variant {variant}")
        # save all CFG files delivered with variant:
        try:
            all_cfg = self.execute_command(f"{cmd_ls}/{variant}/*.cfg").split("\n")
            BuiltIn().log(f"all .cfg files:{all_cfg}")
            for item in all_cfg:
                if item != "":
                    os.system(f"cp -pu {item} {destPathname}")
        except subprocess.CalledProcessError as e:
            # Handle the exception here
            BuiltIn().log(f"WARNING: there is no CFG file delivered with variant {variant}")
        # save all TXT files delivered with variant:
        try:
            all_txt = self.execute_command(f"{cmd_ls}/{variant}/*.txt").split("\n")
            BuiltIn().log(f"all .txt files:{all_txt}")
            for item in all_txt:
                if item != "":
                    os.system(f"cp -pu {item} {destPathname}")
        except subprocess.CalledProcessError as e:
            # Handle the exception here
            BuiltIn().log(f"WARNING: there is no TXT file delivered with variant {variant}")

    def copy_custom_basic_file(self, file):
        import stat
        source1 = '/opt/wts/latest/basic_setup.cfg'
        target1 = '/opt/wts/latest/basic_setup.cfg.ori'
        source2 = file
        target2 = '/opt/wts/latest/basic_setup.cfg'

        def log_file_info(path, label):
            if os.path.exists(path):
                st = os.stat(path)
                BuiltIn().log(f"{label} exists. Permissions: {oct(st.st_mode)}, Owner: {st.st_uid}, Group: {st.st_gid}")
            else:
                BuiltIn().log(f"{label} does not exist.", "WARN")
        dest_dir = os.path.dirname(source1)
        BuiltIn().log("CHECKING Files information:")
        BuiltIn().log(f"Checking if DIR {dest_dir} exists: {os.path.exists(dest_dir)}")
        log_file_info(source1, "source1")
        log_file_info(target1, "target1 (ori)")
        log_file_info(source2, "source2 (custom)")
        log_file_info(target2, "target2")
        output_file_tmp = '/tmp/output'
        try:
            ret1 = self.execute_command(f'cp -puv {source1} {target1} 1>>{OUTPUT_FILE_TMP} 2>>{OUTPUT_FILE_TMP}')
        except subprocess.CalledProcessError as e:
            ret1 = self.execute_command(f'ls -l /opt 1>>/tmp/output 2>>/tmp/output')
            self.print_and_log_output_file()
            BuiltIn().log(f"cp -pu failed: {e}. Retrying with sudo.", "WARN")
            try:
                ret1 = self.execute_command(f'sudo cp -puv {source1} {target1}')
            except subprocess.CalledProcessError as e2:
                BuiltIn().log(f"sudo cp -puv also failed: {e2}", "ERROR")
                BuiltIn().log(f"stderr: {getattr(e2, 'output', b'').decode(errors='ignore')}")
                raise e2
        try:
            ret2 = self.execute_command(f'cp {source2} {target2}')
        except subprocess.CalledProcessError as e:
            BuiltIn().log(f"cp failed: {e}. Retrying with sudo.", "WARN")
            BuiltIn().log(f"stderr: {getattr(e, 'output', b'').decode(errors='ignore')}")
            try:
                ret2 = self.execute_command(f'sudo cp {source2} {target2}')
            except subprocess.CalledProcessError as e2:
                BuiltIn().log(f"sudo cp also failed: {e2}", "ERROR")
                BuiltIn().log(f"stderr: {getattr(e2, 'output', b'').decode(errors='ignore')}")
                raise e2

    def copy_custom_iphy_file(self, file):
        target1 = 'toor4nsn@192.168.200.1:/ffs/run/simmode/iphy.xml'
        target2 = 'toor4nsn@192.168.200.1:/ffs/run/simmode/new_iphy.xml'
        target3 = 'toor4nsn@192.168.200.1:/ffs/run/simmode/.'
        source = file
        ret1 = self.execute_command(f'{SSHPASS_PREFIX} scp {SCP_OPTIONS} {source} {target1}')
        ret2 = self.execute_command(f'{SSHPASS_PREFIX} scp {SCP_OPTIONS} {source} {target2}')
        ret3 = self.execute_command(f'{SSHPASS_PREFIX} scp {SCP_OPTIONS} {source} {target3}')

    def copy_custom_swcfg_file(self, file):
        target = 'toor4nsn@192.168.255.129:/ffs/run/swconfig.txt'
        source = file
        ret = self.execute_command(f'{SSHPASS_PREFIX} scp {SCP_OPTIONS} {source} {target}')

    def execute_command(self, command):
        pipes = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, stderr = pipes.communicate()
        if pipes.returncode != 0:
            exception = subprocess.CalledProcessError(pipes.returncode, command, output=output)
            error_msg = f'ERROR occurred\nstderr: {stderr.strip()}:\nRC: {pipes.returncode}'
            raise exception
        return output.decode('utf-8')

    def checkTopoFromAgentLogFile(self):
        user = os.environ['USER']
        path = f"/home/{user}/testline_init_results/agent.log"
        field = "LABEL:"
        match = re.match(r'^NAME:\s*(\S+)$', field)
        if match:
            field = match.group(1)
            BuiltIn().log(f"field: {field}")
        if os.path.isfile(path):
            with open(path, "r") as f:
                while True:
                    line = f.readline()
                    BuiltIn().log(f"line: {line}")
                    if not line:
                        BuiltIn().log("not line => break")
                        break
                    if field in line:
                        pos = line.index(field)+len(field)
                        topo = (line[pos:]).strip()
                        BuiltIn().log(f"Detected topology is: {topo}")
                        if "_5GC_" in topo:
                            return True
                        else:
                            return False
            f.close()
        return False

    def temporary_bsoc_reinstall(self):
        """
        This method is used to reinstall the BSOC package temporarily, if not already done.
        Returns True if the BSOC file was already present or successfully installed, False otherwise.
        """
        already_done = False  # Initialisation de la variable à False
        bsh_file_path = f"{HOME_DIR}/{BSOC_FILE}"
        if check_bsh_file_path(bsh_file_path):
            already_done = True
            return already_done
        download_package_using_git(
            'gitlabe1.ext.net.nokia.com/nps_vrf_8_and_9/bsr.git',
            'SWENG/Bsoc',
            BSOC_FILE,
            'NpsVrfToken',
            'glpat-4yNB_jaBXxz_BsyeAsgL',
            target_dir=HOME_DIR
        )
        if check_bsh_file_path(bsh_file_path):
            BuiltIn().log(f"BSOC file {BSOC_FILE} succesfully downloaded in {HOME_DIR}")
        else:
            BuiltIn().log(f"BSOC file {BSOC_FILE} download FAILED")
        extract_tar_with_strip(bsh_file_path, HOME_DIR, strip_components=2)
        cmd_var = "/home/ute/TemporaryBsocForLabUsageOnly/TemporaryBsocForLabUsageOnly_installationFromVM.sh"
        try:
            res_txt = self.execute_command(cmd_var).replace("\n", "")
            BuiltIn().log(f"BSOC file {BSOC_FILE} successfully installed\nOutput:\n\n{res_txt}")
            already_done = True
        except subprocess.CalledProcessError as e:
            BuiltIn().log("===================================================")
            BuiltIn().log("       ERROR: BSOC file installation FAILED        ")
            BuiltIn().log("===================================================")
        return already_done
