import time
from robot.api import logger


from taf.transport.ssh.interface import ssh
import taf.config.scf as scf_interface
import taf.gnb.oam.coam.admin as admin_cli_interface


ssh_usr = ssh()
ssh_alias = "ASOD"


def connect_to_gnb(address, alias, user="toor4nsn", passw="oZPS0POrRieRtu"):
    ssh_usr.connect_to(hostname=address, username=user, password=passw, alias=alias)
    ssh_alias = alias


def generate_fault_4077():
    ssh_usr.execute(
        command="echo '#!/bin/bash' > /tmp/temp_script.sh; echo 'while [ 1 ]; do echo 0 > /dev/ddal/fan/0/pwm; "
                "echo 0 > /dev/ddal/fan/1/pwm; done' >> /tmp/temp_script.sh; chmod 775 /tmp/temp_script.sh",
        connection=ssh_alias)
    ssh_usr.send_command(command="/tmp/temp_script.sh", connection=ssh_alias)


def disable_fault_4077():
    ssh_usr.execute(command="killall temp_script.sh; rm /tmp/temp_script.sh", connection=ssh_alias)


def disconnect_to_gnb():
    ssh_usr.disconnect(connection="ssh_alias")
