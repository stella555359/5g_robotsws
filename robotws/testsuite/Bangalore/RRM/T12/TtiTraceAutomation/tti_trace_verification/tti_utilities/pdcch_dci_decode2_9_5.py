import csv
import os
import json
import sys
import traceback
import pandas as pd

DCI_1_1_field_name = [
    "PdcchDciData.rnti",
    "PdcchDciData.dciFromat",
    "PdcchDciData.Vision",
    "PdcchDciData.bwPartIndicator",
    "PdcchDciData.shortMsgIndicator",
    "PdcchDciData.shortMessage",
    "PdcchDciData.fdResourceAssignment",
    "PdcchDciData.tdResourceAssignment",
    "PdcchDciData.vrbToPrbMapping",
    "PdcchDciData.mcs",
    "PdcchDciData.ndi",
    "PdcchDciData.tbScaling",
    "PdcchDciData.redundancyVersion",
    "PdcchDciData.harqProcessNumber",
    "PdcchDciData.systemInfoIndicator",
    "PdcchDciData.downlinkAssigmentIndex",
    "PdcchDciData.tpcCommandForPucch",
    "PdcchDciData.precodingInformationAndNumbersOfLayers",
    "PdcchDciData.pucchResourceIndication",
    "PdcchDciData.pdschToHarqFeedbackTime",
    "PdcchDciData.antennaPort",
    "PdcchDciData.srsRequest",
    "PdcchDciData.csiRequest",
    "PdcchDciData.ptrsDmrs",
    "PdcchDciData.betaOffsetindicator",
    "PdcchDciData.dmrsSequenceInit",
    "PdcchDciData.ulSchindicator",
    "PdcchDciData.freqHoppingFlag",
    "PdcchDciData.PdcchMonitoringAdaptationInd",
]


def DecodeDCI_1_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict["PdcchDciData.Vision"] = int(
        dciDynamicParamsLength_reverse[28:32][::-1], 2
    )
    VisionCtrl = temp_field_dict["PdcchDciData.Vision"]
    # dci11_dciFormat = dciBitStream_[pos: pos + 1]
    pos += 1
    bwPartIndicator_length = int(dciDynamicParamsLength_reverse[0:2][::-1], 2)
    if bwPartIndicator_length:
        bwPartIndicator = dciBitStream_[pos: pos + bwPartIndicator_length]
        temp_field_dict["PdcchDciData.bwPartIndicator"] = int(bwPartIndicator, 2)
    pos += bwPartIndicator_length
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[2:7][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos = pos + fdResourceAssignment_length
    tdResourceAssignment_length = int(dciDynamicParamsLength_reverse[7:10][::-1], 2)
    if tdResourceAssignment_length:
        temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
            dciBitStream_[pos: pos + tdResourceAssignment_length], 2
        )
    pos = pos + tdResourceAssignment_length
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.ndi"] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    temp_field_dict["PdcchDciData.redundancyVersion"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.harqProcessNumber"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    downlinkAssigmentIndex_length = int(dciDynamicParamsLength_reverse[10:13][::-1], 2)
    if downlinkAssigmentIndex_length:
        temp_field_dict["PdcchDciData.downlinkAssigmentIndex"] = int(
            dciBitStream_[pos: pos + downlinkAssigmentIndex_length], 2
        )
    pos = pos + downlinkAssigmentIndex_length
    temp_field_dict["PdcchDciData.tpcCommandForPucch"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.pucchResourceIndication"] = int(
        dciBitStream_[pos: pos + 3], 2
    )
    pos = pos + 3
    temp_field_dict["PdcchDciData.pdschToHarqFeedbackTime"] = int(
        dciBitStream_[pos: pos + 3], 2
    )
    pos = pos + 3
    if VisionCtrl:
        antennaPort_length = int(dciDynamicParamsLength_reverse[13:16][::-1], 2)
        if antennaPort_length:
            temp_field_dict["PdcchDciData.antennaPort"] = int(
                dciBitStream_[pos: pos + antennaPort_length], 2
            )
        pos = pos + antennaPort_length
    else:
        temp_field_dict["PdcchDciData.antennaPort"] = int(
            dciBitStream_[pos: pos + 4], 2
        )
        pos = pos + 4
    temp_field_dict["PdcchDciData.srsRequest"] = int(dciBitStream_[pos: pos + 2], 2)
    pos = pos + 2
    temp_field_dict["PdcchDciData.dmrsSequenceInit"] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    PdcchMonitorAdapInd_length = int(dciDynamicParamsLength_reverse[16:17][::-1], 2)
    if PdcchMonitorAdapInd_length:
        temp_field_dict["PdcchDciData.PdcchMonitoringAdaptationInd"] = int(
            dciBitStream_[pos: pos + PdcchMonitorAdapInd_length], 2
        )
    return temp_field_dict


