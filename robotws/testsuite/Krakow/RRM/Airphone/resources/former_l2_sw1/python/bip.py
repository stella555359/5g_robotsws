""" Module responsible for BIP related operations like starting and stopping mirroring and getting vDU details."""
from contextlib import contextmanager
import pexpect
from robot.libraries.BuiltIn import BuiltIn
from taf.collectors.core.entities import managed_ssh_connection


class bip:
    """Class responsible for getting vDU details and starting/stopping mirroring"""
    def __init__(self):
        self.tl_config = BuiltIn().get_variable_value('${tl}')
        self.vdu_namespace = self.get_vdu_namespace()
        self.vdu_ssh_details = self.get_vdu_ssh_details()

    @contextmanager
    def vdu_master_node_connection(self):
        """Context manager for ssh connection to vDU master node."""
        ssh_connection = managed_ssh_connection.ManagedSshConnection(host=self.vdu_ssh_details.addr,
                                                                     user=self.vdu_ssh_details.username,
                                                                     password=self.vdu_ssh_details.password)
        ssh_connection.setup()
        try:
            yield ssh_connection
        finally:
            ssh_connection.teardown()

    def get_pod(self, pod_name):
        """Get pod name from vDU namespace."""
        with self.vdu_master_node_connection() as ssh_connection:
            cmd = f'kubectl get pods -n {self.vdu_namespace} | grep {pod_name}'
            kubectl_output = ssh_connection.execute(cmd)
            return kubectl_output.split()[0]

    def get_vdu_ssh_details(self):
        """Get ssh details for vDU master node."""
        return self.tl_config.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details

    def get_vdu_namespace(self):
        """Get namespace on vDU master node."""
        return self.tl_config.cloud_hostings[1].namespace

    def get_container(self, pod_name, container_name):
        """Get container name from containers in specific pod."""
        with self.vdu_master_node_connection() as ssh_connection:
            cmd = f"kubectl get pods -n {self.vdu_namespace} {pod_name} -o jsonpath='{{.spec.containers[*].name}}'"
            kubectl_output = ssh_connection.execute(cmd)
            for container in kubectl_output.split():
                if container_name in container:
                    return container

    def start_mirroring_l1up(self, pod_name, container_name):
        """Enable mirroring in container"""
        def _start_mirroring_l1up():
            cmd = f'sshpass -p {self.vdu_ssh_details.password} ' \
                  f'ssh {self.vdu_ssh_details.username}@{self.vdu_ssh_details.addr} ' \
                  f'kubectl exec -n {self.vdu_namespace} {pod_name} -c {container_name} ' \
                  f'-- hal-cli pdump mirror l1up lo &'
            p = pexpect.spawn(cmd)
            p.expect('Device with port_id=2 already stopped', timeout=10)
            print("Mirroring enabled")
        try:
            _start_mirroring_l1up()
        except Exception as exc:
            print(exc)
            print("Mirroring failed. Trying repeat command")
            _start_mirroring_l1up()

    def stop_mirroring_l1up(self, pod_name, container_name):
        """Disable mirroring in container"""
        cmd = f'kubectl exec -it -n {self.vdu_namespace} {pod_name} -c {container_name} -- bash -c "killall hal-cli"'
        with self.vdu_master_node_connection() as ssh_connection:
            kubectl_output = ssh_connection.execute(cmd)
            return kubectl_output
