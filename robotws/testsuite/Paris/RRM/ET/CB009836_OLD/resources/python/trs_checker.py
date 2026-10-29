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

from taf.ul.ettf.logger import custom_logger
from taf.ul.ettf.logger import log as ettf_log

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

from taf.config.scf import scf
from taf.config.scf import scf_operations as scf

logger = custom_logger(name='trs_checker', filename='test_execution_trs_checker.log', disable_html_logging=True)


@ettf_log('createTrsCsiRs...', 'createTrsCsiRs finished', logger)
def createTrsCsiRs(frameStructure, beamCfg, slowPrbPoolingTddFr1DlAllowed,
                   actExplicitCsirsPoolSolution, actInfTddFrameMuting=False, actTddCsirsAllocOptimization=False,
                   numOfSubSectors='0sub-sector'):
    if type(slowPrbPoolingTddFr1DlAllowed) is bool:
        _slowPrbPoolingTddFr1DlAllowed = slowPrbPoolingTddFr1DlAllowed
    else:
        if slowPrbPoolingTddFr1DlAllowed == 'True' or slowPrbPoolingTddFr1DlAllowed == 'true':
            _slowPrbPoolingTddFr1DlAllowed = True
        else:
            _slowPrbPoolingTddFr1DlAllowed = False
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

    # 5GC001116_3 means tdLte 3ms
    # 5GC001116_0 means tdLte 0ms
    # 5GC001116_3_Canada means tdLte 3ms (Bell Canada)
    # 5GC001208 means SemiStatic 1:4
    # 5GC001070 means SemiStatic 3:7
    # 5G_UP_ALG_19422
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

    ssBurstSetPeriod = 40
    nbBeams = int(beamCfg.split(" ")[0])
    csirsPoolingGroup = []
    numOfSubSectors = int(numOfSubSectors.split("sub-sector")[0])

    print('framestructure: {}'.format(framestructure))
    print('slowPrbPoolingTddFr1DlAllowed: {}'.format(slowPrbPoolingTddFr1DlAllowed))
    print('actExplicitCsirsPoolSolution: {}'.format(actExplicitCsirsPoolSolution))
    print('actTddCsirsAllocOptimization: {}'.format(actTddCsirsAllocOptimization))
    print('actInfTddFrameMuting: {}'.format(actInfTddFrameMuting))
    print('nbBeams: {}'.format(nbBeams))
    print('numOfSubSectors: {}'.format(numOfSubSectors))
    print('trsSlotOffset: {}'.format(trsSlotOffset))

    logger.info("slowPrbPoolingTddFr1DlAllowed: %s" % slowPrbPoolingTddFr1DlAllowed)
    logger.info("actExplicitCsirsPoolSolution: %s" % actExplicitCsirsPoolSolution)
    logger.info("actTddCsirsAllocOptimization: %s" % actTddCsirsAllocOptimization)
    logger.info("actInfTddFrameMuting: %s" % actInfTddFrameMuting)
    logger.info("nbBeams: %s" % nbBeams)
    logger.info('numOfSubSectors: {}'.format(numOfSubSectors))
    logger.info("trsSlotOffset: %s" % trsSlotOffset)

    # 5G_CP_ARC_ALG_2020 : Handling of csiRsTrackingResourceSet for FR1 (according to [5G_CP_ARC_ALG_13045])
    # https://gates.nsn-net.net/view/00025da1#o=5488
    for csiRsGroupId in range(3):

        # print("****************\ncsiRsGroupId: {}".format(csiRsGroupId))
        logger.info("csiRsGroupId: %s" % csiRsGroupId)
        csirsPoolingGroup.append({"csirsPoolingGroupId": csiRsGroupId, "csirsTrackingResourceSet": []})

        if _slowPrbPoolingTddFr1DlAllowed is True and _actExplicitCsirsPoolSolution is False and \
                _actTddCsirsAllocOptimization is False:
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

        elif ((_slowPrbPoolingTddFr1DlAllowed is True and _actExplicitCsirsPoolSolution is True) or
              _actTddCsirsAllocOptimization is True) and (numOfSubSectors == 0):
            if _actTddCsirsAllocOptimization is True:
                print("CB009836 Config")
                logger.info("CB009836 Config")
            else:
                print("CB010513 Config")
                logger.info("CB010513 Config")
            # print("-----------------\ni: {}, j: {}".format(trsSlotOffset[frameStructure]['i'],
            # trsSlotOffset[frameStructure]['j']))
            logger.info("-------------------i: %s, j: %s" % (trsSlotOffset[frameStructure]['i'],
                                                             trsSlotOffset[frameStructure]['j']))
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
            logger.info("csiResourceConfig = %s", csiResourceConfig)

        elif ((_slowPrbPoolingTddFr1DlAllowed is True and _actExplicitCsirsPoolSolution is True) or
              _actTddCsirsAllocOptimization is True) and (numOfSubSectors == 2):
            if _actTddCsirsAllocOptimization is True:
                print("CB009836 Config with numOfSubSectors=2")
                logger.info("CB009836 Config with numOfSubSectors=2")
            else:
                print("CB010513 Config with numOfSubSectors=2")
                logger.info("CB010513 Config with numOfSubSectors=2")
            # print("-----------------\ni: {}, j: {}".format(trsSlotOffset[frameStructure]['i'],
            # trsSlotOffset[frameStructure]['j']))
            logger.info("-------------------i: %s, j: %s" % (trsSlotOffset[frameStructure]['i'],
                                                             trsSlotOffset[frameStructure]['j']))
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
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 2}
                    ],
            }
            print(csiResourceConfig)
            logger.info("csiResourceConfig = %s", csiResourceConfig)

        elif ((_slowPrbPoolingTddFr1DlAllowed is True and _actExplicitCsirsPoolSolution is True) or
              _actTddCsirsAllocOptimization is True) and (numOfSubSectors == 4):
            if _actTddCsirsAllocOptimization is True:
                print("CB009836 Config with numOfSubSectors=2")
                logger.info("CB009836 Config with numOfSubSectors=2")
            else:
                print("CB010513 Config with numOfSubSectors=2")
                logger.info("CB010513 Config with numOfSubSectors=2")
            # print("-----------------\ni: {}, j: {}".format(trsSlotOffset[frameStructure]['i'],
            # trsSlotOffset[frameStructure]['j']))
            logger.info("-------------------i: %s, j: %s" % (trsSlotOffset[frameStructure]['i'],
                                                             trsSlotOffset[frameStructure]['j']))
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
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 2}
                    ],
                2: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_4", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_8", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_4", 'RE': 1},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_8", 'RE': 1}
                    ],
                3: [{'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod,
                     'symbol': "SYMBOL_9", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_5", 'RE': 2},
                    {'slot': trsSlotOffset[frameStructure]['i'] + csiRsGroupId * ssBurstSetPeriod + 1,
                     'symbol': "SYMBOL_9", 'RE': 2}
                    ],
            }
            print(csiResourceConfig)
            logger.info("csiResourceConfig = %s", csiResourceConfig)

        else:
            print("Pooling activation flag combination NOT SUPPORTED")
            logger.info("Pooling activation flag combination NOT SUPPORTED")
            csirsPoolingGroup = None

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

    logger.info("csirsPoolingGroup = %s", csirsPoolingGroup)
    file = 'expected_trs_checker_manual_analysis'
    testCaseDir = BuiltIn().get_variable_value('${testCaseDir}')
    filename = testCaseDir + '/' + file + '.json'
    with open(filename, 'w') as f:
        json.dump(csirsPoolingGroup, f, indent=4)
    return csirsPoolingGroup


