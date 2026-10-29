from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.resources.rrm_fixture import asik_username, asik_password, classical_asik_ip_address
from robot.api import logger
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_abil_hostname


class AsikConnection:
    def __init__(self, hostname=classical_asik_ip_address, user=asik_username, password=asik_password):
        self.ssh = ssh()
        self.hostname = hostname
        self.user = user
        self.password = password
        self.alias = 'ssh_asik'

    def __enter__(self):
        self.ssh.connect_to(self.hostname, self.user, self.password, alias=self.alias)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.ssh.disconnect(self.alias)

    def execute_command_on_asik(self, command):
        logger.info("Executing command: {}".format(command), also_console=True)
        output = self.ssh.execute(command, connection=self.alias)
        logger.debug(output)
        return output

    def execute_command_on_abil(self, command, bsh='master'):
        abil_address = get_abil_hostname(bsh)
        logger.info("Executing command on ABIL {} {}: {}".format(bsh, abil_address, command), also_console=True)
        self.ssh.connect_to(hostname=get_abil_hostname(bsh),
                            username=asik_username, password=asik_password, proxy=self.alias, alias='ssh_abil')
        output = self.ssh.execute(command, connection='ssh_abil')
        logger.debug("Output: {}".format(output))
        self.ssh.disconnect(connection='ssh_abil')
        return output

    def execute_command_on_slave(self, command):
        slave_address = '192.168.253.2'
        logger.info("Executing command on ASIK Slave({}): {}".format(slave_address, command), also_console=True)
        self.ssh.connect_to(hostname=slave_address, username=asik_username, password=asik_password,
                            proxy=self.alias, alias='ssh_slave')
        output = self.ssh.execute(command, connection='ssh_slave')
        logger.debug("Output: {}".format(output))
        self.ssh.disconnect(connection='ssh_slave')
        return output
