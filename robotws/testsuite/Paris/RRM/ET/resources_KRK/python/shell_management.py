"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Beata Kapusta
:maintainer:  Adrianna Pienkowska, Beata Kapusta
:contact: adrianna.pienkowska@nokia.com, beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from contextlib import contextmanager
from abc import ABCMeta, abstractmethod
from robot.libraries.BuiltIn import BuiltIn
import paramiko
import re


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
        self.stdin.flush()
        return self.handle_output(cmd=cmd, echo_cmd=echo_cmd, finish=finish)

    @abstractmethod
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
        super().__init__(host, user, password)

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

        for line in self.stdout:
            str_line = re.compile(r'(\x9B|\x1B\[)[0-?]*[ -/]*[@-~]').sub('', line).replace('\b', '').replace('\r', '')
            if str(line).startswith(cmd) or str(line).startswith(echo_cmd):
                pass
            elif str(line).startswith(finish) or 'finished with exit status 0' in line:
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
def shell_session_vdu(host=None, user=None, password=None):
    """
    Creates shell session with vDU

    :param host: vDU IP address
    :param user: username
    :param password: password
    """
    if not all([host, user, password]):
        host, user, password = get_vdu_connection_params()
    handler = AiCShellHandler(host, user, password)
    try:
        yield handler
    finally:
        handler.close()


@contextmanager
def shell_session_vcu(host=None, user=None, password=None):
    """
    Creates shell session with vCU

    :param host: vCU address
    :param user: username
    :param password: password
    """
    if not all([host, user, password]):
        host, user, password = get_vcu_connection_params()
    handler = AiCShellHandler(host, user, password)
    try:
        yield handler
    finally:
        handler.close()


def get_vdu_namespace():
    """Gets namespace from suite variables

    :return: namespace
    """
    namespace = BuiltIn().get_variable_value("${VDU_NAMESPACE}")
    if not namespace:
        namespace = BuiltIn().get_variable_value("${tl}").gnbs[0].dus[0].cloud_deployment.cloud_hosting.namespace

    try:
        assert namespace
    except AssertionError as e:
        BuiltIn().log("VDU_NAMESPACE variable must not be empty!", level='ERROR', console=True)
        raise e
    return namespace


def get_vdu_connection_params():
    """Gets vDU IP, username and passsord from suite variables

    :return: IP, username, passsord
    """
    host = BuiltIn().get_variable_value("${VDU_MASTER_IP}")
    user = BuiltIn().get_variable_value("${VDU_MASTER_USERNAME}")
    passw = BuiltIn().get_variable_value("${VDU_MASTER_PASS}")
    if not all([host, user, passw]):
        ssh_connection_details = BuiltIn().get_variable_value("${tl}").gnbs[0].dus[0]\
                                    .cloud_deployment.cloud_hosting.master_node.ssh_connection_details
        host = ssh_connection_details.addr
        user = ssh_connection_details.username
        passw = ssh_connection_details.password

    try:
        assert all([host, user, passw])
    except AssertionError as e:
        BuiltIn().log("VDU_MASTER_IP, VDU_MASTER_USERNAME and VDU_MASTER_PASS variables must not be empty!",
                      level='ERROR', console=True)
        raise e
    return host, user, passw


def get_vcu_connection_params():
    """Gets vCU IP, username and passsord from suite variables

    :return: IP, username, passsord
    """
    host = BuiltIn().get_variable_value("${VCU_MASTER_IP}")
    user = BuiltIn().get_variable_value("${VCU_MASTER_USERNAME}")
    passw = BuiltIn().get_variable_value("${VCU_MASTER_PASS}")
    if not all([host, user, passw]):
        ssh_connection_details = BuiltIn().get_variable_value("${tl}").gnbs[0]\
                                    .cloud_deployment.cloud_hosting.master_node.ssh_connection_details
        host = ssh_connection_details.addr
        user = ssh_connection_details.username
        passw = ssh_connection_details.password

    try:
        assert all([host, user, passw])
    except AssertionError as e:
        BuiltIn().log("VCU_MASTER_IP, VCU_MASTER_USERNAME and VCU_MASTER_PASS variables must not be empty!",
                      level='ERROR', console=True)
        raise e
    return host, user, passw


def go_to_the_container(handler, namespace, container, pod):
    """
    Executed command in the container

    :param handler: shell session
    :param namespace: (str) namespace e.g. 7-7-ute5gcloudt7sk038
    :param container: (str) container e.g. l1hi
    :param pod: (str) pod e.g. up-0
    :return: shout
    """
    cmd = 'oc exec -it ute-{namespace}-{pod} -c ctr-{namespace}-{container} -n {namespace} -- bash'.format(
        namespace=namespace, pod=pod, container=container)
    while True:
        shin, shout, sherr = handler.execute(cmd=cmd)
        if sherr:
            continue
        break


def go_to_the_pod(handler, namespace, pod):
    """
    Executed command in the container

    :param handler: shell session
    :param namespace: (str) namespace e.g. 7-7-ute5gcloudt7sk038
    :param container: (str) container e.g. l1hi
    :param pod: (str) pod e.g. up-0
    :return: shout
    """
    cmd = 'oc exec -it ute-{namespace}-{pod} -n {namespace} -- bash'.format(
        namespace=namespace, pod=pod)
    while True:
        shin, shout, sherr = handler.execute(cmd=cmd)
        if sherr:
            continue
        break


def download_file_from_container_to_vdu(handler, namespace, container, pod, file_path):
    """Collects files from containers to vDU"""
    file_name = file_path.split('/')[-1]
    cmd_tmp = 'kubectl cp ute-{namespace}-{pod}:{file_path} {file_name} -c ctr-{namespace}-{container} -n {namespace}'
    cmd = cmd_tmp.format(
        namespace=namespace, pod=pod, file_name=file_name, container=container, file_path=file_path)
    handler.execute(cmd=cmd)
