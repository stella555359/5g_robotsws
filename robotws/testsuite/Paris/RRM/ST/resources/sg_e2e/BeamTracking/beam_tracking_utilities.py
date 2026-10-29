import os
import binascii
import csv
import string

from robot.api import logger as logger

# csi-SSB-ResourceList
SSB_idx_1668 = ['4', '5', '6', '7', '12', '13', '14', '15', '20', '21', '22', '23', '28', '29', '30', '31', '36', '37',
                '38', '39', '44', '45', '46', '47', '52', '53', '54', '55', '60', '61', '62', '63']


def ue_beam_traking_controle(filepath, duration=5):
    '''
    This function return the detected serving beam SSB exceeding the duration in s
    @param duration:
    @type filepath:
    '''
    rBeamlst = []
    duration = duration
    with open(filepath) as csvfile:
        reader = csv.DictReader(csvfile)
        row = next(reader)
        beamid = row['Serving Beam SSB Index']
        timestamp = float(row['timestamp'])
        for row in reader:
            if beamid not in row['Serving Beam SSB Index']:
                newtimestamp = float(row['timestamp'])
                timestamp_diff = newtimestamp - timestamp
                logger.debug('beamid %s timestamp duration %s' % (beamid, timestamp_diff))
                if timestamp_diff > duration:
                    rBeamlst.append({beamid: str(timestamp_diff).format("#00")})
                beamid = row['Serving Beam SSB Index']
                timestamp = newtimestamp

    return (rBeamlst[1:-1])


