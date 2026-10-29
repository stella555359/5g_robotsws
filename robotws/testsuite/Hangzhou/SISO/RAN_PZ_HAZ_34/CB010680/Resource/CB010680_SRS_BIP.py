# there is one json file and read this file to get the key value
import json
import os.path
import re
from datetime import datetime
import pytz
import calendar
import xml.etree.ElementTree as ET


# follow is the json file content
# [
#   {
#     "_index": "packets-2024-12-25",
#     "_type": "doc",
#     "_score": null,
#     "_source": {
#       "layers": {
#         "frame": {
#           "frame.section_number": "1",
#           "frame.interface_id": "0",
#           "frame.interface_id_tree": {
#             "frame.interface_name": "unknown"
#           },
#           "frame.encap_type": "1",
#           "frame.time": "Dec 25, 2024 16:12:58.855372000 CST",
#           "frame.time_utc": "Dec 25, 2024 08:12:58.855372000 UTC",
#           "frame.time_epoch": "1735114378.855372000",
#           "frame.offset_shift": "0.000000000",
#           "frame.time_delta": "0.002537000",
#           "frame.time_delta_displayed": "0.000000000",
#           "frame.time_relative": "0.002537000",
#           "frame.number": "2",
#           "frame.len": "94",
#           "frame.cap_len": "94",
#           "frame.marked": "0",
#           "frame.ignored": "0",
#           "frame.protocols": "eth:ethertype:vlan:ethertype:bip:bip_event_chaining:swe:uldata_srsposreceiverespps"
#         },
#         "eth": {
#           "eth.dst": "02:40:43:80:00:14",
#           "eth.dst_tree": {
#             "eth.dst_resolved": "02:40:43:80:00:14",
#             "eth.dst.oui": "147523",
#             "eth.addr": "02:40:43:80:00:14",
#             "eth.addr_resolved": "02:40:43:80:00:14",
#             "eth.addr.oui": "147523",
#             "eth.dst.lg": "1",
#             "eth.lg": "1",
#             "eth.dst.ig": "0",
#             "eth.ig": "0"
#           },
#           "eth.src": "02:40:43:80:00:04",
#           "eth.src_tree": {
#             "eth.src_resolved": "02:40:43:80:00:04",
#             "eth.src.oui": "147523",
#             "eth.addr": "02:40:43:80:00:04",
#             "eth.addr_resolved": "02:40:43:80:00:04",
#             "eth.addr.oui": "147523",
#             "eth.src.lg": "1",
#             "eth.lg": "1",
#             "eth.src.ig": "0",
#             "eth.ig": "0"
#           },
#           "eth.type": "0x8100"
#         },
#         "vlan": {
#           "vlan.priority": "5",
#           "vlan.dei": "0",
#           "vlan.id": "218",
#           "vlan.etype": "0x8951"
#         },
#         "bip": "BIP header dispatcher: Event Chaining",
#         "bip_event_chaining": {
#           "bip_ec.StreamId": "8196",
#           "bip_ec.StreamId_tree": {
#             "bip_ec.StreamId.Type": "2",
#             "bip_ec.StreamId.Id": "4"
#           },
#           "bip_ec.eventSize": "68",
#           "bip_ec.Timestamp_Pointer": "0x900006b7",
#           "bip_ec.Timestamp_Pointer_tree": {
#             "bip_ec.eventSeqNum": "144",
#             "bip_ec.fragmentIndex": "0",
#             "bip_ec.localQueueId": "1719"
#           }
#         },
#         "swe": {
#           "bip_ec.eventSize": "68",
#           "bip_ec.Sw_Event.MessageID": "0xe26a",
#           "swe.Header": "00:02:e2:6a:00:00:00:00",
#           "swe.Header_tree": {
#             "swe.Reserved": "0x00",
#             "swe.TE": "0x02",
#             "swe.TE_tree": {
#               "swe.T": "0",
#               "swe.E": "1"
#             },
#             "swe.MessageID": "0xe26a",
#             "swe.Reserved": "0x00",
#             "swe.Timestamp": "0"
#           },
#           "swe.Payload": "45:03:03:04:08:00:00:00:01:00:00:00:03:00:3d:00:0d:00:00:00:1d:00:00:80:00:80:00:80:00:00:
#           0c:c3:00:00:0c:c3:00:00:0c:c3:00:00:0c:c3:00:00:7f:43:00:00:7f:43:00:00:7f:43:00:00:7f:43"
#         },
#         "icom_5g": {
#           "nr_l1ul_l2ps": {
#             "uldata_srsposreceiverespps": {
#               "nr_l1ul_l2ps_uldata_srsposreceiverespps_t": {
#                 "3gpp.sfn": "837",
#                 "3gpp.slot": "3",
#                 "3gpp.subcellid": "4",
#                 "srsPosReports (DynamicVariableSizedArray)": {
#                   "UlData_SrsPosReceiveRespPs_t.srsPosReports.Offset": "8",
#                   "UlData_SrsPosReceiveRespPs_t.srsPosReports.Length": "1",
#                   "nr_l1ul_l2ps_uldata_srsposreport_t": {
#                     "UlData_srsPosReport_t.measId": "3",
#                     "UlData_srsPosReport_t.sequenceId": "61",
#                     "UlData_srsPosReport_t.symbolPosition": "13",
#                     "UlData_srsPosReport_t.result": "0",
#                     "timeOffsetPos (StaticFixedSizedArray)": {
#                       "UlData_srsPosReport_t.timeOffsetPos_item": "29",
#                       "UlData_srsPosReport_t.timeOffsetPos_item": "-32768",
#                       "UlData_srsPosReport_t.timeOffsetPos_item": "-32768",
#                       "UlData_srsPosReport_t.timeOffsetPos_item": "-32768"
#                     },
#                     "rsrp (StaticFixedSizedArray)": {
#                       "UlData_srsPosReport_t.rsrp_item": "-140",
#                       "UlData_srsPosReport_t.rsrp_item": "-140",
#                       "UlData_srsPosReport_t.rsrp_item": "-140",
#                       "UlData_srsPosReport_t.rsrp_item": "-140"
#                     },
#                     "sinr (StaticFixedSizedArray)": {
#                       "UlData_srsPosReport_t.sinr_item": "255",
#                       "UlData_srsPosReport_t.sinr_item": "255",
#                       "UlData_srsPosReport_t.sinr_item": "255",
#                       "UlData_srsPosReport_t.sinr_item": "255"
#                     }
#                   }
#                 }
#               }
#             }
#           }
#         }
#       }
#     }
#   }
# ]


