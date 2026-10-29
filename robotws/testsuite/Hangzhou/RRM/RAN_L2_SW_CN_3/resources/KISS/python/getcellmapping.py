# -*- encoding: utf-8 -*-
import os
import sys
import subprocess as sp
import pkg_resources
sic_path = '{}/'.format(pkg_resources.resource_filename(__name__, "tools"))


def rt2_print_cell_core_id():
    sic_name = 'onlineTtiStream'
    # sic_path =os.path.split(os.path.realpath(__file__))[0]
    sic_name_path = os.path.join(sic_path, sic_name)
    command = 'cd %s;chmod +x onlineTtiStream' % sic_path
    display_cmd = "%s -f " % (sic_name_path)
    if os.path.isfile(sic_name_path) is None:
        print("'%s'file is not found" % sic_name)
    else:
        os.system(command)
        process_obj = sp.Popen(display_cmd, stdin=sp.PIPE, stdout=sp.PIPE, shell=True)
        value_list = []
        for line in process_obj.stdout.readlines():
            tmp = line.split()
            if len(tmp) > 8:
                value_list.append(tmp)
        return value_list


def _RT2_read_cell_core_id(cell, direction):
    value_list = rt2_print_cell_core_id()
    # print value_list
    macultti = 'MACULTTI'
    macdltti = 'MACDLTTI'
    cell_id = 'lnCel'
    cell_id_position = value_list[0].index(cell_id)
    macdltti_position = value_list[0].index(macdltti)
    macultti_position = value_list[0].index(macultti)
    mac_ul_address_list = []
    for i in range(1, len(value_list)):
        value = value_list[i]
        mac_ul_temp = value[macultti_position][2:6]
        mac_ul_address_list.append(mac_ul_temp)
    mac_address_dict = {}
    for i in range(1, len(value_list)):
        value = value_list[i]
        mac_ul = value[macultti_position][2:]
        mac_dl = value[macdltti_position][2:]
        lncel = value[cell_id_position]
        mac_address_dict['%s' % (i)] = [lncel, mac_dl, mac_ul]
    if direction == 'UL':
        return mac_address_dict[cell][2]
    elif direction == 'DL':
        return mac_address_dict[cell][1]
    else:
        return mac_address_dict[cell]


def RT2_read_cell_core_id(cell, direction):
    from ttitrace_control import get_mac_tti_address
    core = get_mac_tti_address(cell=cell, node_type=direction)
    return core


def RT2_get_cell_core_id(cell, direction):
    if os.path.isfile('onlineTtiStream') is None:
        print("onlineTtiStream file is not found,please add it")
    result = RT2_read_cell_core_id(cell, direction)
    return result


if __name__ == '__main__':
    RT2_get_cell_core_id(sys.argv[1], sys.argv[2])
