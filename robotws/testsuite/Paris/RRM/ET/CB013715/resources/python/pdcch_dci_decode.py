import csv
import os
import json
import sys
import traceback
from decimal import Decimal, ROUND_HALF_UP
from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
import logging

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tools import log_begin_end_func_name


rbi = BuiltIn()


DCI_1_1_field_name = ['PdcchDciData.rnti', 'PdcchDciData.dciFromat', 'PdcchDciData.Vision',
                      'PdcchDciData.bwPartIndicator', 'PdcchDciData.shortMsgIndicator', 'PdcchDciData.shortMessage',
                      'PdcchDciData.fdResourceAssignment', 'PdcchDciData.tdResourceAssignment',
                      'PdcchDciData.vrbToPrbMapping', 'PdcchDciData.mcs', 'PdcchDciData.ndi',
                      'PdcchDciData.tbScaling', 'PdcchDciData.redundancyVersion',
                      'PdcchDciData.harqProcessNumber', 'PdcchDciData.systemInfoIndicator',
                      'PdcchDciData.downlinkAssigmentIndex', 'PdcchDciData.tpcCommandForPucch',
                      'PdcchDciData.precodingInformationAndNumbersOfLayers',
                      'PdcchDciData.pucchResourceIndication', 'PdcchDciData.pdschToHarqFeedbackTime',
                      'PdcchDciData.antennaPort', 'PdcchDciData.srsRequest', 'PdcchDciData.csiRequest',
                      'PdcchDciData.ptrsDmrs', 'PdcchDciData.betaOffsetindicator',
                      'PdcchDciData.dmrsSequenceInit', 'PdcchDciData.ulSulindicator',
                      'PdcchDciData.freqHoppingFlag', 'PdcchDciData.PdcchMonitoringAdaptationInd']


def DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict['PdcchDciData.Vision'] = int(dciDynamicParamsLength_reverse[28: 32][::-1], 2)
    VisionCtrl = temp_field_dict['PdcchDciData.Vision']
    dci11_dciFormat = dciBitStream_[pos: pos + 1]
    pos += 1
    bwPartIndicator_length = int(dciDynamicParamsLength_reverse[0: 2][::-1], 2)
    if bwPartIndicator_length:
        bwPartIndicator = dciBitStream_[pos: pos + bwPartIndicator_length]
        temp_field_dict['PdcchDciData.bwPartIndicator'] = int(bwPartIndicator, 2)
    pos += bwPartIndicator_length
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[2: 7][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    tdResourceAssignment_length = int(dciDynamicParamsLength_reverse[7: 10][::-1], 2)
    if tdResourceAssignment_length:
        temp_field_dict['PdcchDciData.tdResourceAssignment'] = \
            int(dciBitStream_[pos: pos + tdResourceAssignment_length], 2)
    pos = pos + tdResourceAssignment_length
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.ndi'] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    temp_field_dict['PdcchDciData.redundancyVersion'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.harqProcessNumber'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    downlinkAssigmentIndex_length = \
        int(dciDynamicParamsLength_reverse[10: 13][::-1], 2)
    if downlinkAssigmentIndex_length:
        temp_field_dict['PdcchDciData.downlinkAssigmentIndex'] = \
            int(dciBitStream_[pos: pos + downlinkAssigmentIndex_length], 2)
    pos = pos + downlinkAssigmentIndex_length
    temp_field_dict['PdcchDciData.tpcCommandForPucch'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.pucchResourceIndication'] = int(dciBitStream_[pos: pos + 3], 2)
    pos = pos + 3
    temp_field_dict['PdcchDciData.pdschToHarqFeedbackTime'] = int(dciBitStream_[pos: pos + 3], 2)
    pos = pos + 3
    if VisionCtrl:
        antennaPort_length = int(dciDynamicParamsLength_reverse[13: 16][::-1], 2)
        if antennaPort_length:
            temp_field_dict['PdcchDciData.antennaPort'] = int(dciBitStream_[pos: pos + antennaPort_length], 2)
        pos = pos + antennaPort_length
    else:
        temp_field_dict['PdcchDciData.antennaPort'] = int(dciBitStream_[pos: pos + 4], 2)
        pos = pos + 4
    temp_field_dict['PdcchDciData.srsRequest'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.dmrsSequenceInit'] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    PdcchMonitorAdapInd_length = int(dciDynamicParamsLength_reverse[16: 17][::-1], 2)
    if PdcchMonitorAdapInd_length:
        temp_field_dict['PdcchDciData.PdcchMonitoringAdaptationInd'] = \
            int(dciBitStream_[pos: pos + PdcchMonitorAdapInd_length], 2)
    return temp_field_dict


def Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0: 5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos += fdResourceAssignment_length
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.vrbToPrbMapping'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.tbScaling'] = int(dciBitStream_[pos: pos + 2], 2)
    return temp_field_dict


def Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    dci10_dciFormat = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0: 5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos += fdResourceAssignment_length
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = \
        int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.vrbToPrbMapping'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.ndi'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.redundancyVersion'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.harqProcessNumber'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.downlinkAssigmentIndex'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.tpcCommandForPucch'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.pucchResourceIndication'] = int(dciBitStream_[pos: pos + 3], 2)
    pos = pos + 3
    temp_field_dict['PdcchDciData.pdschToHarqFeedbackTime'] = int(dciBitStream_[pos: pos + 3], 2)
    return temp_field_dict


def Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0: 5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos += fdResourceAssignment_length
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.vrbToPrbMapping'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.redundancyVersion'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.systemInfoIndicator'] = int(dciBitStream_[pos: pos + 1], 2)
    return temp_field_dict


def Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict['PdcchDciData.shortMsgIndicator'] = int(dciBitStream_[pos: pos + 2], 2)
    pos += 2
    temp_field_dict['PdcchDciData.shortMessage'] = hex(int(dciBitStream_[pos: pos + 8], 2))
    pos = pos + 8
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0: 5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.vrbToPrbMapping'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.tbScaling'] = int(dciBitStream_[pos: pos + 2], 2)
    return temp_field_dict


def DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict['PdcchDciData.Vision'] = int(dciDynamicParamsLength_reverse[28: 32][::-1], 2)
    VisionCtrl = temp_field_dict['PdcchDciData.Vision']
    dci01_dciFormat = dciBitStream_[pos: pos + 1]
    pos += 1
    bwPartIndicator_length = int(dciDynamicParamsLength_reverse[0: 2][::-1], 2)
    if bwPartIndicator_length:
        bwPartIndicator = dciBitStream_[pos: pos + bwPartIndicator_length]
        temp_field_dict['PdcchDciData.bwPartIndicator'] = int(bwPartIndicator, 2)
    pos += bwPartIndicator_length
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[2: 7][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    tdResourceAssignment_length = int(dciDynamicParamsLength_reverse[7: 10][::-1], 2)
    if tdResourceAssignment_length:
        temp_field_dict['PdcchDciData.tdResourceAssignment'] = \
            int(dciBitStream_[pos: pos + tdResourceAssignment_length], 2)
    pos = pos + tdResourceAssignment_length
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.ndi'] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    temp_field_dict['PdcchDciData.redundancyVersion'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.harqProcessNumber'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.downlinkAssigmentIndex'] = \
        int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.tpcCommandForPucch'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    precodingInformationAndNumbersOfLayers_length = int(dciDynamicParamsLength_reverse[10: 13][::-1], 2)
    if precodingInformationAndNumbersOfLayers_length:
        temp_field_dict['PdcchDciData.precodingInformationAndNumbersOfLayers'] = \
            int(dciBitStream_[pos: pos + precodingInformationAndNumbersOfLayers_length], 2)
    pos = pos + precodingInformationAndNumbersOfLayers_length
    if VisionCtrl:
        antennaPort_length = int(dciDynamicParamsLength_reverse[13: 16][::-1], 2)
        if antennaPort_length:
            temp_field_dict['PdcchDciData.antennaPort'] = int(dciBitStream_[pos: pos + antennaPort_length], 2)
        pos = pos + antennaPort_length
        temp_field_dict['PdcchDciData.srsRequest'] = int(dciBitStream_[pos: pos + 2], 2)
        pos = pos + 2
        csiRequest_length = int(dciDynamicParamsLength_reverse[16: 17][::-1], 2)
        if csiRequest_length:
            temp_field_dict['PdcchDciData.csiRequest'] = dciBitStream_[pos: pos + csiRequest_length]
        pos += csiRequest_length
        ptrsDmrs_length = int(dciDynamicParamsLength_reverse[17: 19][::-1], 2)
        if ptrsDmrs_length:
            temp_field_dict['PdcchDciData.ptrsDmrs'] = dciBitStream_[pos: pos + ptrsDmrs_length]
        pos += ptrsDmrs_length
        betaOffsetindicator_length = int(dciDynamicParamsLength_reverse[19: 21][::-1], 2)
        if betaOffsetindicator_length:
            temp_field_dict['PdcchDciData.betaOffsetindicator'] = dciBitStream_[pos: pos + betaOffsetindicator_length]
        pos += betaOffsetindicator_length
        dmrsSequenceInit_length = int(dciDynamicParamsLength_reverse[21: 22][::-1], 2)
        if dmrsSequenceInit_length:
            temp_field_dict['PdcchDciData.dmrsSequenceInit'] = \
                int(dciBitStream_[pos: pos + dmrsSequenceInit_length], 2)
        pos += dmrsSequenceInit_length
        temp_field_dict['PdcchDciData.ulSulindicator'] = dciBitStream_[pos: pos + 1]
        pos = pos + 1
        PdcchMonitorAdapInd_length = int(dciDynamicParamsLength_reverse[22: 23][::-1], 2)
        if PdcchMonitorAdapInd_length:
            temp_field_dict['PdcchDciData.PdcchMonitoringAdaptationInd'] = \
                int(dciBitStream_[pos: pos + PdcchMonitorAdapInd_length], 2)
    else:
        antennaPort_length = int(dciDynamicParamsLength_reverse[13: 15][::-1], 2)
        if antennaPort_length:
            temp_field_dict['PdcchDciData.antennaPort'] = int(dciBitStream_[pos: pos + antennaPort_length], 2)
        pos = pos + antennaPort_length
        temp_field_dict['PdcchDciData.srsRequest'] = int(dciBitStream_[pos: pos + 2], 2)
        pos = pos + 2
        csiRequest_length = int(dciDynamicParamsLength_reverse[15: 16][::-1], 2)
        if csiRequest_length:
            temp_field_dict['PdcchDciData.csiRequest'] = dciBitStream_[pos: pos + csiRequest_length]
        pos += csiRequest_length
        ptrsDmrs_length = int(dciDynamicParamsLength_reverse[16: 18][::-1], 2)
        if ptrsDmrs_length:
            temp_field_dict['PdcchDciData.ptrsDmrs'] = dciBitStream_[pos: pos + ptrsDmrs_length]
        pos += ptrsDmrs_length
        betaOffsetindicator_length = int(dciDynamicParamsLength_reverse[18: 20][::-1], 2)
        if betaOffsetindicator_length:
            temp_field_dict['PdcchDciData.betaOffsetindicator'] = dciBitStream_[pos: pos + betaOffsetindicator_length]
        pos += betaOffsetindicator_length
        dmrsSequenceInit_length = int(dciDynamicParamsLength_reverse[20: 21][::-1], 2)
        if dmrsSequenceInit_length:
            temp_field_dict['PdcchDciData.dmrsSequenceInit'] = \
                int(dciBitStream_[pos: pos + dmrsSequenceInit_length], 2)
        pos += dmrsSequenceInit_length
        temp_field_dict['PdcchDciData.ulSulindicator'] = dciBitStream_[pos: pos + 1]
    return temp_field_dict


def DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    dci00_dciFormat = dciBitStream_[0: 1]
    pos = pos + 1
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0: 5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
            hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = int(dciBitStream_[pos: pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.freqHoppingFlag'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.ndi'] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    temp_field_dict['PdcchDciData.redundancyVersion'] = dciBitStream_[pos: pos + 2]
    pos = pos + 2
    temp_field_dict['PdcchDciData.harqProcessNumber'] = int(dciBitStream_[pos: pos + 4], 2)
    return temp_field_dict


def Decode_PDCCH_Dciinfo(csv_filename):
    print('tti trace file name: ', csv_filename)
    with open(csv_filename, 'r') as csvfile:
        header = []
        reader = csv.DictReader(csvfile, delimiter=';')
        list_reader = list(reader)
        for fieldnames in reader.fieldnames:
            header.append(fieldnames)
            # print(fieldnames)
        # dlPdcchDciData.ueDciInfoList
        if 'dlPdcchDciData.ueDciInfoList' in header or 'ulPdcchDciData.ueDciInfoList' in header:
            print('tti trace format: excelcsv format with json data')
            newfile_header = header + DCI_1_1_field_name
            f = open(csv_filename.replace('.csv', '_dci_decode.csv'), mode='w', encoding='utf-8', newline='')
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header, delimiter=';')
            csv_writer.writeheader()
            for i_line in list_reader:
                data = i_line
                if 'dlPdcchDciData.ueDciInfoList' in header:
                    dci_info = i_line["dlPdcchDciData.ueDciInfoList"]
                elif "ulPdcchDciData.ueDciInfoList" in header:
                    dci_info = i_line["ulPdcchDciData.ueDciInfoList"]
                if dci_info != '':
                    dci_info = dci_info.replace('\'', '\"')
                    dci_info_list = json.loads(dci_info)
                    for loop_index in range(len(dci_info_list)):
                        # print(int(dci_info_list[loop_index]["dciBitStream"]))
                        dciBitStream = bin(int(dci_info_list[loop_index]["dciBitStream"]))
                        dciDynamicParamsLength = bin(int(dci_info_list[loop_index]["dciDynamicParamsLength"]))
                        dciPayloadLength = int(dci_info_list[loop_index]["dciPayloadLength"])
                        dci_format = dci_info_list[loop_index]["dciFormat"]
                        rnti = dci_info_list[loop_index]["rnti"]
                        dciBitStream_ = dciBitStream[2:].ljust(dciPayloadLength, "0").rjust(64, "0")
                        if dci_format == 'DL_11':
                            dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format in ('DL_10_MSG4',
                                            'DL_10_SMALLRRC',
                                            'DL_10_SRB0MSG',
                                            'DL_10_SRB1MSG',
                                            'DL_10_FORCE'):
                            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength,
                                                                       dciBitStream_,
                                                                       dciPayloadLength)
                        elif dci_format == 'DL_10_MSG2':
                            dci_dict = Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength,
                                                                dciBitStream_,
                                                                dciPayloadLength)
                        elif dci_format in ('DL_10_SIB1', 'DL_10_OSI'):
                            dci_dict = Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength,
                                                                 dciBitStream_,
                                                                 dciPayloadLength)
                        elif dci_format == 'DL_10_PAGING':
                            dci_dict = Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength,
                                                                   dciBitStream_,
                                                                   dciPayloadLength)
                        elif dci_format == 'UL_01':
                            dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format in ('UL_00', 'UL_00_FORCE'):
                            dci_dict = DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict['PdcchDciData.rnti'] = rnti
                        dci_dict['PdcchDciData.dciFromat'] = dci_format
                        data.update(dci_dict)
                        csv_writer.writerow(data)
                else:
                    csv_writer.writerow(data)
            f.close()
        elif 'ueDciInfoList' in header:
            print('tti trace format: new legacycsv format data split cell')
            newfile_header = header + DCI_1_1_field_name
            f = open(csv_filename.replace('.csv', '_dci_decode.csv'), mode='w', encoding='utf-8', newline='')
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
            csv_writer.writeheader()
            for i_line in list_reader:
                data = i_line
                if 'ueDciInfoList' in header:
                    dci_info = i_line["ueDciInfoList"]
                if dci_info != '':
                    dci_info = dci_info.replace('\'', '\"')
                    dci_info_list = json.loads(dci_info)
                    for loop_index in range(len(dci_info_list)):
                        dciBitStream = bin(int(dci_info_list[loop_index]["dciBitStream"]))
                        dciDynamicParamsLength = bin(int(dci_info_list[loop_index]["dciDynamicParamsLength"]))
                        dciPayloadLength = int(dci_info_list[loop_index]["dciPayloadLength"])
                        dci_format = dci_info_list[loop_index]["dciFormat"]
                        rnti = dci_info_list[loop_index]["rnti"]
                        dciBitStream_ = dciBitStream[2:].ljust(dciPayloadLength, "0").rjust(64, "0")
                        if dci_format == 'DL_11':
                            dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format in ('DL_10_MSG4',
                                            'DL_10_SMALLRRC',
                                            'DL_10_SRB0MSG',
                                            'DL_10_SRB1MSG',
                                            'DL_10_FORCE'):
                            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength,
                                                                       dciBitStream_,
                                                                       dciPayloadLength)
                        elif dci_format == 'DL_10_MSG2':
                            dci_dict = Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength,
                                                                dciBitStream_,
                                                                dciPayloadLength)
                        elif dci_format in ('DL_10_SIB1', 'DL_10_OSI'):
                            dci_dict = Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength,
                                                                 dciBitStream_,
                                                                 dciPayloadLength)
                        elif dci_format == 'DL_10_PAGING':
                            dci_dict = Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength,
                                                                   dciBitStream_,
                                                                   dciPayloadLength)
                        elif dci_format == 'UL_01':
                            dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format in ('UL_00', 'UL_00_FORCE'):
                            dci_dict = DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict['PdcchDciData.rnti'] = rnti
                        dci_dict['PdcchDciData.dciFromat'] = dci_format
                        data.update(dci_dict)
                        csv_writer.writerow(data)
                else:
                    csv_writer.writerow(data)
            f.close()
        elif 'dciBitStream' in header and 'type' in header:
            print('tti trace format: Gnb_logs convert old legacycsv format data split cell')
            newfile_header = header[:-1] + DCI_1_1_field_name
            f = open(csv_filename.replace('.csv', '_dci_decode.csv'), mode='w', encoding='utf-8', newline='')
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
            csv_writer.writeheader()
            for i_line in list_reader:
                data = i_line
                del data['']
                dci_format = i_line["dciFormat"]
                dciDynamicParamsLength = i_line["dciDynamicParamsLength"]
                dciPayloadLength = i_line["dciPayloadLength"]
                if dci_format and dciDynamicParamsLength and dciPayloadLength:
                    dciBitStream = bin(int(i_line["dciBitStream"]))
                    dciDynamicParamsLength = bin(int(dciDynamicParamsLength))
                    dciPayloadLength = int(dciPayloadLength)
                    dciBitStream_ = dciBitStream[2::].rjust(64, "0")
                    if dci_format == 'DL_11':
                        dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format == 'UL_01':
                        dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format in ('DL_10_MSG4',
                                        'DL_10_SMALLRRC',
                                        'DL_10_SRB0MSG',
                                        'DL_10_SRB1MSG',
                                        'DL_10_FORCE'):
                        dci_dict = Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength,
                                                                   dciBitStream_,
                                                                   dciPayloadLength)
                    elif dci_format == 'DL_10_MSG2':
                        dci_dict = Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength,
                                                            dciBitStream_,
                                                            dciPayloadLength)
                    elif dci_format in ('DL_10_SIB1', 'DL_10_OSI'):
                        dci_dict = Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength,
                                                             dciBitStream_,
                                                             dciPayloadLength)
                    elif dci_format == 'DL_10_PAGING':
                        dci_dict = Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength,
                                                               dciBitStream_,
                                                               dciPayloadLength)
                    else:
                        dci_dict = dict.fromkeys(DCI_1_1_field_name)
                    dci_dict['PdcchDciData.rnti'] = i_line["rnti"]
                    dci_dict['PdcchDciData.dciFromat'] = i_line["dciFormat"]
                    data.update(dci_dict)
                csv_writer.writerow(data)
            f.close()
        elif 'dciBitStream' in header and 'type' not in header:
            print('event csv DL UL same format')
            global pd
            pd = pandas_gate.install_and_import_pandas()
            df = pd.read_csv(csv_filename, low_memory=False, dtype=str)   # low_memory, big csv, dtype=str
            dcidata_index = df.columns.get_loc('dciPayloadLength') - 1
            rnti_index = df.columns.get_loc('rnti')
            repeated_headers = [col.split('.')[0] for col in df.columns[dcidata_index:] if '.' in col][1::]
            # Extract the column names containing . from the columns starting with dcidata_index,
            # and remove the numeric suffix after . to get the header of the repeated columns.
            new_rows = []  # Create an empty list to store new DataFrame rows
            for index, row in df.iterrows():
                new_row = {}
                for j in range(
                        dcidata_index):  # Add data before dcidata_index to the dictionary, skip the fifth column rnti
                    if j == rnti_index:  # Skip the rnti column
                        continue
                    new_row[df.columns[j]] = row.iloc[j]
                # Add the current row's data to the dictionary
                for k, header in enumerate(repeated_headers):
                    # Get the current column index
                    col_index = k + dcidata_index
                    # Get the current column value
                    value = row.iloc[col_index]
                    # Add the value to the dictionary using a unified column name
                    new_row[header] = value
                new_rows.append(new_row)
                # print(new_rows)
                # Iterate through repeated column groups, adding the repeated part's data to the new DataFrame row list
                for i in range(0, len(repeated_headers), 6):
                    # Get the current repeated column group's headers
                    current_headers = repeated_headers[i:i + 6]
                    # print(current_headers)
                    # Create a new dictionary to store the current row's data
                    new_row = {}
                    # Add the first seven columns' data to the dictionary, skip the fifth column
                    for j in range(dcidata_index):
                        if j == rnti_index:  # Skip the rnti column
                            continue
                        new_row[df.columns[j]] = row.iloc[j]
                    # Add the current repeated column group's data to the dictionary and modify the column names
                    for k, header in enumerate(current_headers):
                        # Get the current column index
                        col_index = k + i + dcidata_index
                        # Get the current column value
                        value = row.iloc[col_index]
                        # Add the value to the dictionary using a unified column name
                        new_row[header] = value
                    # Add the new dictionary to the new DataFrame row list
                    new_rows.append(new_row)
                    # print(new_rows)
            # Create a new DataFrame containing all new rows
            new_df = pd.DataFrame(new_rows)
            # print(new_df)
            # Adjust column order
            '''new_df = new_df[
                ['hfnTickCount', 'sfn', 'slot', 'emCoreId', 'lcrId', 'physCellId', 'rnti', 'dciPayloadLength',
                 'dciFormat', 'dciDynamicParamsLength', 'dciBitStream', 'dciTransmitPower']]'''
            new_df = new_df[new_df['rnti'].notna()]
            new_df.to_csv('new_event.csv', index=False)

            # open new event
            with open('new_event.csv', 'r') as eventcsv:
                header = []
                reader = csv.DictReader(eventcsv)
                list_reader = list(reader)
                for fieldnames in reader.fieldnames:
                    header.append(fieldnames)
                newfile_header = header + DCI_1_1_field_name
                # print(newfile_header)
                f = open(csv_filename.replace('.csv', '_dci_decode.csv'), mode='w', encoding='utf-8', newline='')
                csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
                csv_writer.writeheader()
                for i_line in list_reader:
                    data = i_line
                    # print(data)
                    dci_format = i_line["dciFormat"]
                    dciDynamicParamsLength = i_line["dciDynamicParamsLength"]
                    dciPayloadLength = i_line["dciPayloadLength"]
                    # print(dciDynamicParamsLength,dciDynamicParamsLength.split(".")[0])
                    if dci_format and dciDynamicParamsLength and dciPayloadLength:
                        dciBitStream = bin(int(i_line["dciBitStream"]))
                        dciDynamicParamsLength = bin(int(dciDynamicParamsLength.split(".")[0]))
                        # print(dciDynamicParamsLength)
                        dciPayloadLength = int(dciPayloadLength.split(".")[0])
                        dciBitStream_ = dciBitStream[2::].rjust(64, "0")
                        if dci_format == 'DL_11':
                            dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'UL_01':
                            dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format in ('DL_10_MSG4',
                                            'DL_10_SMALLRRC',
                                            'DL_10_SRB0MSG',
                                            'DL_10_SRB1MSG',
                                            'DL_10_FORCE'):
                            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength,
                                                                       dciBitStream_,
                                                                       dciPayloadLength)
                        elif dci_format == 'DL_10_MSG2':
                            dci_dict = Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength,
                                                                dciBitStream_,
                                                                dciPayloadLength)
                        elif dci_format in ('DL_10_SIB1', 'DL_10_OSI'):
                            dci_dict = Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength,
                                                                 dciBitStream_,
                                                                 dciPayloadLength)
                        elif dci_format == 'DL_10_PAGING':
                            dci_dict = Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength,
                                                                   dciBitStream_,
                                                                   dciPayloadLength)
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict['PdcchDciData.rnti'] = i_line["rnti"]
                        dci_dict['PdcchDciData.dciFromat'] = i_line["dciFormat"]
                        data.update(dci_dict)
                    csv_writer.writerow(data)
                f.close()
        else:
            print("ERROR format: Ttitrace has no PdcchDciData field!")
        print('Output file name: ', csv_filename.replace('.csv', '_dci_decode.csv'))


