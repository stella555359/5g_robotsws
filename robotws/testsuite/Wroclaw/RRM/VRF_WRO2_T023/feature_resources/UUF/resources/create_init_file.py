import os
from string import Template


def create_init_file(vdu_ssh_ip, vdu_ssh_user, vdu_ssh_password, vdu_oam_ip, vdu_oam_user, vdu_oam_password,
                     vdu_namespace, vcu_ssh_ip, vcu_ssh_user, vcu_ssh_password, vcu_oam_ip, vcu_oam_user,
                     vcu_oam_password, vcu_namespace, vm_ip, vm_user, vm_password, maintainer,
                     team, maintainer_email, owner_email, destination_dir_path):

    """
    Creates __init__.py file from template and saves it in destination directory.

    :param vdu_ssh_ip: IP of vDU used for SSH connection.
    :param vdu_ssh_user: Username for SSH connection with vDU.
    :param vdu_ssh_password: Password for SSH connection with vDU.
    :param vdu_oam_ip: OAM IP address for connecting with vDU (M-plane).
    :param vdu_oam_user: OAM username for connecting with vDU.
    :param vdu_oam_password: OAM password for connecting with vDU.
    :param vdu_namespace: Namespace for vDU.
    :param vcu_ssh_ip: IP of vCU used for ssh connection.
    :param vcu_ssh_user: Username for SSH connection with vCU.
    :param vcu_ssh_password: Password for SSH connection with vCU.
    :param vcu_oam_ip: OAM IP address for connecting with vCU (M-plane).
    :param vcu_oam_user: OAM username for connecting with vCU.
    :param vcu_oam_password: OAM password for connecting with vCU.
    :param vcu_namespace: Namespace for vCU.
    :param vm_ip: IP of VM where tests are being run.
    :param vm_user: Username for VM where tests are being run.
    :param vm_password: Password for VM where tests are being run.
    :param maintainer: Name of maintainer.
    :param team: Team of maintainer.
    :param maintainer_email: Email of maintainer.
    :param owner_email: Email of configuration owner.
    :param destination_dir_path: Absolute path to directory in which file will be saved.
    """

    content = _create_init_file_from_template(vdu_ssh_ip, vdu_ssh_user, vdu_ssh_password, vdu_oam_ip, vdu_oam_user,
                                              vdu_oam_password, vdu_namespace, vcu_ssh_ip, vcu_ssh_user,
                                              vcu_ssh_password, vcu_oam_ip, vcu_oam_user, vcu_oam_password,
                                              vcu_namespace, vm_ip, vm_user, vm_password, maintainer, team,
                                              maintainer_email, owner_email)
    _save_init_file(content, destination_dir_path)


