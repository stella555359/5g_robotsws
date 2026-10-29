from moler.cmd import RegexHelper
from moler.util.moler_test import MolerTest
from testsuite.Krakow.resources.linux_accounts.system_account_permissions\
    import load_moler_configuration_from_tl
from testsuite.Krakow.resources.linux_accounts.system_account_permissions import SystemAccountPermissions
import datetime
import re

logs = {
    "tc_1.1": [
        r".* info .* ext-sshd\[\d*\]: pam_unix\(ext-sshd:session\): session opened for user serviceuser\(uid=\d*\) ",
        r"by \(uid=0\)",
        r".* info .*executable.*/opt/nokia/SS_SCLI/bin/clifwkdaemon.*operation.*SCLICommandExecuted.*additionalText.*"
        r"serviceuser.*executed command: created a SCLI session on terminal /dev/pts/.*, exit code:0",
        r".* info.*executable.*/opt/nokia/SS_SCLI/bin/clifwkdaemon.*operation.*SCLICommandExecuted.*additionalText.*"
        r"user.*serviceuser.*executed command: SCLI session terminated by user, exit code:0.*",
        r".* info .* pam_unix\(ext-sshd:session\): session closed for user serviceuser"
    ],
    "tc_1.2": [
        r".* info .* ext-sshd.*: Connection from .* port .* on .* port 22 rdomain.*",
        r".* info .* ext-sshd.*: Accepted key .* found at /var/opt/nokia/lib/externalsshkeys/serviceuser/"
        r"authorized_keys:.*",
        r".* info .* ext-sshd.*: Accepted publickey for serviceuser from .* port .* ssh2: .*",
        r".* info .* ext-sshd.*: pam_unix\(ext-sshd:session\): session opened for user "
        r"serviceuser\(uid=\d*\) by \(uid=0\)",
        r".* warning .* ext-sshd.*: pam_limitLogin\(ext-sshd:session\): returning success"
    ],
    "tc_1.3": [
        r".* notice .* pam_unix\(.*\): authentication failure; logname=.* uid=.* euid=0 tty=.* ruser=.* rhost=.*  "
        "user=toor4nsn",
        r".* err .* error: PAM: Authentication failure for toor4nsn from .*"
    ],
    "tc_1.4": [
        r".* info .* ext-sshd.*: Connection from .* port .* on .* port 22 rdomain.*",
        r".* info .* ext-sshd.*: Failed publickey for serviceuser from .* port .* ssh2: .*",
        r".* info .* ext-sshd.*: Postponed keyboard-interactive for serviceuser from .* port .* ssh2 \[preauth\]",
        r".* info .* ext-sshd.*: Connection closed by authenticating user serviceuser .* port .* \[preauth\]",
        r".* notice .* audit.*: AUDIT.* pid=.* uid=.* auid=.* ses=.* msg='op=PAM:bad_ident grantors=.* acct=.* "
        r"exe=\"/usr/sbin/ext-sshd\" hostname=.* addr=.* terminal=ssh res=failed.*"
    ],
    "tc_1.5": [
        r".* err .* error: PAM: Authentication failure for serviceuser from .*",
        r".* info .* Failed keyboard-interactive\/pam for serviceuser from .* port .* ssh2"
    ],
    "tc_1.6": [r"Last login: .* from .* on SSH",
               r"Last failed login: .* from .* on SSH",
               r"There was 1 failed login attempt since the last successful login\.",
               ],
    "tc_1.7": [
        r".* info .*executable.*/opt/nokia/SS_SCLI/bin/clifwkdaemon.*operation.*SCLICommandExecuted"
        r".*additionalText.*serviceuser.*executed command: set user username.*toor4nsn.* exit code:0.*"
    ],
    "tc_2.1": [
        r".* info .* ext-sshd\[\d*\]: pam_unix\(ext-sshd:session\): session opened for user serviceuser.* "
        r"by \(uid=0\)",
        r".* warning .* ext-sshd\[\d*\]: pam_limitLogin\(ext-sshd:session\): returning success",
        r".* info .* ext-ssh.*: Reading last login info SUCCESS.*",
        r".* info .* clifwkdaemon\[\d*\]: .*\"\/opt\/nokia\/SS_SCLI\/bin\/clifwkdaemon\".*\"user:"
        r"<!\[CDATA\[<RCP-log>serviceuser<RCP-log>\]\]> executed command: exit, exit code:0.*",
        r".* info .* pam_unix\(ext-sshd:session\): session closed for user serviceuser"
    ],
    "tc_2.2": [
        r".* notice .* pam_unix\(.*\): authentication failure; logname=.* uid=.* euid=0 tty=.* ruser=.* rhost=.*  "
        "user=toor4nsn",
        r".* info .* ext-sshd\[\d*\]: pam_unix\(ext-sshd:session\): session opened for user serviceuser.* "
        r"by \(uid=0\)"
    ],
    "tc_2.3": [
        r",* info .*executable.*/opt/nokia/SS_SCLI/bin/clifwkdaemon.*operation.*SCLICommandExecuted.*additionalText"
        r".*user.*serviceuser.*executed command: set user username.*toor4nsn.*, exit code:0.*",
        r".* notice .* su.*: \(to toor4nsn\) serviceuser on.*",
        r".* info .* HISTORY: PID=.* UID=0 fdisk -l",
        r".* info .* -bash.*: HISTORY: PID=.* UID=0 exit",
        r".* info .* su.*: pam_unix\(su:session\): session closed for user toor4nsn"
    ],
    "tc_3.1": [
        r""
    ],
    "tc_selenium_webem_login": [
        r".* info .* janus.*executable.*/usr/libexec/api-gateway-framework/bin/janus.*operation.*Login.*username.*"
        r"Nemuadmin.*operationResult.*success.*source.*webem.*",
        r".* info .* janus.*executable.*/usr/libexec/api-gateway-framework/bin/janus.*operation.*Logout.*username.*Ne"
        r"muadmin.*operationResult.*success.*source.*webem.*"
    ],
    "tc_selenium_change_BTS_name": [
        r".* info .* asm.*executable.*/opt/nokia/SS_OAMCU/ASM/asm.*operation.*PLAN_ACTIVATE_IND.*username.*Nemuadmin.*"
        r"operationResult.*success.*source.*webem.*btsName.*CU.*"
    ]
}