def ue_log_beam_change_controle(filepath, detected_beams_num, beam_offset=0, ssb_id_list=None,
                                tst_duration_min=0.0, max_beamChange=200):
    ''' function to detect Beam Change procedure
    @param filepath:
    @param detected_beams_num:
    @param beam_offset:
    @param ssb_id_list:
    @param tst_duration_min:
    @type max_beamChange: int
    '''
    result = ''
    detected_beams_num = int(detected_beams_num)
    beam_offset = int(beam_offset)
    logger.info('************************ start beam tracking DEBUG ******************************')
    with open(filepath) as csvfile:
        reader = csv.DictReader(csvfile)
        estimation_offset = 1.5  # estimation offset > 1.5 dB due to mobile measurement.
        start = True
        ssb_idx = None
        old_serv_beam_id = None
        serv_beam_id = None
        serv_beam_rsrp = None
        best_beam_id = None
        uci_ssb_idx = []
        best_ssb_idx = {}
        beam_change_succ = 0
        beam_change_fail = 0
        wrong_beam_reported = 0
        number_of_beam_change = 0
        line = {}
        for row in reader:
            if bool(row['Serving SSB']) and row['Serving SSB'] != '65535' and row['Serving SSB'] != 'NA':
                serv_beam_id = row['Serving SSB']
                old_serv_beam_id = serv_beam_id
                start = True
                break
        if start:
            verify = False
            for row in reader:
                if not verify:
                    i = 0
                    if row['Report Quantity Bitmask'] == 'RSRP | SSB_INDEX':
                        if bool(row['SSBRI CRI']):
                            line = {'msg_id': row['msg_id'],
                                    'timestamp': row['timestamp']}
                            SSBRI_CRI = [int(x.replace("'", '').strip()) for x in
                                         row['SSBRI CRI'].split('[')[1].split(']')[0].split(',')]
                            uci_ssb_idx = [ssb_id_list[x] for x in SSBRI_CRI[:2]]
                            logger.debug('reported UCI BSSid {} ==> {} at timestamp: {} '.format(
                                SSBRI_CRI, uci_ssb_idx, line['timestamp']))
                            verify = True
                            ssb_idx = {}
                            best_ssb_idx = {}
                if verify and bool(row['Serving SSB']):
                    if i < detected_beams_num:
                        if i < 1:
                            serv_beam_id = row['Serving SSB']
                            if bool(ssb_id_list) and serv_beam_id not in ssb_id_list:
                                logger.info('Detected SSB index {} not in : {} at {}'.format(
                                    serv_beam_id, ssb_id_list, row['timestamp']))
                            if bool(best_beam_id):
                                if best_beam_id not in uci_ssb_idx:
                                    logger.info(
                                        'Reported best uci beam {} are different to measured best beam {} '
                                        'at {}'.format(uci_ssb_idx[0], best_beam_id, row['timestamp']))
                                    wrong_beam_reported += 1
                                else:
                                    if best_beam_id != serv_beam_id and best_beam_rsrp > (
                                            serv_beam_rsrp + beam_offset + estimation_offset):
                                        Msg_Err = 'Detected beam change failure : \n'
                                        Msg_Err += '>>   Serving Beam Id is : {} with RSRP {}\n'.format(
                                            serv_beam_id, serv_beam_rsrp)
                                        Msg_Err += '>>   found better measured SSB Beam Id : {} ' \
                                                   'with RSRP {} \n'.format(best_beam_id, best_beam_rsrp)
                                        Msg_Err += '>>   RSRP delta {}\n'.format(best_beam_rsrp - serv_beam_rsrp)

                                        Msg_Err += '>>   ==> msg_id {} {}\n'.format(
                                            row['msg_id'], row['timestamp'])
                                        logger.debug(Msg_Err)
                                        beam_change_fail += 1
                                        if not bool(result):
                                            result = 'Failed, refer to log debug file'
                                    else:
                                        beam_change_succ += 1

                        ssb_idx.update({row['SSB Index']: float(row['NR2NR Filtered Tx Beam RSRP L3'])})
                        if i == detected_beams_num - 1:
                            verify = False
                            if serv_beam_id != old_serv_beam_id:
                                number_of_beam_change += 1
                                old_serv_beam_id = serv_beam_id
                            if serv_beam_id in ssb_idx.keys():
                                serv_beam_rsrp = ssb_idx[serv_beam_id]
                            else:
                                logger.info('SSB id {} not in mesaured ML1 list {} at timestamp: {}'.format(
                                    serv_beam_id, ssb_idx, row['timestamp']))
                            for id, rsrp in ssb_idx.items():
                                if rsrp > serv_beam_rsrp + beam_offset:
                                    best_ssb_idx.update({id: rsrp})
                            if bool(best_ssb_idx):
                                best_beam_id = max(best_ssb_idx, key=best_ssb_idx.get)
                                best_beam_rsrp = best_ssb_idx[best_beam_id]
                                # logger.info(
                                # serv_beam_id, serv_beam_rsrp, best_ssb_idx, row['msg_id'], row['date_time'])
                            else:
                                best_beam_rsrp = serv_beam_rsrp
                                best_beam_id = serv_beam_id
                        i += 1
            logger.info('real test duration: {}s'.format(float(line['timestamp'])))
            logger.info('test duration minimum admitted: {}s'.format(float(tst_duration_min)))

            if float(line['timestamp']) < float(tst_duration_min):
                Msg_Err = 'Error Occurred Test duration not reached : \n'
                Msg_Err += '>>   Expected test duration is : {}s \n'.format(tst_duration_min)
                Msg_Err += '>>   Real test duration is : {}s \n'.format(line['timestamp'])
                raise AssertionError(Msg_Err)

    logger.info('Total number of times the beam has changed : {}'.format(number_of_beam_change))
    logger.info('Total number of times of failed beam change procedure: {}'.format(beam_change_fail))
    logger.info('Total number of times of succeed of procedure: {}'.format(beam_change_succ))
    # logger.info('Total number of times of reported UCI are different to measured beam: {}'.format(
    #    wrong_beam_reported))

    logger.info('************************ end beam tracking DEBUG ******************************')
    if beam_change_fail / (beam_change_succ + beam_change_fail) > 0.0125 \
            and (2 < number_of_beam_change < max_beamChange):
        return 'Test Failed, please refer to Debug.log'

    return ''


def L1L2_beam_tracking(filepath, beam_offset=0, ssbidx=[],
                       tst_duration_min=0.0, min_beamChange=2, max_beamChange=200):
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

    ssbidx = map(str, ssbidx)
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
            # if check is True and 'DlData_PdcchSendReq' in row['_ws.col.Info']:
            if 'DlData_PdcchSendReq' in row[columns['Info']]:
                check = False
                BeamId = str(int(row[columns['beamId']], 16))
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
                    logger.info('error reported UCI BeamIdx are {} and BeamId is {}'.format(
                        [primaryBeamIdx, seconderBeamIdx], BeamId
                    ))
                    beam_tracking_procedure_fail += 1
                elif BeamId != primaryBeamIdx and (seconderBeamRSRP > beam_offset):
                    logger.info(
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
                        logger.info('beamId change from {} ==> {}'.format(old_BeamId,
                                                                          BeamId))
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
