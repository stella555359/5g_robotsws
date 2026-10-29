import csv
import os.path
import re
import json
import random
import math
import logging
# import pandas as pd
# import PySimpleGUI as sg
from collections import Counter
from statistics import mean
from taf.sbts.oam.coam.admin import admin
from taf.config.scf import scf
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from json.decoder import JSONDecodeError
from openpyxl import Workbook
from openpyxl.chart import LineChart, BarChart, Reference

try:
    import matplotlib.pyplot as plt
except ImportError:
    pass
    # TODO fix because tmp for pipelines
    # os.system('pip install matplotlib')
    # import matplotlib.pyplot as plt


scf = scf()
coam = admin()
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')


def extract_ull1sp_from_syslog(syslogextract):
    return extract_l1sp_from_syslog(syslogextract, 'ul')


def extract_dll1sp_from_syslog_one_cell(syslogextract):
    return extract_l1sp_from_syslog_one_cell(syslogextract, 'dl')


def extract_ull1sp_from_syslog_one_cell(syslogextract):
    return extract_l1sp_from_syslog_one_cell(syslogextract, 'ul')


def extract_dll1sp_from_syslog(syslogextract):
    return extract_l1sp_from_syslog(syslogextract, 'dl')


def extract_l1sp_from_syslog_onel1p(syslogextract, direction):
    nrcellIds = get_nrcellIds(None)
    print('nrCellIds: {}'.format(nrcellIds))
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'transactionId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print(last_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    # pattern = r'\{.*?\"CellMappingList\":.*?\"cellIndex\":.*?\}\]\}'

    matches = re.findall(pattern, syslogextract_flt)
    l1p = []
    l1sp = []
    sp0 = []
    sp1 = []
    # Select l1pool with pooling (> 1 Sp)
    for msg in matches:
        # print('msg:')
        # print(msg)
        data = json.loads(msg)
        print(data)
        l1pool = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1PoolId']
        l1subpool = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1SubpoolId']
        if l1subpool != 0:
            l1p_with_pooling = l1pool
            break
    try:
        l1p_with_pooling
    except NameError:
        l1p_with_pooling = l1pool
    for msg in matches:
        # print(msg)
        data = json.loads(msg)
        # print(data)
        cellL1p = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1PoolId']
        l1sp_per_cell = [data['CellMappingList'][0]['nrCellIdentity'],
                         data['CellMappingList'][0][direction + 'SubcellList'][0]['l1SubpoolId']]
        if cellL1p == l1p_with_pooling and l1sp_per_cell not in l1sp:
            l1sp.append(l1sp_per_cell)
    # mincellidentity = min([int(x[0]) for x in l1sp])
    minspidentity = min([int(x[1]) for x in l1sp])
    for element in l1sp:
        print(element)
        if int(element[1]) == minspidentity:
            # sp0.append(int(element[0]) - mincellidentity)
            sp0.append([d['lcrId'] for d in nrcellIds if d['nrCellIdentity'] == element[0]][0])
        else:
            sp1.append([d['lcrId'] for d in nrcellIds if d['nrCellIdentity'] == element[0]][0])
    # if len(sp0) >= len(sp1):
    return [sorted(sp0), sorted(sp1)]
    # else:
    #     return [sorted(sp1), sorted(sp0)]


def extract_l1sp_from_syslog(syslogextract, direction):
    nrcellIds = get_nrcellIds(None)
    print('nrCellIds: {}'.format(nrcellIds))
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'transactionId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print(last_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    l1pools = {}
    l1sp = []
    # Select l1pool with pooling (> 1 Sp)
    for msg in matches:
        data = json.loads(msg)
        cellL1p = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1PoolId']
        l1sp_per_cell = [data['CellMappingList'][0]['nrCellIdentity'],
                         data['CellMappingList'][0][direction + 'SubcellList'][0]['l1SubpoolId'],
                         data['CellMappingList'][0][direction + 'SubcellList'][0]['l1PoolId']]
        print('l1sp_per_cell: {}'.format(l1sp_per_cell))
        # Initialize the list of 3-element lists
        if l1sp_per_cell not in l1sp:
            l1sp.append(l1sp_per_cell)
    grouped = {}
    for element in l1sp:
        cell, subpool, pool = element
        if pool not in grouped:
            grouped[pool] = {}
        if subpool not in grouped[pool]:
            grouped[pool][subpool] = []
        grouped[pool][subpool].append([d['lcrId'] for d in nrcellIds if d['nrCellIdentity'] == cell][0])

        # Convert the dictionary values to a nested list
        l1pools = [[sorted(grouped[pool][subpool]) for subpool in sorted(grouped[pool])] for pool in sorted(grouped)]
        l1pools.sort(key=lambda x: x[0][0])

        print('l1pools: {}'.format(l1pools))

    return l1pools[0] if len(l1pools) == 1 else l1pools


def extract_l1sp_from_syslog_one_cell(syslogextract, direction):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'transactionId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print(last_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    # pattern = r'\{.*?\"CellMappingList\":.*?\"cellIndex\":.*?\}\]\}'

    matches = re.findall(pattern, syslogextract_flt)
    l1p = []
    l1sp = []
    sp0 = []
    sp1 = []
    # Select l1pool with pooling (> 1 Sp)
    for msg in matches:
        # print('msg:')
        # print(msg)
        data = json.loads(msg)
        # print(data)
        l1pool = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1PoolId']
        l1subpool = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1SubpoolId']
        if l1subpool != 0:
            l1p_with_pooling = l1pool
            break
    try:
        l1p_with_pooling
    except NameError:
        l1p_with_pooling = l1pool
    for msg in matches:
        # print(msg)
        data = json.loads(msg)
        print("data:")
        print(data)
        cellL1p = data['CellMappingList'][0][direction + 'SubcellList'][0]['l1PoolId']
        l1sp_per_cell = [data['CellMappingList'][0]['nrCellIdentity'],
                         data['CellMappingList'][0][direction + 'SubcellList'][0]['l1SubpoolId']]
        print("celll1p: {}".format(cellL1p))
        print("l1sp_per_cell: {}".format(l1sp_per_cell))
        print("l1p_with_pooling: {}".format(l1p_with_pooling))
        print("l1sp: {}".format(l1sp))
        if cellL1p == l1p_with_pooling and l1sp_per_cell not in l1sp:
            l1sp.append(l1sp_per_cell)

    return l1sp


def extract_csirsPoolingGroupId_from_syslog(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print('last item: {}'.format(last_item))
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    csirsgroups = []
    for msg in matches:
        # print('msg: {}'.format(msg))
        try:
            data = json.loads(msg)
        except Exception as e:
            return []
        # print(data)
        try:
            csirsgroup_per_cell = {'cell': data['nrCellIdentity'],
                                   'csirsPoolingGroupId': data['bbPoolingInfoCell']['csirsPoolingGroupId']}
            if csirsgroup_per_cell not in csirsgroups:
                csirsgroups.append(csirsgroup_per_cell)
        except TypeError:
            pass

    sorted_csirs = sorted(csirsgroups, key=lambda p: p['cell'])

    return sorted_csirs


def extract_csirsPoolingGroupId_from_syslog_v2(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    csirsgroups = []
    for msg in matches:
        # print('msg: {}'.format(msg))
        try:
            data = json.loads(msg)
        except Exception as e:
            return []
        # print(data)
        try:
            csirsgroup_per_cell = {'cell': data['nrCellIdentity'],
                                   'csirsPoolingGroupId': data['bbPoolingInfoCell']['csirsPoolingGroupId'],
                                   'lcrId': data['lcrId']}
            if csirsgroup_per_cell not in csirsgroups:
                csirsgroups.append(csirsgroup_per_cell)
        except TypeError:
            pass

    sorted_csirs = sorted(csirsgroups, key=lambda p: p['cell'])

    return sorted_csirs


def extract_nrCellGrpId_from_syslog(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    # pattern = r'\{\"nrCellGrpId\":.*?\"slotAggregationConfig\":.*?\}'
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    nrCellGrps = []
    for msg in matches:
        try:
            data = json.loads(msg)
        except Exception as e:
            return []
        nrCellGrp_per_cell = {'cell': data['nrCellIdentity'],
                              'nrCellGrpId': data['nrCellGrpId']}
        if nrCellGrp_per_cell not in nrCellGrps:
            nrCellGrps.append(nrCellGrp_per_cell)

    sorted_nrCellGrps = sorted(nrCellGrps, key=lambda p: p['cell'])

    return sorted_nrCellGrps


def extract_longPucchNumPuschPrb_from_syslog(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    print(syslogextract_flt)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    longPucchNumPuschPrb = []
    for msg in matches:
        data = json.loads(msg)
        longPucchNumPuschPrb_per_cell = {'cell': data['lcrId'],
                                         'longPucchNumPuschPrb':
                                             [item for item in data['cellBwp']['cellBwpList'] if
                                              item.get("bwpType") == "DEDICATED"][0]['uplinkBwp']
                                             ['longPucchNumPuschPrb']}
        if longPucchNumPuschPrb_per_cell not in longPucchNumPuschPrb:
            longPucchNumPuschPrb.append(longPucchNumPuschPrb_per_cell)

    sorted_longPucchNumPuschPrb = [item["longPucchNumPuschPrb"] for item in
                                   sorted(longPucchNumPuschPrb, key=lambda p: p['cell'])]
    return sorted_longPucchNumPuschPrb


def extract_trscsirs_from_syslog(syslogextract, csirsgroups, nrCellGroups):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        # print('data')
        try:
            data = json.loads(msg)
        except Exception as e:
            print("TRS JSON Failed")
            return []
        # print(data)
        try:
            nrCellId = [sub['cell'] for sub in nrCellGroups if sub['nrCellGrpId'] == data['nrCellGrpId']][0]
            csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == nrCellId]
            trscsirs_per_cellgrp = {'csirsPoolingGroupId': csirsgroup[0],
                                    'csirsTrackingResourceSet': data['csirsTrackingResourceSet']}
            if trscsirs_per_cellgrp not in slot_offsets:
                slot_offsets.append(trscsirs_per_cellgrp)
        except IndexError:
            pass
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])

    return sorted_slots


def extract_uecsirs_from_syslog(syslogextract, csirsgroups):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'messageResult'
    last_item = get_last_item(syslogextract_flt, starting_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        # print('data')
        data = json.loads(msg)
        # print(data)
        try:
            csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
            uecsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                                'uecsirs': data['availablePucchAndCsiRsResources']}
            if uecsirs_per_cell not in slot_offsets:
                slot_offsets.append(uecsirs_per_cell)
        except IndexError:
            pass
    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])

    return sorted_slots


def extract_cellcsirs_from_syslog(syslogextract, csirsgroups):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'messageResult'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print('last item: ' + last_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []
    for msg in matches:
        print('msg:')
        print(msg)
        try:
            data = json.loads(msg)
        except Exception as e:
            return []
        # print(data)
        try:
            csirsgroup = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['cell'] == data['nrCellIdentity']]
            # print(csirsgroup)
            cellcsirs_per_cell = {'csirsPoolingGroupId': csirsgroup[0],
                                  'resource_set': data['cellCsiRsTimeDomainAllocation']['resourceSet']}
            try:
                for i in range(len(cellcsirs_per_cell['resource_set'])):
                    cellcsirs_per_cell['resource_set'][i].pop('csiImResSlotOffset')
            except Exception as e:
                pass
            if cellcsirs_per_cell not in slot_offsets:
                slot_offsets.append(cellcsirs_per_cell)
        except (TypeError, IndexError):
            pass

    sorted_slots = sorted(slot_offsets, key=lambda p: p['csirsPoolingGroupId'])

    return sorted_slots


def sort_and_filter(syslogextract):
    syslogextract_lines = re.findall(r".*?\n", syslogextract + '\n')
    syslogtosort = []
    for linhas in syslogextract_lines:
        sorting_key = re.search(r"([0-9]{6}) [0-9]{2}\..*?\[.*?] ([a-z0-9]{2}) FCT", linhas)
        # sorting_key2 = re.search(r"([0-9]{6}) [0-9]{2}\.", linhas)
        syslogtosort.append({'line': linhas, 'key1': int(sorting_key.group(1)) // 100, 'key2': sorting_key.group(2)})
        print("key1: {}".format(int(sorting_key.group(1)) // 100))
        print("key2: {}".format(sorting_key.group(2)))
    sorted_syslogextract = sorted(syslogtosort, key=lambda p: (p['key1'], p['key2']))
    print(sorted_syslogextract)
    for item in sorted_syslogextract:
        print("item: ".format(item['key1']))
    new_syslogextract = ''.join(str(d['line']) for d in sorted_syslogextract)
    new_syslogextract_flt = re.sub(r"\n.*?: ", '', new_syslogextract)

    return new_syslogextract_flt


def extract_numMinPrbAlloc_from_syslog(syslogextract):
    return extract_numMinAlloc_from_syslog('', syslogextract)


def extract_numMinLayerPrbAlloc_from_syslog(syslogextract):
    return extract_numMinAlloc_from_syslog('Layer', syslogextract)


def extract_numMinAlloc_from_syslog(type, syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'nrCellGrpId'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print('last item: {}'.format(last_item))
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'
    matches = re.findall(pattern, syslogextract_flt)
    numMinPrbAllocDl = []
    numMinPrbAllocUl = []
    # print('type: {}'.format(type))
    for msg in matches:
        print("msg: {}".format(msg))
        try:
            data = json.loads(msg)
        except JSONDecodeError:
            data = json.loads(msg + '}')
        print('data: {}'.format(data))
        try:
            numMinPrbAllocDl_per_cell = {'cell': data['nrCellIdentity'],
                                         'numMin' + type + 'PrbAllocDl': data['bbPoolingInfoCell'][
                                             'numMin' + type + 'PrbAllocDl']}
            # print('numMinPrbAllocDl_per_cell: {}'.format(numMinPrbAllocDl_per_cell))
            numMinPrbAllocUl_per_cell = {'cell': data['nrCellIdentity'],
                                         'numMin' + type + 'PrbAllocUl': data['bbPoolingInfoCell'][
                                             'numMin' + type + 'PrbAllocUl']}
            if numMinPrbAllocDl_per_cell not in numMinPrbAllocDl:
                numMinPrbAllocDl.append(numMinPrbAllocDl_per_cell)
            if numMinPrbAllocUl_per_cell not in numMinPrbAllocUl:
                numMinPrbAllocUl.append(numMinPrbAllocUl_per_cell)
        except TypeError:
            pass
    sorted_numMinPrbAllocDl_c = sorted(numMinPrbAllocDl, key=lambda p: p['cell'])
    sorted_numMinPrbAllocUl_c = sorted(numMinPrbAllocUl, key=lambda p: p['cell'])
    # print('sorted_numMinPrbAllocDl_c: {}'.format(sorted_numMinPrbAllocDl_c))
    sorted_numMinPrbAllocDl = [d['numMin' + type + 'PrbAllocDl'] for d in sorted_numMinPrbAllocDl_c]
    # print('sorted_numMinPrbAllocDl: {}'.format(sorted_numMinPrbAllocDl))
    sorted_numMinPrbAllocUl = [d['numMin' + type + 'PrbAllocUl'] for d in sorted_numMinPrbAllocUl_c]
    return sorted_numMinPrbAllocDl, sorted_numMinPrbAllocUl


def list_json_elements(json_data):
    if isinstance(json_data, dict):
        for key, value in json_data.items():
            print(f"Key: {key}")
            list_json_elements(value)
    elif isinstance(json_data, list):
        for item in json_data:
            list_json_elements(item)
    else:
        print(f"Value: {json_data}")


def extract_bbPoolInfos_from_syslog(syslogextract):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    print('flt : {}'.format(syslogextract_flt))
    starting_item = 'loCtrlAddress'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print("last_item: {}".format(last_item))
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?\}{1,}'
    # pattern = r'AddressDistributionReq_t:.*?(\{.*?\}\}\}\})'
    # pattern = r'\{\"l1Pools\":\[.*?\}\}\}'
    # matches = re.findall(pattern, syslogextract_flt)

    matches = re.search(pattern, syslogextract_flt)
    print('matches: {}'.format(matches))
    data = json.loads(matches[0])
    print(data)

    return data


def get_sfn_column(row_from_list):
    sfn_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            sfn_column = i + 1
            break
    return sfn_column


def read_and_parse_tti_data(path_to_tti):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.reader(csv_file)
        csv_reader = list(csv_dict)
        # print("dic: {}".format(csv_dict))
        # print("list: {}".format(csv_reader))

        line_count = 0
        ttifilter = ['ulMetricIndData: hfnTickCount', 'dlMetricIndData: hfnTickCount',
                     'ulFdSchedData: hfnTickCount', 'dlFdSchedData: hfnTickCount',
                     'dlAllocatedPooledResourcesData: hfnTickCount', 'ulAllocatedPooledResourcesData: hfnTickCount',
                     'dlSliceData: hfnTickCount']
        tti_dict = list()
        sfn_index = 0
        sfn_val = 0
        for row in csv_reader:
            col_sfn = get_sfn_column(row)
            # print('sfn_val: {}'.format(row[col_sfn]))
            try:
                if int(row[col_sfn]) < sfn_val:
                    sfn_val = 0
                    sfn_index = sfn_index + 1
                else:
                    sfn_val = int(row[col_sfn])
            except IndexError:
                pass

            if row[0] == 'dlSliceData: hfnTickCount':
                col_length = row.index('rrmSliceWeight')
                col_numSlice = row.index('slicesNumber')
                real_length = col_length - col_numSlice
                slicesNumber = int(row[col_numSlice + col_sfn - 1])
                for loop_row in range(0, slicesNumber):
                    new_row = dict()
                    new_row.update({'Event': row[0][:-14]})
                    new_row.update({'sfn': row[col_sfn]})
                    new_row.update({'sfn_abs': int(row[col_sfn]) + 1024 * sfn_index})
                    for index_dic in range(2, col_numSlice + 1):
                        new_row.update({row[index_dic]: row[index_dic + col_sfn - 1]})
                    for index_dic in range(col_numSlice + 1, col_length + 1):
                        # if (index_dic + col_sfn) < len(row):
                        # print(index_dic, row[index_dic], row[index_dic + col_sfn - 1])
                        new_row.update({row[index_dic]:
                                        row[index_dic + col_sfn - 1 + loop_row * real_length]})
                        # else:
                        #     break
                    tti_dict.append(new_row)

                line_count += 1
            elif row[0] in ttifilter:
                new_row = dict()
                new_row.update({'Event': row[0][:-14]})
                # print(row)
                new_row.update({'sfn': row[col_sfn]})
                new_row.update({'sfn_abs': int(row[col_sfn]) + 1024 * sfn_index})
                for index_dic in range(2, col_sfn):
                    if (index_dic + col_sfn) < len(row)+1:
                        # print(index_dic, row[index_dic], row[index_dic + col_sfn - 1])
                        new_row.update({row[index_dic]: row[index_dic + col_sfn - 1]})
                    else:
                        break
                tti_dict.append(new_row)

                line_count += 1

    return tti_dict


def calculate_sfn_periodicity(syslogextract):
    match = re.findall(r"sfn:(\d+)", syslogextract)
    if len(match) < 2:
        return None
    # Not enough elements to find a difference

    # Calculate differences between consecutive elements
    diff = [int(match[i + 1]) - int(match[i]) for i in range(len(match) - 1) if int(match[i + 1]) > int(match[i])]

    # Count occurrences of each difference
    difference_counts = Counter(diff)
    # print(f'difference_counts: {difference_counts}')

    # Find the most common difference
    most_common_diff = difference_counts.most_common(1)[0][0]

    return most_common_diff, difference_counts


def get_ulprb_demand(syslogextract):
    return get_prb_demand(syslogextract, 'ul')


def get_dlprb_demand(syslogextract):
    return get_prb_demand(syslogextract, 'dl')


def get_prb_demand(tti_dic, direction):
    firstsfn = list(map(lambda d: d['sfn'], filter(lambda d: d['Event'] == direction + 'MetricIndData' and
                        int(d['sfn']) < 1012, tti_dic)))[0]
    # print('first: {}'.format(firstsfn))
    prbdemand = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        # print(sfntocheck)
        gbrPrbDemand_key = 'gbrPrbDemand'
        nonGbrPrbDemand_key = 'nonGbrPrbDemand'
        # print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        gbrPrbDemand = []
        nonGbrPrbDemand = []
        lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
        for lcrId in lcrIds:
            gbrPrbDemand_i = [int(i) for i in
                              list(map(lambda d: d[gbrPrbDemand_key],
                                       filter(lambda d: d['Event'] == direction + 'MetricIndData',
                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                     filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            nonGbrPrbDemand_i = [int(i) for i in
                                 list(map(lambda d: d[nonGbrPrbDemand_key],
                                          filter(lambda d: d['Event'] == direction + 'MetricIndData',
                                                 filter(lambda d: d['sfn'] == sfntocheck,
                                                        filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            if not gbrPrbDemand_i:
                gbrPrbDemand.append(0)
            else:
                gbrPrbDemand.append(gbrPrbDemand_i[0])
            if not nonGbrPrbDemand_i:
                nonGbrPrbDemand.append(0)
            else:
                nonGbrPrbDemand.append(nonGbrPrbDemand_i[0])
        prbdemand.append({'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return prbdemand


def get_ulprb_demand_series(tti_dic):
    return get_prb_demand_series(tti_dic, 'ul')


def get_dlprb_demand_series(tti_dic):
    return get_prb_demand_series(tti_dic, 'dl')


def get_prb_demand_series(tti_dic, direction):
    prbdemand = []
    gbrPrbDemand_key = 'gbrPrbDemand'
    nonGbrPrbDemand_key = 'nonGbrPrbDemand'

    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        gbrPrbDemand_i = [int(i) for i in
                          list(map(lambda d: d[gbrPrbDemand_key],
                                   filter(lambda d: d['Event'] == direction + 'MetricIndData',
                                          filter(lambda d: d['lcrId'] == str(lcrId), tti_dic))))]
        nonGbrPrbDemand_i = [int(i) for i in
                             list(map(lambda d: d[nonGbrPrbDemand_key],
                                      filter(lambda d: d['Event'] == direction + 'MetricIndData',
                                             filter(lambda d: d['lcrId'] == str(lcrId), tti_dic))))]
        sfn_i = [int(i) for i in
                 list(map(lambda d: d['sfn_abs'],
                          filter(lambda d: d['Event'] == direction + 'MetricIndData',
                                 filter(lambda d: d['lcrId'] == str(lcrId), tti_dic))))]

        prbdemand.append({'lcrId': lcrId, 'sfn': sfn_i, 'gbrPrbDemand': gbrPrbDemand_i,
                          'nonGbrPrbDemand': nonGbrPrbDemand_i})
    return prbdemand


def get_data_series(tti_dic, event, data_key):
    data_series = []

    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        data_series_i = [int(i) for i in
                         list(map(lambda d: d[data_key],
                                  filter(lambda d: d['Event'] == event,
                                         filter(lambda d: d['lcrId'] == str(lcrId), tti_dic))))]
        sfn_i = [int(i) for i in
                 list(map(lambda d: d['sfn_abs'],
                          filter(lambda d: d['Event'] == event,
                                 filter(lambda d: d['lcrId'] == str(lcrId), tti_dic))))]

        data_series.append({'lcrId': lcrId, 'sfn': sfn_i, data_key: data_series_i})
    return data_series


def get_numAllocCellPrbUl(tti_dic, sfntocheck):
    numAllocCellPrbUl_key = 'numAllocCellPrbUl'

    numAllocCellPrbUl = []
    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        filteredprbs = list(map(lambda d: d[numAllocCellPrbUl_key],
                                filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                       filter(lambda d: int(d['sfn']) in range(int(sfntocheck), int(sfntocheck) + 5),
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        numAllocCellPrbUl.append(int(max(filteredprbs) if filteredprbs else 0))
    return {'sfn': sfntocheck, 'numAllocCellPrbUl': numAllocCellPrbUl}


def get_hasZabPrivilege(tti_dic, sfntocheck):
    hasZabPrivilege_key = 'hasZabPrivilege'
    hasZabPrivilege = []
    lcrIds = sorted(set(d['lcrId'] for d in tti_dic if d['Event'] == 'dlAllocatedPooledResourcesData'))
    sfntocheck_c = int(sfntocheck) if int(sfntocheck) < 1024 else int(sfntocheck) % 1024
    for lcrId in lcrIds:

        filteredprbs = list(map(lambda d: d[hasZabPrivilege_key],
                                filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                       filter(lambda d: int(d['sfn']) in range(sfntocheck_c, sfntocheck_c + 5),
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))

        hasZabPrivilege.append(int(max(filteredprbs) if filteredprbs else None))
        if hasZabPrivilege[-1] > 1:
            hasZabPrivilege[-1] = 0

    return hasZabPrivilege


def calculate_hasZabPrivilege(numMinPrbAlloc, maxCellPrb, DL_PRB_Demand,
                              Assigned_PRB, poolMaxNumStreamPrb, maxWbPoolStreamPrb):
    class cell:
        def __init__(self, cellid, stream, numMinPrbAlloc, maxCellPrb, prbDemandGbr,
                     prbDemandNonGbr, numAllocCellPrb):
            self.cellid = cellid
            self.stream = stream
            self.numMinPrbAlloc = numMinPrbAlloc * self.stream
            self.maxCellPrb = maxCellPrb * self.stream
            self.prbDemandGbr = prbDemandGbr * self.stream
            self.prbDemandNonGbr = prbDemandNonGbr * self.stream
            self.numAllocCellStreamPrb = numAllocCellPrb * self.stream
            self.absCellLoad = (self.prbDemandGbr + self.prbDemandNonGbr) / float(self.maxCellPrb)
            # self.numMinPrbAlloc removed from equation due to change in the algorithm
            # self.absCellLoad = (self.numMinPrbAlloc + self.prbDemandGbr+self.prbDemandNonGbr)/float(self.maxCellPrb)
            self.hasZab = 0

    rimRsZabReservation = 0
    cells = []
    streams = [4] * len(numMinPrbAlloc)
    numAllocStreamPrbZabCells = 0
    zabCapacityForAllCsiRsPoolingGroups = poolMaxNumStreamPrb - maxWbPoolStreamPrb
    rimRsZabReservation = rimRsZabReservation
    for i_cell in range(0, len(numMinPrbAlloc)):
        cells.append(
            cell(i_cell + 1, streams[i_cell], numMinPrbAlloc[i_cell], maxCellPrb[i_cell],
                 DL_PRB_Demand['gbrPrbDemand'][i_cell],
                 DL_PRB_Demand['nonGbrPrbDemand'][i_cell],
                 Assigned_PRB['numAllocCellPrbDl'][i_cell]))
    cells.sort(key=lambda x: x.absCellLoad, reverse=True)
    for cell in cells:
        # print('zabCapacityForAllCsiRsPoolingGroups: {}'.format(zabCapacityForAllCsiRsPoolingGroups))
        # print('numAllocStreamPrbZabCells: {}'.format(numAllocStreamPrbZabCells))

        if cell.numAllocCellStreamPrb > 0 and zabCapacityForAllCsiRsPoolingGroups >= cell.numAllocCellStreamPrb + \
                numAllocStreamPrbZabCells + rimRsZabReservation:
            cell.hasZab = 1
            numAllocStreamPrbZabCells = cell.numAllocCellStreamPrb + numAllocStreamPrbZabCells
        # print(vars(cell))

    cells.sort(key=lambda x: x.cellid)

    return [d.hasZab for d in cells]


def get_numAllocCellPrbDl(tti_dic, sfntocheck):
    numAllocCellPrbDl_key = 'numAllocCellPrbDl'

    numAllocCellPrbDl = []
    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                       filter(lambda d: int(d['sfn']) in range(int(sfntocheck), int(sfntocheck) + 5),
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
    return {'sfn': sfntocheck, 'numAllocCellPrbDl': numAllocCellPrbDl}


def get_slices_number(tti_dic, lcrId):
    slices_number = list(map(lambda d: d['slicesNumber'],
                             filter(lambda d: d['Event'] == 'dlSliceData',
                                    filter(lambda d: d['lcrId'] == str(lcrId), tti_dic))))
    return int(slices_number[0]) if slices_number else 0


def get_rrmSliceAvgHighShare(tti_dic):
    return get_rrmSliceAvgShare(tti_dic, 'High')


def get_rrmSliceAvgLowShare(tti_dic):
    return get_rrmSliceAvgShare(tti_dic, 'Low')


def get_rrmSliceAvgShare(tti_dic, highlo):
    rrmSliceAvgShare_key = 'rrmSliceAvg' + highlo + 'Share'
    rrmSliceAvgShare = []
    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        slices = get_slices_number(tti_dic, lcrId)
        print(lcrId, slices)
        for slice in range(0, slices):
            filteredprbs = list(map(lambda d: float(d[rrmSliceAvgShare_key]),
                                    filter(lambda d: d['sliceId'] == str(slice),
                                           filter(lambda d: d['Event'] == 'dlSliceData',
                                                  filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
            rrmSliceAvgShare.append({'cell': lcrId, 'sliceId': slice,
                                     rrmSliceAvgShare_key: mean(filteredprbs if filteredprbs else 0)})
    return rrmSliceAvgShare


def get_adaptRetxStatus(tti_dic):
    adaptRetxStatus_key = 'adaptRetxStatus'

    adaptRetxStatus = []
    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        adaptRetxStatus = set(list(map(lambda d: d[adaptRetxStatus_key],
                                       filter(lambda d: d['Event'] == 'dlFdSchedData',
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
    return adaptRetxStatus


def get_pdschusage_per_slot(tti_dic, sfntocheck, oddoreven='all'):
    cqi_key = 'pdcchCqi'
    usage = []
    # if oddoreven == 'all':
    #     rango = range(int(sfntocheck), int(sfntocheck)+31)
    # elif oddoreven == 'odd':
    range_odd = list(filter(lambda x: (x % 2 != 0), range(int(sfntocheck), int(sfntocheck) + 32)))
    # elif oddoreven == 'even':
    range_even = list(filter(lambda x: (x % 2 == 0), range(int(sfntocheck), int(sfntocheck) + 32)))
    lcrIds = sorted(set(d['lcrId'] for d in tti_dic))
    for lcrId in lcrIds:
        for slot in range(0, 20):
            filteredsfns_odd = list(
                map(
                    lambda d: d[cqi_key], filter(
                        lambda d: d['Event'] == 'dlFdSchedData', filter(
                            lambda d: int(d['slot']) == slot, filter(
                                lambda d: int(d['sfn']) in range_odd, filter(
                                    lambda d: d['lcrId'] == str(lcrId), tti_dic
                                )
                            )
                        )
                    )
                )
            )

            filteredsfns_even = list(
                map(
                    lambda d: d[cqi_key], filter(
                        lambda d: d['Event'] == 'dlFdSchedData', filter(
                            lambda d: int(d['slot']) == slot, filter(
                                lambda d: int(d['sfn']) in range_even, filter(
                                    lambda d: d['lcrId'] == str(lcrId), tti_dic
                                )
                            )
                        )
                    )
                )
            )
            # print('slot: {}, pdcchcqi: {}'.format(slot, filteredsfns))
            usage.append(dict(cell=lcrId, slot=slot, usage_odd=len(filteredsfns_odd) / 16,
                              usage_even=len(filteredsfns_even) / 16))
    return usage


def Calculate_cb007113_prbs_new(maxnumprbs, streams, numMinPrbAlloc, maxCellPrb,
                                UL_PRB_Demand, UL_PRB_Demand_Nminus6, l1spcells, cellType, scf=None, dlul='dl',
                                longPucchNumPuschPrb=0, rdMinSecondarSubcellCapacityMargin=0.1, cb012605=False):
    layers = [4] * len(maxCellPrb) if dlul == 'dl' else [2] * len(maxCellPrb)
    if cb012605:
        return Calculate_cb012605_prbs(maxnumprbs, layers, numMinPrbAlloc, maxCellPrb, UL_PRB_Demand,
                                       UL_PRB_Demand_Nminus6, l1spcells, cellType, scf,  dlul, longPucchNumPuschPrb,
                                       rdMinSecondarSubcellCapacityMargin, cb012605)
    else:
        return Calculate_cb009836_prbs(maxnumprbs, streams, numMinPrbAlloc, maxCellPrb, UL_PRB_Demand,
                                       UL_PRB_Demand_Nminus6, l1spcells, cellType, scf, dlul,
                                       longPucchNumPuschPrb, rdMinSecondarSubcellCapacityMargin)


def Calculate_cb009836_prbs(maxnumprbs, streams, numMinPrbAlloc, maxCellPrb,
                            UL_PRB_Demand, UL_PRB_Demand_Nminus6, l1spcells, cellType, scf=None, dlul='dl',
                            longPucchNumPuschPrb=0, rdMinSecondarSubcellCapacityMargin=0.1):
    debug = True

    class l1sp:
        def __init__(self, spid, numofcells, startcell, maxStreamPrb, maxNumLayerPrb, l1spcells):
            self.spid = spid
            self.newMinStreamPrbCapacityPerSp = 0
            self.newMinStreamPrbAllocationPerSp = 0
            self.newNonGbrStreamPrbAllocationPerSp = 0
            self.newNonGbrStreamPrbAllocationPerSpRound1 = 0
            self.totalStreamPrbGbrDemandPerSp = 0
            self.totalStreamPrbNonGbrDemandPerSp = 0
            self.totalStreamPrbNonGbrDemandPerSpRound2 = 0
            self.maxStreamPrbNonGbrAllocLimitSpRound2 = 0
            self.newGbrStreamPrbAllocationPerSp = 0
            self.nonGbrStreamPrbAllocation = 0
            self.newGbrStreamPrbAllocationPerSp = 0
            self.totalAllocStreamPrb = 0
            self.newTotalAllocStreamPrbSp = 0
            self.spSortingCriteria1 = 0
            self.spSortingCriteria2 = 0
            self.maxSpStreamPrb = 0
            self.maxStreamPrbL1Sp = 0
            self.maxLayerPrbL1Sp = 0
            self.numStreams = 0
            self.numLayers = 0
            self.maxStreamPrbGbrAllocLimitSp = 0
            self.maxStreamPrbNonGbrAllocLimitSp = 0
            self.l1spcells = l1spcells
            self.cells = []

        def add_cell(self, cell):
            self.cells.append(cell)

    class cell:
        def __init__(self, cellid, spId, streams, numMinPrbAlloc, maxCellPrb, prbDemandGbr,
                     prbDemandNonGbr, cellType, longPucchNumPuschPrb):
            self.cellid = cellid
            self.spId = spId
            self.streams = streams
            self.numMinPrbAlloc = numMinPrbAlloc
            self.maxCellPrb = maxCellPrb
            self.prbDemandGbr = prbDemandGbr
            self.prbDemandNonGbr = prbDemandNonGbr
            self.longPucchNumPuschPrb = longPucchNumPuschPrb
            self.cellType = cellType
            self.maxCellStreamPrb = self.streams * self.maxCellPrb
            self.maxCellPrbPrimarySubCell = self.maxCellPrb - self.longPucchNumPuschPrb
            self.maxCellStreamPrbPrimarySubCell = self.maxCellPrbPrimarySubCell * self.streams
            self.maxCellPrbSecondarySubCell = self.longPucchNumPuschPrb
            self.maxCellStreamPrbSecondarySubCell = self.maxCellPrbSecondarySubCell * self.streams
            self.numMinStreamPrbAlloc = self.streams * self.numMinPrbAlloc
            self.streamPrbDemandGbr = self.streams * self.prbDemandGbr
            self.streamPrbDemandNonGbr = self.streams * self.prbDemandNonGbr
            self.streamPrbDemandNonGbrRound2 = 0
            self.streamToLayerScaleFactor = float(4) / self.streams
            self.numAllocCellStreamPrb = self.numMinStreamPrbAlloc
            self.numLayerToStreamRatio = float(2) / self.streams
            self.numMinLayerPrbAlloc = self.numMinStreamPrbAlloc * self.numLayerToStreamRatio
            self.allocStreamPrbNonGbr = 0
            self.allocStreamPrbGbr = 0
            self.allocStreamPrbRest = 0
            self.secondarySubcellPrbUtilizationFactor = 0
            self.allocStreamPrbNonGbrLimitCell = math.floor(
                min(self.maxCellStreamPrb, self.maxCellStreamPrbPrimarySubCell +
                    (self.secondarySubcellPrbUtilizationFactor *
                     (1 - rdMinSecondarSubcellCapacityMargin) +
                     rdMinSecondarSubcellCapacityMargin) *
                    self.maxCellStreamPrbSecondarySubCell))
            self.cellSortingCriteria1 = min(self.maxCellStreamPrb - self.numAllocCellStreamPrb,
                                            self.streamPrbDemandGbr)
            self.cellSortingCriteria2 = self.streamPrbDemandGbr

    l1sps = []
    cells = []
    poolMaxNumStreamPrb = 0
    poolMaxNumLayerPrb = 0
    PoolStreamPrbToShare = 0
    numAllocCellStreamPrb = 0
    l1SpPoolLayerPrbToShare = 0
    l1SpPoolStreamPrbToShare = 0
    remainingStreamPrbPerPool = 0
    l1spcells = l1spcells[0] if isinstance(l1spcells[0][0], list) else l1spcells
    numofl1sp = len(l1spcells)

    if debug:
        print('maxnumprbs: {}'.format(maxnumprbs))
        print('streams: {}'.format(streams))
        print('numMinPrbAlloc: {}'.format(numMinPrbAlloc))
        print('maxCellPrb: {}'.format(maxCellPrb))
        print('UL_PRB_Demand: {}'.format(UL_PRB_Demand))
        print('UL_PRB_Demand_Nminus6: {}'.format(UL_PRB_Demand_Nminus6))

    nrcellIds = get_nrcellIds(scf)
    # print('nrcellIds: {}'.format(nrcellIds))
    ncells = len([cell for sp in l1spcells for cell in sp])
    # print('ncells: {}'.format(ncells))
    for i_cell in range(0, ncells):
        cells.append(
            cell(nrcellIds[i_cell]['lcrId'], 0 if nrcellIds[i_cell]['lcrId'] in l1spcells[0] else 1, streams[i_cell],
                 numMinPrbAlloc[i_cell], maxCellPrb[i_cell],
                 UL_PRB_Demand_Nminus6['gbrPrbDemand'][i_cell],
                 UL_PRB_Demand_Nminus6['nonGbrPrbDemand'][i_cell], cellType[i_cell], longPucchNumPuschPrb[i_cell]))
        if debug:
            print('initial assignment:')
            print('i_cell: {}'.format(i_cell))
            print('cell: {}'.format(cells[i_cell].__dict__).replace(',', '\n'))
            print('l1spcells: {}'.format(l1spcells))
    for i_l1sp in range(0, numofl1sp):
        l1sps.append(l1sp(i_l1sp, len(l1spcells[i_l1sp]), 0, maxnumprbs[i_l1sp]['maxNumStreamPrbL1Sp'],
                          maxnumprbs[i_l1sp]['maxNumLayerPrbL1Sp'], l1spcells[i_l1sp]))
        poolMaxNumStreamPrb = poolMaxNumStreamPrb + maxnumprbs[i_l1sp]['maxNumStreamPrbL1Sp']
        poolMaxNumLayerPrb = poolMaxNumLayerPrb + maxnumprbs[i_l1sp]['maxNumLayerPrbL1Sp']
        for lcrId in l1spcells[i_l1sp]:
            i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]
            l1sps[i_l1sp].newMinStreamPrbCapacityPerSp = l1sps[i_l1sp].newMinStreamPrbCapacityPerSp + \
                cells[i_cell].numMinStreamPrbAlloc * cells[i_cell].streamToLayerScaleFactor
            l1sps[i_l1sp].maxSpStreamPrb = l1sps[i_l1sp].maxSpStreamPrb + \
                cells[i_cell].maxCellStreamPrb * cells[i_cell].streamToLayerScaleFactor
            l1sps[i_l1sp].totalStreamPrbGbrDemandPerSp = l1sps[i_l1sp].totalStreamPrbGbrDemandPerSp + \
                cells[i_cell].streamPrbDemandGbr * cells[i_cell].streamToLayerScaleFactor
            l1sps[i_l1sp].totalStreamPrbNonGbrDemandPerSp = l1sps[i_l1sp].totalStreamPrbNonGbrDemandPerSp + \
                cells[i_cell].streamPrbDemandNonGbr * cells[i_cell].streamToLayerScaleFactor
            # print('totalStreamPrbNonGbrDemandPerSp: {}: cell {}, {}'.
            # format(l1sps[i_l1sp].totalStreamPrbNonGbrDemandPerSp, lcrId, cells[i_cell].streamPrbDemandNonGbr))
            l1sps[i_l1sp].maxStreamPrbGbrAllocLimitSp =\
                (l1sps[i_l1sp].maxStreamPrbGbrAllocLimitSp + min(cells[i_cell].streamPrbDemandGbr,
                                                                 max(0, cells[i_cell].maxCellStreamPrb -
                                                                     cells[i_cell].numMinStreamPrbAlloc)) *
                 cells[i_cell].streamToLayerScaleFactor)
            if dlul == 'dl' or cells[i_cell].cellType != '8DL8UL':
                l1sps[i_l1sp].maxStreamPrbNonGbrAllocLimitSp =\
                    (l1sps[i_l1sp].maxStreamPrbNonGbrAllocLimitSp + min(
                        cells[i_cell].streamPrbDemandNonGbr, max(0, cells[i_cell].maxCellStreamPrb -
                                                                 cells[i_cell].numMinStreamPrbAlloc -
                                                                 cells[i_cell].streamPrbDemandGbr)) *
                     cells[i_cell].streamToLayerScaleFactor)
            else:
                l1sps[i_l1sp].maxStreamPrbNonGbrAllocLimitSp =\
                    (l1sps[i_l1sp].maxStreamPrbNonGbrAllocLimitSp + min(
                        cells[i_cell].streamPrbDemandNonGbr, max(0, cells[i_cell].allocStreamPrbNonGbrLimitCell -
                                                                 cells[i_cell].numMinStreamPrbAlloc -
                                                                 cells[i_cell].streamPrbDemandGbr)) *
                     cells[i_cell].streamToLayerScaleFactor)

            l1sps[i_l1sp].numLayers = l1sps[i_l1sp].numLayers + 2
            l1sps[i_l1sp].numStreams = l1sps[i_l1sp].numStreams + cells[i_cell].streams
            l1sps[i_l1sp].cells.append(cells[i_cell])

    # INTER SP PRB POOLING
    # GBR allocation per subpool
    remainingStreamPrbPerPool =\
        poolMaxNumStreamPrb - l1sps[0].newMinStreamPrbCapacityPerSp - l1sps[1].newMinStreamPrbCapacityPerSp
    if sum(l1sp.totalStreamPrbGbrDemandPerSp for l1sp in l1sps) > 0:
        l1sps.sort(key=lambda x: min(x.totalStreamPrbGbrDemandPerSp, x.maxStreamPrbGbrAllocLimitSp))

        for i, l1sp in enumerate(l1sps):
            l1sp.newGbrStreamPrbAllocationPerSp = math.floor((remainingStreamPrbPerPool -
                                                              sum(l1sps[j].newGbrStreamPrbAllocationPerSp
                                                                  for j in range(0, i))) *
                                                             (l1sp.totalStreamPrbGbrDemandPerSp /
                                                              sum(l1sps[k].totalStreamPrbGbrDemandPerSp
                                                                  for k in range(i, len(l1sps)))))
            l1sp.newGbrStreamPrbAllocationPerSp = min(l1sp.maxStreamPrbGbrAllocLimitSp,
                                                      l1sp.newGbrStreamPrbAllocationPerSp)

    else:
        for l1sp in l1sps:
            l1sp.newGbrStreamPrbAllocationPerSp = 0

    for l1sp in l1sps:
        l1sp.newTotalAllocStreamPrbSp = l1sp.newMinStreamPrbCapacityPerSp + l1sp.newGbrStreamPrbAllocationPerSp

    # non GBR allocation per subpool
    remainingStreamPrbPerPool = poolMaxNumStreamPrb - sum(l1sp.newTotalAllocStreamPrbSp for l1sp in l1sps)
    if debug:
        print('remainingStreamPrbPerPool before Round1: {}'.format(remainingStreamPrbPerPool))
        for l1sp in l1sps:
            print("l1sp before Round1: {}".format(l1sp.__dict__).replace(',', '\n'))

    # Round 1 of ULTDD Algo (5G_UP_ALG_26880)

    if dlul == "ul" and cells[0].cellType == '8DL8UL':
        # if (l1sps[0].totalStreamPrbNonGbrDemandPerSp + l1sps[1].totalStreamPrbNonGbrDemandPerSp) > 0:
        if sum(l1sp.totalStreamPrbNonGbrDemandPerSp for l1sp in l1sps) > 0:

            # Sort l1sps based on totalStreamPrbGbrDemandPerSp and maxStreamPrbGbrAllocLimitSp
            l1sps.sort(key=lambda x: min(x.totalStreamPrbNonGbrDemandPerSp, x.maxStreamPrbNonGbrAllocLimitSp))
            for i, l1sp in enumerate(l1sps):
                l1sp.newNonGbrStreamPrbAllocationPerSp = math.floor((remainingStreamPrbPerPool -
                                                                     sum(l1sps[j].newNonGbrStreamPrbAllocationPerSp
                                                                         for j in range(0, i))) *
                                                                    (l1sp.totalStreamPrbNonGbrDemandPerSp /
                                                                     sum(l1sps[k].totalStreamPrbNonGbrDemandPerSp
                                                                         for k in range(i, len(l1sps)))))
            if debug:
                print('step1.1')
                print(
                    'l1sps[0].newNonGbrStreamPrbAllocationPerSp: {}'.format(
                        l1sps[0].newNonGbrStreamPrbAllocationPerSp))
                print(
                    'l1sps[1].newNonGbrStreamPrbAllocationPerSp: {}'.format(
                        l1sps[1].newNonGbrStreamPrbAllocationPerSp))

            for i, l1sp in enumerate(l1sps):
                l1sp.newNonGbrStreamPrbAllocationPerSp = max(l1sp.newNonGbrStreamPrbAllocationPerSp,
                                                             remainingStreamPrbPerPool -
                                                             sum(l1sps[j].newNonGbrStreamPrbAllocationPerSp for j in
                                                                 range(0, i)) -
                                                             sum(min(l1sps[k].totalStreamPrbNonGbrDemandPerSp,
                                                                     l1sps[k].maxStreamPrbNonGbrAllocLimitSp) for k in
                                                                 range(i + 1, len(l1sps))))
            if debug:
                print('step1.2')
                print(
                    'l1sps[0].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrStreamPrbAllocationPerSp))
                print(
                    'l1sps[1].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrStreamPrbAllocationPerSp))

            for l1sp in l1sps:
                l1sp.newNonGbrStreamPrbAllocationPerSp = min(l1sp.maxStreamPrbNonGbrAllocLimitSp,
                                                             l1sp.newNonGbrStreamPrbAllocationPerSp)

            if debug:
                print('step1.3')
                print(
                    'l1sps[0].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrStreamPrbAllocationPerSp))
                print(
                    'l1sps[1].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrStreamPrbAllocationPerSp))

        else:
            for l1sp in l1sps:
                l1sp.newNonGbrStreamPrbAllocationPerSp = 0

        if debug:
            for l1sp in l1sps:
                print("l1sp before Round2: {}".format(l1sp.__dict__).replace(',', '\n'))

        remainingStreamPrbPerPool = max(0, remainingStreamPrbPerPool -
                                        sum(l1sp.newNonGbrStreamPrbAllocationPerSp for l1sp in l1sps))

        if debug:
            print('remainingStreamPrbPerPool before Round2: {}'.format(remainingStreamPrbPerPool))
        for l1sp in l1sps:
            l1sp.newNonGbrStreamPrbAllocationPerSpRound1 = l1sp.newNonGbrStreamPrbAllocationPerSp
            l1sp.totalStreamPrbNonGbrDemandPerSpRound2 = max(0, l1sp.totalStreamPrbNonGbrDemandPerSp -
                                                             l1sp.newNonGbrStreamPrbAllocationPerSp)

            # l1sp.maxStreamPrbNonGbrAllocLimitSp = 0
            for i_cell in l1sp.l1spcells:
                l1sp.maxStreamPrbNonGbrAllocLimitSpRound2 = (l1sp.maxStreamPrbNonGbrAllocLimitSpRound2 +
                                                             (min(cells[i_cell].streamPrbDemandNonGbr,
                                                                  max(0, cells[i_cell].maxCellStreamPrb -
                                                                      cells[i_cell].numMinStreamPrbAlloc -
                                                                      cells[i_cell].streamPrbDemandGbr)) *
                                                              cells[i_cell].streamToLayerScaleFactor))
            l1sp.maxStreamPrbNonGbrAllocLimitSpRound2 = (l1sp.maxStreamPrbNonGbrAllocLimitSpRound2 -
                                                         l1sp.newNonGbrStreamPrbAllocationPerSp)
        # if there is still remaining pool capacity after Round1, provide additinal allocaiton
        # as described in this step section using updated values from Round1:

        # Round2 of ULTDD Algo (5G_UP_ALG_26880)
        if remainingStreamPrbPerPool > 0:
            for l1sp in l1sps:
                l1sp.totalStreamPrbNonGbrDemandPerSp = l1sp.totalStreamPrbNonGbrDemandPerSpRound2
                l1sp.maxStreamPrbNonGbrAllocLimitSp = l1sp.maxStreamPrbNonGbrAllocLimitSpRound2
                # remainingStreamPrbPerPool = max(0, remainingStreamPrbPerPool -
                #                                 l1sp.newNonGbrStreamPrbAllocationPerSp)
                l1sp.newNonGbrStreamPrbAllocationPerSpRound1 = l1sp.newNonGbrStreamPrbAllocationPerSp
                l1sp.newNonGbrStreamPrbAllocationPerSp = 0

            # l1sp.maxStreamPrbNonGbrAllocLimitSp - l1sp.newNonGbrStreamPrbAllocationPerSp
        if debug:
            for l1sp in l1sps:
                print("l1sp after Round2: {}".format(l1sp.__dict__).replace(',', '\n'))
                print('remainingStreamPrbPerPool after Round2: {}'.format(remainingStreamPrbPerPool))

    # End Of Round2
    if sum(l1sp.totalStreamPrbNonGbrDemandPerSp for l1sp in l1sps) > 0:

        l1sps.sort(key=lambda x: min(x.totalStreamPrbNonGbrDemandPerSp, x.maxStreamPrbNonGbrAllocLimitSp))
        for i, l1sp in enumerate(l1sps):
            l1sp.newNonGbrStreamPrbAllocationPerSp = math.floor((remainingStreamPrbPerPool -
                                                                 sum(l1sps[j].newNonGbrStreamPrbAllocationPerSp
                                                                     for j in range(0, i))) *
                                                                (l1sp.totalStreamPrbNonGbrDemandPerSp /
                                                                 sum(l1sps[k].totalStreamPrbNonGbrDemandPerSp
                                                                     for k in range(i, len(l1sps)))))

        if debug:
            print('step2.1')
            print('l1sps[0].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrStreamPrbAllocationPerSp))
            print('l1sps[1].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrStreamPrbAllocationPerSp))
        for l1sp in l1sps:
            l1sp.newNonGbrStreamPrbAllocationPerSp = min(l1sp.maxStreamPrbNonGbrAllocLimitSp,
                                                         l1sp.newNonGbrStreamPrbAllocationPerSp)

        if debug:
            print('step2.2')
            print('l1sps[0].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrStreamPrbAllocationPerSp))
            print('l1sps[1].newNonGbrStreamPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrStreamPrbAllocationPerSp))

    else:
        for l1sp in l1sps:
            l1sp.newNonGbrStreamPrbAllocationPerSp = 0

    if dlul == "ul" and cells[0].cellType == '8DL8UL':
        for l1sp in l1sps:
            l1sp.newNonGbrStreamPrbAllocationPerSp += l1sp.newNonGbrStreamPrbAllocationPerSpRound1

    for l1sp in l1sps:
        l1sp.newTotalAllocStreamPrbSp = l1sp.newTotalAllocStreamPrbSp + l1sp.newNonGbrStreamPrbAllocationPerSp

    remainingStreamPrbPerPool = poolMaxNumStreamPrb - sum(l1sp.newTotalAllocStreamPrbSp for l1sp in l1sps)

    # Sorting subpools
    for l1sp in l1sps:
        l1sp.spSortingCriteria1 = l1sp.maxSpStreamPrb
        l1sp.spSortingCriteria2 = l1sp.maxSpStreamPrb - l1sp.newTotalAllocStreamPrbSp

    l1sps.sort(key=lambda x: (x.spSortingCriteria1, x.spSortingCriteria2))
    if debug:
        for l1sp in l1sps:
            print("l1sp before  Distributing: {}".format(l1sp.__dict__).replace(',', '\n'))

    # Distributing remaining resources until SP's max
    for i, l1sp in enumerate(l1sps):
        l1sp.newTotalAllocStreamPrbSp =\
            min(l1sp.maxSpStreamPrb, l1sp.newTotalAllocStreamPrbSp +
                max(
                    0,
                    math.floor(remainingStreamPrbPerPool * (l1sp.newTotalAllocStreamPrbSp / (
                        sum(l1sps[k].newTotalAllocStreamPrbSp for k in range(i, len(l1sps)))))),
                    remainingStreamPrbPerPool - sum(l1sps[k].spSortingCriteria2 for k in range(i + 1, len(l1sps)))))
        remainingStreamPrbPerPool = poolMaxNumStreamPrb - sum(l1spi.newTotalAllocStreamPrbSp for l1spi in l1sps)

    # Distributing remaining resources beyond SP's max
    for i, l1sp in enumerate(l1sps):
        l1sp.newTotalAllocStreamPrbSp = min(l1sp.maxSpStreamPrb, l1sp.newTotalAllocStreamPrbSp +
                                            max(0, remainingStreamPrbPerPool -
                                                sum(l1sps[k].spSortingCriteria2 for k in range(i + 1, len(l1sps))))
                                            )
        remainingStreamPrbPerPool = poolMaxNumStreamPrb - sum(l1spi.newTotalAllocStreamPrbSp for l1spi in l1sps)

    #  (5) Allocate the rest of remaining stream PRBs of the pool, if any, equally between the subpools
    for i, l1sp in enumerate(l1sps):
        l1sp.newTotalAllocStreamPrbSp = (l1sp.newTotalAllocStreamPrbSp +
                                         math.floor(remainingStreamPrbPerPool / (len(l1sps) - i)))

        remainingStreamPrbPerPool = poolMaxNumStreamPrb - sum(l1spi.newTotalAllocStreamPrbSp for l1spi in l1sps)

    #  Determine final values of SP capacity
    for l1sp in l1sps:
        l1sp.maxStreamPrbL1Sp = l1sp.newTotalAllocStreamPrbSp
        l1sp.maxLayerPrbL1Sp = l1sp.newTotalAllocStreamPrbSp / 2

    if debug:
        for l1sp in l1sps:
            print("l1sp after InterSP: {}".format(l1sp.__dict__).replace(',', '\n'))
        for celli in cells:
            print("celli after InterSP: {}".format(celli.__dict__).replace(',', '\n'))

    # INTRA SP PRB POOLING
    l1sps.sort(key=lambda x: x.spid)
    # Cells updated with current PRB demand
    cells = []
    for i_cell in range(0, ncells):
        cells.append(
            cell(nrcellIds[i_cell]['lcrId'], 0 if nrcellIds[i_cell]['lcrId'] in l1spcells[0] else 1, streams[i_cell],
                 numMinPrbAlloc[i_cell], maxCellPrb[i_cell],
                 UL_PRB_Demand['gbrPrbDemand'][i_cell],
                 UL_PRB_Demand['nonGbrPrbDemand'][i_cell], cellType[i_cell], longPucchNumPuschPrb[i_cell]))

    for l1sp in l1sps:
        l1sp.cells = []
        for cell in cells:
            if cell.cellid in l1sp.l1spcells:
                l1sp.cells.append(cell)

    # End update cells with current PRB demand
    poolPotentialStreamPrbs = poolMaxNumStreamPrb
    sumCellPotentialStreamPrbs = 0

    for i, l1sp in enumerate(l1sps):

        l1sp.cells.sort(key=lambda x: (x.cellSortingCriteria1, x.cellSortingCriteria2))

        for l1cells in l1sp.cells:
            print('after sorting: l1sp: {}, cells: {}'.format(i, l1cells.__dict__).replace(',', '\n'))

        l1SpPoolStreamPrbToShare = l1sp.newTotalAllocStreamPrbSp
        l1SpPoolLayerPrbToShare = l1SpPoolStreamPrbToShare * l1sp.numLayers / l1sp.numStreams
        if debug:
            print('l1SpPoolStreamPrbToShare: {}'.format(l1SpPoolStreamPrbToShare))

        # for lcrId in l1sp.l1spcells:
        #     i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]
        l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - sum(l1cell.numAllocCellStreamPrb for l1cell in l1sp.cells)
        l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - sum(l1cell.numAllocCellStreamPrb *
                                                                l1cell.numLayerToStreamRatio for l1cell in l1sp.cells)

        sumNumAllocCellStreamPrb = 0

        # GBR
        # if a == 1:
        for icell, l1cell in enumerate(l1sp.cells):
            # i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]
            # i_cells = [next(i for i, cell in enumerate(cells) if cell.cellid == lcrId) for lcrId in l1sp.l1spcells]
            sumStreamPrbDemandGbrGTEi = sum(l1sp.cells[k].streamPrbDemandGbr for k in range(icell, len(l1sp.cells)))

            if sumStreamPrbDemandGbrGTEi == 0:
                l1cell.allocStreamPrbGbr = 0
            else:
                l1SpPoolStreamPrbToShareTemp = min(l1SpPoolLayerPrbToShare / l1cell.numLayerToStreamRatio,
                                                   l1SpPoolStreamPrbToShare)
                l1cell.allocStreamPrbGbr =\
                    l1SpPoolStreamPrbToShareTemp * float(l1cell.streamPrbDemandGbr) / sumStreamPrbDemandGbrGTEi
                l1cell.allocStreamPrbGbr = min(
                    l1cell.maxCellStreamPrb - l1cell.numMinStreamPrbAlloc,
                    l1cell.streamPrbDemandGbr, l1cell.allocStreamPrbGbr)
                l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - l1cell.allocStreamPrbGbr
                l1SpPoolLayerPrbToShare =\
                    l1SpPoolLayerPrbToShare - l1cell.allocStreamPrbGbr * l1cell.numLayerToStreamRatio

            l1cell.numAllocCellStreamPrb = l1cell.numAllocCellStreamPrb + l1cell.allocStreamPrbGbr
            sumNumAllocCellStreamPrb = sumNumAllocCellStreamPrb + l1cell.numAllocCellStreamPrb

            l1cell.cellSortingCriteria1 = min(l1cell.maxCellStreamPrb -
                                              l1cell.numAllocCellStreamPrb,
                                              l1cell.streamPrbDemandNonGbr)
            l1cell.cellSortingCriteria2 = l1cell.streamPrbDemandNonGbr

        if debug:
            print('l1SpPoolStreamPrbToShare: {}'.format(l1SpPoolStreamPrbToShare))
            print('l1sp.maxStreamPrbL1Sp: {}'.format(l1sp.maxStreamPrbL1Sp))
        # l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - sumNumAllocCellStreamPrb

        l1sp.cells.sort(key=lambda x: (x.cellSortingCriteria1, x.cellSortingCriteria2))

        l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - sum(l1cell.allocStreamPrbNonGbr for l1cell in l1sp.cells)
        l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - sum(l1cell.allocStreamPrbNonGbr *
                                                                l1cell.numLayerToStreamRatio for l1cell in l1sp.cells)
        # non GBR
        for icell, l1cell in enumerate(l1sp.cells):
            print('after sorting: sp: {}, i_cells: {}'.format(l1sp.spid, l1cell.cellid))
        # Step 1 for MUMIMO UL Cells
        if dlul == "ul" and cells[0].cellType == '8DL8UL':
            l1sp.cells.sort(key=lambda x: (min(x.allocStreamPrbNonGbrLimitCell -
                                               x.numAllocCellStreamPrb, x.streamPrbDemandNonGbr)))

            for icell, l1cell in enumerate(l1sp.cells):

                if sum(l1sp.cells[k].streamPrbDemandNonGbr for k in range(icell, len(l1sp.cells))) > 0:
                    l1SpPoolStreamPrbToShareTemp = min(l1SpPoolLayerPrbToShare /
                                                       l1cell.numLayerToStreamRatio,
                                                       l1SpPoolStreamPrbToShare)
                    l1cell.allocStreamPrbNonGbr = min(l1cell.streamPrbDemandNonGbr,
                                                      l1SpPoolStreamPrbToShareTemp *
                                                      l1cell.streamPrbDemandNonGbr /
                                                      sum(l1sp.cells[k].streamPrbDemandNonGbr
                                                          for k in range(icell, len(l1sp.cells))))

                    l1cell.allocStreamPrbNonGbr = max(l1cell.allocStreamPrbNonGbr,
                                                      l1SpPoolStreamPrbToShareTemp -
                                                      sum(min(l1sp.cells[k].allocStreamPrbNonGbrLimitCell -
                                                              l1sp.cells[k].numAllocCellStreamPrb,
                                                              l1sp.cells[k].streamPrbDemandNonGbr) *
                                                          (l1sp.cells[k].numLayerToStreamRatio /
                                                           l1cell.numLayerToStreamRatio)
                                                          for k in range(icell + 1, len(l1sp.cells))))

                    l1cell.allocStreamPrbNonGbr = max(0, min(l1cell.allocStreamPrbNonGbr,
                                                             (l1cell.allocStreamPrbNonGbrLimitCell -
                                                              l1cell.numAllocCellStreamPrb)))

                    l1cell.streamPrbDemandNonGbrRound2 = (l1cell.streamPrbDemandNonGbr -
                                                          l1cell.allocStreamPrbNonGbr)
                    l1cell.numAllocCellStreamPrb = (l1cell.numAllocCellStreamPrb +
                                                    l1cell.allocStreamPrbNonGbr)

                    l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - l1cell.allocStreamPrbNonGbr
                    l1SpPoolLayerPrbToShare = (l1SpPoolLayerPrbToShare - l1cell.allocStreamPrbNonGbr *
                                               l1cell.numLayerToStreamRatio)

            if debug:
                for lcrId in l1sp.l1spcells:
                    i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]

            # Round 2 for MUMIMO UL Cells
            if l1SpPoolStreamPrbToShare > 0:
                for icell, l1cell in enumerate(l1sp.cells):
                    l1cell.streamPrbDemandNonGbrTemp = l1cell.streamPrbDemandNonGbr
                    l1cell.streamPrbDemandNonGbr = l1cell.streamPrbDemandNonGbrRound2
                l1sp.cells.sort(key=lambda x: min(x.maxCellStreamPrb -
                                                  x.numAllocCellStreamPrb, x.streamPrbDemandNonGbr))
                print('sum: {}'.format(sum(l1sp.cells[k].streamPrbDemandNonGbr for k in range(icell, len(l1sp.cells)))))
                for icell, l1cell in enumerate(l1sp.cells):
                    if sum(l1sp.cells[k].streamPrbDemandNonGbr for k in range(icell, len(l1sp.cells))) > 0:
                        l1SpPoolStreamPrbToShareTemp = min(l1SpPoolLayerPrbToShare /
                                                           l1cell.numLayerToStreamRatio,
                                                           l1SpPoolStreamPrbToShare)
                        l1cell.allocStreamPrbNonGbr = min(l1cell.streamPrbDemandNonGbr,
                                                          l1SpPoolStreamPrbToShareTemp *
                                                          l1cell.streamPrbDemandNonGbr /
                                                          sum(l1sp.cells[k].streamPrbDemandNonGbr
                                                              for k in range(icell, len(l1sp.cells))))
                        l1cell.allocStreamPrbNonGbr = max(0, min(l1cell.allocStreamPrbNonGbr,
                                                                 (l1cell.maxCellStreamPrb -
                                                                  l1cell.numAllocCellStreamPrb)))
                        l1cell.numAllocCellStreamPrb = (l1cell.numAllocCellStreamPrb +
                                                        l1cell.allocStreamPrbNonGbr)
                        l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - l1cell.allocStreamPrbNonGbr
                        l1SpPoolLayerPrbToShare = (l1SpPoolLayerPrbToShare - l1cell.allocStreamPrbNonGbr *
                                                   l1cell.numLayerToStreamRatio)
                if debug:
                    print('l1SpPoolStreamPrbToShare after Round2 IntraSp: {}'.format(l1SpPoolStreamPrbToShare))
                    for lcrId in l1sp.l1spcells:
                        print("celli after Round2 IntraSp: {}".format(l1cell.__dict__).replace(',', '\n'))

        if debug:
            for celli in cells:
                print("celli before IntraSP: {}".format(celli.__dict__).replace(',', '\n'))
        for icell, l1cell in enumerate(l1sp.cells):

            l1SpPoolStreamPrbToShareTemp = min(l1SpPoolLayerPrbToShare /
                                               l1cell.numLayerToStreamRatio,
                                               l1SpPoolStreamPrbToShare)

            sumStreamPrbDemandNonGbrGTEi = sum(
                l1sp.cells[k].streamPrbDemandNonGbr for k in range(icell, len(l1sp.cells)))

            if sumStreamPrbDemandNonGbrGTEi == 0:
                l1cell.allocStreamPrbNonGbr = 0
            else:
                l1cell.allocStreamPrbNonGbr = min(l1cell.streamPrbDemandNonGbr,
                                                  l1SpPoolStreamPrbToShareTemp *
                                                  l1cell.streamPrbDemandNonGbr /
                                                  sumStreamPrbDemandNonGbrGTEi)
                l1cell.allocStreamPrbNonGbr = min(l1cell.maxCellStreamPrb -
                                                  l1cell.numAllocCellStreamPrb,
                                                  l1cell.allocStreamPrbNonGbr)
                l1cell.allocStreamPrbNonGbr = max(0, l1cell.allocStreamPrbNonGbr)

            l1cell.numAllocCellStreamPrb = l1cell.numAllocCellStreamPrb + l1cell.allocStreamPrbNonGbr
            l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - l1cell.allocStreamPrbNonGbr
            l1SpPoolLayerPrbToShare =\
                l1SpPoolLayerPrbToShare - l1cell.allocStreamPrbNonGbr * l1cell.numLayerToStreamRatio

            poolPotentialStreamPrbs =\
                poolPotentialStreamPrbs - l1cell.allocStreamPrbGbr - l1cell.numMinStreamPrbAlloc
            sumCellPotentialStreamPrbs =\
                sumCellPotentialStreamPrbs + (
                    l1cell.maxCellStreamPrb - l1cell.allocStreamPrbGbr - l1cell.numMinStreamPrbAlloc)
            l1cell.cellSortingCriteria1 = max(l1cell.maxCellStreamPrb -
                                              l1cell.numAllocCellStreamPrb, 0)
            l1cell.cellSortingCriteria2 = random.randint(0, 100)

        l1sp.cells.sort(key=lambda x: (x.cellSortingCriteria1, x.cellSortingCriteria2))

        for icell, l1cell in enumerate(l1sp.cells):
            l1SpPoolStreamPrbToShareTemp = min(l1SpPoolLayerPrbToShare /
                                               l1cell.numLayerToStreamRatio, l1SpPoolStreamPrbToShare)

            allocatedStreamPrbSubsequentInclusive = sum(l1sp.cells[k].numAllocCellStreamPrb *
                                                        l1sp.cells[k].numLayerToStreamRatio
                                                        for k in range(icell, len(l1sp.cells)))

            potentialStreamPrbSubsequent = sum(l1sp.cells[k].maxCellStreamPrb *
                                               l1sp.cells[k].numAllocCellStreamPrb
                                               for k in range(icell + 1, len(l1sp.cells)))

            l1cell.allocStreamPrbRest =\
                max(math.floor(
                    l1SpPoolStreamPrbToShareTemp * l1cell.numAllocCellStreamPrb /
                    (allocatedStreamPrbSubsequentInclusive / l1cell.numLayerToStreamRatio)),
                    l1SpPoolStreamPrbToShareTemp - (potentialStreamPrbSubsequent / l1cell.numLayerToStreamRatio))
            l1cell.allocStreamPrbRest = min(l1cell.maxCellStreamPrb - l1cell.numAllocCellStreamPrb,
                                            l1cell.allocStreamPrbRest)
            l1cell.allocStreamPrbRest = max(l1cell.allocStreamPrbRest, 0)

            l1cell.numAllocCellStreamPrb = l1cell.numAllocCellStreamPrb + l1cell.allocStreamPrbRest
            l1SpPoolStreamPrbToShare = l1SpPoolStreamPrbToShare - l1cell.allocStreamPrbRest
            l1SpPoolLayerPrbToShare =\
                l1SpPoolLayerPrbToShare - l1cell.allocStreamPrbRest * l1cell.numLayerToStreamRatio

    #  BBRM USABLE CELL PRB
    # for l1sp in l1sps:
    #     print("l1sp after IntraSP: {}".format(l1sp.__dict__).replace(',', '\n'))

    # for celli in cells:
    #     print("celli after IntraSP: {}".format(celli.__dict__).replace(',', '\n'))
    cells.sort(key=lambda cell: cell.cellid)
    result = [int(x.numAllocCellStreamPrb / x.streams) for x in cells]
    return result


def Calculate_cb012605_prbs(maxnumprbs, layers, numMinPrbAlloc, maxCellPrb, UL_PRB_Demand, UL_PRB_Demand_Nminus6,
                            l1spcells, cellType, scf=None, dlul='dl', longPucchNumPuschPrb=0,
                            rdMinSecondarSubcellCapacityMargin=0.1, cb012605=True):
    debug = True

    class l1sp:
        def __init__(self, spid, numofcells, startcell, maxStreamPrb, maxNumLayerPrb, l1spcells):
            self.spid = spid
            self.newMinLayerPrbCapacityPerSp = 0
            self.newMinLayerPrbAllocationPerSp = 0
            self.newNonGbrLayerPrbAllocationPerSp = 0
            self.newNonGbrLayerPrbAllocationPerSpRound1 = 0
            self.totalLayerPrbGbrDemandPerSp = 0
            self.totalLayerPrbNonGbrDemandPerSp = 0
            self.totalLayerPrbNonGbrDemandPerSpRound2 = 0
            self.maxLayerPrbNonGbrAllocLimitSp = 0
            self.maxLayerPrbGbrAllocLimitSp = 0
            self.maxLayerPrbNonGbrAllocLimitSpRound2 = 0
            self.maxLayerPrbNonGbrMimoAllocLimitSp = 0
            self.newGbrLayerPrbAllocationPerSp = 0
            self.nonGbrLayerPrbAllocation = 0
            self.newGbrLayerPrbAllocationPerSp = 0
            self.newTotalAllocLayerPrbSp = 0
            self.spSortingCriteria1 = 0
            self.spSortingCriteria2 = 0
            self.maxSpLayerPrb = 0
            self.maxLayerPrbL1Sp = 0
            self.numLayers = 0
            self.l1spcells = l1spcells
            self.cells = []

        def add_cell(self, cell):
            self.cells.append(cell)

    class cell:
        def __init__(self, cellid, spId, layers, numMinPrbAlloc, maxCellPrb, prbDemandGbr,
                     prbDemandNonGbr, cellType, longPucchNumPuschPrb):
            self.cellid = cellid
            self.spId = spId
            self.layers = layers
            self.numMinPrbAlloc = numMinPrbAlloc
            self.maxCellPrb = maxCellPrb
            self.prbDemandGbr = prbDemandGbr
            self.prbDemandNonGbr = prbDemandNonGbr
            self.longPucchNumPuschPrb = longPucchNumPuschPrb
            self.cellType = cellType
            self.maxCellLayerPrb = self.layers * self.maxCellPrb
            self.maxCellPrbPrimarySubCell = self.maxCellPrb - self.longPucchNumPuschPrb
            self.maxCellLayerPrbPrimarySubCell = self.maxCellPrbPrimarySubCell * self.layers
            self.maxCellPrbSecondarySubCell = self.longPucchNumPuschPrb
            self.maxCellLayerPrbSecondarySubCell = self.maxCellPrbSecondarySubCell * self.layers
            self.numMinLayerPrbAlloc = self.numMinPrbAlloc
            self.layerPrbDemandGbr = self.prbDemandGbr
            self.layerPrbDemandNonGbr = self.prbDemandNonGbr
            self.layerPrbDemandNonGbrRound2 = 0
            self.numAllocCellLayerPrb = self.numMinLayerPrbAlloc
            self.allocLayerPrbNonGbr = 0
            self.allocLayerPrbGbr = 0
            self.allocLayerPrbRest = 0
            self.secondarySubcellPrbUtilizationFactor = 0
            self.allocLayerPrbNonGbrLimitCell = math.floor(
                min(self.maxCellLayerPrb, self.maxCellLayerPrbPrimarySubCell +
                    (self.secondarySubcellPrbUtilizationFactor *
                     (1 - rdMinSecondarSubcellCapacityMargin) +
                     rdMinSecondarSubcellCapacityMargin) *
                    self.maxCellLayerPrbSecondarySubCell))
            self.cellSortingCriteria1 = min(self.maxCellLayerPrb - self.numAllocCellLayerPrb,
                                            self.layerPrbDemandGbr)
            self.cellSortingCriteria2 = self.layerPrbDemandGbr

    l1sps = []
    cells = []
    poolMaxNumLayerPrb = 0
    l1SpPoolLayerPrbToShare = 0
    l1SpPoolStreamPrbToShare = 0
    remainingStreamPrbPerPool = 0
    l1spcells = l1spcells[0] if isinstance(l1spcells[0][0], list) else [l1spcells[0], []]
    numofl1sp = len(l1spcells)
    if debug:
        print('maxnumprbs: {}'.format(maxnumprbs))
        print('layers: {}'.format(layers))
        print('numMinPrbAlloc: {}'.format(numMinPrbAlloc))
        print('maxCellPrb: {}'.format(maxCellPrb))
        print('UL_PRB_Demand: {}'.format(UL_PRB_Demand))
        print('UL_PRB_Demand_Nminus6: {}'.format(UL_PRB_Demand_Nminus6))
        print('l1spcells: {}'.format(l1spcells))

    nrcellIds = get_active_nrcellIds(None)
    print('nrcellIds: {}'.format(nrcellIds))
    cellsInSps = [cell for sp in l1spcells for cell in sp]
    ncells = len(cellsInSps)
    print('ncells: {}'.format(ncells))
    for i_cell in range(0, ncells):
        # if nrcellIds[i_cell]['lcrId'] in cellsInSps:
        cells.append(
            cell(nrcellIds[i_cell]['lcrId'], 0 if nrcellIds[i_cell]['lcrId'] in l1spcells[0] else 1, layers[i_cell],
                 numMinPrbAlloc[i_cell], maxCellPrb[i_cell], UL_PRB_Demand_Nminus6['gbrPrbDemand'][i_cell],
                 UL_PRB_Demand_Nminus6['nonGbrPrbDemand'][i_cell], cellType[i_cell], longPucchNumPuschPrb[i_cell]))
        if debug:
            print('initial assignment:')
            print('i_cell: {}'.format(i_cell))
            print('cell: {}'.format(cells[i_cell].__dict__).replace(',', '\n'))
            print('l1spcells: {}'.format(l1spcells))
    for i_l1sp in range(0, numofl1sp):
        l1sps.append(l1sp(i_l1sp, len(l1spcells[i_l1sp]), 0, maxnumprbs[i_l1sp]['maxNumLayerPrbL1Sp'],
                          maxnumprbs[i_l1sp]['maxNumLayerPrbL1Sp'], l1spcells[i_l1sp]))
        if debug:
            print('l1sp: {}'.format(l1sps[i_l1sp].__dict__).replace(',', '\n'))
        # poolMaxNumStreamPrb = poolMaxNumStreamPrb + maxnumprbs[i_l1sp]['maxNumStreamPrbL1Sp']
        poolMaxNumLayerPrb = poolMaxNumLayerPrb + maxnumprbs[i_l1sp]['maxNumLayerPrbL1Sp']
        for lcrId in l1spcells[i_l1sp]:
            i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]
            l1sps[i_l1sp].cells.append(cells[i_cell])
        l1sps[i_l1sp].newMinLayerPrbCapacityPerSp = sum(l1cell.numMinLayerPrbAlloc for l1cell in l1sps[i_l1sp].cells)
        l1sps[i_l1sp].maxSpLayerPrb = sum(l1cell.maxCellLayerPrb for l1cell in l1sps[i_l1sp].cells)
        l1sps[i_l1sp].totalLayerPrbGbrDemandPerSp = sum(l1cell.layerPrbDemandGbr for l1cell in l1sps[i_l1sp].cells)
        l1sps[i_l1sp].totalLayerPrbNonGbrDemandPerSp = sum(
            l1cell.layerPrbDemandNonGbr for l1cell in l1sps[i_l1sp].cells)

        l1sps[i_l1sp].maxLayerPrbGbrAllocLimitSp = sum(min(l1cell.layerPrbDemandGbr,
                                                           max(0, l1cell.maxCellLayerPrb -
                                                               l1cell.numMinLayerPrbAlloc))
                                                       for l1cell in l1sps[i_l1sp].cells)
        l1sps[i_l1sp].maxLayerPrbNonGbrAllocLimitSp = sum(min(
            l1cell.layerPrbDemandNonGbr,
            max(0, l1cell.maxCellLayerPrb - l1cell.numMinLayerPrbAlloc - l1cell.layerPrbDemandGbr))
            for l1cell in l1sps[i_l1sp].cells)

        if dlul == 'ul' and cells[0].cellType == '8DL8UL':
            l1sps[i_l1sp].maxLayerPrbNonGbrMimoAllocLimitSp = sum(min(l1cell.maxMuMimoCellLayerPrbNonGbrLimit,
                                                                      max(0, l1cell.maxCellLayerPrb -
                                                                          l1cell.numMinLayerPrbAlloc -
                                                                          l1cell.layerPrbDemandGbr)) for l1cell in
                                                                  l1sps[i_l1sp].cells)
        # l1sps[i_l1sp].numLayers = l1sps[i_l1sp].numLayers + 2
        # l1sps[i_l1sp].numStreams = l1sps[i_l1sp].numStreams + cells[i_cell].streams
        # l1sps[i_l1sp].cells.append(cells[i_cell])

    # INTER SP PRB POOLING
    # GBR allocation per subpool

    remainingLayerPrbPerPool = poolMaxNumLayerPrb - sum(l1sp.newMinLayerPrbCapacityPerSp for l1sp in l1sps)
    if sum(l1sp.totalLayerPrbGbrDemandPerSp for l1sp in l1sps) > 0:
        l1sps.sort(key=lambda x: min(x.totalLayerPrbGbrDemandPerSp, x.maxLayerPrbGbrAllocLimitSp))

        for i, l1sp in enumerate(l1sps):
            l1sp.newGbrLayerPrbAllocationPerSp = math.floor((remainingLayerPrbPerPool -
                                                             sum(l1sps[j].newGbrLayerPrbAllocationPerSp
                                                                 for j in range(0, i))) *
                                                            (l1sp.totalLayerPrbGbrDemandPerSp /
                                                             sum(l1sps[k].totalLayerPrbGbrDemandPerSp
                                                                 for k in range(i, len(l1sps)))))
            l1sp.newGbrLayerPrbAllocationPerSp = min(l1sp.maxLayerPrbGbrAllocLimitSp,
                                                     l1sp.newGbrLayerPrbAllocationPerSp)

    else:
        for l1sp in l1sps:
            l1sp.newGbrLayerPrbAllocationPerSp = 0

    for l1sp in l1sps:
        l1sp.newTotalAllocLayerPrbSp = l1sp.newMinLayerPrbCapacityPerSp + l1sp.newGbrLayerPrbAllocationPerSp

    # non GBR allocation per subpool
    remainingLayerPrbPerPool = poolMaxNumLayerPrb - sum(l1sp.newTotalAllocLayerPrbSp for l1sp in l1sps)
    if debug:
        print('remainingLayerPrbPerPool before Round1: {}'.format(remainingLayerPrbPerPool))
        for l1sp in l1sps:
            print("l1sp before Round1: {}".format(l1sp.__dict__).replace(',', '\n'))

    # Round 1 of ULTDD Algo (5G_UP_ALG_26880)

    if dlul == "ul" and cells[0].cellType == '8DL8UL':
        # if (l1sps[0].totalLayerPrbNonGbrDemandPerSp + l1sps[1].totalLayerPrbNonGbrDemandPerSp) > 0:
        if sum(l1sp.totalLayerPrbNonGbrDemandPerSp for l1sp in l1sps) > 0:

            # Sort l1sps based on totalLayerPrbGbrDemandPerSp and maxLayerPrbGbrAllocLimitSp
            l1sps.sort(key=lambda x: min(x.totalLayerPrbNonGbrDemandPerSp, x.maxLayerPrbNonGbrAllocLimitSp))
            for i, l1sp in enumerate(l1sps):
                l1sp.newNonGbrLayerPrbAllocationPerSp = math.floor((remainingLayerPrbPerPool -
                                                                    sum(l1sps[j].newNonGbrLayerPrbAllocationPerSp
                                                                        for j in range(0, i))) *
                                                                   (l1sp.totalLayerPrbNonGbrDemandPerSp /
                                                                    sum(l1sps[k].totalLayerPrbNonGbrDemandPerSp
                                                                        for k in range(i, len(l1sps)))))
            if debug:
                print('step1.1')
                print('l1sps[0].newNonGbrLayerPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrLayerPrbAllocationPerSp))
                print('l1sps[1].newNonGbrLayerPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrLayerPrbAllocationPerSp))

            for i, l1sp in enumerate(l1sps):
                l1sp.newNonGbrLayerPrbAllocationPerSp = max(l1sp.newNonGbrLayerPrbAllocationPerSp,
                                                            remainingLayerPrbPerPool -
                                                            sum(l1sps[j].newNonGbrLayerPrbAllocationPerSp for j in
                                                                range(0, i)) -
                                                            sum(min(l1sps[k].totalLayerPrbNonGbrDemandPerSp,
                                                                    l1sps[k].maxLayerPrbNonGbrAllocLimitSp) for k in
                                                                range(i + 1, len(l1sps))))
            if debug:
                print('step1.2')
                print('l1sps[0].newNonGbrLayerPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrLayerPrbAllocationPerSp))
                print('l1sps[1].newNonGbrLayerPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrLayerPrbAllocationPerSp))

            for l1sp in l1sps:
                l1sp.newNonGbrLayerPrbAllocationPerSp = min(l1sp.maxLayerPrbNonGbrAllocLimitSp,
                                                            l1sp.newNonGbrLayerPrbAllocationPerSp)

            if debug:
                print('step1.3')
                print('l1sps[0].newNonGbrLayerPrbAllocationPerSp: {}'.format(l1sps[0].newNonGbrLayerPrbAllocationPerSp))
                print('l1sps[1].newNonGbrLayerPrbAllocationPerSp: {}'.format(l1sps[1].newNonGbrLayerPrbAllocationPerSp))

        else:
            for l1sp in l1sps:
                l1sp.newNonGbrLayerPrbAllocationPerSp = 0

        if debug:
            for l1sp in l1sps:
                print("l1sp before Round2: {}".format(l1sp.__dict__).replace(',', '\n'))

        remainingLayerPrbPerPool = max(0, remainingLayerPrbPerPool -
                                       sum(l1sp.newNonGbrLayerPrbAllocationPerSp for l1sp in l1sps))

        if debug:
            print('remainingLayerPrbPerPool before Round2: {}'.format(remainingLayerPrbPerPool))
        for l1sp in l1sps:
            l1sp.newNonGbrLayerPrbAllocationPerSpRound1 = l1sp.newNonGbrLayerPrbAllocationPerSp
            l1sp.totalLayerPrbNonGbrDemandPerSpRound2 = max(0, l1sp.totalLayerPrbNonGbrDemandPerSp -
                                                            l1sp.newNonGbrLayerPrbAllocationPerSp)

            # l1sp.maxLayerPrbNonGbrAllocLimitSp = 0
            l1sp.maxLayerPrbNonGbrAllocLimitSpRound2 =\
                sum(min(l1cell.layerPrbDemandNonGbr, max(0, l1cell.maxCellLayerPrb - l1cell.numMinLayerPrbAlloc -
                                                         l1cell.layerPrbDemandGbr)) for l1cell in l1sps[i_l1sp].cells)
            l1sp.maxLayerPrbNonGbrAllocLimitSpRound2 =\
                (l1sp.maxLayerPrbNonGbrAllocLimitSpRound2 - l1sp.newNonGbrLayerPrbAllocationPerSp)
        # if there is still remaining pool capacity after Round1, provide additinal allocaiton
        # as described in this step section using updated values from Round1:

        # Round2 of ULTDD Algo (5G_UP_ALG_26880)
        if remainingLayerPrbPerPool > 0:
            for l1sp in l1sps:
                l1sp.totalLayerPrbNonGbrDemandPerSp = l1sp.totalLayerPrbNonGbrDemandPerSpRound2
                l1sp.maxLayerPrbNonGbrAllocLimitSp = l1sp.maxLayerPrbNonGbrAllocLimitSpRound2
                # remainingLayerPrbPerPool = max(0, remainingLayerPrbPerPool -
                #                                 l1sp.newNonGbrLayerPrbAllocationPerSp)
                l1sp.newNonGbrLayerPrbAllocationPerSpRound1 = l1sp.newNonGbrLayerPrbAllocationPerSp
                l1sp.newNonGbrLayerPrbAllocationPerSp = 0

            # l1sp.maxLayerPrbNonGbrAllocLimitSp - l1sp.newNonGbrLayerPrbAllocationPerSp
        if debug:
            for l1sp in l1sps:
                print("l1sp after Round2: {}".format(l1sp.__dict__).replace(',', '\n'))
                print('remainingLayerPrbPerPool after Round2: {}'.format(remainingLayerPrbPerPool))

    # End Of Round2
    if sum(l1sp.totalLayerPrbNonGbrDemandPerSp for l1sp in l1sps) > 0:

        l1sps.sort(key=lambda x: min(x.totalLayerPrbNonGbrDemandPerSp, x.maxLayerPrbNonGbrAllocLimitSp))
        for i, l1sp in enumerate(l1sps):
            try:
                l1sp.newNonGbrLayerPrbAllocationPerSp = math.floor(
                    (remainingLayerPrbPerPool - sum(l1sps[j].newNonGbrLayerPrbAllocationPerSp for j in range(0, i))) * (
                        l1sp.totalLayerPrbNonGbrDemandPerSp / sum(
                            l1sps[k].totalLayerPrbNonGbrDemandPerSp for k in range(i, len(l1sps)))))
            except ZeroDivisionError:
                l1sp.newNonGbrLayerPrbAllocationPerSp = math.floor(
                    (remainingLayerPrbPerPool - sum(l1sps[j].newNonGbrLayerPrbAllocationPerSp for j in range(0, i))))
            if debug:
                print('step2.1')
                print('l1sps[{}].newNonGbrLayerPrbAllocationPerSp: {}'.format(i, l1sp.newNonGbrLayerPrbAllocationPerSp))
            l1sp.newNonGbrLayerPrbAllocationPerSp = min(
                l1sp.maxLayerPrbNonGbrAllocLimitSp, l1sp.newNonGbrLayerPrbAllocationPerSp)
            if debug:
                print('step2.2')
                print('l1sps[{}].newNonGbrLayerPrbAllocationPerSp: {}'.format(i, l1sp.newNonGbrLayerPrbAllocationPerSp))

    else:
        for l1sp in l1sps:
            l1sp.newNonGbrLayerPrbAllocationPerSp = 0

    if dlul == "ul" and cells[0].cellType == '8DL8UL':
        for l1sp in l1sps:
            l1sp.newNonGbrLayerPrbAllocationPerSp += l1sp.newNonGbrLayerPrbAllocationPerSpRound1

    for l1sp in l1sps:
        l1sp.newTotalAllocLayerPrbSp = l1sp.newTotalAllocLayerPrbSp + l1sp.newNonGbrLayerPrbAllocationPerSp

    remainingLayerPrbPerPool = poolMaxNumLayerPrb - sum(l1sp.newTotalAllocLayerPrbSp for l1sp in l1sps)

    # Sorting subpools
    for l1sp in l1sps:
        l1sp.spSortingCriteria1 = l1sp.maxSpLayerPrb
        l1sp.spSortingCriteria2 = l1sp.maxSpLayerPrb - l1sp.newTotalAllocLayerPrbSp

    l1sps.sort(key=lambda x: (x.spSortingCriteria1, x.spSortingCriteria2))
    if debug:
        for l1sp in l1sps:
            print("l1sp before  Distributing: {}".format(l1sp.__dict__).replace(',', '\n'))

    # Distributing remaining resources until SP's max
    for i, l1sp in enumerate(l1sps):
        l1sp.newTotalAllocLayerPrbSp =\
            min(l1sp.maxSpLayerPrb, l1sp.newTotalAllocLayerPrbSp + max(
                0, math.floor(remainingLayerPrbPerPool * (
                        l1sp.newTotalAllocLayerPrbSp / (sum(l1sps[k].newTotalAllocLayerPrbSp for k in
                                                            range(i, len(l1sps)))))),
                remainingLayerPrbPerPool - sum(l1sps[k].spSortingCriteria2 for k in range(i + 1, len(l1sps)))))
        remainingLayerPrbPerPool = poolMaxNumLayerPrb - sum(l1spi.newTotalAllocLayerPrbSp for l1spi in l1sps)

# Distributing remaining resources beyond SP's max
    for i, l1sp in enumerate(l1sps):
        l1sp.newTotalAllocLayerPrbSp = min(l1sp.maxSpLayerPrb, l1sp.newTotalAllocLayerPrbSp +
                                           max(0, remainingLayerPrbPerPool -
                                               sum(l1sps[k].spSortingCriteria2 for k in range(i + 1, len(l1sps))))
                                           )
        remainingLayerPrbPerPool = poolMaxNumLayerPrb - sum(l1spi.newTotalAllocLayerPrbSp for l1spi in l1sps)

#  (5) Allocate the rest of remaining Layer PRBs of the pool, if any, equally between the subpools
    for i, l1sp in enumerate(l1sps):
        l1sp.newTotalAllocLayerPrbSp = (l1sp.newTotalAllocLayerPrbSp +
                                        math.floor(remainingLayerPrbPerPool / (len(l1sps) - i)))

        remainingLayerPrbPerPool = poolMaxNumLayerPrb - sum(l1spi.newTotalAllocLayerPrbSp for l1spi in l1sps)

    #  Determine final values of SP capacity
    for l1sp in l1sps:
        l1sp.maxLayerPrbL1Sp = l1sp.newTotalAllocLayerPrbSp

    if debug:
        for l1sp in l1sps:
            print("l1sp after InterSP: {}".format(l1sp.__dict__).replace(',', '\n'))
        for celli in cells:
            print("celli after InterSP: {}".format(celli.__dict__).replace(',', '\n'))

    # INTRA SP PRB POOLING
    l1sps.sort(key=lambda x: x.spid)
    # Cells updated with current PRB demand
    cells = []
    for i_cell in range(0, ncells):
        cells.append(
            cell(nrcellIds[i_cell]['lcrId'], 0 if nrcellIds[i_cell]['lcrId'] in l1spcells[0] else 1, layers[i_cell],
                 numMinPrbAlloc[i_cell], maxCellPrb[i_cell],
                 UL_PRB_Demand['gbrPrbDemand'][i_cell],
                 UL_PRB_Demand['nonGbrPrbDemand'][i_cell], cellType[i_cell], longPucchNumPuschPrb[i_cell]))

    for l1sp in l1sps:
        l1sp.cells = []
        for cell in cells:
            if cell.cellid in l1sp.l1spcells:
                l1sp.cells.append(cell)

    # End update cells with current PRB demand
    poolPotentialLayerPrbs = poolMaxNumLayerPrb
    sumCellPotentialLayerPrbs = 0

    for i, l1sp in enumerate(l1sps):

        l1sp.cells.sort(key=lambda x: (x.cellSortingCriteria1, x.cellSortingCriteria2))

        for l1cells in l1sp.cells:
            print('after sorting: l1sp: {}, cells: {}'.format(i, l1cells.__dict__).replace(',', '\n'))

        l1SpPoolLayerPrbToShare = l1sp.newTotalAllocLayerPrbSp
        if debug:
            print('l1SpPoolLayerPrbToShare: {}'.format(l1SpPoolLayerPrbToShare))

        # for lcrId in l1sp.l1spcells:
        #     i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]
        l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - sum(l1cell.numAllocCellLayerPrb for l1cell in l1sp.cells)

        sumNumAllocCellLayerPrb = 0

        # GBR
        # if a == 1:
        for icell, l1cell in enumerate(l1sp.cells):
            # i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]
            # i_cells = [next(i for i, cell in enumerate(cells) if cell.cellid == lcrId) for lcrId in l1sp.l1spcells]
            sumLayerPrbDemandGbrGTEi = sum(l1sp.cells[k].layerPrbDemandGbr for k in range(icell, len(l1sp.cells)))

            if sumLayerPrbDemandGbrGTEi == 0:
                l1cell.allocLayerPrbGbr = 0
            else:
                l1cell.allocLayerPrbGbr = l1SpPoolLayerPrbToShare * \
                                          float(l1cell.layerPrbDemandGbr) / sumLayerPrbDemandGbrGTEi
                l1cell.allocLayerPrbGbr = min(
                    l1cell.maxCellLayerPrb - l1cell.numMinLayerPrbAlloc,
                    l1cell.layerPrbDemandGbr, l1cell.allocLayerPrbGbr)
                l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - l1cell.allocLayerPrbGbr

            l1cell.numAllocCellLayerPrb = l1cell.numAllocCellLayerPrb + l1cell.allocLayerPrbGbr
            sumNumAllocCellLayerPrb = sumNumAllocCellLayerPrb + l1cell.numAllocCellLayerPrb

            l1cell.cellSortingCriteria1 = min(l1cell.maxCellLayerPrb -
                                              l1cell.numAllocCellLayerPrb,
                                              l1cell.layerPrbDemandNonGbr)
            l1cell.cellSortingCriteria2 = l1cell.layerPrbDemandNonGbr

        if debug:
            print('l1SpPoolLayerPrbToShare: {}'.format(l1SpPoolLayerPrbToShare))
            print('l1sp.maxLayerPrbL1Sp: {}'.format(l1sp.maxLayerPrbL1Sp))
        # l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - sumNumAllocCellLayerPrb

        l1sp.cells.sort(key=lambda x: (x.cellSortingCriteria1, x.cellSortingCriteria2))

        l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - sum(l1cell.allocLayerPrbNonGbr for l1cell in l1sp.cells)
        # non GBR
        for icell, l1cell in enumerate(l1sp.cells):
            print('after sorting: sp: {}, i_cells: {}'.format(l1sp.spid, l1cell.cellid))
        # Step 1 for MUMIMO UL Cells
        if dlul == "ul" and cells[0].cellType == '8DL8UL':
            l1sp.cells.sort(key=lambda x: (min(x.allocLayerPrbNonGbrLimitCell -
                                               x.numAllocCellLayerPrb, x.layerPrbDemandNonGbr)))

            # if len(l1sp.l1spcells) > 1:
            #     # print('before sorting: SpCells: {}, i_cells: {}'.format(l1sp.l1spcells, i_cells))
            #     if (min(cells[i_cells[0]].allocLayerPrbNonGbrLimitCell -
            #             cells[i_cells[0]].numAllocCellLayerPrb, cells[i_cells[0]].layerPrbDemandNonGbr) >
            #         min(cells[i_cells[1]].allocLayerPrbNonGbrLimitCell -
            #              cells[i_cells[1]].numAllocCellLayerPrb, cells[i_cells[1]].layerPrbDemandNonGbr)):
            #         l1sp.l1spcells.reverse()
            #         i_cells.reverse()
            for icell, l1cell in enumerate(l1sp.cells):

                if sum(l1sp.cells[k].layerPrbDemandNonGbr for k in range(icell, len(l1sp.cells))) > 0:
                    l1cell.allocLayerPrbNonGbr = min(l1cell.layerPrbDemandNonGbr,
                                                     l1SpPoolLayerPrbToShare *
                                                     l1cell.layerPrbDemandNonGbr /
                                                     sum(l1sp.cells[k].layerPrbDemandNonGbr
                                                         for k in range(icell, len(l1sp.cells))))

                    l1cell.allocLayerPrbNonGbr = max(l1cell.allocLayerPrbNonGbr,
                                                     l1SpPoolLayerPrbToShare -
                                                     sum(min(l1sp.cells[k].allocLayerPrbNonGbrLimitCell -
                                                             l1sp.cells[k].numAllocCellLayerPrb,
                                                             l1sp.cells[k].layerPrbDemandNonGbr)
                                                         for k in range(icell + 1, len(l1sp.cells))))

                    l1cell.allocLayerPrbNonGbr = max(0, min(l1cell.allocLayerPrbNonGbr,
                                                            (l1cell.allocLayerPrbNonGbrLimitCell -
                                                             l1cell.numAllocCellLayerPrb)))

                    l1cell.layerPrbDemandNonGbrRound2 = (l1cell.layerPrbDemandNonGbr -
                                                         l1cell.allocLayerPrbNonGbr)
                    l1cell.numAllocCellLayerPrb = (l1cell.numAllocCellLayerPrb +
                                                   l1cell.allocLayerPrbNonGbr)

                    l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - l1cell.allocLayerPrbNonGbr

            if debug:
                for lcrId in l1sp.l1spcells:
                    i_cell = [i for i, cell in enumerate(cells) if cell.cellid == lcrId][0]

            # Round 2 for MUMIMO UL Cells
            if l1SpPoolLayerPrbToShare > 0:
                for icell, l1cell in enumerate(l1sp.cells):
                    l1cell.layerPrbDemandNonGbrTemp = l1cell.layerPrbDemandNonGbr
                    l1cell.layerPrbDemandNonGbr = l1cell.layerPrbDemandNonGbrRound2
                l1sp.cells.sort(key=lambda x: min(x.maxCellLayerPrb -
                                                  x.numAllocCellLayerPrb, x.layerPrbDemandNonGbr))
                print('sum: {}'.format(sum(l1sp.cells[k].layerPrbDemandNonGbr for k in range(icell, len(l1sp.cells)))))
                for icell, l1cell in enumerate(l1sp.cells):
                    if sum(l1sp.cells[k].layerPrbDemandNonGbr for k in range(icell, len(l1sp.cells))) > 0:
                        l1cell.allocLayerPrbNonGbr = min(l1cell.layerPrbDemandNonGbr,
                                                         l1SpPoolLayerPrbToShare *
                                                         l1cell.layerPrbDemandNonGbr /
                                                         sum(l1sp.cells[k].layerPrbDemandNonGbr
                                                             for k in range(icell, len(l1sp.cells))))
                        l1cell.allocLayerPrbNonGbr = max(0, min(l1cell.allocLayerPrbNonGbr,
                                                                (l1cell.maxCellLayerPrb -
                                                                 l1cell.numAllocCellLayerPrb)))
                        l1cell.numAllocCellLayerPrb = (l1cell.numAllocCellLayerPrb +
                                                       l1cell.allocLayerPrbNonGbr)
                        l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - l1cell.allocLayerPrbNonGbr

                if debug:
                    print('l1SpPoolLayerPrbToShare after Round2 IntraSp: {}'.format(l1SpPoolLayerPrbToShare))
                    for lcrId in l1sp.l1spcells:
                        print("celli after Round2 IntraSp: {}".format(l1cell.__dict__).replace(',', '\n'))

        if debug:
            for celli in cells:
                print("celli before IntraSP: {}".format(celli.__dict__).replace(',', '\n'))
        for icell, l1cell in enumerate(l1sp.cells):

            sumLayerPrbDemandNonGbrGTEi = sum(l1sp.cells[k].layerPrbDemandNonGbr for k in range(icell, len(l1sp.cells)))

            if sumLayerPrbDemandNonGbrGTEi == 0:
                l1cell.allocLayerPrbNonGbr = 0
            else:
                l1cell.allocLayerPrbNonGbr = min(l1cell.layerPrbDemandNonGbr,
                                                 l1SpPoolLayerPrbToShare *
                                                 l1cell.layerPrbDemandNonGbr /
                                                 sumLayerPrbDemandNonGbrGTEi)
                l1cell.allocLayerPrbNonGbr = min(l1cell.maxCellLayerPrb -
                                                 l1cell.numAllocCellLayerPrb,
                                                 l1cell.allocLayerPrbNonGbr)
                l1cell.allocLayerPrbNonGbr = max(0, l1cell.allocLayerPrbNonGbr)
                if debug:
                    print('l1cell.allocLayerPrbNonGbr: {}'.format(l1cell.allocLayerPrbNonGbr))
                    print('l1cell.numAllocCellLayerPrb: {}'.format(l1cell.numAllocCellLayerPrb))

            l1cell.numAllocCellLayerPrb = l1cell.numAllocCellLayerPrb + l1cell.allocLayerPrbNonGbr
            l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - l1cell.allocLayerPrbNonGbr

            poolPotentialLayerPrbs =\
                poolPotentialLayerPrbs - l1cell.allocLayerPrbGbr - l1cell.numMinLayerPrbAlloc
            sumCellPotentialLayerPrbs = sumCellPotentialLayerPrbs + \
                (l1cell.maxCellLayerPrb - l1cell.allocLayerPrbGbr - l1cell.numMinLayerPrbAlloc)
            l1cell.cellSortingCriteria1 = max(l1cell.maxCellLayerPrb -
                                              l1cell.numAllocCellLayerPrb, 0)
            l1cell.cellSortingCriteria2 = random.randint(0, 100)

        l1sp.cells.sort(key=lambda x: (x.cellSortingCriteria1, x.cellSortingCriteria2))

        for icell, l1cell in enumerate(l1sp.cells):
            allocatedLayerPrbSubsequentInclusive = sum(l1sp.cells[k].numAllocCellLayerPrb
                                                       for k in range(icell, len(l1sp.cells)))

            potentialLayerPrbSubsequent = sum(l1sp.cells[k].maxCellLayerPrb *
                                              l1sp.cells[k].numAllocCellLayerPrb
                                              for k in range(icell + 1, len(l1sp.cells)))

            l1cell.allocLayerPrbRest = max(math.floor(l1SpPoolLayerPrbToShare * l1cell.numAllocCellLayerPrb /
                                                      allocatedLayerPrbSubsequentInclusive),
                                           l1SpPoolLayerPrbToShare - potentialLayerPrbSubsequent)
            l1cell.allocLayerPrbRest = min(l1cell.maxCellLayerPrb - l1cell.numAllocCellLayerPrb,
                                           l1cell.allocLayerPrbRest)
            l1cell.allocLayerPrbRest = max(l1cell.allocLayerPrbRest, 0)

            l1cell.numAllocCellLayerPrb = l1cell.numAllocCellLayerPrb + l1cell.allocLayerPrbRest
            l1SpPoolLayerPrbToShare = l1SpPoolLayerPrbToShare - l1cell.allocLayerPrbRest

    #  BBRM USABLE CELL PRB
    # for l1sp in l1sps:
    #     print("l1sp after IntraSP: {}".format(l1sp.__dict__).replace(',', '\n'))

    # for celli in cells:
    #     print("celli after IntraSP: {}".format(celli.__dict__).replace(',', '\n'))
    cells.sort(key=lambda cell: cell.cellid)
    result = [int(x.numAllocCellLayerPrb) for x in cells]
    return result


def ComputeMaxCsiRsPerCsiRsPool(csirsGroups, maxCsiRsNumber):
    maxCsiRsPerCsiRsPool = [0, 0, 0]
    i = 0
    for item in csirsGroups:
        maxCsiRsPerCsiRsPool[item['csirsPoolingGroupId']] = maxCsiRsNumber[i]
        i += 1
    return maxCsiRsPerCsiRsPool


def createCellCsiRs(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod, actInfTddFrameMuting="false",
                    csirsNbWithinReportPeriod_Set1=1, actTddCsirsAllocOptimization="false",
                    maxCsiRsPerCsiRsPool=[4, 4, 4]):
    csiRsConfig = []

    maxCsiRsPoolGroups = 3

    if actTddCsirsAllocOptimization == "true":
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}

    trsSlot = [trsSlotOffset[framestructure]['i'], trsSlotOffset[framestructure]['i'] + 1,
               trsSlotOffset[framestructure]['j'], trsSlotOffset[framestructure]['j'] + 1]

    print('csiRsPeriod NIDD: {}'.format(csiRsPeriod))
    print('actCsiMux: {}'.format(actCsiMux))
    print('actExplicitCsirsPoolSolution: {}'.format(actExplicitCsirsPoolSolution))
    print('actTddCsirsAllocOptimization: {}'.format(actTddCsirsAllocOptimization))

    # Calcul du CSI-RS resource periodicity
    csiRsPeriod = int(re.search(r"\d+", csiRsPeriod).group())
    print('csiRsPeriod Calculated: {}'.format(csiRsPeriod))
    if (csiRsPeriod / math.pow(2, csirsNbWithinReportPeriod_Set1 - 1)) > 40:
        csiRsPeriod = csiRsPeriod / math.pow(2, csirsNbWithinReportPeriod_Set1 - 1)
    else:
        csiRsPeriod = 40

    if actExplicitCsirsPoolSolution == "false" and actTddCsirsAllocOptimization == "false":

        print("CB008940 Cell Specific CSI-RS Config")

        if actInfTddFrameMuting == "true":
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 2
            rs4startSymb3 = 6
            rs4startSymb4 = 6
        elif actCsiMux == "false":
            rs1startSymb1 = 12
            rs2startSymb1 = 2
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 6
            rs4startSymb3 = 10
            rs4startSymb4 = 12
        elif actCsiMux == "true":
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 10
            rs4startSymb2 = 10
            rs4startSymb3 = 12
            rs4startSymb4 = 12
        else:
            exit(-1)

        for csiRsPoolGrpId in range(3):
            rs1 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + csiRsPoolGrpId * 40,
                    'startingSymbolIndex': rs1startSymb1}]
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40, 'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40, 'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40, 'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

    elif actExplicitCsirsPoolSolution == "true" and actTddCsirsAllocOptimization == "false":

        print("CB010513 Cell Specific CSI-RS Config")

        # StartSymbol par reseource set pour chaque csiRsPoolingGrp
        rs1startSymb1 = [10, 10, 12]
        rs2startSymb1 = [12, 12, 10]
        rs4startSymb1 = [2, 2, 2]
        rs4startSymb2 = [6, 6, 6]

        if csiRsPeriod == 40:
            # CsiRsPoolingGroupId = 0, 1
            for csiRsPoolGrpId in range(2):
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            # CsiRsPoolingGroupId = 2
            csiRsPoolGrpId = 2
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

        elif csiRsPeriod == 80:
            # CsiRsPoolingGroupId = 0, 1
            for csiRsPoolGrpId in range(2):
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            # CsiRsPoolingGroupId = 2
            csiRsPoolGrpId = 2
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

        elif csiRsPeriod == 160 or csiRsPeriod == 320:
            # CsiRsPoolingGroupId = 0, 1
            for csiRsPoolGrpId in range(2):
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                        (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            # CsiRsPoolingGroupId = 2
            csiRsPoolGrpId = 2
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                    (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                    (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
        else:
            print("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    elif actTddCsirsAllocOptimization == "true":

        print("CB009836 Cell Specific CSI-RS Config")

        if csiRsPeriod == 40:

            for csiRsPoolGrpId in range(3):
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})

        elif csiRsPeriod == 80:
            for csiRsPoolGrpId in range(2):
                rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            csiRsPoolGrpId = 2
            rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
            rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
            rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                        {'res': rs4}]})

        elif csiRsPeriod == 160 or csiRsPeriod == 320:
            for csiRsPoolGrpId in range(3):
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})

        else:
            print("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    else:
        print("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    currentCsiRsGrp = 0
    for maxCsiRs in maxCsiRsPerCsiRsPool:
        if maxCsiRs == "1":
            del csiRsConfig[currentCsiRsGrp]['resource_set'][-2:]
        if maxCsiRs == "2":
            del csiRsConfig[currentCsiRsGrp]['resource_set'][-1]
        currentCsiRsGrp += 1

    return csiRsConfig
    # Update 112023 - scroquet
    # Add CB009836
    # Remove flag actBbPoolExtensionTddFr1 (10513) not used. Selection done with actExplicitCsirsPoolSolution


def createTrsCsiRs(frameStructure, beamCfg, slowPrbPoolingTddFr1DlAllowed,
                   actExplicitCsirsPoolSolution, actInfTddFrameMuting=False, actTddCsirsAllocOptimization="false"):
    if actTddCsirsAllocOptimization == "true":
        print('CB009836 Initial Slot Offset')
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        print('CB08940/CB010513 Initial Slot Offset')
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}

    ssBurstSetPeriod = 40
    nbBeams = int(beamCfg.split(" ")[0])
    csirsPoolingGroup = []

    print('slowPrbPoolingTddFr1DlAllowed: {}'.format(slowPrbPoolingTddFr1DlAllowed))
    print('actExplicitCsirsPoolSolution: {}'.format(actExplicitCsirsPoolSolution))
    print('actTddCsirsAllocOptimization: {}'.format(actTddCsirsAllocOptimization))

    for csiRsGroupId in range(3):

        # print("****************\ncsiRsGroupId: {}".format(csiRsGroupId))
        csirsPoolingGroup.append({"csirsPoolingGroupId": csiRsGroupId, "csirsTrackingResourceSet": []})

        # if slowPrbPoolingTddFr1DlAllowed == "true" and actBbPoolExtensionTddFr1 == "false":
        if slowPrbPoolingTddFr1DlAllowed == "true" and actExplicitCsirsPoolSolution == "false" and \
                actTddCsirsAllocOptimization == "false":
            print("CB008940 Config")
            if nbBeams <= 6:

                csiResourceConfig = {
                    0: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_4", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_8", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_4", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_8", 'RE': 1}
                        ],
                    1: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_4", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_8", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_4", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_8", 'RE': 4}
                        ],
                    2: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_5", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_9", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_5", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_9", 'RE': 2}
                        ],
                    3: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_5", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_9", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_5", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_9", 'RE': 8}
                        ],
                    4: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_6", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_10", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_6", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_10", 'RE': 1}
                        ],
                    5: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_6", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_10", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_6", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_10", 'RE': 4}
                        ],
                }

            elif nbBeams == 8:

                csiResourceConfig = {
                    0: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_4", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_8", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_4", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_8", 'RE': 1}
                        ],
                    1: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_4", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_8", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_4", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_8", 'RE': 4}
                        ],
                    2: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_5", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_9", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_5", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_9", 'RE': 2}
                        ],
                    3: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_5", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_9", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_5", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_9", 'RE': 8}
                        ],
                    4: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_4", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_8", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_4", 'RE': 1},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_8", 'RE': 1}
                        ],
                    5: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_4", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_8", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_4", 'RE': 4},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_8", 'RE': 4}
                        ],
                    6: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_5", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_9", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_5", 'RE': 2},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_9", 'RE': 2}
                        ],
                    7: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_5", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                         'symbol': "SYMBOL_9", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_5", 'RE': 8},
                        {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                         'symbol': "SYMBOL_9", 'RE': 8}
                        ],
                }

            else:
                print("Wrong number of beams")
                csiRsConfig = None

        # elif slowPrbPoolingTddFr1DlAllowed == "true" and actBbPoolExtensionTddFr1 == "true":
        elif (slowPrbPoolingTddFr1DlAllowed == "true" and actExplicitCsirsPoolSolution == "true") or \
                actTddCsirsAllocOptimization == "true":
            if actTddCsirsAllocOptimization == "true":
                print("CB009836 Config")
            else:
                print("CB010513 Config")
            # print("-----------------\ni: {}, j: {}".format(trsSlotOffset[frameStructure]['i'],
            # trsSlotOffset[frameStructure]['j']))
            csiResourceConfig = {
                0: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_4", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_8", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_4", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_8", 'RE': 1}
                    ],
                1: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_4", 'RE': 4},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_8", 'RE': 4},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_4", 'RE': 4},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_8", 'RE': 4}
                    ],
                2: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 2}
                    ],
                3: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_5", 'RE': 8},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 8},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 8},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 8}
                    ],
                4: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_4", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_8", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_4", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_8", 'RE': 1}
                    ],
                5: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_4", 'RE': 4},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_8", 'RE': 4},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_4", 'RE': 4},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_8", 'RE': 4}
                    ],
                6: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 2}
                    ],
                7: [{'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_5", 'RE': 8},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 8},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 8},
                    {'slot': trsSlotOffset[frameStructure]['j'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 8}
                    ],
            }
            print(csiResourceConfig)

        else:
            print("Pooling activation flag combiantion NOT SUPPORTED")
            csiRsConfig = None

        for beamId in range(nbBeams):

            # print("****************\nbeamId: {}".format(beamId))
            csirsPoolingGroup[csiRsGroupId]['csirsTrackingResourceSet'].append({"ssbIndex": beamId,
                                                                                "csirsTrackingResource": []})
            for csiResourceInst in csiResourceConfig[beamId]:
                # targetConfig['csirsPoolingGroupIds'][csiRsGroupId]['csirsTrackingResourceSet']
                # [beamId]['csirsTrackingResource'].append({
                # print(csiResourceInst)
                csirsPoolingGroup[csiRsGroupId]['csirsTrackingResourceSet'][beamId]['csirsTrackingResource'].append({
                    "csirsTrackingSlotOffset": csiResourceInst['slot'],
                    "csirsTrackingSymbol": csiResourceInst['symbol'],
                    "csirsTrackingFreqDomainAllocation": csiResourceInst['RE']})

    return csirsPoolingGroup


def createCellCsiRs_v2(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                       csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups, cellList,
                       actTddCsirsAllocOptimization, actInfTddFrameMuting="false"):
    csiRsConfig = []
    csiRsPeriodicity = []

    maxCsiRsPoolGroups = 3

    if actTddCsirsAllocOptimization == "true":
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}

    trsSlot = [trsSlotOffset[framestructure]['i'], trsSlotOffset[framestructure]['i'] + 1,
               trsSlotOffset[framestructure]['j'], trsSlotOffset[framestructure]['j'] + 1]

    print('actCsiMux: {}'.format(actCsiMux))
    print('actExplicitCsirsPoolSolution: {}'.format(actExplicitCsirsPoolSolution))
    print('csiRsPeriod NIDD: {}'.format(csiRsPeriod))
    print('csirsNbWithinReportPeriod_Set1: {}'.format(csirsNbWithinReportPeriod_Set1))
    print('maxCsiRsPerCsiRsPool: {}'.format(maxCsiRsPerCsiRsPool))
    print('csiRsGroups: {}'.format(csiRsGroups))
    print('cellList: {}'.format(cellList))
    print('actTddCsirsAllocOptimization: {}'.format(actTddCsirsAllocOptimization))
    print('actInfTddFrameMuting: {}'.format(actInfTddFrameMuting))

    # Calcul du CSI-RS resource periodicity
    for i in range(len(csiRsPeriod)):
        csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod[i]).group())
        if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)) > 40:
            csiRsPeriodicity.append(int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)))
        else:
            csiRsPeriodicity.append(40)

    print('\nCalculated csiRsPeriodicity: {}'.format(csiRsPeriodicity))

    csiRsInfo = {}
    for item in csiRsGroups:
        index = cellList.index(str(item['lcrId']))
        # index = cellList.index(item['lcrId'])
        csiRsInfo[item['csirsPoolingGroupId']] = {"lcrId": item['lcrId'],
                                                  "csiRsReportPeriod": csiRsPeriodicity[index],
                                                  "maxCsiRs": maxCsiRsPerCsiRsPool[index]}

    print('\ncsiRsInfo: {}'.format(csiRsInfo))

    # CB008940
    if actExplicitCsirsPoolSolution == "false" and actTddCsirsAllocOptimization == "false":
        print("CB008940 Cell Specific CSI-RS Config")
        if actInfTddFrameMuting == "true":
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 2
            rs4startSymb3 = 6
            rs4startSymb4 = 6
        elif actCsiMux == "false":
            rs1startSymb1 = 12
            rs2startSymb1 = 2
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 6
            rs4startSymb3 = 10
            rs4startSymb4 = 12
        elif actCsiMux == "true":
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 10
            rs4startSymb2 = 10
            rs4startSymb3 = 12
            rs4startSymb4 = 12
        else:
            exit(-1)

        for csiRsPoolGrpId in range(3):
            rs1 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + csiRsPoolGrpId * 40,
                    'startingSymbolIndex': rs1startSymb1}]
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40, 'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40, 'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
    # CB010513
    elif actExplicitCsirsPoolSolution == "true" and actTddCsirsAllocOptimization == "false":
        print("CB010513 Cell Specific CSI-RS Config")
        # StartSymbol par reseource set pour chaque csiRsPoolingGrp
        rs1startSymb1 = [10, 10, 12]
        rs2startSymb1 = [12, 12, 10]
        rs4startSymb1 = [2, 2, 2]
        rs4startSymb2 = [6, 6, 6]

        # CsiRsPoolingGroupId = 0, 1
        for csiRsPoolGrpId in range(2):
            if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            elif (csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160
                  or csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320):
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                        (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                        ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})

            else:
                print("csiRsPeriod NOT SUPPORTED")
                csiRsConfig = None

        # CsiRsPoolingGroupId = 2
        csiRsPoolGrpId = 2
        if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
        elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
        elif (csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160
              or csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320):
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                    (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                    (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                    ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

        else:
            print("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    # CB009836
    elif actTddCsirsAllocOptimization == "true":
        print("CB009836 Cell Specific CSI-RS Config")
        # CsiRsPoolingGroupId = 0, 1
        for csiRsPoolGrpId in range(2):
            if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
                rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})
            elif (csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160
                  or csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320):
                for csiRsPoolGrpId in range(3):
                    rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                    rs4 = [
                        {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                         'startingSymbolIndex': 10},
                        {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                         'startingSymbolIndex': 10},
                        {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                         'startingSymbolIndex': 12},
                        {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                         'startingSymbolIndex': 12}]
                    csiRsConfig.append(
                        {'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                 {'res': rs4}]})

            else:
                print("csiRsPeriod NOT SUPPORTED")
                csiRsConfig = None

        # CsiRsPoolingGroupId = 2
        csiRsPoolGrpId = 2
        if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
            rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
            rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
            rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                        {'res': rs4}]})

        elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
            rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
            rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
            rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                        {'res': rs4}]})

        elif (csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160
              or csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320):
            for csiRsPoolGrpId in range(3):
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                                            {'res': rs4}]})

        else:
            print("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    else:
        print("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    for csiRsId in range(maxCsiRsPoolGroups):
        if csiRsInfo[csiRsId]['maxCsiRs'] == "1":
            del csiRsConfig[csiRsId]['resource_set'][-2:]
        if csiRsInfo[csiRsId]['maxCsiRs'] == "2":
            del csiRsConfig[csiRsId]['resource_set'][-1]

    print(csiRsConfig)

    return csiRsConfig


def onclick(event):
    # Check if the event was a mouse click
    if event.button == 1:
        # Get the coordinates of the clicked point
        x_clicked, y_clicked = event.xdata, event.ydata
        print(f"Clicked at x={x_clicked}, y={y_clicked}")


def create_Charts_from_TTI(tti_convert, algo_prbs, dlul, fig):
    # tti_convert = read_and_parse_tti_data(tti_csv)
    plots = [{'dataset': dlul + 'MetricIndData', 'metric': 'nonGbrPrbDemand'},
             {'dataset': dlul + 'MetricIndData', 'metric': 'gbrPrbDemand'},
             {'dataset': dlul + 'AllocatedPooledResourcesData', 'metric': 'numAllocCellPrb' + dlul.title()}]
    if dlul == 'dl':
        plots.append({'dataset': dlul + 'AllocatedPooledResourcesData', 'metric': 'hasZabPrivilege'})

    # nbOfNonConsecutiveSFNs = sum(numbers[i + 1] - numbers[i] != 5 for i in range(len(numbers) - 1))

    for j, plot in enumerate(plots):
        dataToPlot = get_data_series(tti_convert, plot['dataset'], plot['metric'])
        # if j == 0:
        # nbOfNonConsecutiveSFNs = sum(numbers[i + 1] - numbers[i] != 5 for i in range(len(numbers) - 1))

        # print(dataToPlot)
        lcrIds = sorted(set(d['lcrId'] for d in dataToPlot))
        samples_num = len(dataToPlot[0]['sfn'])
        # print(lcrIds)
        # print(list(d['nonGbrPrbDemand'] for d in dlprb if d['lcrId'] == '2'))
        linecolors = ['r', 'b', 'g', 'm', 'c', 'y', 'b']
        axs = fig.add_subplot(4, 2, j + 1)
        bottom = [0] * samples_num
        for i, lcrid in enumerate(lcrIds):
            dataToPlot_i = list(d[plot['metric']] for d in dataToPlot if d['lcrId'] == lcrid)[0]
            if dataToPlot_i:
                if plot['metric'] == "hasZabPrivilege":
                    axs.bar(list(d['sfn'] for d in dataToPlot if d['lcrId'] == lcrid)[0], dataToPlot_i,
                            color=linecolors[i], width=2.0, label='lcrId ' + lcrid, bottom=bottom)
                    bottom = [sum(i) for i in zip(bottom, dataToPlot_i)]
                    axs.set_xlabel('SFN')
                    axs.set_ylabel('hasZAB')
                    axs.set_title(plot['metric'])
                else:
                    axs.plot(list(d['sfn'] for d in dataToPlot if d['lcrId'] == lcrid)[0], dataToPlot_i,
                             linecolors[i], label='lcrId ' + lcrid)
                    axs.set_xlabel('SFN')
                    axs.set_ylabel('PRB')
                    axs.set_title(plot['metric'])
        plt.grid()
        plt.legend()
        plt.tight_layout()
        plt.subplots_adjust(hspace=0.2)
    if algo_prbs:
        dataToPlot1 = get_data_series(tti_convert, dlul + 'AllocatedPooledResourcesData',
                                      'numAllocCellPrb' + dlul.title())
        # print(dataToPlot1)
        lcrIds = sorted(set(d['lcrId'] for d in dataToPlot1))
        for i, lcrId in enumerate(lcrIds):
            # print(list(d['nonGbrPrbDemand'] for d in dlprb if d['lcrId'] == '2'))
            j += 1
            axs = fig.add_subplot(4, 2, j + 1) if i == 0 else fig.add_subplot(4, 2, j + 1, sharey=axs)
            dataToPlot1_i = \
                list(d['numAllocCellPrb' + dlul.title()] for d in dataToPlot1 if d['lcrId'] == lcrId)[0][1:-1]
            dataToPlot2_i = list(d['algorithmPrbs'][i] for d in algo_prbs)
            # print(dataToPlot1_i)
            # print(dataToPlot2_i)

            if dataToPlot2_i:
                axs.plot(list(d['sfn'] for d in dataToPlot1 if d['lcrId'] == lcrId)[0][1:-1], dataToPlot1_i,
                         linecolors[0], label='TTI Trace')
                axs.plot(list(d['sfn'] for d in algo_prbs), dataToPlot2_i,
                         linecolors[1], label='Algorithm')
                axs.set_xlabel('SFN')
                axs.set_ylabel('PRB')
                axs.set_title('Reported vs Calculated PRBs lcrId ' + lcrId)

                plt.grid()
                plt.legend()
                plt.tight_layout()
                plt.subplots_adjust(hspace=0.3)

    return fig


def Create_DLUL_Charts_from_TTI(tti_csv, tl, dl, ul, syslog_folder):
    tti_convert = read_and_parse_tti_data(tti_csv)
    fig_size = (12, 20)
    if dl:
        algo_prbs = algorithm_prbs(tti_convert, tl, 'dl', syslog_folder)
        print("algo PRBs: {}".format(algo_prbs))
        f1 = plt.figure(figsize=fig_size)
        f1 = create_Charts_from_TTI(tti_convert, algo_prbs, "dl", fig=f1)
        f1.canvas.set_window_title('DL TTI Analysis')
        f1.show()
    if ul:
        algo_prbs = algorithm_prbs(tti_convert, tl, 'ul', syslog_folder)
        f2 = plt.figure(figsize=fig_size)
        f2 = create_Charts_from_TTI(tti_convert, algo_prbs, "ul", fig=f2)
        f2.canvas.set_window_title('UL TTI Analysis')
        f2.show()


def Create_Excel_Charts_from_TTI(tti_csv, tl, dl, ul, syslog, scf_file='/tmp/scf_orig.xml', cb012605=False):
    tti_csv_File = tti_csv.split('/')[-1]
    # save_scf(tl, 'scf_charts.xml')
    debug = True
    cells = get_active_lcrIds(None)
    # scf.load_scf(scf_file)
    # cells_c = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
    # cells = (list(map(lambda x: x.split('NRCELL-')[1], cells_c)))

    excelFile = tti_csv.replace('.csv', '_output.xlsx')
    tti_convert = read_and_parse_tti_data(tti_csv)
    # print('cb012605: {}'.format(cb012605))
    # print("tti_convert: {}".format(tti_convert))

    wb = Workbook()

    dlul = [{"dir": "dl", "value": dl}, {"dir": "ul", "value": ul}]
    dl_mismatch = 0
    ul_mismatch = 0
    zab_mismatch = 0
    allocType = 'Layer' if cb012605 else ''

    for i_dlul, val_dlul in enumerate(dlul):
        if val_dlul['value']:
            ws = wb.create_sheet("PRB TTI vs Algo " + val_dlul['dir'].title())
            ws_charts = wb.create_sheet("Charts - PRB TTI vs Algo " + val_dlul['dir'].title())
            dataChartsOffset = 6
            columnOffset = 15
            algo_prbs = algorithm_prbs(tti_convert, scf_file, val_dlul['dir'], syslog, cb012605)
            algo_zab = 0 if cb012605 else algorithm_zab(tti_convert, scf_file, syslog)
            # nonGbrPrbDemand = get_data_series(tti_convert, val_dlul['dir'] + 'MetricIndData', 'nonGbrPrbDemand')
            numAllocCellPrb = get_data_series(tti_convert, val_dlul['dir'] +
                                              'AllocatedPooledResourcesData',
                                              'numAllocCell'+allocType+'Prb' + val_dlul['dir'].title())
            ZabAlloc = get_data_series(tti_convert, 'dlAllocatedPooledResourcesData', 'hasZabPrivilege')
            if debug:
                print('algo_prbs: {}'.format(algo_prbs))
                print("ZabAlloc: {}".format(ZabAlloc))
                print("algo ZAB: {}".format(algo_zab))
            ws.cell(row=1, column=1, value='SFN')
            ws.cell(row=1, column=2, value='lcrId')
            ws.cell(row=1, column=3, value='numAllocCell'+allocType+'Prb' + val_dlul['dir'].title())
            ws.cell(row=1, column=4, value='algorithmPrbs')

            numcells = len(cells)

            for i, i_algo in enumerate(algo_prbs[:-3]):
                if debug:
                    print("i: {}".format(i))
                    print("i_algo: {}".format(i_algo))
                for j in range(numcells):
                    if i == 0:
                        ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 1, value='SFN')
                        ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 2, value='lcrId')
                        ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 3,
                                       value='numAllocCell'+allocType+'Prb' + val_dlul['dir'].title())
                        ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 4, value='algorithmPrbs')
                        ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 5, value='diff')
                    try:
                        print('numAllocCellPrb: {}'.format(numAllocCellPrb))
                        print('i_algo[sfn]: {}'.format(i_algo['sfn']))
                        numAlloc_sfn_i = \
                            [d['sfn'] for d in numAllocCellPrb if d['lcrId'] == str(cells[j])][0].index(i_algo['sfn'])
                        algo_i = i_algo['algorithmPrbs'][j]
                        numAlloc_i = None if algo_i is None else \
                            [d['numAllocCell'+allocType+'Prb' + val_dlul['dir'].title()] for d in numAllocCellPrb
                             if d['lcrId'] == str(cells[j])][0][numAlloc_sfn_i]
                    except (ValueError, IndexError):
                        numAlloc_i = None
                        algo_i = None
                    try:
                        if abs(numAlloc_i - algo_i) > 1:
                            if val_dlul['dir'] == 'dl':
                                dl_mismatch += 1
                            else:
                                ul_mismatch += 1
                    except TypeError:
                        pass
                    ws.cell(row=numcells * i + j + 2, column=1, value=i_algo['sfn'])
                    ws.cell(row=numcells * i + j + 2, column=2, value=int(cells[j]))
                    ws.cell(row=numcells * i + j + 2, column=3,
                            value=numAlloc_i)
                    ws.cell(row=numcells * i + j + 2, column=4, value=algo_i)
                    ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 1, value=i_algo['sfn'])
                    ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 2, value=int(cells[j]))
                    ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 3,
                                   value=numAlloc_i)
                    ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 4, value=algo_i)
                    ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 5,
                                   value="=" + colLetter(columnOffset + dataChartsOffset * j + 2) + str(i + 2) + "-" +
                                         colLetter(columnOffset + dataChartsOffset * j + 3) + str(i + 2))

            for i_cell in range(numcells):
                try:
                    chart = LineChart()
                    data = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_cell + 3, min_row=1,
                                     max_col=columnOffset + dataChartsOffset * i_cell + 4, max_row=len(algo_prbs))
                    cats = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_cell + 1, min_row=2,
                                     max_col=columnOffset + dataChartsOffset * i_cell + 1, max_row=len(algo_prbs))
                    chart.add_data(data, titles_from_data=True)
                    chart.set_categories(cats)
                    chart.title = "numAllocCell"+allocType+"Prb" + val_dlul['dir'].title() + " lcrId " + str(
                        cells[i_cell])
                    chart.x_axis.title = "SFN"
                    chart.y_axis.title = "PRB"
                    # chart.series[1].graphicalProperties.line.solidFill = "FF0000"
                    chart.series[0].graphicalProperties.line.width = 15000
                    chart.series[1].graphicalProperties.line.width = 15000
                    chart.series[1].graphicalProperties.line.dashStyle = "dash"
                    diffchart = BarChart()
                    diffdata = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_cell + 5, min_row=1,
                                         max_col=columnOffset + dataChartsOffset * i_cell + 5, max_row=len(algo_prbs))
                    diffchart.add_data(diffdata, titles_from_data=True)
                    diffchart.y_axis.axId = 20
                    diffchart.y_axis.title = "diff"
                    diffchart.y_axis.crosses = "max"
                    chart += diffchart
                    chart.width = 20
                    chart.height = 10
                    # for row in ws_charts.iter_rows():
                    #     for cell in row:
                    #         cell.font = Font(color='FFFFFFFF')
                    ws_charts.add_chart(chart, "B{}".format(21 * i_cell + 2))
                except ValueError:
                    print('no data for cell {}'.format(i_cell))
                    pass

            if val_dlul['dir'] == 'dl' and not cb012605:
                ws_charts = wb.create_sheet("Charts - ZAB TTI vs Algo ")
                dataChartsOffset = 6
                columnOffset = 15
                for i, i_algo in enumerate(algo_zab[:-1]):
                    # print("i: {}".format(i))
                    # print("i_algo: {}".format(i_algo))
                    for j in range(numcells):
                        if i == 0:
                            ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 1, value='SFN')
                            ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 2, value='lcrId')
                            ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 3,
                                           value='hasZabPrivilege')
                            ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 4, value='algorithmZab')
                            ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * j + 5, value='diff')
                        try:
                            numAlloc_sfn_i = [d['sfn'] for d in ZabAlloc if d['lcrId'] == str(cells[j])][0].index(
                                i_algo['sfn'])
                            numAlloc_i = [d['hasZabPrivilege'] for d in ZabAlloc
                                          if d['lcrId'] == str(cells[j])][0][
                                numAlloc_sfn_i] if numAlloc_sfn_i is not None else None
                            algo_i = i_algo['algorithm_ZabPrivilege'][j]
                            if numAlloc_i != algo_i:
                                zab_mismatch += 1
                        except ValueError:
                            numAlloc_i = 0
                            algo_i = 0

                        ws.cell(row=numcells * i + j + 2, column=1, value=i_algo['sfn'])
                        ws.cell(row=numcells * i + j + 2, column=2, value=cells[j])
                        ws.cell(row=numcells * i + j + 2, column=3,
                                value=numAlloc_i)
                        ws.cell(row=numcells * i + j + 2, column=4, value=algo_i)
                        ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 1, value=i_algo['sfn'])
                        ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 2, value=cells[j])
                        ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 3,
                                       value=numAlloc_i)
                        ws_charts.cell(row=i + 2, column=columnOffset + dataChartsOffset * j + 4, value=algo_i)
                        ws_charts.cell(
                            row=i + 2,
                            column=columnOffset + dataChartsOffset * j + 5,
                            value="=" + colLetter(columnOffset + dataChartsOffset * j + 2) + str(i + 2) + "-" +
                            colLetter(columnOffset + dataChartsOffset * j + 3) + str(i + 2))

                for i_cell in range(numcells):
                    try:
                        chart = LineChart()
                        data = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_cell + 3, min_row=1,
                                         max_col=columnOffset + dataChartsOffset * i_cell + 4, max_row=len(algo_zab))
                        cats = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_cell + 1, min_row=2,
                                         max_col=columnOffset + dataChartsOffset * i_cell + 1, max_row=len(algo_zab))
                        chart.add_data(data, titles_from_data=True)
                        chart.set_categories(cats)
                        chart.title = "hasZabPrivilege lcrId " + str(cells[i_cell])
                        chart.x_axis.title = "SFN"
                        chart.y_axis.title = "PRB"
                        chart.y_axis.majorGridlines = None

                        # chart.series[1].graphicalProperties.line.solidFill = "FF0000"
                        chart.series[0].graphicalProperties.line.width = 15000
                        chart.series[1].graphicalProperties.line.width = 15000
                        chart.series[1].graphicalProperties.line.dashStyle = "dash"
                        diffchart = BarChart()
                        diffdata = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_cell + 5, min_row=1,
                                             max_col=columnOffset + dataChartsOffset * i_cell + 5,
                                             max_row=len(algo_zab))
                        diffchart.add_data(diffdata, titles_from_data=True)
                        diffchart.y_axis.axId = 20
                        diffchart.y_axis.title = "diff"
                        diffchart.y_axis.crosses = "max"
                        diffchart.y_axis.majorGridlines = None

                        chart += diffchart
                        chart.width = 20
                        chart.height = 10
                        # for row in ws_charts.iter_rows():
                        #     for cell in row:
                        #         cell.font = Font(color='FFFFFFFF')
                        ws_charts.add_chart(chart, "B{}".format(21 * i_cell + 2))
                    except ValueError:
                        print('no data for cell {}'.format(i_cell))

                        pass

    metricsToPlot = [
        {"group": "dlMetricIndData", "metrics": ["nonGbrPrbDemand", "gbrPrbDemand"]},
        {"group": "ulMetricIndData", "metrics": ["nonGbrPrbDemand", "gbrPrbDemand"]},
        {"group": "dlAllocatedPooledResourcesData", "metrics": ["numAllocCell"+allocType+"PrbDl", "hasZabPrivilege"]},
        {"group": "ulAllocatedPooledResourcesData", "metrics": ["numAllocCell"+allocType+"PrbUl"]}]

    for metricToPlot in metricsToPlot:

        #     # if val_dlul['value']:
        ws = wb.create_sheet(metricToPlot['group'][:31])
        ws_charts = wb.create_sheet("Charts - " + metricToPlot['group'][:22])
        dataChartsOffset = 6
        ws.cell(row=1, column=1, value='SFN')
        ws.cell(row=1, column=2, value='lcrId')
        # dataChartsOffset = len(metricToPlot['metrics']) + 2
        for i_metric, metric in enumerate(metricToPlot['metrics']):
            ws.cell(row=1, column=i_metric + 3, value=metric)

            for j in range(numcells):
                ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * i_metric + 1, value='SFN')
                ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * i_metric + j + 2,
                               value='lcrId ' + str(cells[j]))
        for i_metric, metric in enumerate(metricToPlot['metrics']):
            currentserie = get_data_series(tti_convert, metricToPlot['group'], metric)
            print('currentserie: {}'.format(currentserie))
            ws_charts.cell(row=1, column=columnOffset + dataChartsOffset * i_metric + 1, value=metric)

            for i_cell in range(numcells):
                print('cells: {}'.format(cells))
                print('i_cell: {}'.format(i_cell))
                sfns = [d['sfn'] for d in currentserie if d['lcrId'] == str(cells[i_cell])][0]
                values = [d[metric] for d in currentserie if d['lcrId'] == str(cells[i_cell])][0]
                # print('sfns: {}'.format(sfns))
                # print('values: {}'.format(values))
                for i_sfn, sfn in enumerate(sfns):
                    ws.cell(row=numcells * i_sfn + i_cell + 2, column=1, value=sfn)
                    ws.cell(row=numcells * i_sfn + i_cell + 2, column=2, value=cells[i_cell])
                    ws.cell(row=numcells * i_sfn + i_cell + 2, column=3 + i_metric, value=values[i_sfn])
                    ws_charts.cell(row=i_sfn + 2, column=columnOffset + dataChartsOffset * i_metric + 1, value=sfn)
                    ws_charts.cell(row=i_sfn + 2, column=columnOffset + dataChartsOffset * i_metric + i_cell + 2,
                                   value=values[i_sfn])
        for i_metric, metric in enumerate(metricToPlot['metrics']):
            chart = LineChart()
            data = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_metric + 2, min_row=1,
                             max_col=columnOffset + dataChartsOffset * i_metric + numcells + 1, max_row=len(sfns))
            cats = Reference(ws_charts, min_col=columnOffset + dataChartsOffset * i_metric + 1, min_row=2,
                             max_col=columnOffset + dataChartsOffset * i_metric + 1, max_row=len(sfns))
            chart.add_data(data, titles_from_data=True)
            chart.set_categories(cats)
            chart.title = metric
            chart.x_axis.title = "SFN"
            chart.width = 20
            chart.height = 10
            ws_charts.add_chart(chart, "B{}".format(20 * i_metric + 2))

    wb.save(excelFile)
    sheet_names = wb.sheetnames
    first_order = sorted([d for d in sheet_names if d[:6] == 'Charts'])
    next_order = sorted([d for d in sheet_names if d[:6] != 'Charts'])
    order = first_order + next_order
    wb._sheets.sort(key=lambda x: order.index(x.title))
    wb.save(excelFile)
    # if dl_mismatch > 0 or ul_mismatch > 0:
    #     logger.error("Mismatchs between algo and traces: DL: {}, UL: {}. Check {} for details".format(
    #         dl_mismatch, ul_mismatch, excelFile))

    return excelFile, dl_mismatch, ul_mismatch, zab_mismatch