def Decode_DCIFormat1_0_Msg2(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos += fdResourceAssignment_length
    temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.vrbToPrbMapping"] = int(
        dciBitStream_[pos: pos + 1], 2
    )
    pos = pos + 1
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.tbScaling"] = int(dciBitStream_[pos: pos + 2], 2)
    return temp_field_dict


def Decode_DCIFormat1_0_Msg4OrForce(
    dciDynamicParamsLength, dciBitStream_, dciPayloadLength
):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    # dci10_dciFormat = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos += fdResourceAssignment_length
    temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.vrbToPrbMapping"] = int(
        dciBitStream_[pos: pos + 1], 2
    )
    pos = pos + 1
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.ndi"] = int(dciBitStream_[pos: pos + 1], 2)
    pos = pos + 1
    temp_field_dict["PdcchDciData.redundancyVersion"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.harqProcessNumber"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.downlinkAssigmentIndex"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.tpcCommandForPucch"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.pucchResourceIndication"] = int(
        dciBitStream_[pos: pos + 3], 2
    )
    pos = pos + 3
    temp_field_dict["PdcchDciData.pdschToHarqFeedbackTime"] = int(
        dciBitStream_[pos: pos + 3], 2
    )
    return temp_field_dict


def Decode_DCIFormat_1_0_SIB1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos += fdResourceAssignment_length
    temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.vrbToPrbMapping"] = int(
        dciBitStream_[pos: pos + 1], 2
    )
    pos = pos + 1
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.redundancyVersion"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.systemInfoIndicator"] = int(
        dciBitStream_[pos: pos + 1], 2
    )
    return temp_field_dict


def Docode_DCIFormat_1_0_PAGING(
    dciDynamicParamsLength, dciBitStream_, dciPayloadLength
):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict["PdcchDciData.shortMsgIndicator"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos += 2
    temp_field_dict["PdcchDciData.shortMessage"] = hex(
        int(dciBitStream_[pos: pos + 8], 2)
    )
    pos = pos + 8
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos = pos + fdResourceAssignment_length
    temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.vrbToPrbMapping"] = int(
        dciBitStream_[pos: pos + 1], 2
    )
    pos = pos + 1
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.tbScaling"] = int(dciBitStream_[pos: pos + 2], 2)
    return temp_field_dict


