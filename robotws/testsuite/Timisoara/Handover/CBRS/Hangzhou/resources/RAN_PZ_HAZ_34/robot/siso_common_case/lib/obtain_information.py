# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com

for ue information in __init__.py file such as commissionings/TSR/7_5_UTE5G402T593/__init__.py
content:
__all__ = ['mappings']

# 5G
ue_mapping_1 = {
    'mobile_network_system': 'NR'    # optional, if not exist, will be NR
    'ue_index': 0,  # ue index in TL    # mandatory
    'network_type': 'SA',    # mandatory, for NR
    'cell_id_list': [1],    # mandatory
    'ue_ue_layer': 4,    # optional, for NR
    'ue_ul_layer': 2,    # optional, for NR
    'protocol': 'tcp',    # optional
    'ui_version': 'default',    # optional
    'iperf_type': 'via_app',    # optional
    'peak_percent': 0.9,    # optional, tput will be peak * peak_percent
    'cell_pci': 82,    # optional
    'arfcn': 630720,    # optional
    'ul_iperf_process': 5,    # optional
}

# LTE
ue_mapping_2 = {
    'mobile_network_system': 'LTE'    # optional, if not exist, will be NR
    'ue_index': 1,  # ue index in TL    # mandatory
    'cell_id_list': [2],    # mandatory
    'protocol': 'udp',    # optional
    'ui_version': 'default',    # optional
    'iperf_type': 'via_app',    # optional
    'peak_percent': 1,    # optional, tput will be peak * peak_percent
    'cell_pci':93,    # optional
    'arfcn': 42990,    # optional
    'ul_iperf_process': 1,    # optional
}

# phase_setting
mcs_mapping_1 = {
    'mcs_file_name': 'MCS_DEFAULT.csv',
    'set_type': 'phases_setting',
    'matrix_id': 1,
    'output_id_list': list(range(9, 17)),
    'input_id_list': list(range(1, 32)),
}

# angles_setting
mcs_mapping_1 = {
    'mcs_file_name': 'MCS_DEFAULT.csv',
    'set_type': 'angles_setting',
    'matrix_id': 1,
    'output_group_id_list': list(range(9, 17)),
    'input_group_id_list': list(range(1, 17)),
    'horizontal_distance': 0.5,
    'vertical_distance': 4.04,
}

mappings = [
    {
        'scf_name': 'SCF_SBTS00_1S-1CC-8D-4U.xml',  # * means all scf common
        'ue_mapping_list': [ue_mapping_1, ue_mapping_2],
        'mcs_mapping': mcs_mapping_1,
    }
]