def Calculate_prbs_series(tti_dict, maxnumprbs, streams, numMinPrbAlloc, maxCellPrb,
                          l1spcells, nrCellType, dlul, scf_file, longPucchNumPuschPrb=0, cb012605=False):
    prb_demand = get_prb_demand_series(tti_dict, dlul)
    lcrIds = sorted(set(d['lcrId'] for d in tti_dict))
    numcells = len(lcrIds)
    # print('prb_demand: {}'.format(prb_demand))
    sfns_in_trace = [d['sfn'] for d in prb_demand][0]
    sfns = list(range(prb_demand[0]['sfn'][1], prb_demand[0]['sfn'][-1], 5))
    sfns_set = set(sfns)
    sfns_in_trace_set = set(sfns_in_trace)

    missing_values = sfns_set.difference(sfns_in_trace_set)

    # The length of missing_values will give you the count of values in sfns that are not present in sfns_in_trace

    if len(missing_values) > 0:
        logger.error("The TTI trace is incomplete ({} missing samples). Please contact TTI support".format(
            len(missing_values) - 1))
    prbDemand = {}
    prbDemand_minus6 = {}
    prb_algo = []
    # print(prb_demand)
    for i, sfn in enumerate(sfns, 1):
        try:
            # print(i, sfn)
            i_sfn = prb_demand[0]['sfn'].index(sfn)
            i_sfn_minus6 = prb_demand[0]['sfn'].index(sfn - 5)
            prbDemand['gbrPrbDemand'] = [d['gbrPrbDemand'][i_sfn] for d in prb_demand if d['gbrPrbDemand']]
            prbDemand['nonGbrPrbDemand'] = [d['nonGbrPrbDemand'][i_sfn] for d in prb_demand if d['gbrPrbDemand']]
            prbDemand['sfn'] = str(sfn)
            prbDemand_minus6['gbrPrbDemand'] = \
                [d['gbrPrbDemand'][i_sfn_minus6] for d in prb_demand if d['gbrPrbDemand']]
            prbDemand_minus6['nonGbrPrbDemand'] = \
                [d['nonGbrPrbDemand'][i_sfn_minus6] for d in prb_demand if d['gbrPrbDemand']]
            prbDemand_minus6['sfn'] = str(sfn - 5)
            # print('sfn: {}'.format(sfn))
            # print('maxnumprbs: {}'.format(maxnumprbs))
            # print('streams: {}'.format(streams))
            # print('numMinPrbAlloc: {}'.format(numMinPrbAlloc))
            # print('maxCellPrb: {}'.format(maxCellPrb))
            # print('prbDemand: {}'.format(prbDemand))
            # print('prbDemand_minus6: {}'.format(prbDemand_minus6))
            # print('l1spcells: {}'.format(l1spcells))
            # print('nrCellType: {}'.format(nrCellType))
            # print('dlul: {}'.format(dlul))
            # print('longPucchNumPuschPrb: {}'.format(longPucchNumPuschPrb))
            prb_algo_i = Calculate_cb007113_prbs_new(maxnumprbs, streams, numMinPrbAlloc, maxCellPrb[dlul],
                                                     prbDemand, prbDemand_minus6, l1spcells, nrCellType,
                                                     scf_file, dlul, longPucchNumPuschPrb, True, cb012605)
            # print('end of new algo')
            # prb_algo_i = Calculate_cb007113_prbs_old(maxnumprbs, streams, numMinPrbAlloc, maxCellPrb[dlul],
            #                                          prbDemand, prbDemand_minus6, l1spcells, nrCellType,
            #                                          scf_file, dlul, longPucchNumPuschPrb)

            print('prb_algo_i: {}'.format(prb_algo_i))
            prb_algo.append({'sfn': sfn + 1, 'algorithmPrbs': prb_algo_i})
        except ValueError:
            prb_algo.append({'sfn': sfn + 1, 'algorithmPrbs': [None] * numcells})
        except IndexError:
            pass
    return prb_algo


