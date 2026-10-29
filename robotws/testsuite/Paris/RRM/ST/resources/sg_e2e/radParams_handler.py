#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
Helpful library to set rad parameters using AaShell
"""

import telnetlib
from contextlib import contextmanager
import logging
from time import sleep
from six import string_types  # str/unicode string type.
from paramiko import (
    SSHClient,
    MissingHostKeyPolicy,
)


@contextmanager
def make_connexion(ssh_user, ssh_password, ssh_host, ssh_port, dst_ip, dst_port):
    ''' this function create a tunnelling ssh connexion'''
    client = SSHClient()
    client.set_missing_host_key_policy(MissingHostKeyPolicy())
    client.connect(hostname=ssh_host, username=ssh_user, password=ssh_password, port=ssh_port)
    transport = client.get_transport()
    _connexion = transport.open_channel('direct-tcpip', (dst_ip, dst_port), ('127.0.0.1', 0))
    yield _connexion
    _connexion.close()
    client.close()


def set_rad_flags(sequence, ssh_host='192.168.255.1', dst_port=15007, ssh_user='toor4nsn',
                  ssh_password='oZPS0POrRieRtu', timeout=5, retry=3, persistently=False):
    """
    :type rad_flags: dictionnary of rad parameters exp: {'0x5800c7': '1'}
    """
    _UNTIL_FLAG = b"AaShell>"
    _ENTER_FLAG = b"\r\n"
    if isinstance(sequence, dict):
        rad_flags = sequence
    else:
        rad_flags = sequence_to_dictionary(sequence, e_sep=' ', v_sep="=")

    if not bool(rad_flags):
        logging.info("Error occured no rad param found in {}".format(sequence))
        return
    try:
        with make_connexion(ssh_user=ssh_user, ssh_password=ssh_password,
                            ssh_host=ssh_host, ssh_port=22, dst_ip='localhost', dst_port=dst_port) as channel:
            tn = telnetlib.Telnet()
            tn.sock = channel
            for rad_flag, value in rad_flags.items():
                tn.read_until(_UNTIL_FLAG, timeout=timeout)
                if persistently:
                    command = 'rad -mwp {} {}'.format(rad_flag, value)
                else:
                    command = 'rad -mw {} {}'.format(rad_flag, value)
                while retry:
                    tn.write(command.encode("ascii") + _ENTER_FLAG)
                    sleep(3)
                    command_result = tn.read_until(
                        _UNTIL_FLAG, timeout=timeout
                    ).decode("ascii")
                    logging.info('command: {} >> \nresult: {}'.format(command, command_result))
                    if 'written succesfully' in command_result:
                        break
                    retry = retry - 1
                else:
                    logging.info("Error occured rad param value is not set for {}".format(rad_flag))
    except Exception as e:
        logging.info('Error occurred:', e)
    finally:
        pass


def reset_rad_params_to_factory_default(ssh_host='192.168.255.1', dst_port=15007, ssh_user='toor4nsn',
                                        ssh_password='oZPS0POrRieRtu', timeout=5, retry=3):
    """
    Restore R&D parameters to factory default values
    """
    _UNTIL_FLAG = b"AaShell>"
    _ENTER_FLAG = b"\r\n"
    try:
        with make_connexion(ssh_user=ssh_user, ssh_password=ssh_password,
                            ssh_host=ssh_host, ssh_port=22, dst_ip='localhost', dst_port=dst_port) as channel:
            tn = telnetlib.Telnet()
            tn.sock = channel
            tn.read_until(_UNTIL_FLAG, timeout=timeout)
            command = 'rad -f'
            while retry:
                tn.write(command.encode("ascii") + _ENTER_FLAG)
                sleep(3)
                command_result = tn.read_until(
                    _UNTIL_FLAG, timeout=timeout
                ).decode("ascii")
                logging.info('command: {} >> \nresult: {}'.format(command, command_result))
                if 'Restoring parameters done succesfully' in command_result:
                    break
                retry = retry - 1
            else:
                logging.info("an error occured on setting R&D parameters to factory default values")
    except Exception as e:
        logging.info('Error occurred:', e)
    finally:
        pass


def sequence_to_dictionary(sequence, e_sep=' ', v_sep="="):
    """
    this function return dictionnary from formatted string/list sequence.
    :param sequence:  formatted string exp: "0x5800C7=1 0x5800DF=0"
    :param e_sep: element separator exp: " "
    :param v_sep: value separator exp : "="
    :return: dictionnary result exp: "{'0x5800C7':'1' '0x5800DF':'0'}"
    """
    result = {}
    if isinstance(sequence, list):
        for e in sequence:
            x = e.split(v_sep)
            result.update({x[0]: x[1]})
    elif isinstance(sequence, string_types):
        for e in sequence.split(e_sep):
            x = e.split(v_sep)
            if len(x) > 1:
                result.update({x[0]: x[1]})
    return result