# here is csrs and prbNum mapping base on 3gpp table, bsrs=0
# 0	4
# 1	8
# 2	12
# 3	16
# 4	16
# 5	20
# 6	24
# 7	24
# 8	28
# 9	32
# 10	36
# 11	40
# 12	48
# 13	48
# 14	52
# 15	56
# 16	60
# 17	64
# 18	72
# 19	72
# 20	76
# 21	80
# 22	88
# 23	96
# 24	96
# 25	104
# 26	112
# 27	120
# 28	120
# 29	120
# 30	128
# 31	128
# 32	128
# 33	132
# 34	136
# 35	144
# 36	144
# 37	144
# 38	144
# 39	152
# 40	160
# 41	160
# 42	160
# 43	168
# 44	176
# 45	184
# 46	192
# 47	192
# 48	192
# 49	192
# 50	208
# 51	216
# 52	224
# 53	240
# 54	240
# 55	240
# 56	240
# 57	256
# 58	256
# 59	256
# 60	264
# 61	272
# 62	272
# 63	272

CSRS_PRBNUM_MAPPING = {
    0: 4, 1: 8, 2: 12, 3: 16, 4: 16, 5: 20, 6: 24, 7: 24, 8: 28, 9: 32, 10: 36, 11: 40, 12: 48, 13: 48, 14: 52,
    15: 56, 16: 60, 17: 64, 18: 72, 19: 72, 20: 76, 21: 80, 22: 88, 23: 96, 24: 96, 25: 104, 26: 112, 27: 120,
    28: 120, 29: 120, 30: 128, 31: 128, 32: 128, 33: 132, 34: 136, 35: 144, 36: 144, 37: 144, 38: 144, 39: 152,
    40: 160, 41: 160, 42: 160, 43: 168, 44: 176, 45: 184, 46: 192, 47: 192, 48: 192, 49: 192, 50: 208, 51: 216,
    52: 224, 53: 240, 54: 240, 55: 240, 56: 240, 57: 256, 58: 256, 59: 256, 60: 264, 61: 272, 62: 272, 63: 272
}