def _create_init_file_from_template(vdu_ssh_ip, vdu_ssh_user, vdu_ssh_password, vdu_oam_ip, vdu_oam_user,
                                    vdu_oam_password, vdu_namespace, vcu_ssh_ip, vcu_ssh_user, vcu_ssh_password,
                                    vcu_oam_ip, vcu_oam_user, vcu_oam_password, vcu_namespace, vm_ip, vm_user,
                                    vm_password, maintainer, team, maintainer_email, owner_email):
    template = Template("""
__maintainer__ = $maintainer
__team__ = $team
__email__ = $maintainer_email
__owner_email__ = $owner_email

import os
from taf.config.testline.cloud_hosting import (
    CloudDeployment,
)

from taf.config.testline.connection_details import (
    SshServiceDetails,
    HttpConnectionDetails,
    K8SConnectionDetails,
)
from taf.config.testline.testpc import TestPc
from taf.config.testline.testline import TestLine
from taf.config.testline.gnb import CloudBts, CU
from taf.config.testline.gnb.du import VDU
from taf.config.testline.cloud_hosting import MasterNode, K8S

_cfg_dir = os.path.dirname(os.path.abspath(__file__))



_vdu_k8s_ssh_connection_details = SshServiceDetails(
    addr=$vdu_ssh_ip, username=$vdu_ssh_user, password=$vdu_ssh_password
)

_vdu_k8s_connection_details = K8SConnectionDetails(
    ip_addr=$vdu_ssh_ip, username=$vdu_ssh_user, password=$vdu_ssh_password, port=22
)

_vdu_master_node = MasterNode(
    k8s_connection_details=_vdu_k8s_connection_details,
    ssh_connection_details=_vdu_k8s_ssh_connection_details,
)

_vdu_k8s = K8S(namespace=$vdu_namespace, master_node=_vdu_master_node)

_vdu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vdu_k8s,
)

_vdu_oam_http_connection_details = HttpConnectionDetails(
    addr=$vdu_oam_ip, port=443, username=$vdu_oam_user, password=$vdu_oam_password
)

_vdu = VDU(
    cloud_deployment=_vdu_k8s_cloud_deployment,
    oam_http_connection_details=_vdu_oam_http_connection_details,
)

_cu = CU(
    oam_ssh_connection_details=SshServiceDetails(
        addr=$vcu_oam_ip, username=$vcu_oam_user, password=$vcu_oam_password
    ),
    oam_http_connection_details=HttpConnectionDetails(
        addr=$vcu_oam_ip, port=443, username=$vcu_oam_user, password=$vcu_oam_password
    ),
    backhaul_site_oam_ip="None",
)

_vcu_k8s_ssh_connection_details = SshServiceDetails(
    addr=$vcu_ssh_ip,
    username=$vcu_ssh_user,
    password=$vcu_ssh_password,
)

_vcu_k8s_connection_details = K8SConnectionDetails(
    ip_addr=$vcu_ssh_ip,
    username=$vcu_ssh_user,
    password=$vcu_ssh_password,
    port=22,
)

_vcu_master_node = MasterNode(
    k8s_connection_details=_vcu_k8s_connection_details,
    ssh_connection_details=_vcu_k8s_ssh_connection_details,
)

_vcu_k8s = K8S(namespace=$vcu_namespace, master_node=_vcu_master_node)

_vcu_k8s_cloud_deployment = CloudDeployment(
    default_cfg_dir=_cfg_dir,
    cloud_hosting=_vcu_k8s,
)

_cbts = CloudBts(
    dus=[_vdu],
    cu=_cu,
    cloud_deployment=_vcu_k8s_cloud_deployment,
)


gnbs=[_cbts]

_test_pc = TestPc(
    default_ssh_connection_details=SshServiceDetails(
        addr=$vm_ip,
        username=$vm_user,
        password=$vm_password,
    ),
    connections=[_cbts],
)

tl = TestLine(
    test_pc=_test_pc,
    cloud_hostings=[_vcu_k8s, _vdu_k8s],
    gnbs=[_cbts],
)

__all__ = ["tl"]
    """)

    data = {
        "vdu_ssh_ip": f"\"{vdu_ssh_ip}\"",
        "vdu_ssh_user": f"\"{vdu_ssh_user}\"",
        "vdu_ssh_password": f"\"{vdu_ssh_password}\"",
        "vdu_oam_ip": f"\"{vdu_oam_ip}\"",
        "vdu_oam_user": f"\"{vdu_oam_user}\"",
        "vdu_oam_password": f"\"{vdu_oam_password}\"",
        "vdu_namespace": f"\"{vdu_namespace}\"",

        "vcu_ssh_ip": f"\"{vcu_ssh_ip}\"",
        "vcu_ssh_user": f"\"{vcu_ssh_user}\"",
        "vcu_ssh_password": f"\"{vcu_ssh_password}\"",
        "vcu_oam_ip": f"\"{vcu_oam_ip}\"",
        "vcu_oam_user": f"\"{vcu_oam_user}\"",
        "vcu_oam_password": f"\"{vcu_oam_password}\"",
        "vcu_namespace": f"\"{vcu_namespace}\"",

        "vm_ip": f"\"{vm_ip}\"",
        "vm_user": f"\"{vm_user}\"",
        "vm_password": f"\"{vm_password}\"",
        "maintainer": f"\"{maintainer}\"",
        "team": f"\"{team}\"",
        "maintainer_email": f"\"{maintainer_email}\"",
        "owner_email": f"\"{owner_email}\""
    }

    return template.substitute(data)


def _save_init_file(content, destination_dir_path):
    os.makedirs(destination_dir_path, exist_ok=True)
    file_path = os.path.join(destination_dir_path, "__init__.py")

    with open(file_path, "w") as file:
        file.write(content)
    print(f"__inie__.py file generated in {destination_dir_path}")
