"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""
from contextlib import contextmanager
import abc
import six
from robot.libraries.BuiltIn import BuiltIn
import paramiko
import time
import re


@six.add_metaclass(abc.ABCMeta)
class ShellHandler:
    """
    Shell Handler Class

    Creates shell handler
    """

    def __init__(self, host, user, password):
        """
        Init Shell Handler

        :param self
        :param host: hostname
        :param user: username
        :param password: password
        """
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.ssh.connect(host, username=user, password=password, port=22)

        channel = self.ssh.invoke_shell()
        self.stdin = channel.makefile('wb')
        self.stdout = channel.makefile('r')

    def __del__(self):
        """
        Destructor of ShellHandler Class

        """
        self.ssh.close()

    def close(self):
        """
        Closes ssh connection
        """
        self.ssh.close()

    def execute(self, cmd):
        """
        Executes command

        :param cmd: (str) command that will be executed
        :return: cmd, echo_cmd and end of stdOUT buffer
        """
        cmd = cmd.strip('\n')
        self.stdin.write(cmd + '\n')
        finish = 'end of stdOUT buffer. finished with exit status'
        echo_cmd = 'echo {} $?'.format(finish)
        self.stdin.write(echo_cmd + '\n')
        shin = self.stdin
        self.stdin.flush()
        return self.handle_output(cmd, echo_cmd, finish)

    @abc.abstractmethod
    def handle_output(self, **kwargs): pass


class AiCShellHandler(ShellHandler):
    """
    AICShellHandler Class

    Creates shell handler for AIC
    """

    def __init__(self, host, user, password):
        """
        Init AICShellHandler Class

        :param self
        :param host: hostname
        :param user: username
        :param password: password
        """
        super(AiCShellHandler, self).__init__(host, user, password)

    def handle_output(self, cmd, echo_cmd, finish):
        """
        Handles output

        :param self
        :param cmd: command to run
        :param echo_cmd: echo of command
        :param finish: end of stdOUT buffer
        """
        shin = self.stdin
        shout = []
        sherr = []
        exit_status = 0

        for line in self.stdout:
            str_line = re.compile(r'(\x9B|\x1B\[)[0-?]*[ -/]*[@-~]').sub('', line).replace('\b', '').replace('\r', '')
            if str(line).startswith(cmd) or str(line).startswith(echo_cmd):
                pass
            elif str(line).startswith(finish):
                break
            elif 'error' in str_line:
                sherr.append(str_line.strip('\n'))  # raise error
                print(str_line.strip('\n'))
            else:
                shout.append(str_line)

        if shout and echo_cmd in shout[-1]:
            shout.pop()
        if shout and cmd in shout[0]:
            shout.pop(0)

        return shin, shout, sherr


@contextmanager
def shell_session_vdu(host='192.168.2.124', user='core', password='system123'):
    """
    Creates shell session with vDU

    :param host: vDU IP address
    :param user: username
    :param password: password
    """
    handler = AiCShellHandler(host, user, password)
    try:
        yield handler
    finally:
        handler.close()


@contextmanager
def shell_session_vcu(host='etcd-1.ska-rm17-3-27.ska-lab.nsn-rdnet.net', user='core', password='system123'):
    """
    Creates shell session with vCU

    :param host: vCU address
    :param user: username
    :param password: password
    """
    handler = AiCShellHandler(host, user, password)
    try:
        yield handler
    finally:
        handler.close()


def get_vcu_master_ip():
    """Gets vCU master IP from suite variables

    :return: namespace
    """
    master_ip = BuiltIn().get_variable_value("${VCU_MASTER_IP}")
    return str(master_ip)


def get_vdu_master_ip():
    """Gets vDU master IP from suite variables

    :return: namespace
    """
    master_ip = BuiltIn().get_variable_value("${VDU_MASTER_IP}")
    return str(master_ip)


def get_vdu_namespace():
    """Gets namespace from suite variables

    :return: namespace
    """
    namespace = BuiltIn().get_variable_value("${VDU_NAMESPACE}")
    return namespace


def go_to_the_container(handler, namespace, container, pod):
    """
    Executed command in the container

    :param handler: shell session
    :param namespace: (str) namespace e.g. 7-7-ute5gcloudt7sk038
    :param container: (str) container e.g. l1hi
    :param pod: (str) pod e.g. up-0
    :return: shout
    """
    cmd = 'oc exec -it ute-{}-{} -c ctr-{}-{} -n {} -- bash'.format(namespace, pod, namespace, container, namespace)
    print(cmd)
    while True:
        shin, shout, sherr = handler.execute(cmd=cmd)
        if sherr:
            continue
        break


def download_file_from_container_to_vdu(handler, namespace, container, pod, file_path):
    """Collects files from containers to vDU"""
    print(file_path)
    file_name = file_path.split('/')[-1]
    print(file_name)
    cmd = 'kubectl cp ute-{}-{}:{} {} -c ctr-{}-{} -n {}'.format(namespace, pod, file_path, file_name, namespace,
                                                                 container, namespace)
    print(cmd)
    handler.execute(cmd=cmd)
