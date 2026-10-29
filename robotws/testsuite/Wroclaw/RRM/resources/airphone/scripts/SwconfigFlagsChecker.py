import subprocess
import re
import paramiko
import taf.sbts.oam.coam.admin.interface as admin
import time
from robot.api import logger
from ute_admin_infomodel import ute_admin_infomodel
from ute_admin_infomodel.exception import InfoModelQueryTimeoutException
from contextlib import contextmanager

__version__ = '0.1'

SSH_USERNAME = 'toor4nsn'
SSH_PASSWORD = "oZPS0POrRieRtu"
BTS_IP_ADDRESS = "192.168.255.129"
MAX_RMOD_DETECTION_TIME = 600


class SwconfigFlagsChecker:
    """
       A class to check and install swconfig flags on a BTS.
       Attributes:
           ROBOT_LIBRARY_SCOPE (str): Scope of the Robot Framework library.
           admin_conn (admin): Admin connection object.
           flags (list): List of flags to be checked and installed.
           im (ute_admin_infomodel): InfoModel object.
           wait_for_rmods_needed (bool): Flag to check if rmod reset is needed.
           rmod_list (list): List of radio units.
       """
    ROBOT_LIBRARY_SCOPE = 'SUITE'

    def __init__(self):
        """Initializes the SwconfigFlagsChecker with flags and admin IP."""
        self.admin_conn = admin.admin()
        self.flags = []
        self.im = ute_admin_infomodel()
        self.wait_for_rmods_needed = True
        self.rmod_list = []

    def infomodel_context(self):
        return self.im.infomodel_context(address=BTS_IP_ADDRESS, port=443, timeout=200)

    def get_rmod_list(self):
        """Retrieves a list of RMOD names from the InfoModel."""
        with self.infomodel_context():
            get_rmods = self.im.query_infomodel(
                'get list /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/RMOD_L-*', timeout=MAX_RMOD_DETECTION_TIME)
        for dist_name in get_rmods:
            self.rmod_list.append(dist_name["dist_name"])

    @contextmanager
    def admin_context(self, ip, port, alias='default', timeout=30):
        try:
            logger.debug("Setup Admin with alias '%s'..." % alias)
            conn = self.admin_conn.setup_admin(bts_host=ip, bts_port=port, alias=alias, timeout=timeout)
            yield conn
        finally:
            logger.debug("Teardown Admin with alias '%s'..." % alias)
            self.admin_conn.teardown_admin(alias=alias)

    def reset_site(self):
        """Resets the site and waits until RMODs are available."""
        with self.admin_context(ip=BTS_IP_ADDRESS, port=443):
            self.admin_conn.reset_site()
        logger.info("Wait until RMODS are online...", also_console=True)
        self.check_if_rmods_available()

    def check_rmod_status(self, rmod):
        """Checks the operational state of a specific RMOD."""
        try:
            with self.infomodel_context():
                self.im.query_infomodel(f'check {rmod} is [stateInfo.operationalState=regex"Enabled|enabled"]',
                                        timeout=MAX_RMOD_DETECTION_TIME)
            logger.info(f'Radio module {rmod} detected and online', also_console=True)
            return True
        except InfoModelQueryTimeoutException:
            logger.debug(f'Radio module {rmod} still not online after {MAX_RMOD_DETECTION_TIME} secs, rebooting BTS...')
            self.reset_site()
            return False

    def _is_rmod_online(self, rmod, timeout):
        """
        Check if a single RMOD is online.
        Returns True if online, otherwise performs a secondary check and returns the result.
        """
        if self.check_rmod_status(rmod):
            return True
        logger.warn(f"RMOD {rmod} not online. Attempting secondary check...")
        check_rmod = self.im.query_infomodel(
                f'get object {rmod} is [stateInfo.operationalState=regex"Enabled|enabled"]',
                timeout=timeout)
        if check_rmod:
            logger.info(f"RMOD {rmod} is now online after secondary check.")
            return True
        return False

    def _check_all_rmods_online(self):
        """
        Check the status of all RMODs in the list.
        Returns True if all are online, otherwise False.
        """
        all_online = True
        for rmod in self.rmod_list:
            if self._is_rmod_online(rmod, MAX_RMOD_DETECTION_TIME):
                logger.info(f"RMOD {rmod} detected and online.")
            else:
                logger.warn(f"RMOD {rmod} still not online.")
                all_online = False
        return all_online

    @staticmethod
    def _has_timed_out(start_time, max_time):
        """
        Check if the total elapsed time has exceeded the maximum time allowed.
        """
        elapsed_time = time.time() - start_time
        if elapsed_time > max_time:
            logger.error(f"Timeout reached after {elapsed_time:.2f} seconds.")
            return True
        return False

    def check_if_rmods_available(self):
        """Main function to check if all RMODs are available and online."""
        start_time = time.time()
        logger.info(f"Starting detection of {len(self.rmod_list)} RMODs.", also_console=True)
        while True:
            if self._check_all_rmods_online():
                logger.info("All RMODs detected and online.", also_console=True)
                return True
            if self._has_timed_out(start_time, MAX_RMOD_DETECTION_TIME):
                logger.error("Timeout reached. Some RMODs are still offline.")
                return False
            time.sleep(1)  # Delay before re-checking

    @staticmethod
    def execute_command_on_bts(cmd):
        """Executes a command on the BTS via SSH."""
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh.connect(BTS_IP_ADDRESS, username=SSH_USERNAME, password=SSH_PASSWORD)
        ssh.exec_command(cmd)
        ssh.close()

    def install_swconfig_flag(self, flag):
        """Installs swconfig flags on the BTS."""
        cmd = "echo {} >> /ffs/run/swconfig.txt".format(flag)
        self.execute_command_on_bts(cmd)

    @staticmethod
    def get_swconfig():
        """Retrieves swconfig flags from the BTS."""
        swconfig_txt = subprocess.check_output(
            ['sshpass', '-p', SSH_PASSWORD, 'ssh', '-q', f'{SSH_USERNAME}@{BTS_IP_ADDRESS}',
             'cd ' '/ffs/run;', 'cat', 'swconfig.txt'])
        swconfig_without_spaces = "".join(swconfig_txt.decode().split())
        return swconfig_without_spaces

    def check_and_install_swconfig_flags_if_needed(self):
        """Checks if the specified flags are present in the swconfig and installs them if needed."""
        swconfig = self.get_swconfig()
        flags_to_install = []
        for flag in self.flags:
            if re.search(rf'(?<!#){flag}', swconfig):
                logger.info(f"{flag} flag is present in swconfig.txt.", also_console=True)
            else:
                logger.info(f"{flag} flag is not present in swconfig.txt. Adding it requires BTS reboot.",
                            also_console=True)
                flags_to_install.append(flag)
        for flag in flags_to_install:
            self.install_swconfig_flag(flag)
        return bool(flags_to_install)

    def modify_flags_in_swconfig(self, flags):
        """If the proper flags are not present in the swconfig.txt on the BTS,
           they will be added to the swconfig.txt and BTS will reset to set this flags up.
        """
        self.get_rmod_list()
        for flag in flags:
            self.flags.append(flag)
        logger.info("Checking proper flags configuration on the BTS...", also_console=True)
        update_needed = self.check_and_install_swconfig_flags_if_needed()
        if update_needed:
            logger.info("\nRebooting BTS to enable flags...", also_console=True)
            self.reset_site()
