# -*- coding: utf-8 -*-
"""
Author:         Ding Binmei
Contact Mail:   binmei.ding@nokia-sbell.com
Description:    Functions based on taf.gnb.oam.coam.cu

"""
from taf.gnb.oam.coam.cu import cu

cu = cu()


def get_all_vms_info(connection):
    """
    Author: Ding Binmei
    :param connection: connection alias to cu via ssl
    :return: dict with vm name as key. Example output:
            {'CPCL': {'alarms': [], 'availability_status': 'on line', XXXX},
            'CPIF': {'alarms': [], 'availability_status': 'on line', XXXX},...}
    """
    all_vms_info = cu.get_vms(connection=connection)
    dict_vm_info = {}
    for vm_info in all_vms_info:
        vm_name = vm_info['hostname'].upper().split('-')[-2]
        dict_vm_info[vm_name] = vm_info
    return dict_vm_info
