"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.file_management import download_files_from
from testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.shell_management import (
    shell_session_vdu, go_to_the_container, get_vdu_namespace)


def get_bip_port(handler):
    """Gets bip port

    :param handler: shell session
    :return: shout
    """
    shin, shout, sherr = handler.execute(cmd='dpdk-cli show port table')
    if not sherr:
        for bip_line in shout:
            if 'BIP' in bip_line:
                bip_line = bip_line.split()
                print(bip_line[0])
                return bip_line[0]
        return shout


def start_collecting_aic_bip_logs(method='pdump'):
    """
    Starts collecting AIC bip logs

    :param method: method of collecting bip logs
    :return: nothing
    """
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        go_to_the_container(handler, container, 'l1hi', 'up-0')
        bip_port = get_bip_port(handler)
        shin, shout, sherr = handler.execute(cmd='dpdk-cli {} port {}&'.format(method, bip_port))


def stop_collecting_aic_bip():
    """
    Stops collecting AIC bip logs

    :return: nothing
    """
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        go_to_the_container(handler, container, 'l1hi', 'up-0')
        handler.execute(cmd='pkill pdump')


def collect_logs_from_container():
    """
    Collects logs from container

    :return: nothing
    """
    cmd = 'kubectl cp ute-{con}-up-0:/tmp/l1bipl1.pcap l1bipl1.pcap -c ctr-{con}-l1hi -n {con}'
    with shell_session_vdu() as handler:
        container = get_vdu_namespace()
        handler.execute(cmd=cmd.format(con=container))


def collect_bip_logs_from_vdu(files=None, local_path='/home/ute/'):
    """
    Collects bip logs from vDU

    :param files: a list of paths on remote to files which should be copied
    :param local_path: a path to which files should be copied
    :return: nothing
    """
    if files is None:
        files = ['l1bipl1.pcap']
    collect_logs_from_container()
    download_files_from('192.168.2.124', 'core', 'system123', files, local_path)
