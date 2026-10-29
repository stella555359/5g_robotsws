import time
import paramiko
from contextlib import contextmanager
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from .utility_functions import get_pod_name


class OcpOperator:
    def __init__(self):
        self.testline_details = BuiltIn().get_variable_value("${tl}")
        self.ocp_entities = self.testline_details.cloud_hostings
        self.ocp_vcu_ip, self.ocp_vcu_user, self.ocp_vcu_password, self.ocp_vcu_namespace = self.setup_vcu_details()
        self.ocp_vdu1_ip, self.ocp_vdu1_user, self.ocp_vdu1_password, self.ocp_vdu1_namespace = \
            self.setup_vdu_details()[0]
        self.ocp_vdu2_ip, self.ocp_vdu2_user, self.ocp_vdu2_password, self.ocp_vdu2_namespace = \
            self.setup_vdu_details()[1]

    @contextmanager
    def use_ssh(self, host_ip, username, password):
        ssh = paramiko.SSHClient()
        ssh.load_system_host_keys()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            ssh.connect(host_ip, username=username, password=password)
            yield ssh
        except paramiko.SSHException as e:
            print("SSH Exception occurred:", e)
        finally:
            ssh.close()

    def setup_vcu_details(self):
        ssh_details_vcu = self.ocp_entities[0].master_node.ssh_connection_details
        ocp_vcu_ip = ssh_details_vcu.addr
        ocp_vcu_user = ssh_details_vcu.username
        ocp_vcu_password = ssh_details_vcu.password
        ocp_vcu_namespace = self.ocp_entities[0].namespace
        return ocp_vcu_ip, ocp_vcu_user, ocp_vcu_password, ocp_vcu_namespace

    def setup_vdu_details(self):
        ssh_details_vdu_1 = self.ocp_entities[1].master_node.ssh_connection_details
        vdu1_details, vdu2_details = [], []
        if len(self.ocp_entities) > 2:
            ssh_details_vdu_2 = self.ocp_entities[2].master_node.ssh_connection_details
            vdu2_details.append(ssh_details_vdu_2.addr)
            vdu2_details.append(ssh_details_vdu_2.username)
            vdu2_details.append(ssh_details_vdu_2.password)
            vdu2_details.append(self.ocp_entities[2].namespace)
        else:
            vdu2_details.extend(["", "", "", ""])
        vdu1_details.append(ssh_details_vdu_1.addr)
        vdu1_details.append(ssh_details_vdu_1.username)
        vdu1_details.append(ssh_details_vdu_1.password)
        vdu1_details.append(self.ocp_entities[1].namespace)
        return vdu1_details, vdu2_details

    def get_entity_details(self, entity):
        if "vcu" in entity:
            return self.ocp_vcu_ip, self.ocp_vcu_user, self.ocp_vcu_password, self.ocp_vcu_namespace
        elif "vdu1" in entity:
            return self.ocp_vdu1_ip, self.ocp_vdu1_user, self.ocp_vdu1_password, self.ocp_vdu1_namespace
        elif "vdu2" in entity:
            return self.ocp_vdu2_ip, self.ocp_vdu2_user, self.ocp_vdu2_password, self.ocp_vdu2_namespace
        else:
            raise Exception("Wrong entity specified (%s). Possible values: vcu, vdu1, vdu2." % entity)

    def get_containers(self, entity='vdu1', pod='cprt'):
        """
        Gets all container names within specified pod.

        Args:
            entity (str): Possible values: vcu, vdu1 and vdu2.
            pod (str): Specify component name for desired pod, e.g. cprt, l2rt etc. (same format as visible in WebEM).
        """
        host, user, password, namespace = self.get_entity_details(entity)
        with self.use_ssh(host, user, password) as ssh:
            stdin, stdout, stderr = ssh.exec_command(
                "kubectl get pods %s -o jsonpath='{.spec.containers[*].name}' -n %s" % (get_pod_name(pod), namespace))
            containers = stdout.readlines()
            if containers:
                return containers[0].split()
            else:
                return []

    def get_container(self, entity, pod, container_name):
        """
        Gets full container name within specified pod.

        Args:
            entity (str): Possible values: vcu, vdu1 and vdu2.
            pod (str): Specify component name for desired pod, e.g. cprt, l2rt etc. (same format as visible in WebEM).
            container_name (str): Short name of a container, e.g. nwmgmt, cprt, ipsecmgmt, tracecontroller etc.
        """
        containers = self.get_containers(entity, pod)
        if containers:
            for container in containers:
                if container_name in container:
                    return container

    def change_interface_status_on_pod(self, entity='vdu1', pod='cprt', container='', interface='f1c', status='down'):
        """
        Sets provided network interface status to up or down.

        Args:
            entity (str): Possible values: vcu, vdu1 and vdu2.
            pod (str): Specify component name for desired pod, e.g. cprt, l2rt etc. (same format as visible in WebEM).
            container (str): Short name of a container, e.g. nwmgmt, cprt, ipsecmgmt, tracecontroller etc.
            interface (str): Specify interface for which status change is needed
            status: in most cases up or down
        """
        if container:
            container_part = " -c " + self.get_container(entity, pod, container)
        else:
            container_part = ""
        host, user, password, namespace = self.get_entity_details(entity)
        pod_name = get_pod_name(pod)
        ip_link_command = "oc exec -it %s%s -n %s -- bash -c 'ip link set dev %s %s'" % (
            pod_name, container_part, namespace, interface, status)
        verify_command = "oc exec -it %s%s -n %s -- bash -c 'ip a show dev %s | grep state | cut -d \" \" -f 9'" % (
            pod_name, container_part, namespace, interface)
        with self.use_ssh(host, user, password) as ssh:
            ssh.exec_command(ip_link_command)
            time.sleep(0.4)  # time between SSH commands should be longer than 0.2s in order to work on OCP
            stdin, stdout, stderr = ssh.exec_command(verify_command)
            status = status.casefold()
            verify_command_output = stdout.read().decode().strip().casefold()
            if status in verify_command_output:
                logger.info("%s interface successfully changed status to %s" % (interface, status), also_console=True)
            else:
                raise Exception("Failed to set %s interface status to %s" % (interface, status))
