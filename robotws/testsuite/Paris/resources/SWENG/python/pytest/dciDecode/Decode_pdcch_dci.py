import csv
import os
import json
import StringTool
import glob

from taf.converters.eventdecoder import eventdecoder

DCI_1_1_field_name = ['PdcchDciData.rnti', 'PdcchDciData.dciFormat', 'PdcchDciData.bwPartIndicator',
                      'PdcchDciData.shortMsgIndicator', 'PdcchDciData.shortMessage',
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
                      'PdcchDciData.freqHoppingFlag']


# def DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
def DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength, nbBitAntennaPort):
    StringTool.datedConsole(">>> RDH DEBUG: DecodeDCI_1_1")                                                     # RDH
    pos = 0
    nbBitAntennaPort = int(nbBitAntennaPort)
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    dci11_dciFormat = dciBitStream_[0:1]
    bwPartIndicator_length = int(dciDynamicParamsLength_reverse[0:2][::-1], 2)
    bwPartIndicator = dciBitStream_[1: 1 + bwPartIndicator_length]
    pos = 1 + bwPartIndicator_length
    temp_field_dict['PdcchDciData.bwPartIndicator'] = int(bwPartIndicator, 2)
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[2:7][::-1], 2)
    temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
        hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    tdResourceAssignment_length = int(dciDynamicParamsLength_reverse[7: 7 + 3][::-1], 2)
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
    temp_field_dict['PdcchDciData.downlinkAssigmentIndex'] = \
        int(dciBitStream_[pos: pos + downlinkAssigmentIndex_length], 2)
    pos = pos + downlinkAssigmentIndex_length
    temp_field_dict['PdcchDciData.tpcCommandForPucch'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.pucchResourceIndication'] = int(dciBitStream_[pos: pos + 3], 2)
    pos = pos + 3
    temp_field_dict['PdcchDciData.pdschToHarqFeedbackTime'] = int(dciBitStream_[pos: pos + 3], 2)
    pos = pos + 3
    temp_field_dict['PdcchDciData.antennaPort'] = int(dciBitStream_[pos: pos + nbBitAntennaPort], 2)
    pos = pos + nbBitAntennaPort

    StringTool.datedConsole(">>> RDH DEBUG: PdcchDciData.antennaPort = {}".                                     # RDH
                            format(int(dciBitStream_[pos: pos + nbBitAntennaPort], 2)))                         # RDH
    StringTool.datedConsole(">>> RDH DEBUG: pos = {}".format(pos))                                              # RDH

    temp_field_dict['PdcchDciData.srsRequest'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict['PdcchDciData.dmrsSequenceInit'] = int(dciBitStream_[pos: pos + 1], 2)
    # pos = pos + 1
    # temp_field_dict['PdcchDciData.rnti'] = int(rnti)
    return temp_field_dict


def is_csv_file_generated(output):
    if not is_csv_file_exist(output):
        raise Exception("There is no csv file generated.")


def is_csv_file_exist(output):
    split_path = os.path.split(output)
    base_path, tag = split_path[0], split_path[1]
    csv_exist = True if len(glob.glob(base_path + "/" + tag + "_*.csv")) > 0 else False
    return csv_exist


def decode_ttitrace_file_fail(tti_file, output, decode_form='excelCsv', excel_csv_options='-w',
                              conversion_filter=None):
    logging.info("excel_csv_options:{},type:{}".format(excel_csv_options, type(excel_csv_options)))
    decoder_obj = eventdecoder()
    decoder_obj.create_eventdecoder_converter(name='converter', input_file_path=tti_file, output_file_path=output,
                                              output_file_format=decode_form, excel_csv_options=excel_csv_options,
                                              conversion_filter=conversion_filter)
    decoder_obj.convert(name='converter')
    if not is_csv_file_exist(output):
        raise Exception("Decode result is abnormal.There is no decode file (*.csv) generated.")


def Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    StringTool.datedConsole(">>> RDH DEBUG: Decode_DCIFormat1_0_Msg2")                                          # RDH
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    pos = fdResourceAssignment_length
    temp_field_dict['PdcchDciData.fdResourceAssignment'] = hex(int(dciBitStream_[0: pos], 2))
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = int(dciBitStream_[pos, pos + 4], 2)
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
    dci11_dciFormat = dciBitStream_[0:1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    pos = fdResourceAssignment_length
    temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
        hex(int(dciBitStream_[1: 1 + pos], 2))
    pos = pos + 1
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = \
        int(dciBitStream_[pos, pos + 4], 2)
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
    StringTool.datedConsole(">>> RDH DEBUG: Decode_DCIFormat_1_0_SIB1")                                         # RDH
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
        hex(int(dciBitStream_[0: fdResourceAssignment_length], 2))
    pos = fdResourceAssignment_length
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
    StringTool.datedConsole(">>> RDH DEBUG: Docode_DCIFormat_1_0_PAGING")                                       # RDH
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict['PdcchDciData.shortMsgIndicator'] = int(dciBitStream_[0, 2], 2)
    pos = 2
    temp_field_dict['PdcchDciData.shortMessage'] = hex(int(dciBitStream_[pos: pos + 8], 2))
    pos = pos + 8
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
        hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    temp_field_dict['PdcchDciData.tdResourceAssignment'] = int(dciBitStream_[pos, pos + 4], 2)
    pos = pos + 4
    temp_field_dict['PdcchDciData.vrbToPrbMapping'] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict['PdcchDciData.mcs'] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict['PdcchDciData.tbScaling'] = int(dciBitStream_[pos: pos + 2], 2)
    return temp_field_dict


def DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    StringTool.datedConsole(">>> RDH DEBUG: DecodeDCI_0_1")                                                     # RDH
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    dci01_dciFormat = dciBitStream_[0:1]
    pos += 1
    bwPartIndicator_length = int(dciDynamicParamsLength_reverse[0:2][::-1], 2)
    bwPartIndicator = dciBitStream_[1: 1 + bwPartIndicator_length]
    pos += bwPartIndicator_length
    temp_field_dict['PdcchDciData.bwPartIndicator'] = int(bwPartIndicator, 2)
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[2:7][::-1], 2)
    temp_field_dict['PdcchDciData.fdResourceAssignment'] = \
        hex(int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2))
    pos = pos + fdResourceAssignment_length
    tdResourceAssignment_length = int(dciDynamicParamsLength_reverse[7: 7 + 3][::-1], 2)
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
    antennaPort_length = int(dciDynamicParamsLength_reverse[13: 15][::-1], 2)
    temp_field_dict['PdcchDciData.antennaPort'] = int(dciBitStream_[pos: pos + antennaPort_length], 2)
    pos = pos + antennaPort_length
    temp_field_dict['PdcchDciData.srsRequest'] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    csiRequest_length = int(dciDynamicParamsLength_reverse[15: 16][::-1], 2)
    temp_field_dict['PdcchDciData.csiRequest'] = dciBitStream_[pos: pos + csiRequest_length]
    pos += csiRequest_length
    ptrsDmrs_length = int(dciDynamicParamsLength_reverse[16: 18][::-1], 2)
    temp_field_dict['PdcchDciData.ptrsDmrs'] = dciBitStream_[pos: pos + ptrsDmrs_length]
    pos += ptrsDmrs_length
    betaOffsetindicator_length = int(dciDynamicParamsLength_reverse[18: 20][::-1], 2)
    if betaOffsetindicator_length:
        temp_field_dict['PdcchDciData.betaOffsetindicator'] = dciBitStream_[pos: pos + betaOffsetindicator_length]
    pos += betaOffsetindicator_length
    dmrsSequenceInit_length = int(dciDynamicParamsLength_reverse[20: 21][::-1], 2)
    if dmrsSequenceInit_length:
        temp_field_dict['PdcchDciData.dmrsSequenceInit'] = int(dciBitStream_[pos: pos + dmrsSequenceInit_length], 2)
    pos += dmrsSequenceInit_length
    temp_field_dict['PdcchDciData.ulSulindicator'] = dciBitStream_[pos: pos + 1]
    return temp_field_dict


def DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    StringTool.datedConsole(">>> RDH DEBUG: DecodeDCI_0_0")                                                     # RDH
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    dci01_dciFormat = dciBitStream_[0:1]
    pos = pos + 1
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
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


def Decode_PDCCH_DciInfo(csv_filename, nbBitAntennaPort):
    StringTool.datedConsole(">>> RDH DEBUG: Decode_PDCCH_DciInfo")                                              # RDH
    with open(csv_filename, 'r') as csvfile:
        header = []
        reader = csv.DictReader(csvfile)
        list_reader = list(reader)
        for fieldnames in reader.fieldnames:
            header.append(fieldnames)
        if 'dlPdcchDciData.ueDciInfoList' in header or "ulPdcchDciData.ueDciInfoList" in header:
            print('excelcsv format with json date')
            newfile_header = header + DCI_1_1_field_name
            f = open(csv_filename.replace('.csv', '_dci_decode.csv'), mode='w', encoding='utf-8', newline='')
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
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
                    StringTool.datedConsole(">>> RDH DEBUG: dci_info_list = {}".format(dci_info_list))            # RDH
                    for loop_index in range(len(dci_info_list)):
                        dciBitStream = bin(int(float(dci_info_list[loop_index]["dciBitStream"])))
                        dciDynamicParamsLength = bin(int(float(dci_info_list[loop_index]["dciDynamicParamsLength"])))
                        dciPayloadLength = int(float(dci_info_list[loop_index]["dciPayloadLength"]))
                        dci_format = dci_info_list[loop_index]["dciFormat"]
                        rnti = dci_info_list[loop_index]["rnti"]
                        dciBitStream_ = dciBitStream[2:].ljust(dciPayloadLength, "0").rjust(64, "0")
                        if dci_format == 'DL_11':
                            dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_,
                                                     dciPayloadLength, nbBitAntennaPort)
                        elif dci_format == 'DL_10_MSG4':
                            dci_dict = \
                                Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength, dciBitStream_,
                                                                dciPayloadLength)
                        elif dci_format == 'DL_10_MSG2':
                            dci_dict = \
                                Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'DL_10_SIB1':
                            dci_dict = \
                                Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'DL_10_PAGING':
                            dci_dict = \
                                Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'UL_01':
                            dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'UL_00':
                            dci_dict = DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict['PdcchDciData.rnti'] = rnti
                        dci_dict['PdcchDciData.dciFormat'] = dci_format
                        data.update(dci_dict)
                        csv_writer.writerow(data)
                else:
                    StringTool.datedConsole(">>> RDH DEBUG: dci_info is empty")                                 # RDH
                    csv_writer.writerow(data)                                                                   # RDH
            f.close()
        elif 'ueDciInfoList' in header:
            print('new legacycsv format data split cell')
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
                        dciBitStream = bin(int(float(dci_info_list[loop_index]["dciBitStream"])))
                        dciDynamicParamsLength = bin(int(float(dci_info_list[loop_index]["dciDynamicParamsLength"])))
                        dciPayloadLength = int(float(dci_info_list[loop_index]["dciPayloadLength"]))
                        dci_format = dci_info_list[loop_index]["dciFormat"]
                        rnti = dci_info_list[loop_index]["rnti"]
                        dciBitStream_ = dciBitStream[2:].ljust(dciPayloadLength, "0").rjust(64, "0")
                        if dci_format == 'DL_11':
                            dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'DL_10_MSG4':
                            dci_dict = \
                                Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength, dciBitStream_,
                                                                dciPayloadLength)
                        elif dci_format == 'DL_10_MSG2':
                            dci_dict = \
                                Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'DL_10_SIB1':
                            dci_dict = \
                                Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'DL_10_PAGING':
                            dci_dict = \
                                Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'UL_01':
                            dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        elif dci_format == 'UL_00':
                            dci_dict = DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict['PdcchDciData.rnti'] = rnti
                        dci_dict['PdcchDciData.dciFormat'] = dci_format
                        data.update(dci_dict)
                        csv_writer.writerow(data)
                else:
                    csv_writer.writerow(data)
            f.close()
        elif 'dciBitStream' in header:
            print('old legacycsv format data split cell')
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
                dciBitStream = i_line["dciBitStream"]
                if dci_format and dciBitStream and dciDynamicParamsLength and dciPayloadLength:
                    dciBitStream = bin(int(float(dciBitStream)))
                    dciDynamicParamsLength = bin(int(float(dciDynamicParamsLength)))
                    dciPayloadLength = int(float(dciPayloadLength))
                    dciBitStream_ = dciBitStream[2:].ljust(dciPayloadLength, "0")
                    if (len(dciBitStream_) < 64):
                        dciBitStream_ = dciBitStream_.rjust(64 - len(dciBitStream_), '0')
                    if dci_format == 'DL_11':
                        dci_dict = DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format == 'UL_01':
                        dci_dict = DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format == 'DL_10_MSG4':
                        dci_dict = \
                            Decode_DCIFormat1_0_Msg4OrForce(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format == 'DL_10_MSG2':
                        dci_dict = Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format == 'DL_10_SIB1':
                        dci_dict = Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    elif dci_format == 'DL_10_PAGING':
                        dci_dict = \
                            Docode_DCIFormat_1_0_PAGING(dciDynamicParamsLength, dciBitStream_, dciPayloadLength)
                    else:
                        dci_dict = dict.fromkeys(DCI_1_1_field_name)
                    dci_dict['PdcchDciData.rnti'] = i_line["rnti"]
                    dci_dict['PdcchDciData.dciFromat'] = i_line["dciFormat"]
                    data.update(dci_dict)
                csv_writer.writerow(data)
            f.close()
        else:
            print("Ttitrace has no PdcchDciData field!")