def Calculate_zab_series(tti_dict, maxnumprbs, streams, numMinPrbAlloc, maxCellPrb,
                         l1spcells, poolMaxNumStreamPrb, maxWbPoolStreamPrb):
    dlul = 'dl'
    lcrIds = sorted(set(d['lcrId'] for d in tti_dict))
    numcells = len(lcrIds)
    prb_demand = get_prb_demand_series(tti_dict, dlul)
    # numAllocCellPrb = get_data_series(tti_convert, 'dlAllocatedPooledResourcesData', 'numAllocCellPrbDl')
    # sfns = [d['sfn'] for d in prb_demand][0][1:-1]
    sfns = list(range(prb_demand[0]['sfn'][1], prb_demand[0]['sfn'][-1], 5))
    prbDemand = {}
    zab_algo = []
    # print(prb_demand)
    for i, sfn in enumerate(sfns, 1):
        try:
            # print(i, sfn)
            i_sfn = prb_demand[0]['sfn'].index(sfn)
            prbDemand['gbrPrbDemand'] = [d['gbrPrbDemand'][i_sfn] for d in prb_demand if d['gbrPrbDemand']]
            prbDemand['nonGbrPrbDemand'] = [d['nonGbrPrbDemand'][i_sfn] for d in prb_demand if d['nonGbrPrbDemand']]
            prbDemand['sfn'] = str(sfn)
            assigned_prbs = get_numAllocCellPrbDl(tti_dict, (sfn + 1) % 1024)
            zab_algo_i = calculate_hasZabPrivilege(numMinPrbAlloc, maxCellPrb['dl'], prbDemand,
                                                   assigned_prbs, poolMaxNumStreamPrb, maxWbPoolStreamPrb)
            zab_algo.append({'sfn': sfn + 1, 'algorithm_ZabPrivilege': zab_algo_i})
        except ValueError:
            # print("ValueError, SFN :{}".format(sfn))
            zab_algo.append({'sfn': sfn + 1, 'algorithm_ZabPrivilege': [None] * numcells})
        except IndexError:
            print("IndexError, SFN :{}".format(sfn))
            pass
    return zab_algo