BTS_DIST_749 = 'MRBTS-37600/NRBTS-37600'


def updateSrsDrxParamList(btsDist, drxLongCycle, drxInactivityTimer, drxOnDurationTimer, drxPriority,
                          srsUePeriodicity, other_parameter=[], create_drx_mo=True, posNrDrxDN='NRDRX-32'):
    srs_cell_0 = [{
        'cSRS': '63',
        'comb': 'comb2',
        'numberOfCS': '4 cycle shifts',
        'srsUePeriodicity': srsUePeriodicity,
        'posNrDrxDN': posNrDrxDN
    }]
    srs_cell_1 = [{
        'cSRS': '7',
        'comb': 'comb2',
        'numberOfCS': '2 cycle shifts',
        'srsUePeriodicity': srsUePeriodicity,
        'posNrDrxDN': posNrDrxDN
    }]
    srs_cell_2 = [{
        'cSRS': '13',
        'comb': 'comb4',
        'numberOfCS': '2 cycle shifts',
        'srsUePeriodicity': srsUePeriodicity,
        'posNrDrxDN': posNrDrxDN
    }]
    srs_cell_3 = [{
        'cSRS': '13',
        'comb': 'comb4',
        'numberOfCS': '2 cycle shifts',
        'srsUePeriodicity': srsUePeriodicity,
        'posNrDrxDN': posNrDrxDN
    }]
    srs_cell_4 = [{
        'cSRS': '51',
        'comb': 'comb4',
        'numberOfCS': '2 cycle shifts',
        'srsUePeriodicity': srsUePeriodicity,
        'posNrDrxDN': posNrDrxDN
    }]
    srs_cell_5 = [{
        'cSRS': '51',
        'comb': 'comb4',
        'numberOfCS': '2 cycle shifts',
        'srsUePeriodicity': srsUePeriodicity,
        'posNrDrxDN': posNrDrxDN
    }]
    new_list = [
        dict(dist_name=btsDist, parameter='actDrbDrx', value='true', operation='update'),
        dict(dist_name=btsDist + '/NRCELL-0', parameter='srsForPositioning', value=srs_cell_0, operation='update'),
        dict(dist_name=btsDist + '/NRCELL-1', parameter='srsForPositioning', value=srs_cell_1, operation='update'),
        dict(dist_name=btsDist + '/NRCELL-2', parameter='srsForPositioning', value=srs_cell_2, operation='update'),
        dict(dist_name=btsDist + '/NRCELL-3', parameter='srsForPositioning', value=srs_cell_3, operation='update'),
        dict(dist_name=btsDist + '/NRCELL-4', parameter='srsForPositioning', value=srs_cell_4, operation='update'),
        dict(dist_name=btsDist + '/NRCELL-5', parameter='srsForPositioning', value=srs_cell_5, operation='update'),
    ]
    if create_drx_mo:
        new_list.extend([
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='', value='', operation='create_object'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxInactivityTimer',
                 value=drxInactivityTimer, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxLongCycle',
                 value=drxLongCycle, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxOnDurationTimer',
                 value=drxOnDurationTimer, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxPriority',
                 value=drxPriority, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='userLabel', value='NRPOS', operation='update'),
        ])
    else:
        new_list.extend([
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxInactivityTimer',
                 value=drxInactivityTimer, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxLongCycle',
                 value=drxLongCycle, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxOnDurationTimer',
                 value=drxOnDurationTimer, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='drxPriority',
                 value=drxPriority, operation='update'),
            dict(dist_name=btsDist + '/' + posNrDrxDN, parameter='userLabel', value='NRPOS', operation='update'),
        ])
    new_list.extend(other_parameter)
    return new_list


