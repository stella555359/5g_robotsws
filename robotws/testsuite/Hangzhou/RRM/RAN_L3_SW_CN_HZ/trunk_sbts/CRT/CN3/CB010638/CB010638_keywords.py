# -*- coding: utf-8 -*-
# comment

import json
import os
import time
from robot.errors import ExecutionFailed
from ta5g_enb import ta5g_enb


def generateJSONFile(outputFile, data):
    with open(outputFile, "w") as json_file:
        json.dump(data, json_file, indent=4)

    if not os.path.exists(outputFile):
        raise ExecutionFailed(message="json file generation failed!")

    time.sleep(0.1)


def generate_lbpsCellList(lbpsCellSOOrderList, outputFile):
    localList = lbpsCellSOOrderList.split(',')
    localList = [int(SOOrder) for SOOrder in localList]
    data = [
        {
            "distName": "MRBTS-1/NRBTS-1/NRPGRP-1",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "lbpsCellList",
                    "value": [
                        {
                            "lbpsCellSOOrder": str(lbpsCellSOOrder),
                            "lbpsUseExtConfig": "False",
                            "nrCellId": str(nrCellId)
                        }
                        for nrCellId, lbpsCellSOOrder in enumerate(localList, start=1)
                    ]
                }
            ]
        }
    ]

    generateJSONFile(outputFile, data)


def generate_lbpsPeriodList(offset, outputFile, init):
    ta5g_enb_instance = ta5g_enb()
    date_output = ta5g_enb_instance.execute_enb_command(cmd="date \"+%a %H %M\"")
    day, hour, minute = date_output.strip().split()

    adjusted_minute = int(minute) + int(offset)
    adjusted_hour = int(hour)
    adjusted_day = day
    adjusted_duration = 1440

    if adjusted_minute >= 60:
        adjusted_hour += 1
        adjusted_minute -= 60
        if adjusted_hour >= 24:
            adjusted_hour -= 24
            day_number = int(day_number)
            day_names = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            adjusted_day = day_names[(day_number + 1) % 7]

    if init == "True":
        adjusted_hour = 23
        adjusted_minute = 59
        adjusted_day = "Sun"
        adjusted_duration = 1
    data = [
        {
            "distName": "MRBTS-1/NRBTS-1/NRPGRP-1",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "lbpsPeriodList",
                    "value": [
                        {
                            "lbpsDayOfWeek": str(adjusted_day),
                            "lbpsDuration": str(adjusted_duration),
                            "lbpsStartTimeHour": str(adjusted_hour),
                            "lbpsStartTimeMinute": str(adjusted_minute),
                            "lbpsSuspended": "notSuspended"
                        }
                    ]
                }
            ]
        }
    ]

    generateJSONFile(outputFile, data)


def setPowerSavingParameters(paramList, outputFile):
    localList = paramList.split(',')
    localList = [str(paramValue) for paramValue in localList]
    data = [
        {
            "distName": "MRBTS-1/NRBTS-1",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "actNrLBPowerSaving",
                    "value": str(localList[0])
                },
                {
                    "operation": "update",
                    "parameterName": "actNrLBRTXPowerSaving",
                    "value": str(localList[1])
                },
                {
                    "operation": "update",
                    "parameterName": "actNrLBmMimoRTXPowerSaving",
                    "value": str(localList[2])
                },
                {
                    "operation": "update",
                    "parameterName": "actNrMixedSOMethod",
                    "value": str(localList[3])
                }
            ]
        },
        {
            "distName": "MRBTS-1/NRBTS-1/NRPGRP-1",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "lbpsSOMethod",
                    "value": str(localList[4])
                }
            ]
        }
    ]

    generateJSONFile(outputFile, data)


def setCB008745Parameters(action, outputFile):

    if action == "update":
        state = "true"
    else:
        state = "false"

    data = [
        {
            "distName": "MRBTS-1/NRBTS-1",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "actLbpsCtrlLogicEnh",
                    "value": str(state)
                }
            ]
        },
        {
            "distName": "MRBTS-1/NRBTS-1/NRPGRP-1",
            "operation": "update",
            "parameters": [
                {
                    "operation": str(action),
                    "parameterName": "lbpsLoadCalcMethod",
                    "value": "Max(G, C, P)"
                },
                {
                    "operation": str(action),
                    "parameterName": "lbpsMonWinForCellSOff",
                    "value": "60"
                },
                {
                    "operation": str(action),
                    "parameterName": "lbpsMonWinForCellSOn",
                    "value": "60"
                },
                {
                    "operation": str(action),
                    "parameterName": "lbpsSOffTrRule",
                    "value": "SlidingAverageMethod"
                },
                {
                    "operation": str(action),
                    "parameterName": "lbpsSOnTrRule",
                    "value": "SlidingAverageMethod"
                }
            ]
        }
    ]

    generateJSONFile(outputFile, data)
