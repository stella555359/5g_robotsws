# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Jiangjing Lin
:contact: jiangjli@nokia-sbell.com
"""
import re


def get_group_ids_from_soap(filepath):
    group_list = []
    pattern = r"<newValue>endpointCapacitySharingGroup(\d+)</newValue>"
    lines = open(filepath).readlines()
    for line in lines:
        result = re.findall(pattern=pattern, string=line)
        if result:
            for item in result:
                item = int(item)
                if item not in group_list:
                    group_list.append(item)
    group_list.sort()
    return group_list[:4]


def check_group_info(filepath, group_id, maxUplaneSectionHeadersPerSymbol, maxUplaneSectionHeadersPerSlot, Endpoints):
    lines = open(filepath).readlines()
    rule = r"<managedObject distName=\"endpointCapacitySharingGroup"+str(group_id)
    pattern1 = rule+r".*?<parameterName>maxUplaneSectionHeadersPerSymbol</parameterName><newValue>(\d+)</newValue>"
    pattern2 = rule+r".*?<parameterName>maxUplaneSectionHeadersPerSlot</parameterName><newValue>(\d+)</newValue>"
    pattern3 = rule+r".*?<parameterName>maxEndpoints</parameterName><newValue>(\d+)</newValue>"
    for line in lines:
        Symbol = ""
        Slot = ""
        Endpoints = ""
        Symbol = re.search(pattern=pattern1, string=line)
        if Symbol:
            Symbol = int(Symbol.group(1))
            print(Symbol)
        Slot = re.search(pattern=pattern2, string=line)
        if Slot:
            Slot = int(Slot.group(1))
            print(Slot)
        Endpoints = re.search(pattern=pattern3, string=line)
        if Endpoints:
            Endpoints = int(Endpoints.group(1))
            print(Endpoints)
        if Symbol and Slot and Endpoints:
            break
    if Symbol == maxUplaneSectionHeadersPerSymbol and Slot == maxUplaneSectionHeadersPerSlot and Endpoints == Endpoints:
        return True
    else:
        return False
