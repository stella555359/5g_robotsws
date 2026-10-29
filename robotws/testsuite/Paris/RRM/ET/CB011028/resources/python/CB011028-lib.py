import csv
import re
import math
import logging

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.config.scf import scf
from taf.analyzer.pdml import PdmlReader
from testsuite.Paris.resources.SWENG.python.StringTool import datedConsole, getHeaderLine

from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.dtx import get_dtx_stats
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.mumimo import get_mumimo_stats, \
    generate_rank_stats, generate_subcellId_stats
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.ue_cell_identification import identify_cells_and_ues
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.check_CB011028 import\
    filter_valid_events_and_check_CB011028, check_CB009890, filter_valid_events_and_check_CB009890_A_2
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.check_nack import\
    filter_valid_events_and_check_acknack_retx
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.check_CB011028_UL import\
    filter_valid_events_and_check_CB009890_UL, check_CB009890_UL
from testsuite.Paris.RRM.ET.CB011028.resources.python.tti_analysis.check_fdSched import\
    filter_valid_events_and_check_dlFdSchedData

# ====================================================================================================[120 characters]
#   Global Variables
# ====================================================================================================[120 characters]


logLevel = "INFO"
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RESET = '\033[0m'
BOLD = '\033[1m'
rbi = BuiltIn()


def logException(functionNameStr, e, silent=False):
    rbi.log("%s(): Exception = <%s>" % (functionNameStr, str(e)), "TRACE")
    if not silent:
        rbi.log_to_console(
            "  %s: exception happened (see log.html)" % functionNameStr)


def extract_BBRM_ERR_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    1540190-EQ_L2PS_BBRM ERR/L2-PS/src/bbrm/subCellsPooling/PrbCapacityChecker.cpp[161]
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.BBRM ERR.(.*)", syslogextract)
    print(err)
    return err


def extract_ESTATUS5G_NOTOK_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.ESTATUS5G_NOTOK.(.*)", syslogextract)
    print(err)
    return err


def extract_GnbOamCellUpdateFailed_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    ESTATUS5G_NOTOK
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.GnbOamCellUpdateFailed.(.*)", syslogextract)
    print(err)
    return err