def get_csirsTrackingSlotOffset_list(filename='expected_trs_checker_manual_analysis', csirsPoolingGroupId=0):
    """
       Retrieves a list of csirsTrackingSlotOffset values based on the provided csirsPoolingGroupId.

       Args:
           filename (str): The name of the file containing csirsTrackingSlotOffset data.
            Default is 'expected_trs_checker_manual_analysis'.
           csirsPoolingGroupId (int): The csirsPoolingGroupId for which to retrieve csirsTrackingSlotOffset values.
            Default is 0.

       Returns:
           list: A list of csirsTrackingSlotOffset values associated with the specified csirsPoolingGroupId.

       Example:
           # Assuming data is stored in 'expected_trs_checker_manual_analysis.json'
           csirs_offsets = get_csirsTrackingSlotOffset_list(filename='expected_trs_checker_manual_analysis',
            csirsPoolingGroupId=2)
           print(csirs_offsets)  # Output: [10, 15, 20]

       Note:
           - The function reads data from the specified file and filters based on csirsPoolingGroupId.
           - Modify the filename or provide a different path if needed.
    """
    # testCaseDir = BuiltIn().get_variable_value('${testCaseDir}')
    # filename = testCaseDir + '/' + file + '.json'
    list_csirsTrackingSlotOffset = []
    with open(filename, 'r') as f:
        file_content = f.read()
        data = json.loads(file_content)
    for item in data:
        if item['csirsPoolingGroupId'] == csirsPoolingGroupId:
            for csirsTrackingResourceSet_item in item['csirsTrackingResourceSet']:
                for csirsTrackingResource_item in csirsTrackingResourceSet_item['csirsTrackingResource']:
                    slot = csirsTrackingResource_item['csirsTrackingSlotOffset'] % 20
                    if slot not in list_csirsTrackingSlotOffset:
                        list_csirsTrackingSlotOffset.append(int(slot))
    return list_csirsTrackingSlotOffset