def algorithm_prbs(tti_dict, scf_file, dlul, syslog, cb012605=False):
    # save_scf(tl, 'scf_prbs.xml')
    # maxCellPrb = getMaxCellPRB('/tmp/scf_prbs.xml', syslog)
    syslog_folder = os.path.dirname(syslog)
    # maxCellPrb = call_keyword('Get MaxCellPRB', '/tmp/scf_prbs.xml', syslog_folder)
    try:
        json_result = syslog_folder + "/check_cell_setup.json"
        with open(json_result, "r") as content:
            setup_params = json.load(content)
            filterCells = setup_params['CellsOnAir']
            l1spcells = setup_params['l1SpCells'][dlul + 'L1SpCells']
            allocType = 'Layer' if cb012605 else ''
            numMinPrbAlloc = [setup_params['numMin'+allocType+'PrbAlloc']['numMin'+allocType+'PrbAlloc' + dlul.title()]
                              [i] for i in filterCells]
            maxCellPrb = {'dl': [setup_params['maxCellPrb']['dl'][i] for i in filterCells],
                          'ul': [setup_params['maxCellPrb']['ul'][i] for i in filterCells]}
            nrCellType = [setup_params['nrCellType'][i] for i in filterCells]
            longPucchNumPuschPrb = [setup_params['longPucchNumPuschPrb'][i] for i in filterCells]
            streams = [4] * len(maxCellPrb['dl'])
            # print('streams: {}'.format(streams))
            # slowPrbPoolingParameters = \
            #     setup_params['bbPoolInformations']['l2RtPoolDeploymentInformations']['bbPoolInfos']\
            #         ['l1PoolList']['l1Pools'][0]['l1' + dlul.title() + 'SubPoolList'][0]['slowPrbPoolingParameters']
            slowPrbPoolingParameters = [d['slowPrbPoolingParameters'] for d in
                                        setup_params['bbPoolInformations']['l2RtPoolDeploymentInformations'][
                                        'bbPoolInfos']['l1PoolList']['l1Pools'][0]['l1' + dlul.title() + 'SubPoolList']]

            maxnumprbs = [{'csSize': '48' if dlul == 'dl' else '64',
                           'direction': dlul.upper(),
                           'maxNumStreamPrbL1Sp': slowPrbPoolingParameters[0]['l1SpMaxNumStreamPrb'],
                           'maxNumLayerPrbL1Sp': slowPrbPoolingParameters[0]['l1SpMaxNumLayerPrb'],
                           'maxNumWbStreamPrbL1Sp': slowPrbPoolingParameters[0]['l1SpMaxNumStreamPrbWb']},
                          {'csSize': '48' if dlul == 'dl' else '32',
                           'direction': dlul.upper(),
                           'maxNumStreamPrbL1Sp': slowPrbPoolingParameters[1]['l1SpMaxNumStreamPrb'],
                           'maxNumLayerPrbL1Sp': slowPrbPoolingParameters[1]['l1SpMaxNumLayerPrb'],
                           'maxNumWbStreamPrbL1Sp': slowPrbPoolingParameters[1]['l1SpMaxNumStreamPrbWb']}]
            prb_algo = Calculate_prbs_series(tti_dict, maxnumprbs, streams, numMinPrbAlloc, maxCellPrb,
                                             l1spcells, nrCellType, dlul, scf_file, longPucchNumPuschPrb, cb012605)
            return prb_algo
    except FileNotFoundError:
        print("You must run ""Check Cell Setup"" before using this option.")


