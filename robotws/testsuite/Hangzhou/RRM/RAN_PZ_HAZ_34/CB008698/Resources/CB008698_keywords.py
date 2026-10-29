# *-coding=utf-8-*

# Name: Ming Shi
# Time: 2022/6/14 13:40

import taf.transport.ssh as ssh
import re


def get_index_of_min_value(list_name):
    """
    list_name: which need to get index of min value
    """
    return list_name.index(min(list_name))


def get_attached_nr_cell_id_on_ue(host, username, password, sn, alias='cell_pc'):
    """
    get nr cell id via command with PC on ue
    :param host: : pc_ip
    :param username: pc_username
    :param password: pc_password
    :para sn: UEs SN
    """
    try:
        sshconn = ssh.ssh()
        sshconn.connect_to(hostname=host, username=username, password=password, alias=alias)
    except Exception as e:
        print('connection failed: {}'.format(e))
    else:
        sshconn.send_command(
            command='adb -s {} shell dumpsys telephony.registry | grep mServiceState | grep mNci'.format(sn),
            connection=alias)
        service_state = sshconn.read_output(connection=alias)
        pattern = r'mNci = \d+'
        print(service_state)
        match_result = re.findall(pattern=pattern, string=service_state)[0]
        nr_cell_info_on_ue = match_result.split('=')[1].strip()
        print(nr_cell_info_on_ue)
    finally:
        try:
            sshconn.disconnect(connection=alias)
        except UnboundLocalError:
            print('close failed')
    return nr_cell_info_on_ue


def get_released_5qi_drb_qosflow(required_mapping_list, arppriority, number=1):
    """
    get new list after 5qi, drb and qosflow release
    :param required_mapping_list: : 5QI/drb/qosflow list
    :param arppriority: arp priority
    :param number: released 5qi/drb/qos number
    :return reserved_list
    :return reserved_arppriority
    :return released_list
    :return release_arppriority
    """
    original_required_mapping_list = required_mapping_list[:]
    original_arppriority = arppriority[:]
    arppriority_sorted = sorted(arppriority, reverse=True)
    for i in range(number):
        required_mapping_list[arppriority.index(arppriority_sorted[i])] = 'need_release'
        arppriority[arppriority.index(arppriority_sorted[i])] = 'need_release'
    reserved_list = [item for item in required_mapping_list if item != 'need_release']
    reserved_arppriority = [item for item in arppriority if item != 'need_release']
    released_list = [x for x in original_required_mapping_list if x not in reserved_list]
    release_arppriority = [i for i in original_arppriority if i not in reserved_arppriority]
    return reserved_list, reserved_arppriority, released_list, release_arppriority


def get_corresponding_mo_id(parameter_list, distname_id):
    """
    get corresponding mo id from coam.get_managed_objects, which index is required to get
    parameter_list =
    [{'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-37/SCF-1/MRBTS_A-38211/NRBTS_A-38211/NRCELL_A-2'},
    {'distName': '/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-37/SCF-1/MRBTS_A-38211/NRBTS_A-38211/NRCELL_A-1'}]
    :param parameter_list: mo_list from coam.get_managed_objects
    :param distname_id: which index is required to get
    """
    for i, j in enumerate(parameter_list):
        if int(parameter_list[i].get('distName').split('/')[-1][-1]) == int(distname_id):
            mo_id = i
    return mo_id


def find_string(pattern, string):
    match_sting = re.findall(pattern=pattern, string=string)
    return match_sting