@ettf_log('filter_trs_offset...', 'filter_trs_offset finished', logger)
def filter_trs_offset(expectedTrsCsiRs=None, csirsgroups=None, lcrId=1):
    if expectedTrsCsiRs is None:
        return
    try:
        csirsgroup_cell = [sub['csirsPoolingGroupId'] for sub in csirsgroups if sub['lcrId'] == int(lcrId)]
        expectedtrscsirs_cell_grp = [sub for sub in expectedTrsCsiRs
                                     if sub['csirsPoolingGroupId'] == csirsgroup_cell[0]]
    except Exception as e:
        details = traceback.format_exc()
        BuiltIn().log_to_console("debug: Failure in filter_trs_offset. traceback = %s" % details)
        BuiltIn().log("debug: Failure in filter_trs_offset. traceback = %s" % details)
    msg = "[filter_trs_offset] =====> sorted_slots=%s"
    logger.info(msg % expectedtrscsirs_cell_grp)
    return expectedtrscsirs_cell_grp


def writeCsiRsConfigTrs(file, config):
    input_file_fd = open(file, 'a')
    input_file_fd.write("\n*************\nTRS Config\n*************\n")
    for data in config:
        input_file_fd.write("\n\tcsirsPoolingGroupId " + str(data['csirsPoolingGroupId']) + "\n")
        for data2 in data['csirsTrackingResourceSet']:
            input_file_fd.write("\t\tssbIndex " + str(data2['ssbIndex']) + "\n")
            for data3 in data2['csirsTrackingResource']:
                input_file_fd.write("\t\t\t" + str(data3) + "\n")
    input_file_fd.close()


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)

    # tafScfFunc = scf.SCFOperations()
    # tafScfFunc.load_scf(file_path='/home/ute/csamson/TRACES/scf_orig.xml')
    # tafScfFunc.modify_scf_element(dist_name='MRBTS-1/NRBTS-1', p_name='actTddCsiRsOpt', value='false')

    # file = '/home/ute/csamson/TRACES/expected_trs_checker_manual_analysis.json'
    # csirsTrackingSlotOffset_list_cell50 = get_csirsTrackingSlotOffset_list(filename=file, csirsPoolingGroupId=0)
    # csirsTrackingSlotOffset_list_cell51 = get_csirsTrackingSlotOffset_list(filename=file, csirsPoolingGroupId=1)
    # csirsTrackingSlotOffset_list_cell52 = get_csirsTrackingSlotOffset_list(filename=file, csirsPoolingGroupId=2)

    # SemiStatic 1:4
    framestructure = '5GC001208'
    # framestructure = '5GC001116_3_Canada'
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

    # actTddCsirsAllocOptimization = False
    slowPrbPoolingTddFr1DlAllowed = True
    actTddCsirsAllocOptimization = True
    actInfTddFrameMuting = False
    beamCfg = ['8 beams', '8 beams', '8 beams', '8 beams', '8 beams', '8 beams']
    TrsCsiRsConfig_calc = createTrsCsiRs(framestructure, beamCfg[0], slowPrbPoolingTddFr1DlAllowed,
                                         actExplicitCsirsPoolSolution, actInfTddFrameMuting=False,
                                         actTddCsirsAllocOptimization=False, numOfSubSectors='0sub-sector')
    logging.info("TrsCsiRsConfig_calc Calculated = %s" % TrsCsiRsConfig_calc)
    # pass
