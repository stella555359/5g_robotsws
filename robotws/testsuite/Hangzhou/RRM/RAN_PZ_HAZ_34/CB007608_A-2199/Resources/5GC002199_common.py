# -*- coding: utf-8 -*
import re
import linecache
from xml.dom.minidom import parse
import os
from robot.libraries.BuiltIn import BuiltIn


def return_add_measId_and_Event_map(file_name):
    f = open(file_name)
    st = f.read()
    measCombineRe = \
        re.compile(r'MeasIdToAddMod\s+?measId: (\d+)\s+?measObjectId: (\d+)\s+?reportConfigId: (\d+)', re.I)
    objectFreqRe = re.compile(r"MeasObjectToAddMod\s+?measObjectId: (\d+)[\s\S]+?ssbFrequency: (\d+)", re.I)
    reportEventRe = re.compile(r"ReportConfigToAddMod\s+?reportConfigId: (\d+)[\s\S]+?eventId: (.+?)\s", re.I)
    measids = measCombineRe.findall(st)
    report = reportEventRe.findall(st)
    if len(measids) == 0:
        raise Exception('measid is empty')
    else:
        MeasAndEventDic = {}
        for i in range(0, len(measids)):
            for j in range(0, len(report)):
                if report[j][0] == measids[i][2]:
                    MeasAndEventDic[report[j][1]] = measids[i][0]
    return MeasAndEventDic


def return_remove_measId_and_Event_map(file_name):
    count = len(open(file_name).readlines())
    message1 = 'measIdToRemoveList'
    message2 = 'measIdToAddModList'
    index1 = 0
    index2 = 0
    measid_list = []
    for i in range(0, count):
        fst_line = linecache.getline(file_name, i)
        if str(message1) in fst_line:
            index1 = i
        if str(message2) in fst_line:
            index2 = i
    for i in range(index1, index2):
        fst_line = linecache.getline(file_name, i)
        if str('MeasId:') in fst_line:
            measid = linecache.getline(file_name, i).split(' ')[-1].strip()
            measid_list.append(measid)
    return measid_list


def return_rsrp_or_rsrq_Event_map(file_name, event):
    f = open(file_name)
    st = f.read()
    measCombineRe = re.compile(
        r'MeasIdToAddMod\s+?measId: (\d+)\s+?measObjectId: (\d+)\s+?reportConfigId: (\d+)', re.I)
    reportEventRe = re.compile(
        r"ReportConfigToAddMod\s +?reportConfigId: (\d+)[\s\S]+?eventId: (.+?)\s[\s\S]+?: (.+?)\s", re.I)
    measids = measCombineRe.findall(st)
    report = reportEventRe.findall(st)
    MeasAndEventDic = {}
    for i in range(0, len(measids)):
        for j in range(0, len(report)):
            if report[j][0] == measids[i][2]:
                if report[j][1] == event:
                    MeasAndEventDic[report[j][2]] = measids[i][0]
    return MeasAndEventDic
