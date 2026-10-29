"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska, Beata Kapusta
:maintainer:  Adrianna Pienkowska, Beata Kapusta
:contact: adrianna.pienkowska@nokia.com, beata.kapusta@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""

from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console
from testsuite.Paris.RRM.ET.resources_KRK.python.file_management import download_files_from
from testsuite.Paris.RRM.ET.resources_KRK.python.shell_management import (
    shell_session_vdu, go_to_the_container, get_vdu_namespace, get_vdu_connection_params, go_to_the_pod)


def get_bip_port(handler, port_name='BIP'):
    """
    Gets bip port by port name

    :param handler: shell session
    :param port_name: name of port to collect BIP logs on
    :return: shout
    """
    shin, shout, sherr = handler.execute(cmd='hal-cli show port table')
    if not sherr:
        for bip_line in shout:
            if port_name in bip_line:
                bip_line = bip_line.split()
                print(bip_line[0])
                return bip_line[0]
        return shout


def start_collecting_aic_bip_logs(method='pdump', port_name='BIP', collect_from_container=True):
    """
    Starts collecting AIC bip logs

    :param method: method of collecting bip logs
    :param port_name: name of port to collect BIP logs on
    :param collect_from_container: flag checking if container or pod should be used
    :return: nothing
    """
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        if collect_from_container:
            go_to_the_container(handler, container, 'l2rt', 'l2rt-a-0')
        else:
            go_to_the_pod(handler, container, 'l2rt-a-0')
        bip_port = get_bip_port(handler, port_name)
        shin, shout, sherr = handler.execute(cmd='hal-cli {} port {}&'.format(method, bip_port))


def stop_collecting_aic_bip(collect_from_container=True):
    """
    Stops collecting AIC bip logs

    :return: nothing
    """
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        if collect_from_container:
            go_to_the_container(handler, container, 'l2rt', 'l2rt-a-0')
        else:
            go_to_the_pod(handler, container, 'l2rt-a-0')
        handler.execute(cmd='pkill pdump')


def collect_logs_from_container(files):
    """
    Collects logs from container

    :param: files(list) list of file names in /tmp
    :return: nothing
    """
    cmd = 'kubectl cp ute-{con}-l2rt-a-0:/tmp/{f} {f} -c ctr-{con}-l2rt -n {con}'
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        for file in files:
            handler.execute(cmd=cmd.format(con=container, f=file))


def collect_bip_logs_from_vdu(files=None, local_path='/home/ute/'):
    """
    Collects bip logs from vDU

    :param files: a list of paths on remote to files which should be copied
    :param local_path: a path to which files should be copied
    :return: nothing
    """
    vdu_ip, vdu_user, vdu_pass = get_vdu_connection_params()
    files = ['l1bipl1.pcap'] if files is None else files
    files = [files] if type(files) is str else files
    collect_logs_from_container(files)
    download_files_from(vdu_ip, vdu_user, vdu_pass, files, local_path)