def algorithm_zab(tti_dict, scf_file, syslog):
    # save_scf(tl, 'scf_prbs.xml')
    syslog_folder = os.path.dirname(syslog)
    try:
        json_result = syslog_folder + "/check_cell_setup.json"
        with open(json_result, "r") as content:
            setup_params = json.load(content)
            l1spcells = setup_params['l1SpCells']['dlL1SpCells']
            numMinPrbAlloc = setup_params['numMinPrbAlloc']['numMinPrbAllocDl']
            maxCellPrb = setup_params['maxCellPrb']
            streams = [4] * len(maxCellPrb['dl'])
            slowPrbPoolingParameters = setup_params[
                'bbPoolInformations']['l2RtPoolDeploymentInformations']['bbPoolInfos']['l1PoolList']['l1Pools'][
                0]['l1DlSubPoolList'][0]['slowPrbPoolingParameters']
            maxnumprbs = [{'csSize': '48',
                           'direction': 'DL',
                           'maxNumStreamPrbL1Sp': slowPrbPoolingParameters['l1SpMaxNumStreamPrb'],
                           'maxNumLayerPrbL1Sp': slowPrbPoolingParameters['l1SpMaxNumLayerPrb'],
                           'maxNumWbStreamPrbL1Sp': slowPrbPoolingParameters['l1SpMaxNumStreamPrbWb']},
                          {'csSize': '48',
                           'direction': 'DL',
                           'maxNumStreamPrbL1Sp': slowPrbPoolingParameters['l1SpMaxNumStreamPrb'],
                           'maxNumLayerPrbL1Sp': slowPrbPoolingParameters['l1SpMaxNumLayerPrb'],
                           'maxNumWbStreamPrbL1Sp': slowPrbPoolingParameters['l1SpMaxNumStreamPrbWb']}]
            zab_algo = Calculate_zab_series(tti_dict, maxnumprbs, streams, numMinPrbAlloc, maxCellPrb,
                                            l1spcells, 2 * int(slowPrbPoolingParameters['l1SpMaxNumStreamPrb']),
                                            2 * int(slowPrbPoolingParameters['l1SpMaxNumStreamPrbWb']))
            return zab_algo
    except FileNotFoundError:
        print("You must run ""Check Cell Setup"" before using this option.")


