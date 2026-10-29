# -*- coding: utf-8 -*-
"""
:created on: 2020-01-11

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""
import logging
import paramiko
from SSHLibrary import SSHClient


class SshConnection(object):
    """SshConnecion class creates SSH Connection between Robot workspace Lab PC
       and a remote host

    :param String host: hostname or IP address
    :param String user: user name
    :param String password: user password
    :param Integer port: SSH Connection port
    :param String prompt: SSH Connection user prompt (default is "$ ")
    :param Integer timeout: SSH Connection timeout
    """

    def __init__(self, host, user, password, port=22, prompt="$ ", timeout=15, **kwargs):

        self._sshClt = SSHClient(host=host, prompt=prompt, timeout=timeout, port=port)
        self.__user = user
        self.__password = password
        self.__name = "%s@%s:%d %#x" % (user, host, int(port), id(self))
        self._log = logging.getLogger(__name__)

    def _setup(self):
        nTries = 3
        for i in range(1, nTries + 1):
            try:
                self._log.info("[%s] login #%d, password = <%s>" % (self.__name, i, self.__password))
                if 'look_for_keys' in self._sshClt.login.__code__.co_varnames:
                    ret = self._sshClt.login(self.__user, self.__password, look_for_keys=True)
                else:
                    ret = self._sshClt.login(self.__user, self.__password)
                self._log.info("login result:{}".format(ret))
                break
            except Exception as e:
                logging.info("login exception: {}".format(e))
                if i == nTries:
                    raise Exception("%d ")

    def _teardown(self):
        if self._sshClt:
            self._sshClt.close()
            self._sshClt = None
            self._log.info("[%s] connection closed" % self.__name)

    def execute(self, cmd):
        """ Execute command on SSH Connection.

        :param String cmd: command string
        """
        try:
            self._log.debug("executed command is: %s" % cmd)
            out, err, rc = self._sshClt.execute_command(cmd)
        except paramiko.SSHException:
            self._teardown()
        return out.strip(), err.strip(), rc

    def get_file(self, src, dst):
        """ Get file using SSH Connection.
        """
        self._log.info("Get File: source:{}, destination:{}".format(src, dst))
        return self._sshClt.get_file(src, dst)

    def put_file(self, src, dst):
        """ Put file using SSH Connection.
        """
        self._log.info("Put File: source:{}, destination:{}".format(src, dst))
        return self._sshClt.put_file(src, dst, "0777")

    def write(self, text):
        """ Write text on SSH Connection.
        """
        self._sshClt.write(text)

    def read_until_regex(self, regex, timeout=None):
        """ Read until regular expression matches the SSH Connection output.

        :param String regex: read until regular expression
        :param Integer timeout: read until timeout (default is None)
        """
        old_timeout = self._sshClt.config.timeout
        now_timeout = timeout if timeout is not None else old_timeout
        self._log.info("Read Until Regex: except string:{}, timeout:{}".format(regex, now_timeout))
        try:
            self._sshClt.config.update(timeout=now_timeout)
            out = self._sshClt.read_until_regexp(regex)
            self._log.info("Read Until Regex: output:{}".format(out))
            return out
        except Exception as e:
            raise Exception("Read Until Regex has exception:{}".format(e))
        finally:
            self._sshClt.config.update(timeout=old_timeout)

    def read(self):
        """ Read all output from SSH Connection.
        """
        out = self._sshClt.read()
        if out:
            self._log.info("Read: output:{}".format(out))
        return out

    def start_command(self, command):
        """Starts command execution on remote host and return immediately.

        This keyword doesn't return anything. Use `Read Command Output` to read
        the output generated from command execution.

        Note that the `Read Command Output` keyword always reads the output of
        the most recently started command.

        Example:
        | Start Command | some command |
        """
        self._log.info("Starting command:{}".format(command))
        self._command = command
        self._sshClt.start_command(command)

    def _output_options(self, stdout, stderr, rc):
        # Handle legacy options for configuring returned outputs
        if not isinstance(stdout, str):
            return stdout, stderr, rc
        stdout = stdout.lower()
        if stdout == 'stderr':
            return False, True, rc
        if stdout == 'both':
            return True, True, rc
        return stdout, stderr, rc

    def read_command_output(self, return_stdout=True, return_stderr=False,
                            return_rc=False):
        """Reads and returns/logs output (stdout and/or stderr) of a command.

        Command must have been started using `Start Command` before this
        keyword can be used.

        See `Execute Command` for examples about how the return value can
        be configured using `return_stdout`, `return_stderr` and `return_rc`.
        """
        self._log.info("Reading output of command '%s'" % self._command)
        opts = self._output_options(return_stdout, return_stderr, return_rc)
        stdout, stderr, rc = self._sshClt.read_command_output()
        return self._return_command_output(stdout, stderr, rc, *opts)
