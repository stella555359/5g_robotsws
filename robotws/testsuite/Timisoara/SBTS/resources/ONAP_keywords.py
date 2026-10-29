"""
JSON editor. Replaces placeholders with provided MRBTSID, NRBTSID  and Ves Node IP address.
Needs base JSON file with placeholders in the value or Object DistNames:
"distName": "MRBTS-BTS_ID/MNL-1/CERTH-1/CMP-1"
"distName": "MRBTS-BTS_ID/NRBTS-NR_ID"
"value": "VES_ADD"
from taf.transport.ssh.ssh_keywords import SSHManager
from taf.gnb.oam.megazone_client.interface import megazone_client
from taf.sbts.oam.coam.admin.interface import admin
from taf.internal.aliasing.exceptions import AliasLookupError
import logging
"""
import pysftp


def check_sftp_for_pms(mplane_add, pm_to_download):
    cnopts = pysftp.CnOpts()
    cnopts.hostkeys = None
    with pysftp.Connection(mplane_add, username='toor4nsn', password='oZPS0POrRieRtu', cnopts=cnopts) as sftp:
        with sftp.cd('/ram'):
            sftp.get(pm_to_download)  # get PM


def edit_json(base_json, output_json, bts_id, ipif_id, worker_ip, ves_port):
    """
    :param base_json:   eg. /testsuite/Wroclaw/OAM/cOAM1/5GC001104/resources/deltaIPv6.json
    :param output_json: eg. /testsuite/Wroclaw/OAM/cOAM1/5GC001104/resources/ready_delta.json
    :param bts_id:      eg. 50357
    :param nrbts_id:    eg. 50357
    :param worker_ip:   eg. 2a00:8a00:6000:607c::1:b62c
    :param ipif_id:     eg. 5
    :return: None. Saves output_json in the provided path
    """

    output = open(output_json, "w+")
    with open(base_json, 'r+') as delta:
        content = delta.read()
        delta.seek(0)
        content = content.replace('BTS_ID', str(bts_id))
        content = content.replace('VES_ADD', str(worker_ip))
        content = content.replace('IPIF_ID', str(ipif_id))
        content = content.replace('VES_PORT', str(ves_port))
        output.write(content)
    output.close()


def get_pms_bts(last_pm_on_bts):
    result = last_pm_on_bts.split()
    name = result[-1][:-3]
    return name
