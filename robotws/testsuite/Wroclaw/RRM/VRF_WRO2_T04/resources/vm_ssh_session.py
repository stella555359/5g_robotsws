import os
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from robot.api import logger

LEFT_SMOD = 0
RIGHT_SMOD = 1


class VmSshSession:
    def __init__(self, vm_id=LEFT_SMOD):
        self.ssh = ssh()
        self.vm_id = vm_id
        self.alias = f"connection_{vm_id}"
        self.connection = None

    def __enter__(self):
        if self.vm_id != LEFT_SMOD:
            self.connection = self.ssh.connect_to(
                hostname=tl.test_pcs[self.vm_id].default_ssh_connection_details.addr,
                username=tl.test_pcs[self.vm_id].default_ssh_connection_details.username,
                password=tl.test_pcs[self.vm_id].default_ssh_connection_details.password,
                alias=self.alias)
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self.vm_id != LEFT_SMOD:
            self.ssh.disconnect(connection=self.alias)

    def execute_command_on_smod(self, cmd):
        smod_conn = self.ssh.connect_to(
            hostname=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.addr,
            username=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.username,
            password=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.password,
            proxy=self.connection
        )
        try:
            return self.ssh.execute(cmd, smod_conn)
        finally:
            self.ssh.disconnect(smod_conn)

    def download_file_from_smod(self, remote_filepath, local_filepath):
        logger.info(f"Downloading file: {remote_filepath} from SMOD")
        smod_conn = self.ssh.connect_to(
            hostname=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.addr,
            username=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.username,
            password=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.password,
            proxy=self.connection
        )
        try:
            self.ssh.download_file(remote_path=remote_filepath, local_path=local_filepath, connection=smod_conn)
        finally:
            self.ssh.disconnect(smod_conn)

    def download_file(self, remote_filepath, local_filepath):
        logger.info(f"Downloading file: {remote_filepath} from VM")
        self.ssh.download_file(remote_path=remote_filepath, local_path=local_filepath, connection=self.alias)

    def file_exists_on_smod(self, remote_filepath):
        smod_conn = self.ssh.connect_to(
            hostname=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.addr,
            username=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.username,
            password=tl.gnbs[self.vm_id].dus[0].airscale.common_units[0].lmp_connection.password,
            proxy=self.connection
        )
        try:
            return self.ssh.file_exists(remote_filepath, smod_conn)
        finally:
            self.ssh.disconnect(smod_conn)