def update_parameters_dn(cell_dn, params):
    for item in params:
        item['dist_name'] = cell_dn
    return params


def transform_json_structure(json_text):
    # Define regex patterns to match and replace the specified keys
    patterns = [
        (r'"timeOffsetPos \(StaticFixedSizedArray\)": \{([^}]+)\}', r'"timeOffsetPos (StaticFixedSizedArray)": [\1]'),
        (r'"rsrp \(StaticFixedSizedArray\)": \{([^}]+)\}', r'"rsrp (StaticFixedSizedArray)": [\1]'),
        (r'"sinr \(StaticFixedSizedArray\)": \{([^}]+)\}', r'"sinr (StaticFixedSizedArray)": [\1]'),
        (r'"result \(StaticFixedSizedArray\)": \{([^}]+)\}', r'"result (StaticFixedSizedArray)": [\1]'),
    ]
    # Apply each pattern to the JSON text
    for pattern, replacement in patterns:
        json_text = re.sub(pattern, lambda m: re.sub(r'"UlData_srsPosReport_t\.[^"]+": "([^"]+)"',
                                                     r'"\1"', m.group(0)), json_text, flags=re.DOTALL)
        json_text = re.sub(pattern, replacement, json_text, flags=re.DOTALL)
    return json_text


def generate_new_json_from_raw(file_name):
    new_file_name = os.path.dirname(file_name) + "new_" + os.path.basename(file_name)
    with open(file_name, 'r') as f:
        raw_text = f.read()
        transformed_json_data = transform_json_structure(raw_text)
        with open(new_file_name, 'w') as new_file:
            new_file.write(transformed_json_data)
    return new_file_name


def generate_new_csv_name(file_name):
    new_file_name = (os.path.dirname(file_name) +
                     "new_" + os.path.basename(file_name).replace('.json', '.csv'))
    # write into header with {frame_number}, {frame_time_utc}, {sfn_cur_rsp}, {slot}, {subcellid}, {sequenceId},"
    # {result} {timeOffsetPosArray}, {rsrpArray}, {sinrArray}")
    with open(new_file_name, 'w') as csv_file:
        csv_file.write("frame_number, frame_time_utc, sfn, slot, subcellid, sequenceId, reliable, "
                       "timeOffsetPosArray, rsrpArray, sinrArray\n")
    return new_file_name