"""
import attr
import fnmatch
from typing import Optional
import importlib
import logging

__all__ = ['get_ue_details_from_ue_mapping_file', 'get_all_cell_id_list_from_ue_mapping_file',
           'get_protocol_from_ue_mapping_file', 'get_ue_network_type_from_ue_mapping_file',
           'get_ue_ul_layer_from_ue_mapping_file', 'get_tput_ue_num_from_ue_mapping_file',
           'get_ue_network_type_from_ue_mapping_file', 'get_iperf_type_from_ue_mapping_file',
           'get_ui_version_from_ue_mapping_file', 'get_ue_peak_percent_from_ue_mapping_file',
           'get_ue_for_cell_with_condition_from_ue_mapping_file', 'get_pci_from_ue_mapping_file',
           'get_arfcn_from_ue_mapping_file', 'get_ul_iperf_process_from_ue_mapping_file',
           'get_dl_iperf_process_from_ue_mapping_file', 'get_ue_dl_layer_from_ue_mapping_file',
           'get_cell_id_list_from_ue_mapping_file', 'get_cell_pa_values', 'get_cell_pa_ports',
           'get_mcs_mapping', 'get_band_from_ue_mapping_file', 'get_scs_from_ue_mapping_file']


@attr.s(cmp=False)
class UeInfo(object):
    ue_index = attr.ib(type=int)
    mobile_network_system = attr.ib(type=Optional[str], default='NR')
    cell_id_list = attr.ib(type=Optional[list], default=[1])
    protocol = attr.ib(type=Optional[str], default='udp')
    peak_percent = attr.ib(type=Optional[int], default=1)
    cell_pci = attr.ib(type=Optional[int], default=0)
    arfcn = attr.ib(type=Optional[int], default=0)
    cell_band = attr.ib(type=Optional[str], default=None)
    scs = attr.ib(type=Optional[int], default=0)
    ui_version = attr.ib(type=Optional[str], default='default')
    iperf_type = attr.ib(type=Optional[str], default='via_app')
    ul_iperf_process = attr.ib(type=Optional[int], default=1)
    dl_iperf_process = attr.ib(type=Optional[int], default=1)


@attr.s(cmp=False)
class LTEUeInfo(UeInfo):
    pass


@attr.s(cmp=False)
class NRUeInfo(UeInfo):
    network_type = attr.ib(type=Optional[str], default='BOTH')
    ue_dl_layer = attr.ib(type=Optional[int], default=4)
    ue_ul_layer = attr.ib(type=Optional[int], default=1)


class ObtainInformation(object):
    def __init__(self, testline_name):
        self.testline_name = testline_name
        self.lib = 'commissionings.TSR.' + self.testline_name

    def import_lib(self):
        import_lib = importlib.import_module(self.lib)
        return import_lib


def _get_ue_mapping_list(testline_name, scf_name=None):
    object = ObtainInformation(testline_name=testline_name)
    import_lib = object.import_lib()
    mappings = import_lib.mappings
    for mapping in mappings:
        if mapping['scf_name'] == scf_name:
            return mapping['ue_mapping_list']
    for mapping in mappings:
        pattern = mapping['scf_name']
        if scf_name is not None:
            matches_pattern = fnmatch.fnmatch(scf_name, pattern)
            if matches_pattern:
                return mapping['ue_mapping_list']
    for mapping in mappings:
        if mapping['scf_name'] == '*':
            return mapping['ue_mapping_list']


def _get_ue_mapping_dict(testline_name, ue_index=0, mobile_network_system='NR', scf_name=None, **kwargs):
    ue_mapping_list = _get_ue_mapping_list(testline_name=testline_name, scf_name=scf_name)
    ue_mapping_dict = {}
    get_mapping_dict = {}
    for ue_mapping in ue_mapping_list:
        logging.debug("-------ue_mapping:{}------".format(ue_mapping))
        if ue_mapping['ue_index'] == ue_index:
            get_mapping_dict = ue_mapping
            break
    logging.debug("get_mapping_dict:{}".format(get_mapping_dict))
    if len(get_mapping_dict) == 0:
        return ue_mapping_dict
    object_mapping_dict = get_mapping_dict.copy()
    get_mobile_network_system = object_mapping_dict.get('mobile_network_system')
    get_mobile_network_system = get_mobile_network_system if get_mobile_network_system else mobile_network_system
    logging.debug("get_mobile_network_system:{}".format(get_mobile_network_system))
    object_mapping_dict['mobile_network_system'] = get_mobile_network_system
    del object_mapping_dict['ue_index']
    for key, value in kwargs.items():
        if key in ['protocol', 'iperf_type', 'ui_version'] and key not in object_mapping_dict.keys():
            object_mapping_dict[key] = value
    logging.debug("mobile_network_system:{},object_mapping_dict:{}".format(mobile_network_system, object_mapping_dict))
    if mobile_network_system == 'LTE' and object_mapping_dict['mobile_network_system'] == 'LTE':
        ue = LTEUeInfo(ue_index=ue_index, **object_mapping_dict)
        ue_mapping_dict = ue.__dict__
    elif mobile_network_system == 'NR' and object_mapping_dict['mobile_network_system'] == 'NR':
        ue = NRUeInfo(ue_index=ue_index, **object_mapping_dict)
        ue_mapping_dict = ue.__dict__
    return ue_mapping_dict


def get_ue_details_from_ue_mapping_file(testline_name, ue_index=0, mobile_network_system='NR',
                                        protocol='udp', iperf_type='via_app', ui_version='default', scf_name=None):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    # logging.debug("ue_mapping_dict:{}".format(ue_mapping_dict))
    if len(ue_mapping_dict) > 0:
        ue_mapping_dict['protocol'] = get_protocol_from_ue_mapping_file(
            testline_name=testline_name, ue_index=ue_index, scf_name=scf_name, protocol=protocol,
            mobile_network_system=mobile_network_system)
        ue_mapping_dict['iperf_type'] = get_iperf_type_from_ue_mapping_file(
            testline_name=testline_name, ue_index=ue_index, scf_name=scf_name, iperf_type=iperf_type,
            mobile_network_system=mobile_network_system)
        ue_mapping_dict['ui_version'] = get_ui_version_from_ue_mapping_file(
            testline_name=testline_name, ue_index=ue_index, scf_name=scf_name, ui_version=ui_version,
            mobile_network_system=mobile_network_system)
    return ue_mapping_dict


def get_protocol_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, protocol='udp',
                                      mobile_network_system='NR'):
    try:
        object = ObtainInformation(testline_name=testline_name)
        import_lib = object.import_lib()
        protocol = import_lib.protocol
    except Exception:
        print('get variable protocol from commissionings.TSR.{}.__init__.py failed'.format(testline_name))
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           protocol=protocol, mobile_network_system=mobile_network_system)
    protocol = ue_mapping_dict.get('protocol')
    return protocol


def get_iperf_type_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, iperf_type='via_app',
                                        mobile_network_system='NR'):
    try:
        object = ObtainInformation(testline_name=testline_name)
        import_lib = object.import_lib()
        iperf_type = import_lib.iperf_type
    except Exception:
        print('get variable iperf_type from commissionings.TSR.{}.__init__.py failed'.format(testline_name))
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           iperf_type=iperf_type, mobile_network_system=mobile_network_system)
    iperf_type = ue_mapping_dict.get('iperf_type')
    return iperf_type


def get_ui_version_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, ui_version='default',
                                        mobile_network_system='NR'):
    try:
        object = ObtainInformation(testline_name=testline_name)
        import_lib = object.import_lib()
        ui_version = import_lib.ui_version
    except Exception:
        print('get variable ui_version from commissionings.TSR.{}.__init__.py failed'.format(testline_name))
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           ui_version=ui_version, mobile_network_system=mobile_network_system)
    ui_version = ue_mapping_dict.get('ui_version')
    return ui_version


def get_ue_dl_layer_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, ue_dl_layer=4,
                                         mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_ue_dl_layer = ue_mapping_dict.get('ue_dl_layer')
    ue_dl_layer = get_ue_dl_layer if get_ue_dl_layer else ue_dl_layer
    return ue_dl_layer


def get_ue_ul_layer_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, ue_ul_layer=1,
                                         mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_ue_ul_layer = ue_mapping_dict.get('ue_ul_layer')
    ue_ul_layer = get_ue_ul_layer if get_ue_ul_layer else ue_ul_layer
    return ue_ul_layer


def get_ue_network_type_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, network_type='NSA',
                                             mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_network_type = ue_mapping_dict.get('network_type')
    network_type = get_network_type if get_network_type else network_type
    return network_type


def get_ue_peak_percent_from_ue_mapping_file(testline_name, scf_name=None, ue_index=0, peak_percent=1,
                                             mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_peak_percent = ue_mapping_dict.get('peak_percent')
    peak_percent = get_peak_percent if get_peak_percent else peak_percent
    return peak_percent


def get_pci_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, cell_pci=0, mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_cell_pci = ue_mapping_dict.get('cell_pci')
    cell_pci = get_cell_pci if get_cell_pci else cell_pci
    return cell_pci


def get_arfcn_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, arfcn=0, mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_arfcn = ue_mapping_dict.get('arfcn')
    arfcn = get_arfcn if get_arfcn else arfcn
    return arfcn


def get_band_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, cell_band=None, mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_cell_band = ue_mapping_dict.get('cell_band')
    cell_band = get_cell_band if get_cell_band else cell_band
    return cell_band


def get_scs_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, scs=0, mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_scs = ue_mapping_dict.get('scs')
    scs = get_scs if get_scs else scs
    return scs


def get_cell_id_list_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    cell_id_list = ue_mapping_dict.get('cell_id_list')
    return cell_id_list


def get_all_cell_id_list_from_ue_mapping_file(testline_name, scf_name=None):
    ue_mapping_list = _get_ue_mapping_list(testline_name=testline_name, scf_name=scf_name)
    cell_id_list = []
    for ue_mapping in ue_mapping_list:
        for cell in ue_mapping['cell_id_list']:
            if cell not in cell_id_list:
                cell_id_list.append(cell)
    return cell_id_list


def get_ul_iperf_process_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, ul_iperf_process=1,
                                              mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_ul_iperf_process = ue_mapping_dict.get('ul_iperf_process')
    ul_iperf_process = get_ul_iperf_process if get_ul_iperf_process else ul_iperf_process
    return ul_iperf_process


def get_dl_iperf_process_from_ue_mapping_file(testline_name, ue_index=0, scf_name=None, dl_iperf_process=1,
                                              mobile_network_system='NR'):
    ue_mapping_dict = _get_ue_mapping_dict(testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
                                           mobile_network_system=mobile_network_system)
    get_dl_iperf_process = ue_mapping_dict.get('dl_iperf_process')
    dl_iperf_process = get_dl_iperf_process if get_dl_iperf_process else dl_iperf_process
    return dl_iperf_process


def get_tput_ue_num_from_ue_mapping_file(testline_name, scf_name=None):
    ue_mapping_list = _get_ue_mapping_list(testline_name=testline_name, scf_name=scf_name)
    ue_num = len(ue_mapping_list)
    return ue_num


def get_ue_for_cell_with_condition_from_ue_mapping_file(testline_name, cell_id, ue_num=1, scf_name=None,
                                                        mobile_network_system='NR', ext_ue_index_ist=None,
                                                        network_type='SA', **kwargs):
    ue_index_list = []
    ext_ue_index_ist = [] if ext_ue_index_ist is None else ext_ue_index_ist
    ue_mapping_list = _get_ue_mapping_list(testline_name=testline_name, scf_name=scf_name)
    for ue_mapping in ue_mapping_list:
        logging.debug("--------------------------------ue_mapping:{}".format(ue_mapping))
        ue_index = ue_mapping['ue_index']
        if ue_index in ext_ue_index_ist:
            continue
        ue_mapping_dict = get_ue_details_from_ue_mapping_file(
            testline_name=testline_name, ue_index=ue_index, scf_name=scf_name,
            mobile_network_system=mobile_network_system,  **kwargs)
        if len(ue_mapping_dict) == 0:
            continue
        for cell in ue_mapping_dict['cell_id_list']:
            if int(cell) == int(cell_id):
                flag = True
                if mobile_network_system == 'NR':
                    if ue_mapping_dict['network_type'] != network_type and ue_mapping_dict['network_type'] != 'BOTH':
                        flag = False
                for key, value in kwargs.items():
                    if ue_mapping_dict[key] != value:
                        flag = False
                if flag:
                    ue_index_list.append(ue_index)
                if len(ue_index_list) == int(ue_num):
                    return ue_index_list
    return ue_index_list


def get_cell_pa_values(testline_name, cell_id=1, scf_name=None):
    flag = 0
    object = ObtainInformation(testline_name=testline_name)
    import_lib = object.import_lib()
    pa_infos = import_lib.pa_info
    for item in pa_infos:
        if item['scf_name'] == scf_name:
            flag = 1
            break
    if flag == 1:
        return item['cells_pa_values'][cell_id]
    else:
        for item in pa_infos:
            if item['scf_name'] == '*':
                break
        return item['cells_pa_values'][cell_id]


def get_cell_pa_ports(testline_name, cell_id=1, scf_name=None):
    flag = 0
    object = ObtainInformation(testline_name=testline_name)
    import_lib = object.import_lib()
    pa_infos = import_lib.pa_info
    for item in pa_infos:
        if item['scf_name'] == scf_name:
            flag = 1
            break
    if flag == 1:
        if cell_id in item['cells_pa_ports']:
            return item['cells_pa_ports'][cell_id]
        else:
            return []
    else:
        for item in pa_infos:
            if item['scf_name'] == '*':
                break
        if cell_id in item['cells_pa_ports']:
            return item['cells_pa_ports'][cell_id]
        else:
            return []


def get_mcs_mapping(testline_name, scf_name=None):
    object = ObtainInformation(testline_name=testline_name)
    import_lib = object.import_lib()
    mappings = import_lib.mappings
    for mapping in mappings:
        if mapping['scf_name'] == scf_name:
            return mapping['mcs_mapping']
    for mapping in mappings:
        pattern = mapping['scf_name']
        if scf_name is not None:
            matches_pattern = fnmatch.fnmatch(scf_name, pattern)
            if matches_pattern:
                return mapping['mcs_mapping']
    for mapping in mappings:
        if mapping['scf_name'] == '*':
            return mapping['mcs_mapping']