def main():
    logging.basicConfig(level=logging.DEBUG)
    try:
        print('tti trace starting DCI decoding...')
        csv_file_dl = '/home/ute/csamson/TRACES/filtered_dlPdcchDciData_ttitrace.csv'
        csv_file_ul = '/home/ute/csamson/TRACES/filtered_ulPdcchDciData_ttitrace.csv'
        path_to_ttitrace_dlfdsched_pkl = '/home/ute/csamson/TRACES/ttitrace_streaming_dlPdcchDciData.pkl'
        path_to_ttitrace_ulfdsched_pkl = '/home/ute/csamson/TRACES/ttitrace_streaming_ulPdcchDciData.pkl'
        if csv_file_dl:
            Decode_PDCCH_Dciinfo(csv_file_dl)
        else:
            Decode_PDCCH_Dciinfo(sys.argv[1])
        if csv_file_ul:
            Decode_PDCCH_Dciinfo(csv_file_ul)
        print('DCI decoding completed')
        Verify_DCI(path_to_ttitrace_dlfdsched_pkl, dir='dl', ue_rnti=59080, nbrEvent=8000)
        Verify_DCI(path_to_ttitrace_ulfdsched_pkl, dir='ul', ue_rnti=59080, nbrEvent=8000)
        print('DCI decoding completed')
    except Exception as e:
        print(f'Error during decoding: {e}')
        traceback.print_exc()  # Print detailed traceback for debugging
    # Pause execution to keep the console window open
    # os.system('pause')