def get_srs_and_check_value(file_name, srsUePeriodicity='slots20', csrs=63, expected_startPrb=0, pci='none',
                            subcell_num=0, srs_cell_num=0):
    print(f"start to parse bip srs json file {file_name} and check value")
    new_file_name = generate_new_json_from_raw(file_name)
    new_csv_name = generate_new_csv_name(file_name)
    print(f"new json file name is {new_file_name}, new csv file name is {new_csv_name}")
    srsUePeriodicity_sfn = int((int(srsUePeriodicity[5:]) * 0.5)/10)
    toe_meas_num_for_pci = 0
    subcellid_list = []
    subcell_toe_dic = {}
    subcell_rsrp_dic = {}
    continuous_unreliable_num = 0
    total_reliable_num = 0
    with (open(new_file_name, 'r') as f):
        data = json.load(f)
        if len(data) <= 10:
            raise ValueError("No uldata_srsposreceiverespps data in the BIP log !!!")
        sfn_pre_rsp = 0
        sfn_cur_rsp = 0
        sfn_pre_req = 0
        sfn_cur_rep = 0
        frame_time_utc_pre = "NA"
        frame_time_utc_cur = "NA"
        for item in data:
            frame_number = item.get('_source').get('layers').get('frame').get('frame.number')
            frame_time_utc = item.get('_source').get('layers').get('frame').get('frame.time_utc')
            frame_time_utc_cur = frame_time_utc
            # first check if key is exist
            if "uldata_srsposreceivereq" in item['_source']['layers']['icom_5g']['nr_l1ul_l2ps']:
                srsposreceivereq = (item['_source']['layers']['icom_5g']['nr_l1ul_l2ps']['uldata_srsposreceivereq']
                                        ['nr_l1ul_l2ps_uldata_srsposreceivereq_t'])
                srsPosRequest = (
                    srsposreceivereq['srsPosReportRequests (DynamicVariableSizedArray)']
                    ['nr_l1ul_l2ps_uldata_srsposreportrequest_t']
                )
                sequenceId = srsPosRequest['UlData_srsPosReportRequest_t.sequenceId']
                if str(pci).find(str(sequenceId)) >= 0 or pci == 'none':
                    toe_meas_num_for_pci = toe_meas_num_for_pci + 1
                    sfn_cur_req = int(srsposreceivereq['3gpp.sfn'])
                    if sfn_cur_req != sfn_pre_req and sfn_pre_req != 0:
                        if sfn_cur_req < sfn_pre_req or (sfn_cur_rsp - sfn_pre_rsp) < 0:
                            srs_periodicity = sfn_cur_req + 1024 - sfn_pre_req
                        else:
                            srs_periodicity = sfn_cur_req - sfn_pre_req
                        if (srs_periodicity != srsUePeriodicity_sfn
                                and frame_time_utc_cur[0:-10] != frame_time_utc_pre[0:-10]):
                            print(f"frame_time_utc_cur: {frame_time_utc_cur}, frame_time_utc_pre: {frame_time_utc_pre}")
                            raise ValueError(f"srs_periodicity should be {srsUePeriodicity_sfn}*SFN(10ms), but got "
                                             f"{srs_periodicity} for frame {frame_number}")
                    sfn_pre_req = sfn_cur_req
                    frame_time_utc_pre = frame_time_utc_cur
                    slot = srsposreceivereq['3gpp.slot']
                    subcellid = srsposreceivereq['3gpp.subcellid']
                    startPrb = int(srsPosRequest['UlData_srsPosReportRequest_t.startPrb'])
                    numOfPrb = int(srsPosRequest['UlData_srsPosReportRequest_t.numOfPrb'])
                    print(f"{frame_number}, {frame_time_utc}, {sfn_cur_req}, {slot}, {subcellid}, {sequenceId}, "
                          f"{startPrb}, {numOfPrb}")
                    prb_value_should_expected(startPrb, numOfPrb, csrs, expected_startPrb, frame_number)
                    print(f"prb_start and prbNum value check pass for frame {frame_number}")
            elif "uldata_srsposreceiverespps" in item['_source']['layers']['icom_5g']['nr_l1ul_l2ps']:
                srsposreceiverespps = (
                    item['_source']['layers']['icom_5g']['nr_l1ul_l2ps']
                    ['uldata_srsposreceiverespps']['nr_l1ul_l2ps_uldata_srsposreceiverespps_t']
                )
                srsPosReport = (
                    srsposreceiverespps['srsPosReports (DynamicVariableSizedArray)']
                    ['nr_l1ul_l2ps_uldata_srsposreport_t']
                )
                sequenceId = srsPosReport['UlData_srsPosReport_t.sequenceId']
                if str(pci).find(str(sequenceId)) >= 0 or pci == 'none':
                    sfn_cur_rsp = int(srsposreceiverespps['3gpp.sfn'])
                    frame_time_utc_pre = frame_time_utc_cur
                    if sfn_cur_rsp != sfn_pre_rsp and sfn_pre_rsp != 0:
                        if sfn_cur_rsp < sfn_pre_rsp or (sfn_cur_rsp - sfn_pre_rsp) < 0:
                            srs_periodicity = sfn_cur_rsp - sfn_pre_rsp + 1024
                        else:
                            srs_periodicity = sfn_cur_rsp - sfn_pre_rsp
                        if (srs_periodicity != srsUePeriodicity_sfn
                                and frame_time_utc_cur[0:-10] != frame_time_utc_pre[0:-10]):
                            raise ValueError(f"srs_periodicity should be {srsUePeriodicity_sfn}*SFN(10ms), "
                                             f"but got {srs_periodicity}*SFN(10ms) for frame {frame_number}")
                    sfn_pre_rsp = sfn_cur_rsp
                    frame_time_utc_pre = frame_time_utc_cur
                    slot = srsposreceiverespps['3gpp.slot']
                    subcellid = srsposreceiverespps['3gpp.subcellid']
                    if subcellid not in subcellid_list:
                        subcellid_list.append(subcellid)
                    if subcellid not in subcell_toe_dic:
                        subcell_toe_dic[subcellid] = []
                    if subcellid not in subcell_rsrp_dic:
                        subcell_rsrp_dic[subcellid] = []
                    result = srsPosReport['result (StaticFixedSizedArray)']
                    timeOffsetPosArray = srsPosReport['timeOffsetPos (StaticFixedSizedArray)']
                    rsrpArray = srsPosReport['rsrp (StaticFixedSizedArray)']
                    sinrArray = srsPosReport['sinr (StaticFixedSizedArray)']
                    print(f"{frame_number}, {frame_time_utc}, {sfn_cur_rsp}, {slot}, {subcellid}, {sequenceId},"
                          f" {result} {timeOffsetPosArray}, {rsrpArray}, {sinrArray}")
                    # write toe frame scf slot subcellid sequenceId startPrb numOfPrb to csv file
                    with open(new_csv_name, 'a') as csv_file:
                        csv_file.write(f"{frame_number}, {frame_time_utc.replace(',','')}, {sfn_cur_rsp}, {slot},"
                                       f"{subcellid}, {sequenceId},{result[0]}, {timeOffsetPosArray[0]},"
                                       f"{rsrpArray[0]}, {sinrArray[0]}\n")
                    # 0-unrelaible 1-reliable
                    if int(result[0]) == 0:
                        continuous_unreliable_num = continuous_unreliable_num + 1
                    else:
                        subcell_toe_dic[subcellid].append(timeOffsetPosArray[0])
                        subcell_rsrp_dic[subcellid].append(rsrpArray[0])
                        total_reliable_num = total_reliable_num + 1
                    if int(result[0]) == 1 and continuous_unreliable_num >= 1:
                        print(f"WRN: srs toe report continuous_unreliable_num is {continuous_unreliable_num} !!!")
                    toe_value_should_expected(timeOffsetPosArray, result, rsrpArray, sinrArray, frame_number)
                    print(f"srs period and toe value check pass for frame {frame_number}")
            else:
                continue
    if total_reliable_num == 0:
        print(f"ERR, all toe is unreliable, please check and report PR !!!")
        raise ValueError(f"ERR, all toe is unreliable in bip log, please check and report PR !!!")
    if toe_meas_num_for_pci == 0:
        print(f"WRN: no toe report for pci {pci} in bip, please manual check this !!!")
        raise ValueError(f"no toe report for pci {pci} in bip, please manual check this !!!")
    elif pci != "none":
        print(f"total reliable toe num is {toe_meas_num_for_pci} for pci {pci}")
    else:
        print(f"total reliable toe num is {toe_meas_num_for_pci} for all cells")
    if subcell_num != 0 and len(subcellid_list) != subcell_num:
        print(f"WRN: expect {subcell_num} subcell toe report, but current only subcell_id {subcellid_list} in bp, !!!")
    else:
        print(f"all subcell_id {subcellid_list} toe report in bp")
    if srs_cell_num != 0 and len(subcellid_list) != (srs_cell_num + 1):
        print(f"WRN: expect {srs_cell_num} srs only cell toe report, but only {subcellid_list} report toe in bp, !!!")
    else:
        print(f"all srs only cell toe report in bp: {subcellid_list}")
    check_toe_value_should_be_stable(subcell_toe_dic)
    check_rsrp_value_should_be_stable(subcell_rsrp_dic)