class AuthLogs(SystemAccountPermissions):

    def __init__(self):
        SystemAccountPermissions.__init__(self)
        self._regex_helper = RegexHelper()
        self.moler_device = None
        self.time = None

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def get_actual_time(self, gmt_timezone=False, bts_id=0):
        """
        Get time

        :param bts_id: BTS ID
        :param gmt_timezone: get gmt time
        :return: None
        """
        self._prepare_moler_device(bts_id, "DU")
        cmd_params = None
        if gmt_timezone:
            cmd_params = {"options": "-u"}
        cmd_date = self.moler_device.get_cmd(cmd_name="date", cmd_params=cmd_params)
        ret = cmd_date()
        self.time = "{} {}".format(ret["DATE"]["FULL"], ret["TIME"]["FULL"])
        self.time = datetime.datetime.strptime(self.time, "%d-%m-%Y %H:%M:%S")
        MolerTest.steps_end()

    _re_parse_date = re.compile(r'(?P<DATE>\d{4}-\d{2}-\d{2})T(?P<TIME>\d{2}:\d{2}:\d{2})')

    @load_moler_configuration_from_tl()
    def _get_log_time(self, line):
        """
        Get time from auth.log

        :param line: line from log
        :return: None
        """
        time = None
        if self._regex_helper.search_compiled(AuthLogs._re_parse_date, line):
            time = "{} {}".format(self._regex_helper.group("DATE"), self._regex_helper.group("TIME"))
            time = datetime.datetime.strptime(time, "%Y-%m-%d %H:%M:%S")
        return time

    @load_moler_configuration_from_tl()
    def _get_auth_log(self, number_of_lines=2000):
        """
        Get auth.log

        :return: None
        """
        cmd_tail = self.moler_device.get_cmd(cmd_name="tail",
                                             cmd_params={"path": "/mnt/log/master/fsaudit/auth.log",
                                                         "options": "-n {}".format(number_of_lines)})
        ret = cmd_tail()
        return ret["LINES"]

    @load_moler_configuration_from_tl()
    def _compare_log_time(self, line):
        """
        check if log time is greater than start time

        :return: None
        """
        curr_time = self._get_log_time(line)
        if curr_time:
            return curr_time >= self.time
        else:
            return False

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_auth_log(self, tc_number, number_of_lines=2000, bts_id=0):
        """
        check /mnt/log/master/fsaudit/auth.log file.

        :param tc_number: test case number
        :param number_of_lines: number of log lines to read
        :param bts_id: bts id
        :return: None
        """
        self._prepare_moler_device(bts_id, "CU")
        self.moler_device.goto_state("FCT")
        expected = logs["tc_{}".format(tc_number)]
        checked = []
        lines = self._get_auth_log(number_of_lines)
        for line in lines:
            if self._compare_log_time(line):
                for el in expected:
                    if self._regex_helper.search_compiled(re.compile(el), line):
                        checked.append(el)
                        break
        ret = [item for item in expected if item not in checked]
        if ret:
            MolerTest.error("Missing items in auth.log", dump=ret)
        MolerTest.steps_end()