def DecodeDCI_0_1(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    temp_field_dict["PdcchDciData.Vision"] = int(
        dciDynamicParamsLength_reverse[28:32][::-1], 2
    )
    VisionCtrl = temp_field_dict["PdcchDciData.Vision"]
    # dci01_dciFormat = dciBitStream_[pos: pos + 1]
    pos += 1
    bwPartIndicator_length = int(dciDynamicParamsLength_reverse[0:2][::-1], 2)
    if bwPartIndicator_length:
        bwPartIndicator = dciBitStream_[pos: pos + bwPartIndicator_length]
        temp_field_dict["PdcchDciData.bwPartIndicator"] = int(bwPartIndicator, 2)
    pos += bwPartIndicator_length
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[2:7][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos = pos + fdResourceAssignment_length
    tdResourceAssignment_length = int(dciDynamicParamsLength_reverse[7:10][::-1], 2)
    if tdResourceAssignment_length:
        temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
            dciBitStream_[pos: pos + tdResourceAssignment_length], 2
        )
    pos = pos + tdResourceAssignment_length
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.ndi"] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    temp_field_dict["PdcchDciData.redundancyVersion"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.harqProcessNumber"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.downlinkAssigmentIndex"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    temp_field_dict["PdcchDciData.tpcCommandForPucch"] = int(
        dciBitStream_[pos: pos + 2], 2
    )
    pos = pos + 2
    precodingInformationAndNumbersOfLayers_length = int(
        dciDynamicParamsLength_reverse[10:13][::-1], 2
    )
    if precodingInformationAndNumbersOfLayers_length:
        temp_field_dict["PdcchDciData.precodingInformationAndNumbersOfLayers"] = int(
            dciBitStream_[pos: pos + precodingInformationAndNumbersOfLayers_length], 2
        )
    pos = pos + precodingInformationAndNumbersOfLayers_length
    if VisionCtrl:
        antennaPort_length = int(dciDynamicParamsLength_reverse[13:16][::-1], 2)
        if antennaPort_length:
            temp_field_dict["PdcchDciData.antennaPort"] = int(
                dciBitStream_[pos: pos + antennaPort_length], 2
            )
        pos = pos + antennaPort_length
        temp_field_dict["PdcchDciData.srsRequest"] = int(
            dciBitStream_[pos: pos + 2], 2
        )
        pos = pos + 2
        csiRequest_length = int(dciDynamicParamsLength_reverse[16:17][::-1], 2)
        if csiRequest_length:
            temp_field_dict["PdcchDciData.csiRequest"] = dciBitStream_[
                pos: pos + csiRequest_length
            ]
        pos += csiRequest_length
        ptrsDmrs_length = int(dciDynamicParamsLength_reverse[17:19][::-1], 2)
        if ptrsDmrs_length:
            temp_field_dict["PdcchDciData.ptrsDmrs"] = dciBitStream_[
                pos: pos + ptrsDmrs_length
            ]
        pos += ptrsDmrs_length
        betaOffsetindicator_length = int(dciDynamicParamsLength_reverse[19:21][::-1], 2)
        if betaOffsetindicator_length:
            temp_field_dict["PdcchDciData.betaOffsetindicator"] = dciBitStream_[
                pos: pos + betaOffsetindicator_length
            ]
        pos += betaOffsetindicator_length
        dmrsSequenceInit_length = int(dciDynamicParamsLength_reverse[21:22][::-1], 2)
        if dmrsSequenceInit_length:
            temp_field_dict["PdcchDciData.dmrsSequenceInit"] = int(
                dciBitStream_[pos: pos + dmrsSequenceInit_length], 2
            )
        pos += dmrsSequenceInit_length
        temp_field_dict["PdcchDciData.ulSchindicator"] = dciBitStream_[pos: pos + 1]
        pos = pos + 1
        PdcchMonitorAdapInd_length = int(dciDynamicParamsLength_reverse[22:23][::-1], 2)
        if PdcchMonitorAdapInd_length:
            temp_field_dict["PdcchDciData.PdcchMonitoringAdaptationInd"] = int(
                dciBitStream_[pos: pos + PdcchMonitorAdapInd_length], 2
            )
    else:
        antennaPort_length = int(dciDynamicParamsLength_reverse[13:15][::-1], 2)
        if antennaPort_length:
            temp_field_dict["PdcchDciData.antennaPort"] = int(
                dciBitStream_[pos: pos + antennaPort_length], 2
            )
        pos = pos + antennaPort_length
        temp_field_dict["PdcchDciData.srsRequest"] = int(
            dciBitStream_[pos: pos + 2], 2
        )
        pos = pos + 2
        csiRequest_length = int(dciDynamicParamsLength_reverse[15:16][::-1], 2)
        if csiRequest_length:
            temp_field_dict["PdcchDciData.csiRequest"] = dciBitStream_[
                pos: pos + csiRequest_length
            ]
        pos += csiRequest_length
        ptrsDmrs_length = int(dciDynamicParamsLength_reverse[16:18][::-1], 2)
        if ptrsDmrs_length:
            temp_field_dict["PdcchDciData.ptrsDmrs"] = dciBitStream_[
                pos: pos + ptrsDmrs_length
            ]
        pos += ptrsDmrs_length
        betaOffsetindicator_length = int(dciDynamicParamsLength_reverse[18:20][::-1], 2)
        if betaOffsetindicator_length:
            temp_field_dict["PdcchDciData.betaOffsetindicator"] = dciBitStream_[
                pos: pos + betaOffsetindicator_length
            ]
        pos += betaOffsetindicator_length
        dmrsSequenceInit_length = int(dciDynamicParamsLength_reverse[20:21][::-1], 2)
        if dmrsSequenceInit_length:
            temp_field_dict["PdcchDciData.dmrsSequenceInit"] = int(
                dciBitStream_[pos: pos + dmrsSequenceInit_length], 2
            )
        pos += dmrsSequenceInit_length
        temp_field_dict["PdcchDciData.ulSchindicator"] = dciBitStream_[pos: pos + 1]
    return temp_field_dict