def check_toe_value_should_be_stable(subcell_toe_dic: dict, average_threshold: float = 300.0):
    toe_statistics = get_min_max_average_toe(subcell_toe_dic)
    for subcellid, stats in toe_statistics.items():
        min_toe = stats['min']
        max_toe = stats['max']
        avg_toe = stats['average']

        if min_toe is None or max_toe is None or avg_toe is None:
            print(f"WRN: No valid TOE data for subcellid {subcellid} to check stability.")
            continue
        if is_90_percent_within_threshold(lst=subcell_toe_dic[subcellid], threshold=average_threshold):
            print(f"90% TOE value for subcellid {subcellid} is within threshold {average_threshold}.")
            gap_toe = float(max_toe) - float(min_toe)
            print(f"min_toe: {min_toe}, max_toe: {max_toe}, avg_toe: {avg_toe}, gap_toe: {gap_toe}")
            if gap_toe > average_threshold:
                print(f"WRN: Although 90% TOE value is within threshold, the overall TOE gap {gap_toe} "
                      f"exceeds threshold {average_threshold} for subcellid {subcellid}.")
        else:
            raise ValueError(f"90% TOE value for subcellid {subcellid} is not within threshold {average_threshold}.")


def is_90_percent_within_threshold(lst, threshold):
    n = len(lst)
    if n == 0:
        return False
    lst_sorted = sorted(lst, key=float)
    # print(f"original TOE/RSRP values: {lst_sorted}")
    # remove 5% of the data from both ends
    trim = int(n * 0.08)
    # print(f"remove {trim} values from each end from total {n} values")
    trimmed = lst_sorted[trim:n - trim] if n - 2 * trim > 0 else lst_sorted
    # print(f"trimmed TOE/RSRP values: {trimmed}")
    return float(max(trimmed)) - float(min(trimmed)) < threshold


