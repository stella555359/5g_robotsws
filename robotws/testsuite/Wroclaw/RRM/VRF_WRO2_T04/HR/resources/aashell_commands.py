import json
from robot.api import logger
from paramiko import SSHClient, AutoAddPolicy
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from asik_commands import AsikConnection
GNB_IP = tl.gnbs[0].cu.oam_ssh_connection_details.addr
GNB_USER = tl.gnbs[0].cu.oam_ssh_connection_details.username
GNB_PASSWORD = tl.gnbs[0].cu.oam_ssh_connection_details.password
TELNET_PORT = 15007


CPNB_RESOURCES = 'getResourcesUsage -l @cp_nb #0x2513'
CPNRT_RESOURCES = 'getResourcesUsage -l @cp-nrt #0x2516'
CPRT_RESOURCES = 'getResourcesUsage -l @Cprt #0x2515'


def execute_aashell_command(command, json_output=True):
    with AsikConnection() as conn:
        logger.info("Executing command: {}".format(command), also_console=True)
        output = conn.execute_command_on_asik('echo \"{}\" | nc 127.0.0.1 -w {} {}'.format(command, 10, TELNET_PORT))
        output = parse_aashell_output(output)
        logger.debug("Output: {}".format(output))
        if json_output:
            return parse_as_json(output)
        return output


def parse_aashell_output(output):
    return output.replace('AaShell> ', '')


def parse_as_json(output):
    return json.loads(output)


def get_cpnb_resources_info():
    return execute_aashell_command(CPNB_RESOURCES)


def get_cprt_resources_info():
    return execute_aashell_command(CPRT_RESOURCES)


def get_cpnrt_resources_info():
    return execute_aashell_command(CPNRT_RESOURCES)