def get_directory(path_to_pickle):
    split_path = path_to_pickle.split('/')
    return "/".join(split_path[:-1])


def visualization():
    pd.set_option('display.max_columns', None)
    pd.set_option('display.expand_frame_repr', False)


def prepare_dataframe_for_analysis(df):
    df = df[["timeStamp", "sfn", "slot",
             "rnti",
             "ulPdcchDciData.ueDciInfoList"]]

    df = df.rename(columns={
        "dlPdcchDciData.ueDciInfoList": "dlDciInfoList",
        "ulPdcchDciData.ueDciInfoList": "ulDciInfoList"})

    # Convert to binary, for debugging purposes
    # df['b_rat0Bitmap'] = df['rat0Bitmap'].map(lambda x: format(int(x), '020b'))

    return df


def prepare_dl_dataframe_for_analysis(df):
    df = df[["timeStamp", "sfn", "slot",
             "rnti", "dlPdcchDciData.ueDciInfoList"]]

    df = df.rename(columns={
        "dlPdcchDciData.ueDciInfoList": "dlDciInfoList"})

    # Convert to binary, for debugging purposes
    # df['b_rat0Bitmap'] = df['rat0Bitmap'].map(lambda x: format(int(x), '020b'))

    return df


def prepare_ul_dataframe_for_analysis(df):
    df = df[["timeStamp", "sfn", "slot",
             "rnti", "ulPdcchDciData.ueDciInfoList"]]

    df = df.rename(columns={
        "ulPdcchDciData.ueDciInfoList": "ulDciInfoList"})

    return df


