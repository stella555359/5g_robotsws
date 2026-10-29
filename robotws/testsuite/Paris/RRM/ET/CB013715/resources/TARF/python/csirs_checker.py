# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Christophe SAMSON
:contact: christophe.samson@nokia.com
:maintainer:
:contact:
"""

import os
import re
import logging
import math
import json
import traceback
from taf.ul.ettf.logger import custom_logger, log

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn


logger = custom_logger(name='csirs_checker', filename='test_execution_csirs_checker.log', disable_html_logging=True)


@log('createCellCsiRs_9836...', 'createCellCsiRs_9836 finished', logger)
def createCellCsiRs_9836(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                         csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups, cellList,
                         actTddCsirsAllocOptimization, actInfTddFrameMuting=False):
    if type(actCsiMux) is bool:
        _actCsiMux = actCsiMux
    else:
        if actCsiMux == 'True':
            _actCsiMux = True
        else:
            _actCsiMux = False
    if type(actExplicitCsirsPoolSolution) is bool:
        _actExplicitCsirsPoolSolution = actExplicitCsirsPoolSolution
    else:
        if actExplicitCsirsPoolSolution == 'True':
            _actExplicitCsirsPoolSolution = True
        else:
            _actExplicitCsirsPoolSolution = False
    if type(actInfTddFrameMuting) is bool:
        _actInfTddFrameMuting = actInfTddFrameMuting
    else:
        if actInfTddFrameMuting == 'True':
            _actInfTddFrameMuting = True
        else:
            _actInfTddFrameMuting = False
    if type(actTddCsirsAllocOptimization) is bool:
        _actTddCsirsAllocOptimization = actTddCsirsAllocOptimization
    else:
        if actTddCsirsAllocOptimization == 'True':
            _actTddCsirsAllocOptimization = True
        else:
            _actTddCsirsAllocOptimization = False

    csiRsConfig = []
    csiRsPeriodicity = []

    maxCsiRsPoolGroups = 3

    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # _actTddCsirsAllocOptimization means CB009836
    if _actTddCsirsAllocOptimization is True:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001116_3_Canada': {'i': 20, 'j': 30},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001116_3_Canada': {'i': 20, 'j': 22},
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
    print('trsSlot: {}'.format(trsSlot))

    logger.info("actCsiMux: %s" % actCsiMux)
    logger.info("actExplicitCsirsPoolSolution: %s" % actCsiMux)
    logger.info("csiRsPeriod NIDD: %s" % csiRsPeriod)
    logger.info("csirsNbWithinReportPeriod_Set1: %s" % csirsNbWithinReportPeriod_Set1)
    logger.info("maxCsiRsPerCsiRsPool: %s" % maxCsiRsPerCsiRsPool)
    logger.info("cellList: %s" % cellList)
    logger.info("actTddCsirsAllocOptimization: %s" % actTddCsirsAllocOptimization)
    logger.info("actInfTddFrameMuting: %s" % actInfTddFrameMuting)
    logger.info("trsSlot: %s" % trsSlot)

    # Calcul du CSI-RS resource periodicity
    # 5G_CP_ARC_ALG_2571 and 5G_CP_ARC_ALG_4854
    for i in range(len(csiRsPeriod)):
        csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod[i]).group())
        if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)) > 40:
            csiRsPeriodicity.append(int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)))
        else:
            csiRsPeriodicity.append(40)

    print('\nCalculated csiRsPeriodicity: {}'.format(csiRsPeriodicity))
    logger.info("Calculated csiRsPeriodicity: %s" % csiRsPeriodicity)

    csiRsInfo = {}
    for item in csiRsGroups:
        logger.info("[init csiRsInfo]: csiRsGroups_i = %s" % item)
        logger.info("[init csiRsInfo] item lcrId = %s" % item['lcrId'])
        # manage only 3 Cells!!!
        # if int(item['lcrId']) > 3:
        #      continue
        logger.info("[init csiRsInfo] use csiRsGroups_i = %s" % item)
        index = cellList.index(str(item['lcrId']))
        # index = cellList.index(item['lcrId'])
        csiRsInfo[item['csirsPoolingGroupId']] = {"lcrId": item['lcrId'],
                                                  "csiRsReportPeriod": csiRsPeriodicity[index],
                                                  "maxCsiRs": maxCsiRsPerCsiRsPool[index]}
        text = "[init csiRsInfo] %s added in csiRsInfo for csirsPoolingGroupId = %s"
        logger.info(text % (csiRsInfo[item['csirsPoolingGroupId']], item['csirsPoolingGroupId']))

    print('\ncsiRsInfo: {}'.format(csiRsInfo))
    logger.info("csiRsInfo: %s" % csiRsInfo)

    # CB008940
    # actExplicitCsirsPoolSolution is CB010544
    if _actExplicitCsirsPoolSolution is False and _actTddCsirsAllocOptimization is False:
        print("CB008940 Cell Specific CSI-RS Config")
        logger.info("CB008940 Cell Specific CSI-RS Config")
        if _actInfTddFrameMuting is True:
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 2
            rs4startSymb3 = 6
            rs4startSymb4 = 6
        elif _actCsiMux is False:
            rs1startSymb1 = 12
            rs2startSymb1 = 2
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 6
            rs4startSymb3 = 10
            rs4startSymb4 = 12
        elif _actCsiMux is True:
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 10
            rs4startSymb2 = 10
            rs4startSymb3 = 12
            rs4startSymb4 = 12
        else:
            exit(-1)
        # 5G_UP_ALG_11582
        for csiRsPoolGrpId in range(3):
            rs1 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + csiRsPoolGrpId * 40,
                    'startingSymbolIndex': rs1startSymb1}]
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                    (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                           (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] + (
                    (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

    # CB010513
    elif _actExplicitCsirsPoolSolution is True and _actTddCsirsAllocOptimization is False:
        print("CB010513 Cell Specific CSI-RS Config")
        logger.info("CB010513 Cell Specific CSI-RS Config")
        # StartSymbol par reseource set pour chaque csiRsPoolingGrp
        rs1startSymb1 = [10, 10, 12]
        rs2startSymb1 = [12, 12, 10]
        rs4startSymb1 = [2, 2, 2]
        rs4startSymb2 = [6, 6, 6]

        # 5G_UP_ALG_19019
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
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs2,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs4,
                                                      'csiImResSlotOffset': None}]})

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
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs2,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs4,
                                                      'csiImResSlotOffset': None}]})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                    csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                        csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                        (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                        (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs2,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs4,
                                                      'csiImResSlotOffset': None}]})

            else:
                print("csiRsPeriod NOT SUPPORTED")
                logger.info("csiRsPeriod NOT SUPPORTED")
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
            csiRsConfig.append({'csirsPoolingGroupId': 2,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

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
            csiRsConfig.append({'csirsPoolingGroupId': 2,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

        elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                    (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                    csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                           csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                    (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

        else:
            print("csiRsPeriod NOT SUPPORTED")
            logger.info("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    # CB009836
    # 5G_UP_ALG_25402
    # https://gates.nsn-net.net/view/0002753b#o=557&hlt
    elif _actTddCsirsAllocOptimization is True:
        print("CB009836 Cell Specific CSI-RS Config")
        logger.info("CB009836 Cell Specific CSI-RS Config")
        # CsiRsPoolingGroupId = 0, 1
        for csiRsPoolGrpId in range(2):
            logger.info("csiRsPoolGrpId=%s", csiRsPoolGrpId)
            if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
                logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                    'csiImResSlotOffset': None})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
                logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
                rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                    'csiImResSlotOffset': None})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                    csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
                logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
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
                        {'csirsPoolingGroupId': csiRsPoolGrpId,
                         'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                         'csiImResSlotOffset': None})

            else:
                print("csiRsPeriod NOT SUPPORTED")
                logger.info("csiRsPeriod NOT SUPPORTED")
                csiRsConfig = None

        # CsiRsPoolingGroupId = 2
        csiRsPoolGrpId = 2
        logger.info("csiRsPoolGrpId=%s", csiRsPoolGrpId)
        if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
            logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
            rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
            rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
            rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                'csiImResSlotOffset': None})

        elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
            logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
            rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
            rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
            rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                   {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                'csiImResSlotOffset': None})

        elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
            logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
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
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                    'csiImResSlotOffset': None})

        else:
            print("csiRsPeriod NOT SUPPORTED")
            logger.info("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    else:
        print("Activation flag NOT SUPPORTED")
        logger.info("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    for csiRsId in range(maxCsiRsPoolGroups):
        logger.info("csiRsId = %s" % csiRsId)
        logger.info("maxCsiRs = %s in csiRsInfo for csiRsId=%s " % (csiRsInfo[csiRsId]['maxCsiRs'], csiRsId))
        if int(csiRsInfo[csiRsId]['maxCsiRs']) == 1:
            logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsId]['resource_set'][:])
            del csiRsConfig[csiRsId]['resource_set'][1:]
            logger.info("keep only one resource")
            logger.info("csiRsConfig = %s" % csiRsConfig)
        if int(csiRsInfo[csiRsId]['maxCsiRs']) == 2:
            logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsId]['resource_set'][:])
            del csiRsConfig[csiRsId]['resource_set'][2:]
            logger.info("keep only two resources")
            logger.info("csiRsConfig = %s" % csiRsConfig)

    print(csiRsConfig)
    logging.info("csiRsConfig_output = %s" % csiRsConfig)
    logger.info("csiRsConfig_output = %s" % csiRsConfig)

    file = 'expected_cellcsirs_checker_manual_analysis'
    testCaseDir = BuiltIn().get_variable_value('${testCaseDir}')
    filename = testCaseDir + '/' + file + '.json'
    with open(filename, 'w') as f:
        json.dump(csiRsConfig, f, indent=4)
    return csiRsConfig


@log('createCellCsiRs_9836...', 'createCellCsiRs_9836 finished', logger)
def createCellCsiRs_9836_v2(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                            csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups, cellList,
                            actTddCsirsAllocOptimization, actInfTddFrameMuting=False):
    if type(actCsiMux) is bool:
        _actCsiMux = actCsiMux
    else:
        if actCsiMux == 'True':
            _actCsiMux = True
        else:
            _actCsiMux = False
    if type(actExplicitCsirsPoolSolution) is bool:
        _actExplicitCsirsPoolSolution = actExplicitCsirsPoolSolution
    else:
        if actExplicitCsirsPoolSolution == 'True':
            _actExplicitCsirsPoolSolution = True
        else:
            _actExplicitCsirsPoolSolution = False
    if type(actInfTddFrameMuting) is bool:
        _actInfTddFrameMuting = actInfTddFrameMuting
    else:
        if actInfTddFrameMuting == 'True':
            _actInfTddFrameMuting = True
        else:
            _actInfTddFrameMuting = False
    if type(actTddCsirsAllocOptimization) is bool:
        _actTddCsirsAllocOptimization = actTddCsirsAllocOptimization
    else:
        if actTddCsirsAllocOptimization == 'True':
            _actTddCsirsAllocOptimization = True
        else:
            _actTddCsirsAllocOptimization = False

    csiRsConfig = []
    csiRsPeriodicity = []

    maxCsiRsPoolGroups = 3

    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # _actTddCsirsAllocOptimization means CB009836
    if _actTddCsirsAllocOptimization is True:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001116_3_Canada': {'i': 20, 'j': 30},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001116_3_Canada': {'i': 20, 'j': 22},
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
    print('trsSlot: {}'.format(trsSlot))

    logger.info("actCsiMux: %s" % actCsiMux)
    logger.info("actExplicitCsirsPoolSolution: %s" % actCsiMux)
    logger.info("csiRsPeriod NIDD: %s" % csiRsPeriod)
    logger.info("csirsNbWithinReportPeriod_Set1: %s" % csirsNbWithinReportPeriod_Set1)
    logger.info("maxCsiRsPerCsiRsPool: %s" % maxCsiRsPerCsiRsPool)
    logger.info("cellList: %s" % cellList)
    logger.info("actTddCsirsAllocOptimization: %s" % actTddCsirsAllocOptimization)
    logger.info("actInfTddFrameMuting: %s" % actInfTddFrameMuting)
    logger.info("trsSlot: %s" % trsSlot)

    # Calcul du CSI-RS resource periodicity
    # 5G_CP_ARC_ALG_2571, 5G_CP_ARC_ALG_2572
    for i in range(len(csiRsPeriod)):
        csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod[i]).group())
        if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)) > 40:
            csiRsPeriodicity.append(int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)))
        else:
            csiRsPeriodicity.append(40)

    print('\nCalculated csiRsPeriodicity: {}'.format(csiRsPeriodicity))
    logger.info("Calculated csiRsPeriodicity: %s" % csiRsPeriodicity)

    csiRsInfo = {}
    for item in csiRsGroups:
        logger.info("[init csiRsInfo]: csiRsGroups_i = %s" % item)
        logger.info("[init csiRsInfo] item lcrId = %s" % item['lcrId'])
        # manage only 3 Cells!!!
        # if int(item['lcrId']) > 3:
        #      continue
        logger.info("[init csiRsInfo] use csiRsGroups_i = %s" % item)
        index = cellList.index(str(item['lcrId']))
        # index = cellList.index(item['lcrId'])
        csiRsInfo[item['csirsPoolingGroupId']] = {"lcrId": item['lcrId'],
                                                  "csiRsReportPeriod": csiRsPeriodicity[index],
                                                  "maxCsiRs": maxCsiRsPerCsiRsPool[index]}
        text = "[init csiRsInfo] %s added in csiRsInfo for csirsPoolingGroupId = %s with calculated csiRsPeriodicity"
        logger.info(text % (csiRsInfo[item['csirsPoolingGroupId']], item['csirsPoolingGroupId']))

    print('\ncsiRsInfo: {}'.format(csiRsInfo))
    logger.info("csiRsInfo: %s" % csiRsInfo)

    # CB008940
    # actExplicitCsirsPoolSolution is CB010544
    if _actExplicitCsirsPoolSolution is False and _actTddCsirsAllocOptimization is False:
        print("CB008940 Cell Specific CSI-RS Config")
        logger.info("CB008940 Cell Specific CSI-RS Config")
        if _actInfTddFrameMuting is True:
            rs1startSymb1 = 12
            rs2startSymb1 = 12
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 2
            rs4startSymb3 = 6
            rs4startSymb4 = 6
        elif _actCsiMux is False:
            rs1startSymb1 = 12
            rs2startSymb1 = 2
            rs2startSymb2 = 12
            rs4startSymb1 = 2
            rs4startSymb2 = 6
            rs4startSymb3 = 10
            rs4startSymb4 = 12
        elif _actCsiMux is True:
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
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                    (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                           (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] + (
                    (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

    # CB010513
    elif _actExplicitCsirsPoolSolution is True and _actTddCsirsAllocOptimization is False:
        print("CB010513 Cell Specific CSI-RS Config")
        logger.info("CB010513 Cell Specific CSI-RS Config")
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
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs2,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs4,
                                                      'csiImResSlotOffset': None}]})

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
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs2,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs4,
                                                      'csiImResSlotOffset': None}]})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                    csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
                rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                        csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                        (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                        (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                       {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                        'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs2,
                                                      'csiImResSlotOffset': None},
                                                     {'res': rs4,
                                                      'csiImResSlotOffset': None}]})

            else:
                print("csiRsPeriod NOT SUPPORTED")
                logger.info("csiRsPeriod NOT SUPPORTED")
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
            csiRsConfig.append({'csirsPoolingGroupId': 2,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

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
            csiRsConfig.append({'csirsPoolingGroupId': 2,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

        elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
            rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                    (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
            rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                    csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                           csiRsPoolGrpId % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
            rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                    (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                   {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                           (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
            csiRsConfig.append({'csirsPoolingGroupId': 2,
                                'resource_set': [{'res': rs1,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs2,
                                                  'csiImResSlotOffset': None},
                                                 {'res': rs4,
                                                  'csiImResSlotOffset': None}]})

        else:
            print("csiRsPeriod NOT SUPPORTED")
            logger.info("csiRsPeriod NOT SUPPORTED")
            csiRsConfig = None

    # CB009836
    elif _actTddCsirsAllocOptimization is True:
        print("CB009836 Cell Specific CSI-RS Config")
        logger.info("CB009836 Cell Specific CSI-RS Config")
        # CsiRsPoolingGroupId = 0, 1, 3
        for csiRsPoolGrpId in range(3):
            logger.info("csiRsPoolGrpId=%s", csiRsPoolGrpId)
            if csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 40:
                logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
                rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                    'csiImResSlotOffset': None})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 80:
                logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
                rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                       {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                csiRsConfig.append({'csirsPoolingGroupId': csiRsPoolGrpId,
                                    'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                                    'csiImResSlotOffset': None})

            elif csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 160 or\
                    csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'] == 320:
                logger.info("csiRsReportPeriod=%s", csiRsInfo[csiRsPoolGrpId]['csiRsReportPeriod'])
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
                        {'csirsPoolingGroupId': csiRsPoolGrpId,
                         'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}],
                         'csiImResSlotOffset': None})
            else:
                print("csiRsPeriod NOT SUPPORTED")
                logger.info("csiRsPeriod NOT SUPPORTED")
                csiRsConfig = None

    else:
        print("Activation flag NOT SUPPORTED")
        logger.info("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    for csiRsId in range(maxCsiRsPoolGroups):
        logger.info("csiRsId = %s" % csiRsId)
        logger.info("maxCsiRs = %s in csiRsInfo for csiRsId=%s " % (csiRsInfo[csiRsId]['maxCsiRs'], csiRsId))
        if int(csiRsInfo[csiRsId]['maxCsiRs']) == 1:
            logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsId]['resource_set'][:])
            del csiRsConfig[csiRsId]['resource_set'][1:]
            logger.info("keep only one resource")
            logger.info("csiRsConfig = %s" % csiRsConfig)
        if int(csiRsInfo[csiRsId]['maxCsiRs']) == 2:
            logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsId]['resource_set'][:])
            del csiRsConfig[csiRsId]['resource_set'][2:]
            logger.info("keep only two resources")
            logger.info("csiRsConfig = %s" % csiRsConfig)

    print(csiRsConfig)
    logging.info("csiRsConfig_output = %s" % csiRsConfig)
    logger.info("csiRsConfig_output = %s" % csiRsConfig)

    file = 'expected_cellcsirs_checker_manual_analysis'
    testCaseDir = BuiltIn().get_variable_value('${testCaseDir}')
    filename = testCaseDir + '/' + file + '.json'
    with open(filename, 'w') as f:
        json.dump(csiRsConfig, f, indent=4)

    return csiRsConfig


@log('createCellCsiRs_9836_v3...', 'createCellCsiRs_9836_v3 finished', logger)
def createCellCsiRs_9836_v3(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                            csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups, cellList,
                            actTddCsirsAllocOptimization, actInfTddFrameMuting="false"):
    if type(actCsiMux) is bool:
        _actCsiMux = actCsiMux
    else:
        if actCsiMux == 'True':
            _actCsiMux = True
        else:
            _actCsiMux = False
    if type(actExplicitCsirsPoolSolution) is bool:
        _actExplicitCsirsPoolSolution = actExplicitCsirsPoolSolution
    else:
        if actExplicitCsirsPoolSolution == 'True':
            _actExplicitCsirsPoolSolution = True
        else:
            _actExplicitCsirsPoolSolution = False
    if type(actInfTddFrameMuting) is bool:
        _actInfTddFrameMuting = actInfTddFrameMuting
    else:
        if actInfTddFrameMuting == 'True':
            _actInfTddFrameMuting = True
        else:
            _actInfTddFrameMuting = False
    if type(actTddCsirsAllocOptimization) is bool:
        _actTddCsirsAllocOptimization = actTddCsirsAllocOptimization
    else:
        if actTddCsirsAllocOptimization == 'True':
            _actTddCsirsAllocOptimization = True
        else:
            _actTddCsirsAllocOptimization = False

    csiRsConfig = []
    csiRsPeriodicity = []

    maxCsiRsPoolGroups = 3

    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # _actTddCsirsAllocOptimization means CB009836
    if _actTddCsirsAllocOptimization is True:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001116_3_Canada': {'i': 20, 'j': 30},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001116_3_Canada': {'i': 20, 'j': 22},
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
    print('trsSlot: {}'.format(trsSlot))

    logger.info("actCsiMux: %s" % actCsiMux)
    logger.info("actExplicitCsirsPoolSolution: %s" % actCsiMux)
    logger.info("csiRsPeriod NIDD: %s" % csiRsPeriod)
    logger.info("csirsNbWithinReportPeriod_Set1: %s" % csirsNbWithinReportPeriod_Set1)
    logger.info("maxCsiRsPerCsiRsPool: %s" % maxCsiRsPerCsiRsPool)
    logger.info("cellList: %s" % cellList)
    logger.info("actTddCsirsAllocOptimization: %s" % actTddCsirsAllocOptimization)
    logger.info("actInfTddFrameMuting: %s" % actInfTddFrameMuting)
    logger.info("trsSlot: %s" % trsSlot)

    # 5G_CP_ARC_ALG_2571 and 5G_CP_ARC_ALG_4854
    # Calcul du CSI-RS resource periodicity
    for i in range(len(csiRsPeriod)):
        csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod[i]).group())
        if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)) > 40:
            csiRsPeriodicity.append(int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)))
        else:
            csiRsPeriodicity.append(40)

    print('\nCalculated csiRsPeriodicity: {}\n'.format(csiRsPeriodicity))
    logger.info("Calculated csiRsPeriodicity: %s" % csiRsPeriodicity)

    cellCsiRsInfo = {}
    for item in csiRsGroups:
        logger.info("[init cellCsiRsInfo]: csiRsGroups_i = %s" % item)
        logger.info("[init cellCsiRsInfo] item lcrId = %s" % item['lcrId'])
        index = cellList.index(str(item['lcrId']))
        # index = cellList.index(item['lcrId'])
        cellCsiRsInfo[item['cell']] = {"lcrId": item['lcrId'],
                                       "csiRsReportPeriod": csiRsPeriodicity[index],
                                       "maxCsiRs": maxCsiRsPerCsiRsPool[index],
                                       "csiRsPoolGrpId": item['csirsPoolingGroupId']}
        print('{} {}'.format(item['cell'], cellCsiRsInfo[item['cell']]))
        logger.info("cell=%s cellCsiRsInfo=%s" % (item['cell'], cellCsiRsInfo[item['cell']]))
        text = "[init csiRsInfo] %s added in csiRsInfo for csirsPoolingGroupId = %s"
        logger.info(text % (cellCsiRsInfo[item['cell']], item['csirsPoolingGroupId']))

    # print('\ncellCsiRsInfo: {}'.format(cellCsiRsInfo))
    logger.info("cellCsiRsInfo: %s" % cellCsiRsInfo)

    # CB008940
    # actExplicitCsirsPoolSolution is CB010544
    if _actExplicitCsirsPoolSolution is False and _actTddCsirsAllocOptimization is False:
        print("CB008940 Cell Specific CSI-RS Config")
        logger.info("CB008940 Cell Specific CSI-RS Config")
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
        # 5G_UP_ALG_11582
        for cell in cellCsiRsInfo.keys():
            csiRsPoolGrpId = cellCsiRsInfo[cell]['csiRsPoolGrpId']
            rs1 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + csiRsPoolGrpId * 40,
                    'startingSymbolIndex': rs1startSymb1}]
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                    (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                           (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] + (
                    (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'cellId': cell,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

    # CB010513
    elif _actExplicitCsirsPoolSolution is True and _actTddCsirsAllocOptimization is False:
        print("CB010513 Cell Specific CSI-RS Config")
        logger.info("CB010513 Cell Specific CSI-RS Config")
        # StartSymbol par reseource set pour chaque csiRsPoolingGrp
        rs1startSymb1 = [10, 10, 12]
        rs2startSymb1 = [12, 12, 10]
        rs4startSymb1 = [2, 2, 2]
        rs4startSymb2 = [6, 6, 6]

        # 5G_UP_ALG_19019
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

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or \
                        cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40),
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    logger.info("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

            else:
                # CsiRsPoolingGroupId = 2
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

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or \
                        cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40),
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                                   (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40),
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    logger.info("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

    # CB009836
    # 5G_UP_ALG_25402
    # https://gates.nsn-net.net/view/0002753b#o=557&hlt
    elif _actTddCsirsAllocOptimization is True:
        print("CB009836 Cell Specific CSI-RS Config")
        logger.info("CB009836 Cell Specific CSI-RS Config")
        for cell in cellCsiRsInfo.keys():
            csiRsPoolGrpId = cellCsiRsInfo[cell]['csiRsPoolGrpId']
            logger.info("csiRsPoolGrpId=%s", csiRsPoolGrpId)
            if csiRsPoolGrpId == 0 or csiRsPoolGrpId == 1:
                if cellCsiRsInfo[cell]['csiRsReportPeriod'] == 40:
                    rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})
                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 80:
                    rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                    rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or \
                        cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                            (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                                   (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                                   (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                                   (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 12}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    logger.info("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

            else:
                # CsiRsPoolingGroupId = 2
                logger.info("csiRsPoolGrpId=%s", csiRsPoolGrpId)
                if cellCsiRsInfo[cell]['csiRsReportPeriod'] == 40:
                    rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 80:
                    rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
                    rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or \
                        cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[0] + csiRsPoolGrpId * 40, 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                            (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                                   (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                                   (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + (
                                   (csiRsPoolGrpId + 1) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': 12}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    logger.info("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

    else:
        print("Activation flag NOT SUPPORTED")
        logger.info("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    for data in csiRsConfig:
        logger.info("data = %s" % data)
        logger.info("maxCsiRs = %s in csiRsInfo for data=%s " % (cellCsiRsInfo[data['cellId']]['maxCsiRs'], data))
        if int(cellCsiRsInfo[data['cellId']]['maxCsiRs']) == 1:
            logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsConfig.index(data)]['resource_set'][:])
            del csiRsConfig[csiRsConfig.index(data)]['resource_set'][1:]
            logger.info("keep only one resource")
            logger.info("csiRsConfig = %s" % csiRsConfig)
        if int(cellCsiRsInfo[data['cellId']]['maxCsiRs']) == 2:
            logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsConfig.index(data)]['resource_set'][:])
            del csiRsConfig[csiRsConfig.index(data)]['resource_set'][2:]
            logger.info("keep only one resource")
            logger.info("csiRsConfig = %s" % csiRsConfig)

    print(csiRsConfig)
    logging.info("csiRsConfig_output = %s" % csiRsConfig)
    logger.info("csiRsConfig_output = %s" % csiRsConfig)

    file = 'expected_cellcsirs_checker_manual_analysis'
    testCaseDir = BuiltIn().get_variable_value('${testCaseDir}')
    filename = testCaseDir + '/' + file + '.json'
    with open(filename, 'w') as f:
        json.dump(csiRsConfig, f, indent=4)

    return csiRsConfig


@log('createCellCsiRs_9836_v3_1...', 'createCellCsiRs_9836_v3_1 finished', logger)
def createCellCsiRs_9836_v3_1(result_file, framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                              csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups, cellList,
                              actTddCsirsAllocOptimization, actInfTddFrameMuting="false"):
    if type(actCsiMux) is bool:
        _actCsiMux = actCsiMux
    else:
        if actCsiMux == 'True':
            _actCsiMux = True
        else:
            _actCsiMux = False
    if type(actExplicitCsirsPoolSolution) is bool:
        _actExplicitCsirsPoolSolution = actExplicitCsirsPoolSolution
    else:
        if actExplicitCsirsPoolSolution == 'True' or actExplicitCsirsPoolSolution == 'true':
            _actExplicitCsirsPoolSolution = True
        else:
            _actExplicitCsirsPoolSolution = False
    if type(actInfTddFrameMuting) is bool:
        _actInfTddFrameMuting = actInfTddFrameMuting
    else:
        if actInfTddFrameMuting == 'True' or actInfTddFrameMuting == 'true':
            _actInfTddFrameMuting = True
        else:
            _actInfTddFrameMuting = False
    if type(actTddCsirsAllocOptimization) is bool:
        _actTddCsirsAllocOptimization = actTddCsirsAllocOptimization
    else:
        if actTddCsirsAllocOptimization == 'True' or actTddCsirsAllocOptimization == 'true':
            _actTddCsirsAllocOptimization = True
        else:
            _actTddCsirsAllocOptimization = False

    csiRsConfig = []
    csiRsPeriodicity = []

    maxCsiRsPoolGroups = 3

    result_file_fd = open(result_file, 'a')

    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # _actTddCsirsAllocOptimization means CB009836
    if _actTddCsirsAllocOptimization is True:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 36},
                         '5GC001116_3_Canada': {'i': 20, 'j': 30},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}
    else:
        trsSlotOffset = {'5GC001116_3': {'i': 20, 'j': 15},
                         '5GC001116_0': {'i': 20, 'j': 18},
                         '5GC001116_3_Canada': {'i': 20, 'j': 22},
                         '5GC001208': {'i': 20, 'j': 16},
                         '5GC001070': {'i': 20, 'j': 15}}

    trsSlot = [trsSlotOffset[framestructure]['i'], trsSlotOffset[framestructure]['i'] + 1,
               trsSlotOffset[framestructure]['j'], trsSlotOffset[framestructure]['j'] + 1]

    print('actCsiMux: {}'.format(actCsiMux))
    print('actExplicitCsirsPoolSolution(CB010513): {}'.format(actExplicitCsirsPoolSolution))
    print('_actExplicitCsirsPoolSolution: {}'.format(_actExplicitCsirsPoolSolution))
    print('csiRsPeriod NIDD: {}'.format(csiRsPeriod))
    print('csirsNbWithinReportPeriod_Set1: {}'.format(csirsNbWithinReportPeriod_Set1))
    print('maxCsiRsPerCsiRsPool: {}'.format(maxCsiRsPerCsiRsPool))
    print('csiRsGroups: {}'.format(csiRsGroups))
    print('cellList: {}'.format(cellList))
    print('actTddCsirsAllocOptimization(CB009836): {}'.format(actTddCsirsAllocOptimization))
    print('actInfTddFrameMuting: {}'.format(actInfTddFrameMuting))
    print('trsSlot: {}'.format(trsSlot))

    logger.info("actCsiMux: %s" % actCsiMux)
    logger.info("actExplicitCsirsPoolSolution(CB010513): %s" % actExplicitCsirsPoolSolution)
    logger.info("_actExplicitCsirsPoolSolution: %s" % _actExplicitCsirsPoolSolution)
    logger.info("csiRsPeriod NIDD: %s" % csiRsPeriod)
    logger.info("csirsNbWithinReportPeriod_Set1: %s" % csirsNbWithinReportPeriod_Set1)
    logger.info("maxCsiRsPerCsiRsPool: %s" % maxCsiRsPerCsiRsPool)
    logger.info("cellList: %s" % cellList)
    logger.info("actTddCsirsAllocOptimization(CB009836): %s" % actTddCsirsAllocOptimization)
    logger.info("actInfTddFrameMuting: %s" % actInfTddFrameMuting)
    logger.info("trsSlot: %s" % trsSlot)

    # 5G_CP_ARC_ALG_2571 and 5G_CP_ARC_ALG_4854
    # Calcul du CSI-RS resource periodicity
    for i in range(len(csiRsPeriod)):
        csiRsPeriodValue = int(re.search(r"\d+", csiRsPeriod[i]).group())
        if (csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)) > 40:
            csiRsPeriodicity.append(int(csiRsPeriodValue / math.pow(2, int(csirsNbWithinReportPeriod_Set1[i]) - 1)))
        else:
            csiRsPeriodicity.append(40)

    print('\nCalculated csiRsPeriodicity: {}\n'.format(csiRsPeriodicity))
    logger.info("Calculated csiRsPeriodicity: %s" % csiRsPeriodicity)
    result_file_fd.write('\n\tCalculated csiRsPeriodicity: {}\n'.format(csiRsPeriodicity))

    cellCsiRsInfo = {}
    for item in csiRsGroups:
        logger.info("[init cellCsiRsInfo]: csiRsGroups_i = %s" % item)
        logger.info("[init cellCsiRsInfo] item lcrId = %s" % item['lcrId'])
        index = cellList.index(str(item['lcrId']))
        # index = cellList.index(item['lcrId'])
        cellCsiRsInfo[item['cell']] = {"lcrId": item['lcrId'],
                                       "csiRsReportPeriod": csiRsPeriodicity[index],
                                       "maxCsiRs": maxCsiRsPerCsiRsPool[index],
                                       "csiRsPoolGrpId": item['csirsPoolingGroupId']}
        print('{} {}'.format(item['cell'], cellCsiRsInfo[item['cell']]))
        logger.info("cell=%s cellCsiRsInfo=%s" % (item['cell'], cellCsiRsInfo[item['cell']]))
        text = "[init csiRsInfo] %s added in csiRsInfo for csirsPoolingGroupId = %s"
        logger.info(text % (cellCsiRsInfo[item['cell']], item['csirsPoolingGroupId']))

    # print('\ncellCsiRsInfo: {}'.format(cellCsiRsInfo))
    logger.info("cellCsiRsInfo: %s" % cellCsiRsInfo)

    # CB008940
    # actExplicitCsirsPoolSolution is CB010544
    if _actExplicitCsirsPoolSolution is False and _actTddCsirsAllocOptimization is False:
        print("CB008940 Cell Specific CSI-RS Config")
        logger.info("CB008940 Cell Specific CSI-RS Config")
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
        # 5G_UP_ALG_11582
        for cell in cellCsiRsInfo.keys():
            csiRsPoolGrpId = cellCsiRsInfo[cell]['csiRsPoolGrpId']
            rs1 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + csiRsPoolGrpId * 40,
                    'startingSymbolIndex': rs1startSymb1}]
            rs2 = [{'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                    (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['i'] + 1 + (
                           (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs2startSymb2}]
            rs4 = [{'slotOffset': trsSlotOffset[framestructure]['j'] + (
                    (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb1},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb2},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb3},
                   {'slotOffset': trsSlotOffset[framestructure]['j'] + (
                               (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                    'startingSymbolIndex': rs4startSymb4}]
            csiRsConfig.append({'cellId': cell,
                                'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

    # CB010513
    elif _actExplicitCsirsPoolSolution is True and _actTddCsirsAllocOptimization is False:
        print("CB010513 Cell Specific CSI-RS Config")
        logger.info("CB010513 Cell Specific CSI-RS Config")
        # StartSymbol par reseource set pour chaque csiRsPoolingGrp
        rs1startSymb1 = [10, 10, 12]
        rs2startSymb1 = [12, 12, 10]
        rs4startSymb1 = [2, 2, 2]
        rs4startSymb2 = [6, 6, 6]

        # 5G_UP_ALG_19019
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

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or \
                        cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40),
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    logger.info("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

            else:
                # CsiRsPoolingGroupId = 2
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

                elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 160 or \
                        cellCsiRsInfo[cell]['csiRsReportPeriod'] == 320:
                    rs1 = [{'slotOffset': trsSlot[((1 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (1 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs1startSymb1[csiRsPoolGrpId]}]
                    rs2 = [{'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                            (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40),
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[(csiRsPoolGrpId % maxCsiRsPoolGroups)] + (
                                   (csiRsPoolGrpId % maxCsiRsPoolGroups) * 40),
                            'startingSymbolIndex': rs2startSymb1[csiRsPoolGrpId]}]
                    rs4 = [{'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                            (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb1[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]},
                           {'slotOffset': trsSlot[((2 + csiRsPoolGrpId) % maxCsiRsPoolGroups)] + (
                                   (2 + csiRsPoolGrpId) % maxCsiRsPoolGroups) * 40,
                            'startingSymbolIndex': rs4startSymb2[csiRsPoolGrpId]}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1},
                                                                         {'res': rs2},
                                                                         {'res': rs4}]})

                else:
                    print("csiRsPeriod NOT SUPPORTED")
                    logger.info("csiRsPeriod NOT SUPPORTED")
                    csiRsConfig = None

    # CB009836
    # 5G_UP_ALG_25402 and 5G_UP_ALG_25404
    # 5G_UP_ALG_19019
    # https://gates.nsn-net.net/view/0002753b#o=557&hlt
    elif _actTddCsirsAllocOptimization is True:
        print("CB009836 Cell Specific CSI-RS Config")
        logger.info("CB009836 Cell Specific CSI-RS Config")
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
                csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
            elif cellCsiRsInfo[cell]['csiRsReportPeriod'] == 80:
                if csiRsPoolGrpId == 0 or csiRsPoolGrpId == 1:
                    rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
                else:  # CsiRsPoolingGroupId = 2
                    rs1 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 12}]
                    rs2 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1], 'startingSymbolIndex': 10}]
                    rs4 = [{'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 12},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10},
                           {'slotOffset': trsSlot[csiRsPoolGrpId + 1] + 40, 'startingSymbolIndex': 10}]
                    csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})
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
                csiRsConfig.append({'cellId': cell, 'resource_set': [{'res': rs1}, {'res': rs2}, {'res': rs4}]})

    else:
        print("Activation flag NOT SUPPORTED")
        logger.info("Activation flag NOT SUPPORTED")
        csiRsConfig = None

    if csiRsConfig:
        for data in csiRsConfig:
            logger.info("data = %s" % data)
            logger.info("maxCsiRs = %s in csiRsInfo for data=%s " % (cellCsiRsInfo[data['cellId']]['maxCsiRs'], data))
            if int(cellCsiRsInfo[data['cellId']]['maxCsiRs']) == 1:
                logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsConfig.index(data)]['resource_set'][:])
                del csiRsConfig[csiRsConfig.index(data)]['resource_set'][1:]
                logger.info("keep only one resource")
                logger.info("csiRsConfig = %s" % csiRsConfig)
            if int(cellCsiRsInfo[data['cellId']]['maxCsiRs']) == 2:
                logger.info("csiRsConfig_i = %s" % csiRsConfig[csiRsConfig.index(data)]['resource_set'][:])
                del csiRsConfig[csiRsConfig.index(data)]['resource_set'][2:]
                logger.info("keep only one resource")
                logger.info("csiRsConfig = %s" % csiRsConfig)

        print(csiRsConfig)
        logging.info("csiRsConfig_output = %s" % csiRsConfig)
        logger.info("csiRsConfig_output = %s" % csiRsConfig)

        file = 'expected_cellcsirs_checker_manual_analysis'
        testCaseDir = BuiltIn().get_variable_value('${testCaseDir}')
        filename = testCaseDir + '/' + file + '.json'
        with open(filename, 'w') as f:
            json.dump(csiRsConfig, f, indent=4)

    result_file_fd.close()
    return csiRsConfig


def writeCsiRsConfigCellSpe(file, config, csirsGroups):
    mapping = {}
    for data in csirsGroups:
        mapping[data['cell']] = data['csirsPoolingGroupId']
    print(mapping)
    input_file_fd = open(file, 'a')
    input_file_fd.write("\n***********************\nCell Specific Config\n***********************\n")
    for data in config:
        input_file_fd.write("\n\tcellId " + str(data['cellId']) + " / csiRsGroup " +
                            str(mapping[data['cellId']]) + "\n")
        for data2 in data['resource_set']:
            input_file_fd.write("\t\tresource_set\n")
            # input_file_fd.write("\t\t" + str(data2) + "\n")
            for data3 in data2['res']:
                input_file_fd.write("\t\t\t" + str(data3) + "\n")
            # input_file_fd.write("\tresource_set " + str(data['resource_set']) + "\n")
    input_file_fd.close


class csiRsCellSpecTti:

    def __init__(self):

        # header and column number to extract
        self.csiRsSchedData_hfn_field = "hfnTickCount"
        self.csiRsSchedData_hfn = None
        self.csiRsSchedData_sfn_field = "sfn"
        self.csiRsSchedData_sfn = None
        self.csiRsSchedData_slot_field = "slot"
        self.csiRsSchedData_slot = None
        self.csiRsSchedData_pci_field = "physCellId"
        self.csiRsSchedData_pci = None
        self.csiRsSchedData_startSymb_field = "startSymbol"
        self.csiRsSchedData_startSymb = None

        self.first_csiRsSchedData = True   # At the first index, we search for the fields indexes

        self.data = {}
        self.output = {}

    def closeFileFilter(self):
        self.file_filtered_fd.close()

    def findPos_csiRsSchedData(self, fields):
        offset_value = int(len(fields) / 2)
        self.csiRsSchedData_hfn = fields.index(self.csiRsSchedData_hfn_field) + offset_value
        self.csiRsSchedData_sfn = fields.index(self.csiRsSchedData_sfn_field) + offset_value
        self.csiRsSchedData_slot = fields.index(self.csiRsSchedData_slot_field) + offset_value
        self.csiRsSchedData_pci = fields.index(self.csiRsSchedData_pci_field) + offset_value
        self.csiRsSchedData_startSymb = fields.index(self.csiRsSchedData_startSymb_field) + offset_value
        self.first_csiRsSchedData = False

    def addData(self, fields):
        vslot = int(fields[self.csiRsSchedData_hfn]) * 1024 * 20 + int(fields[self.csiRsSchedData_sfn]) * 20 +\
                int(fields[self.csiRsSchedData_slot])
        if not (vslot in self.data[fields[self.csiRsSchedData_pci]]):
            self.data[fields[self.csiRsSchedData_pci]][vslot] = [1, [int(fields[self.csiRsSchedData_startSymb])]]
        else:
            self.data[fields[self.csiRsSchedData_pci]][vslot][0] = \
                self.data[fields[self.csiRsSchedData_pci]][vslot][0] + 1
            if not (int(fields[self.csiRsSchedData_startSymb]) in self.data[fields[self.csiRsSchedData_pci]][vslot][1]):
                self.data[fields[self.csiRsSchedData_pci]][vslot][1].append(int(fields[self.csiRsSchedData_startSymb]))

    def addMsg(self, current_line):
        current_line = current_line.replace("\n", "").replace(" ", "")
        fields = current_line.split(":")[1].split(",")
        if self.first_csiRsSchedData:
            self.findPos_csiRsSchedData(fields)
        if not (fields[self.csiRsSchedData_pci] in self.data):
            self.data[fields[self.csiRsSchedData_pci]] = {}
        self.addData(fields)

    def final(self):
        for pci in self.data:
            for vslot in self.data[pci]:
                if not (pci in self.output):
                    self.output[pci] = self.data[pci][vslot]
                if self.data[pci][vslot][0] > self.output[pci][0]:
                    self.output[pci][0] = self.data[pci][vslot][0]
                    if self.output[pci][1] != self.data[pci][vslot][1]:
                        self.output[pci][1] = ["NA", "NA"]


def checkRefSignal(input_file, result_file, maxCsirsNumber):
    try:
        # Validate maxCsirsNumber as a list
        if not isinstance(maxCsirsNumber, list):
            print("maxCsirsNumber must be a list.")
            return False

        # Open input and result files
        with open(input_file, 'r') as input_file_fd, open(result_file, 'a') as result_file_fd:
            # Initialize data structure for CSI-RS scheduling information
            csiRsSchedData = csiRsCellSpecTti()

            # Read lines from the input file
            for buffer_in in input_file_fd:
                if buffer_in.find("ERROR") == -1 and re.match(r'csiRsSchedData', buffer_in):
                    csiRsSchedData.addMsg(buffer_in)

            # Finalize CSI-RS scheduling data
            csiRsSchedData.final()

            # Sort data by cell ID
            dico = sorted(csiRsSchedData.output.items(), key=lambda t: t[0])

            # Write results to the result file
            result_file_fd.write("\n\tCell Specific CSI-RS for UEs on each cell\n")
            result_file_fd.write("\t\tMax cell-specific CSI-RS configured {}\n".format(maxCsirsNumber))
            result_file_fd.write("\t\tFrom TTI traces\n")
            text = "\t\t\tCell: {}, {} resources configured in total on symbols {}\n"
            for data in dico:
                result_file_fd.write(text.format(data[0], data[1][0], data[1][1]))

            # Check if the number of cells matches the expected count
            if len(dico) != len(maxCsirsNumber):
                print("Wrong cell number")
                BuiltIn().log("Wrong cell number [current=%s; expected=%s]." % (len(dico), len(maxCsirsNumber)),
                              level="ERROR")
                return False

            # Check if the configured resources match the expected value
            index = 0
            for pci in dico:
                if pci[1][0] != 2 * int(maxCsirsNumber[index]):
                    print("Max RS not configured. PCI: {}".format(pci[0]))
                    BuiltIn().log("Max RS not configured. PCI: {%s}." % pci[0], level="ERROR")
                    return False
                index += 1

            return True
    except FileNotFoundError:
        print("Input file not found.")
        details = traceback.format_exc()
        BuiltIn().log_to_console("debug: Failure in checkRefSignal. traceback = %s" % details)
        BuiltIn().log("debug: Failure in checkRefSignal. traceback = %s" % details, level="ERROR")
        return False
    except Exception as e:
        print(f"An error occurred: {e}")
        details = traceback.format_exc()
        BuiltIn().log_to_console("debug: Failure in checkRefSignal. traceback = %s" % details)
        BuiltIn().log("debug: Failure in checkRefSignal. traceback = %s" % details, level="ERROR")
        return False


def checkRefSignal_v1(input_file, result_file, maxCsirsNumber):

    print(maxCsirsNumber)
    status = True
    input_file_fd = open(input_file, 'r')
    result_file_fd = open(result_file, 'a')
    csiRsSchedData = csiRsCellSpecTti()
    while True:
        buffer_in = input_file_fd.readline()
        if buffer_in == "":
            break
        if buffer_in.find("ERROR") == -1 and re.match(r'csiRsSchedData', buffer_in):
            csiRsSchedData.addMsg(buffer_in)
    input_file_fd.close()
    csiRsSchedData.final()
    # sort data by CellId
    dico = sorted(csiRsSchedData.output.items(), key=lambda t: t[0])
    print(dico)

    result_file_fd.write("\n\tCell Specific CSI-RS for UEs on each cell\n")
    result_file_fd.write("\t\tMax cell-specific CSI-RS configured {}\n".format(maxCsirsNumber))
    result_file_fd.write("\t\tFrom TTI traces\n")
    for data in dico:
        result_file_fd.write("\t\t\tCell: {}, {} resources configured in total on symbols {}\n".format(data[0],
                                                                                                       data[1][0],
                                                                                                       data[1][1]))
    # check if number of Cells match the expected value
    if len(dico) != len(maxCsirsNumber):
        print("Wrong cell number")
        result_file_fd.close()
        return False
    # check if the configured resources match the expected value
    index = 0
    for pci in dico:
        if pci[1][0] != 2*int(maxCsirsNumber[index]):
            print("Max RS not configured. PCI: {}".format(pci[0]))
            status = False
        index += 1
    result_file_fd.close()
    return status


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    maxCsiRsPerCsiRsPool = [4, 4, 4, 4]
    input_file = '/home/ute/csamson/TRACES/ttitrace_streaming.dl.csv'
    result_file = '/home/ute/csamson/TRACES/result.txt'
    checkRefSignal(input_file, result_file, maxCsiRsPerCsiRsPool)

    # framestructure = '5GC001208'
    framestructure = '5GC001116_3_Canada'
    actCsiMux = False
    # CB010513
    actExplicitCsirsPoolSolution = True
    csiRsPeriod = ['slots160', 'slots160', 'slots160', 'slots160', 'slots160', 'slots160']
    csirsNbWithinReportPeriod_Set1 = [1, 1, 1, 1, 1, 1]
    maxCsiRsPerCsiRsPool = [4, 4, 4, 4, 4, 4]
    # case ASOE 4 Cells , cell 16385 and 16388 use csirsPoolingGroupId=0
    # csiRsGroups = [{'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
    #                {'cell': 16386, 'csirsPoolingGroupId': 1, 'lcrId': 2},
    #                {'cell': 16387, 'csirsPoolingGroupId': 1, 'lcrId': 3},
    #                {'cell': 16388, 'csirsPoolingGroupId': 2, 'lcrId': 4}]

    csiRsGroups = [{'cell': 16385, 'csirsPoolingGroupId': 0, 'lcrId': 1},
                   {'cell': 16386, 'csirsPoolingGroupId': 0, 'lcrId': 2},
                   {'cell': 16387, 'csirsPoolingGroupId': 2, 'lcrId': 3},
                   {'cell': 16388, 'csirsPoolingGroupId': 1, 'lcrId': 4},
                   {'cell': 16389, 'csirsPoolingGroupId': 1, 'lcrId': 5},
                   {'cell': 16390, 'csirsPoolingGroupId': 2, 'lcrId': 6}]

    # nrCellId
    cellList = ['1', '2', '3', '4', '5', '6']
    # CB009836
    # actTddCsirsAllocOptimization = False
    actTddCsirsAllocOptimization = False
    actInfTddFrameMuting = False
    csiRsConfig_calc = createCellCsiRs_9836_v3(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
                                               csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool, csiRsGroups,
                                               cellList, actTddCsirsAllocOptimization, actInfTddFrameMuting)
    logging.info("csiRsConfig Calculated = %s" % csiRsConfig_calc)

    # actTddCsirsAllocOptimization = True
    # csiRsConfig_calc = createCellCsiRs_9836(framestructure, actCsiMux, actExplicitCsirsPoolSolution, csiRsPeriod,
    #                                         csirsNbWithinReportPeriod_Set1, maxCsiRsPerCsiRsPool,
    #                                         csiRsGroups, cellList,
    #                                         actTddCsirsAllocOptimization, actInfTddFrameMuting)
    # logging.info("csiRsConfig Calculated = %s" % csiRsConfig_calc)

    # pass
