"""
:copyright: Nokia Networks
:author: Lixia Tang
:contact: lixia.tang@nokia-sbell.com
"""

from robot.api import logger
from taf.sbts.oam.coam.admin import admin
from robot.libraries.BuiltIn import BuiltIn
import os
import paramiko


def create_ssh_keypair_for(owner):
    from cryptography.hazmat.backends import default_backend as crypto_default_backend
    from cryptography.hazmat.primitives import serialization as crypto_serialization
    from cryptography.hazmat.primitives.asymmetric import rsa

    keypaths = []
    key = rsa.generate_private_key(
        backend=crypto_default_backend(),
        public_exponent=65537,
        key_size=2048
    )
    private_key = key.private_bytes(
        crypto_serialization.Encoding.PEM,
        crypto_serialization.PrivateFormat.TraditionalOpenSSL,
        crypto_serialization.NoEncryption())
    public_key = key.public_key().public_bytes(
        crypto_serialization.Encoding.OpenSSH,
        crypto_serialization.PublicFormat.OpenSSH
    )
    with open("private_{}.key".format(owner), 'wb') as priv:
        priv.write(private_key)
        keypaths.append("private_{}.key".format(owner))
    with open("public_{}.key".format(owner), 'wb') as pub:
        pub.write(public_key)
        keypaths.append("public_{}.key".format(owner))
    logger.console("SSH keypair for {} created.".format(owner))
    return keypaths


def create_ssh_connection_using_paramiko(ip_address, username, password):
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh_client.connect(
        hostname=ip_address,
        username=username,
        password=password)
    return ssh_client


def send_private_key_to(ip_address, username, password, keypath):
    ssh_client = create_ssh_connection_using_paramiko(
        ip_address, username, password)
    sftp = ssh_client.open_sftp()
    sftp.put(keypath, "/user/{}/{}".format(username, keypath.split("/")[-1]))
    sftp.close()


def check_if_system_control_possible(answer):
    assert 'Permission denied' not in answer, "Permission denied for operation fdisk -l"


def delete_ssh_files_locally(private_path, public_path):
    os.remove(private_path)
    os.remove(public_path)


def check_if_permission_is_non_root(answer):
    answer = answer.rstrip()
    assert int(answer) != 0, "UID equals 0."


def add_public_ssh_key_to_bts_to(
        owner, list_of_filepaths, connection, mrbtsid):
    public_key_path = list_of_filepaths[-1]
    with open(public_key_path, 'r') as f:
        public_key = f.read().replace('\n', '')
    payload = [{'keyDescription': '# TEST', 'keyValue': public_key}]
    change_parameter_on_bts(
        'MRBTS-{}/MNL-1/MNLENT-1/SECADM-1'.format(mrbtsid),
        owner,
        payload,
        connection)


def get_public_ssh_key_content(list_of_filepaths):
    public_key_path = list_of_filepaths[-1]
    with open(public_key_path, 'r') as f:
        public_key = f.read().replace('\n', '')
    return public_key