def DecodeDCI_0_0(dciDynamicParamsLength, dciBitStream_, dciPayloadLength):
    pos = 0
    temp_field_dict = dict.fromkeys(DCI_1_1_field_name)
    dciDynamicParamsLength_reverse = dciDynamicParamsLength[2:].rjust(32, "0")[::-1]
    # dci00_dciFormat = dciBitStream_[0: 1]
    pos = pos + 1
    fdResourceAssignment_length = int(dciDynamicParamsLength_reverse[0:5][::-1], 2)
    if fdResourceAssignment_length:
        temp_field_dict["PdcchDciData.fdResourceAssignment"] = hex(
            int(dciBitStream_[pos: pos + fdResourceAssignment_length], 2)
        )
    pos = pos + fdResourceAssignment_length
    temp_field_dict["PdcchDciData.tdResourceAssignment"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    pos = pos + 4
    temp_field_dict["PdcchDciData.freqHoppingFlag"] = int(
        dciBitStream_[pos: pos + 1], 2
    )
    pos = pos + 1
    temp_field_dict["PdcchDciData.mcs"] = int(dciBitStream_[pos: pos + 5], 2)
    pos = pos + 5
    temp_field_dict["PdcchDciData.ndi"] = dciBitStream_[pos: pos + 1]
    pos = pos + 1
    temp_field_dict["PdcchDciData.redundancyVersion"] = dciBitStream_[pos: pos + 2]
    pos = pos + 2
    temp_field_dict["PdcchDciData.harqProcessNumber"] = int(
        dciBitStream_[pos: pos + 4], 2
    )
    return temp_field_dict


def Decode_PDCCH_Dciinfo(csv_filename):
    print("tti trace file name: ", csv_filename)
    with open(csv_filename, "r") as csvfile:
        header = []
        reader = csv.DictReader(csvfile)
        list_reader = list(reader)
        for fieldnames in reader.fieldnames:
            header.append(fieldnames)
            # print(fieldnames)
        if (
            "dlPdcchDciData.ueDciInfoList" in header
            or "ulPdcchDciData.ueDciInfoList" in header
        ):
            print("tti trace format: excelcsv format with json date")
            newfile_header = header + DCI_1_1_field_name
            f = open(
                csv_filename.replace(".csv", "_dci_decode.csv"),
                mode="w",
                encoding="utf-8",
                newline="",
            )
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
            csv_writer.writeheader()
            for i_line in list_reader:
                data = i_line
                if "dlPdcchDciData.ueDciInfoList" in header:
                    dci_info = i_line["dlPdcchDciData.ueDciInfoList"]
                elif "ulPdcchDciData.ueDciInfoList" in header:
                    dci_info = i_line["ulPdcchDciData.ueDciInfoList"]
                if dci_info != "":
                    dci_info = dci_info.replace("'", '"')
                    dci_info_list = json.loads(dci_info)
                    for loop_index in range(len(dci_info_list)):
                        # print(int(dci_info_list[loop_index]["dciBitStream"]))
                        dciBitStream = bin(
                            int(dci_info_list[loop_index]["dciBitStream"])
                        )
                        dciDynamicParamsLength = bin(
                            int(dci_info_list[loop_index]["dciDynamicParamsLength"])
                        )
                        dciPayloadLength = int(
                            dci_info_list[loop_index]["dciPayloadLength"]
                        )
                        dci_format = dci_info_list[loop_index]["dciFormat"]
                        rnti = dci_info_list[loop_index]["rnti"]
                        dciBitStream_ = (
                            dciBitStream[2:].ljust(dciPayloadLength, "0").rjust(64, "0")
                        )
                        if dci_format == "DL_11":
                            dci_dict = DecodeDCI_1_1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in (
                            "DL_10_MSG4",
                            "DL_10_SMALLRRC",
                            "DL_10_SRB0MSG",
                            "DL_10_SRB1MSG",
                            "DL_10_FORCE",
                        ):
                            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "DL_10_MSG2":
                            dci_dict = Decode_DCIFormat1_0_Msg2(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in ("DL_10_SIB1", "DL_10_OSI"):
                            dci_dict = Decode_DCIFormat_1_0_SIB1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "DL_10_PAGING":
                            dci_dict = Docode_DCIFormat_1_0_PAGING(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "UL_01":
                            dci_dict = DecodeDCI_0_1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in ("UL_00", "UL_00_FORCE"):
                            dci_dict = DecodeDCI_0_0(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict["PdcchDciData.rnti"] = rnti
                        dci_dict["PdcchDciData.dciFromat"] = dci_format
                        data.update(dci_dict)
                        csv_writer.writerow(data)
                else:
                    csv_writer.writerow(data)
            f.close()
        elif "ueDciInfoList" in header:
            print("tti trace format: new legacycsv format data split cell")
            newfile_header = header + DCI_1_1_field_name
            f = open(
                csv_filename.replace(".csv", "_dci_decode.csv"),
                mode="w",
                encoding="utf-8",
                newline="",
            )
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
            csv_writer.writeheader()
            for i_line in list_reader:
                data = i_line
                if "ueDciInfoList" in header:
                    dci_info = i_line["ueDciInfoList"]
                if dci_info != "":
                    dci_info = dci_info.replace("'", '"')
                    dci_info_list = json.loads(dci_info)
                    for loop_index in range(len(dci_info_list)):
                        dciBitStream = bin(
                            int(dci_info_list[loop_index]["dciBitStream"])
                        )
                        dciDynamicParamsLength = bin(
                            int(dci_info_list[loop_index]["dciDynamicParamsLength"])
                        )
                        dciPayloadLength = int(
                            dci_info_list[loop_index]["dciPayloadLength"]
                        )
                        dci_format = dci_info_list[loop_index]["dciFormat"]
                        rnti = dci_info_list[loop_index]["rnti"]
                        dciBitStream_ = (
                            dciBitStream[2:].ljust(dciPayloadLength, "0").rjust(64, "0")
                        )
                        if dci_format == "DL_11":
                            dci_dict = DecodeDCI_1_1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in (
                            "DL_10_MSG4",
                            "DL_10_SMALLRRC",
                            "DL_10_SRB0MSG",
                            "DL_10_SRB1MSG",
                            "DL_10_FORCE",
                        ):
                            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "DL_10_MSG2":
                            dci_dict = Decode_DCIFormat1_0_Msg2(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in ("DL_10_SIB1", "DL_10_OSI"):
                            dci_dict = Decode_DCIFormat_1_0_SIB1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "DL_10_PAGING":
                            dci_dict = Docode_DCIFormat_1_0_PAGING(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "UL_01":
                            dci_dict = DecodeDCI_0_1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in ("UL_00", "UL_00_FORCE"):
                            dci_dict = DecodeDCI_0_0(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict["PdcchDciData.rnti"] = rnti
                        dci_dict["PdcchDciData.dciFromat"] = dci_format
                        data.update(dci_dict)
                        csv_writer.writerow(data)
                else:
                    csv_writer.writerow(data)
            f.close()
        elif "dciBitStream" in header and "type" in header:
            print(
                "tti trace format: Gnb_logs convert old legacycsv format data split cell"
            )
            newfile_header = header[:-1] + DCI_1_1_field_name
            f = open(
                csv_filename.replace(".csv", "_dci_decode.csv"),
                mode="w",
                encoding="utf-8",
                newline="",
            )
            csv_writer = csv.DictWriter(f, fieldnames=newfile_header)
            csv_writer.writeheader()
            for i_line in list_reader:
                data = i_line
                del data[""]
                dci_format = i_line["dciFormat"]
                dciDynamicParamsLength = i_line["dciDynamicParamsLength"]
                dciPayloadLength = i_line["dciPayloadLength"]
                if dci_format and dciDynamicParamsLength and dciPayloadLength:
                    dciBitStream = bin(int(i_line["dciBitStream"]))
                    dciDynamicParamsLength = bin(int(dciDynamicParamsLength))
                    dciPayloadLength = int(dciPayloadLength)
                    dciBitStream_ = dciBitStream[2::].rjust(64, "0")
                    if dci_format == "DL_11":
                        dci_dict = DecodeDCI_1_1(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    elif dci_format == "UL_01":
                        dci_dict = DecodeDCI_0_1(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    elif dci_format in ("UL_00", "UL_00_FORCE"):
                        dci_dict = DecodeDCI_0_0(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    elif dci_format in (
                        "DL_10_MSG4",
                        "DL_10_SMALLRRC",
                        "DL_10_SRB0MSG",
                        "DL_10_SRB1MSG",
                        "DL_10_FORCE",
                    ):
                        dci_dict = Decode_DCIFormat1_0_Msg4OrForce(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    elif dci_format == "DL_10_MSG2":
                        dci_dict = Decode_DCIFormat1_0_Msg2(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    elif dci_format in ("DL_10_SIB1", "DL_10_OSI"):
                        dci_dict = Decode_DCIFormat_1_0_SIB1(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    elif dci_format == "DL_10_PAGING":
                        dci_dict = Docode_DCIFormat_1_0_PAGING(
                            dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                        )
                    else:
                        dci_dict = dict.fromkeys(DCI_1_1_field_name)
                    dci_dict["PdcchDciData.rnti"] = i_line["rnti"]
                    dci_dict["PdcchDciData.dciFromat"] = i_line["dciFormat"]
                    data.update(dci_dict)
                csv_writer.writerow(data)
            f.close()
        elif "dciBitStream" in header and "type" not in header:
            print("event csv DL UL same format")
            df = pd.read_csv(csv_filename, low_memory=False, dtype=str)
            # 不丢精度
            dcidata_index = df.columns.get_loc("dciPayloadLength") - 1
            # 有效数据开始列
            rnti_index = df.columns.get_loc("rnti")
            # 第一个rnti是无效的，可以删掉
            repeated_headers = [
                col.split(".")[0] for col in df.columns[dcidata_index:] if "." in col
            ][1::]
            # 从 dcidata_index 开始的列中，提取包含 . 的列名，并去除 . 后面的数字后缀，得到重复列的表头。
            new_rows = []
            # 创建一个空列表，用于存储新的 DataFrame 行
            for index, row in df.iterrows():
                new_row = {}
                # 创建一个新的字典来存储当前行的数据
                for j in range(dcidata_index):
                    # 将dcidata_index前列的数据添加到字典中，跳过第五列rnti 列
                    if j == rnti_index:
                        # 跳过rnti 列
                        continue
                    new_row[df.columns[j]] = row.iloc[j]
                # 将当前行的数据添加到字典中
                for k, header in enumerate(repeated_headers):
                    # 获取当前列的索引
                    col_index = k + dcidata_index
                    # 获取当前列的值
                    value = row.iloc[col_index]
                    # 将值添加到字典中，并使用统一的列名
                    new_row[header] = value
                new_rows.append(new_row)
                #  print(new_rows)
                #  遍历重复列组，将重复部分的数据添加到新的 DataFrame 行列表中
                for i in range(0, len(repeated_headers), 6):
                    # 获取当前重复列组的表头
                    current_headers = repeated_headers[i: i + 6]
                    # print(current_headers)
                    # 创建一个新的字典来存储当前行的数据
                    new_row = {}
                    # 将前七列的数据添加到字典中，跳过第五列
                    for j in range(dcidata_index):
                        if j == rnti_index:  # 跳过rnti列
                            continue
                        new_row[df.columns[j]] = row.iloc[j]
                    # 将当前重复列组的数据添加到字典中，并修改列名
                    for k, header in enumerate(current_headers):
                        # 获取当前列的索引
                        col_index = k + i + dcidata_index
                        # 获取当前列的值
                        value = row.iloc[col_index]
                        # 将值添加到字典中，并使用统一的列名
                        new_row[header] = value
                    # 将新的字典添加到新的 DataFrame 行列表中
                    new_rows.append(new_row)
                    # print(new_rows)
            # 创建一个新的 DataFrame，包含所有新的行
            new_df = pd.DataFrame(new_rows)
            # print(new_df)
            # 调整列顺序
            """new_df = new_df[
                ['hfnTickCount', 'sfn', 'slot', 'emCoreId', 'lcrId', 'physCellId', 'rnti', 'dciPayloadLength',
                 'dciFormat', 'dciDynamicParamsLength', 'dciBitStream', 'dciTransmitPower']]"""
            new_df = new_df[new_df["rnti"].notna()]
            new_df.to_csv("new_event.csv", index=False)
            # open new event
            with open("new_event.csv", "r") as eventcsv:
                header = []
                reader = csv.DictReader(eventcsv)
                list_reader = list(reader)
                for fieldnames in reader.fieldnames:
                    header.append(fieldnames)
                newfile_header = header + DCI_1_1_field_name
                # print(newfile_header)
                f = open(
                    csv_filename.replace(".csv", "_dci_decode.csv"),
                    mode="w",
                    encoding="utf-8",
                    newline="",
                )
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
                        dciDynamicParamsLength = bin(
                            int(dciDynamicParamsLength.split(".")[0])
                        )
                        # print(dciDynamicParamsLength)
                        dciPayloadLength = int(dciPayloadLength.split(".")[0])
                        dciBitStream_ = dciBitStream[2::].rjust(64, "0")
                        if dci_format == "DL_11":
                            dci_dict = DecodeDCI_1_1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "UL_01":
                            dci_dict = DecodeDCI_0_1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in ("UL_00", "UL_00_FORCE"):
                            dci_dict = DecodeDCI_0_0(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in (
                            "DL_10_MSG4",
                            "DL_10_SMALLRRC",
                            "DL_10_SRB0MSG",
                            "DL_10_SRB1MSG",
                            "DL_10_FORCE",
                        ):
                            dci_dict = Decode_DCIFormat1_0_Msg4OrForce(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "DL_10_MSG2":
                            dci_dict = Decode_DCIFormat1_0_Msg2(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format in ("DL_10_SIB1", "DL_10_OSI"):
                            dci_dict = Decode_DCIFormat_1_0_SIB1(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        elif dci_format == "DL_10_PAGING":
                            dci_dict = Docode_DCIFormat_1_0_PAGING(
                                dciDynamicParamsLength, dciBitStream_, dciPayloadLength
                            )
                        else:
                            dci_dict = dict.fromkeys(DCI_1_1_field_name)
                        dci_dict["PdcchDciData.rnti"] = i_line["rnti"]
                        dci_dict["PdcchDciData.dciFromat"] = i_line["dciFormat"]
                        data.update(dci_dict)
                    csv_writer.writerow(data)
                f.close()
            try:
                os.remove("new_event.csv")
                print("Tmp file deleted successfully.")
            except FileNotFoundError:
                print("Tmp csv not found.")
            except OSError as e:
                print(f"Error deleting file 'new_event.csv': {e}")
        else:
            print("ERROR format: Ttitrace has no PdcchDciData field!")
        print("Output file name: ", csv_filename.replace(".csv", "_dci_decode.csv"))


def main():
    try:
        print("tti trace starting DCI decoding...")
        print(
            "confluence page: https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1557534986"
        )
        Decode_PDCCH_Dciinfo(sys.argv[1])
        print("DCI decoding completed")
    except Exception as e:
        print("Error during decoding: {}".format(e))
        traceback.print_exc()  # Print detailed traceback for debugging
        print(
            """
              you need download new exe from:
               https://confluence.ext.net.nokia.com/pages/editpage.action?pageId=1557534986"""
        )
        print("If decode fail still happen, contact yajie.j.wang@nokia-sbell.com.")
    # Pause execution to keep the console window open
    # os.system("pause")


if __name__ == "__main__":
    main()
