from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.pcap.pcap_common import pdml_file_to_dict, \
    pdml_file_to_list, get_packet
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.pcap.pcap_common import sequence_in_packets, \
    sequence_in_packets_list


def get_attenuation_beam(beam, beamset):
    ret_str = ""
    for i in range(beamset):
        if i == beam:
            ret_str += '\\x05'
        else:
            ret_str += '\\x0F'
    for i in range(40 - beamset):
        ret_str += '\\xFF'

    ret_str = "'" + ret_str + "'"
    return ret_str


def beamset_2_checking(path):
    field_names = ['DlData_SsBlockSendReq']
    packets_dict = pdml_file_to_dict(path, field_names)
    pattern_ids = [('21', '26')]
    items = [('patternId_item_0', 'patternId_item_1')]

    return sequence_in_packets(packets_dict, items, pattern_ids)


def beamset_6_checking(path):
    field_names = ['DlData_SsBlockSendReq']
    packets_dict = pdml_file_to_dict(path, field_names)
    pattern_ids = [('0x0047', '0x004c'),
                   ('0x0051', '0x0056'),
                   ('0x005b', '0x0060')]
    items = [('patternId_item_0', 'patternId_item_1') for x in range(3)]

    return sequence_in_packets(packets_dict, items, pattern_ids)


def decimal_to_hex(dec, num_len=4):
    """
    Creates hex num with user len
    decimal_to_hex(15,4) -> 0x000f
    decimal_to_hex(15,3) -> 0x00f
    """
    hexx = hex(dec)
    while len(hexx) < num_len + 2:
        hexx = hexx[:2] + '0' + hexx[2:]
    return hexx


def create_pattern_id_list(first_num, n):
    ret_list = []
    for i in range(n):
        ret_list.append(first_num)
        first_num += 5
    return ret_list


def beamset_2_sspbch_checking(path):
    """    commit before changes: e6bc5ec8
    earlier pattern_ids = ['0x02c7', '0x02cc', '0x02d1', '0x02d6'] was in HEX
    now     pattern_ids = ['711','716','721','726'] is in DEC
    """
    field_names = ['DlData_PdcchSendReq',
                   'DlData_SsBlockSendReq',
                   'UlData_pucchReceiveRespPsPucchResource',
                   '3gpp.rnti']
    # pattern_ids = create_pattern_id_list(711, 4)
    pattern_ids = [711, 716, 0, 0, 721, 726, 0, 0]
    items = [('patternId_item_0', 'patternId_item_1', 'patternId_item_2', 'patternId_item_3') for x in range(2)]
    # pattern_tuples = [(pattern_ids[2 * x], pattern_ids[2 * x + 1]) for x in range(2)]
    pattern_tuples = [(711, 716, 0, 0), (721, 726, 0, 0)]

    packets_dict = pdml_file_to_dict(path, field_names)

    packet = get_packet(packets_dict, ('packet_name_', 'dtx', 'pucchFormat'),
                        ('UlData_pucchReceiveRespPsPucchResource', 'NON_DTX', 'PUCCH_FORMAT_2'))
    # print(f"packet UlData_pucchReceiveRespPsPucchResource:\n{packet}")    #print to debug
    if packet is None:
        print(
            "packet UlData_pucchReceiveRespPsPucchResource with dtx=NON_DTX, pucchFromat=PUCCH_FORMAT_2 not found"
            )
        return False
    rnti = packet['rnti']
    # print(f"packet['rnti']:\n{rnti}")    #print to debug

    packet = get_packet(packets_dict, ('packet_name_', 'rnti'), ('DlData_PdcchSendReq', rnti))
    # print(f"packet DlData_PdcchSendReq:\n{packet}")    #print to debug

    if packet is None:
        print("packet DlData_PdcchSendReq with correct rnti not found")
        return False
    beamId = int(packet['beamId'], 16)
    pattern_beamId = f"patternId_item_{beamId}"
    print(
        f"For rnti {rnti}: beamId = {beamId}, so {pattern_beamId} and value {pattern_ids[beamId]} will be analyzing..."
        )

    # print(f"packets_dict:\n\n{packets_dict}")    #print to debug

    if any(pattern_beamId in v and v[pattern_beamId] == str(pattern_ids[beamId]) for v in packets_dict.values()):
        print('Test passed!')
        return True
    else:
        print("not correct patternId for this beamId")
        return False

    return sequence_in_packets(packets_dict, items, pattern_tuples)