def extract_and_rename_columns(df):
    for col in df.columns:
        print(df[col].iloc[0])
        print(df[col].dtype)
        if ':' in df[col].iloc[0]:
            print(dict(df[col].iloc[0]))
            df[col].iloc[0] = df[col].iloc[0].apply(type=dict)

        if isinstance(df[col].iloc[0], dict):  # Check if the first element is a dictionary
            for key in df[col].iloc[0].keys():
                df[f'{col}_{key}'] = df[col].apply(lambda x: x[key])
            df.drop(columns=[col], inplace=True)
    return df


def split_df(df, column_name="ulPdcchDciData.ueDciInfoList", new_column_name="Ul_ueDciInfoList", w_drop=True):
    global pd
    pd = pandas_gate.install_and_import_pandas()
    # rename column name first
    df = df.rename(columns={column_name: new_column_name})
    # Split the "new_column_name" column into separate columns
    column_name_split = df[new_column_name].str.split(",", expand=True)
    # print(column_name_split)
    column_name_split.columns = [f"{new_column_name}_{i + 1}" for i in range(column_name_split.shape[1])]
    # Concatenate the new columns with the original DataFrame
    df = pd.concat([df, column_name_split], axis=1)
    # Drop the original "column_name" column
    if w_drop:
        df.drop(columns=[new_column_name], inplace=True)
    return df


