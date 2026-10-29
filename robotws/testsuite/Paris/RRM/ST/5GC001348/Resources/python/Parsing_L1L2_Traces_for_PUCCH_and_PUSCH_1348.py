"""
        Keywords Purpose:
            Keywords to manage logs

        AUTHOR:
            Pape DIALLO         pape.diallo@nokia.com
            Florence Thepot     florence.thepot@nokia.com
            Annie Wong          annie.wong@nokia.com

        Last update 23.03.2021
"""

import pyshark
import requests
import time
import re
import os
import os.path
from collections import defaultdict

from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn

rob = BuiltIn()
ssh_mgt = ssh()


def check_slot_for_ulData_PUCCHreceiveReq_TC11(pdml_name):
    # Read the pdml file
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')
    re_startPrb = re.compile(r'UlData_PucchReceiveReq.pucchResources_item_85.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfPrb = re.compile(r'UlData_PucchReceiveReq.pucchResources_item_85.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfSymbols = re.compile(
        r'UlData_PucchReceiveReq.pucchResources_item_85.numOfSymbols.+ show="(0x[0-9A-Fa-f]+)"')
    re_firstSymbol = re.compile(
        r'UlData_PucchReceiveReq.pucchResources_item_85.firstSymbol.+ show="(0x[0-9A-Fa-f]+)"')
    slot = 0
    sfn = 0
    startPrb = 0
    numOfPrb = 0
    numOfSymbols = 0
    firstSymbol = 0
    nb_line = 0
    nb_check = 0
    nb_check_OK = 0
    nb_check_KO = 0
    # no more check on nb_check_startPrbFailure, as it can be 0 / 16 /etc
    # nb_check_startPrbFailure = 0
    nb_check_numOfPrbFailure = 0
    nb_check_numOfSymbolsFailure = 0
    nb_check_firstSymbolFailure = 0

    # Parse each packet
    for line in input_file:
        nb_line += 1

        # Extract the sfn data in the line
        group_list = re_sfn.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        # Extract slot data in the line:
        group_list = re_slot.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

        # Extract startPrb data in other line:
        group_list = re_startPrb.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            startPrb = int(data_value, 16)

        # Extract numOfPrb data in other line:
        group_list = re_numOfPrb.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            numOfPrb = int(data_value, 16)

        # Extract numOfSymbols data in other line:
        group_list = re_numOfSymbols.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            numOfSymbols = int(data_value, 16)

        # Extract firstSymbol data in other line:
        group_list = re_firstSymbol.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            firstSymbol = int(data_value, 16)

            # now that firstSymbol is found, check all retrieved parameters:
            if sfn % 2 == 1:
                if slot == 19 or slot == 9:
                    # prachConfigurationIndex:93 => rach occurence in slots 9 and 19

                    _error_found = 0
                    # check:
                    # if startPrb != 0:
                    #    _error_found = 1
                    #   nb_check_startPrbFailure += 1
                    if numOfPrb != 1 and numOfPrb != 5:
                        _error_found = 1
                        nb_check_numOfPrbFailure += 1
                    if numOfSymbols != 1:
                        _error_found = 1
                        nb_check_numOfSymbolsFailure += 1
                    if firstSymbol != 12 and firstSymbol != 13:
                        _error_found = 1
                        nb_check_firstSymbolFailure += 1

                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                        rob.log('GOOD sfn{} slot{} startPrb:{} numPrb:{} numSymb:{} firstSymb:{}'.format(sfn,
                                                                                                         slot,
                                                                                                         startPrb,
                                                                                                         numOfPrb,
                                                                                                         numOfSymbols,
                                                                                                         firstSymbol))
                    else:
                        nb_check_KO += 1
                        rob.log('ERR  sfn{} slot{} startPrb:{} numPrb:{} numSymb:{} firstSymb:{}'.format(sfn,
                                                                                                         slot,
                                                                                                         startPrb,
                                                                                                         numOfPrb,
                                                                                                         numOfSymbols,
                                                                                                         firstSymbol))
    rob.log('nb_check={}, nb_check_OK={}, nb_check_KO={}'.format(nb_check, nb_check_OK, nb_check_KO))
    # rob.log('nb_check_startPrb_Failure={}'.format(nb_check_startPrbFailure))
    rob.log('nb_check_numOfPrb_Failure={}'.format(nb_check_numOfPrbFailure))
    rob.log('nb_check_numOfSymbols_Failure={}'.format(nb_check_numOfSymbolsFailure))
    rob.log('nb_check_firstSymbol_Failure={}'.format(nb_check_firstSymbolFailure))
    # assert nb_check_startPrbFailure < 1, "Assert: error about the start prb, {}".format(nb_check_startPrbFailure)
    assert nb_check_numOfPrbFailure < 1, "Error about numOfPrb, times={}".format(nb_check_numOfPrbFailure)
    assert nb_check_numOfSymbolsFailure < 1, "Error about numOfSymbols, times={}".format(nb_check_numOfSymbolsFailure)
    assert nb_check_firstSymbolFailure < 1, "Error about firstSymbol,times={}".format(nb_check_firstSymbolFailure)
    assert nb_check_OK > 0, "Assert: nb_check_OK is none"


def check_slot_for_ulData_PUSCHreceiveReq_TC11bis(pdml_name):
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PuschReceiveReq.PuschReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PuschReceiveReq.PuschReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')
    # case pucch :
    # re_startPrb = re.compile(r'UlData_PuschReceiveReq.puschResources_item_85.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_startPrb = re.compile(r'UlData_PuschReceiveReq.grants_item_15.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    # case pucch :
    # re_numOfPrb = re.compile(r'UlData_PuschReceiveReq.puschResources_item_85.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfPrb = re.compile(r'UlData_PuschReceiveReq.grants_item_15.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')

    # check = False
    slot = 0
    sfn = 0
    startPrb = 0
    numOfPrb = 0
    numOfSymbols = 0
    firstSymbol = 0
    nb_line = 0
    nb_check = 0
    nb_check_OK = 0
    nb_check_KO = 0
    nb_check_startPrbFailure = 0
    nb_check_numOfPrbFailure = 0

    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_sfn.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        group_list = re_slot.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

        group_list = re_startPrb.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            startPrb = int(data_value, 16)

        group_list = re_numOfPrb.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            numOfPrb = int(data_value, 16)

            if sfn % 2 == 1:
                if slot == 19 or slot == 9:
                    _error_found = 0
                    # startPrb is : 12 + 5
                    if startPrb != 17:
                        nb_check_startPrbFailure += 1
                        _error_found = 1
                    # numPrb is: 273 - 17 = 256
                    if numOfPrb != 256:
                        nb_check_numOfPrbFailure += 1
                        _error_found = 1

                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                        rob.log('GOOD sfn{} slot{} startPrb:{} numPrb:{}'.format(sfn, slot, startPrb, numOfPrb))
                    else:
                        nb_check_KO += 1
                        rob.log('ERR: sfn{} slot{} startPrb:{} numPrb:{}'.format(sfn, slot, startPrb, numOfPrb))
    rob.log('nb_check={}, nb_check_OK={}, nb_check_KO={}'.format(nb_check, nb_check_OK, nb_check_KO))
    rob.log('nb_check_startPrb_Failure={}'.format(nb_check_startPrbFailure))
    rob.log('nb_check_numOfPrb_Failure={}'.format(nb_check_numOfPrbFailure))
    assert nb_check_startPrbFailure < 1, "Error about startPrb, times={}".format(nb_check_startPrbFailure)
    assert nb_check_numOfPrbFailure < 1, "Error about numOfPrb, times={}".format(nb_check_numOfPrbFailure)
    assert nb_check_OK > 0, "Assert: nb_check_OK is none"


def check_slot_for_ulData_PUCCHreceiveReq_TC13(pdml_name):
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')
    re_startPrb = re.compile(r'UlData_PucchReceiveReq.pucchResources_item_85.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfPrb = re.compile(r'UlData_PucchReceiveReq.pucchResources_item_85.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfSymbols = re.compile(
        r'UlData_PucchReceiveReq.pucchResources_item_85.numOfSymbols.+ show="(0x[0-9A-Fa-f]+)"')
    re_firstSymbol = re.compile(
        r'UlData_PucchReceiveReq.pucchResources_item_85.firstSymbol.+ show="(0x[0-9A-Fa-f]+)"')

    # check = False
    slot = 0
    sfn = 0
    startPrb = 0
    numOfPrb = 0
    numOfSymbols = 0
    firstSymbol = 0
    nb_line = 0
    nb_check = 0
    nb_check_OK = 0
    nb_check_KO = 0
    # nb_check_startPrbFailure = 0
    nb_check_numOfPrbFailure = 0
    nb_check_numOfSymbolsFailure = 0
    nb_check_firstSymbolFailure = 0
    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_sfn.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        group_list = re_slot.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

        group_list = re_startPrb.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            startPrb = int(data_value, 16)

        group_list = re_numOfPrb.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            numOfPrb = int(data_value, 16)

        group_list = re_numOfSymbols.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            numOfSymbols = int(data_value, 16)

        group_list = re_firstSymbol.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            firstSymbol = int(data_value, 16)

            if sfn % 2 == 1:
                if slot == 19:
                    # prachConfigurationIndex:98 => rach occurence in slot 19

                    _error_found = 0
                    # startPrb can be 0 / 16 / 32
                    # if startPrb != 0:
                    #    nb_check_startPrbFailure += 1
                    #    _error_found = 1

                    # numOfPrb=1 for ACK and numOfPrb=5 for CQI
                    if numOfPrb != 1 and numOfPrb != 5:
                        nb_check_numOfPrbFailure += 1
                        _error_found = 1
                    if numOfSymbols != 1:
                        nb_check_numOfSymbolsFailure += 1
                        _error_found = 1
                    # firstSymbol=12 for FDM and firstSymbol=13 for TDM
                    if firstSymbol != 12 and firstSymbol != 13:
                        nb_check_firstSymbolFailure += 1
                        _error_found = 1
                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                        rob.log('ERR  sfn{} slot{} startPrb:{} numPrb:{} numSymb:{} firstSymb:{}'.format(sfn,
                                                                                                         slot,
                                                                                                         startPrb,
                                                                                                         numOfPrb,
                                                                                                         numOfSymbols,
                                                                                                         firstSymbol))
                    else:
                        nb_check_KO += 1
                        rob.log('ERR  sfn{} slot{} startPrb:{} numPrb:{} numSymb:{} firstSymb:{}'.format(sfn,
                                                                                                         slot,
                                                                                                         startPrb,
                                                                                                         numOfPrb,
                                                                                                         numOfSymbols,
                                                                                                         firstSymbol))
    rob.log('nb_check={}, nb_check_OK={}, nb_check_KO={}'.format(nb_check, nb_check_OK, nb_check_KO))
    # rob.log('nb_check_startPrb_Failure={}'.format(nb_check_startPrbFailure))
    rob.log('nb_check_numOfPrb_Failure={}'.format(nb_check_numOfPrbFailure))
    rob.log('nb_check_numOfSymbols_Failure={}'.format(nb_check_numOfSymbolsFailure))
    rob.log('nb_check_firstSymbol_Failure={}'.format(nb_check_firstSymbolFailure))
    # assert nb_check_startPrbFailure < 1, "Error about the start prb, {}".format(nb_check_startPrbFailure)
    assert nb_check_numOfPrbFailure < 1, "Error about numOfPrb,times={}".format(nb_check_numOfPrbFailure)
    assert nb_check_numOfSymbolsFailure < 1, "Error about numOfSymbols,times={}".format(nb_check_numOfSymbolsFailure)
    assert nb_check_firstSymbolFailure < 1, "Error about firstSymbol,times={}".format(nb_check_firstSymbolFailure)
    assert nb_check_OK > 0, "Assert: nb_check_OK is none"


def check_slot_for_ulData_PUCCHreceiveReq_TC23(pdml_name):
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')
    re_startPrb = re.compile(r'UlData_PucchReceiveReq.pucchResources_item_85.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfPrb = re.compile(r'UlData_PucchReceiveReq.pucchResources_item_85.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfSymbols = re.compile(
        r'UlData_PucchReceiveReq.pucchResources_item_85.numOfSymbols.+ show="(0x[0-9A-Fa-f]+)"')
    re_firstSymbol = re.compile(
        r'UlData_PucchReceiveReq.pucchResources_item_85.firstSymbol.+ show="(0x[0-9A-Fa-f]+)"')

    # check = False
    slot = 0
    sfn = 0
    startPrb = 0
    numOfPrb = 0
    numOfSymbols = 0
    firstSymbol = 0
    nb_line = 0
    nb_check = 0
    nb_check_OK = 0
    nb_check_KO = 0
    nb_check_startPrbFailure = 0
    nb_check_numOfPrbFailure = 0
    nb_check_numOfSymbolsFailure = 0
    nb_check_firstSymbolFailure = 0
    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_sfn.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        group_list = re_slot.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

        group_list = re_startPrb.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            startPrb = int(data_value, 16)

        group_list = re_numOfPrb.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            numOfPrb = int(data_value, 16)

        group_list = re_numOfSymbols.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            numOfSymbols = int(data_value, 16)

        group_list = re_firstSymbol.search(line)
        if group_list:
            data_value = group_list.groups()[0]
            firstSymbol = int(data_value, 16)

            if sfn % 2 == 1:
                if slot == 19:
                    # prachConfigurationIndex:98 => rach occurence in slot 19

                    _error_found = 0
                    if startPrb != 0:
                        nb_check_startPrbFailure += 1
                        _error_found = 1
                    if numOfPrb != 1:
                        nb_check_numOfPrbFailure += 1
                        _error_found = 1
                    if numOfSymbols != 1:
                        nb_check_numOfSymbolsFailure += 1
                        _error_found = 1
                    if firstSymbol != 13:
                        nb_check_firstSymbolFailure += 1
                        _error_found = 1
                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                        rob.log('ERR  sfn{} slot{} startPrb:{} numPrb:{} numSymb:{} firstSymb:{}'.format(sfn,
                                                                                                         slot,
                                                                                                         startPrb,
                                                                                                         numOfPrb,
                                                                                                         numOfSymbols,
                                                                                                         firstSymbol))
                    else:
                        nb_check_KO += 1
                        rob.log('ERR  sfn{} slot{} startPrb:{} numPrb:{} numSymb:{} firstSymb:{}'.format(sfn,
                                                                                                         slot,
                                                                                                         startPrb,
                                                                                                         numOfPrb,
                                                                                                         numOfSymbols,
                                                                                                         firstSymbol))
    rob.log('nb_check={}, nb_check_OK={}, nb_check_KO={}'.format(nb_check, nb_check_OK, nb_check_KO))
    rob.log('nb_check_startPrb_Failure={}'.format(nb_check_startPrbFailure))
    rob.log('nb_check_numOfPrb_Failure={}'.format(nb_check_numOfPrbFailure))
    rob.log('nb_check_numOfSymbols_Failure={}'.format(nb_check_numOfSymbolsFailure))
    rob.log('nb_check_firstSymbol_Failure={}'.format(nb_check_firstSymbolFailure))
    assert nb_check_startPrbFailure < 1, "Error about startPrb,times={}".format(nb_check_startPrbFailure)
    assert nb_check_numOfPrbFailure < 1, "Error about numOfPrb,times={}".format(nb_check_numOfPrbFailure)
    assert nb_check_numOfSymbolsFailure < 1, "Error about numOfSymbols,times={}".format(nb_check_numOfSymbolsFailure)
    assert nb_check_firstSymbolFailure < 1, "Error about firstSymbol,times={}".format(nb_check_firstSymbolFailure)
    assert nb_check_OK > 0, "Assert: nb_check_OK is none"


def check_slot_for_ulData_PUCCHreceiveReq_TC22(pdml_name):
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PucchReceiveReq.PucchReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')

    # check = False
    slot = 0
    sfn = 0
    nb_line = 0
    nb_check = 0
    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_sfn.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        group_list = re_slot.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

            if slot == 19 or slot == 9:
                nb_check += 1
                assert sfn % 2 == 0, "Assert: slot 9 or 19 is present in odd sfn:{} slot:{}".format(sfn, slot)
    rob.log('The nb_check values is {}'.format(nb_check))


def check_slot_for_ulData_PUSCHreceiveReq_TCJ003_prachConfig_98_1Ue_2beams_2subcells(pdml_name):
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PuschReceiveReq.PuschReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PuschReceiveReq.PuschReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')
    # case pucch :
    # re_startPrb = re.compile(r'UlData_PuschReceiveReq.puschResources_item_85.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_startPrb = re.compile(r'UlData_PuschReceiveReq.grants_item_15.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    # case pucch :
    # re_numOfPrb = re.compile(r'UlData_PuschReceiveReq.puschResources_item_85.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfPrb = re.compile(r'UlData_PuschReceiveReq.grants_item_15.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_subcellId = re.compile(r'UlData_PuschReceiveReq.subcells_item_3.subcellId.+ show="(0x[0-9A-Fa-f]+)"')

    # check = False
    slot = 0
    sfn = 0
    startPrb = 0
    subcellId = 0
    numOfPrb = 0
    numOfSymbols = 0
    firstSymbol = 0
    nb_line = 0
    nb_check = 0
    nb_check_OK = 0
    nb_check_KO = 0
    nb_check_startPrbFailure = 0
    nb_check_numOfPrbFailure = 0
    nb_check_subcellIdFailure = 0
    nb_check_subcellIdFailure_OddSfn = 0
    nb_check_subcellIdFailure_EvenSfn = 0

    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_sfn.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        group_list = re_slot.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

        group_list = re_startPrb.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            startPrb = int(data_value, 16)

        group_list = re_subcellId.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            subcellId = int(data_value, 16)

        group_list = re_numOfPrb.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            numOfPrb = int(data_value, 16)

            if sfn % 2 == 1:
                if slot == 19:
                    _error_found = 0
                    # startPrb is : 12 + 0
                    if startPrb != 12:
                        nb_check_startPrbFailure += 1
                        _error_found = 1
                    # numPrb is: 273 - 12 = 261
                    if numOfPrb != 261:
                        nb_check_numOfPrbFailure += 1
                        _error_found = 1
                    # sucellId is: 1
                    if subcellId != 1:
                        nb_check_subcellIdFailure += 1
                        _error_found = 1

                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                    else:
                        nb_check_KO += 1
                        rob.log(
                            'ERR: sfn{} slot{} startPrb{} numPrb{} subcellId:{}'.format(sfn, slot, startPrb, numOfPrb,
                                                                                        subcellId))
                else:
                    if subcellId != 0:
                        nb_check_subcellIdFailure_OddSfn += 1
                        nb_check_KO += 1
                        rob.log(
                            'ERR: sfn{} slot{} startPrb{} numPrb{} subcellId:{}'.format(sfn, slot, startPrb, numOfPrb,
                                                                                        subcellId))
            else:
                if subcellId != 0:
                    nb_check_subcellIdFailure_EvenSfn += 1
                    nb_check_KO += 1
                    rob.log('ERR: sfn{} slot{} startPrb{} numPrb{} subcellId:{}'.format(sfn, slot, startPrb, numOfPrb,
                                                                                        subcellId))

    rob.log('nb_check={}, nb_check_OK={}, nb_check_KO={}'.format(nb_check, nb_check_OK, nb_check_KO))
    rob.log('nb_check_startPrb_Failure={}'.format(nb_check_startPrbFailure))
    rob.log('nb_check_numOfPrb_Failure={}'.format(nb_check_numOfPrbFailure))
    rob.log('nb_check_subcellIdFailure={}'.format(nb_check_subcellIdFailure))
    rob.log('nb_check_subcellIdFailure_OddSfn={}'.format(nb_check_subcellIdFailure_OddSfn))
    rob.log('nb_check_subcellIdFailure_EvenSfn={}'.format(nb_check_subcellIdFailure_EvenSfn))

    assert nb_check_startPrbFailure < 1, "Error about startPrb, times={}".format(nb_check_startPrbFailure)
    assert nb_check_numOfPrbFailure < 1, "Error about numOfPrb, times={}".format(nb_check_numOfPrbFailure)
    assert nb_check_subcellIdFailure < 1, "Error about subcellId, times={}".format(nb_check_subcellIdFailure)
    assert nb_check_subcellIdFailure_OddSfn < 1, "Error about subcellId for odd sfn, times={}".format(
        nb_check_subcellIdFailure_OddSfn)
    assert nb_check_subcellIdFailure_EvenSfn < 1, "Error about subcellId for even sfn, times={}".format(
        nb_check_subcellIdFailure_EvenSfn)
    assert nb_check_OK > 0, "Assert: nb_check_OK is none"


def check_slot_for_ulData_PUSCHreceiveReq_TCJ005_TCJ004_prachConfig_93_1Ue_2beams_2subcells(pdml_name):
    input_file = open(pdml_name)
    # Define the regex for the interesting lines
    # re_slot_type_req = re.compile(r'uldata_pucchreceivereq.([A-Za-z]+).+ show="([0-9A-Fa-fx]+)"')
    re_sfn = re.compile(r'UlData_PuschReceiveReq.PuschReceiveReq.sfn.+ show="(0x[0-9A-Fa-f]+)"')
    re_slot = re.compile(r'UlData_PuschReceiveReq.PuschReceiveReq.slot.+ show="(0x[0-9A-Fa-f]+)"')
    # case pucch :
    # re_startPrb = re.compile(r'UlData_PuschReceiveReq.puschResources_item_85.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_startPrb = re.compile(r'UlData_PuschReceiveReq.grants_item_15.startPrb.+ show="(0x[0-9A-Fa-f]+)"')
    # case pucch :
    # re_numOfPrb = re.compile(r'UlData_PuschReceiveReq.puschResources_item_85.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_numOfPrb = re.compile(r'UlData_PuschReceiveReq.grants_item_15.numOfPrb.+ show="(0x[0-9A-Fa-f]+)"')
    re_subcellId = re.compile(r'UlData_PuschReceiveReq.subcells_item_3.subcellId.+ show="(0x[0-9A-Fa-f]+)"')

    # check = False
    slot = 0
    sfn = 0
    startPrb = 0
    subcellId = 0
    numOfPrb = 0
    numOfSymbols = 0
    firstSymbol = 0
    nb_line = 0
    nb_check = 0
    nb_check_OK = 0
    nb_check_KO = 0
    nb_check_startPrbFailure = 0
    nb_check_numOfPrbFailure = 0
    nb_check_subcellIdFailure = 0
    nb_check_subcellIdFailure_OddSfn = 0
    nb_check_subcellIdFailure_EvenSfn = 0

    # For each packet
    for line in input_file:
        nb_line += 1
        # Extract the useful data in the line
        group_list = re_sfn.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            sfn = int(data_value, 16)

        group_list = re_slot.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            slot = int(data_value, 16)

        group_list = re_startPrb.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            startPrb = int(data_value, 16)

        group_list = re_subcellId.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            subcellId = int(data_value, 16)

        group_list = re_numOfPrb.search(line)
        # If something has been found
        if group_list:
            data_value = group_list.groups()[0]
            numOfPrb = int(data_value, 16)

            if sfn % 2 == 1:
                if slot == 19:
                    _error_found = 0
                    # startPrb is : 12 + 0
                    if startPrb != 12:
                        nb_check_startPrbFailure += 1
                        _error_found = 1
                    # numPrb is: 273 - 12 = 261
                    if numOfPrb != 261:
                        nb_check_numOfPrbFailure += 1
                        _error_found = 1
                    # sucellId is: 1
                    if subcellId != 1:
                        nb_check_subcellIdFailure += 1
                        _error_found = 1

                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                    else:
                        nb_check_KO += 1
                        rob.log(
                            'ERR: sfn{} slot{} startPrb{} numPrb{} subcellId{}'.format(sfn, slot, startPrb, numOfPrb,
                                                                                       subcellId))
                elif slot == 9:
                    _error_found = 0
                    # startPrb is : 12 + 0
                    if startPrb != 12:
                        nb_check_startPrbFailure += 1
                        _error_found = 1
                    # numPrb is: 273 - 12 = 261
                    if numOfPrb != 261:
                        nb_check_numOfPrbFailure += 1
                        _error_found = 1
                    # sucellId is: 1
                    if subcellId != 0:
                        nb_check_subcellIdFailure += 1
                        _error_found = 1
                    nb_check += 1
                    # print error for debug
                    if _error_found == 0:
                        nb_check_OK += 1
                    else:
                        nb_check_KO += 1
                        rob.log('ERR: sfn{} slot{} startPrb:{} numPrb:{} subcellId:{}'.format(sfn, slot, startPrb,
                                                                                              numOfPrb, subcellId))
                else:
                    if subcellId != 0:
                        nb_check_subcellIdFailure_OddSfn += 1
                        nb_check_KO += 1
                        rob.log(
                            'ERR: sfn{} slot{} startPrb{} numPrb{} subcellId{}'.format(sfn, slot, startPrb, numOfPrb,
                                                                                       subcellId))
            else:
                if subcellId != 0:
                    nb_check_subcellIdFailure_EvenSfn += 1
                    nb_check_KO += 1
                    rob.log('ERR: sfn{} slot{} startPrb{} numPrb{} subcellId{}'.format(sfn, slot, startPrb, numOfPrb,
                                                                                       subcellId))

    rob.log('nb_check={}, nb_check_OK={}, nb_check_KO={}'.format(nb_check, nb_check_OK, nb_check_KO))
    rob.log('nb_check_startPrb_Failure={}'.format(nb_check_startPrbFailure))
    rob.log('nb_check_numOfPrb_Failure={}'.format(nb_check_numOfPrbFailure))
    rob.log('nb_check_subcellIdFailure={}'.format(nb_check_subcellIdFailure))
    rob.log('nb_check_subcellIdFailure_OddSfn={}'.format(nb_check_subcellIdFailure_OddSfn))
    rob.log('nb_check_subcellIdFailure_EvenSfn={}'.format(nb_check_subcellIdFailure_EvenSfn))

    assert nb_check_startPrbFailure < 1, "Error about startPrb, times={}".format(nb_check_startPrbFailure)
    assert nb_check_numOfPrbFailure < 1, "Error about numOfPrb, times={}".format(nb_check_numOfPrbFailure)
    assert nb_check_subcellIdFailure < 1, "Error about subcellId, times={}".format(nb_check_subcellIdFailure)
    assert nb_check_subcellIdFailure_OddSfn < 1, "Error about subcellId for odd sfn, times={}".format(
        nb_check_subcellIdFailure_OddSfn)
    assert nb_check_subcellIdFailure_EvenSfn < 1, "Error about subcellId for even sfn, times={}".format(
        nb_check_subcellIdFailure_EvenSfn)
    assert nb_check_OK > 0, "Assert: nb_check_OK is none"