def save_scf(tl, scf_file='sfc_orig'):
    coam.connect_to(bts_host=tl.gnbs[0].cu.oam_ssh_connection_details.addr, name='coam_admin', trim_logs=True)
    coam.get_current_scf_file(local_dir_path='/tmp', file_name=scf_file, connection='coam_admin')
    # coam.teardown('coam_admin')


def get_csirs_params(tl):
    save_scf(tl, 'scf_csirs.xml')
    scf.load_scf('/tmp/scf_csirs.xml')
    cells = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
    nrcellgroups = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELLGRP')
    nrbts = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
    print(nrbts)
    fsType = scf.get_value_from_scf(dist_name=cells[0], p_name='frameStructureType', list_name='tddFrameStructure')
    print(fsType)
    fsSlotRatio = scf.get_value_from_scf(dist_name=cells[0], p_name='ulDlDataSlotRatio', list_name='tddFrameStructure')
    print(fsSlotRatio)
    try:
        fsFrameShift = scf.get_value_from_scf(dist_name=cells[0], p_name='lteToNrFrameShift',
                                              list_name='tddFrameStructure')
    except KeyError:
        fsFrameShift = '0ms'
    print(fsFrameShift)
    fsActCsiMux = scf.get_value_from_scf(dist_name=cells[0], p_name='actCsirsMultiplexing')
    fsbeamCfg = scf.get_value_from_scf(dist_name=nrcellgroups[0], p_name='numberOfTransmittedSsBlocks')
    fsactBbPoolExt = scf.get_value_from_scf(dist_name=nrbts, p_name='actBbPoolExtensionTddFr1')
    fsactBbPool = scf.get_value_from_scf(dist_name=nrbts, p_name='actBbPoolTddFr1')
    try:
        factInfTddFrameMuting = scf.get_value_from_scf(dist_name=cells[0], p_name='actInfTddFrameMuting')
    except KeyError:
        factInfTddFrameMuting = 'false'
    try:
        fsActExpCsi = scf.get_value_from_scf(dist_name=nrbts, p_name='actExplicitCsirsPoolSolution')
    except KeyError:
        fsActExpCsi = 'false'
    fsCsiPeriod = scf.get_value_from_scf(dist_name=cells[0], p_name='csiReportPeriodicity')
    if fsType == 'tdLte' and fsFrameShift == '3ms':
        framestructure = '5GC001116_3'
    elif fsType == 'tdLte' and fsFrameShift == '0ms':
        framestructure = '5GC001116_0'
    elif fsType == 'semiStatic' and fsSlotRatio == '1/4':
        framestructure = '5GC001208'
    elif fsType == 'semiStatic' and fsSlotRatio == '3/7':
        framestructure = '5GC001070'

    return framestructure, fsActCsiMux, fsCsiPeriod, fsActExpCsi, fsbeamCfg, fsactBbPool, fsactBbPoolExt, \
        factInfTddFrameMuting


