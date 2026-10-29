# -*- coding: utf-8 -*-
"""
author: Grzegorz Kaczor, grzegorz.kaczor@nokia.com
maintainer:
"""
import logging
import time
from taf.transport.ssh import ssh

ssh = ssh()
channel = None


def connect_to_gnb(gnb_ip, username="toor4nsn", passwd="oZPS0POrRieRtu", alias="gnb_proxy"):
    ssh.connect_to(hostname=gnb_ip, username=username, password=passwd, alias=alias)


def disconnect_from_gnb(alias='gnb_proxy'):
    ssh.disconnect(connection=alias)


def get_all_ru_internal_ips(alias="gnb_proxy"):
    rus = ssh.execute('cat /ffs/run/config/FRIps.txt', connection=alias).strip().split('\n')
    logging.debug(f'RU found: {rus}')
    ru_ip = {}
    for ru in rus:
        if ru:
            ru = ru.strip().split(';')
            ru_ip[ru[2]] = ru[-1]
    return ru_ip


def login_to_ru_via_channel(ru_ip, alias="gnb_proxy", user="toor4nsn", password="oZPS0POrRieRtu"):
    def read_buffer():
        buffer = login_channel.recv(65536)
        return buffer.decode("utf-8")

    connection = ssh.get_connection_by_alias(alias)
    login_channel = connection.invoke_shell()
    passwd = None
    if password is not None:
        passwd = ''.join((password, '\n'))
    node = '1'
    login_channel.send('hostname\n')
    time.sleep(1)
    hostname = login_channel.recv(65536)
    if '4a' in str(hostname):
        node = '2'
    login_channel.send('lxc-attach -n 0x{}018\n'.format(node))
    time.sleep(2)
    logging.debug('Logging to Node output: {}'.format(login_channel.recv(65536)))
    if user is None:
        cmd = ''.join(('ssh -o HostKeyAlgorithms=+ssh-rsa ', ru_ip, '\n'))
    else:
        cmd = ''.join(('ssh -o HostKeyAlgorithms=+ssh-rsa ', user, '@', ru_ip, '\n'))
    login_channel.send(cmd)
    time.sleep(6)
    resp = login_channel.recv(65536).decode("utf-8")
    if 'yes/no/[fingerprint]' in str(resp):
        login_channel.send('yes\n')
        resp = login_channel.recv(65536).decode("utf-8")
    logging.debug(f'SSH on RU output: {resp}')
    channel_buffer = resp
    for attempt in range(3):
        if "Password:" in channel_buffer:
            break
        time.sleep(3)
        channel_buffer += read_buffer()
        logging.debug(f"Current console output: {channel_buffer}")
    if "Password:" not in channel_buffer:
        raise BufferError("Password prompt not found")
    channel_buffer = ""
    if passwd is not None:
        login_channel.send(passwd)
        for attempt in range(3):
            if user in channel_buffer:
                break
            time.sleep(3)
            channel_buffer += read_buffer()
            logging.debug(f"Current console output: {channel_buffer}")
    if user not in channel_buffer:
        raise BufferError("User not logged in")
    return login_channel


def execute_command_on_ru(ru_ip, command, alias="gnb_proxy", user="toor4nsn", password="oZPS0POrRieRtu"):
    def trim_output(output):
        output = output.split("\n")
        output = [line.strip() + "\n" for line in output if line]
        output = output[1:-1]
        return "".join(output)

    global channel
    if not channel:
        channel = login_to_ru_via_channel(ru_ip=ru_ip, alias=alias, user=user, password=password)
    try:
        channel.send(command + '\n')
        time.sleep(2)
        response = channel.recv(65536)
        logging.debug(f'Command output: {response}')
        time.sleep(2)
        return trim_output(response.decode("utf-8"))
    except Exception as e:
        logging.debug(f"Error during command execution: {e}")
        channel.close()
        raise


def close_channel_connection():
    global channel
    try:
        if channel:
            channel.close()
        channel = None
    except Exception as e:
        logging.debug(f"Error during channel closing: {e}")
        channel = None
        raise