def check_rsrp_value_should_be_stable(subcell_rsrp_dic: dict, average_threshold: float = 4.0):
    rsrp_statistics = get_min_max_average_rsrp(subcell_rsrp_dic)
    for subcellid, stats in rsrp_statistics.items():
        min_rsrp = stats['min']
        max_rsrp = stats['max']
        avg_rsrp = stats['average']
        if min_rsrp is None or max_rsrp is None or avg_rsrp is None:
            print(f"WRN: No valid RSRP data for subcellid {subcellid} to check stability.")
            continue
        if is_90_percent_within_threshold(lst=subcell_rsrp_dic[subcellid], threshold=average_threshold):
            print(f"90% RSRP value for subcellid {subcellid} is within threshold {average_threshold}.")
            gap_rsrp = float(max_rsrp) - float(min_rsrp)
            print(f"min_rsrp: {min_rsrp}, max_rsrp: {max_rsrp}, avg_rsrp: {avg_rsrp}, gap_rsrp: {gap_rsrp}")
            if gap_rsrp > average_threshold:
                print(f"WRN: Although 90% RSRP value is within threshold, the overall RSRP gap {gap_rsrp} "
                      f"exceeds threshold {average_threshold} for subcellid {subcellid}.")
        else:
            raise ValueError(f"90% RSRP value for subcellid {subcellid} is not within threshold {average_threshold}.")


def get_min_max_average_toe(subcell_toe_dic):
    toe_statistics_dic = {}
    for subcellid, toe_list in subcell_toe_dic.items():
        toe_values = [int(toe) for toe in toe_list if int(toe) != -32768]
        if toe_values:
            min_toe = min(toe_values)
            max_toe = max(toe_values)
            avg_toe = sum(toe_values) / len(toe_values)
            toe_statistics_dic[subcellid] = {
                'min': min_toe,
                'max': max_toe,
                'average': avg_toe
            }
        else:
            toe_statistics_dic[subcellid] = {
                'min': None,
                'max': None,
                'average': None
            }
    print(f"min_max_average_toe: {toe_statistics_dic}")
    return toe_statistics_dic