def decode_dci(row, dir='dl'):
    # dlDciInfoList_2 is dciPayloadLength
    # dlDciInfoList_3 is dciFormat
    # dlDciInfoList_4 is dciDynamicParamsLength
    # dlDciInfoList_5 is dciBitStream
    dciPayloadLength_s = row[dir+"DciInfoList_2"]
    dciPayloadLength = int(dciPayloadLength_s.split(':')[1])
    # print(dciPayloadLength_s, dciPayloadLength_s.split(":")[1])
    dci_format_s = row[dir+"DciInfoList_3"]
    # remove unnecessary char as space and "'"
    dci_format = (dci_format_s.split(':')[1]).replace(r"'", "")
    dci_format_fmt = "".join(dci_format.split()).replace(r"\'", "")
    # print(dci_format_s, dci_format_s.split(":")[1], dci_format_fmt)
    dciDynamicParamsLength_s = row[dir+"DciInfoList_4"]
    dciDynamicParamsLength = int(dciDynamicParamsLength_s.split(':')[1])
    # print(dciDynamicParamsLength,dciDynamicParamsLength.split(".")[1])
    if dci_format and dciDynamicParamsLength and dciPayloadLength:
        dciBitStream = bin(int(row[dir+"DciInfoList_5"].split(':')[1]))
        # dciBitStream = bin(int(row["dlDciInfoList_5"]))
        dciDynamicParamsLength = bin(dciDynamicParamsLength)
        # print(dciDynamicParamsLength)
        # dciPayloadLength = int(dciPayloadLength.split(".")[0])
        dciPayloadLength = int(dciPayloadLength)
        dciBitStream_ = dciBitStream[2::].rjust(64, "0")
        if dci_format_fmt == 'DL_11':
            dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
        elif dci_format_fmt == 'UL_01':
            dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
        elif dci_format_fmt in ('DL_10_MSG4',
                                'DL_10_SMALLRRC',
                                'DL_10_SRB0MSG',
                                'DL_10_SRB1MSG',
                                'DL_10_FORCE'):
            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength,
                                                       dciBitStream_,
                                                       dciPayloadLength)
        elif dci_format_fmt == 'DL_10_MSG2':
            dci_dict = Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength,
                                                dciBitStream_,
                                                dciPayloadLength)
        elif dci_format_fmt in ('DL_10_SIB1', 'DL_10_OSI'):
            dci_dict = Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength,
                                                 dciBitStream_,
                                                 dciPayloadLength)
        elif dci_format_fmt == 'DL_10_PAGING':
            dci_dict = Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength,
                                                   dciBitStream_,
                                                   dciPayloadLength)
        else:
            dci_dict = dict.fromkeys(DCI_1_1_field_name)
        dci_dict['PdcchDciData.rnti'] = row["rnti"]
        dci_dict['PdcchDciData.dciFromat'] = dci_format_fmt
        # print(dci_dict)
        new_rows.append(dci_dict)
        return new_rows