def get_csirs_params_v2(tl):
    save_scf(tl, 'scf_csirs.xml')
    scf.load_scf('/tmp/scf_csirs.xml')
    cells = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
    nrcellgroups = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELLGRP')
    nrbts = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
    fsCsiPeriod = []
    print(nrbts)
    fsType = scf.get_value_from_scf(dist_name=cells[0], p_name='frameStructureType', list_name='tddFrameStructure')
    print(fsType)
    fsSlotRatio = scf.get_value_from_scf(dist_name=cells[0], p_name='ulDlDataSlotRatio', list_name='tddFrameStructure')
    print(fsSlotRatio)
    try:
        fsFrameShift = scf.get_value_from_scf(dist_name=cells[0], p_name='lteToNrFrameShift',
                                              list_name='tddFrameStructure')
    except KeyError:
        fsFrameShift = '0ms'
    print(fsFrameShift)

    fsbeamCfg = [scf.get_value_from_scf(dist_name=nrcellgroup, p_name='numberOfTransmittedSsBlocks')
                 for nrcellgroup in nrcellgroups]
    fsactBbPoolExt = scf.get_value_from_scf(dist_name=nrbts, p_name='actBbPoolExtensionTddFr1')
    fsactBbPool = scf.get_value_from_scf(dist_name=nrbts, p_name='actBbPoolTddFr1')

    try:
        fsActExpCsi = scf.get_value_from_scf(dist_name=nrbts, p_name='actExplicitCsirsPoolSolution')
    except KeyError:
        fsActExpCsi = 'false'
    fsCsiPeriod = [scf.get_value_from_scf(dist_name=cell, p_name='csiReportPeriodicity') for cell in cells]
    fsActCsiMux = [scf.get_value_from_scf(dist_name=cell, p_name='actCsirsMultiplexing') for cell in cells]
    factInfTddFrameMuting = [scf.get_value_from_scf(dist_name=cell, p_name='actInfTddFrameMuting') for cell in cells]
    fcsirsNbWithinReportPeriod = \
        [scf.get_value_from_scf(dist_name=cell, p_name='csirsNumberWithinReportPeriod_Set1') for cell in cells]
    fmaxCsiRsNumber = [scf.get_value_from_scf(dist_name=cell, p_name='maxCsirsNumber') for cell in cells]
    fnrCellId = [re.findall(rf"\d+", cell)[-1] for cell in cells]
    if fsType == 'tdLte' and fsFrameShift == '3ms':
        framestructure = '5GC001116_3'
    elif fsType == 'tdLte' and fsFrameShift == '0ms':
        framestructure = '5GC001116_0'
    elif fsType == 'semiStatic' and fsSlotRatio == '1/4':
        framestructure = '5GC001208'
    elif fsType == 'semiStatic' and fsSlotRatio == '3/7':
        framestructure = '5GC001070'

    return framestructure, fsActCsiMux[0], fsCsiPeriod, fsActExpCsi, fsbeamCfg, fsactBbPool, fsactBbPoolExt, \
        factInfTddFrameMuting, fcsirsNbWithinReportPeriod, fmaxCsiRsNumber, fnrCellId