def get_min_max_average_rsrp(subcell_rsrp_dic):
    rsrp_statistics_dic = {}
    for subcellid, rsrp_list in subcell_rsrp_dic.items():
        if len(rsrp_list):
            rsrp_values = [float(x) for x in rsrp_list]
            min_rsrp = min(rsrp_values)
            max_rsrp = max(rsrp_values)
            avg_rsrp = sum(rsrp_values) / len(rsrp_values)
            rsrp_statistics_dic[subcellid] = {
                'min': min_rsrp,
                'max': max_rsrp,
                'average': avg_rsrp
            }
        else:
            rsrp_statistics_dic[subcellid] = {
                'min': None,
                'max': None,
                'average': None
            }
    print(f"min_max_average_rsrp: {rsrp_statistics_dic}")
    return rsrp_statistics_dic


def prb_value_should_expected(startPrb, numOfPrb, csrs=63, expected_startPrb=0, frame_number=0):
    if numOfPrb != CSRS_PRBNUM_MAPPING[csrs]:
        raise ValueError(f"numOfPrb should be {CSRS_PRBNUM_MAPPING[csrs]}, but got {numOfPrb} for sfn {frame_number}")
    if startPrb != expected_startPrb:
        raise ValueError(f"startPrb should be {expected_startPrb}, but got {startPrb} for frame {frame_number}")


def toe_value_should_expected(timeOffsetPosArray, result, rsrpArray, sinrArray, frame_number=0):
    if int(timeOffsetPosArray[0]) == -32768:
        raise ValueError(f"timeOffsetPosArray[0] should not be -32768 for frame {frame_number}")
    if int(timeOffsetPosArray[1]) != -32768:
        raise ValueError(f"timeOffsetPosArray[1] should be -32768 for frame {frame_number}")
    if int(timeOffsetPosArray[2]) != -32768:
        raise ValueError(f"timeOffsetPosArray[2] should be -32768 for frame {frame_number}")
    if int(timeOffsetPosArray[3]) != -32768:
        raise ValueError(f"timeOffsetPosArray[3] should be -32768 for frame {frame_number}")
    if int(result[0]) == 0 and int(rsrpArray[0]) != -157 and int(sinrArray[0]) <= 0:
        raise ValueError(f"UNRELIABLE toe but rsrp is not -157 for frame {frame_number}")


def get_current_utc_timestamp():
    timestamp = calendar.timegm(datetime.now(tz=pytz.timezone("UTC")).timetuple())
    print(timestamp)
    return timestamp


def change_format_for_utr_time(utc_time):
    # 2024-12-27 22:43:43.296-->2024_12_27_22_43_43_296
    return utc_time.replace(" ", "_").replace(":", "_").replace("-", "_").replace(".", "_")


def generate_rmod_lock_cm_list(rmod_dn_list):
    rmod_lock_list = []
    for rmod_dn in rmod_dn_list:
        rmod_lock_list.append(dict(dist_name=rmod_dn, parameter='administrativeState',
                                   value='Locked', operation='update'))
    return rmod_lock_list


def generate_rmod_unlock_cm_list(rmod_dn_list):
    rmod_unlock_list = []
    for rmod_dn in rmod_dn_list:
        rmod_unlock_list.append(dict(dist_name=rmod_dn, parameter='administrativeState',
                                     value='Unlocked', operation='update'))
    return rmod_unlock_list


def update_imsi_in_xml(file_path, new_imsi):
    """
    Updates the IMSI value in the given XML file.

    :param file_path: Path to the XML file.
    :param new_imsi: New IMSI value to set.
    """
    # Parse the XML file
    tree = ET.parse(file_path)
    root = tree.getroot()

    # Find the <msid> element with type="IMSI"
    msid_element = root.find(".//msid[@type='IMSI']")
    if msid_element is not None:
        # Update the IMSI value
        msid_element.text = new_imsi
        # Save the updated XML back to the file
        tree.write(file_path, encoding="UTF-8", xml_declaration=True)
        print(f"IMSI updated to {new_imsi} in {file_path}")
    else:
        print("IMSI element not found in the XML file.")


if __name__ == '__main__':
    get_srs_and_check_value(file_name="bip_srs_2025_12_18_08_33_43_449.json", srsUePeriodicity='slots20',
                            csrs=63, expected_startPrb=0,
                            pci=62, subcell_num=0, srs_cell_num=0)
