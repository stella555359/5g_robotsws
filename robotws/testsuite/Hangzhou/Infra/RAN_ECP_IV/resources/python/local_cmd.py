import subprocess
from robot.api import logger
import re
import time
import os
import sys


class local_cmd(object):
    def execute_local_cmd(self, cmd, timeout=60):
        output = ''
        errout = ''
        try:
            logger.info('execute command {}'.format(cmd))
            proc = subprocess.Popen(
                cmd,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
            if not cmd.strip().endswith('&'):
                output, errout = proc.communicate()
            if proc.returncode != 0:
                result = False
                logger.warn(
                    "command {} execute failed {}".format(
                        cmd, output + errout))
                return_output = output + errout
                return result, return_output
            else:
                logger.info('get output: \n {}'.format(output))
                result = True
                return result, output

        except Exception as e:
            if 'reboot' not in cmd and '[ -' not in cmd:
                logger.warn(
                    "command {} execute failed {}".format(
                        cmd, repr(e)))
            result = False
            return result, repr(e)

    def is_pingable(self, host):
        cmd = 'ping -c 1 {}'.format(host)
        result, output = self.execute_local_cmd(cmd)
        return result

    def is_restarted(self, host):
        return not self.is_pingable(host)

    def is_ssh_enable(self, host, user, password):
        cmd = 'timeout 5s sshpass -p {2} ssh {1}@{0} pwd'.format(host, user, password)
        result, output = self.execute_local_cmd(cmd)
        return result

    def wait_until_restarted(self, host, timeout=30):
        result = _wait_until_succeed(int(timeout), self.is_restarted, host=host)
        if not result:
            raise AssertionError('wait device {} restarted error: {}'.format(host, timeout))

    def wait_until_pingable(self, host, timeout=30):
        result = _wait_until_succeed(int(timeout), self.is_pingable, host=host)
        if not result:
            raise AssertionError('wait device {} pingable error: {}'.format(host, timeout))

    def wait_until_ssh_enable(self, host, user, password, timeout=30):
        result = _wait_until_succeed(int(timeout), self.is_ssh_enable, host=host, user=user, password=password)
        if not result:
            raise AssertionError('wait device {} ssh eanble error: {} {} {}'.format(host, user, password, timeout))


def _wait_until_succeed(timeout, function, **args):
    interval = 5
    loop = int(timeout) / 5 + 1
    for i in range(int(loop)):
        succeed = function(**args)
        if succeed:
            return True
        time.sleep(interval)
    return False