@log_begin_end_func_name
def Verify_DCI(path_to_pickle, dir='all', ue_rnti=None, validate=None, nbrEvent=None):

    global pd
    pd = pandas_gate.install_and_import_pandas()
    visualization()
    df = pd.read_pickle(path_to_pickle)
    df_filtered = df[df["rnti"] != 65535]
    if nbrEvent is not None:
        df_filtered = df_filtered.head(nbrEvent)
    if dir == "all":
        udf = prepare_dataframe_for_analysis(df_filtered)
    elif dir == "dl":
        udf = prepare_dl_dataframe_for_analysis(df_filtered)
    else:
        udf = prepare_ul_dataframe_for_analysis(df_filtered)

    if ue_rnti is None:
        udf_rnti = udf
    else:
        link_dir = ["dl", "ul"]
        if dir == 'ul':
            link_dir = ["ul"]
        elif dir == 'dl':
            link_dir = ["dl"]
        else:
            link_dir = link_dir
        for link in link_dir:
            udf = udf.reset_index(drop=True)
            for index, row in udf.iterrows():
                if row[link + 'DciInfoList'] is not None:
                    item_upated = False
                    for item in row[link + 'DciInfoList']:
                        if int(ue_rnti) == item['rnti']:
                            udf.loc[index, 'rnti'] = int(ue_rnti)
                            udf.loc[index, link + 'DciInfoList'] = str(item)
                            item_upated = True
                            break
                    if not item_upated:
                        udf.loc[index, link + 'DciInfoList'] = None
        udf_rnti = udf[udf['rnti'] == int(ue_rnti)]
    for link in link_dir:
        udf_rnti_fmt = split_df(udf_rnti, column_name=link+"DciInfoList", new_column_name=link+"DciInfoList",
                                w_drop=False)
    # Apply function to each column
    global new_rows
    new_rows = []  # Create an empty list to store new DataFrame rows
    udf_rnti_fmt.apply(lambda row: decode_dci(row, dir=dir), axis=1)
    df_data = pd.DataFrame(new_rows)
    # print(df_data)
    udf_rnti_dci_results = pd.concat([udf_rnti_fmt, df_data], axis=1)
    # dlDciInfoList_2 is dciPayloadLength
    # dlDciInfoList_3 is dciFormat
    # dlDciInfoList_4 is dciDynamicParamsLength
    # dlDciInfoList_5 is dciBitStream
    udf_rnti_dci_results.drop(columns=[dir+'DciInfoList_1'], inplace=True)
    udf_rnti_dci_results.drop(columns=[dir+'DciInfoList_2'], inplace=True)
    udf_rnti_dci_results.drop(columns=[dir+'DciInfoList_3'], inplace=True)
    udf_rnti_dci_results.drop(columns=[dir+'DciInfoList_4'], inplace=True)
    udf_rnti_dci_results.drop(columns=[dir+'DciInfoList_5'], inplace=True)
    save_data_for_analysis_unitary_test(udf_rnti_dci_results, path_to_ttitrace_pkl=path_to_pickle, dir=dir,
                                        ue_rnti=ue_rnti)

    if not validate:
        rbi.log("No validation requested... keyword pass!")
    else:
        areResultsCorrect = True
        try:
            areResultsCorrect &= checkAl1(udf_rnti)
            areResultsCorrect &= checkAlSelectionWhenCqiIsIncreasing(udf_rnti)
            areResultsCorrect &= checkAlSelectionWhenCqiIsDecreasing(udf_rnti)
        except Exception as e:
            areResultsCorrect = False
            logException("Verify_DCI", e)

        logging.info("areResultsCorrect: %s" % areResultsCorrect)


def save_data_for_analysis_unitary_test(udf, path_to_ttitrace_pkl, dir='all', ue_rnti=None):
    path_to_pickle = path_to_ttitrace_pkl
    if ue_rnti is None:
        file_cvs = '%s/manual_analysis_dci_%s.csv'
        udf.to_csv(str(file_cvs % (get_directory(path_to_pickle), dir)), sep=';')
        print('Output csv file name: ', str(file_cvs % (get_directory(path_to_pickle), dir)))
    else:
        file_cvs = '%s/manual_analysis_dci_%s_rnti_%s.csv'
        udf.to_csv(str(file_cvs % (get_directory(path_to_pickle), dir, ue_rnti)), sep=';')
        print('Output csv file name: ', str(file_cvs % (get_directory(path_to_pickle), dir, ue_rnti)))


if __name__ == '__main__':
    main()