def SgNB_addition_to_NSA_cell_check(path):
    field_names = ['X2AP', 'F1AP']
    packets_list = pdml_file_to_list(path, field_names)

    if not sequence_in_packets_list(packets_list, ['x2ap.SgNBAdditionRequest_element',
                                                   'f1ap.UEContextSetupRequest_element']):
        return False

    if not sequence_in_packets_list(packets_list, [('x2ap.SgNBReconfigurationComplete_element',
                                                    'nr-rrc.RRCReconfigurationComplete_element'),
                                                   'x2ap.SNStatusTransfer_element']):
        return False
    return True


def beamset_4_l3call_best_beam_check(path):
    return l3call_best_beam_check(path, numOfBitsUciInf='0x0f', first_pattern=51, beams_count=4)


def beamset_6_l3call_best_beam_check(path):
    return l3call_best_beam_check(path, numOfBitsUciInf='0x11', first_pattern=101, beams_count=6)


def l3call_best_beam_check(path, numOfBitsUciInf, first_pattern, beams_count):
    field_names = ['DlData_PdcchSendReq', 'UlData_PucchReceiveReq', 'UlData_PucchReceiveRespPs',
                   'DlData_PdschSendReq', 'UlData_PucchReceiveRespHarqD']
    packets_dict = pdml_file_to_dict(path, field_names)
    pattern_ids = create_pattern_id_list(first_pattern, beams_count)

    # 3. gNB is informed about Ue selected best SSB beam and its RSRP,
    print('STEP: gNB is informed about Ue selected best SSB beam and its RSRP\n')
    items_to_check = ('packet_name_', 'pucchFormat', 'numOfBitsOfUciInformation')
    values_to_check = ('UlData_PucchReceiveReq', '2', numOfBitsUciInf)
    packet = get_packet(packets_dict, items_to_check, values_to_check)

    print('packet:', packet)
    if packet is None:
        print('UlData_PucchReceiveReq with slotForProcessing, numOfBitsOfUciInformation is None')
        return False
    print('UlData_PucchReceiveReq with slotForProcessing, numOfBitsOfUciInformation is Okay')

    rnti = packet['rnti']
    sfn = packet['sfn']
    patternId = packet['patternId_item_0']
    slotForProc = packet['slotForProcessing']

    print('rnti:', rnti, 'sfn:', sfn, 'slotForProcessin:', slotForProc, 'patternId_item_0:', patternId)

    if pattern_ids.count(patternId) == 0:
        print('patternId not found in pattern ids list')
        return False
    beamId = pattern_ids.index(patternId)

    items_to_check = ('packet_name_', 'sfn', 'rnti', 'slotForProcessing', 'crc')
    values_to_check = ('UlData_PucchReceiveRespPs', sfn, rnti, slotForProc, '0')
    packet = get_packet(packets_dict, items_to_check, values_to_check)

    print('packet:', packet)
    if packet is None:
        print('UlData_PucchReceiveRespPs with correct sfn, rnti, slotForProcessing is None')
        return False
    print('UlData_PucchReceiveRespPs with correct sfn, rnti, slotForProcessing is Okay')

    # 2. Ue connected to the cell via PRACH procedure,
    print('STEP: Ue connected to the cell via PRACH procedure\n')
    packet_msg4 = get_packet(packets_dict, ('packet_name_', 'beamId'),
                             ('DlData_PdcchSendReq', '0x0'+str(beamId)))
    if packet_msg4 is None:
        print('DlData_PdcchSendReq with beamId is None', 'correct beamId:', beamId)
        return False

    beamId = int(packet_msg4['beamId'], 16)
    print(packet_msg4)
    if patternId != pattern_ids[beamId]:
        print(pattern_ids, 'patternId:', patternId, 'beamId:', beamId)
        print('PatternId is not correct for this beamId')
        return False
    print('PatternId is correct for this beamId')

    items_to_check = ('packet_name_', 'slotForProcessing', 'rnti', 'crc')
    values_to_check = ('UlData_PucchReceiveRespPs', slotForProc, rnti, '0')
    packet = get_packet(packets_dict, items_to_check, values_to_check)
    if packet is None:
        print('UlData_PucchReceiveRespPs with slotForProcessing, rnti, crc=0 is None')
        return False

    print('UciBits_item_0:', packet['uciBits_item_0'], 'UciBits_item_1:', packet['uciBits_item_1'])

    if packet['uciBits_item_0'] == '0x00' and packet['uciBits_item_1'] == '0x00':
        print('UlData_PucchReceiveRespPs uciBits_items are 0x00')
        return False
    print('UlData_PucchReceiveRespPs uciBits_items are not 0x00 (correct result)')

    # 4. Initiated data traffic (DL and UL) is close to theoretical estimations for the given configuration
    print('STEP: Initiated data traffic (DL and UL) is close to theoretical estimations for the given configuration\n')

    items_to_check = ('packet_name_', 'rnti')
    values_to_check = ('DlData_PdschSendReq', rnti)
    if get_packet(packets_dict, items_to_check, values_to_check) is None:
        print('DlData_PdschSendReq with specific rnti is None')
        print(values_to_check)
        return False
    print('DlData_PdschSendReq with specific rnti is Okay')

    items_to_check = ('packet_name_', 'rnti', 'crc')
    values_to_check = ('UlData_PucchReceiveRespHarqD', rnti, '0')
    if get_packet(packets_dict, items_to_check, values_to_check) is None:
        print('UlData_PucchReceiveRespHarqD with specific rnti and crc=0 is None')
        print(values_to_check)
        return False
    print('UlData_PucchReceiveRespHarqD with specific rnti and crc=0 is Okay')

    return True


