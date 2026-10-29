from decorator import contextmanager

from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.transport.ssh import ssh

rude_ssh = ssh()


class rude():
    """Main class for RUDE tool management. Instance of this class should be accessible
    automatically after import this module in Robot Framework.
    Naming convention relation: rude.py -> rude() class name must be preserved"""
    def __init__(self):
        self._exec_path = ""
        self._engine_ip = ""
        self._command = ""
        self._ip_addr = BuiltIn().get_variable_value("${RUDE_VM_IP}")  # "10.44.180.240"
        self._username = BuiltIn().get_variable_value("${RUDE_VM_USERNAME}")  # "plwrtrssec"
        self._password = BuiltIn().get_variable_value("${RUDE_VM_PASSWORD}")  # "tr55ec123"
        self._conn = None

    def set_connection_credentials(self, ip_addr, username, password):
        """
        Set different than default connection credentials.
        :param ip_addr:     dest ip address statically assigned to Rude
        :param username:    ptadmin should be default
        :param password:    ptadmin should be default
        :return:
        """
        self._ip_addr = ip_addr
        self._username = username
        self._password = password

    def connect_to(self):
        """Establish single connection to RUDE VM"""
        logger.console("Connect to RUDE with ip={} username={} password={}...".format(self._ip_addr,
                                                                                      self._username,
                                                                                      self._password))
        self._conn = rude_ssh.connect_to(hostname=self._ip_addr, username=self._username, password=self._password,
                                         timeout=60.0)

    def disconnect(self):
        """Disconnect single connection of RUDE VM"""
        logger.console("Disconnect RUDE...")
        rude_ssh.disconnect(self._conn)

    @contextmanager
    def connection(self):
        """
        Provide connection to RUDE VM. RUDE should be available under 10.44.180.240 address by ssh.
        RUDE is available directly only by TLs from Wroclaw WL Labs. For other locations firewall can be raised.
        """
        logger.console("Connect to RUDE with ip={} username={} password={}...".format(self._ip_addr,
                                                                                      self._username,
                                                                                      self._password))
        conn = rude_ssh.connect_to(hostname=self._ip_addr, username=self._username, password=self._password,
                                   timeout=60.0)
        yield conn
        logger.console("Disconnect RUDE...")
        rude_ssh.disconnect(conn)

    def initialize(self, exec_path=BuiltIn().get_variable_value("${RUDE_EXEC_PATH}"),
                   engine_ip=BuiltIn().get_variable_value("${RUDE_ENGINE_IP}")):
        """
        Prepare RUDE executable path and provide engine ip.
        :param exec_path:       RUDE executable path string to binary
        :param engine_ip:       RUDE engine ip string
        """
        logger.console("Initialize RUDE, set exec_path={} rude_engine_ip={}".format(exec_path, engine_ip))
        self._exec_path = exec_path
        self._engine_ip = engine_ip
        self._command = "{}".format(exec_path)

    def _execute_cmd(self, command):
        """
        Internal function for execution RUDE command.
        :param command:     RUDE command
        """
        is_executed_successfully = False
        if self._conn is not None:
            for i in range(5):
                output = rude_ssh.execute(command=command, connection=self._conn)
                logger.console("Execution try: " + str(i+1))
                if "NOK" in output:
                    logger.console("Execution status: NOT OK {}".format(str(output)))
                elif "OK" in output:
                    logger.console("Execution status: OK")
                    is_executed_successfully = True
                    break
        else:
            with self.connection() as conn:
                for i in range(5):
                    output = rude_ssh.execute(command=command, connection=conn)
                    logger.console("Execution try: " + str(i + 1))
                    if "NOK" in output:
                        logger.console("Execution status: NOT OK {}".format(str(output)))
                    elif "OK" in output:
                        logger.console("Execution status: OK")
                        is_executed_successfully = True
                        break
        assert is_executed_successfully, "Rude command is not executed successfully: {}".format(command)

    def start_rule(self, sfp_pair=1, port=7777):
        """
        Start rule on RUDE. Rule has to be started within this command on RUDE to allow further updates on RUDE.
        :param sfp_pair:  Port pair integer
        :param port:  Port integer
        """
        start_rule_cmd = self._command + ' -s {} {} {}'.format(self._engine_ip, port, sfp_pair)
        logger.console("Start rule on RUDE: {}".format(start_rule_cmd))
        self._execute_cmd(start_rule_cmd)

    def reset_rule(self, sfp_pair=1, port=7777):
        """
        Reset rule on RUDE. Its recommended to reset rule before & after RUDE usage.
        :param sfp_pair:  Rule integer
        :param port:  Port integer
        """
        reset_cmd = self._command + ' -r {} {} {} soft'.format(self._engine_ip, port, sfp_pair)
        logger.console("Reset rule on RUDE...: {}".format(reset_cmd))
        self._execute_cmd(reset_cmd)

    def set_delay(self, rule=1, port=7777, sfp_pair=1, delay_value=1500, delay_ratio=10):
        """
        Update delay on RUDE using started rule on RUDE.
        :param rule:          Started rule integer
        :param port:          Port integer
        :param sfp_pair:      Integer indicates sfp_pair. Possible values: 1, 2
        :param delay_value:   Integer delay value in ms
        :param delay_ratio:   Integer delay ratio
        """
        delay_cmd = self._command + ' -u {} {} {} -l {} -f "udp AND port 32742" -d {} {}'.format(
            self._engine_ip, port, rule, sfp_pair, delay_value, delay_ratio)
        logger.console("Set delay on RUDE...: {}".format(delay_cmd))
        self._execute_cmd(delay_cmd)

    def set_drop(self, rule=1, port=7777, sfp_pair=1, drop_direction=None, drop_mode="constant", drop_ratio=10):
        """
        Update drop on RUDE using started rule on RUDE.
        :param rule:               Started rule integer
        :param port:               Port integer
        :param sfp_pair:           Integer indicates sfp_pair. Possible values: 1, 2
        :param drop_direction:     Integer indicates port in rule. 1 for upstream, 2 for downstream
        :param drop_mode:          Drop mode: random, constant, burst or predefined
        :param drop_ratio:         Integer drop ratio
        """
        drop_cmd = self._command + ' -u {} {} {} -l {} -c {} -f "udp" -o {} {}'.format(self._engine_ip, port, rule,
                                                                                       sfp_pair, drop_direction,
                                                                                       drop_mode, drop_ratio)
        logger.console("Set drop on RUDE...: {}".format(drop_cmd))
        self._execute_cmd(drop_cmd)

    def set_duplication(self, rule=1, port=7777, sfp_pair=1,
                        duplication_direction=None, duplication_mode="constant", duplication_ratio=10):
        """
        Update duplication on RUDE using started rule on RUDE.
        :param rule:                      Started rule integer
        :param port:                      Port integer
        :param sfp_pair:                  Integer indicates sfp_pair. Possible values: 1, 2
        :param duplication_direction:     Integer indicates port in rule. 1 for upstream, 2 for downstream
        :param duplication_mode:          Duplication mode: random or constant
        :param duplication_ratio:         Integer duplication ratio
        """
        duplication_cmd = self._command + ' -u {} {} {} -l {} -c {} -f "udp" -p {} {}'.format(self._engine_ip,
                                                                                              port, rule, sfp_pair,
                                                                                              duplication_direction,
                                                                                              duplication_mode,
                                                                                              duplication_ratio)
        logger.console("Set duplication on RUDE...: {}".format(duplication_cmd))
        self._execute_cmd(duplication_cmd)

    def set_reorder(self, rule=1, port=7777, sfp_pair=1, reorder_direction=None,
                    reorder_mode="constant", reorder_ratio=10, reorder_offset=1):
        """
        Update reorder on RUDE using started rule on RUDE.
        :param rule:                   Started rule integer
        :param port:                   Port integer
        :param sfp_pair:               Integer indicates sfp_pair. Possible values: 1, 2
        :param reorder_direction:      Integer indicates port in rule. 1 for upstream, 2 for downstream
        :param reorder_mode:           Reorder mode with the alternative values random, constant or weighted random
        :param reorder_ratio:          Integer reorder ratio
        :param reorder_offset:         Integer reorder offset
        """
        reorder_cmd = self._command + ' -u {} {} {} -l {} -c {} -f "udp" -reor {} {} {}'.format(self._engine_ip, port,
                                                                                                rule, sfp_pair,
                                                                                                reorder_direction,
                                                                                                reorder_mode,
                                                                                                reorder_ratio,
                                                                                                reorder_offset)
        logger.console("Set reorder on RUDE...: {}".format(reorder_cmd))
        self._execute_cmd(reorder_cmd)
