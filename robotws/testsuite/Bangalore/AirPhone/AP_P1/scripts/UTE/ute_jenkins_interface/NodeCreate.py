import jenkins
from taf.transport.ssh import ssh


JENKINS_BASE_URL = "http://5g-cimaster-4.eecloud.dynamic.nsn-net.net:8080"
CREDENTIALS_ID = "8d93c16d-babf-42e1-a006-145d71d19944"
USERNAME = "twp468"
PASSWORD = "4a70612bfde7e63cffad740d16134697"


class NodeCreate():
    def __init__(self, node_name, node_ip, username, password, label, path='/home/ute'):
        self.node = Node(node_name, node_ip, username, password, label, path)
        self.jenkins = jenkins.Jenkins(JENKINS_BASE_URL, username=USERNAME, password=PASSWORD)

    def add_node(self):
        SSHKeyHandler.add_public_key_to_authorised_file(self.node)
        params = {
            'port': '22',
            'username': self.node.username,
            'credentialsId': CREDENTIALS_ID,
            'host': self.node.ip
        }
        self.jenkins.create_node(
            self.node.name,
            nodeDescription='CIT UTE Node',
            remoteFS=self.node.path,
            labels=self.node.label,
            exclusive=True,
            launcher=jenkins.LAUNCHER_SSH,
            launcher_params=params)
        self.jenkins.node_exists(self.node.name)
        return

    def is_node_online(self):
        node_info = self.get_node_info()
        return not node_info['offline']

    def get_node_info(self):
        return self.jenkins.get_node_info(self.node.name)


class Node():
    def __init__(self, node_name, ip, username, password, label, path):
        self.name = node_name
        self.ip = ip
        self.username = username
        self.password = password
        self.label = label
        self.path = path


class SSHKeyHandler():
    SSH_PUBLIC_KEY = '''ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7cesL86ANxOMLqTJ3+jqCuD/kUjh6/TYraRnMj+UB7
R0OkYbcbv00lahhj3kLNoxEVbDLRiMDtjkvq9BKaNSChDdBCZF8zn83Zk/xMUpqvCRoLzqgoPLkzHo5mBdPzqcm3bVUUPMs9xp36pvMVV
dOkL7WAna4rppMnTmKtwYY4s1yIT3KjHsp2HF17DgTTARRHUQ0+Hm10tRO6uoVMwTVcNRM0MdNxxKt3BO6O9bblEB0d00rbUoz9eYcID1
s079Jkg+zAFfT1IbSsVChJnGTRCTB/svaUE7Gx2r5KvcuHRffV2ufhMJYYJH9Moz901i/w9SeFoRR6dpSUbj/vXK9 ute@robot-vm'''
    SSH_PUBLIC_KEY = SSH_PUBLIC_KEY.replace('\n', '').replace('\r', '')
    SSH_INSTANCE = ssh()

    @staticmethod
    def add_public_key_to_authorised_file(node):
        SSHKeyHandler.login(node)
        SSHKeyHandler.SSH_INSTANCE.send_command('echo {} >> ~/.ssh/authorized_keys'
                                                .format(SSHKeyHandler.SSH_PUBLIC_KEY))
        SSHKeyHandler.SSH_INSTANCE.assert_exit_status(0)
        return

    @staticmethod
    def login(node):
        SSHKeyHandler.SSH_INSTANCE.connect_to(node.ip, node.username, node.password)
        return
