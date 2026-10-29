#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
"""
import binascii
import csv

from robot.api import logger as logger


def L1L2_beam_tracking(filepath, beam_offset=0, ssbidx=[],
                       tst_duration_min=0.0, min_beamChange=4, max_beamChange=200):
    """

    @param filepath:
    @param beam_offset:
    @param ssbidx:
    @param tst_duration_min:
    @param min_beamChange:
    @type max_beamChange:
    The csv should be formated as below :
         column_0 _ws.col.Info
         column_1 frame.time_epoch
         column_2 DlData_PdcchSendReq.PdcchSendReq.sfn
         column_3 DlData_PdcchSendReq.PdcchSendReq.slot
         column_4 UlData_PucchReceiveReq.PucchReceiveReq.sfn
         column_5 UlData_PucchReceiveReq.PucchReceiveReq.slot
         column_6 UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn
         column_7 UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot
         column_8 DlData_PdcchSendReq.PdcchSendReq.beamId
         column_9 UlData_PucchReceiveReq.pucchResources_item_85.numOfBitsOfUciInformation
         column_10 UlData_PucchReceiveReq.pucchResources_item_85.nANPucch
         column_11 UlData_PucchReceiveRespPs.uciBits.uciBits
    """
    headers = ['Info', 'time_epoch', 'PdcchSendReq.sfn', 'PdcchSendReq.slot', 'PucchReceiveReq.sfn',
               'PucchReceiveReq.slot', 'PucchReceiveRespPs.sfn', 'PucchReceiveRespPs.slot', 'beamId',
               'numOfBitsOfUciInformation', 'nANPucch', 'uciBits']

    # ssbidx = map(str, ssbidx)
    BitsOfUciInfo_pos = {}
    estimation_offset = 1.5
    beam_offset = int(beam_offset) + estimation_offset
    primaryBeamIdx = 0
    seconderBeamIdx = 0
    primaryBeamRSRP = 0
    seconderBeamRSRP = 0
    beam_tracking_procedure_succ = 0
    beam_tracking_procedure_fail = 0
    number_of_change_beam = 0
    number_of_change_beam_others = 0
    BeamId = -1
    old_BeamId = -1
    tst_duration = 0
    ssbidx = list(map(int, ssbidx))
    ssbidx_row = {x: 0 for x in ssbidx}
    ssbidx_others = {}
    with open(filepath, 'r') as csvfile:
        # skip error line before to load lines as cvs files.
        pos = csvfile.tell()
        line = csvfile.readline()
        while bool(line) and '_ws.col.Info' not in line:
            pos = csvfile.tell()
            line = csvfile.readline()
        csvfile.seek(pos)
        reader = csv.DictReader(csvfile)
        columns = {}
        for i, col in enumerate(reader.fieldnames):
            columns.update({headers[i]: col})
        for row in reader:
            if 'UlData_PucchReceiveReq' in row[columns['Info']]:
                numOfBitsOfUciInfo = row[columns['numOfBitsOfUciInformation']]
                nANPucch = row[columns['nANPucch']]
                if (int(numOfBitsOfUciInfo, 16) - int(nANPucch, 16)) == 21:
                    BitsOfUciInfo_pos.update({row[columns['PucchReceiveReq.sfn']]: row[
                        columns['PucchReceiveReq.slot']]})

        csvfile.seek(pos)
        # logger.info(BitsOfUciInfo_pos)
        reader = csv.DictReader(csvfile)
        check = False
        sfn = 0
        for row in reader:
            if not bool(tst_duration):
                tst_duration = float(row[columns['time_epoch']])
            if bool(row[columns['beamId']]):
                BeamId = str(int(row[columns['beamId']], 16))
            # if check is False and 'UlData_PucchReceiveRespPs' in row['_ws.col.Info']:

            if 'UlData_PucchReceiveRespPs' in row['_ws.col.Info']:
                sfn = row[columns['PucchReceiveRespPs.sfn']]
                slot = row[columns['PucchReceiveRespPs.slot']]
                old_BeamId = BeamId
                if sfn in BitsOfUciInfo_pos.keys() and BitsOfUciInfo_pos[sfn] == slot:
                    uciBits = row[columns['uciBits']]
                    primaryBeamIdx, seconderBeamIdx, primaryBeamRSRP, seconderBeamRSRP = get_uci_details_2_SSB_number(
                        uciBits)
                    check = True
            # if check and 'DlData_PdcchSendReq' in row['_ws.col.Info']:
            if 'DlData_PdcchSendReq' in row[columns['Info']]:
                check = False
                BeamId = int(row[columns['beamId']], 16)
                ssb = BeamId
                if old_BeamId == -1:
                    old_BeamId = BeamId
                if ssb in ssbidx:
                    ssbidx_row[ssb] += 1
                else:
                    if ssb in ssbidx_others.keys():
                        ssbidx_others[ssb] += 1
                    else:
                        ssbidx_others.update({ssb: 1})
                if BeamId not in [primaryBeamIdx, seconderBeamIdx] and primaryBeamIdx != seconderBeamIdx:
                    logger.trace('error reported UCI BeamIdx are {} and BeamId is {}'.format(
                        [primaryBeamIdx, seconderBeamIdx], BeamId
                    ))
                    beam_tracking_procedure_fail += 1
                elif BeamId != primaryBeamIdx and (seconderBeamRSRP > beam_offset):
                    logger.trace(
                        'error reported UCI BeamIdx {} is different to best reported BeamId {} [sfn: {} {}]'.format(
                            BeamId, primaryBeamIdx, sfn,
                            row[columns['PdcchSendReq.sfn']]
                        ))
                    beam_tracking_procedure_fail += 1
                else:
                    beam_tracking_procedure_succ += 1
                    if BeamId != old_BeamId:
                        if BeamId in ssbidx:
                            number_of_change_beam += 1
                        else:
                            number_of_change_beam_others += 1
                        logger.debug('beamId change from {} ==> {}'.format(old_BeamId, BeamId))
                old_BeamId = BeamId

        tst_duration = float(row[columns['time_epoch']]) - tst_duration

        logger.info('test duration {:.2f}s'.format(tst_duration))
        logger.info('number of change on tested beams %s' % number_of_change_beam)
        logger.info('number of change on other beams %s' % number_of_change_beam_others)
        logger.info('beam tracking procedure succ %s' % beam_tracking_procedure_succ)
        logger.info('beam tracking procedure fail %s' % beam_tracking_procedure_fail)
        logger.info('ssbidx row distribution %s' % ssbidx_row)
        logger.info('ssbidx others rows distribution  %s' % ssbidx_others)

        logger.info('************************ beam tracking check ******************************')

        if tst_duration < float(tst_duration_min):
            Msg_Err = 'Error Occurred Test duration not reached : \n'
            Msg_Err += '>>   Expected test duration is : {}s \n'.format(tst_duration_min)
            Msg_Err += '>>   Real test duration is : {:.2f}s \n'.format(tst_duration)
            raise AssertionError(Msg_Err)

        if beam_tracking_procedure_succ > 0 and (
                beam_tracking_procedure_fail / beam_tracking_procedure_succ) > 0.0125:
            Msg_Err = 'Error Occurred Beam tracking Failed procedure : \n'
            Msg_Err += '>>   Beam Tracking Failed procedure is : {} \n'.format(beam_tracking_procedure_fail)
            Msg_Err += '>>   Beam Tracking success procedure is : {} \n'.format(beam_tracking_procedure_succ)
            raise AssertionError(Msg_Err)

        if int(min_beamChange) > number_of_change_beam:
            Msg_Err = 'Error Occurred Number of Beam change Failed  : \n'
            Msg_Err += '>>   Beam change number is : {} \n'.format(number_of_change_beam)
            Msg_Err += '>>   Should be upper then : {} \n'.format(min_beamChange)
            raise AssertionError(Msg_Err)

        if number_of_change_beam > int(max_beamChange):
            Msg_Err = 'Error Occurred Number of Beam change Failed  : \n'
            Msg_Err += '>>   Beam change number is : {} \n'.format(number_of_change_beam)
            Msg_Err += '>>   Should be lower then : {} \n'.format(max_beamChange)
            raise AssertionError(Msg_Err)

        if number_of_change_beam_others > number_of_change_beam:
            Msg_Err = 'Error Occurred Number of Beam change Failed  : \n'
            Msg_Err += '>>   Beam change number on the test row is : {} \n'.format(number_of_change_beam)
            Msg_Err += '>>   Beam change number on others row is : {} \n'.format(number_of_change_beam_others)
            raise AssertionError(Msg_Err)

        if sum(ssbidx_row.values()) < sum(ssbidx_others.values()):
            Msg_Err = 'Error Occurred Number of Beam Tracking Failed  : \n'
            Msg_Err += '>>   Distribution of reported tested Beams is : {} \n'.format(ssbidx_row)
            Msg_Err += '>>   vs distribution of reported others Beams is : {} \n'.format(ssbidx_others)
            raise AssertionError(Msg_Err)


def L1L2_beam_tracking_list(filepaths, beam_offset=0, ssbidx=[],
                            tst_duration_min=0.0, min_beamChange=4, max_beamChange=200):
    """

    @param filepath:
    @param beam_offset:
    @param ssbidx:
    @param tst_duration_min:
    @param min_beamChange:
    @type max_beamChange:
    The csv should be formated as below :
         column_0 _ws.col.Info
         column_1 frame.time_epoch
         column_2 DlData_PdcchSendReq.PdcchSendReq.sfn
         column_3 DlData_PdcchSendReq.PdcchSendReq.slot
         column_4 UlData_PucchReceiveReq.PucchReceiveReq.sfn
         column_5 UlData_PucchReceiveReq.PucchReceiveReq.slot
         column_6 UlData_PucchReceiveRespPs.PucchReceiveRespPs.sfn
         column_7 UlData_PucchReceiveRespPs.PucchReceiveRespPs.slot
         column_8 DlData_PdcchSendReq.PdcchSendReq.beamId
         column_9 UlData_PucchReceiveReq.pucchResources_item_85.numOfBitsOfUciInformation
         column_10 UlData_PucchReceiveReq.pucchResources_item_85.nANPucch
         column_11 UlData_PucchReceiveRespPs.uciBits.uciBits
    """
    headers = ['Info', 'time_epoch', 'PdcchSendReq.sfn', 'PdcchSendReq.slot', 'PucchReceiveReq.sfn',
               'PucchReceiveReq.slot', 'PucchReceiveRespPs.sfn', 'PucchReceiveRespPs.slot', 'beamId',
               'numOfBitsOfUciInformation', 'nANPucch', 'uciBits']

    # ssbidx = map(str, ssbidx)
    BitsOfUciInfo_pos = {}
    estimation_offset = 1.5
    beam_offset = int(beam_offset) + estimation_offset
    primaryBeamIdx = 0
    seconderBeamIdx = 0
    primaryBeamRSRP = 0
    seconderBeamRSRP = 0
    beam_tracking_procedure_succ = 0
    beam_tracking_procedure_fail = 0
    number_of_change_beam = 0
    number_of_change_beam_others = 0
    BeamId = -1
    old_BeamId = -1
    ssbidx = list(map(int, ssbidx))
    ssbidx_row = {x: 0 for x in ssbidx}
    ssbidx_others = {}
    all_elapsed_time = 0
    for filepath in filepaths:
        with open(filepath, 'r') as csvfile:
            # skip error line before to load lines as cvs files.
            tst_duration = 0
            pos = csvfile.tell()
            line = csvfile.readline()
            while bool(line) and '_ws.col.Info' not in line:
                pos = csvfile.tell()
                line = csvfile.readline()
            csvfile.seek(pos)
            reader = csv.DictReader(csvfile)
            columns = {}
            for i, col in enumerate(reader.fieldnames):
                columns.update({headers[i]: col})
            for row in reader:
                if 'UlData_PucchReceiveReq' in row[columns['Info']]:
                    numOfBitsOfUciInfo = row[columns['numOfBitsOfUciInformation']]
                    nANPucch = row[columns['nANPucch']]
                    if (int(numOfBitsOfUciInfo, 16) - int(nANPucch, 16)) == 21:
                        BitsOfUciInfo_pos.update({row[columns['PucchReceiveReq.sfn']]: row[
                            columns['PucchReceiveReq.slot']]})

            csvfile.seek(pos)
            # logger.info(BitsOfUciInfo_pos)
            reader = csv.DictReader(csvfile)
            check = False
            sfn = 0
            for row in reader:
                if not bool(tst_duration):
                    tst_duration = float(row[columns['time_epoch']])
                if bool(row[columns['beamId']]):
                    BeamId = str(int(row[columns['beamId']], 16))
                # if check is False and 'UlData_PucchReceiveRespPs' in row['_ws.col.Info']:

                if 'UlData_PucchReceiveRespPs' in row['_ws.col.Info']:
                    sfn = row[columns['PucchReceiveRespPs.sfn']]
                    slot = row[columns['PucchReceiveRespPs.slot']]
                    old_BeamId = BeamId
                    if sfn in BitsOfUciInfo_pos.keys() and BitsOfUciInfo_pos[sfn] == slot:
                        uciBits = row[columns['uciBits']]
                        (primaryBeamIdx, seconderBeamIdx,
                         primaryBeamRSRP, seconderBeamRSRP) = get_uci_details_2_SSB_number(uciBits)
                        check = True
                # if check and 'DlData_PdcchSendReq' in row['_ws.col.Info']:
                if 'DlData_PdcchSendReq' in row[columns['Info']]:
                    check = False
                    BeamId = int(row[columns['beamId']], 16)
                    ssb = BeamId
                    if old_BeamId == -1:
                        old_BeamId = BeamId
                    if ssb in ssbidx:
                        ssbidx_row[ssb] += 1
                    else:
                        if ssb in ssbidx_others.keys():
                            ssbidx_others[ssb] += 1
                        else:
                            ssbidx_others.update({ssb: 1})
                    if BeamId not in [primaryBeamIdx, seconderBeamIdx] and primaryBeamIdx != seconderBeamIdx:
                        logger.trace('error reported UCI BeamIdx are {} and BeamId is {}'.format(
                            [primaryBeamIdx, seconderBeamIdx], BeamId
                        ))
                        beam_tracking_procedure_fail += 1
                    elif BeamId != primaryBeamIdx and (seconderBeamRSRP > beam_offset):
                        logger.trace(
                            'error reported UCI BeamIdx {} is different '
                            'to best reported BeamId {} [sfn: {} {}]'.format(
                                BeamId, primaryBeamIdx, sfn,
                                row[columns['PdcchSendReq.sfn']]
                            ))
                        beam_tracking_procedure_fail += 1
                    else:
                        beam_tracking_procedure_succ += 1
                        if BeamId != old_BeamId:
                            if BeamId in ssbidx:
                                number_of_change_beam += 1
                            else:
                                number_of_change_beam_others += 1
                            logger.debug('beamId change from {} ==> {}'.format(old_BeamId, BeamId))
                    old_BeamId = BeamId

            tst_duration = float(row[columns['time_epoch']]) - tst_duration
            all_elapsed_time += tst_duration

    logger.info('test duration {:.2f}s'.format(all_elapsed_time))
    logger.info('number of change on tested beams %s' % number_of_change_beam)
    logger.info('number of change on other beams %s' % number_of_change_beam_others)
    logger.info('beam tracking procedure succ %s' % beam_tracking_procedure_succ)
    logger.info('beam tracking procedure fail %s' % beam_tracking_procedure_fail)
    logger.info('ssbidx row distribution %s' % ssbidx_row)
    logger.info('ssbidx others rows distribution  %s' % ssbidx_others)

    logger.info('************************ beam tracking check ******************************')

    if all_elapsed_time < float(tst_duration_min):
        Msg_Err = 'Error Occurred Test duration not reached : \n'
        Msg_Err += '>>   Expected test duration is : {}s \n'.format(tst_duration_min)
        Msg_Err += '>>   Real test duration is : {:.2f}s \n'.format(all_elapsed_time)
        raise AssertionError(Msg_Err)

    if beam_tracking_procedure_succ > 0 and (
            beam_tracking_procedure_fail / beam_tracking_procedure_succ) > 0.0125:
        Msg_Err = 'Error Occurred Beam tracking Failed procedure : \n'
        Msg_Err += '>>   Beam Tracking Failed procedure is : {} \n'.format(beam_tracking_procedure_fail)
        Msg_Err += '>>   Beam Tracking success procedure is : {} \n'.format(beam_tracking_procedure_succ)
        raise AssertionError(Msg_Err)

    if int(min_beamChange) > number_of_change_beam:
        Msg_Err = 'Error Occurred Number of Beam change Failed  : \n'
        Msg_Err += '>>   Beam change number is : {} \n'.format(number_of_change_beam)
        Msg_Err += '>>   Should be upper then : {} \n'.format(min_beamChange)
        raise AssertionError(Msg_Err)

    if number_of_change_beam > int(max_beamChange):
        Msg_Err = 'Error Occurred Number of Beam change Failed  : \n'
        Msg_Err += '>>   Beam change number is : {} \n'.format(number_of_change_beam)
        Msg_Err += '>>   Should be lower then : {} \n'.format(max_beamChange)
        raise AssertionError(Msg_Err)

    if number_of_change_beam_others > number_of_change_beam:
        Msg_Err = 'Error Occurred Number of Beam change Failed  : \n'
        Msg_Err += '>>   Beam change number on the test row is : {} \n'.format(number_of_change_beam)
        Msg_Err += '>>   Beam change number on others row is : {} \n'.format(number_of_change_beam_others)
        raise AssertionError(Msg_Err)

    if sum(ssbidx_row.values()) < sum(ssbidx_others.values()):
        Msg_Err = 'Error Occurred Number of Beam Tracking Failed  : \n'
        Msg_Err += '>>   Distribution of reported tested Beams is : {} \n'.format(ssbidx_row)
        Msg_Err += '>>   vs distribution of reported others Beams is : {} \n'.format(ssbidx_others)
        raise AssertionError(Msg_Err)


def get_uci_details_2_SSB_number(uciBits):
    """
    function to decode 2 SSB UCI informations
    @param hex_string: hex string input exp: d6770800000000
    @return primaryBeamIdx, seconderBeamIdx, primaryBeamRSRP, seconderBeamRSRP of reported SSB
    """
    uciBits = uciBits.replace(":", "")
    bytes_string = binascii.unhexlify(uciBits)
    binary_string = ''.join(['{0:08b}'.format(ord(x)) for x in bytes_string])
    primaryBeamIdx = int(binary_string[:5], 2)
    seconderBeamIdx = int(binary_string[5:10], 2)
    primaryBeamRSRP = int(binary_string[10:17], 2)
    seconderBeamRSRP = int(binary_string[17:21], 2)

    return primaryBeamIdx, seconderBeamIdx, primaryBeamRSRP, seconderBeamRSRP
