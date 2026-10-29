import re
import glob
import os
from paramiko import AutoAddPolicy, SSHClient
from robot.api import logger

SYSLOG_CRASHES = [r'.*-=-=.*', r'.*Please contact the owner of.*']
ACCEPTED_SYSLOG_ERRORS = [r'.*AaSyslog buffer \d+ \(\w+\) reached LoadLevel2.*', r'.*dhcpd:.*',
                          r'.*AaSyslog buffer \d+ \(\w+\) reached LoadLevel3.*',
                          r'.*buffer LoadLevel3 : ERR and VIP logs will be accepted.*',
                          r'.*kernel: \[\s*\d+\.\d+\] EXT4-fs \(sda\d\): '
                          'warning: maximal mount count reached, running e2fsck is recommended.*',
                          r'.*extSrioPortStateControl:.*SFP absent',
                          r'rsyslogd: * try http://www.rsyslog.com/e/2027.*',
                          r'.*kauditd_printk_skb: \d+ callbacks suppressed.*',
                          r'.*Please check if cell is already deactivated in RF '
                          r'but cell is not deleted yet in UL PHY and MAC PS.*']


def get_reset_counter(source='blackbox'):
    """Gets value of reset counter via SSH using 'blackbox' or 'ddal' source.

    :param string source: 'blackbox' or 'ddal' (executes 'cat /ffs/run/config/lifedata/blackbox' or
                          'ddal -s ddal_devicetree_get_reset_loop_counter_1' respectively)
    :return: reset counter value
    :rtype: int
    """
    if source == 'blackbox':
        command = 'cat /ffs/run/config/lifedata/blackbox'
        reset_counter_regex = re.compile(r'RESET\sCOUNTER:\s(?P<counter_value>\d+)')
    elif source == 'ddal':
        command = 'ddal -s ddal_devicetree_get_reset_loop_counter_1'
        reset_counter_regex = re.compile(r'(?P<key>reset_loop_counter_1)=(?P<counter_value>\d+)')
    else:
        raise ValueError('Improper "source" value: {source}'.format(source=source))
    counter_value = _get_from_stdout(command, reset_counter_regex, 'counter_value')
    return int(counter_value)


def _get_from_stdout(command, regex=None, regex_group=None):
    """Executes command and returns value matched by regex from command stdout.

    :param string command:
    :param _sre.SRE_Pattern regex:
    :param (string|int) regex_group:
    :return: matched regex group or stdout
    :rtype: string
    """
    stdout = execute_command(command)
    result = regex.search(stdout).group(regex_group) if regex else stdout
    return result


def execute_command(command):
    client = SSHClient()
    client.set_missing_host_key_policy(AutoAddPolicy())
    client.connect(hostname='192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu')
    stdin, stdout, stderr = client.exec_command(command)
    output_list = stdout.readlines()
    response = ''.join(output_list)
    client.close()
    return response


def check_errors_in_syslog(logs_dir):
    """
    Check errors and crash in collected syslog.
    :param: string logs_dir: path to collected logs.
    """
    os.system("tar zxvf {}/syslog_files.tgz".format(logs_dir))
    syslog = glob.glob("*.LOG")
    errors = ['0']
    with open(syslog[0], "r", errors="ignore") as syslog_file:
        for line in syslog_file.readlines():
            for crash in SYSLOG_CRASHES:
                if re.match(crash, line):
                    crash_split = line.split('>')
                    if crash_split[1] not in errors[-1]:
                        errors.append(line)
        if len(errors) > 1:
            errors.append("OTHER ERRORS:")
            for line in syslog_file.readlines():
                if 'ERR/' in line:
                    for accepted_error in ACCEPTED_SYSLOG_ERRORS:
                        if re.match(accepted_error, line):
                            errors.remove(line)
                            break
                        else:
                            err_split = line.split('>')
                            if err_split[1] not in errors[-1]:
                                errors.append(line)
            filepath = os.path.join(logs_dir, 'SYSLOG_ERRORS.txt')
            syslog_errors = open(filepath, "w+")
            for error in errors:
                syslog_errors.write(error)
            syslog_errors.close()


def check_for_logs_in_binary_files(pattern, connection):
    logger.console(pattern)
    default = '/ffs/run/config/toor4nsn/sys.log'
    log = ssh.execute(command="cat {} | grep '{}' ".format(default, pattern), connection=connection)
    logger.console("Event:\n{}".format(log))
    if log is None:
        sleep(20)
        assist = ['/nvrd/tmp/aasyslog/runtime_LFS.bin',
                  '/nvrd/tmp/aasyslog/runtime_LFS_CC.bin',
                  '/nvrd/tmp/aasyslog/runtime_BTSOM.bin',
                  '/ffs/run/config/toor4nsn/sys.log']
        is_logged = False
        for path in assist:
            logger.console(path)
            log = ssh.execute(command="grep -rnlF '{}' /".format(log),
                              connection=connection)
            logger.console("Event:\n{}".format(log))
            if log is not None:
                is_logged = True
                break

        assert is_logged, "Event wasn't logged"