def UE_beamSet_beam_tracking_best_beam_beamset2(path_to_pcaps):
    beamset_beam_tracking_best_beam(path_to_pcaps, numOfBitsUciInf='0x0d', pattern_id_beam0='0x0015', beams_count=2)


def UE_beamSet_beam_tracking_best_beam_beamset4(path_to_pcaps):
    beamset_beam_tracking_best_beam(path_to_pcaps, numOfBitsUciInf='0x0f', pattern_id_beam0='0x001f', beams_count=4)


def UE_beamSet_beam_tracking_best_beam_beamset6(path_to_pcaps):
    beamset_beam_tracking_best_beam(path_to_pcaps, numOfBitsUciInf='0x11', pattern_id_beam0='0x0065', beams_count=6)


def ue_beamId_attached_verification(pcap_path, pattern_id, rnti, numOfBitsUciInf):
    field_names = ['UlData_PucchReceiveReq', 'DlData_PdschSendReq']
    packets_dict = pdml_file_to_dict(pcap_path, field_names)

    items = ('packet_name_', 'pucchFormat',
             'numOfBitsOfUciInformation', 'patternId_item_0', 'rnti')
    values = ('UlData_PucchReceiveReq', '2', numOfBitsUciInf, pattern_id, rnti)
    packet = get_packet(packets_dict, items, values)

    if packet is None:
        print('UlData_PucchReceiveReq with pucchFormat=2, numOfBitsOfUciInformation, patternId, rnti is None')
        return False
    print('UlData_PucchReceiveReq with pucchFormat, numOfBitsOfUciInformation, patternId is Okay')

    items = ('packet_name_', 'rnti')
    values = ('DlData_PdschSendReq', rnti)
    packet = get_packet(packets_dict, items, values)

    if packet is None:
        print('DlData_PdschSendReq with correct rnti is None')
        return False
    print('DlData_PdschSendReq with correct rnti is Okay')

    sfn = packet['sfn']
    print('DlData_PdschSendReq sfn:', sfn)

    items = ('packet_name_', 'sfn', 'rnti', 'crc')
    values = ('DlData_PdschSendReq', sfn, rnti, '0')
    packet = get_packet(packets_dict, items, values)
    return True