def call_keyword(keyword, *args):
    return BuiltIn().run_keyword(keyword, *args)


def get_last_item(input_string, starting_item):
    starting_string = '{"' + starting_item + '":'
    start_idx = input_string.find(starting_string)

    while start_idx != -1:
        end_idx = find_matching_brace(input_string, start_idx)
        if end_idx == -1:
            break

        json_str = input_string[start_idx:end_idx + 1]
        start_idx = input_string.find(starting_string, end_idx + 1)

    # print(json_str)
    last_item = find_last_occurrence('\"(.*?)\":', json_str)
    return last_item


def find_matching_brace(s, start):
    count = 1
    for i in range(start + 1, len(s)):
        if s[i] == '{':
            count += 1
        elif s[i] == '}':
            count -= 1
            if count == 0:
                return i
    return -1


def find_last_occurrence(pattern, input_string):
    matches = re.findall(pattern, input_string)
    if matches:
        return matches[-1]
    else:
        return None


def get_nrcellIds(scf_file):
    # logging.getLogger('admin').setLevel(logging.INFO)

    if scf_file is None:
        coam = admin()
        # coam.connect_to(bts_host=tl.gnbs[0].cu.oam_ssh_connection_details.addr, name='coam_admin')
        cell_param_all = coam.get_parameters_for_all(class_name='NRCEL', timeout=30, connection='coam_admin')
        # cells = list(d['globalCellId'] for d in cell_status)
        nrcellIds = []
        for cellparam in cell_param_all:
            nrcellIds.append({'lcrId': cellparam['configurationId'], 'nrCellIdentity': cellparam['nrCellIdentity']})
    else:
        scf.load_scf(scf_file)
        cells_c = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
        nrbtsId = re.search(r'NRBTS-(\d+)', cells_c[0]).group(1)
        nrcellIds = []

        for nrcell in cells_c:
            lcrId = int(nrcell.split('NRCELL-')[1])
            nrCellIdentity = (int(nrbtsId) << 14) | int(lcrId)
            nrcellIds.append({'lcrId': lcrId, 'nrCellIdentity': nrCellIdentity})

    return sorted(nrcellIds, key=lambda p: p['lcrId'])


def get_active_nrcellIds(scf_file):
    # logging.getLogger('admin').setLevel(logging.INFO)

    if scf_file is None:
        coam = admin()
        # coam.connect_to(bts_host=tl.gnbs[0].cu.oam_ssh_connection_details.addr, name='coam_admin')
        cell_param_all = coam.get_parameters_for_all(class_name='NRCEL', timeout=30, connection='coam_admin')
        # cells = list(d['globalCellId'] for d in cell_status)
        nrcellIds = []
        for cellparam in cell_param_all:
            if cellparam['operationalState'] == 'enabled':
                nrcellIds.append({'lcrId': cellparam['configurationId'], 'nrCellIdentity': cellparam['nrCellIdentity']})
    else:
        scf.load_scf(scf_file)
        cells_c = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
        nrbtsId = re.search(r'NRBTS-(\d+)', cells_c[0]).group(1)
        nrcellIds = []

        for nrcell in cells_c:
            lcrId = int(nrcell.split('NRCELL-')[1])
            nrCellIdentity = (int(nrbtsId) << 14) | int(lcrId)
            nrcellIds.append({'lcrId': lcrId, 'nrCellIdentity': nrCellIdentity})

    return sorted(nrcellIds, key=lambda p: p['lcrId'])


def get_lcrIds(scf_file=None):
    # logging.getLogger('scf').setLevel(logging.INFO)

    if scf_file is None:
        # print('scf: {}'.format(scf_file))
        coam = admin()
        cell_param_all = coam.get_parameters_for_all(class_name='NRCEL', timeout=30, connection='coam_admin')
        # print('cell_param_all: {}'.format(cell_param_all))
        lcrIds = list(d['configurationId'] for d in cell_param_all)
    else:
        scf.load_scf(scf_file)
        cells_c = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
        lcrIds = (list(map(lambda x: x.split('NRCELL-')[1], cells_c)))

    return sorted(lcrIds)


def get_active_lcrIds(scf_file=None):
    # logging.getLogger('scf').setLevel(logging.INFO)

    if scf_file is None:
        coam = admin()
        cell_param_all = coam.get_parameters_for_all(class_name='NRCEL', timeout=30, connection='coam_admin')
        print('cell_param_all: {}'.format(cell_param_all))
        lcrIds = list(d['configurationId'] for d in cell_param_all if d['operationalState'] == 'enabled')
    else:
        scf.load_scf(scf_file)
        cells_c = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
        lcrIds = (list(map(lambda x: x.split('NRCELL-')[1], cells_c)))

    return sorted(lcrIds)


def extract_cellcsirs_from_syslog_cell(syslogextract, csirsgroups):
    syslogextract_flt = re.sub(r"\n.*?: ", '', syslogextract)
    starting_item = 'messageResult'
    last_item = get_last_item(syslogextract_flt, starting_item)
    print('last item: ' + last_item)
    pattern = r'\{\"' + starting_item + r'\":.*?\"' + last_item + r'\":.*?[}\]]+'

    matches = re.findall(pattern, syslogextract_flt)
    slot_offsets = []

    for msg in matches:
        print('msg:')
        # print(msg)
        try:
            data = json.loads(msg)
        except Exception as e:
            return []
        # print(data)

        try:
            cellCsiRsConfig = {'cellId': data['nrCellIdentity'],
                               'resource_set': data['cellCsiRsTimeDomainAllocation']['resourceSet']}
            try:
                for i in range(len(cellCsiRsConfig['resource_set'])):
                    cellCsiRsConfig['resource_set'][i].pop('csiImResSlotOffset')
            except Exception as e:
                pass
            slot_offsets.append(cellCsiRsConfig)

        except (TypeError, IndexError):
            pass

    cellCsiRsConfig_Sorted = sorted(slot_offsets, key=lambda p: p['cellId'])
    return cellCsiRsConfig_Sorted


def createCellCsiRs_v3(result_file, framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                       csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups, cellIds,
                       actTddCsirsAllocOptimization, actInfTddFrameMuting="false"):
    csiRsConfig = []
    csiRsPeriodicity = []

    maxCsiRsPoolGroups = 3

    result_file_fd = open(result_file, 'a')
    cellList = [d.split('-')[-1] for d in cellIds]

    if actTddCsirsAllocOptimization == "true":
        print('CB009836 Initial Slot Offset')
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        print('CB08940/CB010513 Initial Slot Offset')
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}

    trsSlot = [trsSlotOffset[framestructure]['i'], trsSlotOffset[framestructure]['i'] + 1,
               trsSlotOffset[framestructure]['j'], trsSlotOffset[framestructure]['j'] + 1]

    print('actCsiMux: {}'.format(actCsiMux))
    print('actExplicitCsirsPoolSolution: {}'.format(actExplicitCsirsPoolSolution))
    print('csiRsPeriod NIDD: {}'.format(csiRsPeriod))
    print('csirsNbWithinReportPeriod_Set1: {}'.format(csirsNbWithinReportPeriod_Set1))
    print('maxCsiRsPerCsiRsPool: {}'.format(maxCsiRsPerCsiRsPool))
    print('csiRsGroups: {}'.format(csiRsGroups))
    print('cellList: {}'.format(cellList))
    print('actTddCsirsAllocOptimization: {}'.format(actTddCsirsAllocOptimization))
    print('actInfTddFrameMuting: {}'.format(actInfTddFrameMuting))

    # Calcul du CSI-RS resource periodicity
    for i in range(len(csiRsPeriod)):
        csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod[i]).group())
        if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)) > 40:
            csiRsPeriodicity.append(int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)))
        else:
            csiRsPeriodicity.append(40)

    print('\nCalculated csiRsPeriodicity: {}\n'.format(csiRsPeriodicity))
    result_file_fd.write('\n\tCalculated csiRsPeriodicity: {}\n'.format(csiRsPeriodicity))

    cellCsiRsInfo = {}
    for item in csiRsGroups:
        index = cellList.index(str(item['lcrId']))
        # index = cellList.index(item['lcrId'])
        cellCsiRsInfo[item['cell']] = {"lcrId": item['lcrId'],
                                       "csiRsReportPeriod": csiRsPeriodicity[index],
                                       "maxCsiRs": maxCsiRsPerCsiRsPool[index],
                                       "csiRsPoolGrpId": item['csirsPoolingGroupId']}
        print('{} {}'.format(item['cell'], cellCsiRsInfo[item['cell']]))
    # print('\ncellCsiRsInfo: {}'.format(cellCsiRsInfo))

    # CB008940
    if actExplicitCsirsPoolSolution == "false" and actTddCsirsAllocOptimization == "false":
        print("CB008940 Cell Specific CSI-RS Config")
        if actInfTddFrameMuting == "true":
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 2
            rs4startSymb3 = 6
            rs4startSymb4 = 6
        elif actCsiMux == "false":
            rs1startSymb1 = 12
            rs2startSymb1 = 2
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 6
            rs4startSymb3 = 10
            rs4startSymb4 = 12
        elif actCsiMux == "true":
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 10
            rs4startSymb2 = 10
            rs4startSymb3 = 12
            rs4startSymb4 = 12
        else:
            exit(-1)

        for cell in cellCsiRsInfo.keys():
            csiRsPoolGrpId = cellCsiRsInfo[cell]['csiRsPoolGrpId']
            rs1 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + csiRsPoolGrpId * 40,
                    'startingSymbolIndex': rs1startSymb1}]
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 +
                    ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'cellId': cell,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

    # CB010513
    elif actExplicitCsirsPoolSolution == "true" and actTddCsirsAllocOptimization == "false":
        print("CB010513 Cell Specific CSI-RS Config")
        # StartSymbol par reseource set pour chaque csiRsPoolingGrp
        rs1startSymb1 = [10, 10, 12]
        rs2startSymb1 = [12, 12, 10]
        rs4startSymb1 = [2, 2, 2]
        rs4startSymb2 = [6, 6, 6]

        for cell in cellCsiRsInfo.keys():
            csiRsPoolGrpId = cellCsiRsInfo[cell]['csiRsPoolGrpId']
            if csiRsPoolGrpId == 0 or csiRsPoolGrpId == 1:
                if cellCsiRsInfo[cell]['csiRsReportPeriod'] == 40:
                    rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 80:
                    rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

            else:  # CsiRsPoolingGroupId = 2
                if cellCsiRsInfo[cell]['csiRsReportPeriod'] == 40:
                    rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 80:
                    rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + 40,
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)],
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] +
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] +
                            ((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

    # CB009836
    elif actTddCsirsAllocOptimization == "true":
        print("CB009836 Cell Specific CSI-RS Config")
        for cell in cellCsiRsInfo.keys():
            csiRsPoolGrpId = cellCsiRsInfo[cell]['csiRsPoolGrpId']
            if cellCsiRsInfo[cell]['csiRsReportPeriod'] == 40:
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
                csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                     {'res': rs4}]})

            elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 80:
                if csiRsPoolGrpId == 0 or csiRsPoolGrpId == 1:
                    rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                         {'res': rs4}]})
                else:  # CsiRsPoolingGroupId = 2
                    rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                                         {'res': rs4}]})

            elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [
                    {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                     'startingSymbolIndex': 12},
                    {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                     'startingSymbolIndex': 12},
                    {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                     'startingSymbolIndex': 10},
                    {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + ((csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                     'startingSymbolIndex': 10}]
                csiRsConfig.append(
                    {'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2},
                                                      {'res': rs4}]})

            else:
                print("csiRsPeriod NOT SUPPORTED")
                csiRsConfig = None

    else:
        print("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    for data in csiRsConfig:
        if cellCsiRsInfo[data['cellId']]['maxCsiRs'] == "1":
            del csiRsConfig[csiRsConfig.index(data)]['resource_set'][-2:]
        if cellCsiRsInfo[data['cellId']]['maxCsiRs'] == "2":
            del csiRsConfig[csiRsConfig.index(data)]['resource_set'][-1]

    print(csiRsConfig)

    result_file_fd.close()
    return csiRsConfig


# def getMaxCellPRB(scf_file, syslogfile):
# bw_list = [20, 30, 40, 50, 60, 70, 80, 90, 100]
# prb_list = [51, 78, 106, 133, 162, 189, 217, 245, 273]
# scf.load_scf(scf_file)
# cells = scf.get_all_dist_names_of_specific_class('com.nokia.srbts.nrbts:NRCELL')
# maxCellPRB = {}
# maxCellPRB_dl = []
# maxCellPRB_ul = []
# numCells = len(cells)
# for icell, nrcell in enumerate(cells):
#     chBw = scf.get_value_from_scf(dist_name=nrcell, p_name='chBw')
#     chBw_int = int(re.search(r'\d*', chBw).group())
#     actDlMuMimoEnh = scf.get_value_from_scf(dist_name=nrcell, p_name='actDlMuMimoEnh')
#     actUlMuMimo = scf.get_value_from_scf(dist_name=nrcell, p_name='actUlMuMimo')
#     multiplierPRBdl = 2 if actDlMuMimoEnh == 'true' else 1
#
#     # longPucchNumPuschPrb = get_longPucchNumPuschPrb(syslog(syslogfile).CellSetupReq)
#     if actDlMuMimoEnh == 'true' else 0
#     # correctionUl = longPucchNumPuschPrb[icell] if actUlMuMimo == 'true' else 0
#     list_index = bw_list.index(chBw_int)
#     prbs = prb_list[list_index]
#     maxCellPRB_dl_i = multiplierPRBdl * prbs
#     maxCellPRB_ul_i = correctionUl + prbs
#     print('\nMaxCellPRBs Cell {}: DL: {}, UL: {}'.format(nrcell, maxCellPRB_dl_i, maxCellPRB_ul_i))
#     maxCellPRB_dl.append(maxCellPRB_dl_i)
#     maxCellPRB_ul.append(maxCellPRB_ul_i)
# maxCellPRB['dl'] = maxCellPRB_dl
# maxCellPRB['ul'] = maxCellPRB_ul
# return maxCellPRB

def cat_grep(filename, search_string):
    with open(filename, 'r') as file:
        for line in file:
            if search_string in line:
                print(line)


# Usage

def colLetter(numcol):
    if numcol < 26:
        return chr(65 + numcol)
    else:
        return chr(65 + numcol // 26 - 1) + chr(65 + numcol % 26)