def extract_AASYSINFO_FS_OVERLOAD_IND_MSG_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    AASYSINFO_FS_OVERLOAD_IND_MSG
    :param syslogextract:
    :return:  err
    """
    err = re.findall(r"(\d*).*.AASYSINFO_FS_OVERLOAD_IND_MSG.(.*)", syslogextract)
    print(err)
    return err


def extract_BBRM_conf_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.PRB pooling buffer.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_2_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.Bbrm conf: bbPoolInfo present.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_3_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.Bbrm conf DL.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_4_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.Bbrm conf UL.(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_DL_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.(DOWNLINK).(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_BBRM_conf_UL_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    bbrmconf = re.findall(r"(\d*).*.(UPLINK).(.*)", syslogextract)
    print(bbrmconf)
    return bbrmconf


def extract_SlotTypeSelectorBase_from_syslog(syslogextract):
    """
    Analyzing BBRM_conf
    :param syslogextract:
    :return:  bbrmconf
    """
    # SlotType = re.findall(r"(\d*).*Slot: (\d*).*Type: (.*)", syslogextract)
    SlotType = re.findall(r"(\d*).*Slot= (\d*).*Type= (.*)", syslogextract)
    print(SlotType)
    return SlotType


def extract_totalStreamPrbs_from_syslog(syslogextract):
    """
    Analyzing this kind of trace:
    Created 3 CsiRsPoolingGroup(s) with totalStreamPrbs:2184 in l1PoolId:10
    :param syslogextract:
    :return: totalStreamPrbs_l1PoolId_0, totalStreamPrbs_l1PoolId_10, cellmappingtocsirspoolinggroup
    """
    # cid2sp = re.findall(r"CsiRsPoolingGroup.*totalStreamPrbs:(\d*).*l1PoolId:(\d?)", syslogextract)
    cid2sp = re.findall(r"CsiRsPoolingGroup.*totalStreamPrbs:(\d*).*l1PoolId:(\d*)", syslogextract)
    print(cid2sp)
    totalStreamPrbs_l1PoolId_0 = []
    totalStreamPrbs_l1PoolId_10 = []
    for element in cid2sp:
        print(element)
        if int(element[1]) == 0:
            totalStreamPrbs_l1PoolId_0.append(int(element[0]))
        if int(element[1]) == 10:
            totalStreamPrbs_l1PoolId_10.append(int(element[0]))
    # 8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385
    # with streamPrbDemand:1092 to CsiRsPoolingGroup 0 (allocatedStreamPrbs:1092) in l1PoolId:10\n
    # 8D-cp_rt INF/cp_rt/CsiRsPoolingGroupsTdd.cpp:110 added NrCellIdentity:16385
    # with streamPrbDemand:1092 to CsiRsPoolingGroup 0 (allocatedStreamPrbs:1092) in l1PoolId:10\n
    #
    cellmappingtocsirspoolinggroup =\
        re.findall(
            r"added NrCellIdentity:(\d*).*streamPrbDemand:(\d*).*CsiRsPoolingGroup (\d*)"
            r".*allocatedStreamPrbs:(\d*).*l1PoolId:(\d*)",
            syslogextract)
    print(cellmappingtocsirspoolinggroup)
    return [totalStreamPrbs_l1PoolId_0, totalStreamPrbs_l1PoolId_10, cellmappingtocsirspoolinggroup]


def extract_l1sp_from_syslog(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*ulSubcellId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # ulSubcellId
    sp0 = [0, 1, 2, 4]
    # sp0 = [0, 1, 2, 4, 5, 6, 7, 8, 9]
    # ulsubpoolid => 2 ulsubpool
    sp1 = []
    for element in cid2sp:
        print(element)
        if int(element[1]) == 1:
            sp1.append(int(element[0]))
            sp0.remove(int(element[0]))

    return [sp0, sp1]


def extract_ull1sp_from_syslog_9890_C(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*ulSubcellId\":(\d*).*l1PoolId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # dlSubcellId
    # sp0_poolId10 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    sp0_poolId10 = []
    sp0_poolId13 = []
    sp1_poolId10 = []
    sp1_poolId13 = []
    # dlsubpoolid => 2 dlsubpool
    for element in cid2sp:
        print(element)
        if int(element[2]) == 1 and int(element[1]) == 13:
            sp1_poolId13.append(int(element[0]))
        if int(element[2]) == 1 and int(element[1]) == 10:
            sp1_poolId10.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 13:
            sp0_poolId13.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 10:
            sp0_poolId10.append(int(element[0]))
    return [sp0_poolId10, sp0_poolId13, sp1_poolId10, sp1_poolId13]


def extract_dll1sp_from_syslog(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*dlSubcellId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # dlSubcellId
    sp0 = [0, 1, 2, 3, 4, 5]
    # sp0 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    # dlsubpoolid => 2 dlsubpool
    sp1 = []
    for element in cid2sp:
        print(element)
        if int(element[1]) == 1:
            sp1.append(int(element[0]))
            sp0.remove(int(element[0]))

    return [sp0, sp1]


def extract_dll1sp_from_syslog_9890_C(syslogextract):

    cid2sp = re.findall(r"SCellMappingReq.*dlSubcellId\":(\d*).*l1PoolId\":(\d*).*l1SubpoolId\":(\d?)", syslogextract)
    print(cid2sp)
    # dlSubcellId
    # sp0_poolId10 = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    sp0_poolId10 = []
    sp0_poolId13 = []
    sp1_poolId10 = []
    sp1_poolId13 = []
    # dlsubpoolid => 2 dlsubpool
    for element in cid2sp:
        print(element)
        if int(element[2]) == 1 and int(element[1]) == 13:
            sp1_poolId13.append(int(element[0]))
        if int(element[2]) == 1 and int(element[1]) == 10:
            sp1_poolId10.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 13:
            sp0_poolId13.append(int(element[0]))
        if int(element[2]) == 0 and int(element[1]) == 10:
            sp0_poolId10.append(int(element[0]))
    return [sp0_poolId10, sp0_poolId13, sp1_poolId10, sp1_poolId13]


def extract_dll1sp_from_COAM(cellinfo, sp):
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)','
    #                                                    ' 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    # sp = []
    for element in cellinfo:
        print(element)
        cid2sp = re.findall(r"Subcell-(\d*) \(DL\)", element)
        print(cid2sp)
        if cid2sp:
            sp.append(int(cid2sp[0]))
            sp.sort()
    return sp


def extract_ull1sp_from_COAM(cellinfo, sp):
    #  subCellList=['Subcell-0 (DL)', 'Subcell-0 (UL)', 'Subcell-3 (DL)', 'Subcell-3 (UL)','
    #                                                    ' 'Subcell-4 (DL)', 'Subcell-5 (DL)']
    # sp = []
    for element in cellinfo:
        print(element)
        cid2sp = re.findall(r"Subcell-(\d*) \(UL\)", element)
        print(cid2sp)
        if cid2sp:
            sp.append(int(cid2sp[0]))
            sp.sort()
    return sp


def get_sfn_column(row_from_list):
    sfn_column = 0
    for i, element in enumerate(row_from_list):
        if element.isdigit():
            sfn_column = i
            break
    return sfn_column


def read_and_parse_tti_data(path_to_tti, num_of_events=1000):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.DictReader(csv_file)
        csv_reader = list(csv_dict)
        # print("dic: {}".format(csv_dict))
        # print("list: {}".format(csv_reader))
        line_count = 0
        tti_dict = list()
        ttifilter = ['dlMetricIndData: hfnTickCount', 'dlTdSchedSubcellData: hfnTickCount',
                     'dlAllocatedPooledResourcesData: hfnTickCount',
                     'dlDtxOptimData: hfnTickCount', 'dlFdSchedData: hfnTickCount']
        if num_of_events is not None:
            num_of_events = int(num_of_events)
        for row in csv_reader:
            # print("line: {}.".format(line_count), "Content: {}".format(row))
            # print("line: {}.".format(line_count), "Content: {}".format(row[None][0]))
            # if row[None][0] == 'ulMetricIndData: sfn' or row[None][0] == 'ulTdSchedSubcellData: sfn':
            if row[None][0] in ttifilter:
                # if row[None][0] == 'dlMetricIndData: hfnTickCount'\
                # or row[None][0] == 'dlTdSchedSubcellData: hfnTickCount'\
                #       or row[None][0] == 'dlAllocatedPooledResourcesData: hfnTickCount'\
                #       or row[None][0] == 'dlDtxOptimData: hfnTickCount'\
                #       or row[None][0] == 'dlFdSchedData: hfnTickCount':
                new_row = dict()
                # new_row.update({'Event': row[None][0][:-5]})
                new_row.update({'Event': row[None][0][:-14]})
                print("Content1: {}".format(row[None]))
                print("Content new_row: {}".format(new_row))
                col_sfn = get_sfn_column(row[None])
                col_sfn = col_sfn + 1
                print("col_sfn: {}".format(col_sfn))
                print("sfn: {}".format(row[None][col_sfn]))
                # new_row.update({'sfn': row[None][col_sfn]})
                for index_dic in range(1, col_sfn):
                    if index_dic + col_sfn < len(row[None]):
                        print(index_dic, row[None][index_dic], row[None][index_dic + col_sfn - 1])
                        # BEWARE that 2 columns can have the same name (case of largeBwpPrbs in dlDtxOptimData)
                        if row[None][index_dic] in new_row:
                            continue
                        new_row.update({row[None][index_dic]: row[None][index_dic + col_sfn - 1]})
                    else:
                        break
                tti_dict.append(new_row)
                print("line: {}.".format(line_count), "Content new_row: {}".format(new_row))
            line_count += 1
            if line_count > num_of_events:
                break

    return tti_dict


def read_and_parse_tti_data_ul(path_to_tti, num_of_events=1000):
    with open(path_to_tti, 'r') as csv_file:
        csv_dict = csv.DictReader(csv_file)
        csv_reader = list(csv_dict)
        # print("dic: {}".format(csv_dict))
        # print("list: {}".format(csv_reader))
        line_count = 0
        tti_dict = list()
        ttifilter = ['ulMetricIndData: hfnTickCount', 'ulTdSchedSubcellData: hfnTickCount',
                     'ulAllocatedPooledResourcesData: hfnTickCount']
        if num_of_events is not None:
            num_of_events = int(num_of_events)
        for row in csv_reader:
            print("line: {}.".format(line_count), "Content: {}".format(row))
            if row[None][0] in ttifilter:
                # if row[None][0] == 'ulMetricIndData: hfnTickCount'\
                # or row[None][0] == 'ulTdSchedSubcellData: hfnTickCount'\
                # or row[None][0] == 'ulAllocatedPooledResourcesData: hfnTickCount':
                new_row = dict()
                # new_row.update({'Event': row[None][0][1:-5]})
                new_row.update({'Event': row[None][0][:-14]})
                print(row[None])
                col_sfn = get_sfn_column(row[None])
                col_sfn = col_sfn + 1
                print(col_sfn)
                # new_row.update({'sfn': row[None][col_sfn]})
                for index_dic in range(1, col_sfn):
                    if index_dic + col_sfn < len(row[None]):
                        print(index_dic, row[None][index_dic], row[None][index_dic + col_sfn - 1])
                        # BEWARE that 2 columns can have the same name (case of largeBwpPrbs in dlDtxOptimData)
                        # if row[None][index_dic] in new_row:
                        #     continue
                        new_row.update({row[None][index_dic]: row[None][index_dic + col_sfn - 1]})
                    else:
                        break
                tti_dict.append(new_row)
                print("line: {}.".format(line_count), "Content new_row: {}".format(new_row))
            line_count += 1
            if line_count > num_of_events:
                break

    return tti_dict


def get_ulprb_demand(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'], filter(lambda d: d['Event'] == 'ulMetricIndData' and int(d['sfn']) < 1012,
                                                   tti_dic)))[0]
    print('get_ulprb_demand first: {}'.format(firstsfn))
    prbdemand = []
    prbdemand_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        gbrPrbDemand_key = 'gbrPrbDemand'
        nonGbrPrbDemand_key = 'nonGbrPrbDemand'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        gbrPrbDemand = []
        nonGbrPrbDemand = []
        for lcrId in range(1, 4):
            gbrPrbDemand_i = [int(i) for i in
                              list(map(lambda d: d[gbrPrbDemand_key],
                                       filter(lambda d: d['Event'] == 'ulMetricIndData',
                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                     filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            nonGbrPrbDemand_i = [int(i) for i in
                                 list(map(lambda d: d[nonGbrPrbDemand_key],
                                          filter(lambda d: d['Event'] == 'ulMetricIndData',
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
            prbdemand_several_sfn.append(
                {'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
        prbdemand.append({'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return prbdemand, prbdemand_several_sfn


def get_dlprb_demand(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'], filter(lambda d: d['Event'] == 'dlMetricIndData'
                    and int(d['sfn']) < 1012, tti_dic)))[0]
    print('get_dlprb_demand first: {}'.format(firstsfn))
    prbdemand = []
    prbdemand_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        gbrPrbDemand_key = 'gbrPrbDemand'
        nonGbrPrbDemand_key = 'nonGbrPrbDemand'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        gbrPrbDemand = []
        nonGbrPrbDemand = []
        for lcrId in range(1, 5):
            gbrPrbDemand_i = [int(i) for i in
                              list(map(lambda d: d[gbrPrbDemand_key],
                                       filter(lambda d: d['Event'] == 'dlMetricIndData',
                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                     filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            nonGbrPrbDemand_i = [int(i) for i in
                                 list(map(lambda d: d[nonGbrPrbDemand_key],
                                          filter(lambda d: d['Event'] == 'dlMetricIndData',
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
            prbdemand_several_sfn.append(
                {'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
        prbdemand.append({'sfn': sfntocheck, 'gbrPrbDemand': gbrPrbDemand, 'nonGbrPrbDemand': nonGbrPrbDemand})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return prbdemand, prbdemand_several_sfn


def get_dlprb_alloc_bbrm(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'],
                        filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData' and int(d['sfn']) < 1012,
                               tti_dic)))[0]
    print('first: {}'.format(firstsfn))
    numAllocCellPrbDlBBRM = []
    numAllocCellPrbDlBBRM_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        numAllocCellPrbDl_key = 'numAllocCellPrbDl'
        hasZabPrivilege_key = 'hasZabPrivilege'
        activeDlSubcellsPList_key = 'activeDlSubcellsList_[0]'
        activeDlSubcellsSList_key1 = 'activeDlSubcellsList_[1]'
        activeDlSubcellsSList_key2 = 'activeDlSubcellsList_[2]'
        activeDlSubcellsSList_key3 = 'activeDlSubcellsList_[3]'
        activeDlSubcellsSList_key4 = 'activeDlSubcellsList_[4]'
        activeDlSubcellsSList_key5 = 'activeDlSubcellsList_[5]'
        activeDlSubcellsSList_key6 = 'activeDlSubcellsList_[6]'
        activeDlSubcellsSList_key7 = 'activeDlSubcellsList_[7]'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        numAllocCellPrbDl = []
        hasZabPrivilege = []
        activeDlSubcellsPrimaryList = []
        activeDlSubcellsSecondaryList = []
        for lcrId in range(1, 5):
            numAllocCellPrbDl_i = [int(i) for i in
                                   list(map(lambda d: d[numAllocCellPrbDl_key],
                                            filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                   filter(lambda d: d['sfn'] == sfntocheck,
                                                          filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            hasZabPrivilege_i = [int(i) for i in
                                 list(map(lambda d: d[hasZabPrivilege_key],
                                          filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                 filter(lambda d: d['sfn'] == sfntocheck,
                                                        filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeDlSubcellsPList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsPList_key],
                                                filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                       filter(lambda d: d['sfn'] == sfntocheck,
                                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key1],
                                                filter(lambda d: d[activeDlSubcellsSList_key1] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not numAllocCellPrbDl_i:
                numAllocCellPrbDl.append(0)
            else:
                numAllocCellPrbDl.append(numAllocCellPrbDl_i[0])
            if not hasZabPrivilege_i:
                hasZabPrivilege.append(0)
            else:
                hasZabPrivilege.append(hasZabPrivilege_i[0])
            if not activeDlSubcellsPList_i:
                activeDlSubcellsPrimaryList.append(0)
            else:
                activeDlSubcellsPrimaryList.append(activeDlSubcellsPList_i[0])
            if not activeDlSubcellsSList_i:
                activeDlSubcellsSecondaryList.append(0)
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key2],
                                                filter(lambda d: d[activeDlSubcellsSList_key2] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeDlSubcellsSList_i:
                # activeDlSubcellsSecondaryList.append(0)
                print('no activeDlSubcellsS to add in activeDlSubcellsSList_i')
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key3],
                                                filter(lambda d: d[activeDlSubcellsSList_key3] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeDlSubcellsSList_i:
                # activeDlSubcellsSecondaryList.append(0)
                print('no activeDlSubcellsS to add in activeDlSubcellsSList_i')
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            activeDlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeDlSubcellsSList_key4],
                                                filter(lambda d: d[activeDlSubcellsSList_key4] != '',
                                                       filter(lambda d: d['Event'] == 'dlAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeDlSubcellsSList_i:
                # activeDlSubcellsSecondaryList.append(0)
                print('no activeDlSubcellsS to add in activeDlSubcellsSList_i')
            else:
                activeDlSubcellsSecondaryList.append(activeDlSubcellsSList_i[0])
            numAllocCellPrbDlBBRM_several_sfn.append(
                {'sfn': sfntocheck, 'numAllocCellPrbDl': numAllocCellPrbDl, 'hasZabPrivilege': hasZabPrivilege,
                 'activeDlSubcellsPList': activeDlSubcellsPrimaryList,
                 'activeDlSubcellsSList': activeDlSubcellsSecondaryList})
        numAllocCellPrbDlBBRM.append({'sfn': sfntocheck,
                                      'numAllocCellPrbDl': numAllocCellPrbDl, 'hasZabPrivilege': hasZabPrivilege,
                                      'activeDlSubcellsPList': activeDlSubcellsPrimaryList,
                                      'activeDlSubcellsSList': activeDlSubcellsSecondaryList})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return numAllocCellPrbDlBBRM, numAllocCellPrbDlBBRM_several_sfn


def get_ulprb_alloc_bbrm(tti_dic):
    # firstsfn = [d.get(sfn_key) for d in tti_dic if 'Event' == 'ulMetricIndData']
    firstsfn = list(map(lambda d: d['sfn'],
                        filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData' and int(d['sfn']) < 1012,
                               tti_dic)))[0]
    print('first: {}'.format(firstsfn))
    numAllocCellPrbUlBBRM = []
    numAllocCellPrbUlBBRM_several_sfn = []
    for sfntocheck in (str(int(firstsfn) + 5), str(int(firstsfn) + 10)):
        print(sfntocheck)
        numAllocCellPrbUl_key = 'numAllocCellPrbUl'
        bbrmUsableCellPrbForUlGbrLoadReport_key = 'bbrmUsableCellPrbForUlGbrLoadReport'
        activeUlSubcellCount_key = 'activeUlSubcellCount'
        activeUlSubcellsPList_key = 'activeUlSubcellsList_[0]'
        activeUlSubcellsSList_key1 = 'activeUlSubcellsList_[1]'
        activeUlSubcellsSList_key2 = 'activeUlSubcellsList_[2]'
        activeUlSubcellsSList_key3 = 'activeUlSubcellsList_[3]'
        activeUlSubcellsSList_key4 = 'activeUlSubcellsList_[4]'
        activeUlSubcellsSList_key5 = 'activeUlSubcellsList_[5]'
        activeUlSubcellsSList_key6 = 'activeUlSubcellsList_[6]'
        activeUlSubcellsSList_key7 = 'activeUlSubcellsList_[7]'
        print(filter(lambda d: d['sfn'] == sfntocheck, tti_dic))
        numAllocCellPrbUl = []
        activeUlSubcellCount = []
        activeUlSubcellsPrimaryList = []
        activeUlSubcellsSecondaryList = []
        for lcrId in range(1, 4):
            numAllocCellPrbUl_i = [int(i) for i in
                                   list(map(lambda d: d[numAllocCellPrbUl_key],
                                            filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                   filter(lambda d: d['sfn'] == sfntocheck,
                                                          filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeUlSubcellCount_i = [int(i) for i in
                                      list(map(lambda d: d[activeUlSubcellCount_key],
                                               filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                      filter(lambda d: d['sfn'] == sfntocheck,
                                                             filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeUlSubcellsPList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsPList_key],
                                                filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                       filter(lambda d: d['sfn'] == sfntocheck,
                                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key1],
                                                filter(lambda d: d[activeUlSubcellsSList_key1] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not numAllocCellPrbUl_i:
                numAllocCellPrbUl.append(0)
            else:
                numAllocCellPrbUl.append(numAllocCellPrbUl_i[0])
            if not activeUlSubcellCount_i:
                activeUlSubcellCount.append(0)
            else:
                activeUlSubcellCount.append(activeUlSubcellCount_i[0])
            if not activeUlSubcellsPList_i:
                activeUlSubcellsPrimaryList.append(0)
            else:
                activeUlSubcellsPrimaryList.append(activeUlSubcellsPList_i[0])
            if not activeUlSubcellsSList_i:
                activeUlSubcellsSecondaryList.append(0)
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key2],
                                                filter(lambda d: d[activeUlSubcellsSList_key2] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeUlSubcellsSList_i:
                # activeUlSubcellsSecondaryList.append(0)
                print('no activeUlSubcellsS to add in activeUlSubcellsSList_i')
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key3],
                                                filter(lambda d: d[activeUlSubcellsSList_key3] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeUlSubcellsSList_i:
                # activeUlSubcellsSecondaryList.append(0)
                print('no activeUlSubcellsS to add in activeUlSubcellsSList_i')
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            activeUlSubcellsSList_i = [int(i) for i in
                                       list(map(lambda d: d[activeUlSubcellsSList_key4],
                                                filter(lambda d: d[activeUlSubcellsSList_key4] != '',
                                                       filter(lambda d: d['Event'] == 'ulAllocatedPooledResourcesData',
                                                              filter(lambda d: d['sfn'] == sfntocheck,
                                                                     filter(lambda d: d['lcrId'] == str(lcrId),
                                                                            tti_dic))))))]
            if not activeUlSubcellsSList_i:
                # activeUlSubcellsSecondaryList.append(0)
                print('no activeUlSubcellsS to add in activeUlSubcellsSList_i')
            else:
                activeUlSubcellsSecondaryList.append(activeUlSubcellsSList_i[0])
            numAllocCellPrbUlBBRM_several_sfn.append(
                {'sfn': sfntocheck, 'numAllocCellPrbUl': numAllocCellPrbUl,
                 'activeUlSubcellCount': activeUlSubcellCount,
                 'activeUlSubcellsPList': activeUlSubcellsPrimaryList,
                 'activeUlSubcellsSList': activeUlSubcellsSecondaryList})
        numAllocCellPrbUlBBRM.append({'sfn': sfntocheck,
                                      'numAllocCellPrbUl': numAllocCellPrbUl,
                                      'activeUlSubcellCount': activeUlSubcellCount,
                                      'activeUlSubcellsPList': activeUlSubcellsPrimaryList,
                                      'activeUlSubcellsSList': activeUlSubcellsSecondaryList})
    # [gbrPrbDemand[i] for i in [0, 2]]
    return numAllocCellPrbUlBBRM, numAllocCellPrbUlBBRM_several_sfn


def get_numAllocCellPrbUl(tti_dic, sfntocheck):
    numAllocCellPrbUl_key = 'numAllocCellPrbUl'

    numAllocCellPrbUl = []
    for lcrId in range(1, 4):
        filteredprbs = list(map(lambda d: d[numAllocCellPrbUl_key],
                                filter(lambda d: d['Event'] == 'ulTdSchedSubcellData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        numAllocCellPrbUl.append(int(max(filteredprbs) if filteredprbs else 0))
    return {'sfn': sfntocheck, 'numAllocCellPrbUl': numAllocCellPrbUl}


def get_numAllocCellPrbDl(tti_dic, sfntocheck):
    numAllocCellPrbDl_key = 'numAllocCellPrbDl'

    numAllocCellPrbDl = []
    for lcrId in range(1, 4):
        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlTdSchedSubcellData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
    return {'sfn': sfntocheck, 'numAllocCellPrbDl': numAllocCellPrbDl}


def get_numAllocCellPrbDl_MicroDtx(tti_dic, sfntocheck):
    numAllocCellPrbDl_key = 'largeBwpPrbs'
    numAllocCellPrbDl = []
    numAllocCellPrbDlMicroDTX = []
    for lcrId in range(1, 4):
        filteredprbs_i = [int(i) for i in
                          list(map(lambda d: d[numAllocCellPrbDl_key],
                                   filter(lambda d: d['Event'] == 'dlDtxOptimData',
                                          filter(lambda d: d['sfn'] == sfntocheck,
                                                 filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]

        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlDtxOptimData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        if not filteredprbs_i:
            numAllocCellPrbDl.append(0)
        else:
            numAllocCellPrbDl.append(filteredprbs_i[1])
        # numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
        # numAllocCellPrbDl.append(int(filteredprbs[1]) if filteredprbs else 0)
    numAllocCellPrbDlMicroDTX.append({'sfn': sfntocheck, 'numAllocCellPrbDl': numAllocCellPrbDl})
    return numAllocCellPrbDlMicroDTX
    # return {'sfn': sfntocheck, 'numAllocCellPrbDlMicroDtx': numAllocCellPrbDl}


def get_numAllocCellPrbDl_MicroDtx_v1(tti_dic, sfntocheck):
    numAllocCellPrbDl_key = 'largeBwpPrbs'

    numAllocCellPrbDl = []
    for lcrId in range(1, 4):
        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlDtxOptimData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        # numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
        # numAllocCellPrbDl.append(int(filteredprbs[1]) if filteredprbs else 0)
        # print
        if filteredprbs:
            numAllocCellPrbDl.append(int(filteredprbs[0]))
    return {'sfn': sfntocheck, 'numAllocCellPrbDlMicroDtx': numAllocCellPrbDl}


def get_numOfPrb_dlFdSchedData(tti_dic, sfntocheck, num_of_events=10):
    numAllocCellPrbDl_key = 'numOfPrb'
    numOfPrbCellPrbDl = []
    numAllocCellPrbDldlFdSchedData = []
    line_count = 0
    for lcrId in range(1, 4):
        filteredprbs_i = [int(i) for i in
                          list(map(lambda d: d[numAllocCellPrbDl_key],
                                   filter(lambda d: d['Event'] == 'dlFdSchedData',
                                          filter(lambda d: d['sfn'] == sfntocheck,
                                                 filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))]

        filteredprbs = list(map(lambda d: d[numAllocCellPrbDl_key],
                                filter(lambda d: d['Event'] == 'dlFdSchedData',
                                       filter(lambda d: d['sfn'] == sfntocheck,
                                              filter(lambda d: d['lcrId'] == str(lcrId), tti_dic)))))
        if not filteredprbs_i:
            numOfPrbCellPrbDl.append(0)
        else:
            numOfPrbCellPrbDl.append(filteredprbs_i[1])
        line_count += 1
        if line_count > num_of_events:
            break
        # numAllocCellPrbDl.append(int(max(filteredprbs) if filteredprbs else 0))
        # numAllocCellPrbDl.append(int(filteredprbs[1]) if filteredprbs else 0)
    numAllocCellPrbDldlFdSchedData.append({'sfn': sfntocheck, 'numAllocCellPrbDl': numOfPrbCellPrbDl})
    return numAllocCellPrbDldlFdSchedData


def getValue(scfObj, pName, distName):
    outString = ""
    logging.info("getValue(): pName = %s" % (pName))
    logging.info("getValue(): outString = %s" % (outString))
    try:
        outString = scfObj.get_value_from_scf(p_name=pName, dist_name=distName)
        outString = "true" if outString == "True" else outString
        outString = "false" if outString == "False" else outString
        logging.info("getValue(): '%s' = '%s' (SCF)" % (pName, outString))
    except Exception as e:
        logException("getValue", e)
    return outString


def verifyParametersInScf(verifyScfList, scfFilePath):
    isPassed = True
    scfObj = scf()
    for parameter in verifyScfList:
        returnedValue = 0
        try:
            scfObj.load_scf(scfFilePath)
            returnedValue = getValue(scfObj, parameter["p_name"], parameter["dist_name"])
            aResult = (returnedValue == parameter["value"])
        except Exception as e:
            logException("verifyParametersInScf", e, silent=True)
            aResult = "SCF is NOT available"
            isPassed = False
        else:
            isPassed = (isPassed and aResult)
        logging.info(30*"-" + "> %s == %s (%s)" % (parameter["value"], returnedValue, aResult))
    return isPassed


def verify_SCF_Paramaters():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB008940/CB007113 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # scfFilePath = BuiltIn().run_keyword(
    #    "PRV-Common-Keywords.Get Testcase Log Directory") + "/SCF.xml"
    # BuiltIn().log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_bts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id)

    try:
        expected_scf_list = [{'p_name': 'actBbPoolTddFr1', 'value': 'true', 'dist_name': mr_nr_bts}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


def verify_SCF_Paramaters_TC_MicroDtx():
    # -------------------------------------------------------------------------------------------------[120 characters]
    # - CB008940/CB007113 feature should get activated
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SCF_correct = False
    path_to_scf_xml = rbi.get_variable_value("${test_scf_file}")
    # scfFilePath = BuiltIn().run_keyword(
    #    "PRV-Common-Keywords.Get Testcase Log Directory") + "/SCF.xml"
    # BuiltIn().log("verifyFeatureActivation: scfFilePath = %s (SCF)" % scfFilePath)
    mrbts_id = BuiltIn().get_variable_value('${MRBTS_ID}')
    nrbts_id = BuiltIn().get_variable_value('${NRBTS_ID}')
    mr_nr_bts = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id)
    mr_nr_bts_cell1 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-1'
    mr_nr_bts_cell2 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-2'
    mr_nr_bts_cell3 = 'MRBTS-' + str(mrbts_id) + '/NRBTS-' + str(nrbts_id) + '/NRCELL-3'

    try:
        expected_scf_list = [{'p_name': 'actBbPoolTddFr1', 'value': 'true', 'dist_name': mr_nr_bts},
                             {'p_name': 'actDtxOptimizedScheduler', 'value': 'true', 'dist_name': mr_nr_bts_cell1},
                             {'p_name': 'actDtxOptimizedScheduler', 'value': 'true', 'dist_name': mr_nr_bts_cell2},
                             {'p_name': 'actDtxOptimizedScheduler', 'value': 'true', 'dist_name': mr_nr_bts_cell3}]
        is_SCF_correct = verifyParametersInScf(expected_scf_list, path_to_scf_xml)
    except Exception as e:
        logException("verify_SCF_Paramaters", e)
    rbi.should_be_true(is_SCF_correct)


def load_dataframe(path_to_pickle):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_pickle)
    return df


def get_dtx_statistics_physCellId_ul(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def get_dtx_statistics_rnti_ul(filename):
    is_TTITrace_correct = False
    isPassed = True
    output = ""
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='rnti', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
        isPassed = False
    return output


def get_dtx_statistics_lcrId_ul(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='lcrId', direction='ul')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def get_dtx_statistics_physCellId_dl(filename):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = get_dtx_stats(df, by='physCellId', direction='dl')
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_dtx_statistics", e)
    return output


def log_begin_end_func_name(fn):
    def inner(*args, **kwargs):
        logging.info("============================== Begin Function {0}".format(fn.__name__))
        func_return = fn(*args, **kwargs)
        logging.info("============================== End Function {0}".format(fn.__name__))
        return func_return
    return inner


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='dl')
        logging.info("combined_mumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_dl", e)
    return combined_mumimo_stats, mumimo_stats


@log_begin_end_func_name
def get_mumimo_statistics_physCellId_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_mumimo_stats, mumimo_stats = get_mumimo_stats(df, by='physCellId', direction='ul')
        logging.info("combined_ulmumimo_stats = %s" % (combined_mumimo_stats))
    except Exception as e:
        logException("get_mumimo_statistics_physCellId_ul", e)
    return combined_mumimo_stats, mumimo_stats


def get_cells_and_ues_physCellId(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        output = identify_cells_and_ues(df)
        logging.info("output = %s" % (output))
    except Exception as e:
        logException("get_cells_and_ues_physCellId", e)
    return output


@log_begin_end_func_name
def get_rank_statistics_rnti_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='dl')
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_dl", e)
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_rank_statistics_rnti_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_rank_stats, rank_stats = generate_rank_stats(df, by='rnti', direction='ul')
        logging.info("combined_rank_stats = %s" % (combined_rank_stats))
    except Exception as e:
        logException("get_rank_statistics_rnti_ul", e)
    return combined_rank_stats, rank_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_dl(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='dl')
        logging.info("combined_dl_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_dl", e)
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_subcell_statistics_physCellId_ul(path_to_ttitrace_pkl):
    is_TTITrace_correct = False
    # path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    df = load_dataframe(path_to_ttitrace_pkl)
    try:
        combined_subcell_stats, subcell_stats = generate_subcellId_stats(df, by='physCellId', direction='ul')
        logging.info("combined_ul_subcell_stats = %s" % (combined_subcell_stats))
    except Exception as e:
        logException("get_subcell_statistics_physCellId_ul", e)
    return combined_subcell_stats, subcell_stats


@log_begin_end_func_name
def get_directory(path):
    path_tmp = path.split("/")
    path = "/".join(path_tmp[:-1])
    return path


@log_begin_end_func_name
def filter_dataframe_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulTdSchedSubcellData.subcellId',
                               'ulTdSchedSubcellData.numAllocCellPrbUl', 'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlTdSchedSubcellData.subcellId',
                               'dlTdSchedSubcellData.numAllocCellPrbDl', 'lcrId']
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_mumimo_dl(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'dlFdSchedData.subcellId',
                               'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers',
                               'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def filter_dataframe_mumimo_ul(df):
    required_discriminators = ['timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ulFdSchedData.subcellId',
                               'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers',
                               'lcrId']
    #  'dlFdSchedData.patternId1',
    df = df[required_discriminators].copy()
    df.dropna(inplace=True)
    df['timeStamp'] = pd.to_datetime(df['timeStamp']).copy()
    return df


@log_begin_end_func_name
def drop_head_tail_entries(df, num=1000):
    """Function drops num entries from the beginning and the end of the dataframe to compensate for the
    abnormalities seen in trace during start and stop of traffic"""
    df = df[num:-num]
    return df


@log_begin_end_func_name
def prepare_df_to_compute_average_ul_prb_allocation(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['ulTdSchedSubcellData.numAllocCellPrbUl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_average_dl_prb_allocation(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_statistics(df_pooled_subcells):
    df_stat = pd.DataFrame()
    df_stat = df_pooled_subcells.copy()
    df_stat.dropna(subset=['AveragePRBAllocationPerSubcell'], inplace=True)
    df_stat = df_stat[~df_stat.index.duplicated(keep='first')]
    df_stat['TotalPooledPRB'] = df_stat.groupby(level=[0, 1])['AveragePRBAllocationPerSubcell'].sum()
    df_stat['StreamPrbCapa'] = (df_stat.groupby(level=[0, 1])['AveragePRBAllocationPerSubcell'].sum())*4
    if True in df_stat.index.get_level_values(0).duplicated(keep=False):
        df_stat = df_stat[df_stat.index.get_level_values(0).duplicated(keep=False)]
    logging.info(df_stat)
    return df_stat


@log_begin_end_func_name
def run_load_based_prb_pooling_analysis_7113(path_to_pickle,
                                             subcell_expecting_higher_prb_allocation,
                                             list_of_pooled_subcells=[0, 2],
                                             exclude_samples_for_analysis=1000,
                                             list_of_non_pooled_subcells=[1],
                                             expected_total_prbs=352,
                                             expected_compliance_percentage=90):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_ul_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/ul_dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("CB007113 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def run_load_based_prb_pooling_analysis_8940(path_to_pickle,
                                             subcell_expecting_higher_prb_allocation,
                                             list_of_pooled_subcells=[0, 2],
                                             exclude_samples_for_analysis=1000,
                                             list_of_non_pooled_subcells=[1],
                                             expected_total_prbs=352,
                                             expected_compliance_percentage=90):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_dl_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/dl_dataframe_for_manual_analysis.csv" % get_directory(path_to_pickle)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("CB008940 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def prepare_df_to_compute_mumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlFdSchedData.subcellId',
                                  'dlFdSchedData.muStatus', 'dlFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def prepare_df_to_compute_ulmumimo_info(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['ulFdSchedData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'ulFdSchedData.subcellId',
                                  'ulFdSchedData.ulMuStatus', 'ulFdSchedData.numOfLayers'],
                                 inplace=True)
    # , 'dlFdSchedData.ackNack'
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    # df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
    #     df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def run_mumimo_load_based_prb_pooling_analysis_dl(path_to_pickle,
                                                  list_of_pooled_subcells=[0, 2],
                                                  list_of_non_pooled_subcells=[1],
                                                  exclude_samples_for_analysis=1000,
                                                  expected_total_prbs=352,
                                                  expected_compliance_percentage=90,
                                                  name='dl_dataframe_for_manual_analysis_mumimo_spool1'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_mumimo_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_mumimo_info(df,
                                                           list_of_pooled_subcells,
                                                           list_of_non_pooled_subcells)
    # df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    # df_pooled_subcells.to_csv(str("%s/dl_dataframe_for_manual_analysis_mumimo.csv" % get_directory(path_to_pickle)),
    #                           sep=';')
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    # total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    # logging.info("CB008940 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def run_ulmumimo_load_based_prb_pooling_analysis_ul(path_to_pickle,
                                                    list_of_pooled_subcells=[0, 2],
                                                    list_of_non_pooled_subcells=[1],
                                                    exclude_samples_for_analysis=1000,
                                                    expected_total_prbs=352,
                                                    expected_compliance_percentage=90,
                                                    name='ul_dataframe_for_manual_analysis_ulmumimo_spool1'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_mumimo_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_ulmumimo_info(df,
                                                             list_of_pooled_subcells,
                                                             list_of_non_pooled_subcells)
    # df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    # df_pooled_subcells.to_csv(str("%s/dl_dataframe_for_manual_analysis_mumimo.csv" % get_directory(path_to_pickle)),
    #                           sep=';')
    df_pooled_subcells.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    # total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    # logging.info("CB008940 total_prb_allocation_pooled_cells = %s" % total_prb_allocation_pooled_cells)


@log_begin_end_func_name
def prepare_df_to_compute_average_stream_prb(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    df_subcells = df
    logging.info(df_subcells)
    df_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlTdSchedSubcellData.subcellId'], inplace=True)
    df_subcells['AveragePRBAllocationPerSubcell'] = None
    df_subcells['AveragePRBAllocationPerSubcell'] = \
        df_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_subcells)
    return df_subcells


@log_begin_end_func_name
def check_total_stream_prbs(path_to_pickle,
                            list_of_pooled_subcells=[0, 2],
                            exclude_samples_for_analysis=1000,
                            list_of_non_pooled_subcells=[1],
                            expected_total_prbs=352,
                            expected_compliance_percentage=95,
                            name='dl_dataframe_for_manual_analysis_all_subcells'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_stream_prb(df,
                                                                  list_of_pooled_subcells,
                                                                  list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("check_total_pooled_prbs: total_dl_prb_allocation_pooled_cells = %s"
                 % total_prb_allocation_pooled_cells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


@log_begin_end_func_name
def verify_TTITraces_for_7113(expected_total_prbs=352):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    # ull1spcells[1]= [[0, 2, 4], [1]]
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_7113 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_7113 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        excluded_samples = 1000
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl, excluded_samples)
        run_load_based_prb_pooling_analysis_7113(path_to_ttitrace_pkl,
                                                 subcell_expecting_higher_prb_allocation=0,
                                                 # list_of_pooled_subcells=[0, 2],   => 8 X 4 DL MIMO case
                                                 # list_of_pooled_subcells=[0, 1, 4],  => 8 X 8 DL MIMO case
                                                 list_of_pooled_subcells=list_of_pooled_subcells,
                                                 # list_of_non_pooled_subcells=[1],  => 8 X 4 DL MIMO case
                                                 # list_of_non_pooled_subcells=[2],    => 8 X 8 DL MIMO case
                                                 list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                 exclude_samples_for_analysis=excluded_samples,
                                                 expected_total_prbs=int(expected_total_prbs))
        # logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_7113", e)
    # rbi.should_be_true(is_TTITrace_correct)


def verify_TTITraces_for_8940(expected_total_prbs=352):
    is_TTITrace_correct = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    # dll1spcells[1]=[[0,2,4][1]]
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_8940 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_8940 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        excluded_samples = 1000
        run_load_based_prb_pooling_analysis_8940(path_to_ttitrace_pkl,
                                                 subcell_expecting_higher_prb_allocation=0,
                                                 # list_of_pooled_subcells=[0, 1, 4, 5],  => 8 X 8 DL MIMO case
                                                 # list_of_pooled_subcells=[0, 2],    => 8 X 4 DL MIMO case
                                                 list_of_pooled_subcells=list_of_pooled_subcells,
                                                 # list_of_non_pooled_subcells=[2, 3],  => 8 X 8 DL MIMO case
                                                 # list_of_non_pooled_subcells=[1],  => 8 X 4 DL MIMO case
                                                 list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                 exclude_samples_for_analysis=excluded_samples,
                                                 expected_total_prbs=int(expected_total_prbs))
        # logging.info("is_TTITrace_correct = %s" % (is_TTITrace_correct))
    except Exception as e:
        logException("verify_TTITraces_for_8940", e)


@log_begin_end_func_name
def verify_TTITraces_for_CB008940_C1(expected_avg_total_prbs_spool1=546, expected_avg_total_prbs_spool2=78,
                                     expected_avg_total_prbsstream_spool1=2100,
                                     expected_avg_total_prbsstream_spool2=310):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_CB008940_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_CB008940_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = expected_avg_total_prbs_spool1  # <-- Subpool1
        # bypass acceptance criteria on prbs for spool1, keep only acceptance criteria on prbstream
        # is_TTITrace_correct_p1 = check_total_pooled_prbs(path_to_ttitrace_pkl,
        #                                                  list_of_pooled_subcells=list_of_pooled_subcells,
        #                                                  list_of_non_pooled_subcells=list_of_non_pooled_subcells,
        #                                                  exclude_samples_for_analysis=1000,
        #                                                  expected_total_prbs=expected_total_prbs,
        #                                                  expected_compliance_percentage=95,
        #                                                  name='dl_dataframe_for_manual_analysis_spool1')
        # logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # expected_total_prbs = 64  # <-- Subpool2 / TC 8940-L MicroDtx
        expected_total_prbs = expected_avg_total_prbs_spool2  # <-- Subpool2
        # bypass acceptance criteria on prbs for spool2, keep only acceptance criteria on prbstream
        # is_TTITrace_correct_p2 = check_total_pooled_prbs(path_to_ttitrace_pkl,
        #                                                  list_of_pooled_subcells=list_of_non_pooled_subcells,
        #                                                  list_of_non_pooled_subcells=list_of_pooled_subcells,
        #                                                  exclude_samples_for_analysis=1000,
        #                                                  expected_total_prbs=expected_total_prbs,
        #                                                  expected_compliance_percentage=70,
        #                                                  name='dl_dataframe_for_manual_analysis_spool2')
        # logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool1  # <-- Subpool1
        is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=90,
                                              name='dl_dataframe_for_manual_analysis_spool1')
        logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB008940_C1: averaged_total_dl_prbstream_pooled spool1'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))
        # expected_total_prbsstream = 240  # <-- Subpool2 / TC 8940-L MicroDtx / wo GBR
        expected_total_prbsstream = expected_avg_total_prbsstream_spool2  # <-- Subpool2
        is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_non_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=70,
                                              name='dl_dataframe_for_manual_analysis_spool2')
        logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB008940_C1: averaged_total_dl_prbstream_pooled spool2'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))
    except Exception as e:
        logException("verify_TTITraces_for_CB008940_C1", e)
    #  keep only acceptance criteria on prbstream
    rbi.should_be_true(is_TTITrace_correct_p3 and is_TTITrace_correct_p4)
    # rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
    #                   is_TTITrace_correct_p3 and is_TTITrace_correct_p4)


@log_begin_end_func_name
def verify_TTITraces_for_CB008940_C2(expected_avg_total_prbsstream_spool1=2100,
                                     expected_avg_total_prbsstream_spool2=300,
                                     min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_CB008940_C2 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_CB008940_C2 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = int(expected_avg_total_prbsstream_spool1 / 4)
        is_TTITrace_correct_p0 = check_total_stream_prbs(path_to_ttitrace_pkl,
                                                         list_of_pooled_subcells=list_of_pooled_subcells,
                                                         list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                         exclude_samples_for_analysis=1000,
                                                         expected_total_prbs=expected_total_prbs,
                                                         expected_compliance_percentage=70,
                                                         name='dl_dataframe_for_manual_analysis_all_subcells')
        logging.info("verify_TTITraces_for_CB008940_C2: is_TTITrace_correct_p0 = %s" % (is_TTITrace_correct_p0))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool1  # <-- Subpool1
        # expected_total_prbsstream = 2100  # <-- Subpool1
        is_TTITrace_correct_p1, averaged_total_prbstream_pooled_spool1 = \
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=90,
                                              name='dl_dataframe_for_manual_analysis_spool1')
        logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        logging.info("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
        msg = 'verify_TTITraces_for_CB008940_C2: averaged_total_prbstream_spool1'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool1))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool2  # <-- Subpool1
        # expected_total_prbsstream = 310  # <-- Subpool1
        is_TTITrace_correct_p2, averaged_total_prbstream_pooled_spool2 = \
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_non_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=70,
                                              name='dl_dataframe_for_manual_analysis_spool2')
        logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        logging.info("averaged_total_prbstream_spool2 = %s" % (averaged_total_prbstream_pooled_spool2))
        msg = 'verify_TTITraces_for_CB008940_C2: averaged_total_prbstream_spool2'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool2))
        resultTest = False
        sum = averaged_total_prbstream_pooled_spool1 + averaged_total_prbstream_pooled_spool2
        if (sum >= min_total_prbstream and sum <= max_total_prbstream):
            resultTest = True
        else:
            resultTest = False
        logging.info("verify_TTITraces_for_CB008940_C2: averaged_total_prbstream resultTest = %s" % (resultTest))
        msg = 'verify_TTITraces_for_CB008940_C2: Check averaged_total_prbstream resultTest: '
        datedConsole(getHeaderLine(msg, resultTest))
    except Exception as e:
        logException("verify_TTITraces_for_CB008940_C2", e)
    rbi.should_be_true(resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_MUMIMO_C1(expected_avg_total_prbsstream_spool1=2100,
                                   expected_avg_total_prbsstream_spool2=300,
                                   min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_MUMIMO_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_MUMIMO_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = int(expected_avg_total_prbsstream_spool1 / 4)    # <-- Subpool1
        is_TTITrace_correct_p0 =\
            run_mumimo_load_based_prb_pooling_analysis_dl(path_to_ttitrace_pkl,
                                                          list_of_pooled_subcells=list_of_pooled_subcells,
                                                          list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                          exclude_samples_for_analysis=1000,
                                                          expected_total_prbs=expected_total_prbs,
                                                          expected_compliance_percentage=95,
                                                          name='dl_dataframe_for_manual_analysis_mumimo_spool1')
        logging.info("verify_TTITraces_for_MUMIMO_C1: is_TTITrace_correct_p0 = %s" % (is_TTITrace_correct_p0))
        expected_total_prbs = int(expected_avg_total_prbsstream_spool2 / 4)    # <-- Subpool2
        is_TTITrace_correct_p1 = \
            run_mumimo_load_based_prb_pooling_analysis_dl(path_to_ttitrace_pkl,
                                                          list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                          list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                          exclude_samples_for_analysis=1000,
                                                          expected_total_prbs=expected_total_prbs,
                                                          expected_compliance_percentage=70,
                                                          name='dl_dataframe_for_manual_analysis_mumimo_spool2')
        logging.info("verify_TTITraces_for_MUMIMO_C1: is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # logging.info("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
        # msg = 'verify_TTITraces_for_MUMIMO_C1: averaged_total_prbstream_spool1'
        # datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool1))
    except Exception as e:
        logException("verify_TTITraces_for_MUMIMO_C1", e)
    # rbi.should_be_true(resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_ULMUMIMO_C1(expected_avg_total_prbsstream_spool1=2100,
                                     expected_avg_total_prbsstream_spool2=300,
                                     min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p0 = False
    is_TTITrace_correct_p1 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_ULMUMIMO_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_ULMUMIMO_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = int(expected_avg_total_prbsstream_spool1 / 4)    # <-- Subpool1
        is_TTITrace_correct_p0 =\
            run_ulmumimo_load_based_prb_pooling_analysis_ul(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=95,
                                                            name='ul_dataframe_for_manual_analysis_ulmumimo_spool1')
        logging.info("verify_TTITraces_for_MUMIMO_C1: is_TTITrace_correct_p0 = %s" % (is_TTITrace_correct_p0))
        expected_total_prbs = int(expected_avg_total_prbsstream_spool2 / 4)    # <-- Subpool2
        is_TTITrace_correct_p1 = \
            run_ulmumimo_load_based_prb_pooling_analysis_ul(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=70,
                                                            name='ul_dataframe_for_manual_analysis_ulmumimo_spool2')
        logging.info("verify_TTITraces_for_ULMUMIMO_C1: is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # logging.info("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
        # msg = 'verify_TTITraces_for_ULMUMIMO_C1: averaged_total_prbstream_spool1'
        # datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled_spool1))
    except Exception as e:
        logException("verify_TTITraces_for_ULMUMIMO_C1", e)
    # rbi.should_be_true(resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_CB007113_C1(min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 205 <-- big Subpool1
    #   cell1 gets 205 <-- small Subpool2
    #   cell2 gets 205 <-- big Subpool1
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 69
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_CB007113_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_CB007113_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = 546  # <-- big Subpool1
        is_TTITrace_correct_p1 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=95,
                                                            name='ul_dataframe_for_manual_analysis_spool1')
        logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        expected_total_prbs = 273  # <-- small Subpool2
        is_TTITrace_correct_p2 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=70,
                                                            name='ul_dataframe_for_manual_analysis_spool2')
        logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        expected_total_prbsstream = 2184  # <-- big Subpool1
        is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=95,
                                                name='ul_dataframe_for_manual_analysis_spool1')
        logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
        logging.info("averaged_total_ul_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool1', averaged_total_prbstream_pooled))
        averaged_total_prbstream_pooled_spool1 = averaged_total_prbstream_pooled
        expected_total_prbsstream = 1092  # <-- small Subpool2
        is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_non_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=70,
                                                name='ul_dataframe_for_manual_analysis_spool2')
        logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool2', averaged_total_prbstream_pooled))
        averaged_total_prbstream_pooled_spool2 = averaged_total_prbstream_pooled
        sum = averaged_total_prbstream_pooled_spool1 + averaged_total_prbstream_pooled_spool2
        if (sum >= min_total_prbstream and sum <= max_total_prbstream):
            resultTest = True
        else:
            resultTest = False
        logging.info("verify_TTITraces_for_CB007113_C1: averaged_total_prbstream resultTest = %s" % (resultTest))
        msg = 'verify_TTITraces_for_CB007113_C1: Check averaged_total_prbstream resultTest: '
        datedConsole(getHeaderLine(msg, resultTest))
    except Exception as e:
        logException("verify_TTITraces_for_CB007113_C1", e)
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                       is_TTITrace_correct_p3 and is_TTITrace_correct_p4 and resultTest)


@log_begin_end_func_name
def verify_TTITraces_for_CB011028_C1(path_to_pickle,
                                     name='dl_df_for_manual_analysis_all_subcells_CB011028'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB011028.pkl'
    filter_valid_events_and_check_CB011028(path_to_pickle=path_to_ttitrace_pkl,
                                           target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_C1(path_to_pickle,
                                     name='dl_df_for_manual_analysis_all_subcells_CB009890'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB009890.pkl'
    filter_valid_events_and_check_CB011028(path_to_pickle=path_to_ttitrace_pkl,
                                           target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_C2(path_to_pickle, maxNumDlSubcellL1Pool=6, maxNumDlSubcellL1Sp=4):
    path_to_ttitrace_pkl = path_to_pickle
    check_CB009890(path_to_pickle=path_to_ttitrace_pkl, maxNumDlSubcellL1Pool=maxNumDlSubcellL1Pool,
                   maxNumDlSubcellL1Sp=maxNumDlSubcellL1Sp)


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_A_C3(path_to_pickle,
                                       name='dl_df_for_manual_analysis_all_subcells_CB009890_A_2'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB009890_A_2.pkl'
    filter_valid_events_and_check_CB009890_A_2(path_to_pickle=path_to_ttitrace_pkl,
                                               target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_B_C1(path_to_pickle,
                                       name='ul_df_for_manual_analysis_all_subcells_CB009890_B'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/filtered_ttiTrace_CB009890_B.pkl'
    filter_valid_events_and_check_CB009890_UL(path_to_pickle=path_to_ttitrace_pkl,
                                              target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    return path_to_filtered_ttitrace_pkl


@log_begin_end_func_name
def verify_TTITraces_for_CB011028_FdSched(path_to_pickle,
                                          name='dl_df_for_manual_analysis_all_subcells_FdSched'):
    path_to_ttitrace_pkl = path_to_pickle
    path_to_filtered_ttitrace_pkl = get_directory(path_to_pickle)+'/ttitrace_streaming_FdSched_NbrPrb.pkl'
    filter_valid_events_and_check_dlFdSchedData(path_to_pickle=path_to_ttitrace_pkl,
                                                target_pkl_path=path_to_filtered_ttitrace_pkl)
    df = load_dataframe(path_to_pickle=path_to_filtered_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';', quoting=csv.QUOTE_NONNUMERIC)


@log_begin_end_func_name
def verify_TTITraces_for_CB009890_B_C2(path_to_pickle, maxNumUlSubcellL1Pool=6, maxNumUlSubcellL1Sp=4):
    path_to_ttitrace_pkl = path_to_pickle
    check_CB009890_UL(path_to_pickle=path_to_ttitrace_pkl, maxNumUlSubcellL1Pool=maxNumUlSubcellL1Pool,
                      maxNumUlSubcellL1Sp=maxNumUlSubcellL1Sp)


@log_begin_end_func_name
def verify_TTITraces_for_acknack_retx(path_to_pickle):
    check_nack.filter_valid_events_and_check_acknack_retx(path_to_pickle=path_to_pickle)


@log_begin_end_func_name
def check_total_pooled_prbs(path_to_pickle,
                            list_of_pooled_subcells=[0, 2],
                            exclude_samples_for_analysis=1000,
                            list_of_non_pooled_subcells=[1],
                            expected_total_prbs=352,
                            expected_compliance_percentage=95,
                            name='dl_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_prb_allocation(df,
                                                                      list_of_pooled_subcells,
                                                                      list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("check_total_pooled_prbs: total_dl_prb_allocation_pooled_cells = %s"
                 % total_prb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


def check_total_pooled_prbsstreamcapa(path_to_pickle,
                                      list_of_pooled_subcells=[0, 2],
                                      exclude_samples_for_analysis=1000,
                                      list_of_non_pooled_subcells=[1],
                                      expected_total_prbsstream=1200,
                                      expected_compliance_percentage=95,
                                      name='dl_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_dl(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_prb_allocation(df,
                                                                      list_of_pooled_subcells,
                                                                      list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_streamprb_allocation_pooled_cells = df_stat['StreamPrbCapa'].value_counts()
    logging.info("check_total_pooled_streamprbs: total_streamprb_allocation_pooled_cells = %s"
                 % total_streamprb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period, averaged_total_prb_pooled = validate_averaged_total_prbsstream_allocated(
        total_streamprb_allocation_pooled_cells.to_dict(), expected_total_prbsstream, expected_compliance_percentage,
        list_of_pooled_subcells)
    return all([result_total_prb_in_pooling_period]), averaged_total_prb_pooled


@log_begin_end_func_name
def check_total_pooled_ul_prbs(path_to_pickle,
                               list_of_pooled_subcells=[0, 2],
                               exclude_samples_for_analysis=1000,
                               list_of_non_pooled_subcells=[1],
                               expected_total_prbs=352,
                               expected_compliance_percentage=95,
                               name='ul_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_ul_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_prb_allocation_pooled_cells = df_stat['TotalPooledPRB'].value_counts()
    logging.info("check_total_pooled_prbs: total_ul_prb_allocation_pooled_cells = %s"
                 % total_prb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period = validate_averaged_total_prbs_allocated(
        total_prb_allocation_pooled_cells.to_dict(), expected_total_prbs, expected_compliance_percentage)
    return all([result_total_prb_in_pooling_period])


def check_total_pooled_ulprbsstreamcapa(path_to_pickle,
                                        list_of_pooled_subcells=[0, 2],
                                        exclude_samples_for_analysis=1000,
                                        list_of_non_pooled_subcells=[1],
                                        expected_total_prbsstream=1200,
                                        expected_compliance_percentage=95,
                                        name='ul_dataframe_for_manual_analysis'):
    df = load_dataframe(path_to_pickle=path_to_pickle)
    df = filter_dataframe_ul(df)
    df = drop_head_tail_entries(df, num=exclude_samples_for_analysis)
    df_pooled_subcells = prepare_df_to_compute_average_ul_prb_allocation(df,
                                                                         list_of_pooled_subcells,
                                                                         list_of_non_pooled_subcells)
    df_stat = prepare_df_to_compute_statistics(df_pooled_subcells)
    df_stat.to_csv(str("%s/%s.csv" % (get_directory(path_to_pickle), name)), sep=';')
    total_streamprb_allocation_pooled_cells = df_stat['StreamPrbCapa'].value_counts()
    logging.info("check_total_pooled_streamprbs: total_ul_streamprb_allocation_pooled_cells = %s"
                 % total_streamprb_allocation_pooled_cells)
    # plot_figure(get_directory(path_to_pickle), df_stat, list_of_pooled_subcells)
    result_total_prb_in_pooling_period, averaged_total_prb_pooled = validate_averaged_total_prbsstream_allocated(
        total_streamprb_allocation_pooled_cells.to_dict(), expected_total_prbsstream, expected_compliance_percentage,
        list_of_pooled_subcells)
    return all([result_total_prb_in_pooling_period]), averaged_total_prb_pooled


@log_begin_end_func_name
def prepare_df_to_compute_average_prb_allocation(df, list_of_pooled_subcells, list_of_non_pooled_subcells):
    for non_pooled_subcell in list_of_non_pooled_subcells:
        df = df.where(df['dlTdSchedSubcellData.subcellId'] != non_pooled_subcell).dropna()
    df_pooled_subcells = df
    logging.info(df_pooled_subcells)
    df_pooled_subcells.set_index(['timeStamp', 'sfn',	'slot', 'dlTdSchedSubcellData.subcellId'], inplace=True)
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = None
    df_pooled_subcells['AveragePRBAllocationPerSubcell'] = \
        df_pooled_subcells.groupby(level=[0, 1, 2, 3])['dlTdSchedSubcellData.numAllocCellPrbDl'].mean()
    logging.info(df_pooled_subcells)
    return df_pooled_subcells


@log_begin_end_func_name
def weighted_average(distribution, weights):
    return int(round(sum([distribution[i]*weights[i] for i in range(len(distribution))])/sum(weights), 2))


@log_begin_end_func_name
def validate_averaged_total_prbs_allocated(result, expected_total_prbs=352, expected_compliance_percentage=95):
    """Generates verdict to ensure the total prbs allocated per subcell matches the expected total prbs"""
    logging.info("result = %s" % result)
    logging.info("expected_total_prbs = %s" % expected_total_prbs)
    tolerance = int(expected_total_prbs * (100 - expected_compliance_percentage) / 100)
    defined_range_expected_total_prbs = list(range(expected_total_prbs - tolerance, expected_total_prbs + tolerance))
    logging.info("defined_range_expected_total_prbs = %s" % defined_range_expected_total_prbs)
    noise = int(len(result)/3) + 1
    averaged_total_prb_pooled = weighted_average(list(result.keys())[:noise], list(result.values())[:noise])
    logging.info("averaged_total_prb_pooled = %s" % averaged_total_prb_pooled)
    if averaged_total_prb_pooled in defined_range_expected_total_prbs:
        logging.info("Total [DL/UL] PRBs in pooled subcells matches expected total prbs")
        return True
    else:
        logging.error("Total [DL/UL] PRBs (%s) in pooled subcells does not match expected total prbs (%s)"
                      % (result, defined_range_expected_total_prbs))
        return False
    return averaged_total_prb_pooled


@log_begin_end_func_name
def validate_averaged_total_prbsstream_allocated(result, expected_total_prbs=352, expected_compliance_percentage=95,
                                                 list_of_pooled_subcells=[0, 2]):
    """Generates verdict to ensure the total prbs allocated per subcell matches the expected total prbs"""
    resultTest = False
    logging.info("result = %s" % result)
    logging.info("expected_total_prbsstream = %s" % expected_total_prbs)
    tolerance = int(expected_total_prbs * (100 - expected_compliance_percentage) / 100)
    defined_range_expected_total_prbs = list(range(expected_total_prbs - tolerance, expected_total_prbs + tolerance))
    logging.info("defined_range_expected_total_prbsstream = %s" % defined_range_expected_total_prbs)
    noise = int(len(result)/3) + 1
    averaged_total_prb_pooled = weighted_average(list(result.keys())[:noise], list(result.values())[:noise])
    logging.info("averaged_total_dl_prbstream_pooled = %s" % averaged_total_prb_pooled)
    if averaged_total_prb_pooled in defined_range_expected_total_prbs:
        logging.info("Total [DL/UL] PRBs Stream in pooled subcells matches expected total prbs")
        resultTest = True
    else:
        logging.error(
            "Total [DL/UL] PRBs Stream (%s) in pooled subcells does not match expected total prbs (%s) for SubPool (%s}"
            % (result, defined_range_expected_total_prbs, list_of_pooled_subcells))
        resultTest = False
    return resultTest, averaged_total_prb_pooled


@log_begin_end_func_name
def extract_l1subpool_cell_relation(filename):
    phycell_ul_subcell = {}
    l1_subcell_pool_lcr_id = {}
    logging.info("extract_l1subpool_cell_relation: pdml file = %s" % (filename))
    with open(filename, "rb") as file_obj:
        print("Extracting data from Cell Setup Trace")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "icom_5g" in root:
                phycell_id = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                        "itf_l2_ps_cell_CellSetupReq_t.physCellId")
                lcr_id = root.xpath("icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//"
                                    "itf_l2_ps_cell_CellSetupReq_t.lcrId")
                ulsubcell_pool_id = root.xpath(
                    "icom_5g//pscell//itf_l2_ps_cell_cellsetupreq//itf_l2_ps_ulsubcell//*")
                if len(phycell_id) != 0:
                    phycell_id = int(phycell_id[0].show)
                    lcr_id = int(lcr_id[0].show)
                    for item in ulsubcell_pool_id:
                        if "l1SubPoolId" in str(item.showname):
                            l1_pool_id = item.show
                            phycell_ul_subcell[phycell_id] = int(l1_pool_id)
                            if l1_subcell_pool_lcr_id.get(int(l1_pool_id)) is not None:
                                l1_subcell_pool_lcr_id[int(
                                    l1_pool_id)].append(lcr_id)
                            else:
                                l1_subcell_pool_lcr_id[int(l1_pool_id)] = [
                                    lcr_id]
                            break
    return l1_subcell_pool_lcr_id, phycell_ul_subcell


@log_begin_end_func_name
def verify_CellSetup_SysCom_Pdml_Traces():
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_SysCom_correct = False
    path_to_syscom_pdml = rbi.get_variable_value("${path_to_syscom_pdml}")
    logging.info("pdml file = %s" % (path_to_syscom_pdml))
    expected_phycell_ul_subcell = {50: 0, 51: 1, 52: 0}
    expected_l1_subcell_pool_lcr_id = {0: [1, 3], 1: [2]}
    try:
        l1_subcell_pool_lcr_id, phycell_ul_subcell = extract_l1subpool_cell_relation(path_to_syscom_pdml)
        is_SysCom_correct = ((expected_phycell_ul_subcell == phycell_ul_subcell) and
                             (expected_l1_subcell_pool_lcr_id == l1_subcell_pool_lcr_id))
        logging.info("phycell_ul_subcell = %s" % (phycell_ul_subcell))
        logging.info("l1_subcell_pool_lcr_id = %s" % (l1_subcell_pool_lcr_id))
    except Exception as e:
        logException("verify_CellSetup_SysCom_Pdml_Traces", e)
    rbi.should_be_true(is_SysCom_correct)


@log_begin_end_func_name
def verify_TTITraces_for_CB011028_C_DL_case(expected_avg_total_prbs_spool1_poolId10=546,
                                            expected_avg_total_prbs_spool2_poolId10=78,
                                            expected_avg_total_prbsstream_spool1_poolId10=2100,
                                            expected_avg_total_prbsstream_spool2_poolId10=310,
                                            expected_avg_total_prbsstream_spool1_poolId13=2100):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 300 <--  Subpool1 (1200)
    #   cell1 gets 300 <--  Subpool2 (1200)
    #   cell2 gets 300 <--  Subpool1  (1200)
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 64
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    is_TTITrace_correct_p5 = False
    is_TTITrace_correct_p6 = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${dll1spcells[0]}")
    print("verify_TTITraces_for_CB011028_C_DL_case : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${dll1spcells[1]}")
    print("verify_TTITraces_for_CB011028_C_DL_case : list_of_non_pooled_subcells=" +
          str(list_of_non_pooled_subcells)[1:-1])
    try:
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = expected_avg_total_prbs_spool1_poolId10  # <-- Subpool1
        list_of_pooled_subcells = [0, 3, 7, 8]
        list_of_non_pooled_subcells = [1, 6, 4, 5, 2, 9, 10, 11]
        is_TTITrace_correct_p1 = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                         list_of_pooled_subcells=list_of_pooled_subcells,
                                                         list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                         exclude_samples_for_analysis=1000,
                                                         expected_total_prbs=expected_total_prbs,
                                                         expected_compliance_percentage=90,
                                                         name='dl_dataframe_for_manual_analysis_spool1_poolId10')
        logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        # expected_total_prbs = 64  # <-- Subpool2 / TC 8940-L MicroDtx
        expected_total_prbs = expected_avg_total_prbs_spool2_poolId10   # <-- Subpool2
        list_of_pooled_subcells = [2, 9]
        list_of_non_pooled_subcells = [0, 3, 7, 8, 1, 6, 4, 5, 10, 11]
        is_TTITrace_correct_p2 = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                         list_of_pooled_subcells=list_of_pooled_subcells,
                                                         list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                         exclude_samples_for_analysis=1000,
                                                         expected_total_prbs=expected_total_prbs,
                                                         expected_compliance_percentage=70,
                                                         name='dl_dataframe_for_manual_analysis_spool2_poolId10')
        logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool1_poolId10  # <-- Subpool1
        list_of_pooled_subcells = [0, 3, 7, 8]
        list_of_non_pooled_subcells = [1, 6, 4, 5, 2, 9, 10, 11]
        is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=90,
                                              name='dl_dataframe_for_manual_analysis_spool1_poolId10')
        logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB011028_C_DL_case: averaged_total_dl_prbstream_pooled spool1 poolId10'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))
        # expected_total_prbsstream = 240  # <-- Subpool2 / TC 8940-L MicroDtx / wo GBR
        expected_total_prbsstream = expected_avg_total_prbsstream_spool2_poolId10  # <-- Subpool2
        list_of_pooled_subcells = [2, 9]
        list_of_non_pooled_subcells = [0, 3, 7, 8, 1, 6, 4, 5, 10, 11]
        is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=70,
                                              name='dl_dataframe_for_manual_analysis_spool2_poolId10')
        logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB011028_C_DL_case: averaged_total_dl_prbstream_pooled spool2 poolId10'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))
        # expected_total_prbs = expected_avg_total_prbs_spool1_poolId10  # <-- Subpool1
        expected_total_prbs = 1092  # <-- Subpool1
        list_of_pooled_subcells = [1, 6, 4, 5]
        list_of_non_pooled_subcells = [0, 3, 7, 8, 2, 9, 10, 11]
        is_TTITrace_correct_p5 = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                         list_of_pooled_subcells=list_of_pooled_subcells,
                                                         list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                         exclude_samples_for_analysis=1000,
                                                         expected_total_prbs=expected_total_prbs,
                                                         expected_compliance_percentage=95,
                                                         name='dl_dataframe_for_manual_analysis_spool1_poolId13')
        logging.info("is_TTITrace_correct_p5 = %s" % (is_TTITrace_correct_p5))
        expected_total_prbsstream = expected_avg_total_prbsstream_spool1_poolId13  # <-- Subpool2
        list_of_pooled_subcells = [1, 6, 4, 5]
        # list_of_pooled_subcells = [10, 11]
        list_of_non_pooled_subcells = [0, 3, 7, 8, 2, 9, 10, 11]
        is_TTITrace_correct_p6, averaged_total_prbstream_pooled = \
            check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                              list_of_pooled_subcells=list_of_pooled_subcells,
                                              list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                              exclude_samples_for_analysis=1000,
                                              expected_total_prbsstream=expected_total_prbsstream,
                                              expected_compliance_percentage=70,
                                              name='dl_dataframe_for_manual_analysis_spool1_poolId13')
        logging.info("is_TTITrace_correct_p6 = %s" % (is_TTITrace_correct_p6))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        msg = 'verify_TTITraces_for_CB011028_C_DL_case: averaged_total_dl_prbstream_pooled spool1 poolId13'
        datedConsole(getHeaderLine(msg, averaged_total_prbstream_pooled))

    except Exception as e:
        logException("verify_TTITraces_for_CB011028_C_DL_case", e)
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                       is_TTITrace_correct_p3 and is_TTITrace_correct_p4)


@log_begin_end_func_name
def verify_TTITraces_for_CB011028_C_UL_case(min_total_prbstream=2370, max_total_prbstream=2420):
    # -------------------------------------------------------------------------------------------------[120 characters]
    # Vendor file reduction:
    #   cell0 gets 205 <-- big Subpool1
    #   cell1 gets 205 <-- small Subpool2
    #   cell2 gets 205 <-- big Subpool1
    # Hightraffic on Subpool cells causes the following PRB destribution:
    #   cell0 gets 273
    #   cell1 gets 69
    #   cell2 gets 273
    # where an extra PRBs are taken from Cell1
    # -------------------------------------------------------------------------------------------------[120 characters]
    is_TTITrace_correct_p1 = False
    is_TTITrace_correct_p2 = False
    is_TTITrace_correct_p3 = False
    is_TTITrace_correct_p4 = False
    is_TTITrace_correct_p5 = False
    resultTest = False
    path_to_ttitrace_pkl = rbi.get_variable_value("${path_to_ttitrace_pkl}")
    list_of_pooled_subcells = rbi.get_variable_value("${ull1spcells[0]}")
    print("verify_TTITraces_for_CB007113_C1 : list_of_pooled_subcells=" + str(list_of_pooled_subcells)[1:-1])
    list_of_non_pooled_subcells = rbi.get_variable_value("${ull1spcells[1]}")
    print("verify_TTITraces_for_CB007113_C1 : list_of_non_pooled_subcells=" + str(list_of_non_pooled_subcells)[1:-1])
    try:
        # plot_prb_allocation_per_subcell(path_to_ttitrace_pkl)
        logging.basicConfig(level=logging.DEBUG)
        expected_total_prbs = 516  # <-- big Subpool1
        list_of_pooled_subcells = [0, 3]
        list_of_non_pooled_subcells = [1, 6, 2, 9]
        is_TTITrace_correct_p1 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=95,
                                                            name='ul_dataframe_for_manual_analysis_spool1_poolId10')
        logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
        expected_total_prbs = 273  # <-- small Subpool2
        list_of_pooled_subcells = [2, 9]
        list_of_non_pooled_subcells = [0, 3, 1, 6]
        is_TTITrace_correct_p2 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
                                                            list_of_pooled_subcells=list_of_pooled_subcells,
                                                            list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                            exclude_samples_for_analysis=1000,
                                                            expected_total_prbs=expected_total_prbs,
                                                            expected_compliance_percentage=70,
                                                            name='ul_dataframe_for_manual_analysis_spool2_poolId10')
        logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
        expected_total_prbsstream = 2064  # <-- big Subpool1
        list_of_pooled_subcells = [0, 3]
        list_of_non_pooled_subcells = [1, 6, 2, 9]
        is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=95,
                                                name='ul_dataframe_for_manual_analysis_spool1_poolId10')
        logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
        logging.info("averaged_total_ul_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool1 poolId10',
                                   averaged_total_prbstream_pooled))
        averaged_total_prbstream_pooled_spool1 = averaged_total_prbstream_pooled
        expected_total_prbsstream = 1092  # <-- small Subpool2
        list_of_pooled_subcells = [2, 9]
        list_of_non_pooled_subcells = [0, 3, 1, 6]
        is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=70,
                                                name='ul_dataframe_for_manual_analysis_spool2_poolId10')
        logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool2 poolId10',
                                   averaged_total_prbstream_pooled))
        averaged_total_prbstream_pooled_spool2 = averaged_total_prbstream_pooled
        sum = averaged_total_prbstream_pooled_spool1 + averaged_total_prbstream_pooled_spool2
        if (sum >= min_total_prbstream and sum <= max_total_prbstream):
            resultTest = True
        else:
            resultTest = False
        logging.info("verify_TTITraces_for_CB011028_C_UL_case: averaged_total_prbstream PoolId10 resultTest = %s"
                     % (resultTest))
        msg = 'verify_TTITraces_for_CB011028_C_UL_case: Check averaged_total_prbstream PoolId10 resultTest: '
        datedConsole(getHeaderLine(msg, resultTest))
        averaged_total_prbstream_pooled_spool1 = averaged_total_prbstream_pooled
        expected_total_prbsstream = 2064  # <-- Subpool1
        list_of_pooled_subcells = [1, 6]
        list_of_non_pooled_subcells = [0, 3, 2, 9]
        is_TTITrace_correct_p5, averaged_total_prbstream_pooled = \
            check_total_pooled_ulprbsstreamcapa(path_to_ttitrace_pkl,
                                                list_of_pooled_subcells=list_of_pooled_subcells,
                                                list_of_non_pooled_subcells=list_of_non_pooled_subcells,
                                                exclude_samples_for_analysis=1000,
                                                expected_total_prbsstream=expected_total_prbsstream,
                                                expected_compliance_percentage=70,
                                                name='ul_dataframe_for_manual_analysis_spool1_poolId13')
        logging.info("is_TTITrace_correct_p5 = %s" % (is_TTITrace_correct_p5))
        logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
        datedConsole(getHeaderLine('averaged_total_ul_prbstream_pooled spool1 poolId13',
                                   averaged_total_prbstream_pooled))
    except Exception as e:
        logException("verify_TTITraces_for_CB011028_C_UL_case", e)
    rbi.should_be_true(is_TTITrace_correct_p1 and is_TTITrace_correct_p2 and
                       is_TTITrace_correct_p3 and is_TTITrace_correct_p4 and resultTest)


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    # path_to_ttitrace_pkl = "/home/ute/csamson/TRACES/9890/ttitrace_streaming.pkl"
    path_to_ttitrace_pkl = "/home/ute/csamson/TRACES/ttitrace_streaming.pkl"
    pd = pandas_gate.install_and_import_pandas()
    df = pd.read_pickle(path_to_ttitrace_pkl)
    df.to_csv(str("%s/%s.csv" % (get_directory(path_to_ttitrace_pkl), 'ttiTrace_test')), sep=';')
    path_to_filtered_ttitrace_pkl = get_directory(path_to_ttitrace_pkl) + '/filtered_ttiTrace_CB011028.pkl'
    filter_valid_events_and_check_CB011028(path_to_ttitrace_pkl, path_to_filtered_ttitrace_pkl)
    # verify_TTITraces_for_CB011028_C2(path_to_filtered_ttitrace_pkl)
    # check_CB011028(path_to_filtered_ttitrace_pkl)

    expected_total_prbs = 546  # <-- Subpool1
    is_TTITrace_correct_p1 = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                     list_of_pooled_subcells=[0, 3, 7, 8],
                                                     list_of_non_pooled_subcells=[1, 6, 4, 5, 2, 9, 10, 11],
                                                     exclude_samples_for_analysis=1000,
                                                     expected_total_prbs=expected_total_prbs,
                                                     expected_compliance_percentage=95,
                                                     name='dl_dataframe_for_manual_analysis_spool1_poolId10')
    logging.info("is_TTITrace_correct_p1 = %s" % (is_TTITrace_correct_p1))
    expected_total_prbs = 64  # <-- Subpool2
    is_TTITrace_correct_p2 = check_total_pooled_prbs(path_to_ttitrace_pkl,
                                                     list_of_pooled_subcells=[2, 9],
                                                     list_of_non_pooled_subcells=[0, 3, 7, 8, 1, 6, 4, 5, 10, 11],
                                                     exclude_samples_for_analysis=1000,
                                                     expected_total_prbs=expected_total_prbs,
                                                     expected_compliance_percentage=80,
                                                     name='dl_dataframe_for_manual_analysis_spool2_poolId10')
    logging.info("is_TTITrace_correct_p2 = %s" % (is_TTITrace_correct_p2))
    expected_total_prbsstream = 2100  # <-- Subpool1
    is_TTITrace_correct_p3, averaged_total_prbstream_pooled =\
        check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                          list_of_pooled_subcells=[1, 6, 4, 5],
                                          list_of_non_pooled_subcells=[0, 3, 7, 8, 2, 9, 10, 11],
                                          exclude_samples_for_analysis=1000,
                                          expected_total_prbsstream=expected_total_prbsstream,
                                          expected_compliance_percentage=95,
                                          name='dl_dataframe_for_manual_analysis_spool1_poolId13')
    logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
    logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
    datedConsole(getHeaderLine('averaged_total_prbstream_pooled', averaged_total_prbstream_pooled))
    expected_total_prbsstream = 240  # <-- Subpool1
    is_TTITrace_correct_p4, averaged_total_prbstream_pooled =\
        check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                          list_of_pooled_subcells=[10, 11],
                                          list_of_non_pooled_subcells=[0, 3, 7, 8, 1, 6, 4, 5, 2, 9],
                                          exclude_samples_for_analysis=1000,
                                          expected_total_prbsstream=expected_total_prbsstream,
                                          expected_compliance_percentage=95,
                                          name='dl_dataframe_for_manual_analysis_spool2_PoolId13')
    logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
    logging.info("averaged_total_prbstream_pooled = %s" % (averaged_total_prbstream_pooled))
    datedConsole(getHeaderLine('averaged_total_prbstream_pooled', averaged_total_prbstream_pooled))
    # expected_total_prbs = 506  # <-- big Subpool1
    # is_TTITrace_correct_p5 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
    #                                                     list_of_pooled_subcells=[0, 1, 4],
    #                                                    list_of_non_pooled_subcells=[2],
    #                                                     exclude_samples_for_analysis=1000,
    #                                                     expected_total_prbs=expected_total_prbs,
    #                                                     expected_compliance_percentage=95,
    #                                                     name='ul_dataframe_for_manual_analysis_spool1')
    # logging.info("is_TTITrace_correct_p5 = %s" % (is_TTITrace_correct_p5))
    # expected_total_prbs = 102  # <-- small Subpool2
    # is_TTITrace_correct_p6 = check_total_pooled_ul_prbs(path_to_ttitrace_pkl,
    #                                                     list_of_pooled_subcells=[2],
    #                                                     list_of_non_pooled_subcells=[0, 1, 4],
    #                                                     exclude_samples_for_analysis=1000,
    #                                                     expected_total_prbs=expected_total_prbs,
    #                                                     expected_compliance_percentage=95,
    #                                                     name='ul_dataframe_for_manual_analysis_spool2')
    # logging.info("is_TTITrace_correct_p6 = %s" % (is_TTITrace_correct_p6))
    is_TTITrace_correct_p7 = check_total_stream_prbs(path_to_ttitrace_pkl,
                                                     list_of_pooled_subcells=[2],
                                                     list_of_non_pooled_subcells=[0, 1, 4],
                                                     exclude_samples_for_analysis=1000,
                                                     expected_total_prbs=expected_total_prbs,
                                                     expected_compliance_percentage=95,
                                                     name='dl_dataframe_for_manual_analysis_all_subcells')
    logging.info("is_TTITrace_correct_p7 = %s" % (is_TTITrace_correct_p7))
    expected_total_prbsstream = 2100  # <-- Subpool1
    is_TTITrace_correct_p3, averaged_total_prbstream_pooled_spool1 = \
        check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                          list_of_pooled_subcells=[0, 3, 7, 8],
                                          list_of_non_pooled_subcells=[1, 6, 4, 5, 2, 9, 10, 11],
                                          exclude_samples_for_analysis=1000,
                                          expected_total_prbsstream=expected_total_prbsstream,
                                          expected_compliance_percentage=95,
                                          name='dl_dataframe_for_manual_analysis_spool1')
    logging.info("is_TTITrace_correct_p3 = %s" % (is_TTITrace_correct_p3))
    logging.info("averaged_total_prbstream_spool1 = %s" % (averaged_total_prbstream_pooled_spool1))
    datedConsole(getHeaderLine('averaged_total_prbstream_spool1', averaged_total_prbstream_pooled_spool1))
    expected_total_prbsstream = 240  # <-- Subpool1
    is_TTITrace_correct_p4, averaged_total_prbstream_pooled_spool2 = \
        check_total_pooled_prbsstreamcapa(path_to_ttitrace_pkl,
                                          list_of_pooled_subcells=[1, 6, 4, 5, 2, 9, 10, 11],
                                          list_of_non_pooled_subcells=[0, 3, 7, 8],
                                          exclude_samples_for_analysis=1000,
                                          expected_total_prbsstream=expected_total_prbsstream,
                                          expected_compliance_percentage=95,
                                          name='dl_dataframe_for_manual_analysis_spool2')
    logging.info("is_TTITrace_correct_p4 = %s" % (is_TTITrace_correct_p4))
    logging.info("averaged_total_prbstream_spool2 = %s" % (averaged_total_prbstream_pooled_spool2))
    datedConsole(getHeaderLine('averaged_total_prbstream_spool2', averaged_total_prbstream_pooled_spool2))
    resultTest = False
    sum = averaged_total_prbstream_pooled_spool1 + averaged_total_prbstream_pooled_spool2
    if (sum >= 2370 and sum <= 2420):
        resultTest = True
    else:
        resultTest = False
    is_TTITrace_correct_p5 = \
        run_mumimo_load_based_prb_pooling_analysis_dl(path_to_ttitrace_pkl,
                                                      list_of_pooled_subcells=[0, 3, 7, 8],
                                                      list_of_non_pooled_subcells=[1, 6, 4, 5, 2, 9, 10, 11],
                                                      exclude_samples_for_analysis=1000,
                                                      expected_total_prbs=expected_total_prbs,
                                                      expected_compliance_percentage=95,
                                                      name='dl_dataframe_for_manual_analysis_mumimo_spool1')
    logging.info("is_TTITrace_correct_p5 = %s" % (is_TTITrace_correct_p5))
    is_TTITrace_correct_p6 = \
        run_mumimo_load_based_prb_pooling_analysis_dl(path_to_ttitrace_pkl,
                                                      list_of_pooled_subcells=[1, 6, 4, 5, 2, 9, 10, 11],
                                                      list_of_non_pooled_subcells=[0, 3, 7, 8],
                                                      exclude_samples_for_analysis=1000,
                                                      expected_total_prbs=expected_total_prbs,
                                                      expected_compliance_percentage=95,
                                                      name='dl_dataframe_for_manual_analysis_mumimo_spool2')
    logging.info("is_TTITrace_correct_p6 = %s" % (is_TTITrace_correct_p6))
    logging.info("averaged_total_prbstream resultTest = %s" % (resultTest))

    combined_mumimo_stats, mumimo_stats = get_mumimo_statistics_physCellId_dl(path_to_ttitrace_pkl)
    logging.info("combined_mumimo_stats = %s" % (combined_mumimo_stats))
    logging.info("mumimo_stats = %s" % (mumimo_stats))