def beamset_beam_tracking_best_beam(pcaps_path, numOfBitsUciInf='0x0d', pattern_id_beam0='0x0015', beams_count=2):
    pattern_ids = create_pattern_id_list(int(pattern_id_beam0), beams_count)

    # 3. gNB is informed about Ue selected best SSB beam and its RSRP
    print('STEP: 3. gNB is informed about Ue selected best SSB beam and its RSRP\n')
    field_names = ['UlData_PucchReceiveReq', 'UlData_PucchReceiveRespPs']
    packets_dict = pdml_file_to_dict(pcaps_path + 'L1L2Abil.pcap', field_names)

    items = ('packet_name_', 'pucchFormat',
             'numOfBitsOfUciInformation', 'patternId_item_0')
    values = ('UlData_PucchReceiveReq', '2', numOfBitsUciInf, pattern_ids[0])
    packet = get_packet(packets_dict, items, values)

    if packet is None:
        print('UlData_PucchReceiveReq with pucchFormat=2, numOfBitsOfUciInformation, patternId is None')
        return False
    print(packet)
    print('UlData_PucchReceiveReq with pucchFormat, numOfBitsOfUciInformation, patternId is Okay')

    sfn = packet['sfn']
    rnti = packet['rnti']
    slotForProc = packet['slotForProcessing']
    print('sfn:', sfn, 'rnti:', rnti, 'slotForProcessing:', slotForProc)

    items = ('packet_name_', 'sfn', 'rnti', 'slotForProcessing', 'crc')
    values = ('UlData_PucchReceiveRespPs', sfn, rnti, slotForProc, '0')
    packet = get_packet(packets_dict, items, values)

    if packet is None:
        print('UlData_PucchReceiveRespPs with crc=0 and correct sfn, rnti, slotForProcessing is None')
        return False
    print(packet)
    print('UlData_PucchRespPs with crc=0 and correct sfn, rnti, slotForProcessing is Okay')

    uciBits_0 = packet['uciBits_item_0']
    uciBits_1 = packet['uciBits_item_1']
    print('uciBits_item_0:', uciBits_0, 'uciBits_item_1:', uciBits_1)

    if packet['uciBits_item_0'] == '0x00' and packet['uciBits_item_1'] == '0x00':
        print('uciBits_item_0 and uciBits_item_1 = 0x00')
        return False

    # 4. Initiated data traffic -  DL and UL - is close to theoretical estimations for the given configuration
    print('STEP 4. Initiated data traffic -DL and UL- is close to theoretical estimations for the given configuration')
    field_names = ['DlData_PdschSendReq', 'DlData_PucchReceiveRespHarqD']
    packets_dict = pdml_file_to_dict(pcaps_path + 'beam0.pcap', field_names)

    items = ('packet_name_')
    values = ('DlData_PdschSendReq')
    packet = get_packet(packets_dict, items, values)
    if packet is None:
        print('DlData_PdschSendReq packet is None')
        return False

    rnti = packet['rnti']
    sfn = packet['sfn']
    print('DlData_PdschSendReq rnti:', rnti, 'sfn:', sfn)

    items = ('packet_name_', 'rnti', 'sfn', 'crc')
    values = ('DlData_PucchReceiveRespHarqD', rnti, sfn, '0')
    packet = get_packet(packets_dict, items, values)

    if packet is None:
        print('DlData_PucchReceiveRespHarqD with crc=0 and correct rnti, sfn is None')
        return False
    print('DlData_PucchReceiveRespHarqD with crc=0 and correct rnti, sfn is Okay')

    # 6. and next: Ue beam1 attached verification, DL and UL tput maintained
    for i in range(1, beams_count):
        print('STEP Ue beam number', i,
              'attached verification, DL and UL tput maintained')

        if not ue_beamId_attached_verification(pcaps_path + 'beam' + str(i) + '.pcap', pattern_ids[i], rnti,
                                               numOfBitsUciInf):
            print('Failed on beam number:', i)
            return False
    return True
